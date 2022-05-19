# Values for the Control and Status Registers

# mie Interupt ReQuest (IRQ) bits
.equ MIE_SOFTW_S_EN_MASK, 0x002
.equ MIE_SOFTW_H_EN_MASK, 0x004
.equ MIE_SOFTW_M_EN_MASK, 0x008
.equ MIE_TIMER_S_EN_MASK, 0x020
.equ MIE_TIMER_H_EN_MASK, 0x040
.equ MIE_TIMER_M_EN_MASK, 0x080
.equ MIE_EXTRN_S_EN_MASK, 0x200
.equ MIE_EXTRN_H_EN_MASK, 0x400
.equ MIE_EXTRN_M_EN_MASK, 0x800

# mstatus
.equ MSTATUS_MIE_MASK,    0x008
