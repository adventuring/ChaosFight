draw_bmp_48x1_X
	; 48x1 bitmap display kernel for gameselect minikernel
	; Displays 6 characters (48 pixels wide) using proper TIA timing
	; aux2 = number of bitmap rows to display
	; scorepointers = pointers to bitmap data for each character (6 pointers)
	; bmp_gameselect_color = color for all characters

          ldy aux2
          beq draw_bmp_48x1_X_done

draw_bmp_48x1_X_loop
          sta WSYNC

	; Load bitmap data for 6 characters
          lda (scorepointers+0),y
          sta GRP0
          lda (scorepointers+2),y
          sta GRP1
          lda (scorepointers+4),y
          sta GRP0

          lda (scorepointers+6),y
          sta GRP1
          lda (scorepointers+8),y
          sta GRP0
          lda (scorepointers+10),y
          sta GRP1

          dey
          bne draw_bmp_48x1_X_loop

draw_bmp_48x1_X_done
	; Clear sprites
          lda #0
          sta GRP0
          sta GRP1
          rts
