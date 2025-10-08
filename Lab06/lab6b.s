.bss
    input_Yb_Xc: .skip 0x60         # buffer para o Yb e para o Xc
    input_Ta_Tb_Tc_Tr: .skip 0xa0   # buffer para os tempos do input



# Registradores s0, s1, s2, s3 vão abrigar os valores Ta, Tb, Tc, Tr
# Resgistradores s4 e s5 vão abrigar Yb e Xc

.text


main:
    read:
        li a0, 0  # file descriptor = 0 (stdin)
        la a1, input_Yb_Xc #  buffer to write the data
        li a2, 12  # size (reads 12 bytes)
        li a7, 63 # syscall read (63)
        ecall

    read2:
        li a0, 0  # file descriptor = 0 (stdin)
        la a1, input_Ta_Tb_Tc_Tr #  buffer to write the data
        li a2, 20  # size (reads 20 bytes)
        li a7, 63 # syscall read (63)
        ecall
    
    la a1, input_Ta_Tb_Tc_Tr
    jal str_to_int
    mv s0, a6
    la a1, input_Ta_Tb_Tc_Tr + 5
    jal str_to_int
    mv s1, a6
    la a1, input_Ta_Tb_Tc_Tr + 10
    jal str_to_int
    mv s2, a6
    la a1, input_Ta_Tb_Tc_Tr + 15
    jal str_to_int
    mv s3, a6                       # Ler todos os valores de Tx e colocar nos respectivos registradores

    la a1, input_Yb_Xc
    jal str_to_singned_int
    mv s4, a6
    la a1, input_Yb_Xc + 6
    jal str_to_singned_int
    mv s5, a6                       # Ler os valores de Yb e Xc e salva nos resgistradores salvos
    
    jal calc_da
    mv s6, a0
    jal calc_db
    mv s7, a1
    jal calc_dc
    mv s8, a7
    jal calc_x
    jal calc_y
    
    la a2, input_Yb_Xc
    jal signed_int_to_string
    mv a0, a1
    la a2, input_Yb_Xc + 6
    jal signed_int_to_string

    write:
        li a0, 1                   # file descriptor = 1 (stdout)
        la a1, input_Yb_Xc         # buffer
        li a2, 12                  # size
        li a7, 64                  # syscall write (64)
        ecall

    exit:
        mv a0, a0       # Copia o valor do parâmetro (código de saída) para a0
        li a7, 93       # Carrega o código da chamada de sistema 'exit' (93) em a7
        ecall           # Invoca o sistema operacional para executar a chamada de sistema  

calc_x:
    mul a3, s6, s6              # a3 = da²
    mul a7, s8, s8              # a7 = dc²
    mul a4, s5, s5              # a4 = Xc²
    add a5, a3, a4              # a5 = da² + Xc²
    sub a5, a5, a7              # a5 = da² + Xc² - dc²
    srai a5, a5, 1              # (a5 = da² + Xc² - dc²)/2
    div a5, a5, s5              # (a5 = da² + Xc² - dc²)/2Xc
    mv a0, a5                   # Retorna o valor de y em a0
    ret

calc_y:
    mul a3, s6, s6              # a3 = da²
    mul a1, s7, s7              # a1 = db²
    mul a4, s4, s4              # a4 = Yb²
    add a5, a3, a4              # a5 = da² + Yb²
    sub a5, a5, a1              # a5 = da² + Yb² - db²
    srai a5, a5, 1              # (a5 = da² + Yb² - db²)/2
    div a5, a5, s4              # (a5 = da² + Yb² - db²)/2Yb
    mv a1, a5                   # Retorna o valor de y em a1
    ret

calc_da:
    sub a3, s3, s0                  # Subtrai Tr - Ta
    li t1, 3                        
    mul a3, a3, t1                  # Multiplica a subtração por 3
    li t1, 10                       
    div a3, a3, t1                  # divide o resultado por 10
    mv a0, a3                       # Devolve o valor de da em a0
    ret

calc_db:
    sub a3, s3, s1                  # Subtrai Tr - Tb
    li t1, 3
    mul a3, a3, t1                  # Multiplica a subtração por 3    
    li t1, 10                       
    div a3, a3, t1                  # Divide o resultado por 10
    mv a1, a3                       # Devolve o valor de db em a1
    ret

calc_dc:
    sub a3, s3, s2                  # Subtrai Tr - Tc
    li t1, 3
    mul a3, a3, t1                  # Multiplica a subtração por 3    
    li t1, 10                       
    div a3, a3, t1                  # Divide o resultado por 10
    mv a7, a3
    ret  

str_to_singned_int:
    lb a7, 0(a1)
    addi a7, a7, -45
    mv a6, zero
    li t2, 1000
    li t3, 10
    str_signed_loop:
        lb a2, 1(a1)                     # Carrega o digito atual do numero (milhar -> unidade)
        addi a2, a2, -48                 # Ajusta para o seu valor numérico  
        mul a2, a2, t2                   # Multiplica pelo valor correspondente 
        add a6, a6, a2                   # Adicona o valor ao número ao atual
        divu t2, t2, t3       
        addi a1, a1, 1                   # Ajusta os parametros para o proximo loop
        bne zero, t2, str_signed_loop    # Retorna para o inicio quando o t2 = 1
    bnez a7, nao_negativo
    li t1, -1
    mul a6, a6, t1
    nao_negativo: 
    ret

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

signed_int_to_string:
    li t1, 43               # Carrega o caracter '+'
    sb t1, 0(a2)            # Adiciona o caracter '+' ao início da string
    blt zero, a0, pos       # Caso o número seja menor que 0
    addi t1, t1, 2          
    sb t1, 0(a2)            # Adiciona o caractere  '-' no início da string
    li t1, -1               
    mul a0, a0, t1          # Transforma o número em positivo

    pos:

    addi a2, a2, 1          # Vai para o próximo caractere
    li t1, 4                # Contador
    li t2, 1000
    li t3, 10
    for:
        beqz t1, 1f         # Condição de saída do for
        divu a3, a0, t2     # Pega o valor do dígito mais significativo
        addi a3, a3, 48     # Transforma em char
        sb a3, 0(a2)        # Guarda na memória
        remu a0, a0, t2     # Ajusta o valor do número (retirando o digito mais significativo)
        divu t2, t2, t3     # Ajusta o valor do parametro pelo qual vai dividir
        addi a2, a2, 1      # Vai para o próximo caractere
        addi t1, t1, -1     # Subtrai o contador
        j for
    1:
    ret