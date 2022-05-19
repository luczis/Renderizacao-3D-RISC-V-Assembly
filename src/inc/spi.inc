# Info for SPI functions

# SPI Settings
.equ SPI_WAIT_CYCL, 0
.equ SPI_WORK_MODE, 0
.equ SPI_ADDR_LEN,  0
.equ SPI_ENDIAN,    0
.equ SPI_TRANS_M,   1
.equ SPI_RECEV_M,   2

# SPI0 Settings
.equ SPI0_FRM_FMT,  3
.equ SPI0_BIT_LEN,  8 # Varies 8 or 16
.equ SPI0_INS_LEN,  2 # Varies 2 or 3
.equ SPI0_IATM,     2

# SPI1 
.equ SPI1_FRM_FMT,  0
.equ SPI1_BIT_LEN,  8
.equ SPI1_INS_LEN,  0
.equ SPI1_IATM,     0

# Configuration offsets
.equ SPI_CTL0_OFF,      0x00
.equ SPI_CTL1_OFF,      0x04
.equ SPI_ENABLE_OFF,    0x08
.equ SPI_SLAVE_EN_OFF,  0x10
.equ SPI_BAUD_RATE_OFF, 0x14
.equ SPI_TFIFO_LVL_OFF, 0x20
.equ SPI_RFIFO_LVL_OFF, 0x24
.equ SPI_STATUS_OFF,    0x28
.equ SPI_INTR_MASK_OFF, 0x2C
.equ SPI_DMA_CTL_OFF,   0x4C
.equ SPI_DMA_TDL_OFF,   0x50
.equ SPI_DMA_RDL_OFF,   0x54
.equ SPI_DATA_FIFO_OFF, 0x60
.equ SPI_SCTL0_OFF,     0xF4
.equ SPI_ENDIAN_OFF,    0x118

# Region Mask
.equ SPI_CTL0_FF_MASK,  0x0600000
.equ SPI_CTL0_DBL_MASK, 0x01F0000
.equ SPI_CTL0_WC_MASK,  0x000F800
.equ SPI_CTL0_IL_MASK,  0x0000700
.equ SPI_CTL0_WM_MASK,  0x00000C0
.equ SPI_CTL0_AL_MASK,  0x000003C
.equ SPI_CTL0_ATM_MASK, 0x0000003

#.equ ACLK_PLL_EN_MASK,      0x00000001
#.equ ACLK_APB_SRC_MASK,     0x00000FF8
#.equ PLL_OUTPUT_MASK_LUI,   0x02000
#.equ PLL_POWER_MASK_LUI,    0x00200
#.equ PLL_RESET_MASK_LUI,    0x00100
#.equ PLL_FREQ_MASK,         0x000FFFFF
#.equ CTHR_SPI0_MASK,        0x000000FF
#.equ CTHR_SPI1_MASK,        0x0000FF00

# APB Source
# Between PLL0[0], PLL1[1] or PLL2[2]
#.equ PLL_APB0_SRC, 0
#.equ PLL_APB1_SRC, 0
#.equ PLL_APB2_SRC, 0

# Enable Clock Buses
# 0 - CPU
# 1 - SRAM0
# 2 - SRAM1
# 3 - APB0
# 4 - APB1
# 5 - APB2
#.equ CLK_BUS_EN_REG, 0x003F

# Enable Peripheral Clock
#  0 - ROM
#  1 - DMA
#  2 - AI
#  3 - DVP
#  4 - FFT
#  5 - GPIO
#  6 - SPI0
#  7 - SPI1
#  8 - SPI2
#  9 - SPI3 !It is used for the flash, may be important!
# 10 - I2S0
# 11 - I2S1
# 12 - I2S2
# 13 - I2C0
# 14 - I2C1
# 15 - I2C2
# 16 - UART1
# 17 - UART2
# 18 - UART3
# 19 - AES
# 20 - FPIOA
# 21 - Timer0
# 22 - Timer1
# 23 - Timer2
# 24 - WDT0
# 25 - WDT1
# 26 - SHA
# 27 - OTP
# 28 - Reserved
# 29 - RTC
# 30 - Reserved
# 31 - Reserved
#.equ CLK_PERI_EN_REG,     0x001000E3

# [18:16] Pull
#.equ FPIOA_NP,  0x00000  # No Pull
#.equ FPIOA_PU,  0x10000  # Pull Up
#.equ FPIOA_PD,  0x20000  # Pull Down
#.equ FPIOA_SPU, 0x50000  # Strong Pull up

# [13:12] Output
#.equ FPIOA_OI,  0x2000  # Output Invert
#.equ FPIOA_OE,  0x1000  # Output Enable

# [11:8] Driving output current
#.equ DS_0, 0x000
#.equ DS_1, 0x100
#.equ DS_2, 0x200
#.equ DS_3, 0x300
#.equ DS_4, 0x400
#.equ DS_5, 0x500
#.equ DS_6, 0x600
#.equ DS_7, 0x700

# [7:0] Function select
# GPIOHS
#.equ CH_GPIOHS0_SEL, 0x18
#.equ CH_GPIOHS1_SEL, 0x19
#.equ CH_GPIOHS2_SEL, 0x1A
#.equ CH_GPIOHS3_SEL, 0x1B
#.equ CH_GPIOHS4_SEL, 0x1C
#.equ CH_GPIOHS5_SEL, 0x1D
#.equ CH_GPIOHS6_SEL, 0x1E
#.equ CH_GPIOHS7_SEL, 0x1F
# GPIO
#.equ CH_GPIO0_SEL, 0x38
#.equ CH_GPIO1_SEL, 0x39
#.equ CH_GPIO2_SEL, 0x3A
#.equ CH_GPIO3_SEL, 0x3B
#.equ CH_GPIO4_SEL, 0x3C
#.equ CH_GPIO5_SEL, 0x3D
#.equ CH_GPIO6_SEL, 0x3E
#.equ CH_GPIO7_SEL, 0x3F

