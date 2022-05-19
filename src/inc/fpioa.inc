# Info for FPIOA functions
.equ PINS_MAX, 48
.equ FPIOA_MAX, 256

# Configuration offsets
.equ FPIOA_TIE_EN_OFF,  0xC0
.equ FPIOA_TIE_VAL_OFF, 0xE0

# Multiplex tie values
# Bits enabled are:
# 16 - FUNC_SPI0_ARB
# 82 - FUNC_SPI1_ARB
.equ FPIOA_TIE0, 0x00010000
.equ FPIOA_TIE1, 0x00000000
.equ FPIOA_TIE2, 0x00040000
.equ FPIOA_TIE3, 0x00000000
.equ FPIOA_TIE4, 0x00000000
.equ FPIOA_TIE5, 0x00000000
.equ FPIOA_TIE6, 0x00000000
.equ FPIOA_TIE7, 0x00000000

# Region Mask
.equ FPIOA_INPUT_MASK,      0x00F00000
.equ FPIOA_PULL_MASK,       0x00070000
.equ FPIOA_OUTPUT_MASK,     0x00003000
.equ FPIOA_DRIVING_MASK,    0x00000F00
.equ FPIOA_FUNCTION_MASK,   0x000000FF

# [23:20] Input
.equ FPIOA_ST,  0x800000  # Schmitt Trigger
.equ FPIOA_II,  0x200000  # Input Invert
.equ FPIOA_IE,  0x100000  # Input Enable

# [18:16] Pull
.equ FPIOA_NP,  0x00000  # No Pull
.equ FPIOA_PU,  0x10000  # Pull Up
.equ FPIOA_PD,  0x20000  # Pull Down
.equ FPIOA_SPU, 0x50000  # Strong Pull up

# [13:12] Output
.equ FPIOA_OI,  0x2000  # Output Invert
.equ FPIOA_OE,  0x1000  # Output Enable

# [11:8] Driving output current
.equ DS_0, 0x000
.equ DS_1, 0x100
.equ DS_2, 0x200
.equ DS_3, 0x300
.equ DS_4, 0x400
.equ DS_5, 0x500
.equ DS_6, 0x600
.equ DS_7, 0x700

# [7:0] Function select
# SPI0
.equ CH_SPI0_SS0,    0x0C
.equ CH_SPI0_SS1,    0x0D
.equ CH_SPI0_SS2,    0x0E
.equ CH_SPI0_SS3,    0x0F
.equ CH_SPI0_CLK,    0x11
# GPIOHS
.equ CH_GPIOHS0_SEL, 0x18
.equ CH_GPIOHS1_SEL, 0x19
.equ CH_GPIOHS2_SEL, 0x1A
.equ CH_GPIOHS3_SEL, 0x1B
.equ CH_GPIOHS4_SEL, 0x1C
.equ CH_GPIOHS5_SEL, 0x1D
.equ CH_GPIOHS6_SEL, 0x1E
.equ CH_GPIOHS7_SEL, 0x1F
# GPIO
.equ CH_GPIO0_SEL, 0x38
.equ CH_GPIO1_SEL, 0x39
.equ CH_GPIO2_SEL, 0x3A
.equ CH_GPIO3_SEL, 0x3B
.equ CH_GPIO4_SEL, 0x3C
.equ CH_GPIO5_SEL, 0x3D
.equ CH_GPIO6_SEL, 0x3E
.equ CH_GPIO7_SEL, 0x3F
