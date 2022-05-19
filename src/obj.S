.section .text
.align 8

.include "inc/obj.inc"
.include "inc/char.inc"

.globl openOBJModel
# a0 - File buffer
openOBJModel:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Count number of vertices, uvs, normals and polygons
	mv t0, a0
	li s0, 0
	li s1, 0
	li s2, 0
	li s3, 0
2:
	jal ra, getNewLine
	lbu t1, 0(t0)
	addi t0, t0, 1

	# EOF
	beq x0, t1, 5f

	# Vertice
	li t2, CHAR_v
	bne t1, t2, 4f
	lbu t2, 0(t0)
	li t3, CHAR_SPC
	bne t2, t3, 3f
	addi s0, s0, 1
	j 2b
3:
	# UV
	li t3, CHAR_t
	bne t2, t3, 3f
	addi s1, s1, 1
	j 2b
3:
	# Normal
	li t3, CHAR_n
	bne t2, t3, 4f
	addi s2, s2, 1
	j 2b
4:
	# Polygon
	li t2, CHAR_f
	bne t1, t2, 2b
	addi s3, s3, 1
	j 2b
5:

	# Verify values
	# Vertices
	blt x0, s0, 2f
	li a0, 1 # Vertice count too small
	j 1f
2:
	li t1, OBJ_MAX_VERTICES
	bge t1, s0, 2f
	li a0, 1 # Too many vertices
	j 1f
2:
	# UVs
	blt x0, s1, 2f
	li a0, 1 # UV count too small
	j 1f
2:
	li t1, OBJ_MAX_UVS
	bge t1, s1, 2f
	li a0, 1 # Too many UVs
	j 1f
2:
	# Normals
	blt x0, s2, 2f
	li a0, 1 # Normal count too small
	j 1f
2:
	li t1, OBJ_MAX_NORMALS
	bge t1, s2, 2f
	li a0, 1 # Too many Normals
	j 1f
2:
	# Polygon
	blt x0, s3, 2f
	li a0, 1 # Polygon count too small
	j 1f
2:
	li t1, OBJ_MAX_POLYGONS
	bge t1, s3, 2f
	li a0, 1 # Too many polygons
	j 1f
2:
	# Store vertice count
	la t1, vertice_count
	sw s0, 0(t1)
	# Store texture count
	la t1, texture_count
	sw s1, 0(t1)
	# Store normal count
	la t1, normal_count
	sw s2, 0(t1)
	# Store polygon count
	la t1, polygon_count
	sw s3, 0(t1)

	# Load polygons to memory
	la a1, pos_index
	la a2, uv_index
	la a3, norm_index
	jal ra, loadPolygons

	# Load vertices to memory
	la a1, pos
	jal ra, loadVertices

	# Load UVs to memory
	la a1, uv
	jal ra, loadUVs

	# Load normals to memory
	la a1, norm
	jal ra, loadNormals

	li a0, 0 # Setup successful
1:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# a0 - File buffer
# a1 - Vertice Index Buffer
# a2 - UV Index Buffer
# a3 - Normal Index Buffer
loadPolygons:
	addi sp, sp, -16
	sd ra, 8(sp)

	mv t0, a0
	li s0, 0
1:
	jal ra, getNewLine
	lbu t1, 0(t0)
	addi t0, t0, 1

	# EOF
	beq x0, t1, 2f

	# Polygon
	li t2, CHAR_f
	bne t1, t2, 1b

	# Vertice 0
	jal ra, ignoreSpaces
	li t4, CHAR_FSLASH
	jal ra, getNumberFromFace
	# Store vertice 0
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a1
	sw t1, 0(t2)
	# Texture 0
	jal ra, getNumberFromFace
	# Store texture 0
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a2
	sw t1, 0(t2)
	# Normal
	li t4, CHAR_SPC
	jal ra, getNumberFromFace
	# Store normal
	mv t2, s0
	slli t2, t2, 2
	add t2, t2, a3
	sw t1, 0(t2)

	# Vertice 1
	jal ra, ignoreSpaces
	li t4, CHAR_FSLASH
	jal ra, getNumberFromFace
	# Store vertice 1
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a1
	sw t1, 4(t2)
	# Texture 1
	jal ra, getNumberFromFace
	# Store texture 1
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a2
	sw t1, 4(t2)
	# Normal
	li t4, CHAR_SPC
	jal ra, getNumberFromFace

	# Vertice 2
	jal ra, ignoreSpaces
	li t4, CHAR_FSLASH
	jal ra, getNumberFromFace
	# Store vertice 2
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a1
	sw t1, 8(t2)
	# Texture 2
	jal ra, getNumberFromFace
	# Store texture 2
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a2
	sw t1, 8(t2)
	# Normal
	li t4, CHAR_SPC
	jal ra, getNumberFromFace

	# Vertify if it is a triangle
	mv t1, t0
	li t2, CHAR_SPC
3:
	lbu t3, 0(t1)
	addi t1, t1, 1
	beq t2, t3, 3b

	# Verify if it is a number
	li t2, CHAR_0
	blt t3, t2, 2f
	li t2, CHAR_9
	blt t2, t3, 2f
	j 3f
2:
	# If it is a triangle, copy the third vertex to the fourth
	mv t2, s0
	slli t2, t2, 4
	# Vertice 2 -> Vertice 3
	add t3, t2, a1
	lwu t1, 8(t3)
	sw t1, 12(t3)
	# Texture 2 -> Texture 3
	add t3, t2, a2
	lwu t1, 8(t3)
	sw t1, 12(t3)
	j 4f
3:

	# Vertice 3
	jal ra, ignoreSpaces
	li t4, CHAR_FSLASH
	jal ra, getNumberFromFace
	# Store vertice 3
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a1
	sw t1, 12(t2)
	# Texture 3
	jal ra, getNumberFromFace
	# Store texture 3
	mv t2, s0
	slli t2, t2, 4
	add t2, t2, a2
	sw t1, 12(t2)
	# Normal
	li t4, CHAR_SPC
	jal ra, getNumberFromFace

4:
	addi s0, s0, 1
	la t1, polygon_count
	lwu t1, 0(t1)
	blt s0, t1, 1b
2:

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# a0 - File buffer
# a1 - Vertice Buffer
loadVertices:
	addi sp, sp, -16
	sd ra, 8(sp)

	mv t0, a0
	li s0, 0
1:
	jal ra, getNewLine
	lbu t1, 0(t0)
	addi t0, t0, 1

	# EOF
	beq x0, t1, 2f

	# Vertice
	li t2, CHAR_v
	bne t1, t2, 1b
	li t2, CHAR_SPC
	lbu t1, 0(t0)
	bne t1, t2, 1b

	# Vertice x
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store vertice x
	mv t2, s0
	li t3, 12
	mul t2, t2, t3
	add t2, t2, a1
	fsw fa0, 0(t2)

	# Vertice y
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store vertice y
	mv t2, s0
	li t3, 12
	mul t2, t2, t3
	add t2, t2, a1
	fsw fa0, 4(t2)

	# Vertice z
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store vertice z
	mv t2, s0
	li t3, 12
	mul t2, t2, t3
	add t2, t2, a1
	fsw fa0, 8(t2)

	addi s0, s0, 1
	la t1, vertice_count
	lwu t1, 0(t1)
	blt s0, t1, 1b
2:

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# a0 - File buffer
# a1 - UV Buffer
loadUVs:
	addi sp, sp, -16
	sd ra, 8(sp)

	mv t0, a0
	li s0, 0
1:
	jal ra, getNewLine
	lbu t1, 0(t0)
	addi t0, t0, 1

	# EOF
	beq x0, t1, 2f

	# UV
	li t2, CHAR_v
	bne t1, t2, 1b
	li t2, CHAR_t
	lbu t1, 0(t0)
	bne t1, t2, 1b
	addi t0, t0, 1

	# UV x
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store UV x
	mv t2, s0
	slli t2, t2, 3
	add t2, t2, a1
	fsw fa0, 0(t2)

	# UV y
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store UV y
	mv t2, s0
	slli t2, t2, 3
	add t2, t2, a1
	fsw fa0, 4(t2)

	addi s0, s0, 1
	la t1, texture_count
	lwu t1, 0(t1)
	blt s0, t1, 1b
2:

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# a0 - File buffer
# a1 - Normal Buffer
loadNormals:
	addi sp, sp, -16
	sd ra, 8(sp)

	mv t0, a0
	li s0, 0
1:
	jal ra, getNewLine
	lbu t1, 0(t0)
	addi t0, t0, 1

	# EOF
	beq x0, t1, 2f

	# UV
	li t2, CHAR_v
	bne t1, t2, 1b
	li t2, CHAR_n
	lbu t1, 0(t0)
	bne t1, t2, 1b
	addi t0, t0, 1

	# Normal x
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store Normal x
	mv t2, s0
	li t3, 12
	mul t2, t2, t3
	add t2, t2, a1
	fsw fa0, 0(t2)

	# Normal y
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store Normal y
	mv t2, s0
	li t3, 12
	mul t2, t2, t3
	add t2, t2, a1
	fsw fa0, 4(t2)

	# Normal z
	jal ra, ignoreSpaces
	jal ra, getFloatFromValue
	# Store Normal z
	mv t2, s0
	li t3, 12
	mul t2, t2, t3
	add t2, t2, a1
	fsw fa0, 8(t2)

	addi s0, s0, 1
	la t1, texture_count
	lwu t1, 0(t1)
	blt s0, t1, 1b
2:

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

	# New line
	li t2, CHAR_NL
	bne t1, t2, 2f
	j 1b
2:
	# EOF
	beq t1, x0, 2f

	# Useful line
	li t2, CHAR_v
	beq t1, t2, 2f
	li t2, CHAR_f
	beq t1, t2, 2f

	# Unused line
3:
	lbu t1, 0(t0)
	addi t0, t0, 1

	# Line ended
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

# t0 - Temp File buffer
getFloatFromValue:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Check sign
	li s1, 0
	li t4, CHAR_MINUS
	lbu t1, 0(t0)
	bne t1, t4, 2f
	li s1, 1 # s1 : 0 = + ; 1 = -
	addi t0, t0, 1
2:

	# Get number left of the dot
	li t4, CHAR_SPC
	li t5, CHAR_NL
	li t6, CHAR_DOT
	li t3, 0
3:
	lbu t1, 0(t0)
	addi t0, t0, 1
	beq t1, t4, 1f
	beq t1, t5, 1f
	beq t1, t6, 2f

	li t2, CHAR_0
	sub t1, t1, t2
	li t2, 10
	mul t3, t3, t2
	add t3, t3, t1
	j 3b

2:
	fcvt.s.w ft0, t3

	# Get number right of the dot
	li t3, 0
	li s2, 1
3:
	lbu t1, 0(t0)
	addi t0, t0, 1
	beq t1, t4, 2f
	beq t1, t5, 2f
	
	li t2, CHAR_0
	sub t1, t1, t2
	li t2, 10
	mul t3, t3, t2
	add t3, t3, t1
	mul s2, s2, t2
	j 3b
2:
	fcvt.s.w ft1, t3
	fcvt.s.w ft2, s2
	fdiv.s ft1, ft1, ft2
	fadd.s ft0, ft0, ft1

1:
	# Change sign
	beq x0, s1, 1f
	fneg.s ft0, ft0
1:
	fmv.s fa0, ft0

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# t0 - Temp File buffer
# t4 - Stop Character
getNumberFromFace:
	addi sp, sp, -16
	sd ra, 8(sp)

	li t5, CHAR_NL
	li t3, 0
3:
	lbu t1, 0(t0)
	addi t0, t0, 1
	beq t1, t4, 2f
	beq t1, t5, 2f

	li t2, CHAR_0
	sub t1, t1, t2
	li t2, 10
	mul t3, t3, t2
	add t3, t3, t1
	j 3b
2:
	mv t1, t3
	addi t1, t1, -1

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# t0 - Temp File buffer
ignoreSpaces:
	addi sp, sp, -16
	sd ra, 8(sp)

	li t2, CHAR_SPC
1:
	# Ignore spaces
	lbu t1, 0(t0)
	addi t0, t0, 1
	beq t1, t2, 1b

	addi t0, t0, -1

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end