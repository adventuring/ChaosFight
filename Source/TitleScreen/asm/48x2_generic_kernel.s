; Generic 48x2 bitmap kernel that handles all 4 bitmap sets
; For backwards compatibility, draw_bmp_48x2_3 defaults to ChaosFight (index 3)

draw_bmp_48x2_3
	; Hardcoded to ChaosFight bitmap (index 3)
	lda #<(bmp_48x2_3_colors-1+bmp_48x2_3_height-bmp_48x2_3_window)
	sta aux5+0
	lda #>(bmp_48x2_3_colors-1+bmp_48x2_3_height-bmp_48x2_3_window)
	sta aux5+1

        ldy #11
bmp_48x2_3_pointersetup
        lda bmp_48x2_3_values,y
        sta scorepointers,y
        dey
        lda bmp_48x2_3_values,y
        sta scorepointers,y
        dey
        bpl bmp_48x2_3_pointersetup

	; Use runtime window variable
	ifnconst titlescreenWindow3
	ldy #(bmp_48x2_3_window-1)
	else
	ldy titlescreenWindow3
	dey
	endif
	sty aux2

	iny
	lda (aux5),y
	dey

        sta COLUP0
        sta COLUP1
        sta HMCLR

        lda titlescreencolor
        sta COLUPF

	lda titlescreencolor
	sta aux4

	lda #0
	sta PF1
	sta PF2

 	jmp draw_bmp_48x2_X
