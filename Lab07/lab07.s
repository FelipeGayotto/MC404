.bss
code_input: .skip 0x28  # buffer 4 bytes
decode_input: .skip 0x40  # buffer 8 bytes
V_ou_F_output: .skip 0x10 # buffer 2 byte


.text


.globl start


start:
    jal main
    j exit


main:

    read1:
        li a0, 0  # file descriptor = 0 (stdin)
        la a1, code_input #  buffer to write the data
        li a2, 5  # size (reads only 5 byte)
        li a7, 63 # syscall read (63)
        ecall
    
    read2:
        li a0, 0  # file descriptor = 0 (stdin)
        la a1, decode_input #  buffer to write the data
        li a2, 8  # size (reads only 8 byte)
        li a7, 63 # syscall read (63)
        ecall


    # Converter o code_input to int
    la a1, code_input
    li t1, 3
    mv a2, zero
    jal str_to_int
    mv s1, a1  # Salva o valor original em s1 para uso posterior


    # Converter o decode_input to int
    la a1, decode_input
    li t1, 6
    mv a2, zero
    jal str_to_int
    mv s2, a1  # Salva o valor original em s2 para uso posterior


    jal encode
    mv s3, a0  # Salva o valor codificado em s3 para uso posterior
    jal decode
    mv s4, a0  # Salva o valor decodificado em s4 para uso posterior
    mv s5, a1


    la a1, code_input
    li t0, 3
    mv a0, s4  # Valor codificado
    jal int_to_bin


    la a1, decode_input
    li t0, 6
    mv a0, s3  # Valor decodificado
    jal int_to_bin


    li t1, 48
    li t2, 10
    la a1, V_ou_F_output
    sb t1, 0(a1)  # Inicializa com '0' (Igual)
    sb t2, 1(a1)  # Adiciona o caractere de nova linha
    beqz s5, true_case
    li t1, 49
    sb t1, 0(a1)  # Altera para '1' (Diferente)
    true_case:


    # Escrever o resultados


    write1:
        li a0, 1  # file descriptor = 1 (stdout)
        la a1, decode_input # buffer with the data
        li a2, 8  # size (4 bits + newline)
        li a7, 64 # syscall write (64)
        ecall
    write2:
        li a0, 1  # file descriptor = 1 (stdout)
        la a1, code_input # buffer with the data
        li a2, 5  # size (7 bits + newline)
        li a7, 64 # syscall write (64)
        ecall
    write3:
        li a0, 1  # file descriptor = 1 (stdout)
        la a1, V_ou_F_output # buffer with the data
        li a2, 2  # size (1 bit + newline)
        li a7, 64 # syscall write (64)
        ecall
    j exit


int_to_bin:
    # t0 contém o número de bits a serem processados (4 ou 7)
    # a1 contém o endereço do buffer onde a string binária será armazenada
    addi t1, t0, 1    # contador
    mv a2, zero       # Resultado inicial

    bin_loop:
        srl a3, a0, t0  # Desloca o número para a direita
        andi a3, a3, 1
        addi a3, a3, 48  # Converte para ASCII ('0' = 48)
        sb a3, 0(a1)     # Armazena o caractere no buffer
        addi a1, a1, 1   # Avança para o próximo
        addi t0, t0, -1  # Decrementa o contador de bits
        addi t1, t1, -1 # Decrementa do contador
        bgtz t1, bin_loop # Repete até processar todos os bits
    li t1, 10
    sb t1, 0(a1)
    ret


str_to_int:
    addi t2, t1, 1              # Carrega o contador
    str_loop:
        lb a0, 0(a1)            # Carrega o byte mais significativo
        addi a0, a0, -48        # Transforma em número
        sll a0, a0, t1          # Multiplica pela potência de 2 associada 
        add a2, a2, a0          # Adiciona no número completo
        addi a1, a1, 1          # Vai para o próximo byte
        addi t1, t1, -1         # Diminui uma potência de 2
        addi t2, t2, -1         # Decresce o contador
        bgtz t2, str_loop       
    mv a1, a2  # Retorna o valor inteiro em a1
    ret


encode:
    andi t1, s1, 0b1000
    andi t2, s1, 0b0100
    andi t3, s1, 0b0010
    andi t4, s1, 0b0001


    srli t1, t1, 3
    srli t2, t2, 2
    srli t3, t3, 1          # Coloca os valores dos bits d1, d2, d3 e d4 em t1, t2, t3 e t4
   
    xor a2, t1, t2          # p1 = d1 XOR d2
    xor a2, a2, t4          # p1 = d1 XOR d2 XOR d4  (paridade dos bits d1, d2 e d4)
    xor a3, t1, t3          # p2 = d1 XOR d3
    xor a3, a3, t4          # p2 = d1 XOR d3 XOR d4  (paridade dos bits d1, d3 e d4)
    xor a4, t2, t3          # p3 = d2 XOR d3
    xor a4, a4, t4          # p3 = d2 XOR d3 XOR d4  (paridade dos bits d2, d3 e d4)


    slli a2, a2, 6          # p1 na posicao 1 (bit 7)
    slli a3, a3, 5          # p2 na posicao 2 (bit 6)
    slli t1, t1, 4          # d1 na posicao 3 (bit 5)
    slli a4, a4, 3          # p3 na posicao 4 (bit 4)
    slli t2, t2, 2          # d2 na posicao 5 (bit 3)
    slli t3, t3, 1          # d3 na posicao 6 (bit 2)
    # d4 na posicao 7 (bit 1)
    or a5, a2, a3
    or a5, a5, t1
    or a5, a5, a4
    or a5, a5, t2
    or a5, a5, t3
    or a5, a5, t4           # a5 contem o valor codificado
    mv a0, a5               # Retorna o valor codificado em a0
    ret


decode:
    andi t1, s2, 0b0010000
    andi t2, s2, 0b0000100
    andi t3, s2, 0b0000010
    andi t4, s2, 0b0000001


    srli t1, t1, 1

    or a2, t1, t2
    or a2, a2, t3
    or a2, a2, t4          # a2 contem o número d1 d2 d3 d4

    andi t1, s1, 0b1000000
    andi t2, s1, 0b0010000
    andi t3, s1, 0b0000100
    andi t4, s1, 0b0000001

    xor a7, t1, t2
    xor a7, a7, t3
    xor a7, a7, t4

    andi t1, s1, 0b0100000
    andi t2, s1, 0b0010000
    andi t3, s1, 0b0000010
    andi t4, s1, 0b0000001

    xor a6, t1, t2
    xor a6, a6, t3
    xor a6, a6, t4

    andi t1, s1, 0b0001000
    andi t2, s1, 0b0000100
    andi t3, s1, 0b0000010
    andi t4, s1, 0b0000001

    xor a5, t1, t2
    xor a5, a5, t3
    xor a5, a5, t4

    or a1, a7, a6
    or a1, a1, a5

    mv a0, a2

    ret


exit:
    li a7, 93 # syscall exit (93)
    li a0, 0  # exit code 0
    ecall