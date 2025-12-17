;;; ChaosFight - Source/Routines/RoboTitoJump.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
          ;;
;;; Robo Tito stretch-and-latch jump routine relocated from Bank 12
;;; to Bank 10 to relieve pressure on CharacterControlsJump.


RoboTitoJump .proc
          ;; ROBO TITO (13) - Stretch to ceiling
          ;; Input: temp1 = player index
          ;; Output: Moves up 3px/frame, latches on ceiling contact
          jmp BS_return

          ;; if (playerState[temp1] & 4) then jmp RoboTitoCannotStretch
          lda temp1
          asl
          tax
          lda playerState,x
          and # 4
          bne RTJ_CheckSpecialAbility
          jmp RTJ_CannotStretch

RTJ_CheckSpecialAbility:
          ;; if characterSpecialAbility_R[temp1] = 0 then jmp RoboTitoCannotStretch
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
          jmp BS_return

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
          ;; Set temp2 = playerY[temp1] + 16
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2
          ;; Set temp5 = temp2 / 16
.pend

GroundSearchLoop .proc
          ;; if temp5 >= pfrows then jmp GroundSearchBottom
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
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 9 ($90) for BS_return to decode
          lda # ((>(AfterPlayfieldReadStretch-1)) & $0f) | $90  ;;; Encode bank 9 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadStretch hi (encoded)]
          lda # <(AfterPlayfieldReadStretch-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadStretch hi (encoded)] [SP+0: AfterPlayfieldReadStretch lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadStretch hi (encoded)] [SP+1: AfterPlayfieldReadStretch lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadStretch hi (encoded)] [SP+2: AfterPlayfieldReadStretch lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
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
          ;; Set temp3 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3
          ;; Set temp3 = temp3 - temp2          lda temp3          sec          sbc temp2          sta temp3
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
          lda # 0
          sta characterSpecialAbility_W,x
          ;; if playerY[temp1] <= 5 then jmp RoboTitoCheckCeiling
          lda temp1
          asl
          tax
          lda playerY,x
          cmp # 5
          bcs RTJ_Continue
          jmp RoboTitoCheckCeiling
RTJ_Continue:
          jmp BS_return
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

          ;; Set temp3 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3
          ;; if temp3 <= 0 then jmp RoboTitoLatch
          ;; Set temp4 = temp3 / 16
          lda temp3
          lsr
          lsr
          lsr
          lsr
          sta temp4
          ;; if temp4 <= 0 then jmp RoboTitoLatch
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
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 9 ($90) for BS_return to decode
          lda # ((>(AfterPlayfieldReadCeiling-1)) & $0f) | $90  ;;; Encode bank 9 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadCeiling hi (encoded)]
          lda # <(AfterPlayfieldReadCeiling-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadCeiling hi (encoded)] [SP+0: AfterPlayfieldReadCeiling lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadCeiling hi (encoded)] [SP+1: AfterPlayfieldReadCeiling lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadCeiling hi (encoded)] [SP+2: AfterPlayfieldReadCeiling lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
          ldx # 15
          jmp BS_jsr
AfterPlayfieldReadCeiling:

          ;; if temp1 then jmp RoboTitoLatch
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
          jmp BS_return
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
          ;; Set temp2 = missileStretchHeight_R[temp1]
          lda temp1
          asl
          tax
          lda missileStretchHeight_R,x
          sta temp2
          ;; if temp2 <= 0 then jmp RTL_HeightCleared
          lda temp2
          cmp # 26
          bcc RTL_ReduceHeightZero
          jmp RTL_HeightCleared
RTL_ReduceHeightZero:

          lda temp1
          asl
          tax
          lda # 0
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
          jmp BS_return

.pend

