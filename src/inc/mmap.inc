# K210 memory map

.equ GPIOHS_BASE_ADDR, 0x38001000
.equ DMA_BASE_ADDR,    0x50000000
.equ GPIO_BASE_ADDR,   0x50200000
.equ FPIOA_BASE_ADDR,  0x502B0000
.equ SYSCTL_BASE_ADDR, 0x50440000
.equ SPI0_BASE_ADDR,   0x52000000
.equ SPI1_BASE_ADDR,   0x53000000
.equ CLINT_BASE_ADDR,  0x02000000
.equ PLIC_BASE_ADDR,   0x0C000000

# 20bit For use with lui
.equ GPIOHS_BASE_ADDR_LUI, 0x38001
.equ DMAC_BASE_ADDR_LUI,   0x50000
.equ GPIO_BASE_ADDR_LUI,   0x50200
.equ FPIOA_BASE_ADDR_LUI,  0x502B0
.equ SYSCTL_BASE_ADDR_LUI, 0x50440
.equ SPI0_BASE_ADDR_LUI,   0x52000
.equ SPI1_BASE_ADDR_LUI,   0x53000
.equ CLINT_BASE_ADDR_LUI,  0x02000
.equ PLIC_BASE_ADDR_LUI,   0x0C000