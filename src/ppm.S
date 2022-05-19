.section .text
.align 1

.include "inc/ppm.inc"
.include "inc/char.inc"

.globl openPPMTex
# a0 - File buffer
# a1 - Texture buffer
openPPMTex:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Check if it is ppm file
	mv t0, a0
	jal ra, getNewLine

	lbu t1, 0(t0)
	li t2, CHAR_P
	beq t1, t2, 2f
	li a0, 1 # Not a ppm file
	j 1f
2:
	# Get ppm magic number
	addi t0, t0, 1
	lbu t1, 0(t0)
	li t2, CHAR_0
	sub t1, t1, t2
	li t2, 6
	beq t1, t2, 2f
	li a0, 1 # Unsuported ppm
	j 1f
2:
	# Get image dimensions
	addi t0, t0, 1
	jal ra, getNewLine
	# Width
	li t3, 0
	lbu t1, 0(t0)
	li t2, CHAR_0
	sub t3, t1, t2
2:
	addi t0, t0, 1
	lbu t1, 0(t0)
	li t2, CHAR_SPC
	beq t1, t2, 3f
	li t2, 10
	mul t3, t3, t2
	li t2, CHAR_0
	sub t1, t1, t2
	add t3, t3, t1
	j 2b
3:
	# Verify dimensions
	blt x0, t3, 2f
	li a0, 1 # Invalid width
	j 1f
2:
	li t2, PPM_MAX_WIDTH
	bge t2, t3, 2f
	li a0, 1 # Invalid width
	j 1f
2:
	la t2, texture_size
	sh t3, 0(t2)

	# Height
	addi t0, t0, 1
	li t3, 0
	lbu t1, 0(t0)
	li t2, CHAR_0
	sub t3, t1, t2
2:
	addi t0, t0, 1
	lbu t1, 0(t0)
	li t2, CHAR_NL
	beq t1, t2, 3f
	li t2, CHAR_SPC
	beq t1, t2, 3f
	li t2, CHAR_HASH
	beq t1, t2, 3f
	li t2, 10
	mul t3, t3, t2
	li t2, CHAR_0
	sub t1, t1, t2
	add t3, t3, t1
	j 2b
3:
	# Verify dimensions
	blt x0, t3, 2f
	li a0, 1 # Invalid height
	j 1f
2:
	li t2, PPM_MAX_HEIGHT
	bge t2, t3, 2f
	li a0, 1 # Invalid height
	j 1f
2:
	la t2, texture_size
	sh t3, 2(t2)

	# Get maximum color value
	jal ra, getNewLine
	li t3, 0
	lbu t1, 0(t0)
	li t2, CHAR_0
	sub t3, t1, t2
2:
	addi t0, t0, 1
	lbu t1, 0(t0)
	li t2, CHAR_NL
	beq t1, t2, 3f
	li t2, CHAR_SPC
	beq t1, t2, 3f
	li t2, CHAR_HASH
	beq t1, t2, 3f
	li t2, 10
	mul t3, t3, t2
	li t2, CHAR_0
	sub t1, t1, t2
	add t3, t3, t1
	j 2b
3:
	# Verify value
	li t2, PPM_COLOR_DEPTH
	beq t2, t3, 2f
	li a0, 1 # Unsuported value
	j 1f
2:

	# Get image data
	jal ra, getNewLine
	la t1, texture_size
	lhu t2, 0(t1)
	lhu t3, 2(t1)
	mul s0, t2, t3
	li s1, 0
	li s2, 0xF8
	li s3, 0xFC
2:
	# Red
	lbu t1, 0(t0)
	and t2, t1, s2
	slli t2, t2, 8
	# Green
	addi t0, t0, 1
	lbu t1, 0(t0)
	and t3, t1, s3
	slli t3, t3, 3
	or t2, t2, t3
	# Blue
	addi t0, t0, 1
	lbu t1, 0(t0)
	srli t3, t1, 3
	or t1, t2, t3

	# Store texture
	slli t2, s1, 1
	add t2, t2, a1
	sh t1, 0(t2)

	addi t0, t0, 1
	addi s1, s1, 1
	blt s1, s0, 2b

	li a0, 0 # Setup successful 
1:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# t0 - Temp File buffer
getNewLine:
	addi sp, sp, -16
	sd ra, 8(sp)

1:
	lbu t1, 0(t0)
	addi t0, t0, 1

	# Space
	li t2, CHAR_SPC
	bne t1, t2, 2f
	j 1b
2:
	# New line
	li t2, CHAR_NL
	bne t1, t2, 2f
	j 1b
2:
	# Commented line
	li t2, CHAR_HASH
	bne t1, t2, 2f
3:
	lbu t1, 0(t0)
	addi t0, t0, 1

	# Commented ended
	li t2, CHAR_NL
	bne t1, t2, 3b
	addi t0, t0, -1
	j 1b
2:
	addi t0, t0, -1

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end