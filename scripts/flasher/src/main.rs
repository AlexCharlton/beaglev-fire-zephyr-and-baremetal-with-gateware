use crossterm::event::{self, Event, KeyEvent};
use crossterm::terminal::{disable_raw_mode, enable_raw_mode};
use std::env;
use std::io::{self, Read, Write};
use std::time::Duration;

// TODO
// Use the bottom line of the terminal to be a status line
// that shows help text, and the status of the flasher
// Can be TERMINAL mode
// or FLASH mode, where we also display where we are in the flash process
// CTRL-M toggles between modes

enum Mode {
    Terminal,
    Flash,
}

enum FlashState {
    HssBooted,
    HssInterruptPrompt,
    // HssPrompt,
    UsbHostConnecting,
    Unknown,
}

fn spawn_reader_thread(mut port: Box<dyn serialport::SerialPort>) {
    std::thread::spawn(move || {
        let mut serial_log: Vec<String> = Vec::new();
        let mut current_line = String::new();
        let mut serial_buf = [0u8; 1000];
        let mut current_state = FlashState::Unknown;

        loop {
            if let Ok(bytes_read) = port.read(&mut serial_buf) {
                if bytes_read > 0 {
                    let data = String::from_utf8_lossy(&serial_buf[..bytes_read]);
                    print!("{}", data); // Print immediately for real-time output
                    io::stdout().flush().unwrap();

                    // Process the data character by character
                    for c in data.chars() {
                        if c == '\n' {
                            // Push the completed line to the vector
                            current_state =
                                handle_line(current_state, &mut port, &current_line).unwrap();
                            serial_log.push(current_line.clone());
                            current_line.clear();
                        } else if c != '\r' {
                            // Skip carriage returns
                            current_line.push(c);
                        }
                    }
                }
            }
        }
    });
}

fn handle_line(
    current_state: FlashState,
    port: &mut Box<dyn serialport::SerialPort>,
    line: &str,
) -> Result<FlashState, io::Error> {
    if line.contains("PolarFire(R) SoC Hart Software Services (HSS)") {
        return Ok(FlashState::HssBooted);
    }
    if line.contains("Press a key to enter CLI, ESC to skip") {
        port.write_all("c\r\n".as_bytes())?;
        return Ok(FlashState::HssInterruptPrompt);
    }
    if line.contains("Type HELP for list of commands") {
        port.write_all("mmc\r\n".as_bytes())?;
        port.write_all("usbdmsc\r\n".as_bytes())?;
        return Ok(FlashState::UsbHostConnecting);
    }
    Ok(current_state)
}

fn handle_key_event(
    port_writer: &mut Box<dyn serialport::SerialPort>,
    key_event: KeyEvent,
    char_count: &mut usize,
) -> io::Result<bool> {
    match key_event {
        KeyEvent {
            code: crossterm::event::KeyCode::Char('t'),
            modifiers: crossterm::event::KeyModifiers::CONTROL,
            ..
        } => Ok(true),

        KeyEvent {
            code: crossterm::event::KeyCode::Char('c'),
            modifiers: crossterm::event::KeyModifiers::CONTROL,
            kind: crossterm::event::KeyEventKind::Press,
            ..
        } => {
            port_writer.write_all(&[0x03])?;
            *char_count = 0;
            Ok(false)
        }

        KeyEvent {
            code,
            kind: crossterm::event::KeyEventKind::Press | crossterm::event::KeyEventKind::Repeat,
            ..
        } => {
            match code {
                crossterm::event::KeyCode::Char(c) => {
                    port_writer.write_all(&[c as u8])?;
                    *char_count += 1;
                }
                crossterm::event::KeyCode::Enter => {
                    port_writer.write_all(&[0x0d])?;
                    *char_count = 0;
                }
                crossterm::event::KeyCode::Backspace => {
                    if *char_count > 0 {
                        port_writer.write_all(&[0x08])?;
                        print!("\x08");
                        io::stdout().flush()?;
                        *char_count -= 1;
                    }
                }
                crossterm::event::KeyCode::Esc => port_writer.write_all(&[0x1b])?,
                _ => {}
            }
            Ok(false)
        }

        _ => Ok(false),
    }
}

fn setup_serial_port(
    port_name: &str,
) -> Result<Box<dyn serialport::SerialPort>, serialport::Error> {
    serialport::new(port_name, 115_200)
        .timeout(Duration::from_millis(10))
        .open()
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    enable_raw_mode()?;

    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <port>", args[0]);
        std::process::exit(1);
    }
    let port_name = &args[1];

    let port = setup_serial_port(port_name)?;
    println!("Connected to {}. Press Ctrl-T to exit.", port_name);

    let port_reader = port.try_clone()?;
    spawn_reader_thread(port_reader);

    let mut port_writer = port;
    let mut char_count = 0;

    loop {
        if event::poll(Duration::from_millis(2))? {
            if let Event::Key(key_event) = event::read()? {
                if handle_key_event(&mut port_writer, key_event, &mut char_count)? {
                    break;
                }
            }
        }
    }

    disable_raw_mode()?;
    Ok(())
}
