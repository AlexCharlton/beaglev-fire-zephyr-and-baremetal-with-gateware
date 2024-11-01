#include <stdio.h>
#include <zephyr/kernel.h>

int main(void)
{
	while (1)
	{
		printf("Hello World! %s\n", CONFIG_BOARD_TARGET);
		k_sleep(K_MSEC(10000));
	}

	return 0;
}