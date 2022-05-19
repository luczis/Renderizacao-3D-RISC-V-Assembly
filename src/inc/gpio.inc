# Info for GPIO functions

# Direction
.equ GPIO_INPUT,   0x0
.equ GPIO_OUTPUT,  0x1

# GPIO ------------------
.equ GPIO_MAX, 8

# Offset
.equ GPIO_OUT_OFF, 0x00
.equ GPIO_DIR_OFF, 0x04
.equ GPIO_IN_OFF,  0x50

# GPIOHS ----------------
.equ GPIOHS_MAX, 32

# Offset
.equ GPIOHS_IN_VAL,  0x00
.equ GPIOHS_IN_EN,   0x04
.equ GPIOHS_OUT_EN,  0x08
.equ GPIOHS_OUT_VAL, 0x0C
