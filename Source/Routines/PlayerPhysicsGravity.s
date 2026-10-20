;;; ChaosFight - Source/Routines/PlayerPhysicsGravity.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Disable smart branching optimization to prevent label mismatch errors
;;; smartbranching off


PhysicsApplyGravity .block
          lda # 0
          sta temp1
.bend

GravityLoop .block
          ;; Check if player is active (P1/P2 always active, P3/P4 need
          ;; Quadtari)
          ;; if temp1 >= 2 then jmp GravityPlayerCheck
          lda temp1
          cmp # 2
          bcc GravityCheckCharacter
          jmp GravityCheckCharacter
.bend

GravityCheckCharacter .block
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          tax
          lda playerCharacter,x
          sta temp6
.bend

GravityNextPlayer .block
          ;; placeholder
.bend

GravityPlayerCheck .block
          ;; Players 0-1 always active
.bend

GravityPlayerCheck2 .block
          lda controllerStatus
          and # SetQuadtariDetected
.bend

          bne CheckPlayer2Character

          jmp GravityNextPlayer
CheckPlayer2Character:

          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then jmp GravityNextPlayer
          lda temp1
          cmp # 2
          bne CheckPlayer3Character
          lda # 2
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckPlayer3Character
          jmp GravityNextPlayer
CheckPlayer3Character:

          lda temp1
          cmp # 2
          bne CheckPlayer3Active
          lda # 2
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckPlayer3Active
          jmp GravityNextPlayer
CheckPlayer3Active:


          ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then jmp GravityNextPlayer
          lda temp1
          cmp # 3
          bne GravityCheckCharacter
          lda # 3
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne GravityCheckCharacter
          jmp GravityNextPlayer
;; GravityCheckCharacter (file-scope alias)

          lda temp1
          cmp # 3
          bne CheckCharacterType
          lda # 3
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckCharacterType
          jmp GravityNextPlayer
CheckCharacterType:

;; .bend


          ;; (hovering/flying like Frooty)
          lda temp6
          cmp #CharacterDragonOfStorms
          bne CheckJumpingState
          jmp GravityNextPlayer
CheckJumpingState:

          ;; RoboTito (13): Skip gravity when latched to ceiling
          ;; if temp6 = CharacterRoboTito && (characterStateFlags_R[temp1] & 1) then jmp GravityNextPlayer
          ;; If NOT jumping, skip gravity (player is on ground)
          ldx temp1
          lda playerState,x
          and # PlayerStateBitJumping
          bne ApplyGravityAcceleration
          jmp GravityNextPlayer
ApplyGravityAcceleration:

          ;; Vertical velocity is persistently tracked using playerVelocityY[]
          ;; and playerVelocityYL[] arrays (8.8 fixed-point format).
          ;; Gravity acceleration is applied to the stored velocity each frame.
          ;; Determine gravity acceleration rate based on character
          ;; (8.8 fixed-point subpixel)
          ;; Uses tunable constants from Constants.bas for easy
          ;; adjustment
          lda # GravityNormal
          sta gravityRate
          ;; Default gravity acceleration (normal rate)
          ;; Harpy: reduced gravity rate
          lda temp6
          cmp # CharacterHarpy
          bne ApplyGravityToVelocity

          lda GravityReduced
          sta gravityRate
ApplyGravityToVelocity:
          ;; Apply gravity  acceleration to  velocity subpixel  part Use
          ;; optimized inline  addition instead  of subroutine  call Set
          ;; subpixelAccumulator = playerVelocityYL[temp1] + gravityRate
          ldx temp1
          lda playerVelocityYL,x
          clc
          adc gravityRate
          sta playerVelocityYL,x
          bcc CheckTerminalVelocity
          inc playerVelocityY,x
CheckTerminalVelocity:

          ;; Apply terminal velocity cap (prevents infinite
          ;; acceleration)
          ;; Check if velocity exceeds terminal velocity (positive =
          ;; downward)
          lda playerVelocityY, x
          cmp # >TerminalVelocity
          blt DoneTerminalVelocity

          bne OverTerminalVelocity

          lda playerVelocityYL,x
          cmp # <TerminalVelocity
          blt DoneTerminalVelocity

OverTerminalVelocity:
          lda # <TerminalVelocity
          sta playerVelocityYL,x

          lda # >TerminalVelocity
          sta playerVelocityY,x

DoneTerminalVelocity:
          ;; Check playfield  collision for ground  detection (downward)
          ;; Convert  player  X  position  to  playfield  column  (0-31)
          ;; CRITICAL:  Inlined  CCJ_ConvertPlayerXToPlayfieldColumn  to
          ;; avoid cross-bank  call and  stack imbalance Input:  temp1 =
          ;; player  index Output:  temp2 =  playfield column  (saved to
          ;; temp6) 
          ldx temp1
          lda playerX, x
          sec
          sbc # ScreenInsetX
          lsr a
          lsr a
          ;; Save playfield column (temp2 will be overwritten)
          sta temp6
          ;; Calculate row where player feet are (bottom of sprite)
          ;; Feet are at playerY + PlayerSpriteHeight (16 pixels)
          ;; Set temp3 = playerY[temp1]
          ldx temp1
          lda playerY, x
          clc
          adc # PlayerSpriteHeight
          ldx temp1
          lda playerY, x
          sta temp3
          ;; Divide by PFRowHeight (16) using 4 right shifts
          lda temp3
          sta temp2
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          ;; feetRow = row where feet are
          lda temp2
          sta temp4
          ;; Check if there is a playfield pixel in the row below the
          ;; feet
          ;; If feet are in row N, check row N+1 for ground
          ;; Feet are at or below bottom of playfield, continue falling
          ;; if temp4 >= PFRows then jmp GravityNextPlayer
          lda temp4
          cmp #PFRows

          bcc CalculateRowBelow

          jmp CalculateRowBelow

          CalculateRowBelow:
          ;; rowBelow = row below feet
          lda temp4
          clc
          adc # 1
          sta temp5
          ;; Beyond playfield bounds, check if at bottom
          ;; if temp5 >= PFRows then jmp GravityCheckBottom
          lda temp5
          cmp #PFRows

          bcc CheckGroundPixel

          jmp CheckGroundPixel

          CheckGroundPixel:
          ;; Check if playfield pixel exists in row below feet
          ;; Track pfread result (1 = ground pixel set)
          lda # 0
          sta temp3
          lda temp1
          sta temp4
          lda temp6
          sta temp1
          lda temp5
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterPlayfieldReadGravity-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadGravity hi (encoded)]
          lda # <(AfterPlayfieldReadGravity-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadGravity hi (encoded)] [SP+0: AfterPlayfieldReadGravity lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadGravity hi (encoded)] [SP+1: AfterPlayfieldReadGravity lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadGravity hi (encoded)] [SP+2: AfterPlayfieldReadGravity lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
          ldx # 15
          jmp BS_jsr
AfterPlayfieldReadGravity:
          lda temp1
          beq CheckGroundDetected
          lda # 1
          sta temp3
CheckGroundDetected:
          jmp CheckGroundDetected
          lda temp4
          sta temp1
          ;; Ground detected! Skip standard landing logic for Radish Goblin (bounce system handles it)
          lda temp3
          bne CheckRadishGoblin
          jmp GravityNextPlayer
CheckRadishGoblin:

          ;; Radish Goblin uses bounce movement system, skip standard landing
          lda temp6
          cmp #CharacterRadishGoblin
          bne StandardLandingLogic
          jmp GravityNextPlayer
StandardLandingLogic:

          ;; Standard landing logic for all other characters
          ;; Zero Y velocity (stop falling)
          lda temp1
          tax
          lda # 0
          sta playerVelocityY,x
          lda temp1
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; Calculate Y position for top of ground row using repeated
          ;; addition
          ;; Loop to add PFRowHeight to rowYPosition, rowBelow times
          lda # 0
          sta rowYPosition
          lda temp5
          sta rowCounter
          lda rowCounter
          beq GravityRowCalcDone
GravityRowCalcLoop:
          lda rowYPosition
          clc
          adc # PFRowHeight
          sta rowYPosition
          dec rowCounter
          lda rowCounter
          bne GravityRowCalcLoop
GravityRowCalcDone:
          ;; rowYPosition now contains rowBelow × PFRowHeight (Y
          ;; position of top of ground row)
          ;; Clamp playerY so feet are at top of ground row
          ;; playerY[temp1] = rowYPosition - PlayerSpriteHeight
          ;; Also sync subpixel position
          ;; playerSubpixelY_W[temp1] = playerY[temp1]
          lda temp1
          tax
          lda playerY,x
          lda temp1
          tax
          sta playerSubpixelY_W,x
          lda temp1
          tax
          lda # 0
          sta playerSubpixelY_WL,x
          ;; Clear jumping flag (bit 2, not bit 4 - fix bit number)
          ;; playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitJumping)
          ;; Clear bit 2 (jumping flag)
          ;; Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
          lda temp6
          cmp # 3
          bne CheckRoboTitoLanding
          ;; characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 8)
CheckRoboTitoLanding:

          ;; If RoboTito, set stretch permission on landing
          lda temp6
          cmp # CharacterRoboTito
          bne GravityNextPlayerSkip
          jmp SetRoboTitoStretchPermission
GravityNextPlayerSkip:
          jmp GravityNextPlayer

SetRoboTitoStretchPermission .block
          ;; Set RoboTito stretch permission on landing (allows
          ;; stretching again)
          ;; Input: temp1 (temp1) = player index (0-3),
          ;; characterSpecialAbility_R[] (global SCRAM array) = stretch
          ;; permission (for RoboTito)
          ;; Output: characterSpecialAbility_W[] (global SCRAM array) =
          ;; stretch permission updated, missileStretchHeight_W[] (global
          ;; SCRAM array) = stretch missile height cleared
          ;; Mutates: temp1-temp2 (used for calculations),
          ;; characterSpecialAbility_W[] (global SCRAM array) = stretch
          ;; permission, missileStretchHeight_W[] (global SCRAM array) =
          ;; stretch missile heights
          ;; Called Routines: None
          ;; Constraints: Only called for RoboTito character on landing
          ;; Set stretch permission for this player (simple array assignment)
          ;; Grant stretch permission on landing
          lda temp1
          tax
          lda # 1
          sta characterSpecialAbility_W,x
          ;; Clear stretch missile height on landing (not stretching)
          lda temp1
          tax
          lda # 0
          sta missileStretchHeight_W,x
          ;; CRITICAL: Called via jmp from PhysicsApplyGravity, must continue to GravityNextPlayer
          ;; Do not return - use jmp to continue the loop
          jmp GravityNextPlayer

.bend

GravityCheckBottom .block
          ;; At bottom of playfield - treat as ground if feet are at
          ;; bottom row
          ;; Not at bottom row yet
          ;; if temp4 < PFRows - 1 then jmp GravityNextPlayer
          ;; Skip standard landing logic for Radish Goblin (bounce system handles it)
          ;; Radish Goblin uses bounce movement system, skip standard landing
          lda temp6
          cmp #CharacterRadishGoblin
          bne ClampToBottom
          jmp GravityNextPlayer
ClampToBottom:

          ;; Bottom row is always ground - clamp to bottom
          ;; Calculate (PFRows - 1) × PFRowHeight using repeated
          ;; addition
          lda # 0
          sta rowYPosition
          lda #PFRows
          sec
          sbc # 1
          sta rowCounter
          lda rowCounter
          bne GravityBottomCalcLoopLabel
          jmp GravityBottomCalcDone
GravityBottomCalcLoopLabel:


.bend

GravityBottomCalcLoop .block
          ;; Set rowYPosition = rowYPosition + PFRowHeight
          dec rowCounter
          lda rowCounter
          bne GravityBottomCalcDone
          jmp GravityBottomCalcDone

.bend

GravityBottomCalcDone .block
          ;; Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
          ldx temp1
          lda playerState, x
          and # $ff ^ 4
          sta playerState, x
          lda temp6
          cmp # 3
          bne CheckRoboTitoBottomLanding

CheckRoboTitoBottomLanding:
          lda temp6
          cmp #CharacterRoboTito
          bne GravityNextPlayerSkip2
          jmp SetRoboTitoStretchPermission
GravityNextPlayerSkip2:
          jmp GravityNextPlayer

.bend

;; GravityNextPlayer:
          ;; Move to next player
          inc temp1
          ;; if temp1 < 4 then jmp GravityLoop          lda temp1          cmp 4          bcs .skip_5570          jmp
          lda temp1
          cmp # 4
          bcs GravityLoopDone
          goto_label:

          jmp goto_label
GravityLoopDone:

          lda temp1
          cmp # 4
          bcs PhysicsApplyGravityDone
          jmp goto_label
PhysicsApplyGravityDone:

          
          jmp BS_return

;; .bend

