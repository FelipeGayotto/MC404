.bss
    .align 2
    stack: .skip 1024
    stack_end:
    ISR_stack: .skip 1024
    ISR_stack_end:
    camera: .skip 256

.text
.align 4

int_handler:
    ###### Syscall and Interrupts handler ######

    # Salvar o contexto

    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -16 # Aloca espaço na pilha
    sw t0, 0(sp) # Salva t0
    sw t1, 4(sp) # Salva t1
    sw t2, 8(sp) # Salva t2
    sw s0, 12(sp) # Salva s0

    li s0, 0xFFFF0100

    li t0, 10
    beq t0, a7, 1f
    li t0, 11
    beq t0, a7, 2f
    li t0, 12
    beq t0, a7, 3f
    li t0, 15
    beq t0, a7, 4f
    1:
        li t0, -1
        li t2, -1
        blt a0, t2, 1f
        li t2, 1
        blt t2, a0, 1f
        li t2, 127
        blt t2, a1, 1f
        li t2, -127
        blt a1, t2, 1f

        sb a0, 0x21(s0)
        sb a1, 0x20(s0)
    1:
        mv a0, t0
        j fim
    2:
        sb a0, 0x22(s0)
        j fim
    3:
        li t0, 1
        sb t0, 0x1(s0)
        li t0, 255
        1:
            beqz t0, 1f
            mv t1, s0
            lb t2, 0x24(t1)
            sb t2, 0(a0)
            addi t1, t1, 1
            addi a0, a0, 1
            j 1b
        1:
            j fim
    4:
        li t0, 1
        sb t0, 0x0(s0)
        lw t0, 0x10(s0)
        lw t1, 0x14(s0)
        lw t2, 0x18(s0)
        lw t0, (a0)
        lw t1, (a1)
        lw t2, (a2)
        j fim
    fim:

    # Recupera o contexto

    lw s0, 12(sp) # Recupera s0
    lw t2, 8(sp) # Recupera t2
    lw t1, 4(sp) # Recupera t1
    lw t0, 0(sp) # Recupera t0
    addi sp, sp, 16 # Desaloca espaço da pilha
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente
    
    
    # <= Implement your syscall handler here

    csrr t0, mepc  # load return address (address of
                    # the instruction that invoked the syscall)
    addi t0, t0, 4 # adds 4 to the return address (to return after ecall)
    csrw mepc, t0  # stores the return address back on mepc

    li t0, 00
    csrw mstatus, t0

    mret           # Recover remaining context (pc <- mepc)


.globl _start
_start:

    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                        # the interrupt array.
                        
    la t0, ISR_stack_end    # t0 <= base da pilha
    csrw mscratch, t0       # mscratch <= t0
    la sp, stack_end

    # Habilita Interrupções Externas
    csrr t1, mie # Seta o bit 11 (MEIE)
    li t2, 0x800 # do registrador mie
    or t1, t1, t2
    csrw mie, t1
    # Habilita Interrupções Global
    csrr t1, mstatus # Seta o bit 3 (MIE)
    ori t1, t1, 0x8 # do registrador mstatus
    csrw mstatus, t1

    li t0, 00
    csrw mstatus, t0

    jal user_main

.globl control_logic
control_logic:
    set_volante_motor:
        li a0, 1
        li a1, -15
        li a7, 10
        ecall
    bnez a0, set_volante_motor

    aciona_GPS:
        addi sp, sp, -16

        mv a0, sp
        addi a1, sp, 4
        addi a2, sp, 8
        li a7, 15
        ecall

        lw t0, 0(sp)
        lw t1, 4(sp)
        lw t2, 8(sp)
        
        addi sp, sp, 16

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
        bge t1, t0, aciona_GPS
    
    para_o_carro:
        li a0, 0
        li a1, 0
        li a7, 10
        ecall
    bnez a0, set_volante_motor

    aciona_freio_de_mao:
        li a0, 1
        li a7, 11
        ecall
    ret


    


    



