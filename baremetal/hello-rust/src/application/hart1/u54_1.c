#include <stdio.h>
#include <string.h>
#include "mpfs_hal/mss_hal.h"
#include "drivers/mss/mss_mmuart/mss_uart.h"

void u54_1(void)
{
    // Basic hart setup
    clear_soft_interrupt();
    set_csr(mie, MIP_MSIP);
    // Initialize PLIC and enable interrupts
    PLIC_init();
    __enable_irq();

    // Configure clocks for UART0
    mss_config_clk_rst(MSS_PERIPH_MMUART0, (uint8_t)MPFS_HAL_FIRST_HART, PERIPHERAL_ON);

    // Initialize UART0
    MSS_UART_init(&g_mss_uart0_lo,
                  MSS_UART_115200_BAUD,
                  MSS_UART_DATA_8_BITS | MSS_UART_NO_PARITY | MSS_UART_ONE_STOP_BIT);

    MSS_UART_polled_tx_string(&g_mss_uart0_lo, "\r\n");
    MSS_UART_polled_tx_string(&g_mss_uart0_lo, "Hello World!\r\n");
}
