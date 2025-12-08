;;; ChaosFight - Source/TitleScreen/asm/draw_bmp_48x2_X.s
;;; Copyright © 2025 Bruce-Robert Pocock.

draw_bmp_48x2_X .proc
          lda # 0
          sta GRP0
          ;; sta GRP1 (duplicate)

          ;; lda # 7 (duplicate)
          ;; sta NUSIZ0      ;; 7=Triplex (Player drawn three times) (duplicate)
          ;; sta NUSIZ1      ;; 7=Triplex (Player drawn three times) (duplicate)

          tsx
          stx aux6        ;; save the stack pointer

          jsr position48

          ;; lda # 3          ;; 2 cycles (duplicate)
          ;; sta VDELP0      ;; 3 cycles (duplicate)
          ;; sta VDELP1      ;; 3 cycles (duplicate)

          ;; enough cycles have passed for the HMOV, so we can clear HMCLR
          ;; lda # 0 (duplicate)
          ;; sta HMCLR (duplicate)
          ;; sta WSYNC (duplicate)

          .SLEEP 63

          jmp pf48x2_X_loop

          .if >* != >(* + $52)
          .align 256
          .fi

pf48x2_X_loop:

	;; lda (scorepointers+0),y 	;;;5 (duplicate)
	;; sta GRP0			;;3 (duplicate)
	;; lda (scorepointers+2),y 	;;;5 (duplicate)
	;; sta GRP1			;;3 (duplicate)
        ;; lda (scorepointers+4),y         ;;;5 (duplicate)
        ;; sta GRP0                        ;;;3 (duplicate)

        lax (scorepointers+10),y        ;;;5
        ;; lda (scorepointers+8),y         ;;;5 (duplicate)
        ;; sta aux3                        ;;;3 (duplicate)
        ;; lda (scorepointers+6),y         ;;;5 (duplicate)
        ldy aux3                        ;;;3

        ;; sta GRP1                        ;;;3 (duplicate)
        sty GRP0                        ;;;3
        ;; stx GRP1                        ;;;3 (duplicate)
        ;; sty GRP0                        ;;;3 (duplicate)

	;; ldy aux2			;;3 (duplicate)

	;; lda (aux5),y			;;;5 (duplicate)
	;; sta missile0y			;;;3 (duplicate)

	.SLEEP 3

	dec aux2			;;5


	;; lda (scorepointers+0),y 	;;;5 (duplicate)
	;; sta GRP0			;;3 (duplicate)
	;; lda (scorepointers+2),y 	;;;5 (duplicate)
	;; sta GRP1			;;3 (duplicate)
        ;; lda (scorepointers+4),y         ;;;5 (duplicate)
        ;; sta GRP0                        ;;;3 (duplicate)

        ;; lax (scorepointers+10),y        ;;;5 (duplicate)
        ;; lda (scorepointers+8),y         ;;;5 (duplicate)
        ;; sta aux3                        ;;;3 (duplicate)
        ;; lda (scorepointers+6),y         ;;;5 (duplicate)
        ;; ldy aux3                        ;;;3 (duplicate)

        ;; sta GRP1                        ;;;3 (duplicate)
        ;; sty GRP0                        ;;;3 (duplicate)
        ;; stx GRP1                        ;;;3 (duplicate)
        ;; sty GRP0                        ;;;3 (duplicate)

	.SLEEP 4

	;; lda missile0y (duplicate)
	;; sta COLUP1 (duplicate)
	;; sta COLUP0 (duplicate)

	;; ldy aux2			;;3 (duplicate)
	bpl pf48x2_X_loop		;;;2/3


pf48x2_X_codeend:
 ;;.error "critical code in 48x2 is ",(pf48x2_X_codeend-pf48x2_X_loop), " bytes long."

	;; lda # 0 (duplicate)
	;; sta GRP0 (duplicate)
	;; sta GRP1 (duplicate)
	;; sta GRP0 (duplicate)
	;; sta GRP1 (duplicate)
	;; sta VDELP0 (duplicate)
	;; sta VDELP1 (duplicate)

          ldx aux6        ;;restore the stack pointer
          txs
          rts
.pend
