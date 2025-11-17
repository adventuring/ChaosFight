; ChaosFight superchip RAM definitions and ChaosFight-specific additions.
; The upstream multisprite definitions are included separately.
; Licensed under CC0 to match upstream batariBASIC headers.

 include "2600basic_variable_redefs.h"

; Essential function stubs and constants needed for batariBASIC

pfread                        ; Playfield read function
;x=xvalue, y=yvalue
 jsr setuppointers
 lda setbyte,x
 and playfield,y
 eor setbyte,x
; beq readzero
; lda #1
; readzero
 rts

mul8                          ; 8-bit multiplication function
        rts

draw_bmp_48x1_X             ; 48x1 bitmap display function
        rts

minikernel                    ; Titlescreen minikernel subroutine
        rts

gamenumber        EQU $00    ; Game number for gameselect minikernel

miniscoretable   EQU $0000  ; Score minikernel table

; Kernel configuration constants
pfscore          EQU 1    ; Enable playfield score feature
noscore          EQU 0    ; Enable score display (health bars)

; Bank start labels (needed for cross-bank calls)
start_bank1      EQU $FFE0
start_bank2      EQU $FFE0
start_bank3      EQU $FFE0
start_bank4      EQU $FFE0
start_bank5      EQU $FFE0
start_bank6      EQU $FFE0
start_bank7      EQU $FFE0
start_bank8      EQU $FFE0
start_bank9      EQU $FFE0
start_bank10     EQU $FFE0
start_bank11     EQU $FFE0
start_bank12     EQU $FFE0
start_bank13     EQU $FFE0
start_bank14     EQU $FFE0
start_bank15     EQU $FFE0
start_bank16     EQU $FFE0