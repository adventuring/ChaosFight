; ChaosFight - Source/Common/Randomize.s
; Copyright © 2025 Interworldly Adventuring, LLC.
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
	RETURN

