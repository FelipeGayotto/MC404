.bss 
    input: .skip 256

.text

.globl puts, gets, atoi, itoa, linked_list_search, exit


main:
    li s0, 0xFFFF0100
    la a0, input
    jal gets
    lb t0, 0(a0)
    li t1, '1'
    beq t1, t0, 1f
    li t1, '2'
    beq t1, t0, 2f
    li t1, '3'
    beq t1, t0, 3f
    li t1, '4'
    beq t1, t0, 4f
    1:
        la a0, input
        jal gets
        jal puts
        j final

    2:
        la a0, input
        jal gets
        li t1, 0
        2:
            lb t0, 0(a0)
            beqz t0, 2f
            addi t1, t1, 1
            addi sp, sp, -16
            sb t0, 0(sp)
            addi a0, a0, 1
            j 2b
        2:
            la a0, input
        2:
            beqz t1, 2f
            lb t0, 0(sp)
            sb t0, 0(a0)
            addi sp, sp, 16
            addi t1, t1, -1
            addi a0, a0, 1
            j 2b
        2:
            sb zero, 0(a0)
            la a0, input
            jal puts
            j final

    3:
        la a0, input
        jal gets
        jal atoi
        la a1, input
        li a2, 16
        jal itoa
        jal puts
        j final

    4:
        la a0, input
        jal gets
        jal atoi
        addi a1, a1, 1
        lb t0, 0(a1)
        li t1, '+'
        beq t0, t1, 1f
        li t1, '-'
        beq t0, t1, 2f
        li t1, '*'
        beq t0, t1, 3f
        li t1, '/'
        beq t0, t1, 4f
        1:
            addi a1, a1, 1
            mv t0, a0
            mv a0, a1
            jal atoi
            add a0, a0, t0
            la a1, input
            li a2, 10
            jal itoa
            jal puts
            j final 

        2:
            addi a1, a1, 1
            mv t0, a0
            mv a0, a1
            jal atoi
            sub a0, t0, a0
            la a1, input
            li a2, 10
            jal itoa
            jal puts
            j final 

        3:
            addi a1, a1, 1
            mv t0, a0
            mv a0, a1
            jal atoi
            mul a0, a0, t0
            la a1, input
            li a2, 10
            jal itoa
            jal puts
            j final 

        4:
            addi a1, a1, 1
            mv t0, a0
            mv a0, a1
            jal atoi
            div a0, t0, a0
            la a1, input
            li a2, 10
            jal itoa
            jal puts
            j final 

    final:
        j exit


puts:
    /*
    Recebe em a0 o endereço da string a ser printada
    Essa função recebe esse endereço e printa a string em Serial Port com um \n no final
    */
    mv a1, a0
    mv t2, zero
    1:
    addi t2, t2, 1
    li t0, 0
    lb t1, 0(a0)
    sub t1, t1, t0
    addi a0, a0, 1
    bnez t1, 1b

    li t0, 10
    sb t0, -1(a0)
    addi t2, t2, 1
    mv t0, zero

    write:
        blt t0, t2, 1f
        lb t1, 0(a1)
        sb t1, 0x01(s0)
        li t3, 1
        sb t3, 0x00(s0)
        addi a1, a1, 1
        addi t0, t0, 1
        j write
    1:
        ret

gets:
    /*
    a0 possui o endereço do buffer para onde a string vai ser copiada
    Essa função lê uma string de Serial Port e devolve o endereço do buffer onde ela foi armazenada
    */
    mv a6, a0
    mv a1, a6
    addi a1, a1, -1
    1:
        addi a1, a1, 1
        read:
            li t0, 1
            sb t0, 0x02(s0)
            lb t1, 0x03(s0)
            sb t1, 0(a1)
        li t2, 10
        bne t1, t2, 1b

    li t0, 0     
    sb t0, 0(a1)   # Quando for, troca ele por \0

    mv a0, a6   
    ret 

itoa:
    /*
    a0 -> valor a ser convertido para ascii
    a1 -> endereço do buffer onde a string será escrita
    a2 -> base a ser aplicada
    */
    mv a3, a1       # Guarda o início do buffer
    li t2, 0
    li t6, 10
    bne t6, a2, pos
    bgez a0, pos
    li t6, '-'
    sb t6, 0(a1)
    addi a1, a1, 1
    sub a0, zero, a0
    pos:
        addi sp, sp, -16    # Guarda espaço na pilha para este caracter
        remu t1, a0, a2     # Checa o valor do útimo dígito do número atual
        addi t1, t1, 48     # Transforma em char
        li t6, 58
        blt t1, t6, 1f
        addi t1, t1, -10
        addi t1, t1, 49
    1:
        sb t1, 0(sp)        # Empilha o valor
        divu a0, a0, a2     
        addi t2, t2, 1      # Ajusta os parâmetros para o próximo loop
        bnez a0, pos        # Caso o número ainda não tenha acabado, ele continua no loop
    1:
        beqz t2, 1f         # Caso todos os bytes tenham sido lidos, termina
        lb t1, 0(sp)        # Carrega o próximo byte
        sb t1, 0(a1)        # Guarda no buffer
        addi sp, sp, 16     # Desempilha a pilha
        addi t2, t2, -1     # Diminui do contador
        addi a1, a1, 1      # Avança no endereço do buffer
        j 1b
    1:
        li t6, 0
        sb t6, 0(a1)
        mv a0, a3           # Retorna o ponteiro pro buffer em a0
    ret

atoi:
    /*
    a0 contém o endereço do primeiro char da string
    */
    li t4, 0
    li t6, 0
    1:
        li t0, ' '
        lb t1, 0(a0)
        sub t0, t0, t1
        addi a0, a0, 1
        beqz t0, 1b     # Percorre os whitespaces até o primeiro carcater nonwhite
    addi a0, a0, -1
    li t0, '+'
    li t1, '-'
    lb t2, 0(a0)
    bne t2, t0, 1f
    addi a0, a0, 1
    j 2f
    1:
        bne t2, t1, 2f
        li t6, 1
        addi a0, a0, 1
    2:
        li t0, '9'
        li t1, '0'
        li t3, 10
        lb t2, 0(a0)        # Carrega auxiliares e parametros para o loop
        blt t2, t1, 1f       
        blt t0, t2, 1f      # Verifica se o caractere está entre 0 e 9
        mul t4, t4, t3
        addi t2, t2, -'0'
        add t4, t4, t2     # Adiciona o valor do char atual ao buffer
        addi a0, a0, 1      # Ajusta os parâmetros para a próxima interação
        j 2b
    1:
        beqz t6, 1f
        sub t4, zero, t4
    1:    
        mv a1, a0           # Retorna o endereço do próximo caracter em a1
        mv a0, t4           # Retorna o valor do inteiro em a0
    ret

exit:
    mv a0, a0       # Copia o valor do parâmetro (código de saída) para a0
    li a7, 93       # Carrega o código da chamada de sistema 'exit' (93) em a7
    ecall    