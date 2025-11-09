; Generic 48x2 bitmap kernel that handles all 4 bitmap sets
; For backwards compatibility, draw_bmp_48x2_3 defaults to ChaosFight (index 3)

draw_bmp_48x2_3
	lda #3 ; ChaosFight bitmap
	sta bmp_index
	jmp draw_bmp_48x2_generic

draw_bmp_48x2_generic
	sta bmp_index ; Store bitmap index (0-3)

	; Set up pointers based on bitmap index
	lda bmp_index
	asl
	tay
	lda bmp_colors_table,y
	sta aux5+0
	lda bmp_colors_table+1,y
	sta aux5+1

	; Calculate color pointer with window offset
	lda bmp_index
	asl
	tay
	lda bmp_height_table,y
	sec
	sbc bmp_window_table,y  ; height - window
	clc
	adc aux5+0
	sta aux5+0
	lda aux5+1
	adc #0
	sta aux5+1

        ldy #11
bmp_generic_pointersetup
        lda bmp_index
        asl
        tax
        lda bmp_values_table,x
        sta scorepointers,y
        lda bmp_values_table+1,x
        sta scorepointers+1,y

        ; Adjust for window
        lda bmp_index
        asl
        tax
        lda bmp_height_table,x
        sec
        sbc bmp_window_table,x
        clc
        adc bmp_values_table,x
        sta scorepointers,y
        lda bmp_values_table+1,x
        adc #0
        sta scorepointers+1,y

        dey
        dey
        bpl bmp_generic_pointersetup

	; Use runtime window variable
	lda bmp_index
	asl
	tay
	lda bmp_window_table,y
	tay
	dey
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

; Tables of pointers for each bitmap set
bmp_colors_table
	.word bmp_48x2_0_colors
	.word bmp_48x2_1_colors
	.word bmp_48x2_2_colors
	.word bmp_48x2_3_colors

bmp_values_table
	.word bmp_48x2_0_values
	.word bmp_48x2_1_values
	.word bmp_48x2_2_values
	.word bmp_48x2_3_values

bmp_height_table
	.byte bmp_48x2_0_height
	.byte bmp_48x2_1_height
	.byte bmp_48x2_2_height
	.byte bmp_48x2_3_height

bmp_window_table
	.byte bmp_48x2_0_window
	.byte bmp_48x2_1_window
	.byte bmp_48x2_2_window
	.byte bmp_48x2_3_window
