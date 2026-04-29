.section .text
.global _start

_start:
    lui  s0, 0x2
    addi t0, s0, 4
    li   t1, 0xF
    sw   t1, 0(t0)

main_loop:
    li   s1, 0
    li   s2, 0
    li   s3, 0
    li   s4, 0

read_char:
    addi t0, s0, 0x10
wait_rx:
    lw   t1, 0(t0)
    andi t1, t1, 0x2
    beqz t1, wait_rx

    addi t2, s0, 0x1C
    lw   a0, 0(t2)

    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  ra, send_char
    lw   ra, 0(sp)
    addi sp, sp, 4

    li   t1, 0x0D
    beq  a0, t1, do_calc
    li   t1, 0x2B
    beq  a0, t1, got_op
    li   t1, 0x2D
    beq  a0, t1, got_op
    li   t1, 0x30
    blt  a0, t1, read_char
    li   t1, 0x39
    bgt  a0, t1, read_char

    addi a0, a0, -0x30
    beqz s4, accum_num1

accum_num2:
    slli t1, s2, 3
    slli t2, s2, 1
    add  t1, t1, t2
    add  s2, t1, a0
    j    read_char

accum_num1:
    slli t1, s1, 3
    slli t2, s1, 1
    add  t1, t1, t2
    add  s1, t1, a0
    j    read_char

got_op:
    mv   s3, a0
    li   s4, 1
    j    read_char

do_calc:
    li   a0, 0x0D
    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  ra, send_char
    lw   ra, 0(sp)
    addi sp, sp, 4

    li   a0, 0x0A
    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  ra, send_char
    lw   ra, 0(sp)
    addi sp, sp, 4

    li   t1, 0x2B
    beq  s3, t1, do_add

do_sub:
    sub  a0, s1, s2
    bge  a0, zero, send_result
    li   a0, 0
    j    send_result

do_add:
    add  a0, s1, s2

send_result:
    # Guardar ra antes de print_uint
    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  ra, print_uint
    lw   ra, 0(sp)
    addi sp, sp, 4

    li   a0, 0x0D
    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  ra, send_char
    lw   ra, 0(sp)
    addi sp, sp, 4

    li   a0, 0x0A
    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  ra, send_char
    lw   ra, 0(sp)
    addi sp, sp, 4

    j    main_loop

send_char:
    addi t3, s0, 0x18
    sw   a0, 0(t3)
    addi t3, s0, 0x10
    li   t4, 0x1
    sw   t4, 0(t3)
wait_tx:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, wait_tx
    ret

print_uint:
    # Caso especial: 0
    bnez a0, pui_start
    li   a0, 0x30         # '0'
    addi t3, s0, 0x18
    sw   a0, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_zero_wait:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_zero_wait
    ret

pui_start:
    li   t5, 0            # t5 = flag: aún no enviamos ningún dígito

    # ---- Dígito 10000 ----
    li   t1, 10000
    li   t2, 0            # cociente
pui_d4_loop:
    blt  a0, t1, pui_d4_done
    sub  a0, a0, t1
    addi t2, t2, 1
    j    pui_d4_loop
pui_d4_done:
    beqz t2, pui_d3       # dígito=0 y sin flag → saltar
    addi t2, t2, 0x30
    li   t5, 1
    # enviar t2 inline
    addi t3, s0, 0x18
    sw   t2, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d4_tx:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d4_tx

    # ---- Dígito 1000 ----
pui_d3:
    li   t1, 1000
    li   t2, 0
pui_d3_loop:
    blt  a0, t1, pui_d3_done
    sub  a0, a0, t1
    addi t2, t2, 1
    j    pui_d3_loop
pui_d3_done:
    beqz t2, pui_d3_check
    addi t2, t2, 0x30
    li   t5, 1
    addi t3, s0, 0x18
    sw   t2, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d3_tx:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d3_tx
    j    pui_d2
pui_d3_check:
    beqz t5, pui_d2       # leading zero — saltar
    addi t2, t2, 0x30
    addi t3, s0, 0x18
    sw   t2, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d3_tx2:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d3_tx2

    # ---- Dígito 100 ----
pui_d2:
    li   t1, 100
    li   t2, 0
pui_d2_loop:
    blt  a0, t1, pui_d2_done
    sub  a0, a0, t1
    addi t2, t2, 1
    j    pui_d2_loop
pui_d2_done:
    beqz t2, pui_d2_check
    addi t2, t2, 0x30
    li   t5, 1
    addi t3, s0, 0x18
    sw   t2, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d2_tx:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d2_tx
    j    pui_d1
pui_d2_check:
    beqz t5, pui_d1
    addi t2, t2, 0x30
    addi t3, s0, 0x18
    sw   t2, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d2_tx2:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d2_tx2

    # ---- Dígito 10 ----
pui_d1:
    li   t1, 10
    li   t2, 0
pui_d1_loop:
    blt  a0, t1, pui_d1_done
    sub  a0, a0, t1
    addi t2, t2, 1
    j    pui_d1_loop
pui_d1_done:
    beqz t2, pui_d1_check
    addi t2, t2, 0x30
    li   t5, 1
    addi t3, s0, 0x18
    sw   t2, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d1_tx:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d1_tx
    j    pui_d0
pui_d1_check:
    beqz t5, pui_d0
    addi t2, t2, 0x30
    addi t3, s0, 0x18
    sw   t2, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d1_tx2:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d1_tx2

    # ---- Dígito unidades (siempre se envía) ----
pui_d0:
    addi a0, a0, 0x30
    addi t3, s0, 0x18
    sw   a0, 0(t3)
    addi t3, s0, 0x10
    li   t4, 1
    sw   t4, 0(t3)
pui_d0_tx:
    lw   t4, 0(t3)
    andi t4, t4, 0x1
    bnez t4, pui_d0_tx

    ret
