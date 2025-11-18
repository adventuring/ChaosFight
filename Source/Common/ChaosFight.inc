; ChaosFight custom includes file
; Licensed under CC0 to match upstream batariBASIC headers.

;
; Includes go below - order is crucial, since this is also the order in which
; they will appear in the generated assembly file
;

; ChaosFight combined header with bank boundary constants
MultiSpriteSuperChip.s

; this is the batari Basic file
bB.asm

; ChaosFight uses multisprite kernel instead of standard kernel
multisprite_kernel.asm

; standard startup routine.
startup.asm

; below are collections of subroutines and functions
pf_drawing.asm
pf_scrolling.asm
std_routines.asm

; The overscan routine goes below.  it sets up sprites for the std_kernel.
std_overscan.asm

; Include standard math and utility functions
div_mul.asm
fixed_point_math.asm

; below is the generated batari Basic file
bB2.asm

; score graphics - ChaosFight uses custom font rendering
; score_graphics.asm

; bankswitch support
banksw.asm