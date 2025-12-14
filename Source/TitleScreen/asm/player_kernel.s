;;;; The player minikernel - display 2 different players, 1 line resolution

draw_player_display:

          jsr TSpositionp0p1

save_variables:
          lda player0y
          sta temp2
          lda player1y
          sta temp3

init_variables:
          lda # (bmpPlayerWindow+1)
          sta temp1 ;;; our line count
          lda # 1
          sta VDELP0
          lda # 0
          sta GRP1
          sta GRP0
          lda bmpPlayer0Refp
          sta REFP0
          lda bmpPlayer1Refp
          sta REFP1
          lda bmpPlayer0Nusiz
          sta NUSIZ0
          lda bmpPlayer1Nusiz
          sta NUSIZ1
          lda # (bmpPlayer0Height-1)
          sta player0Height
          lda # (bmpPlayer1Height-1)
          sta player1Height

          lda # <bmp_player0
          .if  bmpPlayer0Index
          clc
          adc bmpPlayer0Index
          .fi
          sta player0pointer
          lda # >bmp_player0
          .if  bmpPlayer0Index
          adc # 0
          .fi
          sta player0pointer+1

          lda # <bmp_color_player0
          .if  bmpPlayer0Index
          clc
          adc bmpPlayer0Index
          .fi
          sta player0color
          lda # >bmp_color_player0
          .if  bmpPlayer0Index
          adc # 0
          .fi
          sta player0color+1


          lda # <bmp_player1
          .if  bmpPlayer1Index
          clc
          adc bmpPlayer1Index
          .fi
          sta player1pointer
          lda # >bmp_player1
          .if  bmpPlayer1Index
          adc # 0
          .fi
          sta player1pointer+1

          lda # <bmp_color_player1
          .if  bmpPlayer1Index
          clc
          adc bmpPlayer1Index
          .fi
          sta player1color
          lda # >bmp_color_player1
          .if  bmpPlayer1Index
          adc # 0
          .fi
          sta player1color+1

          lda # bmpPlayerKernellines
          sta temp4
          lda # 0

draw_players:
          sta WSYNC
          sta GRP1		;;;3
          lda (player1color),y	;;;5
          sta COLUP1		;;;3
          stx COLUP0		;;;3

          lda player0Height	;;;3
          dcp player0y		;;;5
          bcc skipdrawP0		;;;2/3
          ldy player0y		;;;3
          lda (player0pointer),y	;;;5+
continueP0:
          sta GRP0		;;;3

          lax (player0color),y	;;;5+
				;;=29++

          .rept (bmpPlayerKernellines-1)
          sta WSYNC
          .next
          lda player1Height	;;;3
          dcp player1y		;;;5
          bcc skipdrawP1		;;;2/3
          ldy player1y		;;;3
          lda (player1pointer),y	;;;5
continueP1:

          dec temp1		;;;5
          bne draw_players	;;;2/3
          sta WSYNC
          sta GRP1		;;;3
          sta GRP0		;;;3
				;;=8
          lda # 0
          sta GRP0
          sta GRP1
          sta REFP0
          sta REFP1
          sta VDELP1

restore_variables:
          lda temp2
          sta player0y
          lda temp3
          sta player1y

          rts

skipdrawP0:
          lda # 0		;;;2
          tay		;;;2
          jmp continueP0	;;;5

skipdrawP1:
          lda # 0		;;;2
          tay		;;;2
          jmp continueP1	;;;5


          .if >. != >(* + $55)
          .align 256
          .fi

TSpositionp0p1:
          ;; CRITICAL: Cannot use aux6 here (used for SP save/restore in draw_bmp_48x2_X)
          ;; Cannot use temp variables (temp1-temp4 used in draw_player_display)
          ;; Use aux4 and aux5 for player X positions (safe scratch variables)
          lda player0x
          sta aux4  ;;; Player 0 X position
          lda player1x
          sta aux5  ;;; Player 1 X position (was aux6, conflicts with SP save/restore)
          
          ldx # 1
TSpositionp0p1Loop:
          ;; Load correct player X position based on X register
          cpx # 1
          beq LoadPlayer1X
          ;; Player 0 (x=0)
          lda aux4
          jmp TSpositionp0p1Continue
LoadPlayer1X:
          ;; Player 1 (x=1)
          lda aux5
TSpositionp0p1Continue:
          clc
          adc TSadjust,x
          cmp # 161
          bcc TSskipadjust
          sec
          sbc # 160
TSskipadjust:
          ;; Store back to correct aux variable
          cpx # 1
          beq StorePlayer1X
          ;; Player 0 (x=0)
          sta aux4
          jmp TSpositionp0p1AfterStore
StorePlayer1X:
          ;; Player 1 (x=1)
          sta aux5
TSpositionp0p1AfterStore:
          sta WSYNC
          sta HMCLR       ;;; clear out HMP*
          .SLEEP 2
TSHorPosLoop       ;;;     5
          ;; Load correct player X position based on X register
          cpx # 1
          beq LoadPlayer1XHorPos
          ;; Player 0 (x=0)
          lda aux4  ;;;+3   8
          jmp TSpositionp0p1HorPosContinue
LoadPlayer1XHorPos:
          ;; Player 1 (x=1)
          lda aux5  ;;;+3   8
TSpositionp0p1HorPosContinue:
          sec           ;;;+2  10 (adjusted timing)
TSDivLoop:
          sbc # 15
          bcs TSDivLoop;;;+4  15
          tay                 ;;;+2  17 (save division result in Y)
          sta RESP0,x   ;;;+4  21
          sta WSYNC

          ;;; Y already contains division result (no need to load from stack1,x)
          lda TSrepostable-256,y  ;;;+4
          sta HMP0,x              ;;;+4
                                ;;=12
          ldy # 10 ;;;+2
wastetimeloop1:
          dey ;;;2
          bpl wastetimeloop1 ;;;3/2
          .SLEEP 2
          sta HMOVE
          dex
          bpl TSpositionp0p1Loop
          rts

          .byte $80,$70,$60,$50,$40,$30,$20,$10,$00
          .byte $F0,$E0,$D0,$C0,$B0,$A0,$90
TSreposta


TSadjust:
          .byte 9,17



