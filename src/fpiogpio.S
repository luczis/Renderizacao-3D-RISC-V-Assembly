.section .text
.align 2

.include "inc/mmap.inc"
.include "inc/fpioa.inc"
.include "inc/gpio.inc"
.include "inc/pinmap.inc"
.include "inc/sysctl.inc"

.globl initFPIOA
initFPIOA:
    addi sp, sp, -16
    sd ra, 8(sp)

	# Enable central clock bus
	lui t0, SYSCTL_BASE_ADDR_LUI
	addi t1, t0, SYSCTL_CBUS_EN
	lwu t2, 0(t1)
	li t3, CBUS_APB0_MASK
	or t2, t2, t3
	sw t2, 0(t1)

	# Enable FPIOA clock
	addi t1, t0, SYSCTL_PERI_EN
	lwu t2, 0(t1)
	li t3, PERI_FPIOA_MASK
	or t2, t2, t3
	sw t2, 0(t1)

	# Configure multiplex tie
	lui t0, FPIOA_BASE_ADDR_LUI
	addi t1, t0, FPIOA_TIE_EN_OFF
	addi t2, t0, FPIOA_TIE_VAL_OFF
	li t3, FPIOA_TIE0
	sw t3, 0(t1)
	sw t3, 0(t2)
	li t3, FPIOA_TIE1
	sw t3, 4(t1)
	sw t3, 4(t2)
	li t3, FPIOA_TIE2
	sw t3, 8(t1)
	sw t3, 8(t2)
	li t3, FPIOA_TIE3
	sw t3, 12(t1)
	sw t3, 12(t2)
	li t3, FPIOA_TIE4
	sw t3, 16(t1)
	sw t3, 16(t2)
	li t3, FPIOA_TIE5
	sw t3, 20(t1)
	sw t3, 20(t2)
	li t3, FPIOA_TIE6
	sw t3, 24(t1)
	sw t3, 24(t2)
	li t3, FPIOA_TIE7
	sw t3, 28(t1)
	sw t3, 28(t2)

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.globl setupFPIOA
# a0 - Pin Number
# a1 - Configuration Value
setupFPIOA:
    addi sp, sp, -16
    sd ra, 8(sp)

    # Skip if out of range
    li t0, PINS_MAX
    bltu t0, a0, 1f

	# Configure FPIOA
    li t0, FPIOA_BASE_ADDR
    slli t1, a0, 0x2
    c.add t0, t1
    sw a1, 0(t0)

1:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.globl setupGPIO
# a0 - GPIO Number
# a1 - Direction
setupGPIO:
    addi sp, sp, -16
    sd ra, 8(sp)
    
    # Skip if out of range
    li t0, GPIO_MAX
    bltu t0, a0, 1f

    li t0, GPIO_BASE_ADDR
    lw t1, GPIO_DIR_OFF(t0)
    li t2, 1
    sll t2, t2, a0
    not t2, t2
    and t1, t1, t2
    mv t2, a1
    sll t2, t2, a0
    or t1, t1, t2
    sw t1, GPIO_DIR_OFF(t0)

1:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.globl setupGPIOHS
# a0 - GPIOHS Number
# a1 - Direction
setupGPIOHS:
    addi sp, sp, -16
    sd ra, 8(sp)

    # Skip if out of range
    li t0, GPIOHS_MAX
    bltu t0, a0, 1f

	li t0, GPIOHS_BASE_ADDR
	li t1, 1
	sll t1, t1, a0

	# Set Input REG
	lw t2, GPIOHS_IN_EN(t0)
	not t3, t1
	and t2, t2, t3
	mv t3, a1
	not t3, t3
	andi t3, t3, 0x1
	sll t3, t3, a0
	or t2, t2, t3
	sw t2, GPIOHS_IN_EN(t0)

	# Set Output REG
	lw t2, GPIOHS_OUT_EN(t0)
	not t3, t1
	and t2, t2, t3
	mv t3, a1
	sll t3, t3, a0
	or t2, t2, t3
	sw t2, GPIOHS_OUT_EN(t0)

1:
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.globl outputGPIO
# a0 - Mask
# a1 - Output
outputGPIO:
	addi sp, sp, -16
	sd ra, 8(sp)

	li t0, GPIO_BASE_ADDR
	lw t1, GPIO_OUT_OFF(t0)
	not t2, a0
	and t1, t1, t2
	and t2, a0, a1
	or t1, t1, t2
	sw t1, GPIO_OUT_OFF(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl outputGPIOHS
# a0 - Mask
# a1 - Output
outputGPIOHS:
	addi sp, sp, -16
	sd ra, 8(sp)

	li t0, GPIOHS_BASE_ADDR
	lw t1, GPIOHS_OUT_VAL(t0)
	not t2, a0
	and t1, t1, t2
	and t2, a0, a1
	or t1, t1, t2

	sw t1, GPIOHS_OUT_VAL(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end
