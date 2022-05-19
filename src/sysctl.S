.section .text
.align 2

.include "inc/mmap.inc"
.include "inc/sysctl.inc"

.globl setupPLL
setupPLL:
    addi sp, sp, -16
    sd ra, 8(sp)

	# PLL0 --------
	li t0, SYSCTL_BASE_ADDR
	# Change CPU Clock to XTAL
	addi t1, t0, SYSCTL_ACLK_CTL
	ld t2, 0(t1)
	li t3, ACLK_PLL_EN_MASK
	not t3, t3
	and t2, t2, t3
	sd t2, 0(t1)

	# Disable PLL output
	addi t1, t0, SYSCTL_PLL0_CTL
	ld t2, 0(t1)
	lui t3, PLL_OUTPUT_MASK_LUI
	not t3, t3
	and t2, t2, t3
	sd t2, 0(t1)

	# Power off PLL
	ld t2, 0(t1)
	lui t3, PLL_POWER_MASK_LUI
	not t3, t3
	and t2, t2, t3
	sd t2, 0(t1)

	# Set PLL new frequency value
	ld t2, 0(t1)
	li t3, PLL_FREQ_MASK
	not t3, t3
	and t2, t2, t3
	li t3, SYSCTL_PLL0_FREQ
	or t2, t2, t3
	sd t2, 0(t1)

	# Power on PLL
	ld t2, 0(t1)
	lui t3, PLL_POWER_MASK_LUI
	or t2, t2, t3
	sd t2, 0(t1)
	# Wait
	li t3, 0xFF
1:
	addi t3, t3, -1
	bge t3, x0, 1b

	# Reset PLL
	ld t2, 0(t1)
	lui t3, PLL_RESET_MASK_LUI
	not t4, t3
	and t2, t2, t4
	sd t2, 0(t1)
	or t2, t2, t3
	sd t2, 0(t1)
	# Wait
	li t3, 0xFF
1:
	addi t3, t3, -1
	bge t3, x0, 1b

	# Release Reset
	ld t2, 0(t1)
	lui t3, PLL_RESET_MASK_LUI
	not t4, t3
	and t2, t2, t4
	sd t2, 0(t1)

	# Get lock status, wait for PLL to stabilize
	addi t1, t0, SYSCTL_PLL_LOCK
1:
	ld t2, 0(t1)
	li t3, LOCK_PLL0_MASK
	and t2, t2, t3
	beq t2, t3, 2f
	# Clear slip
	ld t2, 0(t1)
	li t3, LOCK_SLIP0_CLEAR
	or t2, t2, t3
	sd t2, 0(t1)
	j 1b
2:

	# Enable PLL output
	addi t1, t0, SYSCTL_PLL0_CTL
	ld t2, 0(t1)
	lui t3, PLL_OUTPUT_MASK_LUI
	or t2, t2, t3
	sd t2, 0(t1)

	# Change CPU Clock to PLL
	addi t1, t0, SYSCTL_ACLK_CTL
	ld t2, 0(t1)
	li t3, ACLK_PLL_EN_MASK
	or t2, t2, t3
	sd t2, 0(t1)

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end
