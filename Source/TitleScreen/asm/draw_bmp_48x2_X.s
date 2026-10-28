;;; ChaosFight - Source/TitleScreen/asm/draw_bmp_48x2_X.s
;;; Copyright © 2025 Bruce-Robert Pocock.

draw_bmp_48x2_X .proc
          lda # 0
          sta GRP0
          sta GRP1

          lda # 3
          sta NUSIZ0      ;; 3=three copies, 16 pixels apart (the 48x2 kernel needs this)
          sta NUSIZ1      ;; 3=three copies, 16 pixels apart (the 48x2 kernel needs this)

          tsx
          stx spritesort   ;; save the stack pointer (use spritesort instead of temp7 to avoid conflict with BS_return)

          jsr position48

          lda # 0
          sta VDELP0
          sta VDELP1

          ;; enough cycles have passed for the HMOV, so we can clear HMCLR
          lda # 0
          sta HMCLR
          sta WSYNC

          ;; The canonical kernel spends 63 cycles here and then another 6
          ;; cycles on `lda aux4 / sta COLUPF` before falling into the loop.
          ;; aux4 is dead in this port (and aliases preambleTimer), so keep
          ;; its 6 cycles as pure padding: the loop's GRP writes must land
          ;; on the same colour clocks as in the canonical kernel or the
          ;; re-loads of the three copies are misaligned and the bitmap is
          ;; smeared diagonally across the screen.
          .SLEEP 69

          ;; Load color for first row BEFORE loop starts (aux2 pre-initialized by caller)
          ldy aux2
          lda (aux5),y
          sta COLUP0
          sta COLUP1
          sta HMCLR

          jmp pf48x2_X_loop

          .if >* != >(* + $52)
          .align 256
          .fi

pf48x2_X_loop:

        lda (scorePointers+0),y 	;;;5
        sta GRP0			;;3
        lda (scorePointers+2),y 	;;;5
        sta GRP1			;;3
        lda (scorePointers+4),y         ;;;5
        sta GRP0                        ;;;3

        lax (scorePointers+10),y        ;;;5
        lda (scorePointers+8),y         ;;;5
        sta aux3                        ;;;3
        lda (scorePointers+6),y         ;;;5
        ldy aux3                        ;;;3

        sta GRP1                        ;;;3
        sty GRP0                        ;;;3
        stx GRP1                        ;;;3
        sty GRP0                        ;;;3

	ldy aux2			;;3

	.SLEEP 3

        dec aux2                        ;;;5  (next row: count down from titlescreenWindowN)

        lda (scorePointers+0),y 	;;;5
        sta GRP0			;;3
        lda (scorePointers+2),y 	;;;5
        sta GRP1			;;3
        lda (scorePointers+4),y         ;;;5
        sta GRP0                        ;;;3

        lax (scorePointers+10),y        ;;;5
        lda (scorePointers+8),y         ;;;5
        sta aux3                        ;;;3
        lda (scorePointers+6),y         ;;;5
        ldy aux3                        ;;;3

        sta GRP1                        ;;;3
        sty GRP0                        ;;;3
        stx GRP1                        ;;;3
        sty GRP0                        ;;;3

        .SLEEP 4

        ldy aux2                ;;;3  (next row index)
        lda (aux5),y            ;;;5  (load next row's color)
        sta COLUP0              ;;;3  (apply BEFORE next iteration draws)
        sta COLUP1
        sta HMCLR

        bpl pf48x2_X_loop      ; branch while aux2 >= 0


pf48x2_X_codeend:
        ;;.error "critical code in 48x2 is ",(pf48x2_X_codeend-pf48x2_X_loop), " bytes long."

        lda # 0
        sta GRP0
        sta GRP1
        sta GRP0
        sta GRP1
        sta VDELP0
        sta VDELP1

        ;; Clear playfield registers after bitmap drawing to prevent garbage
        ;; on subsequent scanlines or frames (fixes issue #1228)
        sta PF0
        sta PF1
        sta PF2

        ldx spritesort   ;; restore the stack pointer (use spritesort instead of temp7 to avoid conflict with BS_return)
        txs
        rts
.pend
