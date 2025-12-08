;;;; The player minikernel - display 2 different players, 1 line resolution

draw_player_display:

          jsr TSpositionp0p1

save_variables:
          lda player0y
          sta temp2
          ;; lda player1y (duplicate)
          ;; sta temp3 (duplicate)

init_variables:
          ;; lda # (bmp_player_window+1) (duplicate)
          ;; sta temp1 ;;; our line count (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta VDELP0 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta GRP1 (duplicate)
          ;; sta GRP0 (duplicate)
          ;; lda bmp_player0_refp (duplicate)
          ;; sta REFP0 (duplicate)
          ;; lda bmp_player1_refp (duplicate)
          ;; sta REFP1 (duplicate)
          ;; lda bmp_player0_nusiz (duplicate)
          ;; sta NUSIZ0 (duplicate)
          ;; lda bmp_player1_nusiz (duplicate)
          ;; sta NUSIZ1 (duplicate)
          ;; lda # (bmp_player0_height-1) (duplicate)
          ;; sta player0height (duplicate)
          ;; lda # (bmp_player1_height-1) (duplicate)
          ;; sta player1height (duplicate)

          ;; lda # <bmp_player0 (duplicate)
          .if  bmp_player0_index
          clc
          adc bmp_player0_index
          .fi
          ;; sta player0pointer (duplicate)
          ;; lda # >bmp_player0 (duplicate)
          .if  bmp_player0_index
          ;; adc # 0 (duplicate)
          .fi
          ;; sta player0pointer+1 (duplicate)

          ;; lda # <bmp_color_player0 (duplicate)
          .if  bmp_player0_index
          ;; clc (duplicate)
          ;; adc bmp_player0_index (duplicate)
          .fi
          ;; sta player0color (duplicate)
          ;; lda # >bmp_color_player0 (duplicate)
          .if  bmp_player0_index
          ;; adc # 0 (duplicate)
          .fi
          ;; sta player0color+1 (duplicate)


          ;; lda # <bmp_player1 (duplicate)
          .if  bmp_player1_index
          ;; clc (duplicate)
          ;; adc bmp_player1_index (duplicate)
          .fi
          ;; sta player1pointer (duplicate)
          ;; lda # >bmp_player1 (duplicate)
          .if  bmp_player1_index
          ;; adc # 0 (duplicate)
          .fi
          ;; sta player1pointer+1 (duplicate)

          ;; lda # <bmp_color_player1 (duplicate)
          .if  bmp_player1_index
          ;; clc (duplicate)
          ;; adc bmp_player1_index (duplicate)
          .fi
          ;; sta player1color (duplicate)
          ;; lda # >bmp_color_player1 (duplicate)
          .if  bmp_player1_index
          ;; adc # 0 (duplicate)
          .fi
          ;; sta player1color+1 (duplicate)

          ;; lda # bmp_player_kernellines (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda # 0 (duplicate)

draw_players:
          ;; sta WSYNC (duplicate)
          ;; sta GRP1		;;;3 (duplicate)
          ;; lda (player1color),y	;;;5 (duplicate)
          ;; sta COLUP1		;;;3 (duplicate)
          stx COLUP0		;;;3

          ;; lda player0height	;;;3 (duplicate)
          dcp player0y		;;;5
          bcc skipdrawP0		;;;2/3
          ldy player0y		;;;3
          ;; lda (player0pointer),y	;;;5+ (duplicate)
continueP0:
          ;; sta GRP0		;;;3 (duplicate)

          lax (player0color),y	;;;5+
				;;=29++

          .rept (bmp_player_kernellines-1)
          ;; sta WSYNC (duplicate)
          .next
          ;; lda player1height	;;;3 (duplicate)
          ;; dcp player1y		;;;5 (duplicate)
          ;; bcc skipdrawP1		;;;2/3 (duplicate)
          ;; ldy player1y		;;;3 (duplicate)
          ;; lda (player1pointer),y	;;;5 (duplicate)
continueP1:

          dec temp1		;;;5
          bne draw_players	;;;2/3
          ;; sta WSYNC (duplicate)
          ;; sta GRP1		;;;3 (duplicate)
          ;; sta GRP0		;;;3 (duplicate)
				;;=8
          ;; lda # 0 (duplicate)
          ;; sta GRP0 (duplicate)
          ;; sta GRP1 (duplicate)
          ;; sta REFP0 (duplicate)
          ;; sta REFP1 (duplicate)
          ;; sta VDELP1 (duplicate)

restore_variables:
          ;; lda temp2 (duplicate)
          ;; sta player0y (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta player1y (duplicate)

          rts

skipdrawP0:
          ;; lda # 0		;;;2 (duplicate)
          tay		;;;2
          jmp continueP0	;;;5

skipdrawP1:
          ;; lda # 0		;;;2 (duplicate)
          ;; tay		;;;2 (duplicate)
          ;; jmp continueP1	;;;5 (duplicate)


          .if >. != >(* + $55)
          .align 256
          .fi

TSpositionp0p1:
          ldx # 1
          ;; lda player0x (duplicate)
          ;; sta aux5 (duplicate)
          ;; lda player1x (duplicate)
          ;; sta aux6 (duplicate)
TSpositionp0p1Loop:
          ;; lda aux5,x (duplicate)
          ;; clc (duplicate)
          ;; adc TSadjust,x (duplicate)
          cmp # 161
          ;; bcc TSskipadjust (duplicate)
          sec
          sbc # 160
TSskipadjust:
          ;; sta aux5,x (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta HMCLR       ;;; clear out HMP* (duplicate)
          .SLEEP 2
TSHorPosLoop       ;;;     5
          ;; lda aux5,x  ;;;+4   9 (duplicate)
          ;; sec           ;;;+2  11 (duplicate)
TSDivLoop:
          ;; sbc # 15 (duplicate)
          bcs TSDivLoop;;;+4  15
          ;; sta stack1,x    ;;;+4  19 (duplicate)
          ;; sta RESP0,x   ;;;+4  23 (duplicate)
          ;; sta WSYNC (duplicate)

          ;; ldy stack1,x            ;;;+4 (duplicate)
          ;; lda TSrepostable-256,y  ;;;+4 (duplicate)
          ;; sta HMP0,x              ;;;+4 (duplicate)
                                ;;=12
          ;; ldy # 10 ;;;+2 (duplicate)
wastetimeloop1:
          dey ;;;2
          bpl wastetimeloop1 ;;;3/2
          .SLEEP 2
          ;; sta HMOVE (duplicate)
          dex
          ;; bpl TSpositionp0p1Loop (duplicate)
          ;; rts (duplicate)

          .byte $80,$70,$60,$50,$40,$30,$20,$10,$00
          .byte $F0,$E0,$D0,$C0,$B0,$A0,$90
TSreposta


TSadjust:
          .byte 9,17



