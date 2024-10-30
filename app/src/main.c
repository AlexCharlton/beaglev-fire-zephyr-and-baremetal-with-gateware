#include <stdio.h>
#include <zephyr/device.h>
#include <zephyr/drivers/uart.h>
#include <zephyr/kernel.h>

int main(void)
{
	const struct device *uart_dev = DEVICE_DT_GET(DT_CHOSEN(zephyr_console));
	if (!device_is_ready(uart_dev)) {
		return 1;
	}

	uart_poll_out(uart_dev, 'H');
	uart_poll_out(uart_dev, 'e');
	uart_poll_out(uart_dev, 'l');
	uart_poll_out(uart_dev, 'l');
	uart_poll_out(uart_dev, 'o');
	// printk("Hello from UART1!\n");
	while (1) {
		k_sleep(K_MSEC(1000));
	}

	return 0;
}