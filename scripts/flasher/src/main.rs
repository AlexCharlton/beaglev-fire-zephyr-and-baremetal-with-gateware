use crossterm::event::{self, Event, KeyEvent};
use crossterm::terminal::{disable_raw_mode, enable_raw_mode};
use std::env;
use std::io::{self, Read};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Enable raw mode
    enable_raw_mode()?;

    // Get port name from command line arguments
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <port>", args[0]);
        std::process::exit(1);
    }
    let port_name = &args[1];

    // Open serial port
    let port = serialport::new(port_name, 115_200)
        .timeout(Duration::from_millis(10))
        .open()?;

    println!("Connected to {}. Press Ctrl-C to exit.", port_name);

    // Create separate thread for reading from serial port
    let mut port_reader = port.try_clone()?;
    std::thread::spawn(move || {
        let mut serial_buf = [0u8; 1000];
        loop {
            if let Ok(bytes_read) = port_reader.read(&mut serial_buf) {
                if bytes_read > 0 {
                    print!("{}", String::from_utf8_lossy(&serial_buf[..bytes_read]));
                }
            }
        }
    });

    // Main thread handles keyboard input
    let mut port_writer = port;

    loop {
        // Reduce polling timeout to make ctrl-c more responsive
        if event::poll(Duration::from_millis(10))? {
            match event::read()? {
                // Add check for ctrl-c
                Event::Key(KeyEvent {
                    code: crossterm::event::KeyCode::Char('c'),
                    modifiers: crossterm::event::KeyModifiers::CONTROL,
                    ..
                }) => {
                    disable_raw_mode()?;
                    return Ok(());
                }
                Event::Key(KeyEvent { code, .. }) => {
                    // Handle the key event
                    if let crossterm::event::KeyCode::Char(c) = code {
                        port_writer.write_all(&[c as u8])?;
                    }
                    // TODO handle other keys
                }
                _ => {}
            }
        }
    }

    // Cleanup
    disable_raw_mode()?;
    Ok(())
}
