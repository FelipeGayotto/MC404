.text
main:
    li s0, 0xFFFF0100
    controlar_carro:
        li t0, -15
        sb t0, 0x20(s0)
        li t0, 1
        sb t0, 0x21(s0)
        loop:
            li t0, 1
            sb t0, 0(s0)
            lw t0, 0x10(s0)
            lw t1, 0x14(s0)
            lw t2, 0x18(s0)
            li t3, 73
            li t4, 1
            li t5, -19
            sub t0, t0, t3
            sub t1, t1, t4
            sub t2, t2, t5
            mul t0, t0, t0
            mul t1, t1, t1
            mul t2, t2, t2
            add t0, t0, t1
            add t0, t0, t2
            li t1, 255
            bge t0, t1, loop
        sb zero, 0x21(s0)
        li t0, 1
        sb t0, 0x22(s0)
    j exit

exit:
    mv a0, a0       # Copia o valor do parâmetro (código de saída) para a0
    li a7, 93       # Carrega o código da chamada de sistema 'exit' (93) em a7
    ecall
