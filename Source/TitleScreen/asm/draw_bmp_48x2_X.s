draw_bmp_48x2_X
	; 48px bitmap display kernel for titlescreen minikernels
	; Displays 48-pixel wide bitmap graphics using 6 data pointers
	; aux2 = number of scanlines to display
	; scorepointers = pointers to bitmap data (6 pointers, each for 8 pixels)
	; aux5 = color data pointer
	; aux4 = background color

	ldy aux2	; Y = scanline counter
	beq draw_bmp_48x2_X_done	; If height is 0, exit

draw_bmp_48x2_X_loop
	lda (aux5),y	; Get color for this scanline
	sta COLUP0
	sta COLUP1

	; Load bitmap data for this scanline from the 6 scorepointers
	lda (scorepointers+0),y
	sta GRP0
	lda (scorepointers+2),y
	sta GRP1
	lda (scorepointers+4),y
	sta PF0
	lda (scorepointers+6),y
	sta PF1
	lda (scorepointers+8),y
	sta PF2
	lda (scorepointers+10),y
	; This 6th value might be for something else, or maybe ignored

	sta WSYNC	; Wait for next scanline

	dey
	bne draw_bmp_48x2_X_loop

draw_bmp_48x2_X_done
	; Clear all graphics
	lda #0
	sta GRP0
	sta GRP1
	sta PF0
	sta PF1
	sta PF2
	rts
