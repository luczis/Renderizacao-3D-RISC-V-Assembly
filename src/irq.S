.section .text
.align 8

.include "inc/mmap.inc"
.include "inc/sysctl.inc"
.include "inc/csr.inc"
.include "inc/plic.inc"

.globl handleSyscall
handleSyscall:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Lock core in a loop
1:
	nop
	j 1b
#end

.globl handleIRQ
handleIRQ:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Lock core in a loop
1:
	nop
	j 1b
#end

.globl handleIrqMExt
handleIrqMExt:
	addi sp, sp, -32
	sd ra, 8(sp)

	# Verify if interrupt bit is set
	li t0, MIE_EXTRN_M_EN_MASK
	csrr t1, mip
	bne t0, t1, 1f

	# Get core Hart id
	csrr t0, mhartid

	# Get primitive interrupt enable flag
	csrr t1, mie
	sd t1, 16(sp)

	# Get current Interupt ReQuest (IRQ) number
	lui t1, PLIC_BASE_ADDR_LUI
	li t2, 0x1000
	mul t2, t2, t0
	add t1, t1, t2
	lw t2, 0x4(t1)

	# Get primitive IRQ threshold
	lw t3, 0(t1)
	sd t3, 24(sp)

	# Set new IRQ threshold
	lui t3, PLIC_BASE_ADDR_LUI
	li t4, PLIC_SRC_PRIORITIES_OFFSET
	add t3, t3, t4
	slli t2, t2, 2
	add t3, t3, t2 # PLIC IRQ Source Priority
	lw t3, 0(t3)
	sw t3, 0(t1)

	# Disable software and timer interrupts
	li t3, MIE_SOFTW_M_EN_MASK
	ori t3, t3, MIE_TIMER_M_EN_MASK
	csrc mie, t3

	# Enable global interrupt
	li t3, MSTATUS_MIE_MASK
	csrs mstatus, t3

1:
	ld ra, 8(sp)
	addi sp, sp, 32
	ret
#end
