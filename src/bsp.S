.section .text
.align 2

.include "inc/mmap.inc"
.include "inc/sysctl.inc"
.include "inc/csr.inc"
.include "inc/plic.inc"

#.globl wake_up_core_1
#wake_up_core_1:
#	.word 0

.globl initBSP
initBSP:
    addi sp, sp, -16
    sd ra, 8(sp)

	# Get core Hart id
	csrr t0, mhartid
	bne x0, t0, 1f
	
	# If core 0 initialize this section
	# Zero out BSS
	jal ra, initBSS

	# Initialize FPIOA
	jal ra, initFPIOA

	# Reset sysctl source status
	lui t0, SYSCTL_BASE_ADDR_LUI
	addi t0, t0, SYSCTL_RST_SST
	ld t1, 0(t0)
	li t2, SYSCTL_RST_CLR_MASK
	or t1, t1, t2
	sd t1, 0(t0)

	# Init Platform-Level Interrupt Controller (PLIC)
	jal ra, initPlic

	# Enable Global Interrupts
	jal ra, enable_irq

	# Enable Core 1 Machine-mode Software Interrupts (MSIP)
	# in the Coreplex-Local INTerrupts (CLINT)
	lui t0, CLINT_BASE_ADDR_LUI
	li t1, 0x1
	lwu t2, 0x4(t0)
	or t2, t2, t1
	sw t2, 0x4(t0)

	# Free core 1
	la t0, g_wake_up
	addi t0, t0, 8
	li t1, 1
2:
	lr.d t2, (t0)
	sc.d t2, t1, (t0)
	bne t2, x0, 2b

	# Send core 0 to main function
	j main

1:
	# If core 1 initialize this section
	# Init Platform-Level Interrupt Controller (PLIC)
	jal ra, initPlic

	# Enable Global Interrupts
	jal ra, enable_irq

	# Wait for core 0 setup
	la t0, g_wake_up
2:
	ld t1, 0x8(t0)
	beq t1, x0, 2b

	# Send core 1 to loop function
	j loop1

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

initBSS:
    addi sp, sp, -16
    sd ra, 8(sp)

	la t0, _bss  # BSS memory start
	la t1, _ebss # BSS memory end

	# Zero out BSS memory region
1: 
	sd x0, 0(t0)
	addi t0, t0, 8
	blt t0, t1, 1b

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.globl enable_irq
enable_irq:
    addi sp, sp, -16
    sd ra, 8(sp)

	# Enable external machine interrupt requests
	li t0, MIE_EXTRN_M_EN_MASK
	csrs mie, t0

	# Set status of the Machine Interrupt Enable status register
	li t0, MSTATUS_MIE_MASK
	csrs mstatus, t0

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.globl initPlic
initPlic:
    addi sp, sp, -16
    sd ra, 8(sp)

	# Get core Hart id
	csrr t0, mhartid
	li t1, 80
	mul t1, t1, t0

	# Disable all interrupts for this core
	lui t0, PLIC_BASE_ADDR_LUI
	add t1, t1, t0
	li t1, PLIC_ENABLE_OFFSET
	add t1, t1, t0

	mv t2, x0
	li t3, PLIC_NUM_SOURCES
	srli t3, t3, 3
1:
	add t4, t1, t2
	#sb x0, 0(t4)
	#sb x0, 1(t4)
	#sb x0, 2(t4)
	#sb x0, 3(t4)
	sw x0, 0(t4)
	addi t2, t2, 4
	blt t2, t3, 1b

	# Set sources priorities to zero on first setup
	la t1, plic_init_flag
	lbu t1, 0(t1)
	bne x0, t1, 1f

	lui t0, PLIC_BASE_ADDR_LUI
	li t1, PLIC_SRC_PRIORITIES_OFFSET
	add t1, t1, t0

	mv t2, x0
	li t3, PLIC_NUM_SOURCES
	slli t3, t3, 2
1:
	add t4, t1, t2
	# This must be stored in 1 byte, in order to avoid misalignment
	sb x0, 0(t4)
	addi t2, t2, 1
	blt t2, t3, 1b

	la t1, plic_init_flag
	li t2, 1
	sb t2, 0(t1)
1:
	# Set the target threshold to zero
	csrr t0, mhartid
	li t1, 0x1000
	mul t1, t1, t0
	lui t0, PLIC_BASE_ADDR_LUI
	add t0, t0, t1
	sw x0, 0(t0)

	# Clear the target claims 
	lwu t1, 0x4(t0)
	li t2, 100
1:
	lwu t1, 0x4(t0)
	bne x0, t1, 2f
	addi t2, t2, -1
	bge t2, x0, 1b
2:

	# Enable external machine interrupt requests
	li t0, MIE_EXTRN_M_EN_MASK
	csrs mie, t0

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.section .data
plic_init_flag:
	.word 0
