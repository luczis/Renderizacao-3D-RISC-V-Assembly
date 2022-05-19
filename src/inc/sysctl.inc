# Info for SYSCTL functions

# PLL frequencies
# 0xB4AD0 -- 400 MHz
# 0xF47D0 -- 800 MHz
.equ SYSCTL_PLL0_FREQ, 0xB4AD0
.equ SYSCTL_SPI0_FDIV, 40    # 40 -- 10 MHz
.equ SYSCTL_SPI1_FDIV, 2000  # 2000 -- 100 kHz
.equ SYSCTL_SPI1_FDIV_HS, 16 # 16 -- 25 MHz

# Configuration offsets
.equ SYSCTL_PLL0_CTL, 0x08
.equ SYSCTL_PLL_LOCK, 0x18
.equ SYSCTL_ACLK_CTL, 0x20
.equ SYSCTL_CBUS_EN,  0x28
.equ SYSCTL_PERI_EN,  0x2C
.equ SYSCTL_CTHR_SPI, 0x3C
.equ SYSCTL_MISC_CTL, 0x54
.equ SYSCTL_RST_SST,  0x60
.equ SYSCTL_DMA_SEL,  0x64

# Region Mask
.equ ACLK_PLL_EN_MASK,      0x00000001
.equ ACLK_APB_SRC_MASK,     0x00000FF8
.equ LOCK_PLL0_MASK,        0x00000003
.equ LOCK_SLIP0_CLEAR,      0x00000004
.equ PLL_OUTPUT_MASK_LUI,   0x02000
.equ PLL_POWER_MASK_LUI,    0x00200
.equ PLL_RESET_MASK_LUI,    0x00100
.equ PLL_FREQ_MASK,         0x000FFFFF
.equ CTHR_SPI0_MASK,        0x000000FF
.equ CTHR_SPI1_MASK,        0x0000FF00
.equ CBUS_APB0_MASK,        0x00000008
.equ PERI_FPIOA_MASK,       0x00100000
.equ SYSCTL_RST_CLR_MASK,   0x00000001

# APB Source
# Between PLL0[0], PLL1[1] or PLL2[2]
.equ PLL_APB0_SRC, 0
.equ PLL_APB1_SRC, 0
.equ PLL_APB2_SRC, 0

# Enable Clock Buses
# 0 - CPU
# 1 - SRAM0
# 2 - SRAM1
# 3 - APB0
# 4 - APB1
# 5 - APB2
.equ CLK_BUS_EN_REG, 0x003F

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
.equ CLK_PERI_EN_REG,     0xCCFFFFFF
