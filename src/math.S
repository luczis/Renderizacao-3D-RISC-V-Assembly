.section .text
.align 4

.globl multiplyModel
# a0 - vertex
multiplyModel:
	addi sp, sp, -16
	sd ra, 8(sp)

	la t0, base_matrix

	flw fs0, 0(a0)
	flw fs1, 4(a0)
	flw fs2, 8(a0)

	# W
	flw ft0, 48(t0)
	flw ft1, 52(t0)
	flw ft2, 56(t0)
	flw ft3, 60(t0)
	fmul.s ft0, ft0, fs0
	fmadd.s ft0, ft1, fs1, ft0
	fmadd.s ft0, ft2, fs2, ft0
	fadd.s fs3, ft0, ft3

	# X
	flw ft0, 0(t0)
	flw ft1, 4(t0)
	flw ft2, 8(t0)
	flw ft3, 12(t0)
	fmul.s ft0, ft0, fs0
	fmadd.s ft0, ft1, fs1, ft0
	fmadd.s ft0, ft2, fs2, ft0
	fmadd.s ft0, ft3, fs3, ft0
	fdiv.s ft0, ft0, fs3
	fsw ft0, 0(a0)

	# Y
	flw ft0, 16(t0)
	flw ft1, 20(t0)
	flw ft2, 24(t0)
	flw ft3, 28(t0)
	fmul.s ft0, ft0, fs0
	fmadd.s ft0, ft1, fs1, ft0
	fmadd.s ft0, ft2, fs2, ft0
	fmadd.s ft0, ft3, fs3, ft0
	fdiv.s ft0, ft0, fs3
	fsw ft0, 4(a0)

	# Z
	flw ft0, 32(t0)
	flw ft1, 36(t0)
	flw ft2, 40(t0)
	flw ft3, 44(t0)
	fmul.s ft0, ft0, fs0
	fmadd.s ft0, ft1, fs1, ft0
	fmadd.s ft0, ft2, fs2, ft0
	fmadd.s ft0, ft3, fs3, ft0
	fdiv.s ft0, ft0, fs3
	#fneg.s ft0, ft0
	fsw ft0, 8(a0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl scaleModel
scaleModel:
	addi sp, sp, -16
	sd ra, 8(sp)

	la t0, base_matrix
	la t1, scale_vector

	# X
	flw ft0, 0(t1)
	flw ft1, 0(t0)
	fmul.s ft0, ft0, ft1
	fsw ft0, 0(t0)
	# Y
	flw ft0, 4(t1)
	flw ft1, 4*5(t0)
	fmul.s ft0, ft0, ft1
	fsw ft0, 4*5(t0)
	# Z
	flw ft0, 8(t1)
	flw ft1, 4*10(t0)
	fmul.s ft0, ft0, ft1
	fsw ft0, 4*10(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl rotateModel
rotateModel:
	addi sp, sp, -16
	sd ra, 8(sp)

	la t0, rotate_angle
	flw fa0, 0(t0)
	jal ra, cosSin

	la t0, base_matrix
	la t1, rotate_axis

	# Quaternion
	fmv.s fs0, fa0
	flw fs1, 0(t1)
	fmul.s fs1, fs1, fa1
	flw fs2, 4(t1)
	fmul.s fs2, fs2, fa1
	flw fs3, 8(t1)
	fmul.s fs3, fs3, fa1

	# Rotation Matrix
	fmul.s fs4, fs1, fs1 #qx2
	fmul.s fs5, fs2, fs2 #qy2
	fmul.s fs6, fs3, fs3 #qz2
	fmul.s fs7, fs1, fs2 #qx.qy
	fmul.s fs8, fs1, fs3 #qx.qz
	fmul.s fs9, fs1, fs0 #qx.qs
	fmul.s fs10, fs2, fs3 #qy.qz
	fmul.s fs11, fs2, fs0 #qy.qs
	fmul.s ft9, fs3, fs0 #qz.qs
	li t1, 1
	fcvt.s.w ft10, t1
	li t1, 2
	fcvt.s.w ft11, t1
	fadd.s ft0, fs5, fs6
	fmul.s ft0, ft0, ft11
	fsub.s ft0, ft10, ft0 # r00
	fsub.s ft1, fs7, ft9
	fmul.s ft1, ft1, ft11 # r01
	fadd.s ft2, fs8, fs11
	fmul.s ft2, ft2, ft11 # r02
	fadd.s ft3, fs7, ft9
	fmul.s ft3, ft3, ft11 # r10
	fadd.s ft4, fs4 , fs6
	fmul.s ft4, ft4, ft11
	fsub.s ft4, ft10, ft4 # r11
	fsub.s ft5, fs10, fs9
	fmul.s ft5, ft5, ft11 # r12
	fsub.s ft6, fs8, fs11
	fmul.s ft6, ft6, ft11 # r20
	fadd.s ft7, fs10, fs9
	fmul.s ft7, ft7, ft11 # r21
	fadd.s ft8, fs4 , fs5
	fmul.s ft8, ft8, ft11
	fsub.s ft8, ft10, ft8 # r22

	# Base Matrix
	flw fs0, 0(t0)   # b00
	flw fs1, 4(t0)   # b01
	flw fs2, 8(t0)   # b02
	flw fs3, 12(t0)  # b03
	flw fs4, 16(t0)  # b10
	flw fs5, 20(t0)  # b11
	flw fs6, 24(t0)  # b12
	flw fs7, 28(t0)  # b13
	flw fs8, 32(t0)  # b20
	flw fs9, 36(t0)  # b21
	flw fs10, 40(t0) # b22
	flw fs11, 44(t0) # b23

	# Multiplication
	fmul.s fa5, ft0, fs0
	fmadd.s fa5, ft1, fs4, fa5
	fmadd.s fa5, ft2, fs8, fa5
	fsw fa5, 0(t0) # c00
	fmul.s fa5, ft0, fs1
	fmadd.s fa5, ft1, fs5, fa5
	fmadd.s fa5, ft2, fs9, fa5
	fsw fa5, 4(t0) # c01
	fmul.s fa5, ft0, fs2
	fmadd.s fa5, ft1, fs6, fa5
	fmadd.s fa5, ft2, fs10, fa5
	fsw fa5, 8(t0) # c02
	fmul.s fa5, ft0, fs3
	fmadd.s fa5, ft1, fs7, fa5
	fmadd.s fa5, ft2, fs11, fa5
	fsw fa5, 12(t0) # c03
	fmul.s fa5, ft3, fs0
	fmadd.s fa5, ft4, fs4, fa5
	fmadd.s fa5, ft5, fs8, fa5
	fsw fa5, 16(t0) # c10
	fmul.s fa5, ft3, fs1
	fmadd.s fa5, ft4, fs5, fa5
	fmadd.s fa5, ft5, fs9, fa5
	fsw fa5, 20(t0) # c11
	fmul.s fa5, ft3, fs2
	fmadd.s fa5, ft4, fs6, fa5
	fmadd.s fa5, ft5, fs10, fa5
	fsw fa5, 24(t0) # c12
	fmul.s fa5, ft3, fs3
	fmadd.s fa5, ft4, fs7, fa5
	fmadd.s fa5, ft5, fs11, fa5
	fsw fa5, 28(t0) # c13
	fmul.s fa5, ft6, fs0
	fmadd.s fa5, ft7, fs4, fa5
	fmadd.s fa5, ft8, fs8, fa5
	fsw fa5, 32(t0) # c20
	fmul.s fa5, ft6, fs1
	fmadd.s fa5, ft7, fs5, fa5
	fmadd.s fa5, ft8, fs9, fa5
	fsw fa5, 36(t0) # c21
	fmul.s fa5, ft6, fs2
	fmadd.s fa5, ft7, fs6, fa5
	fmadd.s fa5, ft8, fs10, fa5
	fsw fa5, 40(t0) # c22
	fmul.s fa5, ft6, fs3
	fmadd.s fa5, ft7, fs7, fa5
	fmadd.s fa5, ft8, fs11, fa5
	fsw fa5, 44(t0) # c23

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl translateModel
translateModel:
	addi sp, sp, -16
	sd ra, 8(sp)

	la t0, base_matrix
	la t1, translate_vector

	# X
	flw ft0, 0(t1)
	flw ft1, 4*3(t0)
	fadd.s ft0, ft0, ft1
	fsw ft0, 4*3(t0)
	# Y
	flw ft0, 4(t1)
	flw ft1, 4*7(t0)
	fadd.s ft0, ft0, ft1
	fsw ft0, 4*7(t0)
	# Z
	flw ft0, 8(t1)
	flw ft1, 4*11(t0)
	fadd.s ft0, ft0, ft1
	fsw ft0, 4*11(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl cosSin
# fa0 - Angle [deg]
cosSin:
	addi sp, sp, -16
	sd ra, 8(sp)

	fcvt.wu.s t0, fa0

	srli t0, t0, 2
	li t2, 180
	remu t1, t0, t2

	la t2, cos_table
	slli t1, t1, 2
	add t1, t1, t2
	flw fa0, 0(t1) # cos

	addi t0, t0, 135
	li t1, 180
	remu t0, t0, t1

	slli t0, t0, 2
	add t0, t0, t2
	flw fa1, 0(t0) # sin

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end


.globl projectModel
projectModel:
	addi sp, sp, -16
	sd ra, 8(sp)

	la t0, fov_const
	la t1, aspect_ratio
	la t2, zconst

	flw fa1, 0(t0)
	flw ft0, 0(t1)
	fmul.s fa0, fa1, ft0
	flw fa2, 0(t2)
	flw fa3, 4(t2)

	la t0, base_matrix

	flw ft0, 4*0(t0)
	fmul.s ft0, ft0, fa0
	fsw ft0, 4*0(t0) # a00
	flw ft0, 4*1(t0)
	fmul.s ft0, ft0, fa0
	fsw ft0, 4*1(t0) # a01
	flw ft0, 4*2(t0)
	fmul.s ft0, ft0, fa0
	fsw ft0, 4*2(t0) # a02
	flw ft0, 4*3(t0)
	fmul.s ft0, ft0, fa0
	fsw ft0, 4*3(t0) # a03

	flw ft0, 4*4(t0)
	fmul.s ft0, ft0, fa1
	fsw ft0, 4*4(t0) # a10
	flw ft0, 4*5(t0)
	fmul.s ft0, ft0, fa1
	fsw ft0, 4*5(t0) # a11
	flw ft0, 4*6(t0)
	fmul.s ft0, ft0, fa1
	fsw ft0, 4*6(t0) # a12
	flw ft0, 4*7(t0)
	fmul.s ft0, ft0, fa1
	fsw ft0, 4*7(t0) # a13

	flw ft0, 4*8(t0)
	flw ft1, 4*12(t0)
	fneg.s ft2, ft0
	fsw ft2, 4*12(t0) # a30
	fmul.s ft0, ft0, fa2
	fmadd.s ft0, ft1, fa3, ft0
	fsw ft0, 4*8(t0) # a20

	flw ft0, 4*9(t0)
	flw ft1, 4*13(t0)
	fneg.s ft2, ft0
	fsw ft2, 4*13(t0) # a31
	fmul.s ft0, ft0, fa2
	fmadd.s ft0, ft1, fa3, ft0
	fsw ft0, 4*9(t0) # a21

	flw ft0, 4*10(t0)
	flw ft1, 4*14(t0)
	fneg.s ft2, ft0
	fsw ft2, 4*14(t0) # a32
	fmul.s ft0, ft0, fa2
	fmadd.s ft0, ft1, fa3, ft0
	fsw ft0, 4*10(t0) # a22

	flw ft0, 4*11(t0)
	flw ft1, 4*15(t0)
	fneg.s ft2, ft0
	fsw ft2, 4*15(t0) # a33
	fmul.s ft0, ft0, fa2
	fmadd.s ft0, ft1, fa3, ft0
	fsw ft0, 4*11(t0) # a23

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.section .data
.align 4

scale_vector:
	.float 0.35, 0.35, 0.35

.globl rotate_angle
rotate_angle:
	.float 45.0

.globl rotate_axis
rotate_axis:
	.float 0.0, 1.0, 0.0
	#.float 0.7071068, 0.7071068, 0.0
	#.float 0.9961947, 0.0616284, 0.0616284

.globl translate_vector
translate_vector:
	.float 0.0, -0.1, -3.5

fov_const: 
	# 1/tan(FOV/2)
	.float 2.0

aspect_ratio:
	# height/width
	.float 0.75

zconst:
	# znear = -1; zfar = -5
	# (znear+zfar)/(znear-zfar)
	.float 1.5
	# 2*znear*zfar/(znear-zfar)
	.float -2.5

.section .rodata
.align 4

.globl cos_table
cos_table:
	.float 1.000000, 0.999391, 0.997564, 0.994522, 0.990268, 0.984808, 0.978148, 0.970296, 0.961262, 0.951057
	.float 0.939693, 0.927184, 0.913545, 0.898794, 0.882948, 0.866025, 0.848048, 0.829038, 0.809017, 0.788011
	.float 0.766044, 0.743145, 0.719340, 0.694658, 0.669131, 0.642788, 0.615662, 0.587785, 0.559193, 0.529919
	.float 0.500000, 0.469472, 0.438371, 0.406737, 0.374607, 0.342020, 0.309017, 0.275637, 0.241922, 0.207912
	.float 0.173648, 0.139173, 0.104528, 0.069757, 0.034899, -0.000000, -0.034899, -0.069756, -0.104529, -0.139173
	.float -0.173648, -0.207912, -0.241922, -0.275637, -0.309017, -0.342020, -0.374607, -0.406737, -0.438371, -0.469472
	.float -0.500000, -0.529919, -0.559193, -0.587785, -0.615661, -0.642788, -0.669131, -0.694658, -0.719340, -0.743145
	.float -0.766044, -0.788011, -0.809017, -0.829038, -0.848048, -0.866025, -0.882948, -0.898794, -0.913545, -0.927184
	.float -0.939693, -0.951056, -0.961262, -0.970296, -0.978148, -0.984808, -0.990268, -0.994522, -0.997564, -0.999391
	.float -1.000000, -0.999391, -0.997564, -0.994522, -0.990268, -0.984808, -0.978148, -0.970296, -0.961262, -0.951057
	.float -0.939693, -0.927184, -0.913545, -0.898794, -0.882948, -0.866025, -0.848048, -0.829038, -0.809017, -0.788011
	.float -0.766044, -0.743145, -0.719340, -0.694658, -0.669131, -0.642788, -0.615662, -0.587785, -0.559193, -0.529919
	.float -0.500000, -0.469472, -0.438371, -0.406737, -0.374607, -0.342020, -0.309017, -0.275637, -0.241922, -0.207912
	.float -0.173648, -0.139173, -0.104528, -0.069757, -0.034899, 0.000000, 0.034899, 0.069757, 0.104528, 0.139173
	.float 0.173648, 0.207911, 0.241922, 0.275637, 0.309017, 0.342020, 0.374607, 0.406737, 0.438371, 0.469472
	.float 0.500000, 0.529919, 0.559193, 0.587785, 0.615662, 0.642788, 0.669131, 0.694658, 0.719340, 0.743145
	.float 0.766044, 0.788011, 0.809017, 0.829038, 0.848048, 0.866025, 0.882948, 0.898794, 0.913546, 0.927184
	.float 0.939693, 0.951057, 0.961262, 0.970296, 0.978148, 0.984808, 0.990268, 0.994522, 0.997564, 0.999391
