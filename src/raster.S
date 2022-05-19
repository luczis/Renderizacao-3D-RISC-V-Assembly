.section .data
.align 8

#texture_data:
#	.half 0xF81F, 0x7800, 0x780F, 0x001F, 0x07E0, 0xF800, 0xFFFF, 0xF81F, 0xFD20

.globl texture_size
texture_size:
	# Width, Height
	.half 4, 4

.section .text
.align 1

.include "inc/image.inc"

# Main Buffers
.comm depth_grid W_WIDTH*W_HEIGHT*2

# Work Buffers
.comm fbx_buffer W_WIDTH*W_HEIGHT*4
.comm fby_buffer W_WIDTH*W_HEIGHT*4
.comm depth_buffer W_WIDTH*W_HEIGHT*4

# Float constants
.equ QNaN, 0x7FC00000
.equ NInf, 0xFF800000

.globl drawSquare
# a0 - Frame Buffer
# a1 - Texture
# a2 - vertex0
# a3 - vertex1
# a4 - vertex2
# a5 - vertex4
# fa0 - Light Intensity
drawSquare:
	addi sp, sp, -128
	sd ra, 8(sp)
	sw a0, 12(sp)
	sw a1, 16(sp)
	sw a2, 20(sp)
	sw a3, 24(sp)
	sw a4, 28(sp)
	sw a5, 32(sp)
	fsw fa0, 100(sp)

	# Store Positions on Stack
	lwu t0, 20(sp)
	lwu t1, 24(sp)
	lwu t2, 28(sp)
	lwu t3, 32(sp)
	# X position
	li a2, W_WIDTH
	flw fa1, 0(t0)
	jal ra, floatToDimension
	sh a1, 36(sp)
	flw fa1, 0(t1)
	jal ra, floatToDimension
	sh a1, 52(sp)
	flw fa1, 0(t2)
	jal ra, floatToDimension
	sh a1, 68(sp)
	flw fa1, 0(t3)
	jal ra, floatToDimension
	sh a1, 84(sp)
	# Y position
	li a2, W_HEIGHT
	flw fa1, 4(t0)
	jal ra, floatToDimension
	sh a1, 38(sp)
	flw fa1, 4(t1)
	jal ra, floatToDimension
	sh a1, 54(sp)
	flw fa1, 4(t2)
	jal ra, floatToDimension
	sh a1, 70(sp)
	flw fa1, 4(t3)
	jal ra, floatToDimension
	sh a1, 86(sp)
	# Depth Value
	flw fa1, 8(t0)
	fsw fa1, 40(sp)
	flw fa1, 8(t1)
	fsw fa1, 56(sp)
	flw fa1, 8(t2)
	fsw fa1, 72(sp)
	flw fa1, 8(t3)
	fsw fa1, 88(sp)
	# UV X Value
	flw fa1, 12(t0)
	fsw fa1, 44(sp)
	flw fa1, 12(t1)
	fsw fa1, 60(sp)
	flw fa1, 12(t2)
	fsw fa1, 76(sp)
	flw fa1, 12(t3)
	fsw fa1, 92(sp)
	# UV Y Value
	flw fa1, 16(t0)
	fsw fa1, 48(sp)
	flw fa1, 16(t1)
	fsw fa1, 64(sp)
	flw fa1, 16(t2)
	fsw fa1, 80(sp)
	flw fa1, 16(t3)
	fsw fa1, 96(sp)

	# Verify if all points are hidden
	li t0, 2
	li t1, 1
	fcvt.s.w ft0, t0
	fcvt.s.w ft1, t1
	fdiv.s ft0, ft1, ft0 # 0.5f to avoid rounding
	# TODO: This number is not correct, correct should be 0x10000
	# But somehow the zfar plane will be too near
	li t0, 0x1
	slli t0, t0, 13
	fcvt.s.w ft2, t0 # for depth buffer

	li s0, 36
1:
	mv t0, s0
	add t0, t0, sp

	# x0, y0
	la a0, depth_grid
	lhu a1, 0(t0)
	lhu a2, 2(t0)
	flw fa0, 4(t0)
	fmul.s fa0, fa0, ft0
	fsub.s fa0, fa0, ft0
	fmul.s fa0, fa0, ft2
	fadd.s fa0, fa0, ft0 # Avoid rounding
	fneg.s fa0, fa0
	fcvt.w.s t0, fa0 # Depth to integer

	li t2, W_WIDTH
	mul t2, t2, a2
	add t2, t2, a1
	slli t2, t2, 2
	srli t1, t2, 1
	add t1, t1, a0
	lhu t1, 0(t1)

	li t2, 0xFFFF
	bge x0, t0, 4f # Cut if too far forward
	bge t0, t2, 4f # Cut if too far behind
	li t2, 0x1F
	sub t0, t0, t2
	bge t0, t1, 4f # Cut if too far behind another pixel

	j 3f # At least one vertice is visible
4:
	addi s0, s0, 16
	li t0, 88
	bge t0, s0, 1b
	j 2f # All vertices are hidden
3:

	# Get X max and min
	lhu a1, 36(sp)
	lhu a2, 52(sp)
	lhu a3, 68(sp)
	lhu a4, 84(sp)
	jal ra, minmaxi # Min Max x
	addi a2, a2, 1
	sh a1, 104(sp)
	sh a2, 106(sp)
	# Get Y max and min
	lhu a1, 38(sp)
	lhu a2, 54(sp)
	lhu a3, 70(sp)
	lhu a4, 86(sp)
	jal ra, minmaxi # Min Max y
	addi a2, a2, 1
	sh a1, 108(sp)
	sh a2, 110(sp)

	# Clear buffers
	la a0, depth_buffer
	la a1, fbx_buffer
	la a2, fby_buffer
	la a3, depth_grid
	lhu t0, 104(sp) # sx
	lhu t1, 106(sp) # bx
	lhu t3, 110(sp) # by
	li t4, NInf
	li s1, W_WIDTH
	lhu s2, 108(sp) # sy
	fmv.w.x ft0, t4
1:
	bgt t0, t1, 3f
	mv t2, s2
	mv t2, s2
4:
	bgt t2, t3, 5f

	mul t4, s1, t2
	add t4, t4, t0
	slli t4, t4, 2

	add t5, t4, a0
	fsw ft0, 0(t5)
	add t5, t4, a1
	fsw ft0, 0(t5)
	add t5, t4, a2
	fsw ft0, 0(t5)

	addi t2, t2, 1
	j 4b
5:
	addi t0, t0, 1
	j 1b
3:

	# Draw Lines
	# v0 & v1
	lhu a1, 36(sp)
	lhu a2, 52(sp)
	lhu a3, 38(sp)
	lhu a4, 54(sp)
	la a0, depth_buffer # Depth buffer
	flw fa0, 40(sp)
	flw fa1, 56(sp)
	jal ra, drawLine
	la a0, fbx_buffer # Texture UV X buffer
	flw fa0, 44(sp)
	flw fa1, 60(sp)
	jal ra, drawLine
	la a0, fby_buffer # Texture UV Y buffer
	flw fa0, 48(sp)
	flw fa1, 64(sp)
	jal ra, drawLine
	# v1 & v2
	lhu a1, 52(sp)
	lhu a2, 68(sp)
	lhu a3, 54(sp)
	lhu a4, 70(sp)
	la a0, depth_buffer # Depth buffer
	flw fa0, 56(sp)
	flw fa1, 72(sp)
	jal ra, drawLine
	la a0, fbx_buffer # Texture UV X buffer
	flw fa0, 60(sp)
	flw fa1, 76(sp)
	jal ra, drawLine
	la a0, fby_buffer # Texture UV Y buffer
	flw fa0, 64(sp)
	flw fa1, 80(sp)
	jal ra, drawLine
	# v2 & v3
	lhu a1, 68(sp)
	lhu a2, 84(sp)
	lhu a3, 70(sp)
	lhu a4, 86(sp)
	la a0, depth_buffer # Depth buffer
	flw fa0, 72(sp)
	flw fa1, 88(sp)
	jal ra, drawLine
	la a0, fbx_buffer # Texture UV X buffer
	flw fa0, 76(sp)
	flw fa1, 92(sp)
	jal ra, drawLine
	la a0, fby_buffer # Texture UV Y buffer
	flw fa0, 80(sp)
	flw fa1, 96(sp)
	jal ra, drawLine
	# v3 & v0
	lhu a1, 84(sp)
	lhu a2, 36(sp)
	lhu a3, 86(sp)
	lhu a4, 38(sp)
	la a0, depth_buffer # Depth buffer
	flw fa0, 88(sp)
	flw fa1, 40(sp)
	jal ra, drawLine
	la a0, fbx_buffer # Texture UV X buffer
	flw fa0, 92(sp)
	flw fa1, 44(sp)
	jal ra, drawLine
	la a0, fby_buffer # Texture UV Y buffer
	flw fa0, 96(sp)
	flw fa1, 48(sp)
	jal ra, drawLine

	# Fill Polygon
	#lhu a1, 38(sp)
	#lhu a2, 54(sp)
	#lhu a3, 70(sp)
	#lhu a4, 86(sp)
	#jal ra, minmaxi # Min Max y
	#mv s0, a1
	#mv s1, a2
	#lhu a1, 36(sp)
	#lhu a2, 52(sp)
	#lhu a3, 68(sp)
	#lhu a4, 84(sp)
	#jal ra, minmaxi # Min Max x
	#mv a3, s0
	#mv a4, s1
	#addi a2, a2, 1
	#addi a4, a4, 1

	lhu a1, 104(sp) # sx
	lhu a2, 106(sp) # bx
	lhu a3, 108(sp) # sy
	lhu a4, 110(sp) # by
	# Depth buffer
	la a0, depth_buffer
	jal ra, fillPolygon
	# Texture UV X buffer
	la a0, fbx_buffer
	jal ra, fillPolygon
	# Texture UV Y buffer
	la a0, fby_buffer
	jal ra, fillPolygon
	
	# Draw Polygon
	mv t0, a1 # x=sx
	mv t1, a2 # bx
	mv t3, a4 # by
	li s0, W_WIDTH
	la s1, texture_size
	lhu s1, 0(s1)
	li t4, NInf
	fmv.w.x fa0, t4
	la t4, texture_size
	lhu t4, 0(t4)
	fcvt.s.w fa1, t4
	la t4, texture_size
	lhu t4, 2(t4)
	fcvt.s.w fa2, t4
	li t4, 2
	li t5, 1
	fcvt.s.w fa3, t4
	fcvt.s.w fa4, t5
	fdiv.s fa3, fa4, fa3 # 0.5f to avoid rounding
	# TODO: This number is not correct, correct should be 0x10000
	# But somehow the zfar plane will be too near
	li t4, 0x1
	slli t4, t4, 13
	fcvt.s.w fa5, t4 # for depth buffer
	#li t4, 0x1F
	#fcvt.s.w ft7, t4
	lwu a0, 12(sp)
	lwu a1, 16(sp)
	la s2, fbx_buffer
	la s3, fby_buffer
	la s4, depth_buffer
	la s5, depth_grid
	# Light Intensity
	flw ft0, 100(sp)
	#li t4, 1         # DEBUG:
	#fcvt.s.w ft0, t4 # Light as 1.0
	li t4, 0x20
	fcvt.s.w ft1, t4
	fmul.s ft0, ft0, ft1
	fsub.s ft0, ft0, fa3 # Avoid rounding
	fcvt.w.s s7, ft0
	bge t4, s7, 6f
	mv s7, t4 # Clamp to max width
6:
	bge s7, x0, 1f
	mv s7, x0 # Clamp to zero
1:
	bge t0, t1, 2f
	mv t2, a3 # y=sy
3:
	bge t2, t3, 4f

	mul s6, s0, t2
	add s6, s6, t0
	slli s6, s6, 2

	add t4, s6, s2 # Fbx pos
	flw ft0, 0(t4)

	feq.s t4, fa0, ft0
	bne t4, x0, 5f # Only write used pixels

	# Check depth_grid
	add t4, s6, s4 # Depth pos
	flw ft1, 0(t4)
	fmul.s ft1, ft1, fa3
	fsub.s ft1, ft1, fa3
	fmul.s ft1, ft1, fa5
	fadd.s ft1, ft1, fa3 # Avoid rounding
	fneg.s ft1, ft1
	fcvt.w.s t4, ft1 # Depth to integer
	bge x0, t4, 5f # Cut if too far forward
	li t5, 0xFFFF
	bge t4, t5, 5f # Cut if too far behind
	srli t5, s6, 1
	add t5, t5, s5
	lhu t6, 0(t5)
	bge t4, t6, 5f # Cut if behind another pixel

	# Store highest depth
	sh t4, 0(t5)

	#srli t5, t4, 11 # DEBUG:
	#slli t4, t5, 6  #
	#slli t6, t5, 11 # Show Depth
	#or t5, t4, t5   #    as
	#or t5, t6, t5   #   Gray
	#add t4, s6, a0  #
	#sh t5, 0(t4)    #
	#j 5f            #

	#add t4, s6, a0  # DEBUG:
	#li t5, 0xFFFF   # Show
	#sh t5, 0(t4)    # White Only
	#j 5f            # 

	fmul.s ft0, fa1, ft0
	fsub.s ft0, ft0, fa3 # Avoid rounding
	fcvt.wu.s t4, ft0 # UV X to integer

	#srli t5, t4, 1  # DEBUG:
	#mv t5, t4       #
	#addi t5, t5, 2  #
	#slli t4, t5, 6  #
	#slli t6, t5, 11 # Show UV X
	#or t5, t4, t5   #    as
	#or t5, t6, t5   #   Gray
	#add t4, s6, a0  #
	#sh t5, 0(t4)    #
	#j 5f            #

	# Clamp Value
	la t5, texture_size
	lhu t5, 0(t5)
	addi t5, t5, -1
	bge t5, t4, 6f
	mv t4, t5 # Clamp to max width
6:
	bge t4, x0, 6f
	mv t4, x0 # Clamp to zero
6:

	add t5, s6, s3 # Fby pos
	flw ft0, 0(t5)
	fsub.s ft0, fa4, ft0
	fmul.s ft0, fa2, ft0
	fsub.s ft0, ft0, fa3 # Avoid rounding
	fcvt.wu.s t5, ft0 # UV Y to integer

	#srli t5, t5, 1  # DEBUG:
	#addi t5, t5, 2  #
	#slli t4, t5, 6  #
	#slli t6, t5, 11 # Show UV Y
	#or t5, t4, t5   #    as
	#or t5, t6, t5   #   Gray
	#add t4, s6, a0  #
	#sh t5, 0(t4)    #
	#j 5f            #

	# Clamp Value
	la t6, texture_size
	lhu t6, 2(t6)
	addi t6, t6, -1
	bge t6, t5, 6f
	mv t5, t6 # Clamp to max width
6:
	bge t5, x0, 6f
	mv t5, x0 # Clamp to zero
6:

	mul t5, t5, s1
	add t4, t4, t5
	slli t4, t4, 1
	add t4, t4, a1

	lhu t4, 0(t4) # Texture
	li t6, 0
	# Blue
	andi t5, t4, 0x001F
	mul t5, t5, s7
	srli t5, t5, 5
	andi t5, t5, 0x001F
	or t6, t6, t5
	# Green
	andi t5, t4, 0x07E0
	mul t5, t5, s7
	srli t5, t5, 5
	andi t5, t5, 0x07E0
	or t6, t6, t5
	# Red
	li t5, 0xF800
	and t5, t5, t4
	mul t5, t5, s7
	srli t5, t5, 5
	li t4, 0xF800
	and t5, t5, t4
	or t5, t6, t5

	add t4, s6, a0 # Frame Buffer Pos
	sh t5, 0(t4)
5:
	addi t2, t2, 1
	j 3b
4:
	addi t0, t0, 1
	j 1b
2:
	ld ra, 8(sp)
	addi sp, sp, 128
	ret
#end

# fa1 - Value
# a2 - Dimension
floatToDimension:
	addi sp, sp, -24
	sd ra, 8(sp)
	sd a2, 16(sp)

	# From float cordinates to screen values
	li t4, 1
	fcvt.s.w ft0, t4
	fcvt.s.w ft1, a2
	fadd.s fa1, fa1, ft0
	fmul.s fa1, fa1, ft1
	fcvt.w.s a1, fa1

	# Clamp Dimensions
	mv a3, a2
	li a2, 0
	slli a3, a3, 1
	addi a3, a3, -1
	jal ra, clampi
	srli a1, a1, 1

	ld a2, 16(sp)
	ld ra, 8(sp)
	addi sp, sp, 24
	ret
#end

# a1 - Value
# a2 - Min
# a3 - Max
clampi:
	addi sp, sp, -16
	sd ra, 8(sp)

	bge a1, a2, 1f
	mv a1, a2
1:
	bge a3, a1, 2f
	mv a1, a3
2:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

# a1 - v0
# a2 - v1
# a3 - v2
# a4 - v3
minmaxi:
	addi sp, sp, -16
	sd ra, 8(sp)

	mv t0, a1
	mv t1, a1

# Min
	bge a2, t0, 1f
	mv t0, a2
1:
	bge a3, t0, 1f
	mv t0, a3
1:
	bge a4, t0, 1f
	mv t0, a4
1:

# Max
	bge t1, a2, 1f
	mv t1, a2
1:
	bge t1, a3, 1f
	mv t1, a3
1:
	bge t1, a4, 1f
	mv t1, a4
1:

	mv a1, t0
	mv a2, t1

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl clearScreen
# a0 - Frame Buffer
# a1 - Color
clearScreen:
	addi sp, sp, -16
	sd ra, 8(sp)

	li t0, 0
	li t1, W_WIDTH
	li t3, W_HEIGHT
	la t4, depth_grid
1:
	bge t0, t1, 2f
	li t2, 0
3:
	bge t2, t3, 4f

	mul t5, t1, t2
	add t5, t5, t0

	slli t6, t5, 2
	add t6, t6, a0
	sh a1, 0(t6)

	slli t6, t5, 1
	add t6, t6, t4
	li t5, 0xFFFF
	sh t5, 0(t6)

	addi t2, t2, 1
	j 3b
4:
	addi t0, t0, 1
	j 1b
2:

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl fillPolygon
# a0 - Frame Buffer
# a1 - X Min Border
# a2 - X Max Border
# a3 - Y Min Border
# a4 - Y Max Border
fillPolygon:
	addi sp, sp, -16
	sd ra, 8(sp)

	li t0, W_WIDTH # f_y
	mv t1, a1

	li t2, NInf
	fmv.w.x fa0, t2
1:
	beq t1, a2, 2f

	li t3, -1 # i_y
	li t4, -1 # f_y

	mv t2, a3
3:
	blt a4, t2, 4f

	mul t5, t2, t0
	add t5, t5, t1
	slli t5, t5, 2
	add t5, t5, a0

	flw ft0, 0(t5)
	feq.s t5, fa0, ft0
	bne t5, x0, 5f # Only write used pixels

	bne t3, t4, 6f
7:
	mv t3, t2 # i_y = y
	j 5f
6:
	mv t5, t2
	addi t5, t5, -1
	beq t3, t5, 7b

	mv t4, t2 # f_y = y
	j 4f
5:
	addi t2, t2, 1
	j 3b
4:

	beq t3, t4, 4f
	
	mul t5, t3, t0
	add t5, t5, t1
	slli t5, t5, 2
	add t5, t5, a0
	flw ft0, 0(t5) # current_val

	mul t5, t4, t0
	add t5, t5, t1
	slli t5, t5, 2
	add t5, t5, a0
	flw ft1, 0(t5)
	sub t5, t4, t3
	fcvt.s.w ft2, t5
	fsub.s ft1, ft1, ft0
	fdiv.s ft1, ft1, ft2 # delta_val

	addi t3, t3, 1
3:
	bge t3, t4, 4f

	mul t5, t3, t0
	add t5, t5, t1
	slli t5, t5, 2
	add t5, t5, a0

	fadd.s ft0, ft0, ft1
	fsw ft0, 0(t5)
	
	addi t3, t3, 1
	j 3b
4:
	addi t1, t1, 1
	j 1b
2:

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl drawLine
# a0 - Frame Buffer
# a1 - x0
# a2 - x1
# a3 - y0
# a4 - y1
# fa0 - val0
# fa1 - val1
drawLine:
	addi sp, sp, -16
	sd ra, 8(sp)

	mv s0, a1
	mv s1, a2
	mv s2, a3
	mv s3, a4
	fmv.s fs0, fa0
	fmv.s fs1, fa1

	sub t0, s1, s0 # dx = x1-x0
	sub t1, s3, s2 # dy = y1-y0
	
	# Special Cases
	# Straight Vertical Line
	bne t0, x0, 1f
	# y0 must be smaller than y1
	bge s3, s2, 2f
	mv t0, s2
	mv s2, s3
	mv s3, t0
	fmv.s ft0, fs0
	fmv.s fs0, fs1
	fmv.s fs1, ft0
	sub t1, x0, t1
2:
	fcvt.s.w ft1, t1     # dy
	fsub.s ft2, fs1, fs0 # val1-val0
	fdiv.s ft1, ft2, ft1 # delta_val

	fmv.s ft0, fs0
	mv t0, s2
	mv t1, s0
	li t2, W_WIDTH

2:
	blt s3, t0, 3f
	fadd.s ft0, ft0, ft1 # current_val

	mul t3, t0, t2
	add t3, t3, t1 # x+WIN_WIDTH*y

	slli t3, t3, 2
	add t3, t3, a0
	fsw ft0, 0(t3)

	addi t0, t0, 1
	j 2b
3:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
1:
	# Straight Horizontal Line
	bne t1, x0, 1f
	# x0 must be smaller than x1
	bge s1, s0, 2f
	mv t1, s0
	mv s0, s1
	mv s1, t1
	fmv.s ft0, fs0
	fmv.s fs0, fs1
	fmv.s fs1, ft0
	sub t0, x0, t0
2:
	fcvt.s.w ft1, t0     # dx
	fsub.s ft2, fs1, fs0 # val1-val0
	fdiv.s ft1, ft2, ft1 # delta_val

	fmv.s ft0, fs0
	mv t0, s0
	mv t1, s2
	li t2, W_WIDTH

2:
	blt s1, t0, 3f
	fadd.s ft0, ft0, ft1 # current_val

	mul t3, t1, t2
	add t3, t3, t0 # x+WIN_WIDTH*y

	slli t3, t3, 2
	add t3, t3, a0
	fsw ft0, 0(t3)

	addi t0, t0, 1
	j 2b
3:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
1:

	fcvt.s.w ft0, t0
	fcvt.s.w ft1, t1
	fdiv.s ft0, ft1, ft0
	fabs.s ft0, ft0 # der

	li t2, 1
	fcvt.s.w ft1, t2
	fle.s t2, ft0, ft1
	# Line if dy is smaller than dx
	beq t2, x0, 1f
	# x0 must be smaller than x1
	bge s1, s0, 2f
	mv t2, s0
	mv s0, s1
	mv s1, t2
	mv t2, s2
	mv s2, s3
	mv s3, t2
	fmv.s ft1, fs0
	fmv.s fs0, fs1
	fmv.s fs1, ft1
	sub t0, x0, t0
	sub t1, x0, t1
2:
	li t3, 1 # sign
	bge t1, x0, 2f
	li t3, -1
2:
	fcvt.s.w ft1, t0     # dx
	fsub.s ft2, fs1, fs0 # val1-val0
	fdiv.s ft1, ft2, ft1 # delta_val

	fmv.w.x ft2, x0
	fmv.s ft3, fs0
	li t0, 1
	li t1, 2
	fcvt.s.w ft4, t0 # 1.0
	fcvt.s.w ft5, t1
	fdiv.s ft5, ft4, ft5 # 0.5
	mv t0, s0
	mv t1, s2
	li t2, W_WIDTH

	#li t6, 0x1F
	#fcvt.s.w ft7, t6
2:
	blt s1, t0, 3f
	fadd.s ft2, ft2, ft0 # er
	fadd.s ft3, ft3, ft1 # current_val

	mul t4, t1, t2
	add t4, t4, t0 # x+WIN_WIDTH*y

	#fmul.s ft6, ft7, ft3
	#fcvt.wu.s t5, ft6

	slli t4, t4, 2
	add t4, t4, a0
	fsw ft3, 0(t4)

	addi t0, t0, 1
	fle.s t5, ft5, ft2
	beq t5, x0, 4f
	add t1, t1, t3
	fsub.s ft2, ft2, ft4
4:
	j 2b
3:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret

	# Line if dx is smaller than dy
1:
	# y0 must be smaller than y1
	bge s3, s2, 2f
	mv t2, s0
	mv s0, s1
	mv s1, t2
	mv t2, s2
	mv s2, s3
	mv s3, t2
	fmv.s ft1, fs0
	fmv.s fs0, fs1
	fmv.s fs1, ft1
	sub t0, x0, t0
	sub t1, x0, t1
2:
	li t3, 1 # sign
	bge t0, x0, 2f
	li t3, -1
2:
	fcvt.s.w ft1, t1     # dy
	fsub.s ft2, fs1, fs0 # val1-val0
	fdiv.s ft1, ft2, ft1 # delta_val

	fmv.w.x ft2, x0
	fmv.s ft3, fs0
	li t0, 1
	li t1, 2
	fcvt.s.w ft4, t0 # 1.0
	fcvt.s.w ft5, t1
	fdiv.s ft5, ft4, ft5 # 0.5
	fdiv.s ft0, ft4, ft0
	mv t0, s2
	mv t1, s0
	li t2, W_WIDTH

	#li t6, 0x1F
	#fcvt.s.w ft7, t6
2:
	blt s3, t0, 3f
	fadd.s ft2, ft2, ft0 # er
	fadd.s ft3, ft3, ft1 # current_val

	mul t4, t0, t2
	add t4, t4, t1 # x+WIN_WIDTH*y

	#fmul.s ft6, ft7, ft3
	#fcvt.wu.s t5, ft6

	slli t4, t4, 2
	add t4, t4, a0
	fsw ft3, 0(t4)

	addi t0, t0, 1
	fle.s t5, ft5, ft2
	beq t5, x0, 4f
	add t1, t1, t3
	fsub.s ft2, ft2, ft4
4:
	j 2b
3:

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end
