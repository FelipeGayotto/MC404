.text

.globl puts, gets, atoi, itoa, linked_list_search, exit

puts:
    /*
    Recebe em a0 o endereço da string a ser printada
    Essa função recebe esse endereço e printa a string com um \n no final
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

    write:
        li a0, 1            # file descriptor = 1 (stdout)
        # a1 já possui o endereço do buffer
        mv a2, t2           # size
        li a7, 64           # syscall write (64)
        ecall
    ret

gets:
    /*
    a0 possui o endereço do buffer para onde a string vai ser copiada
    Essa função lê uma string de STDIN e devolve o endereço do buffer onde ela foi armazenada
    */
    mv a6, a0
    mv a1, a6
    addi a1, a1, -1
    1:
        addi a1, a1, 1
        read:
            li a0, 0        # file descriptor = 0 (stdin)
            # a1 já possui o endereço correto
            li a2, 1       # size (ISSO DEVE SER ARRUMADO DEPOIS)
            li a7, 63       # syscall read (63)
            ecall
        li t1, 10
        lb t2, 0(a1)
        bne t1, t2, 1b

    li t0, 0     
    sb t0, 0(a1)   # Quando for, troca ele por \0

    mv a0, a6   
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
        mv a0, t4           # Retorna o valor do inteiro em a0
    ret

recursive_tree_search:
    /*
    a0 contém o valor do nó de raíz da árvore
    a1 contém o valor que deve ser encontrado na árvore
    
    Para cada iteração,vamos salvar na pilha:
    endereço 1 -> Nó pai
    endereço 2 -> profundidade atual
    endereço 3 -> ra
    */

    lw a7, 0(a0)    # a7 contém o valor do primeiro nó
    mv a2, a0
    mv a0, zero 
    li t1, 1
    
    recursive:
        beqz a0, 1f
        ret
    1:
        beqz a2, 1f

        lw t0, 0(a2)
        beq t0, a1, achou
        lw t2, 4(a2)
        addi sp, sp, -16
        sw ra, 8(sp)
        sw a2, 4(sp)
        sw t1, 0(sp)

        mv a2, t2
        lw t1, 0(sp)
        addi t1, t1, 1
        jal recursive

        li t3, -1
        bne a0, t3, retorno
        

        
    1:
        li a0, -1
        ret
    
    achou:


        


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

linked_list_search:
    /*
    a0 contém o endereço do head_node
    a1 contém o resultado da soma buscado
    */
    mv t0, zero     # Inicia o contador dos nós da lista

    1:
        lw t1, 0(a0)    # Carrega VAL1
        lw t2, 4(a0)    # Carrega VAL2
        add t1, t1, t2  # Soma
        mv t3, t0
        beq a1, t1, 1f  # Retorna caso seja igual
        lw a0, 8(a0)    # Vai para o próximo espaço da lista ligada
        li t3, -1
        beqz a0, 1f     # Caso seja o último, retorna -1
        addi t0, t0, 1
        j 1b
    1:
        mv a0, t3       # Retorna o índice da lista em a0
    ret

exit:
    mv a0, a0       # Copia o valor do parâmetro (código de saída) para a0
    li a7, 93       # Carrega o código da chamada de sistema 'exit' (93) em a7
    ecall        