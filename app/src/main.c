#include <stdio.h>
#include <zephyr/kernel.h>

// Define stack sizes for our threads
#define STACK_SIZE 1024

// Define thread stacks
K_THREAD_STACK_DEFINE(thread0_stack, STACK_SIZE);
K_THREAD_STACK_DEFINE(thread1_stack, STACK_SIZE);
K_THREAD_STACK_DEFINE(thread2_stack, STACK_SIZE);

// Thread data structures
static struct k_thread thread0_data;
static struct k_thread thread1_data;
static struct k_thread thread2_data;

// Add mutex definition
K_MUTEX_DEFINE(print_mutex);

// Thread functions
void thread0_entry(void *p1, void *p2, void *p3)
{
	while (1)
	{
		k_mutex_lock(&print_mutex, K_FOREVER);
		printf("Thread 0 running on CPU %d\n", arch_curr_cpu()->id);
		k_mutex_unlock(&print_mutex);
		k_sleep(K_MSEC(1000));
	}
}

void thread1_entry(void *p1, void *p2, void *p3)
{
	while (1)
	{
		k_mutex_lock(&print_mutex, K_FOREVER);
		printf("Thread 1 running on CPU %d\n", arch_curr_cpu()->id);
		k_mutex_unlock(&print_mutex);
		k_sleep(K_MSEC(1000));
	}
}

void thread2_entry(void *p1, void *p2, void *p3)
{
	while (1)
	{
		k_mutex_lock(&print_mutex, K_FOREVER);
		printf("Thread 2 running on CPU %d\n", arch_curr_cpu()->id);
		k_mutex_unlock(&print_mutex);
		k_sleep(K_MSEC(1000));
	}
}

int main(void)
{
	printf("Hello my beautiful world! %s\n", CONFIG_BOARD_TARGET);
	// Create two threads with different CPU affinities
	k_thread_create(&thread0_data, thread0_stack,
					K_THREAD_STACK_SIZEOF(thread0_stack),
					thread0_entry, NULL, NULL, NULL,
					5, 0, K_FOREVER);
	k_thread_cpu_mask_clear(&thread0_data);
	k_thread_cpu_mask_enable(&thread0_data, 1);

	k_thread_create(&thread1_data, thread1_stack,
					K_THREAD_STACK_SIZEOF(thread1_stack),
					thread1_entry, NULL, NULL, NULL,
					5, 0, K_FOREVER);
	k_thread_cpu_mask_clear(&thread1_data);
	k_thread_cpu_mask_enable(&thread1_data, 2);

	k_thread_create(&thread2_data, thread2_stack,
					K_THREAD_STACK_SIZEOF(thread2_stack),
					thread2_entry, NULL, NULL, NULL,
					5, 0, K_FOREVER);
	k_thread_cpu_mask_clear(&thread2_data);
	k_thread_cpu_mask_enable(&thread2_data, 3);

	printf("Number of CPUs: %d\n", arch_num_cpus());

	// Start threads
	k_thread_start(&thread0_data);
	k_thread_start(&thread1_data);
	k_thread_start(&thread2_data);

	while (1)
	{
		k_mutex_lock(&print_mutex, K_FOREVER);
		printf("Main thread running on CPU %d\n", arch_curr_cpu()->id);
		k_mutex_unlock(&print_mutex);
		k_sleep(K_MSEC(1000));
	}

	return 0;
}