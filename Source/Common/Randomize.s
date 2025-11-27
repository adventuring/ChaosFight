; ChaosFight - Source/Common/Randomize.s
; Copyright © 2025 Bruce-Robert Pocock.
; Random number generator routine
; Local implementation - do not use std_routines.asm

randomize
	lda rand
	lsr
 ifconst rand16
	rol rand16
 endif
	bcc noeor
	eor #$B4
noeor
	sta rand
	ifconst rand16
	eor rand16
	endif
	; CRITICAL: randomize is only called same-bank (via gosub randomize),
	; so it must use rts, not jmp BS_return. RETURN macro expands to
	; jmp BS_return when bankswitch is defined, which is incorrect for
	; same-bank calls.
	rts

