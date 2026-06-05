# ==============================================================================
# main.S — Transmisión Periódica con Inicialización del ADXL362 (Issue #26)
# ==============================================================================

.equ RAM_END,      0x00080000
.equ GPIO_LEDS,    0x00002004

.equ UART_CTRL,    0x00002010  # Bit 0 = tx_busy, Bit 1 = new_rx
.equ UART_TX_DATA, 0x00002018

.equ SPI_CTRL,     0x00002020  # Bit 0 = spi_busy, Bit 1 = preserve_cs
.equ SPI_TX,       0x00002024
.equ SPI_RX,       0x00002028

# --- Constantes ADXL362 ---
.equ ADXL_READ_CMD,  0x0B
.equ ADXL_WRITE_CMD, 0x0A      # Comando SPI para escribir en el ADXL362
.equ REG_POWER_CTL,  0x2D      # Registro de control de potencia
.equ REG_X_DATA,     0x0E
.equ REG_Y_DATA,     0x10
.equ REG_Z_DATA,     0x12

.globl _start
_start:
    li sp, RAM_END
    li s1, UART_CTRL
    li s2, UART_TX_DATA
    li s3, SPI_CTRL
    li s4, SPI_TX
    li s5, SPI_RX
    li s6, GPIO_LEDS

    # Mostrar indicación visual en los LEDs
    li t0, 0x24
    sw t0, 0(s6)

    # --------------------------------------------------------------------------
    # CRUCIAL: ENCENDER EL ACELERÓMETRO (Sacar de modo Standby)
    # Escribir 0x02 (Measurement Mode) en el registro 0x2D (POWER_CTL)
    # --------------------------------------------------------------------------
    li a0, REG_POWER_CTL       # Registro destino
    li a1, 0x02                # Valor para activar la medición continua
    jal ra, write_adxl_register

# ==============================================================================
# Bucle Principal de Telemetría
# ==============================================================================
main_telemetry_loop:

    li a0, REG_X_DATA
    jal ra, read_adxl_register
    mv a2, a0
    li a1, 0x58                  # 'X'
    jal ra, send_uart_packet

    li a0, REG_Y_DATA
    jal ra, read_adxl_register
    mv a2, a0
    li a1, 0x59                  # 'Y'
    jal ra, send_uart_packet

    li a0, REG_Z_DATA
    jal ra, read_adxl_register
    mv a2, a0
    li a1, 0x5A                  # 'Z'
    jal ra, send_uart_packet

    # Retardo para muestreo estable (~10 ms)
    li t0, 33333
dly_10ms:
    addi t0, t0, -1
    bnez t0, dly_10ms

    j main_telemetry_loop

# ==============================================================================
# Subrutina: Escribir en Registro del ADXL362 por SPI
# Entrada: a0 = Dirección del registro interno
#          a1 = Byte de datos a escribir
# ==============================================================================
write_adxl_register:
    # Paso A: Enviar comando de escritura (0x0A) manteniendo CS activo (control=3)
    li t0, ADXL_WRITE_CMD; sw t0, 0(s4); li t0, 3; sw t0, 0(s3)
w_spiw1: lw t1, 0(s3); andi t1, t1, 1; bnez t1, w_spiw1

    # Paso B: Enviar la dirección del registro manteniendo CS activo (control=3)
    sw a0, 0(s4); li t0, 3; sw t0, 0(s3)
w_spiw2: lw t1, 0(s3); andi t1, t1, 1; bnez t1, w_spiw2

    # Paso C: Enviar el dato real y liberar CS (control=1)
    sw a1, 0(s4); li t0, 1; sw t0, 0(s3)
w_spiw3: lw t1, 0(s3); andi t1, t1, 1; bnez t1, w_spiw3
    ret

# ==============================================================================
# Subrutina: Leer Registro del ADXL362 por SPI
# Entrada:  a0 = dirección del registro ADXL362
# Salida:   a0 = byte leído
# ==============================================================================
read_adxl_register:
    li t0, ADXL_READ_CMD; sw t0, 0(s4); li t0, 3; sw t0, 0(s3)
w_spi1: lw t1, 0(s3); andi t1, t1, 1; bnez t1, w_spi1

    sw a0, 0(s4); li t0, 3; sw t0, 0(s3)
w_spi2: lw t1, 0(s3); andi t1, t1, 1; bnez t1, w_spi2

    li t0, 0x00; sw t0, 0(s4); li t0, 1; sw t0, 0(s3)
w_spi3: lw t1, 0(s3); andi t1, t1, 1; bnez t1, w_spi3

    lw a0, 0(s5)
    andi a0, a0, 0xFF
    ret

# ==============================================================================
# Subrutina: Construir Paquete Estructurado UART
# ==============================================================================
send_uart_packet:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a0, 0x24; jal ra, tx_byte    # '$'
    mv a0, a1;   jal ra, tx_byte    # 'X'/'Y'/'Z'
    mv a0, a2;   jal ra, tx_byte    # dato real (ya no será siempre 0)
    li a0, 0x0A; jal ra, tx_byte    # '\n'

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# ==============================================================================
# Subrutina: Transmitir un byte por UART (Con disparador de Hardware Fix)
# ==============================================================================
tx_byte:
w_tx_ready:
    lw t2, 0(s1)
    andi t2, t2, 1          # bit 0 = tx_busy
    bnez t2, w_tx_ready     # esperar mientras tx_busy=1

    sw a0, 0(s2)            # Paso 1: escribir dato en UART_TX_DATA
    li t2, 1
    sw t2, 0(s1)            # Paso 2: escribir 1 en UART_CTRL → dispara tx_start
    ret
