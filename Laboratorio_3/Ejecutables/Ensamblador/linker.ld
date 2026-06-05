OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    . = 0x00000000;          /* Dirección base de la ROM en tu bus */
    .text : {
        *(.text)             /* Todo el código ejecutable */
    }
    /DISCARD/ : {
        *(.comment)
        *(.riscv.attributes)
    }
}
