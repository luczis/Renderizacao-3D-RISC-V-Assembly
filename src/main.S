.section .rodata
.align 4

.include "inc/files.inc"

.section .text
.align 4

.include "inc/colors.inc"
.include "inc/fpioa.inc"
.include "inc/gpio.inc"
.include "inc/pinmap.inc"

.comm frame_buffer0, 320*240*4
.comm frame_buffer1, 320*240*4
.comm texture, 300*300*2
.comm ready_flag, 4
.comm fb_select, 4

.globl main
main:
	addi sp, sp, -32
	sd ra, 8(sp)

	# Setup PLL
	jal ra, setupPLL

	# Setup LEDs for Debugging purposes
	li a0, PIN_LED_G
	li a1, PIN_LED_G_CONFIG
	jal ra, setupFPIOA
	li a0, GPIOHS_LED_G
	li a1, GPIO_OUTPUT
	jal ra, setupGPIOHS
	li a0, PIN_LED_B
	li a1, PIN_LED_B_CONFIG
	jal ra, setupFPIOA
	li a0, GPIOHS_LED_B
	li a1, GPIO_OUTPUT
	jal ra, setupGPIOHS

	# Initialize TFT display
	jal ra, tftInitialize
	la a0, frame_buffer0
	li a1, COLOR_LOADING
	jal ra, clearScreen
	la a0, frame_buffer0
	jal ra, tftRefreshDisplay

	# Initialize SD card
	li t0, 0x3 # Timeout tries
	sw t0, 24(sp)
1:

	jal ra, sdInitialize
	beq x0, a0, 1f # SD card initialized

	lwu t0, 24(sp)
	addi t0, t0, -1
	sw t0, 24(sp)
	bge t0, x0, 1b
	
	li a1, COLOR_ERROR_SD
	bne x0, a0, failure # Failed to initialize SD card
1:

	# Open FAT
	jal ra, openFAT
	li a1, COLOR_ERROR_FAT
	bne x0, a0, failure # Failed to open FAT

	# Load the ppm texture
	la a0, ppm_file
	la a1, frame_buffer0
	jal ra, readFile
	li a1, COLOR_INVALID_PPM
	bne x0, a0, failure # Failed to read file

	la a0, frame_buffer0
	la a1, texture
	jal ra, openPPMTex
	li a1, COLOR_PROBLEM_PPM
	bne x0, a0, failure # File incompatible
	
	# Load the obj model
	la a0, obj_file
	la a1, frame_buffer0
	jal ra, readFile
	li a1, COLOR_INVALID_OBJ
	bne x0, a0, failure # Failed to read file

	la a0, frame_buffer0
	jal ra, openOBJModel
	li a1, COLOR_PROBLEM_OBJ
	bne x0, a0, failure # File incompatible

	la t0, ready_flag
	li t1, 1
	sb t1, 0(t0)
	sb t1, 1(t0)

#end

loop0:

	# TODO: Change flags to fence
	la t0, ready_flag
1:
	lbu t1, 1(t0)
	beq x0, t1, 1b

	la t0, ready_flag
	sb x0, 0(t0)

	# DEBUG: Utilized to measure framerate
	# Turn off LED
	li t0, 1
	slli a0, t0, GPIOHS_LED_G
	mv a1, a0
	jal ra, outputGPIOHS

	# Clear frame buffer
	la t0, fb_select
	lwu t1, 0(t0)
	la a0, frame_buffer0
	beq t1, x0, 1f
	la a0, frame_buffer1
1:
	#li a1, 0x03
	li a1, 0xAAAA
	jal ra, clearScreen

	# Render model
	la t0, fb_select
	lwu t1, 0(t0)
	la a0, frame_buffer0
	beq t1, x0, 1f
	la a0, frame_buffer1
1:
	la a1, texture
	jal ra, renderModel

	# Change frame buffer
	la t0, fb_select
	lwu t1, 0(t0)
	xori t1, t1, 0x1
	sw t1, 0(t0)

	# DEBUG: Utilized to measure framerate
	# Turn on LED
	li t0, 1
	slli a0, t0, GPIOHS_LED_G
	mv a1, x0
	jal ra, outputGPIOHS

	la t0, ready_flag
	li t1, 1
	sb t1, 0(t0)

	j loop0
#end

.globl loop1
loop1:

	la t0, ready_flag
1:
	lbu t1, 0(t0)
	beq x0, t1, 1b

	la t0, ready_flag
	sb x0, 1(t0)

	# DEBUG: Utilized to measure time
	# Turn off LED
	li t0, 1
	slli a0, t0, GPIOHS_LED_B
	mv a1, a0
	jal ra, outputGPIOHS

	# Update display
	la t0, fb_select
	lwu t1, 0(t0)
	la a0, frame_buffer1
	beq t1, x0, 1f
	la a0, frame_buffer0
1:
	jal ra, tftRefreshDisplay

	# DEBUG: Utilized to measure time
	# Turn on LED
	li t0, 1
	slli a0, t0, GPIOHS_LED_B
	mv a1, x0
	jal ra, outputGPIOHS

	la t0, ready_flag
	li t1, 1
	sb t1, 1(t0)

	j loop1
#end

# a1 - Color
failure:
	# Clear frame buffer
	la a0, frame_buffer0
	jal ra, clearScreen

	# Update display
	la a0, frame_buffer0
	jal ra, tftRefreshDisplay

	# Lock
1:
	nop
	j 1b
#end
