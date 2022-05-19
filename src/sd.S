.section .text
.align 1

.include "inc/mmap.inc"
.include "inc/spi.inc"
.include "inc/sysctl.inc"
.include "inc/pinmap.inc"
.include "inc/sd.inc"

.comm sdFrame, 6
.comm sdAFrame, 6
.comm sdReadRes, 514

.globl sdInitialize
sdInitialize:
	addi sp, sp, -16
	sd ra, 8(sp)
	
	# Setup SD
	jal ra, sdSetup

	# CMD 0
	la a0, sdFrame
	li t0, SD_CMD0
	sb t0, 0(a0)
	sb x0, 1(a0)
	sb x0, 2(a0)
	sb x0, 3(a0)
	sb x0, 4(a0)
	sb x0, 5(a0)
	li a1, 5
	jal ra, crc7get
	# Send Command
	li a1, 6
	jal ra, sdSPIwrite
	# Wait for response
	# Response: 0x01 = OK
	la a0, sdReadRes
	li a1, 1
	li a2, 0xFFF
2:
	jal ra, sdSPIread
	lbu t1, 0(a0)
	li t2, 0xFF
	bne t1, t2, 3f
	addi a2, a2, -1
	bne a2, x0, 2b
	li a0, 1
	j 1f # Failed to read
3:
	# Sync SD Card
	jal ra, syncData

	# CMD 8
	la a0, sdFrame
	li t0, SD_CMD8
	sb t0, 0(a0)
	li t1, SD_CMD8_ARG
	sb t1, 4(a0)
	srli t1, t1, 8
	sb t1, 3(a0)
	srli t1, t1, 8
	sb t1, 2(a0)
	srli t1, t1, 8
	sb t1, 1(a0)
	sb x0, 5(a0)
	li a1, 5
	jal ra, crc7get
	# Send Command
	li a1, 6
	jal ra, sdSPIwrite
	# Wait for response
	# Response: 0x01000001nn means SD card V2+ compatible and voltage accepted
	li a2, 0xFFF
	la a0, sdReadRes
	li a1, 1
2:
	jal ra, sdSPIread
	lbu t1, 0(a0)
	li t2, 0xFF
	bne t1, t2, 3f
	addi a2, a2, -1
	bne a2, x0, 2b
	li a0, 1
	j 1f # Failed to read
3:
	addi a0, a0, 1
	li a1, 5
	jal ra, sdSPIread

	# Sync SD Card
	jal ra, syncData

	# CMD 55
	la a0, sdFrame
	li t0, SD_CMD55
	sb t0, 0(a0)
	sb x0, 1(a0)
	sb x0, 2(a0)
	sb x0, 3(a0)
	sb x0, 4(a0)
	sb x0, 5(a0)
	jal ra, crc7get
	# ACMD 41
	la a0, sdAFrame
	li t0, SD_ACMD41
	sb t0, 0(a0)
	li t1, 0x40
	sb t1, 1(a0)
	sb x0, 2(a0)
	sb x0, 3(a0)
	sb t1, 4(a0)
	sb x0, 5(a0)
	li a1, 5
	jal ra, crc7get

	# Try to get a response
	li a2, 0xFF
2:
	# Send Command 55
	la a0, sdFrame
	li a1, 6
	jal ra, sdSPIwrite
	# Wait for response
	# Response: 0x01 = OK
	la a0, sdReadRes
	li a1, 1
	li a3, 0xFF
4:
	jal ra, sdSPIread
	lbu t1, 0(a0)
	li t2, 0x01
	beq t1, t2, 5f
	addi a3, a3, -1
	bne a3, x0, 4b
	j 6f # Failed to read
5:
	# Sync SD Card
	jal ra, syncData
	la a0, sdFrame
	li t0, SD_CMD55
	sb t0, 0(a0)

	# Send Command A41
	la a0, sdAFrame
	li a1, 6
	jal ra, sdSPIwrite
	# Wait for response
	# Response: 0x00 = OK
	la a0, sdReadRes
	li a1, 1
	li a3, 0xFF
4:
	jal ra, sdSPIread
	lbu t1, 0(a0)
	beq t1, x0, 3f
	addi a3, a3, -1
	bne a3, x0, 4b
	j 6f # Failed to read
	la a0, sdFrame
	li t0, 0xFF
	sb t0, 0(a0)
6:
	# Sync SD Card
	jal ra, syncData
	la a0, sdFrame
	li t0, SD_CMD55
	sb t0, 0(a0)

	addi a2, a2, -1
	bne a2, x0, 2b
	li a0, 1
	j 1f # Failed to read
3:
	# Sync SD Card
	jal ra, syncData

	# CMD 58
	la a0, sdFrame
	li t0, SD_CMD58
	sb t0, 0(a0)
	sb x0, 1(a0)
	sb x0, 2(a0)
	sb x0, 3(a0)
	sb x0, 4(a0)
	sb x0, 5(a0)
	jal ra, crc7get
	# Send Command
	li a1, 6
	jal ra, sdSPIwrite
	# Read Response
	# Response: [1]R1 + [2-5]OCR(MSB first)
    #           If CCS (Card Capacity Status) is set, card is SDHC or SDXC
	li a2, 0xFF
	la a0, sdReadRes
	li a1, 1
2:
	jal ra, sdSPIread
	lbu t1, 0(a0)
	li t2, 0xFF
	bne t1, t2, 3f
	addi a2, a2, -1
	bne a2, x0, 2b
	li a0, 1
	j 1f # Failed to read
3:
	addi a0, a0, 1
	li a1, 4
	jal ra, sdSPIread

	# Check Response
	# Verify if CCS and power up bit are set
	li t0, 0xC0
	lb t1, 0(a0)
	and t1, t1, t0
	beq t0, t1, 2f
	li a0, 1
	j 1f # Problem with card
2:
	# Sync SD Card
	jal ra, syncData

	# Increase Clock Rate
	li t0, SPI1_BASE_ADDR
	li t1, SYSCTL_SPI1_FDIV_HS
	sw t1, SPI_BAUD_RATE_OFF(t0)
	
	li a0, 0 # Setup successful 
1:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

syncData:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Dummy Data
	la a0, sdFrame
	li t0, 0xFF
	sb t0, 0(a0)
	# Send Command
	li a1, 1
	jal ra, sdSPIwrite

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

sdSetup:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Setup SPI1 Chip Select Pin
	li a0, PIN_SD_CS
	li a1, PIN_SD_CS_CONFIG
	jal ra, setupFPIOA

	# Setup SPI1 Clock Pin
	li a0, PIN_SD_CLK
	li a1, PIN_SD_CLK_CONFIG
	jal ra, setupFPIOA

	# Setup SPI1 MISO Pin
	li a0, PIN_SD_MISO
	li a1, PIN_SD_MISO_CONFIG
	jal ra, setupFPIOA

	# Setup SPI1 MOSI Pin
	li a0, PIN_SD_MOSI
	li a1, PIN_SD_MOSI_CONFIG
	jal ra, setupFPIOA

	# Configure SPI
	li t0, SPI1_BASE_ADDR
	sw x0, SPI_ENABLE_OFF(t0)
	sw x0, SPI_SLAVE_EN_OFF(t0)
	sw x0, SPI_INTR_MASK_OFF(t0)
	sw x0, SPI_DMA_CTL_OFF(t0)
	sw x0, SPI_DMA_TDL_OFF(t0)
	sw x0, SPI_DMA_RDL_OFF(t0)
	sw x0, SPI_ENDIAN_OFF(t0)
	sw x0, SPI_SCTL0_OFF(t0)
	li t1, SYSCTL_SPI1_FDIV
	sw t1, SPI_BAUD_RATE_OFF(t0)
	li t1, SPI_WORK_MODE
	slli t1, t1, 6
	li t2, SPI_TRANS_M
	slli t2, t2, 8
	or t1, t1, t2
	li t2, 8
	addi t2, t2, -1
	slli t2, t2, 16
	or t1, t1, t2
	li t2, SPI1_FRM_FMT
	slli t2, t2, 21
	or t1, t1, t2
	sw t1, SPI_CTL0_OFF(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl sdSectorRead
# a0 - Data Address
# a1 - Sector
sdSectorRead:
	addi sp, sp, -24
	sd ra, 8(sp)
	sd a0, 16(sp)

	# CMD 17
	la a0, sdFrame
	li t0, SD_CMD17
	sb t0, 0(a0)
	mv t1, a1
	sb t1, 4(a0)
	srli t1, t1, 8
	sb t1, 3(a0)
	srli t1, t1, 8
	sb t1, 2(a0)
	srli t1, t1, 8
	sb t1, 1(a0)
	sb x0, 5(a0)
	li a1, 5
	jal ra, crc7get
	li t0, 0xFF
	sb t0, 6(a0)
	# Send Command
	li a1, 7
	jal ra, sdSPIwrite

	# Wait for response
	la a0, sdReadRes
	li a1, 1
	li a2, 0xFFF
2:
	jal ra, sdSPIread
	lbu t1, 0(a0)
	li t2, 0xFF
	bne t1, t2, 3f
	addi a2, a2, -1
	bne a2, x0, 2b
	li a1, 1
	j 1f # Failed to read
3:
	# Wait for sector start code
	# Response: 0xFE = OK
	ld a0, 16(sp)
	li a2, 0xFFF
2:
	jal ra, sdSPIread
	lbu t1, 0(a0)
	li t2, 0xFE
	beq t1, t2, 3f
	addi a2, a2, -1
	bne a2, x0, 2b
	li a1, 1
	j 1f # Failed to read
3:
	# Read Sector
	# Response: [512]Data + [2]CRC
	li a1, 514
	jal ra, sdSPIread

	# Sync SD Card
	jal ra, syncData

	ld a0, 16(sp)
	li a1, 0 # Successful read
1:
	ld ra, 8(sp)
	addi sp, sp, 24
	ret
#end

.globl sdSPIwrite
# a0 - Data Address
# a1 - Data Length
sdSPIwrite:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Set SPI Transmission Mode
	li t0, SPI1_BASE_ADDR
	lw t1, SPI_CTL0_OFF(t0)
	li t2, 0x3
	slli t2, t2, 8
	not t2, t2
	and t1, t1, t2
	li t2, SPI_TRANS_M
	slli t2, t2, 8
	or t1, t1, t2
	sw t1, SPI_CTL0_OFF(t0)

	# Enable SPI
	li t1, 1
	sw t1, SPI_ENABLE_OFF(t0)

	# Enable SPI Slave
	li t1, 1
	slli t1, t1, SPI_SD_SS
	sw t1, SPI_SLAVE_EN_OFF(t0)

	# Loop while have data to send
	mv t1, a0
	mv t2, a1
1:
	lw t3, SPI_TFIFO_LVL_OFF(t0)
	li t4, 32
	sub t3, t4, t3
	li t4, 0
	bge t2, t3, 2f
	mv t3, t2
2:
	# Store data until FIFO is filled
	bge t4, t3, 3f
	lbu t5, 0(t1)
	sw t5, SPI_DATA_FIFO_OFF(t0)
	addi t1, t1, 1
	addi t4, t4, 1
	j 2b
3:
	sub t2, t2, t3
	blt x0, t2, 1b

	# Wait for SPI
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
#end

.globl sdSPIread
# a0 - Data Address
# a1 - Data Length
sdSPIread:
	addi sp, sp, -16
	sd ra, 8(sp)

	# Set SPI Transmission Mode
	li t0, SPI1_BASE_ADDR
	lw t1, SPI_CTL0_OFF(t0)
	li t2, 0x3
	slli t2, t2, 8
	not t2, t2
	and t1, t1, t2
	li t2, SPI_RECEV_M
	slli t2, t2, 8
	or t1, t1, t2
	sw t1, SPI_CTL0_OFF(t0)

	# Set Receive Data Length
	mv t1, a1
	addi t1, t1, -1
	sw t1, SPI_CTL1_OFF(t0)

	# Enable SPI
	li t1, 1
	sw t1, SPI_ENABLE_OFF(t0)

	# Clear FIFO Buffer
	li t1, 0
	not t1, t1
	sw t1, SPI_DATA_FIFO_OFF(t0)

	# Enable SPI Slave
	li t1, 1
	slli t1, t1, SPI_SD_SS
	sw t1, SPI_SLAVE_EN_OFF(t0)

	# Loop while have data to receive
	mv t1, a0
	mv t2, a1
1:
	lw t3, SPI_RFIFO_LVL_OFF(t0)
	li t4, 0
	bge t2, t3, 2f
	mv t3, t2
2:
	# Store data until FIFO is filled
	bge t4, t3, 3f
	lw t5, SPI_DATA_FIFO_OFF(t0)
	sb t5, 0(t1)
	addi t1, t1, 1
	addi t4, t4, 1
	j 2b
3:
	sub t2, t2, t3
	blt x0, t2, 1b

	# Disable SPI Slave and Output
	sw x0, SPI_SLAVE_EN_OFF(t0)
	sw x0, SPI_ENABLE_OFF(t0)

	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end
