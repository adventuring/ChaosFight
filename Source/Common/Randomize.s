; ChaosFight - Source/Common/Randomize.s
; Copyright © 2025 Bruce-Robert Pocock.
; Random number generator routine
; Local implementation - do not use std_routines.asm

randomize
	lda rand
	lsr
 ifconst rand16_W
	; CRITICAL: rand16 is in SCRAM - no RMW operations allowed
	; Must read from read port, perform operation in register, write to write port
	lda rand16_R
	rol
	sta rand16_W
 endif
	bcc noeor
	eor #$B4
noeor
	sta rand
	ifconst rand16_W
	; CRITICAL: rand16 is in SCRAM, must use read port for EOR (read-only)
	eor rand16_R
	endif
	; CRITICAL: randomize is only called same-bank (via gosub randomize),
	; so it must use rts, not jmp BS_return. RETURN macro expands to
	; jmp BS_return when bankswitch is defined, which is incorrect for
	; same-bank calls.
	rts

