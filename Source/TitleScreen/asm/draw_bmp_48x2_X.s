draw_bmp_48x2_X
	; 48x2 bitmap display kernel for titlescreen
	; Displays double-height characters using scorepointers
	; aux2 = height counter (number of bitmap rows)
	; scorepointers = pointers to bitmap data for each character column
	; aux5 = color data pointer
	; aux4 = background color

;; FIXME: The correct implementation was destroyed and must be recreated.

draw_bmp_48x2_X_done
	rts
