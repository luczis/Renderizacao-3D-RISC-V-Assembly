.section .text
.align 1

.include "inc/fat.inc"

.comm fatBuffer, 514
.comm fatTableBuffer, 514

.globl openFAT
openFAT:
	addi sp, sp, -16
	sd ra, 8(sp)

	# MBR -----------
	# Get Master Boot Record
	la a0, fatBuffer
	li a1, 0
	jal ra, sdSectorRead

	# Verify if it is a valid FAT system
	lbu t0, 510(a0)
	lbu t1, 511(a0)
	slli t0, t0, 8
	or t0, t0, t1
	li t1, FAT_BR_SIGNATURE
	beq t0, t1, 2f
	li a0, 1
	j 1f # Not a FAT system
2:
	
	# Get partition values
	li t0, PARTITION_START
	li t1, PARTITION_NUMBER
	li t2, PARTITION_ENTRY_SIZE
	mul t1, t1, t2
	add t0, t0, t1 # Partition entry offset
	# Partition Start
	li t1, PARTITION_START_OFF
	add t1, t1, t0
	add t2, t1, a0
	lbu t3, 0(t2)
	lbu t4, 1(t2)
	slli t4, t4, 8
	or t3, t3, t4
	lbu t4, 2(t2)
	slli t4, t4, 16
	or t3, t3, t4
	lbu t4, 3(t2)
	slli t4, t4, 24
	or t3, t3, t4
	la t1, partition_start
	sw t3, 0(t1)
	bne x0, t3, 2f
	li a0, 1
	j 1f # Partition doesn't exist
2:
	# Partition Size
	li t1, PARTITION_SIZE_OFF
	add t1, t1, t0
	add t2, t1, a0
	lbu t3, 0(t2)
	lbu t4, 1(t2)
	slli t4, t4, 8
	or t3, t3, t4
	lbu t4, 2(t2)
	slli t4, t4, 16
	or t3, t3, t4
	lbu t4, 3(t2)
	slli t4, t4, 24
	or t3, t3, t4
	la t1, partition_size
	sw t3, 0(t1)
	bne x0, t3, 2f
	li a0, 1
	j 1f # Partition doesn't exist
2:

	# Verify partition type
	# [Must be FAT32 LBA]
	li t1, PARTITION_ID_OFF
	add t1, t1, t0
	add t2, t1, a0
	li t0, PARTITION_FAT32_LBA
	lbu t1, 0(t2)
	beq t0, t1, 2f
	li a0, 1
	j 1f # Type unsuported
2:

	# Boot Sector ---
	# Get Partition Boot Sector
	la t0, partition_start
	lwu a1, 0(t0)
	la a0, fatBuffer
	jal ra, sdSectorRead

	# Check Sector Size
	# [Must be 512]
	li t0, BOOT_BPS_OFF
	add t0, t0, a0
	lbu t1, 1(t0)
	slli t1, t1, 8
	lbu t0, 0(t0)
	or t0, t0, t1
	li t1, FAT_SECTOR_SIZE
	beq t0, t1, 2f
	li a0, 1
	j 1f # Wrong sector size
2:

	# Get Sectors per Clusters
	li t0, BOOT_SPC_OFF
	add t0, t0, a0
	lbu s0, 0(t0)
	la t0, cluster_size
	sw s0, 0(t0)

	# Get Reserved Area Size
	li t0, BOOT_RSVD_SIZE
	add t0, t0, a0
	lbu t1, 1(t0)
	slli t1, t1, 8
	lbu t0, 0(t0)
	or t0, t0, t1

	# FAT Table Start
	la t1, partition_start
	lwu s1, 0(t1)
	add t0, t0, s1
	la t1, fat_table_start
	sw t0, 0(t1)

	# FAT Table Count
	li t0, BOOT_FAT_CPS
	add t0, t0, a0
	lbu s2, 0(t0)
	la t0, fat_table_count
	sw s2, 0(t0)

	# FAT Table Size
	li t0, BOOT_FAT_SIZE
	add t0, t0, a0
	lbu t1, 0(t0)
	lbu t2, 1(t0)
	slli t2, t2, 8
	or t1, t1, t2
	lbu t2, 2(t0)
	slli t2, t2, 16
	or t1, t1, t2
	lbu t2, 3(t0)
	slli t2, t2, 24
	or s3, t1, t2
	la t0, fat_table_size
	sw s3, 0(t0)

	# Root Start
	li t0, 2
	mul t0, t0, s0
	mul t1, s2, s3
	add t1, t1, s1
	add t1, t1, t0
	la t0, root_start
	sw t1, 0(t0)

	# FAT Table -----
	la t0, fat_table_start
	lwu a1, 0(t0)
	la a0, fatBuffer
	jal ra, sdSectorRead

	# Get root folder size in clusters
	mv t0, x0
	li t2, 4
	li t3, 0xF8
	li a1, 0xFFF
2:
	addi t0, t0, 1
	addi t1, t0, 1
	mul t1, t1, t2
	add t1, t1, a0
	lbu t1, 0(t1)
	addi a1, a1, -1
	bne x0, a1, 3f
	blt t1, t2, 2b
3:
	la t1, root_folder_size
	sw t0, 0(t1)

	li a0, 0 # Successful FAT setup
1:
	ld ra, 8(sp)
	addi sp, sp, 16
	ret
#end

.globl readFile
# a0 - File Name
# a1 - Result Address
readFile:
	addi sp, sp, -48
	sd ra, 8(sp)
	sd a0, 16(sp)
	sd a1, 24(sp)

	# Find file
	la a0, fatBuffer
	la a1, root_start
	lwu a1, 0(a1)
	jal ra, sdSectorRead
	li a1, 0
	la t0, cluster_size
	lwu t0, 0(t0)
	la t1, root_folder_size
	lwu t1, 0(t1)
	mul s1, t0, t1
	li s0, 0
1:
	# Check if is Long File Entry
	add t0, a1, a0
	lbu t1, 0xB(t0)
	li t2, 0xF
	bne t1, t2, 3f # Not a Long File Entry
	# Check if it is the first entry
	lbu t1, 0(t0)
	and t1, t1, t2
	li t2, 1
	bne t1, t2, 3f # Not first entry
	li t1, 0
	li t2, 1
4:
	ld t3, 16(sp)
	add t3, t3, t1
	lbu t3, 0(t3) # File name
	add t4, t0, t2
	lbu t4, 0(t4) # FAT buffer

	bne t3, t4, 3f # Wrong file
	beq t3, x0, 2f # File exist

	addi t1, t1, 1
	addi t2, t2, 2

	# Skip gaps
	li t3, 11
	bne t2, t3, 5f
	addi t2, t2, 3
5:
	li t3, 26
	bne t2, t3, 5f
	addi t2, t2, 2
5:
	li t3, 32
	blt t2, t3, 4b
	j 2f

	# Check next entry
	li t3, 512
	addi a1, a1, 32
	# Read new sector if needed
	blt a1, t3, 5f 
	addi s0, s0, 1
	blt s0, s1, 6f
	li a0, 1
	j 1f # File doesn't exist
6:
	la a1, root_start
	lwu a1, 0(a1)
	add a1, a1, s0
	jal ra, sdSectorRead
	li a1, 0
5:
	j 1b
3:
	li t0, 512
	addi a1, a1, 32
	blt a1, t0, 1b
	# Read new sector
	addi s0, s0, 1
	blt s0, s1, 4f
	li a0, 1
	j 1f # File doesn't exist
4:
	la a1, root_start
	lwu a1, 0(a1)
	add a1, a1, s0
	jal ra, sdSectorRead
	li a1, 0
	j 1b
2:

	# Get Short File Entry Info
	addi a1, a1, 32
	add t0, a1, a0
	# File first cluster
	lbu t1, 27(t0)
	slli t1, t1, 8
	lbu t2, 26(t0)
	or t1, t1, t2
	sw t1, 32(sp)
	# File size in Bytes
	lbu t1, 31(t0)
	slli t1, t1, 24
	lbu t2, 30(t0)
	slli t2, t2, 16
	or t1, t1, t2
	lbu t2, 29(t0)
	slli t2, t2, 8
	or t1, t1, t2
	lbu t2, 28(t0)
	or t1, t1, t2
	sw t1, 36(sp)
	li t2, FAT_MAX_FILE_KIB
	blt t1, t2, 2f
	li a0, 1
	j 1f # File is too big
2:
	# Get short name checksum
	li t1, 0
	li t2, 0
2:
	andi t3, t1, 1
	li t4, 0
	beq t3, x0, 4f
	li t4, 0x80
4:
	srli t3, t1, 1
	add t3, t3, t4
	add t4, t2, t0
	lbu t4, 0(t4)
	add t1, t3, t4
	andi t1, t1, 0xFF

	li t3, 11
	addi t2, t2, 1
	blt t2, t3, 2b
3:
	sw t1, 40(sp)

	# Get FAT Table
	la a0, fatTableBuffer
	la a1, fat_table_start
	lwu a1, 0(a1)
	jal ra, sdSectorRead

	# Read File
	li s0, 0
	li s1, 0
	la s2, cluster_size
	lwu s2, 0(s2)
2:
	li s3, 0
4:
	# Read sector data
	la a0, fatBuffer
	la a1, root_start
	lwu a1, 0(a1)
	lwu t0, 32(sp) # File first cluster
	addi t0, t0, -2
	mul t0, t0, s2
	add a1, a1, t0
	add a1, a1, s3
	jal ra, sdSectorRead

	# Pass data to result address
	ld t0, 24(sp)
	li t1, 0
5:
	add t2, t1, a0
	ld t2, 0(t2) # Load data from buffer
	add t3, s1, t0
	sd t2, 0(t3) # Pass data to result

	lwu t2, 36(sp) # File size
	addi s1, s1, 8
	blt t2, s1, 3f # Completed read

	li t2, 512
	addi t1, t1, 8
	blt t1, t2, 5b

	addi s3, s3, 1
	blt s3, s2, 4b

	# Get next cluster
	lwu t0, 32(sp) # File first cluster
	la t1, fatTableBuffer
	slli t0, t0, 2
	add t0, t0, t1
	lbu t1, 3(t0)
	li t2, 0x0F
	beq t1, t2, 3f # No more clusters allocated
	slli t1, t1, 24
	lbu t2, 2(t0)
	slli t2, t2, 16
	or t1, t1, t2
	lbu t2, 1(t0)
	slli t2, t2, 8
	or t1, t1, t2
	lbu t2, 0(t0)
	or t1, t1, t2

	sw t1, 32(sp) # Next cluster
	j 2b
3:
	li a0, 0 # Successful read
1:
	ld ra, 8(sp)
	addi sp, sp, 48
	ret
#end

.section .data
.align 4

partition_start:
	.word 0
partition_size:
	.word 0
cluster_size:
	.word 0
fat_table_start:
	.word 0
fat_table_count:
	.word 0
fat_table_size:
	.word 0
root_start:
	.word 0
root_folder_size:
	.word 0
