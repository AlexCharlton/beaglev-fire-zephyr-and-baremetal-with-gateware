#include <zephyr/device.h>
#include <zephyr/drivers/flash.h>
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
#include <stdio.h>

LOG_MODULE_REGISTER(flash_erase_example, LOG_LEVEL_INF);

void main(void)
{
	const struct device *flash_dev;
	int ret;

	/* Get the flash device defined in the device tree */
	flash_dev = DEVICE_DT_GET(DT_NODELABEL(sys_ctrl_flash));

	if (!device_is_ready(flash_dev))
	{
		printf("Flash device not ready\n");
		return;
	}
	printf("Flash device ready\n");

	/*
		uint32_t buffer[3]; // Array to hold three 32-bit values (12 bytes total)

		ret = flash_read(flash_dev, 0x0, buffer, sizeof(buffer));
		if (ret != 0)
		{
			printf("Flash read failed: %d\n", ret);
			return;
		}

		for (int i = 0; i < 3; i++)
		{
			printf("Address 0x%08x: 0x%08x\n", i * 4, buffer[i]);
		}
	*/

	off_t offset = 0x0;	   // Start at the beginning of the flash (block 0)
	size_t size = 0x10000; // Erase 1 block (adjust to block size, typically 64 KB for SPI NOR)

	/* Erase the flash block */
	printf("Erasing flash: offset=0x%lx, size=%zu\n", offset, size);
	ret = flash_erase(flash_dev, offset, size);
	if (ret != 0)
	{
		printf("Flash erase failed: %d\n", ret);
	}
	else
	{
		printf("Flash erase successful\n");
	}
}
