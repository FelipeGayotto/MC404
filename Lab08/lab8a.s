.bss
    input_file: .asciz "image.pgm"
    arquivo_pgm: .skip 262159

.text

main:
    
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall



escreve_no_canvas:
    /* 
    a3 contém o endereço do buffer onde começa o arquivo binário
    a4 contém o máximo x do arquivo
    a5 contém o máximo y do arquivo
    a6 contém o maximo número de bytes a ser lido

    */
    mv t0, zero
    mv t1, zero

    for:

    li a6, 10

    bne a3, a6, cont
    addi a5, a5, 1
    mv a4, zero
    addi a3, a3, 1
    cont:

    andi t1, a3, 0xFFFFFF00

    mv a0, a4 # x coordinate = 100
    mv a1, a5 # y coordinate = 200
    mv a2, t1 # white pixel
    li a7, 2200 # syscall setPixel (2200)
    ecall

    addi a4, a4, 1









