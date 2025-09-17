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
        la a1, input_address
        jal str_to_int
        jal sqrt
        jal int_to_str
        sw a4, 0(a1)                # Grava o número em caracteres na memória
        li a4, 32
        sb a4, 4(a1)                # Grava o caractere ' ' em seguida
    main2:
        la a1, input_address + 5
        jal str_to_int
        jal sqrt
        jal int_to_str
        sw a4, 0(a1)                # Grava o número em caracteres na memória
        li a4, 32
        sb a4, 4(a1)                # Grava o caractere ' ' em seguida
    main3:
        la a1, input_address + 10
        jal str_to_int
        jal sqrt
        jal int_to_str
        sw a4, 0(a1)                # Grava o número em caracteres na memória
        li a4, 32       
        sb a4, 4(a1)                # Grava o caractere ' ' em seguida
    main4:
        la a1, input_address + 15
        jal str_to_int
        jal sqrt
        jal int_to_str
        sw a4, 0(a1)                # Grava o número em caracteres na memória
        li a4, 10
        sb a4, 4(a1)                # Grava o caractere '\n' em seguida

    write:
        li a0, 1                   # file descriptor = 1 (stdout)
        la a1, input_address       # buffer
        li a2, 20                  # size
        li a7, 64                  # syscall write (64)
        ecall

    exit:
        mv a0, a0       # Copia o valor do parâmetro (código de saída) para a0
        li a7, 93       # Carrega o código da chamada de sistema 'exit' (93) em a7
        ecall           # Invoca o sistema operacional para executar a chamada de sistema    
        
str_to_int:
    mv a6, zero
    li t2, 1000
    li t3, 10
    str_loop:
        lb a2, 0(a1)            # Carrega o digito atual do numero (milhar -> unidade)
        addi a2, a2, -48        # Ajusta para o seu valor numérico  
        mul a2, a2, t2          # Multiplica pelo valor correspondente 
        add a6, a6, a2          # Adicona o valor ao número ao atual
        divu t2, t2, t3       
        addi a1, a1, 1          # Ajusta os parametros para o proximo loop
        bne zero, t2, str_loop    # Retorna para o inicio quando o t2 = 1
    addi a1, a1, -4
    ret
    
sqrt:
    mv a2, zero
    srli a2, a6, 1  # Acha o valor base de k
    li t1, 10        # Começa o contador
    sqrt_loop:
        divu a3, a6, a2             # a3 = y/k
        add a3, a3, a2              # a3 = k + y/k
        srli a3, a3, 1              # a3 = (k + y/k)/2
        mv a2, a3                   # k' = a3
        addi t1, t1, -1             # Ajusta o contador
        bne t1, zero, sqrt_loop     # Retorna para o início do loop
    ret

int_to_str:
    li t1, 10
    li t3, 4
    mv a4, zero
    loop_int:
        slli a4, a4, 8
        remu a3, a2, t1     # Encontra o valor do digito menos significativo atual
        addi a3, a3, 48     # Transforma esse valor em caractere
        add a4, a4, a3      # Adiciona o valor do caractere no registrador da string
        divu a2, a2, t1   
        addi t3, t3, -1     # Ajusta os valores para a próxima iteração
        bne t3, zero, loop_int
    ret 