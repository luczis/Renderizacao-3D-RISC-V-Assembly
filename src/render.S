.section .text
.align 8

# Base Matrix
.comm base_matrix 4*4*4

.globl renderSquare
# a0 - Frame Buffer
# a1 - Texture
# a2 - Vertexes
# fa0 - Light Intensity
renderSquare:
	addi sp, sp, -32
	sd ra, 8(sp)
	sw a0, 12(sp)
	sw a1, 16(sp)
	sw a2, 20(sp)
	fsw fa0, 24(sp)

	# Multiply Vertexes
	lwu a0, 20(sp)
	jal ra, multiplyModel
	lwu a0, 20(sp)
	addi a0, a0, 20
	jal ra, multiplyModel
	lwu a0, 20(sp)
	addi a0, a0, 40
	jal ra, multiplyModel
	lwu a0, 20(sp)
	addi a0, a0, 60
	jal ra, multiplyModel

	# Draw Square
	lwu a0, 12(sp)
	lwu a1, 16(sp)
	lwu a2, 20(sp)
	addi a3, a2, 20
	addi a4, a2, 40
	addi a5, a2, 60
	flw fa0, 24(sp)
	jal ra, drawSquare

	ld ra, 8(sp)
	addi sp, sp, 32
	ret
#end
