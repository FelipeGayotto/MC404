.bss
    input_yb_xc: .skip 0x60         # buffer para o Yb e para o Xc
    input_Ta_Tb_Tc_Tr: .skip 0xa0   # buffer para os tempos do input


main:



    exit:
        mv a0, a0       # Copia o valor do parâmetro (código de saída) para a0
        li a7, 93       # Carrega o código da chamada de sistema 'exit' (93) em a7
        ecall           # Invoca o sistema operacional para executar a chamada de sistema  

calc_db:

calc_da:


str_to_singned_int:
    lb a7, 0(a1)
    addi a7, a7, -45
    mv a6, zero
    li t2, 1000
    li t3, 10
    str_loop:
        lb a2, 1(a1)            # Carrega o digito atual do numero (milhar -> unidade)
        addi a2, a2, -48        # Ajusta para o seu valor numérico  
        mul a2, a2, t2          # Multiplica pelo valor correspondente 
        add a6, a6, a2          # Adicona o valor ao número ao atual
        divu t2, t2, t3       
        addi a1, a1, 1          # Ajusta os parametros para o proximo loop
        bne zero, t2, str_loop    # Retorna para o inicio quando o t2 = 1
    bnez a7, nao_negativo
    mul a6, a6, -1
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

sqrt:
    mv a2, zero
    srli a2, a6, 1  # Acha o valor base de k
    li t1, 10        # Começa o contador
    sqrt_loop:
        divu a3, a6, a2           # a3 = y/k
        add a3, a3, a2              # a3 = k + y/k
        srli a3, a3, 1              # a3 = (k + y/k)/2
        mv a2, a3                   # k' = a3
        addi t1, t1, -1             # Ajusta o contador
        bne t1, zero, sqrt_loop     # Retorna para o início do loop
    ret
