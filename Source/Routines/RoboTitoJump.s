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
          lda temp1
          asl
          tax
          lda playerState,x
          and # 4
          bne RTJ_CheckSpecialAbility
          jmp RTJ_CannotStretch

RTJ_CheckSpecialAbility:
          ;; if characterSpecialAbility_R[temp1] = 0 then goto RoboTitoCannotStretch
          lda temp1
          asl
          tax
          lda characterSpecialAbility_R,x
          bne RTJ_CanStretch
          jmp RTJ_CannotStretch

RTJ_CanStretch:
          jmp RoboTitoStretching

.pend

RTJ_CannotStretch .proc
          ;; Alias for RoboTitoCannotStretch
          jmp RoboTitoCannotStretch

.pend

RoboTitoCannotStretch .proc
          lda temp1
          asl
          tax
          lda # 0
          sta missileStretchHeight_W,x
          jsr BS_return

.pend

RTJ_CanStretchProc .proc
          ;; Alias for RoboTitoCanStretch
          jmp RoboTitoCanStretch

.pend

RoboTitoCanStretch .proc
          ;; Stretch enabled - proceed with stretching
          jmp RoboTitoStretching

.pend

RoboTitoStretching .proc
          ;; playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          lda temp1
          asl
          tax
          lda playerState,x
          and # MaskPlayerStateFlags
          ora # ActionJumpingShifted
          sta playerState,x
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
          lda # >(AfterPlayfieldReadStretch-1)
          pha
          lda # <(AfterPlayfieldReadStretch-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadStretch:

          ;; if temp1 then temp6 = 1
          lda temp1
          beq CheckGroundFound
          lda # 1
          sta temp6
CheckGroundFound:
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
          ;; temp2 = temp5 * 16 (row to pixel position)
          lda temp5
          asl
          asl
          asl
          asl
          sta temp2

.pend

GroundSearchBottom .proc
          lda ScreenBottom
          sta temp2

GroundSearchDone:
          ;; Common exit point for GroundFound and GroundSearchBottom
          ;; Continue with rest of routine
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

          ;; if temp3 < 1 then temp3 = 1
          lda temp3
          cmp # 1
          bcs SetStretchHeight
          lda # 1
          sta temp3
SetStretchHeight:


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
          lda temp1
          asl
          tax
          lda playerY,x
          cmp # 5
          bcs RTJ_Continue
          jmp RoboTitoCheckCeiling
RTJ_Continue:
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
          lda # >(AfterPlayfieldReadCeiling-1)
          pha
          lda # <(AfterPlayfieldReadCeiling-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadCeiling:

          ;; if temp1 then goto RoboTitoLatch
          lda temp1
          beq ContinueStretching
          jmp RoboTitoLatch
ContinueStretching:
          lda temp5
          sta temp1
          ;; playerY[temp1] = playerY[temp1] - 3
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc # 3
          sta playerY,x
          jsr BS_return
.pend

RoboTitoLatch .proc
          ;; RTL_stateFlags = characterStateFlags_R[temp1] | 1
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          ora # 1
          sta characterStateFlags_W,x
          ;; playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          lda temp1
          asl
          tax
          lda playerState,x
          and # MaskPlayerStateFlags
          ora # ActionJumpingShifted
          sta playerState,x
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

RTL_ReduceHeight:
          ;; temp2 = temp2 - 25
          lda temp2
          sec
          sbc # 25
          sta temp2

          lda temp1
          asl
          tax
          lda temp2
          sta missileStretchHeight_W,x

RTL_HeightCleared:
          jsr BS_return

.pend

