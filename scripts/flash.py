import os
from pathlib import Path
import time
import subprocess
import multiprocessing
import getpass
import sys
import textwrap
from ctypes import windll
import select


class FlashPayload:
    def __init__(self):
        self.name = "flash-payload"
        self.help = "flash a payload to the board's eMMC"
        self.description = """ \
            flash-payload is an interactive command that will guide a
            user through flashing a payload on to a board's eMMC.
            It does this through interacting with the Hart Software
            Services (HSS), by:
            1. Prompting the user to power on the device:w
            2. Interrupting the HSS from booting
            3. Issues the commands to mount the eMMC as a block device
                on the host
            4. Finds the device on the host and prompts the user to
               verify the device
            5. Writes the payload to the eMMC using dd command
            6. On completion, sends the boot command to the HSS to boot
                the payload
            """
        self.base_path = Path.cwd()

    @staticmethod
    def parse_args():
        import argparse
        parser = argparse.ArgumentParser(
            description="Flash payload to board's eMMC"
        )
        parser.add_argument("payload", help="payload binary, ex: output.bin")
        parser.add_argument("port_name", help="serial port, ex: /dev/ttyS4")
        return parser.parse_args()


    def read_phrase(self, phrase, timeout=60):
        """
        Reads lines from tio output, looking for a specific phrase.
        Uses different approaches for Windows vs Unix platforms.

        Args:
            phrase: String to look for in the output
            timeout: Maximum time to wait in seconds (default: 60)

        Returns:
            The line containing the phrase if found

        Raises:
            TimeoutError: If phrase isn't found within timeout period
            KeyboardInterrupt: If user interrupts with Ctrl+C
        """
        start_time = time.time()
        buffer = ""

        try:
            while True:
                if time.time() - start_time > timeout:
                    raise TimeoutError(f"Timeout waiting for phrase: {phrase}")

                # Windows-specific reading approach
                if sys.platform == 'win32':
                    chunk = self.tio_process.stdout.read1().decode()
                else:
                    # Unix platforms can use select
                    ready, _, _ = select.select([self.tio_process.stdout], [], [], 0.1)
                    chunk = self.tio_process.stdout.read1().decode() if ready else ""

                if chunk:
                    buffer += chunk
                    print(f"buffer: {buffer}")
                    if phrase in buffer:
                        print(f"\nhss: {phrase}")
                        return buffer

                # Small sleep to prevent CPU spinning
                time.sleep(0.1)

        except KeyboardInterrupt:
            print("\nOperation cancelled by user")
            if hasattr(self, 'tio_process'):
                self.tio_process.terminate()
            raise

    def send_ctrl_c(self):
        """
        Sending CTRL+C through tio
        """
        self.tio_process.stdin.write(b"\x03")
        self.tio_process.stdin.flush()
        print("sent CTR+C\r\n")
        self.device_settling_time(5)

    def send_phrase(self, phrase):
        """
        Writes a phrase to tio. Handles both bytes and string input.
        """
        try:
            if isinstance(phrase, bytes):
                self.tio_process.stdin.write(phrase)
            else:
                self.tio_process.stdin.write(phrase.encode())
            self.tio_process.stdin.flush()
            print(f"sent: {phrase}")
            time.sleep(1)
            self.device_settling_time(5)
            return len(phrase)
        except Exception as e:
            print(f"Failed to send phrase: {e}")
            return -1

    def power_on_message_prompt(self):
        """
        Message printed to the console prompting a user to power on
        their device. Gets called in a process, so it's non blocking
        """
        print("power on your device:")
        start_time = time.time()
        while time.time() - start_time < 60:
            time.sleep(1)
            print(".", end="", flush=True)

    def hss_confirm_connection(self):
        """
        The first output from the Hart Software Services (HSS) application.
        When this is captured from the serial port, we can terminate
        the power on message prompt process
        """
        self.read_phrase(
            "PolarFire(R) SoC Hart Software Services (HSS)"
        )

    def hss_interrupt(self):
        """
        The HSS gives the user an oppertunity to interrupt the boot procedure
        by pressing any key within a given time period. Wait to be prompted,
        then send a character.
        """
        self.read_phrase(
            "Press a key to enter CLI, ESC to skip"
        )
        self.send_phrase("c\r\n")
        self.read_phrase(
            "Type HELP for list of commands"
        )

    def hss_mount_mmc(self):
        """
        The HSS can choose to unpack from the eMMC or SD Card. In this
        case, we want to boot from eMMC
        """
        self.send_phrase("mmc\r\n")
        self.read_phrase(
            "Selecting SDCARD/MMC (fallback) as boot source"
        )
        self.send_phrase("usbdmsc\r\n")
        self.read_phrase(
            "Attempting to select eMMC"
        )

    def hss_boot(self):
        """
        Writing to the eMMC is done, send the ctrl+c sequence, then
        instruct the HSS to boot
        """
        self.send_ctrl_c()
        self.send_phrase("boot\r\n")

    def get_user_input(self):
        while True:
            user_input = input(
                "Please enter 'y' for yes or 'n' for no: "
            ).lower()
            if user_input == "y" or user_input == "n":
                return user_input
            else:
                print("Invalid input. Please enter 'y' for yes or 'n' for no.")

    def set_serial(self, baudrate=115200):
        """
        Sets up the tio connection for the HSS.
        """
        try:
            port = self.port_name
            if sys.platform == 'win32':
                port = port.replace('/??/', '')

            print(f"Connecting to serial port: {port}")
            # Start tio in the background
            self.tio_process = subprocess.Popen(
                ["tio", "-b", str(baudrate), port],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            return 0
        except Exception as e:
            print(f"please check your tio connection: {port}", e)
            return e.errno


    def write_to_emmc(self, devname):
        """
        Writes the payload directly to eMMC using dd command
        """
        command = [
            "dd",
            f"if={self.payload}",
            f"of={devname}",
            "bs=4M",
            "status=progress",
            "oflag=sync"
        ]
        try:
            subprocess.run(command, check=True)
            return 0
        except subprocess.CalledProcessError as e:
            raise Exception(
                "Failed to write to eMMC. Check connections and power cycle before trying again\n"
                f"Error: {str(e)}"
            )

    def list_sd_devices(self):
        """
        Lists all devices in /dev that start with 'sd' on Unix
        or lists available drives on Windows
        Returns a set of device paths
        """
        if sys.platform == 'win32':
            # Get bitmask of available drives
            bitmask = windll.kernel32.GetLogicalDrives()
            drives = set()
            # Check each possible drive letter (A-Z)
            for letter in range(ord('A'), ord('Z') + 1):
                if bitmask & (1 << (letter - ord('A'))):
                    drive = f"{chr(letter)}:\\"
                    # GetDriveType returns 2 for removable drives
                    if windll.kernel32.GetDriveTypeW(drive) == 2:  # DRIVE_REMOVABLE
                        drives.add(drive)
            return drives
        else:
            dev_path = os.path.dirname(self.port_name)
            return {
                os.path.join(dev_path, f)
                for f in os.listdir(dev_path)
                if f.startswith('sd')
            }

    def wait_for_new_device(self, original_devices, timeout=60):
        """
        Continuously checks for new devices for up to timeout seconds
        Returns the new device path if found and confirmed, None if timeout reached
        """
        print("\nWaiting for new block device", end="")
        start_time = time.time()

        while time.time() - start_time < timeout:
            print(".", end="", flush=True)
            current_devices = self.list_sd_devices()
            new_devices = current_devices - original_devices

            if new_devices:
                for device in new_devices:
                    print(f"\nFound new device: {device}")
                    print("Is this the correct device?")
                    if self.get_user_input() == "y":
                        return device
            time.sleep(1)

        return None

    def do_run(self, args):
        self.payload = args.payload
        self.port_name = args.port_name
        self.set_serial()

        # Get initial list of devices
        initial_devices = self.list_sd_devices()
        print("Initial devices:", initial_devices)
        print("Restart your board now")
        self.hss_confirm_connection()

        self.hss_interrupt()
        self.hss_mount_mmc()

        # Wait for new device to appear
        devname = self.wait_for_new_device(initial_devices)
        if not devname:
            print("\nTimed out waiting for new block device")
            exit(-1)

        while self.write_to_emmc(devname):
            print("...\n")

        self.hss_boot()

        print("how about that!")


if __name__ == "__main__":
    args = FlashPayload.parse_args()
    flash = FlashPayload()
    flash.do_run(args)