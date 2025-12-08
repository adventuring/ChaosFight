;;; ChaosFight - Source/Routines/RoboTitoJump.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
          ;;
;;; Robo Tito stretch-and-latch jump routine relocated from Bank 12
;;; to Bank 10 to relieve pressure on CharacterControlsJump.


RoboTitoJump .proc
          ;; ROBO TITO (13) - Stretch to ceiling
          ;; Input: temp1 = player index
          ;; Output: Moves up 3px/frame, latches on ceiling contact
          jsr BS_return
                    ;; if (playerState[temp1] & 4) then goto RoboTitoCannotStretch
                    ;; if characterSpecialAbility_R[temp1] = 0 then goto RoboTitoCannotStretch
          lda temp1
          asl
          tax
          ;; lda characterSpecialAbility_R,x (duplicate)
          bne skip_2293
          jmp RoboTitoCannotStretch
skip_2293:
          ;; jmp RoboTitoCanStretch (duplicate)

.pend

RoboTitoCannotStretch .proc
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          sta missileStretchHeight_W,x
          ;; jsr BS_return (duplicate)
.pend

RoboTitoCanStretch .proc
.pend

RoboTitoStretching .proc
                    ;; let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          ;; CRITICAL: CCJ_ConvertPlayerXToPlayfieldColumn is in Bank 12, not Bank 13
          ;; Cross-bank call to CCJ_ConvertPlayerXToPlayfieldColumn in bank 12
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CCJ_ConvertPlayerXToPlayfieldColumn-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CCJ_ConvertPlayerXToPlayfieldColumn-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 11
          ;; jmp BS_jsr (duplicate)
return_point:

          ;; lda temp2 (duplicate)
          ;; sta temp4 (duplicate)
                    ;; let temp2 = playerY[temp1] + 16         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp2 (duplicate)
                    ;; let temp5 = temp2 / 16

.pend

GroundSearchLoop .proc
          ;; if temp5 >= pfrows then goto GroundSearchBottom
          ;; lda temp5 (duplicate)
          cmp pfrows

          bcc skip_1208

          ;; jmp skip_1208 (duplicate)

          skip_1208:
          ;; lda # 0 (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp5 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

                    ;; if temp1 then let temp6 = 1          lda temp1          beq skip_8161
skip_8161:
          ;; jmp skip_8161 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp6 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_5697 (duplicate)
          ;; jmp GroundFound (duplicate)
skip_5697:

          inc temp5
          ;; jmp GroundSearchLoop (duplicate)

.pend

GroundFound .proc
                    ;; let temp2 = temp5 / 16
          ;; jmp GroundSearchDone (duplicate)

.pend

GroundSearchBottom .proc
          ;; lda ScreenBottom (duplicate)
          ;; sta temp2 (duplicate)

GroundSearchDone
                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; ;; let temp3 = temp3 - temp2          lda temp3          sec          sbc temp2          sta temp3
          ;; lda temp3 (duplicate)
          sec
          sbc temp2
          ;; sta temp3 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp2 (duplicate)
          ;; sta temp3 (duplicate)

          ;; lda temp3 (duplicate)
          ;; cmp # 81 (duplicate)
          ;; bcc skip_6767 (duplicate)
          ;; lda # 80 (duplicate)
          ;; sta temp3 (duplicate)
skip_6767:

          ;; ;; if temp3 < 1 then let temp3 = 1
          ;; lda temp3 (duplicate)
          ;; cmp # 1 (duplicate)
          bcs skip_9147
          ;; jmp let_label (duplicate)
skip_9147:

          ;; lda temp3 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bcs skip_9194 (duplicate)
          ;; jmp let_label (duplicate)
skip_9194:


          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta missileStretchHeight_W,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta characterSpecialAbility_W,x (duplicate)
                    ;; if playerY[temp1] <= 5 then goto RoboTitoCheckCeiling
                    ;; let playerY[temp1] = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerY,x - 3 (duplicate)
          ;; jsr BS_return (duplicate)
.pend

RoboTitoCheckCeiling .proc
          ;; CRITICAL: CCJ_ConvertPlayerXToPlayfieldColumn is in Bank 12, not Bank 13
          ;; Cross-bank call to CCJ_ConvertPlayerXToPlayfieldColumn in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CCJ_ConvertPlayerXToPlayfieldColumn-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CCJ_ConvertPlayerXToPlayfieldColumn-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
                    ;; if temp3 <= 0 then goto RoboTitoLatch
                    ;; let temp4 = temp3 / 16
          ;; lda temp3 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp4 (duplicate)
                    ;; if temp4 <= 0 then goto RoboTitoLatch
          ;; lda temp4 (duplicate)
          beq RoboTitoLatch
          bmi RoboTitoLatch
          ;; jmp skip_6419 (duplicate)
RoboTitoLatch:
skip_6419:
          dec temp4
          ;; lda temp1 (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

                    ;; if temp1 then goto RoboTitoLatch
          ;; lda temp1 (duplicate)
          ;; beq skip_4515 (duplicate)
          ;; jmp RoboTitoLatch (duplicate)
skip_4515:
          ;; lda temp5 (duplicate)
          ;; sta temp1 (duplicate)
                    ;; let playerY[temp1] = playerY[temp1] - 3
          ;; jsr BS_return (duplicate)
.pend

;; RoboTitoLatch .proc (duplicate)
          ;; dim RTL_stateFlags = temp5 (dim removed - variable definitions handled elsewhere)
                    ;; let RTL_stateFlags = characterStateFlags_R[temp1] | 1         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterStateFlags_R,x (duplicate)
          ;; sta RTL_stateFlags (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda RTL_stateFlags (duplicate)
          ;; sta characterStateFlags_W,x (duplicate)
                    ;; let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
                    ;; let temp2 = missileStretchHeight_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileStretchHeight_R,x (duplicate)
          ;; sta temp2 (duplicate)
                    ;; if temp2 <= 0 then goto RTL_HeightCleared
          ;; lda temp2 (duplicate)
          ;; cmp # 26 (duplicate)
          ;; bcc skip_4784 (duplicate)
skip_4784:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta missileStretchHeight_W,x (duplicate)
          ;; jmp RTL_HeightCleared (duplicate)
;; .pend (no matching .proc)

RTL_ReduceHeight .proc
          ;; ;; let temp2 = temp2 - 25          lda temp2          sec          sbc 25          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc 25 (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc 25 (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta missileStretchHeight_W,x (duplicate)
.pend

;; RTL_HeightCleared .proc (no matching .pend)
          ;; jsr BS_return (duplicate)


;; .pend (extra - no matching .proc)

