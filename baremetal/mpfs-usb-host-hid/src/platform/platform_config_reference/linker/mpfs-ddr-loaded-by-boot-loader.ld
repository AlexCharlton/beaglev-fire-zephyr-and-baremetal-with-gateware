/*******************************************************************************
 * Copyright 2019-2023 Microchip FPGA Embedded Systems Solutions.
 *
 * SPDX-License-Identifier: MIT
 *
 * MPFS HAL Embedded Software
 *
 */
/*******************************************************************************
 *
 * file name : mpfs-ddr-loaded-by-boot-loader.ld
 * Use this linker script when the program is fully located in DDR. The
 * assumption is DDR has already been initialized by another program.
 *
 * This linker script can be used with a debugger or when compiled and loaded
 * by a boot-loader.
 * The loading program passes two parameters in a0 and a1
 *     a0  - The hartid is passed here
 *     a1  - A pointer to Hart Local Storage (HLS) is passed here
 *           The HLS is a small amount of memory dedicated to each hart.
 *           The HLS also contains a pointer to shared memory.
 *           The shared memory is accessible by all harts if used. It is
 *           allocated by the boot-loader if the MPFS_HAL_SHARED_MEM_ENABLED
 *           is defined in the mss_sw_config.h file project configuration file.
 * Please see the project mpfs-hal-run-from-ddr-u54-1 located in the Bare Metal
 * examples under examples/mpfs-hal for an example of it use.
 *
 * https://github.com/polarfire-soc/polarfire-soc-bare-metal-examples
 *
 * You can find details on the PolarFireSoC Memory map in the mpfs-memory-hierarchy.md
 * which can be found under the link below:
 * https://github.com/polarfire-soc/polarfire-soc-documentation
 *
 */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

/*-----------------------------------------------------------------------------

-- MSS hart Reset vector

The MSS reset vector for each hart is stored securely in the MPFS.
The most common usage will be where the reset vector for each hart will be set
to the start of the envm at address 0x2022_0100, giving 128K-256B of contiguous
non-volatile storage. Normally this is where the initial boot-loader will
reside. (Note: The first 256B page of envm is used for metadata associated with
secure boot. When not using secure boot (mode 0,1), this area is still reserved
by convention. It allows easier transition from non-secure to secure boot flow
during the development process.

------------------------------------------------------------------------------*/

MEMORY
{
    envm (rx) : ORIGIN  = 0x20220100, LENGTH = 128k - 0x100
    dtim (rwx) : ORIGIN  = 0x01000000, LENGTH = 7k
    /* This 1K of DTIM is used to run code when switching the envm clock */
    switch_code_dtim (rx) : ORIGIN = 0x01001c00, LENGTH = 1k
    e51_itim (rwx)     : ORIGIN = 0x01800000, LENGTH = 28k
    u54_1_itim (rwx)   : ORIGIN = 0x01808000, LENGTH = 28k
    u54_2_itim (rwx)   : ORIGIN = 0x01810000, LENGTH = 28k
    u54_3_itim (rwx)   : ORIGIN = 0x01818000, LENGTH = 28k
    u54_4_itim (rwx)   : ORIGIN = 0x01820000, LENGTH = 28k
    l2lim (rwx)        : ORIGIN = 0x08000000, LENGTH = 256k
    scratchpad(rwx)    : ORIGIN = 0x0A000000, LENGTH = 256k
    /* DDR sections example */
    ddr_cached_32bit (rwx) : ORIGIN  = 0x80000000, LENGTH = 768M
    ddr_non_cached_32bit (rwx) : ORIGIN  = 0xC0000000, LENGTH = 256M
    ddr_wcb_32bit (rwx) : ORIGIN  = 0xD0000000, LENGTH = 256M
    ddr_cached_38bit (rwx) : ORIGIN  = 0x1000000000, LENGTH = 1024M
    ddr_non_cached_38bit (rwx) : ORIGIN  = 0x1400000000, LENGTH = 0k
    ddr_wcb_38bit (rwx) : ORIGIN  = 0x1800000000, LENGTH  = 0k
}
HEAP_SIZE           = 8k;   /* needs to be calculated for your application */

/*
 * There is common area for shared variables, accessed from a pointer in a harts HLS
 */
SIZE_OF_COMMON_HART_MEM = 4k;

/*
 * The stack size needs to be calculated for your application. It must be aligned.
 * Also Thread local storage (AKA hart local storage) is allocated for each hart
 * as part of the stack.
 * So the memory map will look like once apportion in startup code:
 * stack hart0
 * HLS hart 0
 * stack hart1
 * HLS hart 1
 * etc
 * Actual Stack size per hart = (STACK_SIZE_PER_HART - HLS_DEBUG_AREA_SIZE)
 * note: HLS_DEBUG_AREA_SIZE is defined in mss_sw_config.h
 */
/*
 * Stack size for each hart's application.
 * These are the stack sizes that will be allocated to each hart before starting
 * each hart's application function, e51(), u54_1(), u54_2(), u54_3(), u54_4().
 */
STACK_SIZE_E51_APPLICATION = 0k;
STACK_SIZE_U54_1_APPLICATION = 8k;
STACK_SIZE_U54_2_APPLICATION = 8k;
STACK_SIZE_U54_3_APPLICATION = 8k;
STACK_SIZE_U54_4_APPLICATION = 8k;



/* reset address 0xC0000000 */
SECTION_START_ADDRESS           = 0x1000000000;

SECTIONS
{

    /* text: test code section */
    . = SECTION_START_ADDRESS;
    .text : ALIGN(0x10)
    {
         __text_load = LOADADDR(.text);
         __text_start = .;
         *(.text.init)
        . = ALIGN(0x10);
        *(.text .text.* .gnu.linkonce.t.*)
        *(.plt)
        . = ALIGN(0x10);

        KEEP (*crtbegin.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))
        KEEP (*crtbegin.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))

        *(.rodata .rodata.* .gnu.linkonce.r.*)
        *(.sdata2 .sdata2.* .gnu.linkonce.s2.*)
        *(.gcc_except_table)
        *(.eh_frame_hdr)
        *(.eh_frame)

        KEEP (*(.init))
        KEEP (*(.fini))

        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        PROVIDE_HIDDEN (__fini_array_end = .);

        *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2)
        *(.srodata*)

        . = ALIGN(0x10);
        __text_end = .;
    } > ddr_cached_38bit

    /* short/global data section */
    .sdata : ALIGN(0x10)
    {
        __sdata_load = LOADADDR(.sdata);
        __sdata_start = .;
        /* offset used with gp(gloabl pointer) are +/- 12 bits, so set
           point to middle of expected sdata range */
        /* If sdata more than 4K, linker used direct addressing.
           Perhaps we should add check/warning to linker script if sdata is > 4k */
        __global_pointer$ = . + 0x800;
        *(.sdata .sdata.* .gnu.linkonce.s.*)
        . = ALIGN(0x10);
        __sdata_end = .;
    } > ddr_cached_38bit

    /* data section */
    .data : ALIGN(0x10)
    {
        __data_load = LOADADDR(.data);
        __data_start = .;
        *(.got.plt) *(.got)
        *(.shdata)
        *(.data .data.* .gnu.linkonce.d.*)
        . = ALIGN(0x10);
        __data_end = .;
    } > ddr_cached_38bit

    /* sbss section */
    .sbss : ALIGN(0x10)
    {
        __sbss_start = .;
        *(.sbss .sbss.* .gnu.linkonce.sb.*)
        *(.scommon)
        . = ALIGN(0x10);
        __sbss_end = .;
    } > ddr_cached_38bit

    /* sbss section */
    .bss : ALIGN(0x10)
    {
        __bss_start = .;
        *(.shbss)
        *(.bss .bss.* .gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(0x10);
        __bss_end = .;
    } > ddr_cached_38bit

    /* End of uninitialized data segment */
        _end = .;

        .heap : ALIGN(0x10)
        {
        __heap_start = .;
        . += HEAP_SIZE;
        __heap_end = .;
        . = ALIGN(0x10);
        _heap_end = __heap_end;
    } > ddr_cached_38bit

    /* must be on 4k boundary- corresponds to page size */
    .stack : ALIGN(0x1000)
    {
        PROVIDE(__app_stack_bottom = .);

        PROVIDE(__stack_bottom_h0$ = .);
        PROVIDE(__app_stack_bottom_h0 = .);
        . += STACK_SIZE_E51_APPLICATION;
        PROVIDE(__app_stack_top_h0 = .);
        PROVIDE(__stack_top_h0$ = .);

        PROVIDE(__stack_bottom_h1$ = .);
        PROVIDE(__app_stack_bottom_h1$ = .);
        . += STACK_SIZE_U54_1_APPLICATION;
        PROVIDE(__app_stack_top_h1 = .);
        PROVIDE(__stack_top_h1$ = .);

        PROVIDE(__stack_bottom_h2$ = .);
        PROVIDE(__app_stack_bottom_h2 = .);
        . += STACK_SIZE_U54_2_APPLICATION;
        PROVIDE(__app_stack_top_h2 = .);
        PROVIDE(__stack_top_h2$ = .);

        PROVIDE(__stack_bottom_h3$ = .);
        PROVIDE(__app_stack_bottom_h3 = .);
        . += STACK_SIZE_U54_3_APPLICATION;
        PROVIDE(__app_stack_top_h3 = .);
        PROVIDE(__stack_top_h3$ = .);

        PROVIDE(__stack_bottom_h4$ = .);
        PROVIDE(__app_stack_bottom_h4 = .);
        . += STACK_SIZE_U54_4_APPLICATION;
        PROVIDE(__app_stack_top_h4 = .);
        PROVIDE(__stack_top_h4$ = .);

        PROVIDE(__app_stack_top = .);
    } > ddr_cached_38bit

    /*
     * used by a program loaded by a bootloader to store information passed
     * from boot-loader
     * a0 holds the hart ID
     * a1 hold pointer to device data, which includes pointer to shared memory
     * when enabled by setting MPFS_HAL_SHARED_MEM_ENABLED define in the
     * mss_sw_config.h
     */
    .app_hart_common : /* ALIGN(0x1000) */
    {
        PROVIDE(__app_hart_common_start = .);
        . += SIZE_OF_COMMON_HART_MEM;
        PROVIDE(__app_hart_common_end = .);
    } > ddr_cached_38bit
}

