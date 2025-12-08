;;;; The batari Basic score kernel
;;;; This minikernel is not under the same license as the rest of the 
;;;; titlescreen code. Refer to the bB license before you use this in
;;;; a non-bB program.

;;;; macro.h is already included via MultiSpriteSuperChip.s in Preamble.s

draw_score_display:

          lax score+0
          jsr miniscorepointerset
          sty scorepointers+8 
          stx scorepointers+0
          ;; lax score+1 (duplicate)
          ;; jsr miniscorepointerset (duplicate)
          ;; sty scorepointers+4 (duplicate)
          ;; stx scorepointers+6 (duplicate)
          ;; lax score+2 (duplicate)
          ;; jsr miniscorepointerset (duplicate)
          ;; sty scorepointers+10 (duplicate)
          ;; stx scorepointers+2 (duplicate)

          sta HMCLR
          tsx
          ;; stx sta (duplicate)

 ;;ldx #$20
          ldx #$60
          ;; stx HMP0 (duplicate)

          ;; ldx # 0 (duplicate)
          ;; sta WSYNC ;;;   0 (duplicate)
          ;; stx GRP0  ;;; 3 3 (duplicate)
          ;; stx GRP1  ;;; 3 6 seems to be needed because of vdel (duplicate)

          .SLEEP 7   ;;; 7 13

          lda # >SetFontNumbers   ;;; 2 15  ; Use SetFontNumbers from Numbers.bas
          ;; sta scorepointers+1,x  ;;; 4 19 (duplicate)
          ;; sta scorepointers+3,x  ;;; 4 23 (duplicate)
          ;; sta scorepointers+5,x  ;;; 4 27 (duplicate)
          ;; sta scorepointers+7,x  ;;; 4 31 (duplicate)
          ;; sta scorepointers+9,x  ;;; 4 35 (duplicate)
          ;; sta scorepointers+11,x ;;; 4 39 (duplicate)

          ldy # 7		;;; 2 41
          ;; sta RESP0	;;; 3 44 (duplicate)
          ;; sta RESP1	;;; 3 47 (duplicate)

          ;; lda #$03	;;; 2 49 (duplicate)
          ;; sta NUSIZ0 	;;; 3 52 (duplicate)
          ;; sta NUSIZ1,x	;;; 4 56 (duplicate)
          ;; sta VDELP0	;;; 3 59 (duplicate)
          ;; sta VDELP1	;;; 3 62 (duplicate)
       ;;LDA #$30		; 2 64
          ;; lda #$70		;;; 2 64 (duplicate)
          ;; sta HMP1		;;; 3 67 (duplicate)
          ;; lda scorecolor	;;; 3 70 (duplicate)
          ;; sta HMOVE 	;;; cycle 73 ? (duplicate)
          .if  score_kernel_fade
          and score_kernel_fade
          .fi

          ;; sta COLUP0 (duplicate)
          ;; sta COLUP1 (duplicate)
          .if  scorefade
          ;; sta stack2 ;;; scorefade (duplicate)
          .fi
          ;; lda  (scorepointers),y (duplicate)
          ;; sta  GRP0 (duplicate)
          ;; lda  (scorepointers+8),y (duplicate)
          ;; sta WSYNC (duplicate)
          .SLEEP 2
          jmp beginscoreloop

          .if ((<*)>$28)
          .align 256 ;;; kludge that potentially wastes space!  should be fixed!
          .fi

scoreloop2:
          .if  scorefade
          ;; lda sta (duplicate)

          ;; sta COLUP0 (duplicate)
          ;; sta COLUP1 (duplicate)
          .else
          .SLEEP 9
          .fi
          ;; lda  (scorepointers),y     ;;;+5  68  204 (duplicate)
          ;; sta  GRP0            ;;;+3  71  213      D1     --      --     -- (duplicate)
          ;; lda  (scorepointers+$8),y  ;;;+5   5   15 (duplicate)
 ;; cycle 0
beginscoreloop:
          ;; sta  GRP1            ;;;+3   8   24      D1     D1      D2     -- (duplicate)
          ;; lda  (scorepointers+$6),y  ;;;+5  13   39 (duplicate)
          ;; sta  GRP0            ;;;+3  16   48      D3     D1      D2     D2 (duplicate)
          ;; lax  (scorepointers+$2),y  ;;;+5  29   87 (duplicate)
          txs
          ;; lax  (scorepointers+$4),y  ;;;+5  36  108 (duplicate)

          .if  scorefade
          dec sta

          .else
          .SLEEP 5
          .fi
          .SLEEP 2

          ;; lda  (scorepointers+$A),y  ;;;+5  21   63 DIGIT 6 (duplicate)
          ;; stx  GRP1            ;;;+3  44  132      D3     D3      D4     D2! (duplicate)
          ;; tsx (duplicate)
          ;; stx  GRP0            ;;;+3  47  141      D5     D3!     D4     D4 (duplicate)
          ;; sta  GRP1            ;;;+3  50  150      D5     D5      D6     D4! (duplicate)

          ;; sty  GRP0            ;;;+3  53  159      D4*    D5!     D6     D6 (duplicate)
          dey
          bpl  scoreloop2           ;;;+2  60  180
scoreloop2end:

 ;;.error "critical size: ",(scoreloop2end-scoreloop2)


          ;; ldx sta (duplicate)

          ;; txs (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta PF1 (duplicate)
          ;; sta GRP0 (duplicate)
          ;; sta GRP1 (duplicate)
          ;; sta VDELP0 (duplicate)
          ;; sta VDELP1 (duplicate)
          ;; sta NUSIZ0 (duplicate)
          ;; sta NUSIZ1 (duplicate)

 ;; clear out the score pointers in case they’re stolen DPC variables...
          ;; ldx # 11 (duplicate)
clearscoreploop:
          ;; sta scorepointers,x (duplicate)
          dex
          ;; bpl clearscoreploop (duplicate)


 ;;;ldy temp3
 ;;ldy scorepointers+8
 ;;sty scorepointers+3

 ;;;ldy temp5
 ;;ldy scorepointers+10
 ;;sty scorepointers+5
          rts

miniscorepointerset:
          ;; and #$0F (duplicate)
          asl
          ;; asl (duplicate)
          ;; asl (duplicate)
          adc # <SetFontNumbers   ;;; Use SetFontNumbers from Numbers.bas
          tay
          txa
          ;; and #$F0 (duplicate)
          lsr
          ;; adc # <SetFontNumbers   ;;; Use SetFontNumbers from Numbers.bas (duplicate)
          tax
          ;; rts (duplicate)

