;;; ChaosFight - Source/Routines/CharacterControls.bas
;;; Copyright © 2025 Bruce-Robert Pocock
;;; :
;;; Character jump velocity lookup table (for StandardJump)
;;; Values are 8-bit twos complement upward velocities
          ;; 0 = special jump (use character-specific function)
          ;; Non-zero = standard jump velocity
CharacterJumpVelocities:
          .byte 0, 254, 0, 244, 248, 254, 0, 248, 0, 254, 243, 248, 243, 0, 248, 245, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 245


StandardJump .proc
          ;; Shared standard jump with velocity lookup
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: Upward velocity applied, jumping flag set
          ;; Set temp2 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp2
          ;; Set temp2 = CharacterJumpVelocities[temp2]
          lda temp2
          asl
          tax
          lda CharacterJumpVelocities,x
          sta temp2
          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; let playerState[temp1] = playerState[temp1] | 4
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 4
          sta playerState,x
          jmp BS_return

.pend

;; CCJ_ConvertPlayerXToPlayfieldColumn has been inlined at all call sites (FIXME #1250)
;; The inlined code is: (playerX[temp1] - ScreenInsetX) / 4 -> temp2

BernieJump .proc
          ;; BERNIE (0) - Drop through single-row platforms
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: playerY[] updated when falling through
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
          lda temp3
          clc
          adc # 16
          sta temp5
          ;; Set temp6 = temp5 / 16
          lda # 0
          sta temp4
          lda temp1
          sta temp3
          lda temp2
          sta temp1
          lda temp6
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadFirst-1)
          pha
          lda # <(AfterPlayfieldReadFirst-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadFirst:


          ;; If temp1, set temp4 = 1
          lda temp1
          beq BernieCheckBottomWrapFirst
          lda # 1
          sta temp4
BernieCheckBottomWrapFirst:
          lda temp3
          sta temp1
          jmp BS_return

          ;; If temp6 >= pfrows - 1, then jmp BernieCheckBottomWrap
          lda temp6
          clc
          adc # 1
          sta temp4
          lda # 0
          sta temp5
          lda temp1
          sta temp3
          lda temp2
          sta temp1
          lda temp4
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadSecond-1)
          pha
          lda # <(AfterPlayfieldReadSecond-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadSecond:


          ;; If temp1, set temp5 = 1
          lda temp1
          beq BernieCheckBottomWrapSecond
          lda # 1
          sta temp5
BernieCheckBottomWrapSecond:
          lda temp3
          sta temp1
          jmp BS_return

          ;; let playerY[temp1] = playerY[temp1] + 1
          lda temp1
          asl
          tax
          inc playerY,x

          lda temp1
          asl
          tax
          inc playerY,x

          jmp BS_return

.pend

BernieCheckBottomWrap .proc
          ;; Helper: Wrap Bernie to top row if clear
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index, temp2 = playfield column
          lda # 0
          sta temp4
          lda # 0
          sta temp5
          lda temp1
          sta temp3
          lda temp2
          sta temp1
          lda temp4
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadFreeFlightUp1-1)
          pha
          lda # <(AfterPlayfieldReadFreeFlightUp1-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadFreeFlightUp1:


                    if temp1 then let temp5 = 1          lda temp1          beq BernieCheckBottomWrapFreeFlight1
BernieCheckBottomWrapFreeFlight1:
          jmp BernieCheckBottomWrapFreeFlight1
          lda temp3
          sta temp1
          jmp BS_return

          lda temp1
          asl
          tax
          lda 0
          sta playerY,x
          jmp BS_return

.pend

CCJ_FreeFlightUp .proc
          ;; Shared free flight upward movement (DragonOfStorms, Frooty)
          ;; Calling Convention: Near
          ;; Input: temp1 = player index, temp2 = playfield column (inlined from CCJ_ConvertPlayerXToPlayfieldColumn)
          ;; Output: Upward velocity applied if clear above, jumping flag set
          ;; Mutates: temp3-temp6, playerVelocityY[], playerVelocityYL[], playerState[]
          ;; Set temp3 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3
          ;; Set temp4 = temp3 / 16
          lda temp3
          lsr
          lsr
          lsr
          lsr
          sta temp4
          dec temp4
          lda # 0
          sta temp5
          lda temp1
          sta temp6
          lda temp2
          sta temp1
          lda temp4
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadFreeFlightUp2-1)
          pha
          lda # <(AfterPlayfieldReadFreeFlightUp2-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadFreeFlightUp2:

          ;; If temp1, set temp5 = 1
          lda temp1
          beq BernieCheckBottomWrapFreeFlight2
          lda # 1
          sta temp5
BernieCheckBottomWrapFreeFlight2:
          lda temp6
          sta temp1
          lda temp1
          asl
          tax
          lda # 254
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; let playerState[temp1] = playerState[temp1] | 4
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 4
          sta playerState,x
          rts

.pend

DragonOfStormsJump .proc
          ;; Returns: Far (return otherbank)
          jmp CCJ_FreeFlightCharacterJump
          ;; ZOE RYEN (3) - STANDARD JUMP (dispatched directly to StandardJump)
          ;; Returns: Far (return otherbank)
          ;; FAT TONY (4) - STANDARD JUMP (dispatched directly to StandardJump)

.pend

HarpyJump .proc

          ;; HARPY (6) - FLAP TO FLY
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: Upward velocity if energy available and cooldown expired
          jmp BS_return

          ;; Set temp2 = frame - harpyLastFlapFrame_R[temp1]
          lda frame
          sec
          sbc harpyLastFlapFrame_R
          sta temp2

          lda frame
          sec
          sbc harpyLastFlapFrame_R
          sta temp2

          lda temp2
          cmp # 128
          bcc CheckCooldownExpired
          lda # 127
          sta temp2
CheckCooldownExpired:

          jmp BS_return

          ;; If playerY[temp1] <= 5, then jmp HarpyFlapRecord
          lda temp1
          asl
          tax
          lda 254
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; let playerState[temp1] = playerState[temp1] | 4
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 4
          sta playerState,x
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          ora # 2                    ; Set bit 1
          sta characterStateFlags_W,x

.pend

HarpyFlapRecord .proc
          ;; Returns: Far (return otherbank)
                    if characterSpecialAbility_R[temp1] > 0 then let characterSpecialAbility_W[temp1] = characterSpecialAbility_R[temp1] - 1
          lda temp1
          asl
          tax
          lda frame
          sta harpyLastFlapFrame_W,x
          jmp BS_return

.pend

FrootyJump .proc
.pend

CCJ_FreeFlightCharacterJump .proc
          ;; Shared free-flight jump for DragonOfStorms (2) and Frooty (8)
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: Upward velocity if clear above
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

          jsr CCJ_FreeFlightUp

          jmp BS_return

.pend

