.section .data
.align 8

# Light position
light_pos:
	.float 0.0, 1.0, -1.0

light_min:
	.float 0.2

light_max:
	.float 1.0

.section .text
.align 8

# Count
.globl polygon_count
.comm polygon_count 4
.globl vertice_count
.comm vertice_count 4
.globl texture_count
.comm texture_count 4
.globl normal_count
.comm normal_count 4
# Indexes
.globl pos_index
.comm pos_index 500*4*4 # OBJ_MAX_POLYGONS = 500
.globl uv_index
.comm uv_index 500*4*4  # OBJ_MAX_POLYGONS = 500
.globl norm_index
.comm norm_index 500*4  # OBJ_MAX_POLYGONS = 500
# Values
.globl pos
.comm pos 500*4*3  # OBJ_MAX_VERTICES = 500
.globl uv
.comm uv 500*4*2   # OBJ_MAX_UVS = 500
.globl norm
.comm norm 500*4*3 # OBJ_MAX_NORMALS = 500
# Vertex buffer
.comm vertex 5*16
.comm normal_buffer 4*4

.globl renderModel
# a0 - Frame Buffer
# a1 - Texture
renderModel:
	addi sp, sp, -40
	sd ra, 8(sp)
	sw a0, 16(sp)
	sw a1, 20(sp)

	# Make Object rotate
	# Just for testing, may be removed
	la t0, rotate_angle
	flw fa0, 0(t0)
	li t1, 4
	fcvt.s.w ft0, t1
	li t1, 1
	fcvt.s.w ft1, t1
	fdiv.s ft0, ft0, ft1
	fadd.s fa0, fa0, ft0
	fsw fa0, 0(t0)

	# Make Object move
	# Just for testing, may be removed
	la t0, translate_vector
	flw fa0, 4(t0)
	li t1, 1
	fcvt.s.w ft0, t1
	li t1, 50
	fcvt.s.w ft1, t1
	fdiv.s ft0, ft0, ft1
	fneg.s ft0, ft0
	fadd.s fa0, fa0, ft0
	#fsw fa0, 4(t0)

	la t0, polygon_count
	lw t0, 0(t0)
	sw t0, 28(sp)
	li t1, 0
	sw t1, 32(sp)
1:
	lw t0, 28(sp)
	lw t1, 32(sp)
	bge t1, t0, 2f
	addi t2, t1, 1
	sw t2, 32(sp)
	slli t1, t1, 4
	
	# Copy vertex
	la a2, vertex
	la s0, pos_index
	add s0, s0, t1
	la s1, pos
	la s2, uv_index
	add s2, s2, t1
	la s3, uv
	li t0, 0
	li t1, 4
3:
	bge t0, t1, 4f

	# Pos
	slli t2, t0, 2
	add t2, t2, s0
	lw t2, 0(t2)
	li t3, 12
	mul t2, t2, t3
	add t2, t2, s1

	# UV
	slli t3, t0, 2
	add t3, t3, s2
	lw t3, 0(t3)
	li t4, 8
	mul t3, t3, t4
	add t3, t3, s3

	# Vertex
	li t4, 20
	mul t4, t4, t0
	add t4, t4, a2

	# Must use lw in order to avoid misaligned load and store
	lw t6, 0(t2)
	sw t6, 0(t4)
	lw t6, 4(t2)
	sw t6, 4(t4)
	lw t6, 8(t2)
	sw t6, 8(t4)
	lw t6, 0(t3)
	sw t6, 12(t4)
	lw t6, 4(t3)
	sw t6, 16(t4)

	addi t0, t0, 1
	j 3b
4:

	# Transformation Matrix
	# Clear to Identity
	jal ra, cleanBaseMatrix
	# Transform
	jal ra, scaleModel
	jal ra, rotateModel

	# Load Index
	la t0, norm_index
	lw t1, 32(sp)
	addi t1, t1, -1
	slli t1, t1, 2
	add t0, t0, t1
	# Load Normal
	lw t1, 0(t0)
	li t0, 12
	mul t1, t1, t0
	la t0, norm
	add t1, t1, t0

	# Must use lw in order to avoid misaligned load and store
	la t2, normal_buffer
	lw t0, 0(t1)
	sw t0, 0(t2)
	lw t0, 4(t1)
	sw t0, 4(t2)
	lw t0, 8(t1)
	sw t0, 8(t2)
	sw x0, 12(t2)
	
	# Rotate Normal
	mv a0, t2
	jal ra, multiplyModel
	mv t1, a0

	# Light intensity
	la t0, light_pos
	# X
	flw ft0, 0(t0)
	flw ft1, 0(t1)
	fmul.s ft3, ft0, ft0
	fmul.s ft4, ft1, ft1
	fmul.s ft0, ft0, ft1
	# Y
	flw ft1, 4(t0)
	flw ft2, 4(t1)
	fmadd.s ft3, ft1, ft1, ft3
	fmadd.s ft4, ft2, ft2, ft4
	fmadd.s ft0, ft1, ft2, ft0
	# Z
	flw ft1, 8(t0)
	flw ft2, 8(t1)
	fmadd.s ft3, ft1, ft1, ft3
	fmadd.s ft4, ft2, ft2, ft4
	fmadd.s ft0, ft1, ft2, ft0
	# Divide by the normal and light module
	fsqrt.s ft3, ft3
	fsqrt.s ft4, ft4
	fdiv.s ft0, ft0, ft3
	fdiv.s ft0, ft0, ft4
	# Check limits
	la t0, light_min
	flw ft1, 0(t0)
	fmax.s ft0, ft0, ft1 # Minimum
	la t0, light_max
	flw ft1, 0(t0)
	fmin.s ft0, ft0, ft1 # Maximum
	# Store
	fsw ft0, 24(sp)

	# Continue Matrix Transform
	jal ra, translateModel

	# Project
	jal ra, projectModel

	# Render
	lwu a0, 16(sp)
	lwu a1, 20(sp)
	flw fa0, 24(sp)
	jal ra, renderSquare

	j 1b
2:

	ld ra, 8(sp)
	addi sp, sp, 40
	ret
#end

cleanBaseMatrix:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Clean Matrix to Identity
	li t0, 1
	fcvt.s.w ft0, t0

	la t0, base_matrix
	fsw ft0, 4*0(t0)
	sw x0, 4*1(t0)
	sw x0, 4*2(t0)
	sw x0, 4*3(t0)
	sw x0, 4*4(t0)
	fsw ft0, 4*5(t0)
	sw x0, 4*6(t0)
	sw x0, 4*7(t0)
	sw x0, 4*8(t0)
	sw x0, 4*9(t0)
	fsw ft0, 4*10(t0)
	sw x0, 4*11(t0)
	sw x0, 4*12(t0)
	sw x0, 4*13(t0)
	sw x0, 4*14(t0)
	fsw ft0, 4*15(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end