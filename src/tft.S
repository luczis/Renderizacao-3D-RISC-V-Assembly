.section .text
.align 2

.include "inc/mmap.inc"
.include "inc/tft.inc"
.include "inc/spi.inc"
.include "inc/sysctl.inc"
.include "inc/dma.inc"
.include "inc/pinmap.inc"
.include "inc/gpio.inc"
.include "inc/image.inc"

.globl tftInitialize
tftInitialize:
    addi sp, sp, -16
    sd ra, 8(sp)

	# Setup TFT
	jal ra, tftSetup

	# Software Reset
	la a0, tft_cmd
	li t0, SOFTWARE_RESET
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA

	# Sleep Off
	la a0, tft_cmd
	li t0, SLEEP_OFF
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA

	# Set Pixel Format
	la a0, tft_cmd
	li t0, PIXEL_FORMAT_SET
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA
	la a0, tft_cmd
	li t0, PIXEL_565_16BIT
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 1
	jal ra, tftWriteDMA

	# Set Display Direction
	la a0, tft_cmd
	li t0, MEMORY_ACCESS_CTL
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA
	la a0, tft_cmd
	li t0, DIR_YX_LR_DU
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 1
	jal ra, tftWriteDMA

	# Turn Display On
	la a0, tft_cmd
	li t0, DISPLAY_ON
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA

	# Set Display Size
	# Width
	li t0, W_WIDTH
	c.addi t0, -1
	srli t1, t0, 8
	andi t1, t1, 0xFF
	andi t2, t0, 0xFF
	la t0, tft_display_size
	sw t1, 0x8(t0)
	sw t2, 0xC(t0)
	# Height
	li t0, W_HEIGHT
	c.addi t0, -1
	srli t1, t0, 8
	andi t1, t1, 0xFF
	andi t2, t0, 0xFF
	la t0, tft_display_size
	sw t1, 0x18(t0)
	sw t2, 0x1C(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl tftRefreshDisplay
# a0 - Frame Buffer Address
tftRefreshDisplay:
	addi sp, sp, -24
	sd a0, 16(sp)
	sd ra, 8(sp)

	# Set Display Writable Area
	# Width
	la a0, tft_cmd
	li t0, HORIZONTAL_ADDRESS_SET
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA
	la a0, tft_display_size
	li a1, 4
	li a2, 8
	li a3, 1
	jal ra, tftWriteDMA
	# Height
	la a0, tft_cmd
	li t0, VERTICAL_ADDRESS_SET
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA
	la a0, tft_display_size
	c.addi a0, 0x10
	li a1, 4
	li a2, 8
	li a3, 1
	jal ra, tftWriteDMA

	# Write Data to Display Frame Buffer
	la a0, tft_cmd
	li t0, MEMORY_WRITE
	sw t0, 0(a0)
	li a1, 1
	li a2, 8
	li a3, 0
	jal ra, tftWriteDMA

	# Send Frame Buffer Data
	ld a0, 16(sp)
	li a1, W_WIDTH
	li t1, W_HEIGHT
	mul a1, a1, t1
	li a2, 16
	li a3, 1
	jal ra, tftWriteDMA

	ld ra, 8(sp)
	addi sp, sp, 24
	ret
#end

tftSetup:
    addi sp, sp, -16
    sd ra, 8(sp)

	# Attach Video to Memory
	li t0, SYSCTL_BASE_ADDR
	lw t1, SYSCTL_MISC_CTL(t0)
	li t2, 0x400
	not t3, t2
	and t1, t1, t3
	or t1, t1, t2
	sw t1, SYSCTL_MISC_CTL(t0)

	# Setup SPI0 Chip Select Pin
	li a0, PIN_TFT_CS
	li a1, PIN_TFT_CS_CONFIG
	jal ra, setupFPIOA

	# Setup SPI0 Clock Pin
	li a0, PIN_TFT_CLK
	li a1, PIN_TFT_CLK_CONFIG
	jal ra, setupFPIOA

	# Setup Data/Command Pin
	li a0, PIN_TFT_DC
	li a1, PIN_TFT_DC_CONFIG
	jal ra, setupFPIOA
	li a0, GPIOHS_TFT_DC
	li a1, GPIO_OUTPUT
	jal ra, setupGPIOHS

	# Setup Reset Pin
	li a0, PIN_TFT_RST
	li a1, PIN_TFT_RST_CONFIG
	jal ra, setupFPIOA
	li a0, GPIOHS_TFT_RST
	li a1, GPIO_OUTPUT
	jal ra, setupGPIOHS

	# Reset Display
	li a0, 1
	slli a0, a0, GPIOHS_TFT_RST
	mv a1, a0
	jal ra, outputGPIOHS
	mv a1, x0
	jal ra, outputGPIOHS

	# Configure SPI
	li t0, SPI0_BASE_ADDR
	sw x0, SPI_ENABLE_OFF(t0)
	sw x0, SPI_SLAVE_EN_OFF(t0)
	sw x0, SPI_INTR_MASK_OFF(t0)
	sw x0, SPI_DMA_CTL_OFF(t0)
	sw x0, SPI_DMA_TDL_OFF(t0)
	sw x0, SPI_DMA_RDL_OFF(t0)
	sw x0, SPI_ENDIAN_OFF(t0)
	sw x0, SPI_SCTL0_OFF(t0)
	li t1, SYSCTL_SPI0_FDIV
	sw t1, SPI_BAUD_RATE_OFF(t0)
	li t1, SPI_WORK_MODE
	slli t1, t1, 6
	li t2, SPI_TRANS_M
	slli t2, t2, 8
	or t1, t1, t2
	li t2, SPI0_FRM_FMT
	slli t2, t2, 21
	or t1, t1, t2
	sw t1, SPI_CTL0_OFF(t0)

	# Turn on Display
	li a0, 1
	slli a0, a0, GPIOHS_TFT_RST
	mv a1, a0
	jal ra, outputGPIOHS

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
#end

# a0 - Data Address 
# a1 - Data Length
# a2 - Data Bit Length
# a3 - Data/Command Set
tftWriteDMA:
    addi sp, sp, -16
    sd ra, 8(sp)

	# Set DC GPIO Pin
	addi sp, sp, -32
	sd a0, 8(sp)
	sd a1, 16(sp)
	sd a2, 24(sp)
	li t0, 1
	slli a0, t0, GPIOHS_TFT_DC
	mv t0, a3
	slli a1, t0, GPIOHS_TFT_DC
	jal ra, outputGPIOHS
	ld a2, 24(sp)
	ld a1, 16(sp)
	ld a0, 8(sp)
    addi sp, sp, 32

	# SPI Setup
	li t0, SPI0_BASE_ADDR
	li t1, 0x3 # FF Octal
	slli t1, t1, 21
	mv t2, a2 # Data Bit length
	addi t2, t2, -1
	slli t2, t2, 16
	or t1, t1, t2
	li t2, SPI_TRANS_M # Transmission Mode
	slli t2, t2, 8
	or t1, t1, t2
	sw t1, SPI_CTL0_OFF(t0)
	# Configure SPI Controller
	li t1, 8
	beq a2, t1, 1f
	li t1, 16
	beq a2, t1, 2f
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
1:
	li t1, 2
	j 3f
2:
	li t1, 3
3:
	slli t1, t1, 8
	ori t1, t1, SPI0_IATM
	sw t1, SPI_SCTL0_OFF(t0)
	# Enable DMA on SPI
	li t1, 0x2
	sw t1, SPI_DMA_CTL_OFF(t0)
	# Enable SPI
	li t1, 0x1
	sw t1, SPI_ENABLE_OFF(t0)

	# Select DMA Channel Mode
	li t0, SYSCTL_BASE_ADDR
	lw t1, SYSCTL_DMA_SEL(t0)
	li t2, 0x3F
	li t3, 6
	li t4, TFT_DMA_CH
	mul t3, t3, t4
	sll t2, t2, t3
	not t2, t2
	and t1, t1, t2
	li t2, TFT_DMA_SPI0_TX
	sll t2, t2, t3
	or t1, t1, t2
	sw t1, SYSCTL_DMA_SEL(t0)

	# Get DMA Base Addresses
	li t0, DMA_BASE_ADDR
	li t1, TFT_DMA_CH
	li t2, DMA_CH_BASE_OFF
	mul t1, t1, t2
	add t1, t1, t0

	# Clear interrupt
	li t2, 0xFFFFFFFF
	sd t2, DMA_CH_INT_OFF(t1)

	# Disable DMA Channel
	ld t2, DMA_CH_EN_OFF(t0)
	li t3, 1
	slli t3, t3, TFT_DMA_CH
	not t4, t3
	and t2, t2, t4
	slli t3, t3, 8
	or t2, t2, t3
	sd t2, DMA_CH_EN_OFF(t0)

	# Wait while DMA is idle
	li t2, 1
	slli t2, t2, TFT_DMA_CH
1:
	ld t3, DMA_CH_EN_OFF(t0)
	and t3, t3, t2
	bne t3, x0, 1b

	# Set Channel Parameters
	li t3, 0xF79F0000000F
	not t3, t3
	and t2, t2, t3
	li t3, 0x9
	slli t3, t3, 32
	or t2, t2, t3
	li t3, TFT_DMA_CH
	slli t4, t3, 39
	or t2, t2, t4
	slli t3, t3, 44
	or t2, t2, t3
	sd t2, DMA_CH_CONF_OFF(t1)

	# Set Source and Destination Address
	sd a0, DMA_SRC_ADD_OFF(t1)
	li t2, TFT_SPI_DST_ADD
	sd t2, DMA_DST_ADD_OFF(t1)

	# Setup DMA Controller
	ld t2, DMA_CH_CTL_OFF(t1)
	li t3, 0x3FFFF55
	not t3, t3
	and t2, t2, t3
	li t3, 0x45244
	or t2, t2, t3
	sd t2, DMA_CH_CTL_OFF(t1)

	# Define Block Size
	mv t2, a1
	addi t2, t2, -1
	sd t2, DMA_BLOCK_S_OFF(t1)

	# Enable DMA
	ld t2, 0x10(t0)
	ori t2, t2, 0x3
	sd t2, 0x10(t0)

	# Enable Channel
	ld t2, DMA_CH_EN_OFF(t0)
	li t3, 1
	slli t3, t3, TFT_DMA_CH
	or t2, t2, t3
	slli t3, t3, 8
	or t2, t2, t3
	sd t2, DMA_CH_EN_OFF(t0)

	# Enable SPI Slave
	li t2, SPI0_BASE_ADDR
	li t3, 1
	slli t3, t3, SPI_TFT_SS
	sw t3, SPI_SLAVE_EN_OFF(t2)

	# Wait while DMA is idle
	li t2, 1
	slli t2, t2, TFT_DMA_CH
1:
	ld t3, DMA_CH_EN_OFF(t0)
	and t3, t3, t2
	bne t3, x0, 1b

	# Clear interrupt
	li t2, 0xFFFFFFFF
	sd t2, DMA_CH_INT_OFF(t1)

	# Wait for SPI
	li t0, SPI0_BASE_ADDR
	li t1, 0x5
	li t2, 0x4
1:
	lwu t3, SPI_STATUS_OFF(t0)
	and t3, t3, t1
	bne t3, t2, 1b

	# Disable SPI Slave and Output
	sw x0, SPI_SLAVE_EN_OFF(t0)
	sw x0, SPI_ENABLE_OFF(t0)

    ld ra, 8(sp)
    addi sp, sp, 16
    ret
# end

.section .data
.align 4

tft_cmd:
	.word NO_OPERATION

tft_display_size:
	.word 0, 0, 0, 0, 0, 0, 0, 0
