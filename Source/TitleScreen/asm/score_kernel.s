;;;; The batari Basic score kernel
;;;; This minikernel is not under the same license as the rest of the 
;;;; titlescreen code. Refer to the bB license before you use this in
;;;; a non-bB program.

;;;; macro.h is already included via MultiSpriteSuperChip.s in Preamble.s

draw_score_display:

          lax score+0
          jsr miniscorepointerset
          sty scorePointers+8 
          stx scorePointers+0
          lax score+1
          jsr miniscorepointerset
          sty scorePointers+4
          stx scorePointers+6
          lax score+2
          jsr miniscorepointerset
          sty scorePointers+10
          stx scorePointers+2

          sta HMCLR
          tsx
          stx temp7  ;;; Save stack pointer (use temp7, aux6 conflicts with pfScore2/lives at $c2)

 ;;ldx #$20
          ldx #$60
          stx HMP0

          ldx # 0
          sta WSYNC ;;;   0
          stx GRP0  ;;; 3 3
          stx GRP1  ;;; 3 6 seems to be needed because of vdel

          .SLEEP 7   ;;; 7 13

          lda # >SetFontNumbers   ;;; 2 15  ; Use SetFontNumbers from Numbers.bas
          sta scorePointers+1,x  ;;; 4 19
          sta scorePointers+3,x  ;;; 4 23
          sta scorePointers+5,x  ;;; 4 27
          sta scorePointers+7,x  ;;; 4 31
          sta scorePointers+9,x  ;;; 4 35
          sta scorePointers+11,x ;;; 4 39

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
          .if  scoreKernelFade
          and scoreKernelFade
          .fi

          sta COLUP0
          sta COLUP1
          .if  scorefade
          sta aux3 ;;; scorefade (use aux3, NOT stack2 which is in $f0-$ff stack space)
          .fi
          lda  (scorePointers),y
          sta  GRP0
          lda  (scorePointers+8),y
          sta WSYNC
          .SLEEP 2
          jmp beginscoreloop

          .if ((<*)>$28)
          .align 256 ;;; kludge that potentially wastes space!  should be fixed!
          .fi

scoreloop2:
          .if  scorefade
          lda aux3  ;;; Use aux3 for score fade (NOT stack2 which is in $f0-$ff stack space)
          sta COLUP0
          sta COLUP1
          .else
          .SLEEP 9
          .fi
          lda  (scorePointers),y     ;;;+5  68  204
          sta  GRP0            ;;;+3  71  213      D1     --      --     --
          lda  (scorePointers+$8),y  ;;;+5   5   15
 ;; cycle 0
beginscoreloop:
          sta  GRP1            ;;;+3   8   24      D1     D1      D2     --
          lda  (scorePointers+$6),y  ;;;+5  13   39
          sta  GRP0            ;;;+3  16   48      D3     D1      D2     D2
          lax  (scorePointers+$2),y  ;;;+5  29   87
          txs
          lax  (scorePointers+$4),y  ;;;+5  36  108

          .if  scorefade
          dec aux3  ;;; Decrement fade value (use aux3, NOT stack2 which is in $f0-$ff stack space)
          .else
          .SLEEP 5
          .fi
          .SLEEP 2

          lda  (scorePointers+$A),y  ;;;+5  21   63 DIGIT 6
          stx  GRP1            ;;;+3  44  132      D3     D3      D4     D2!
          tsx
          stx  GRP0            ;;;+3  47  141      D5     D3!     D4     D4
          sta  GRP1            ;;;+3  50  150      D5     D5      D6     D4!

          sty  GRP0            ;;;+3  53  159      D4*    D5!     D6     D6
          dey
          bpl  scoreloop2           ;;;+2  60  180
scoreloop2end:

 ;;.error "critical size: ",(scoreloop2end-scoreloop2)


          ldx temp7  ;;; Restore stack pointer from temp7 (aux6 conflicts with pfScore2/lives at $c2)

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
          sta scorePointers,x
          dex
          bpl clearscoreploop


 ;;;ldy temp3
 ;;ldy scorePointers+8
 ;;sty scorePointers+3

 ;;;ldy temp5
 ;;ldy scorePointers+10
 ;;sty scorePointers+5
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

