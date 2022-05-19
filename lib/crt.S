.section .text.start, "ax", @progbits
.globl _start
_start:
  j 1f
  .word 0xdeadbeef
1:
  csrw mideleg, 0
  csrw medeleg, 0
  csrw mie, 0
  csrw mip, 0
  la t0, trap_entry
  csrw mtvec, t0

  li  x1, 0
  li  x2, 0
  li  x3, 0
  li  x4, 0
  li  x5, 0
  li  x6, 0
  li  x7, 0
  li  x8, 0
  li  x9, 0
  li  x10,0
  li  x11,0
  li  x12,0
  li  x13,0
  li  x14,0
  li  x15,0
  li  x16,0
  li  x17,0
  li  x18,0
  li  x19,0
  li  x20,0
  li  x21,0
  li  x22,0
  li  x23,0
  li  x24,0
  li  x25,0
  li  x26,0
  li  x27,0
  li  x28,0
  li  x29,0
  li  x30,0
  li  x31,0

  li t0, 0x6000
  csrs mstatus, t0

  fssr    x0
  fmv.w.x f0, x0
  fmv.w.x f1, x0
  fmv.w.x f2, x0
  fmv.w.x f3, x0
  fmv.w.x f4, x0
  fmv.w.x f5, x0
  fmv.w.x f6, x0
  fmv.w.x f7, x0
  fmv.w.x f8, x0
  fmv.w.x f9, x0
  fmv.w.x f10,x0
  fmv.w.x f11,x0
  fmv.w.x f12,x0
  fmv.w.x f13,x0
  fmv.w.x f14,x0
  fmv.w.x f15,x0
  fmv.w.x f16,x0
  fmv.w.x f17,x0
  fmv.w.x f18,x0
  fmv.w.x f19,x0
  fmv.w.x f20,x0
  fmv.w.x f21,x0
  fmv.w.x f22,x0
  fmv.w.x f23,x0
  fmv.w.x f24,x0
  fmv.w.x f25,x0
  fmv.w.x f26,x0
  fmv.w.x f27,x0
  fmv.w.x f28,x0
  fmv.w.x f29,x0
  fmv.w.x f30,x0
  fmv.w.x f31,x0

  .option push
  .option norelax
   la gp, __global_pointer$
  .option pop
  la  tp, _end + 63
  and tp, tp, -64
  csrr a0, mhartid

  add sp, a0, 1
  sll sp, sp, 15
  add sp, sp, tp

  j initBSP

  .globl trap_entry
  .type trap_entry, @function
  .align 2
trap_entry:
  addi sp, sp, -64*8

  sd x1, 1*8(sp)
  sd x2, 2*8(sp)
  sd x3, 3*8(sp)
  sd x4, 4*8(sp)
  sd x5, 5*8(sp)
  sd x6, 6*8(sp)
  sd x7, 7*8(sp)
  sd x8, 8*8(sp)
  sd x9, 9*8(sp)
  sd x10, 10*8(sp)
  sd x11, 11*8(sp)
  sd x12, 12*8(sp)
  sd x13, 13*8(sp)
  sd x14, 14*8(sp)
  sd x15, 15*8(sp)
  sd x16, 16*8(sp)
  sd x17, 17*8(sp)
  sd x18, 18*8(sp)
  sd x19, 19*8(sp)
  sd x20, 20*8(sp)
  sd x21, 21*8(sp)
  sd x22, 22*8(sp)
  sd x23, 23*8(sp)
  sd x24, 24*8(sp)
  sd x25, 25*8(sp)
  sd x26, 26*8(sp)
  sd x27, 27*8(sp)
  sd x28, 28*8(sp)
  sd x29, 29*8(sp)
  sd x30, 30*8(sp)
  sd x31, 31*8(sp)

  fsw f0, ( 0  + 32)*8(sp)
  fsw f1, ( 1  + 32)*8(sp)
  fsw f2, ( 2  + 32)*8(sp)
  fsw f3, ( 3  + 32)*8(sp)
  fsw f4, ( 4  + 32)*8(sp)
  fsw f5, ( 5  + 32)*8(sp)
  fsw f6, ( 6  + 32)*8(sp)
  fsw f7, ( 7  + 32)*8(sp)
  fsw f8, ( 8  + 32)*8(sp)
  fsw f9, ( 9  + 32)*8(sp)
  fsw f10,( 10 + 32)*8(sp)
  fsw f11,( 11 + 32)*8(sp)
  fsw f12,( 12 + 32)*8(sp)
  fsw f13,( 13 + 32)*8(sp)
  fsw f14,( 14 + 32)*8(sp)
  fsw f15,( 15 + 32)*8(sp)
  fsw f16,( 16 + 32)*8(sp)
  fsw f17,( 17 + 32)*8(sp)
  fsw f18,( 18 + 32)*8(sp)
  fsw f19,( 19 + 32)*8(sp)
  fsw f20,( 20 + 32)*8(sp)
  fsw f21,( 21 + 32)*8(sp)
  fsw f22,( 22 + 32)*8(sp)
  fsw f23,( 23 + 32)*8(sp)
  fsw f24,( 24 + 32)*8(sp)
  fsw f25,( 25 + 32)*8(sp)
  fsw f26,( 26 + 32)*8(sp)
  fsw f27,( 27 + 32)*8(sp)
  fsw f28,( 28 + 32)*8(sp)
  fsw f29,( 29 + 32)*8(sp)
  fsw f30,( 30 + 32)*8(sp)
  fsw f31,( 31 + 32)*8(sp)

  csrr a0, mcause
  csrr a1, mepc
  mv a2, sp
  add a3, sp, 32*8
  bgez a0, .handle_syscall
.handle_irq:
  jal handleIRQ
  j .restore
.handle_syscall:
  jal handleSyscall
.restore:
  csrw mepc, a0
  ld x1, 1*8(sp)
  ld x2, 2*8(sp)
  ld x3, 3*8(sp)
  ld x4, 4*8(sp)
  ld x5, 5*8(sp)
  ld x6, 6*8(sp)
  ld x7, 7*8(sp)
  ld x8, 8*8(sp)
  ld x9, 9*8(sp)
  ld x10, 10*8(sp)
  ld x11, 11*8(sp)
  ld x12, 12*8(sp)
  ld x13, 13*8(sp)
  ld x14, 14*8(sp)
  ld x15, 15*8(sp)
  ld x16, 16*8(sp)
  ld x17, 17*8(sp)
  ld x18, 18*8(sp)
  ld x19, 19*8(sp)
  ld x20, 20*8(sp)
  ld x21, 21*8(sp)
  ld x22, 22*8(sp)
  ld x23, 23*8(sp)
  ld x24, 24*8(sp)
  ld x25, 25*8(sp)
  ld x26, 26*8(sp)
  ld x27, 27*8(sp)
  ld x28, 28*8(sp)
  ld x29, 29*8(sp)
  ld x30, 30*8(sp)
  ld x31, 31*8(sp)

  flw f0, ( 0  + 32)*8(sp)
  flw f1, ( 1  + 32)*8(sp)
  flw f2, ( 2  + 32)*8(sp)
  flw f3, ( 3  + 32)*8(sp)
  flw f4, ( 4  + 32)*8(sp)
  flw f5, ( 5  + 32)*8(sp)
  flw f6, ( 6  + 32)*8(sp)
  flw f7, ( 7  + 32)*8(sp)
  flw f8, ( 8  + 32)*8(sp)
  flw f9, ( 9  + 32)*8(sp)
  flw f10,( 10 + 32)*8(sp)
  flw f11,( 11 + 32)*8(sp)
  flw f12,( 12 + 32)*8(sp)
  flw f13,( 13 + 32)*8(sp)
  flw f14,( 14 + 32)*8(sp)
  flw f15,( 15 + 32)*8(sp)
  flw f16,( 16 + 32)*8(sp)
  flw f17,( 17 + 32)*8(sp)
  flw f18,( 18 + 32)*8(sp)
  flw f19,( 19 + 32)*8(sp)
  flw f20,( 20 + 32)*8(sp)
  flw f21,( 21 + 32)*8(sp)
  flw f22,( 22 + 32)*8(sp)
  flw f23,( 23 + 32)*8(sp)
  flw f24,( 24 + 32)*8(sp)
  flw f25,( 25 + 32)*8(sp)
  flw f26,( 26 + 32)*8(sp)
  flw f27,( 27 + 32)*8(sp)
  flw f28,( 28 + 32)*8(sp)
  flw f29,( 29 + 32)*8(sp)
  flw f30,( 30 + 32)*8(sp)
  flw f31,( 31 + 32)*8(sp)

  addi sp, sp, 64*8
  mret

.section .data
.align 3

.global g_wake_up
g_wake_up:
      .dword 1
      .dword 0

.section ".tdata.begin"
.globl _tdata_begin
_tdata_begin:

.section ".tdata.end"
.globl _tdata_end
_tdata_end:

.section ".tbss.end"
.globl _tbss_end
_tbss_end:

