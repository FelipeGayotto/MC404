.bss
    arquivo_pgm: .skip 262159

.data
    input_file: .asciz "image.pgm"

.text

main:
    
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall

    la a1, arquivo_pgm #  buffer to write the data
    li a2, 262159  # size (reads 20 bytes)
    li a7, 63 # syscall read (63)
    ecall

    mv s0, a1
    mv a0, s0

    jal max_x_y

    mv s1, a1           # s1 contém a largura máxima do PGM
    mv s2, a2           # s2 contém a altura máxima do PGM
    mv s3, a0           # s3 contém o endereço do primeiro byte de pixel do PGM

    set_canvas_size:
        mv a0, s1           # a0:canvas width (value between 0 and 512)
        mv a1, s2           # a1: canvas height (value between 0 and 512)
        li a7, 2201         # a7: 2201 (syscall number)
        ecall

    mv a3, s3
    mv a4, s1
    mv a5, s2

    jal escreve_com_filtro_no_canvas 

    exit:
        mv a0, a0       # Copia o valor do parâmetro (código de saída) para a0
        li a7, 93       # Carrega o código da chamada de sistema 'exit' (93) em a7
        ecall           # Invoca o sistema operacional para executar a chamada de sistema    

max_x_y:
    /*
    a0 contém o endereço do primeiro caractere do arquivo PGM
    */
    addi a0, a0, 3  # Caminha até o primeiro byte de dimensão
    mv a1, zero     
    1:
    lb t0, 0(a0)    # Carrega o byte
    li t1, 32       
    sub t3, t0, t1
    beqz t3, 1f     # Verifica se ele é igual a espaço

    addi t0, t0, -48    # Se não, trasnforma em int
    li t1, 10       # Ajusta o valor que está no número já
    mul a1, a1, t1  
    add a1, a1, t0  # Soma o valor numérico do byte atual
    addi a0, a0, 1  # Avança para o próximo endereço
    j 1b
    1:

    addi a0, a0, 1
    mv a2, zero
    2:
    lb t0, 0(a0)
    li t1, 10
    sub t3, t0, t1
    beqz t3, 2f

    addi t0, t0, -48
    li t1, 10
    mul a2, a2, t1
    add a2, a2, t0
    addi a0, a0, 1
    j 2b
    2:
    addi a0, a0, 5
    ret             
    /* Retorna os valores:
    a0 -> O endereço do primeiro caracter de pixel do arquivo
    a1 -> O valor do max x
    a2 -> O valor do max y
    */

escreve_com_filtro_no_canvas:
    /* 
    a3 contém o endereço do buffer onde começa o arquivo binário
    a4 contém o máximo x do arquivo
    a5 contém o máximo y do arquivo
    */

    mv t0, zero
    mv t1, zero         # Seta os vaores iniciais para zero

    for:

    blt t0, a4, cont    # Caso o valor de x ainda seja menor que x max, continua escrevendo na mesma linha
    addi t1, t1, 1      # Caso contrário, adiciona +1 em y
    bge t1, a5, return  # E checa se o novo valor de y é maior ou igual ao y max, se for, retorna
    mv t0, zero         # Se não, seta o valor de x para 0 novamente
    cont:
    li t2, 0x000000FF
    beqz t0, borda
    beqz t1, borda
    addi t2, t0, 1
    addi t3, t1, 1
    beq t2, a4, borda
    beq t3, a5, borda   # Caso o pixel atual seja pixel de borda, ele pula para o rótulo borda e só imprime pixel preto

    lbu t3, 0(a3)       # Carrega o valor do byte atual

    slli t3, t3, 3

    sub t6, zero, a4
    addi t6, t6, -1
    add t6, t6, a3      # Define t6 como o endereço do elemento da diagonal superior esquerda do atual
    lbu t4, 0(t6)
    sub t3, t3, t4      # Subtrai do valor total
    addi t6, t6, 1      # Define t6 como o endereço do elemento a cima do atual
    lbu t4, 0(t6)
    sub t3, t3, t4      # Subtrai do valor total do filtro
    addi t6, t6, 1      # Define t6 como o endereço do elemento da diagnal superior direita do atual
    lbu t4, 0(t6)
    sub t3, t3, t4      # Subtrai do valor total do filtro
    add t6, t6, a4
    addi t6, t6, -2     # Define t6 como o endereço do elemento à esquerda do atual
    lbu t4, 0(t6)       
    sub t3, t3, t4      # Subtrai do valor total do filtro     
    addi t6, t6, 2      # Define t6 como o endereço do elemento à direita do atual
    lbu t4, 0(t6)
    sub t3, t3, t4      # Subtrai do valor total do filtro
    add t6, t6, a4
    addi t6, t6, -2     # Define t6 como o endereço do elemento da diagonal inferior esquerda do atual
    lbu t4, 0(t6)
    sub t3, t3, t4      # Subtrai do valor total do filtro
    addi t6, t6, 1      # Define t6 como o endereço do elemento abaixo do atual
    lbu t4, 0(t6)
    sub t3, t3, t4      # Subtrai do valor total do filtro
    addi t6, t6, 1      # Define t6 como o endereço do elemento da diagonal inferior direita do atual
    lbu t4, 0(t6)
    sub t3, t3, t4      # Subtrai do valor total do filtro
    
    # Aplica o filtro no byte atual

    li t2, 0x000000FF
    blt t3, zero, borda # Define o pixel como preto caso o valor seja negativo
    li t2, 0xFFFFFFFF
    li t4, 255
    bge t3, t4, borda   # Define o pixel como branco caso o valor seja maior que o máximo

    slli t4, t3, 24     
    slli t5, t3, 16
    slli t3, t3, 8      # "Copia" o byte atual para os tres bytes mais signficativos
    li t2, 0xFF
    or t2, t2, t3
    or t2, t2, t5
    or t2, t2, t4       # Seta as cores desse pixel

    borda:

    mv a0, t0 # x coordinate
    mv a1, t1 # y coordinate
    mv a2, t2
    li a7, 2200 # syscall setPixel (2200)
    ecall

    addi a3, a3, 1      # Vai para o próximo byte do arquivo
    addi t0, t0, 1      # Vai para o próximo valor de x
    j for
    return:
    ret