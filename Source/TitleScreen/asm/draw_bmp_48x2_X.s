draw_bmp_48x2_X
	; 48x2 bitmap display kernel for titlescreen minikernels
	; Displays 6 characters (48 pixels wide) using proper TIA timing
	; aux2 = number of bitmap rows to display
	; scorepointers = pointers to bitmap data for each character (6 pointers)
	; aux5 = color data pointer
	; aux4 = background color

;; FIXME: The correct implementation was destroyed and must be recreated.

draw_bmp_48x2_X_done
	; Clear sprites
	lda #0
	sta GRP0
	sta GRP1
	rts
