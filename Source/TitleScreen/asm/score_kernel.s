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
          lax score+1
          jsr miniscorepointerset
          sty scorepointers+4
          stx scorepointers+6
          lax score+2
          jsr miniscorepointerset
          sty scorepointers+10
          stx scorepointers+2

          sta HMCLR
          tsx
          stx aux6  ;;; Save stack pointer (use aux6, not temp6 which gets modified)

 ;;ldx #$20
          ldx #$60
          stx HMP0

          ldx # 0
          sta WSYNC ;;;   0
          stx GRP0  ;;; 3 3
          stx GRP1  ;;; 3 6 seems to be needed because of vdel

          .SLEEP 7   ;;; 7 13

          lda # >SetFontNumbers   ;;; 2 15  ; Use SetFontNumbers from Numbers.bas
          sta scorepointers+1,x  ;;; 4 19
          sta scorepointers+3,x  ;;; 4 23
          sta scorepointers+5,x  ;;; 4 27
          sta scorepointers+7,x  ;;; 4 31
          sta scorepointers+9,x  ;;; 4 35
          sta scorepointers+11,x ;;; 4 39

          ldy # 7		;;; 2 41
          sta RESP0	;;; 3 44
          sta RESP1	;;; 3 47

          lda #$03	;;; 2 49
          sta NUSIZ0 	;;; 3 52
          sta NUSIZ1,x	;;; 4 56
          sta VDELP0	;;; 3 59
          sta VDELP1	;;; 3 62
       ;;LDA #$30		; 2 64
          lda #$70		;;; 2 64
          sta HMP1		;;; 3 67
          lda scorecolor	;;; 3 70
          sta HMOVE 	;;; cycle 73 ?
          .if  score_kernel_fade
          and score_kernel_fade
          .fi

          sta COLUP0
          sta COLUP1
          .if  scorefade
          sta stack2 ;;; scorefade
          .fi
          lda  (scorepointers),y
          sta  GRP0
          lda  (scorepointers+8),y
          sta WSYNC
          .SLEEP 2
          jmp beginscoreloop

          .if ((<*)>$28)
          .align 256 ;;; kludge that potentially wastes space!  should be fixed!
          .fi

scoreloop2:
          .if  scorefade
          lda stack2  ;;; Use stack2 for score fade (defined as scratch variable)
          sta COLUP0
          sta COLUP1
          .else
          .SLEEP 9
          .fi
          lda  (scorepointers),y     ;;;+5  68  204
          sta  GRP0            ;;;+3  71  213      D1     --      --     --
          lda  (scorepointers+$8),y  ;;;+5   5   15
 ;; cycle 0
beginscoreloop:
          sta  GRP1            ;;;+3   8   24      D1     D1      D2     --
          lda  (scorepointers+$6),y  ;;;+5  13   39
          sta  GRP0            ;;;+3  16   48      D3     D1      D2     D2
          lax  (scorepointers+$2),y  ;;;+5  29   87
          txs
          lax  (scorepointers+$4),y  ;;;+5  36  108

          .if  scorefade
          dec stack2  ;;; Decrement fade value (use stack2, not temp6 which holds saved SP)
          .else
          .SLEEP 5
          .fi
          .SLEEP 2

          lda  (scorepointers+$A),y  ;;;+5  21   63 DIGIT 6
          stx  GRP1            ;;;+3  44  132      D3     D3      D4     D2!
          tsx
          stx  GRP0            ;;;+3  47  141      D5     D3!     D4     D4
          sta  GRP1            ;;;+3  50  150      D5     D5      D6     D4!

          sty  GRP0            ;;;+3  53  159      D4*    D5!     D6     D6
          dey
          bpl  scoreloop2           ;;;+2  60  180
scoreloop2end:

 ;;.error "critical size: ",(scoreloop2end-scoreloop2)


          ldx aux6  ;;; Restore stack pointer from aux6 (not temp6 which was corrupted)

          txs

          lda # 0
          sta PF1
          sta GRP0
          sta GRP1
          sta VDELP0
          sta VDELP1
          sta NUSIZ0
          sta NUSIZ1

 ;; clear out the score pointers in case they’re stolen DPC variables...
          ldx # 11
clearscoreploop:
          sta scorepointers,x
          dex
          bpl clearscoreploop


 ;;;ldy temp3
 ;;ldy scorepointers+8
 ;;sty scorepointers+3

 ;;;ldy temp5
 ;;ldy scorepointers+10
 ;;sty scorepointers+5
          rts

miniscorepointerset:
          and #$0F
          asl
          asl
          asl
          adc # <SetFontNumbers   ;;; Use SetFontNumbers from Numbers.bas
          tay
          txa
          and #$F0
          lsr
          adc # <SetFontNumbers   ;;; Use SetFontNumbers from Numbers.bas
          tax
          rts

