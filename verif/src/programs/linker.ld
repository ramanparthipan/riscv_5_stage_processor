OUTPUT_ARCH("riscv")
ENTRY(main)

MEMORY {
    ram (wx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS {
    .text : { *(.text*) } > ram
    .data : { *(.data*) } > ram
    .bss  : { *(.bss*)  } > ram
}