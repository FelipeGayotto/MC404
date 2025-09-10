.bss
    input_address: .skip 0xa0  # buffer

.data
    string:  .asciz "Hello! It works!!!\n"

.text

main:
    read:
        li a0, 0  # file descriptor = 0 (stdin)
        la a1, input_address #  buffer to write the data
        li a2, 20  # size (reads 20 bytes)
        li a7, 63 # syscall read (63)
        ecall
    main1:
    jal str_to_int
    jal sqrt
    jal int_to_str
    main2:
    jal str_to_int
    jal sqrt
    jal int_to_str
    main3:
    jal str_to_int
    jal sqrt
    jal int_to_str
    main4:
    jal str_to_int
    jal sqrt
    jal int_to_str
    addi a1, a1, -1
    li a3, 10
    sw a3, 0(a1)

    write:
        li a0, 1                   # file descriptor = 1 (stdout)
        la a1, input_address       # buffer
        li a2, 19                  # size
        li a7, 64                  # syscall write (64)
        ecall

    
        
str_to_int:
    mv a6, zero
    li t1, 1
    li t2, 1000
    li t3, 10
    str_loop:
        lb a2, 0(a1)            # Carrega o digito atual do numero (milhar -> unidade)
        addi a2, a2, -48        # Ajusta para o seu valor numérico  
        mul a2, a2, t2          # Multiplica pelo valor correspondente 
        add a6, a6, a2          # Adicona o valor ao número ao atual
        divu t2, t2, t3       
        addi a1, a1, 1          # Ajusta os parametros para o proximo loop
        bne t1, t2, str_loop    # Retorna para o inicio quando o t2 = 1
    ret
    
sqrt:
    mv a2, zero
    slli a2, a5, 1  # Acha o valor base de k
    li t1, 9        # Começa o contador
    sqrt_loop:      
        divu a3, a5, a2           # a3 = y/k
        add a3, a3, a2              # a3 = k + y/k
        slli a3, a3, 1              # a3 = (k + y/k)/2
        mv a2, a3                   # k' = a3
        addi t1, t1, -1             # Ajusta o contador
        bne t1, zero, sqrt_loop     # Retorna para o início do loop
    ret

int_to_str:
    li t1, 1000
    li t2, 10
    li t3, 1
    mv a4, zero
    loop_int:
        slli a4, a4, 8      # Ajusta a posição da string anterior para a nova iteração
        divu a3, a2, t1   # Encontra o valor do digito mais significativo
        addi a3, a3, 48     # Transforma esse valor em caractere
        add a4, a4, a3      # Adiciona o valor do caractere no registrador da string
        remu a2, a2, t1   
        divu t1, t1, t2   # Ajusta os valores para a próxima iteração
        bne t1, t3, loop_int
    sw a4, 0(a1)            # Altera o primeiro valor do input para sua raiz
    li a4, 32
    sb a4, 0(a1)
    addi a1, a1, 1
    ret
         




    

