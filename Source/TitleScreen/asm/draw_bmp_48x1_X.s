draw_bmp_48x1_X:
	;; 48x1 bitmap display kernel for gameselect minikernel
	;; Displays 6 characters (48 pixels wide) using proper TIA timing
	;; aux2 = number of bitmap rows to display
	;; scorePointers = pointers to bitmap data for each character (6 pointers)
	;; bmpGameselectColor = color for all characters

          ldy aux2
          beq draw_bmp_48x1_X_done

draw_bmp_48x1_X_loop:
          sta WSYNC

	;; Load bitmap data for 6 characters
          lda (scorePointers+0),y
          sta GRP0
          lda (scorePointers+2),y
          sta GRP1
          lda (scorePointers+4),y
          sta GRP0

          lda (scorePointers+6),y
          sta GRP1
          lda (scorePointers+8),y
          sta GRP0
          lda (scorePointers+10),y
          sta GRP1

          dey
          bne draw_bmp_48x1_X_loop

draw_bmp_48x1_X_done:
	;; Clear sprites
          lda # 0
          sta GRP0
          sta GRP1
          rts
