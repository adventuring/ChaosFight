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

          if (playerState[temp1] & 4) then goto RoboTitoCannotStretch
          ;; if characterSpecialAbility_R[temp1] = 0 then goto RoboTitoCannotStretch
          lda temp1
          asl
          tax
          lda characterSpecialAbility_R,x
          bne RoboTitoCanStretch

          jmp RoboTitoCannotStretch

RoboTitoCanStretch:

          jmp RoboTitoStretching

.pend

RoboTitoCannotStretch .proc
          lda temp1
          asl
          tax
          lda # 0
          sta missileStretchHeight_W,x
          jsr BS_return

.pend

RoboTitoCanStretch .proc
.pend

RoboTitoStretching .proc
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          ;; Inlined CCJ_ConvertPlayerXToPlayfieldColumn (FIXME #1250)
          ;; Convert player X to playfield column: (playerX[temp1] - ScreenInsetX) / 4
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2
          lda temp2
          lsr
          lsr
          sta temp2

          lda temp2
          sta temp4
          ;; let temp2 = playerY[temp1] + 16         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2
          ;; let temp5 = temp2 / 16

.pend

GroundSearchLoop .proc
          ;; if temp5 >= pfrows then goto GroundSearchBottom
          lda temp5
          cmp # pfrows

          bcc CheckPlayfieldPixel

          jmp GroundSearchBottom

CheckPlayfieldPixel:
          lda # 0
          sta temp6
          lda temp1
          sta temp3
          lda temp4
          sta temp1
          lda temp5
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:

                    if temp1 then let temp6 = 1          lda temp1          beq CheckGroundFound
CheckGroundFound:
          jmp CheckGroundFound
          lda temp3
          sta temp1
          lda temp6
          cmp # 1
          bne ContinueGroundSearch
          jmp GroundFound
ContinueGroundSearch:

          inc temp5
          jmp GroundSearchLoop

.pend

GroundFound .proc
          ;; let temp2 = temp5 / 16
          jmp GroundSearchDone

.pend

GroundSearchBottom .proc
          lda ScreenBottom
          sta temp2

GroundSearchDone
          ;; let temp3 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3
          ;; let temp3 = temp3 - temp2          lda temp3          sec          sbc temp2          sta temp3
          lda temp3
          sec
          sbc temp2
          sta temp3

          lda temp3
          sec
          sbc temp2
          sta temp3

          lda temp3
          cmp # 81
          bcc CheckMinimumHeight
          lda # 80
          sta temp3
CheckMinimumHeight:

          ;; if temp3 < 1 then let temp3 = 1
          lda temp3
          cmp # 1
          bcs SetStretchHeight
          jmp let_label
SetStretchHeight:

          lda temp3
          cmp # 1
          bcs SetStretchHeightLabel
          jmp let_label
SetStretchHeightLabel:


          lda temp1
          asl
          tax
          lda temp3
          sta missileStretchHeight_W,x
          lda temp1
          asl
          tax
          lda 0
          sta characterSpecialAbility_W,x
          ;; if playerY[temp1] <= 5 then goto RoboTitoCheckCeiling
                    let playerY[temp1] = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          lda temp1
          asl
          tax
          sta playerY,x - 3
          jsr BS_return
.pend

RoboTitoCheckCeiling .proc
          ;; Inlined CCJ_ConvertPlayerXToPlayfieldColumn (FIXME #1250)
          ;; Convert player X to playfield column: (playerX[temp1] - ScreenInsetX) / 4
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2
          lda temp2
          lsr
          lsr
          sta temp2

          ;; let temp3 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3
          ;; if temp3 <= 0 then goto RoboTitoLatch
          ;; let temp4 = temp3 / 16
          lda temp3
          lsr
          lsr
          lsr
          lsr
          sta temp4
          ;; if temp4 <= 0 then goto RoboTitoLatch
          lda temp4
          beq RoboTitoLatch
          bmi RoboTitoLatch
          jmp CheckCeilingPixel
RoboTitoLatch:
CheckCeilingPixel:
          dec temp4
          lda temp1
          sta temp5
          lda temp2
          sta temp1
          lda temp4
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:

          ;; if temp1 then goto RoboTitoLatch
          lda temp1
          beq ContinueStretching
          jmp RoboTitoLatch
ContinueStretching:
          lda temp5
          sta temp1
                    let playerY[temp1] = playerY[temp1] - 3
          jsr BS_return
.pend

RoboTitoLatch .proc
          dim RTL_stateFlags = temp5 (dim removed - variable definitions handled elsewhere)
                    let RTL_stateFlags = characterStateFlags_R[temp1] | 1         
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          sta RTL_stateFlags
          lda temp1
          asl
          tax
          lda RTL_stateFlags
          sta characterStateFlags_W,x
                    let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          ;; let temp2 = missileStretchHeight_R[temp1]         
          lda temp1
          asl
          tax
          lda missileStretchHeight_R,x
          sta temp2
          ;; if temp2 <= 0 then goto RTL_HeightCleared
          lda temp2
          cmp # 26
          bcc RTL_ReduceHeight
          jmp RTL_HeightCleared
RTL_ReduceHeight:

          lda temp1
          asl
          tax
          lda 0
          sta missileStretchHeight_W,x
          jmp RTL_HeightCleared
.pend (no matching .proc)

RTL_ReduceHeight .proc
          ;; let temp2 = temp2 - 25          lda temp2          sec          sbc 25          sta temp2
          lda temp2
          sec
          sbc 25
          sta temp2

          lda temp2
          sec
          sbc 25
          sta temp2

          lda temp1
          asl
          tax
          lda temp2
          sta missileStretchHeight_W,x
.pend

;; RTL_HeightCleared .proc (no matching .pend)
          jsr BS_return


.pend (extra - no matching .proc)

