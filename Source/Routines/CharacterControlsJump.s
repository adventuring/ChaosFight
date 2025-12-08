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
                    ;; let temp2 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp2
                    ;; let temp2 = CharacterJumpVelocities[temp2]
          lda temp2
          asl
          tax
          ;; lda CharacterJumpVelocities,x (duplicate)
          sta temp2         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterJumpVelocities,x (duplicate)
          ;; sta temp2 (duplicate)
          jsr BS_return

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] | 4
          ;; jsr BS_return (duplicate)

CCJ_ConvertPlayerXToPlayfieldColumn
;; CCJ_ConvertPlayerXToPlayfieldColumn (duplicate)
          ;; Convert player × to playfield column (0-31)
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: temp2 = playfield column
          ;; FIXME: This should be inlined.
                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          sec
          sbc ScreenInsetX
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          ;; lda temp2 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

BernieJump .proc
          ;; BERNIE (0) - Drop through single-row platforms
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: playerY[] updated when falling through
          ;; CRITICAL: CCJ_ConvertPlayerXToPlayfieldColumn is in Bank 12, use bank12 to match return otherbank
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
          jmp BS_jsr
return_point:


                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp3 (duplicate)
          clc
          adc # 16
          ;; sta temp5 (duplicate)
                    ;; let temp6 = temp5 / 16
          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp6 (duplicate)
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


                    ;; if temp1 then let temp4 = 1          lda temp1          beq skip_5294
skip_5294:
          ;; jmp skip_5294 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr BS_return (duplicate)

                    ;; if temp6 >= pfrows - 1 then goto BernieCheckBottomWrap
          ;; lda temp6 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)
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


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
skip_955:
          ;; jmp skip_955 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr BS_return (duplicate)

          ;; ;; let playerY[temp1] = playerY[temp1] + 1
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          inc playerY,x

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerY,x (duplicate)

          ;; jsr BS_return (duplicate)

.pend

BernieCheckBottomWrap .proc
          ;; Helper: Wrap Bernie to top row if clear
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index, temp2 = playfield column
          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)
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


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
;; skip_955: (duplicate)
          ;; jmp skip_955 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr BS_return (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; jsr BS_return (duplicate)

.pend

CCJ_FreeFlightUp .proc
          ;; Shared free flight upward movement (DragonOfStorms, Frooty)
          ;; Calling Convention: Near
          ;; Input: temp1 = player index, temp2 = playfield column (from CCJ_ConvertPlayerXToPlayfieldColumn)
          ;; Output: Upward velocity applied if clear above, jumping flag set
          ;; Mutates: temp3-temp6, playerVelocityY[], playerVelocityYL[], playerState[]
                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
                    ;; let temp4 = temp3 / 16
          rts

          dec temp4
          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)
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


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
;; skip_955: (duplicate)
          ;; jmp skip_955 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)
          ;; rts (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 254 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] | 4
          ;; rts (duplicate)

DragonOfStormsJump
          ;; Returns: Far (return otherbank)
;; DragonOfStormsJump (duplicate)
          ;; jmp CCJ_FreeFlightCharacterJump (duplicate)
          ;; ZOE RYEN (3) - STANDARD JUMP (dispatched directly to StandardJump)
          ;; Returns: Far (return otherbank)
          ;; FAT TONY (4) - STANDARD JUMP (dispatched directly to StandardJump)

.pend

HarpyJump .proc

          ;; HARPY (6) - FLAP TO FLY
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: Upward velocity if energy available and cooldown expired
          ;; jsr BS_return (duplicate)

          ;; ;; let temp2 = frame - harpyLastFlapFrame_R[temp1]
          ;; lda frame (duplicate)
          ;; sec (duplicate)
          ;; sbc harpyLastFlapFrame_R (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda frame (duplicate)
          ;; sec (duplicate)
          ;; sbc harpyLastFlapFrame_R (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          cmp # 128
          bcc skip_1730
          ;; lda # 127 (duplicate)
          ;; sta temp2 (duplicate)
skip_1730:

          ;; jsr BS_return (duplicate)

                    ;; if playerY[temp1] <= 5 then goto HarpyFlapRecord
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 254 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] | 4
                    ;; let HJ_stateFlags = characterStateFlags_R[temp1] | 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterStateFlags_R,x (duplicate)
          ;; sta HJ_stateFlags (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda HJ_stateFlags (duplicate)
          ;; sta characterStateFlags_W,x (duplicate)

.pend

HarpyFlapRecord .proc
          ;; Returns: Far (return otherbank)
                    ;; if characterSpecialAbility_R[temp1] > 0 then let characterSpecialAbility_W[temp1] = characterSpecialAbility_R[temp1] - 1
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda frame (duplicate)
          ;; sta harpyLastFlapFrame_W,x (duplicate)
          ;; jsr BS_return (duplicate)

.pend

FrootyJump .proc
.pend

CCJ_FreeFlightCharacterJump .proc
          ;; Shared free-flight jump for DragonOfStorms (2) and Frooty (8)
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index
          ;; Output: Upward velocity if clear above
          ;; CRITICAL: CCJ_ConvertPlayerXToPlayfieldColumn is in Bank 12, use bank12 to match return otherbank
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


          ;; jsr CCJ_FreeFlightUp (duplicate)

          ;; jsr BS_return (duplicate)

.pend

