;;; ChaosFight - Source/Routines/PlayerPhysicsGravity.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Disable smart branching optimization to prevent label mismatch errors
;;; smartbranching off


PhysicsApplyGravity .proc
          ;; Player Physics - Gravity and Momentum
          ;; Returns: Far (return otherbank)
          ;; Handles gravity, momentum, and recovery for all players.
          ;; Split from PlayerPhysics.bas to reduce bank size.
          ;; AVAILABLE VARIABLES:
          ;; playerX[0-3], playerY[0-3] - Positions
          ;; playerState[0-3] - State flags
          ;; playerVelocityX[0-3] - Horizontal velocity (8.8
          ;; fixed-point)
          ;; playerVelocityY[0-3] - Vertical velocity (8.8 fixed-point)
          ;; playerRecoveryFrames[0-3] - Recovery (hitstun) frames
          ;; remaining
          ;; QuadtariDetected - Whether 4-player mode active
          ;; playerCharacter[] - Player 3/4 selections
          ;; playerCharacter[0-3] - Character type indices
          ;; Apply Gravity
          ;; Applies gravity acceleration to jumping players.
          ;; Certain characters (Frooty=8, Dragon of Storms=2) are not
          ;; affected by gravity.
          ;; Players land when they are atop a playfield pixel (ground
          ;; detection).
          ;; Gravity accelerates downward using tunable consta

          ;; (Constants.bas):
          ;; GravityNormal (0.1px/frame²), GravityReduced
          ;; (0.05px/frame²), TerminalVelocity (8px/frame)
          ;; Applies gravity acceleration to jumping players and
          ;; handles ground detection
          ;; Input: playerCharacter[] (global array) = character types,
          ;; playerState[] (global array) = player states, playerX[],
          ;; playerY[] (global arrays) = player positions,
          ;; playerVelocityY[], playerVelocityYL[] (global arrays) =
          ;; vertical velocity, controllerStatus (global) = controller
          ;; state, playerCharacter[] (global array) =
          ;; player 3/4 selections, characterStateFlags_R[] (global
          ;; SCRAM array) = character state flags, gravityRate (global)
          ;; = gravity acceleration rate, GravityNormal,
          ;; GravityReduced, TerminalVelocity (global constants) =
          ;; gravity constants, characterSpecialAbility_R[] (global SCRAM
          ;; array) = stretch permission (for RoboTito)
          ;; Output: Gravity applied to jumping players, ground
          ;; detection performed, players clamped to ground on landing
          ;; Mutates: temp1-temp6 (used for calculations),
          ;; playerVelocityY[], playerVelocityYL[] (global arrays) =
          ;; vertical velocity, playerY[] (global array) = player Y
          ;; positions, playerSubpixelY[], playerSubpixelYL[] (global
          ;; arrays) = subpixel Y positions, playerState[] (global
          ;; array) = player states (jumping flag cleared on landing),
          ;; characterSpecialAbility_W[] (global SCRAM array) = stretch
          ;; permission (via SetRoboTitoStretchPermission),
          ;; missileStretchHeight_W[] (global SCRAM array) = stretch
          ;; missile heights (via SetRoboTitoStretchPermission),
          ;; rowYPosition, rowCounter (global) = calculation
          ;; temporaries
          ;; Called Routines: AddVelocitySubpixelY (bank8) - adds
          ;; gravity to vertical velocity,
          ;; CCJ_ConvertPlayerXToPlayfieldColumn (inlined) - converts player
          ;; × to playfield column,y divided by 16 (pfrowheight is always 16)
          ;; row height, SetRoboTitoStretchPermission - sets
          ;; RoboTito stretch permission on landing
          ;; Constraints: Frooty (8) and Dragon of Storms (2) skip
          ;; gravity entirely. RoboTito (13) skips gravity when latched
          ;; to ceiling
          ;; Loop through all players (0-3)
          lda # 0
          sta temp1

.pend

GravityLoop .proc
          ;; Check if player is active (P1/P2 always active, P3/P4 need
          ;; Quadtari)
          ;; if temp1 >= 2 then jmp GravityPlayerCheck
          lda temp1
          cmp # 2

          bcc GravityCheckCharacter

          jmp GravityCheckCharacter

          GravityCheckCharacter:
          jmp GravityCheckCharacter

.pend

GravityPlayerCheck .proc
          ;; Players 0-1 always active
          lda controllerStatus
          and # SetQuadtariDetected
          bne CheckPlayer2Character

          jmp GravityNextPlayer
CheckPlayer2Character:

          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then jmp GravityNextPlayer
          lda temp1
          cmp # 2
          bne CheckPlayer3Character
          lda # 2
          asl
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
          asl
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
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne GravityCheckCharacter
          jmp GravityNextPlayer
GravityCheckCharacter:

          lda temp1
          cmp # 3
          bne CheckCharacterType
          lda # 3
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckCharacterType
          jmp GravityNextPlayer
CheckCharacterType:



.pend

GravityCheckCharacter .proc
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Skip gravity for characters that do not have it
          ;; Frooty (8): Permanent flight, no gravity
          ;; Dragon of Storms (2): Permanent flight, no gravity
          lda temp6
          cmp CharacterFrooty
          bne CheckDragonOfStorms
          jmp GravityNextPlayer
CheckDragonOfStorms:

          ;; (hovering/flying like Frooty)
          lda temp6
          cmp CharacterDragonOfStorms
          bne CheckJumpingState
          jmp GravityNextPlayer
CheckJumpingState:

          ;; RoboTito (13): Skip gravity when latched to ceiling
          ;; if temp6 = CharacterRoboTito && (characterStateFlags_R[temp1] & 1) then jmp GravityNextPlayer
          If NOT jumping, skip gravity (player is on ground)
          lda playerState[temp1]
          and # PlayerStateBitJumping
          bne ApplyGravityAcceleration
          jmp GravityNextPlayer
ApplyGravityAcceleration:

          ;; Vertical velocity is persistently tracked using playerVelocityY[]
          and playerVelocityYL[] arrays (8.8 fixed-point format).
          ;; Gravity acceleration is applied to the stored velocity each frame.
          ;; Determine gravity acceleration rate based on character
          ;; (8.8 fixed-point subpixel)
          ;; Uses tunable constants from Constants.bas for easy
          ;; adjustment
          lda GravityNormal
          sta gravityRate
          ;; Default gravity acceleration (normal rate)
          ;; Harpy: reduced gravity rate
          lda temp6
          cmp CharacterHarpy
          bne ApplyGravityToVelocity
          lda GravityReduced
          sta gravityRate
ApplyGravityToVelocity:

          ;; Apply gravity acceleration to velocity subpixel part
          ;; Use optimized inline addition instead of subroutine call
          ;; Set subpixelAccumulator = playerVelocityYL[temp1] + gravityRate
          lda temp1
          asl
          tax
          lda playerVelocityYL,x
          clc
          adc gravityRate
          sta subpixelAccumulator
          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityYL,x
          lda temp3
          cmp # 1
          bcc CheckTerminalVelocity
          ;; let playerVelocityY[temp1] = playerVelocityY[temp1] + 1
          lda temp1
          asl
          tax
          inc playerVelocityY,x
CheckTerminalVelocity:

          ;; Apply terminal velocity cap (prevents infinite
          ;; acceleration)
          ;; Check if velocity exceeds terminal velocity (positive =
          ;; downward)
                    if playerVelocityY[temp1] > TerminalVelocity then let playerVelocityY[temp1] = TerminalVelocity : let playerVelocityYL[temp1] = 0
          ;; Check playfield collision for ground detection (downward)
          ;; Convert player X position to playfield column (0-31)
          ;; CRITICAL: Inlined CCJ_ConvertPlayerXToPlayfieldColumn to avoid cross-bank call and stack imbalance
          ;; Input: temp1 = player index
          ;; Output: temp2 = playfield column (saved to temp6)
                    ;; Set temp2 = playerX[temp1]
                    lda temp1          asl          tax          lda playerX,x          sta temp2
          ;; Set temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc # ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

          ;; Set temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          lda temp2
          lsr
          lsr
          sta temp2

          lda temp2
          lsr
          lsr
          sta temp2

          ;; Save playfield column (temp2 will be overwritten)
          lda temp2
          sta temp6
          ;; Calculate row where player feet are (bottom of sprite)
          ;; Feet are at playerY + PlayerSpriteHeight (16 pixels)
          ;; Set temp3 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3 + PlayerSpriteHeight
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3
          ;; Divide by pfrowheight (16) using 4 right shifts
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
          If feet are in row N, check row N+1 for ground
          ;; Feet are at or below bottom of playfield, continue falling
          ;; if temp4 >= pfrows then jmp GravityNextPlayer
          lda temp4
          cmp pfrows

          bcc CalculateRowBelow

          jmp CalculateRowBelow

          CalculateRowBelow:
          ;; rowBelow = row below feet
          lda temp4
          clc
          adc # 1
          sta temp5
          ;; Beyond playfield bounds, check if at bottom
          ;; if temp5 >= pfrows then jmp GravityCheckBottom
          lda temp5
          cmp pfrows

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

                    if temp1 then let temp3 = 1          lda temp1          beq CheckGroundDetected
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
          cmp CharacterRadishGoblin
          bne StandardLandingLogic
          jmp GravityNextPlayer
StandardLandingLogic:

          ;; Standard landing logic for all other characters
          ;; Zero Y velocity (stop falling)
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; Calculate Y position for top of ground row using repeated
          ;; addition
          ;; Loop to add pfrowheight to rowYPosition, rowBelow times
          lda # 0
          sta rowYPosition
          lda temp5
          sta rowCounter
          lda rowCounter
          bne GravityRowCalcLoop
          jmp GravityRowCalcDone
GravityRowCalcLoop:


.pend

GravityRowCalcLoop .proc
          ;; Set rowYPosition = rowYPosition + pfrowheight
          dec rowCounter
          lda rowCounter
          cmp # 1
          bcc GravityRowCalcDoneLabel
GravityRowCalcDoneLabel:


GravityRowCalcDone
          ;; rowYPosition now contains rowBelow × pfrowheight (Y
          ;; position of top of ground row)
          ;; Clamp playerY so feet are at top of ground row
                    let playerY[temp1] = rowYPosition - PlayerSpriteHeight
          ;; Also sync subpixel position
                    let playerSubpixelY_W[temp1] = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          lda temp1
          asl
          tax
          sta playerSubpixelY_W,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x
          ;; Clear jumping flag (bit 2, not bit 4 - fix bit number)
                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitJumping)
          ;; Clear bit 2 (jumping flag)
          ;; Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
          lda temp6
          cmp # 3
          bne CheckRoboTitoLanding
                    let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 8)
CheckRoboTitoLanding:

          If RoboTito, set stretch permission on landing
          lda temp6
          cmp CharacterRoboTito
          bne GravityNextPlayer
          jmp SetRoboTitoStretchPermission
GravityNextPlayer:

          jmp GravityNextPlayer

SetRoboTitoStretchPermission
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
          asl
          tax
          lda # 1
          sta characterSpecialAbility_W,x
          ;; Clear stretch missile height on landing (not stretching)
          lda temp1
          asl
          tax
          lda # 0
          sta missileStretchHeight_W,x
          ;; CRITICAL: Called via jmp from PhysicsApplyGravity, must continue to GravityNextPlayer
          ;; Do not return - use jmp to continue the loop
          jmp GravityNextPlayer

.pend

GravityCheckBottom .proc
          ;; At bottom of playfield - treat as ground if feet are at
          ;; bottom row
          ;; Not at bottom row yet
          ;; if temp4 < pfrows - 1 then jmp GravityNextPlayer
          ;; Skip standard landing logic for Radish Goblin (bounce system handles it)
          ;; Radish Goblin uses bounce movement system, skip standard landing
          lda temp6
          cmp CharacterRadishGoblin
          bne ClampToBottom
          jmp GravityNextPlayer
ClampToBottom:

          ;; Bottom row is always ground - clamp to bottom
          ;; Calculate (pfrows - 1) × pfrowheight using repeated
          ;; addition
          lda # 0
          sta rowYPosition
          lda pfrows
          sec
          sbc # 1
          sta rowCounter
          lda rowCounter
          bne GravityBottomCalcLoopLabel
          jmp GravityBottomCalcDone
GravityBottomCalcLoopLabel:


.pend

GravityBottomCalcLoop .proc
          ;; Set rowYPosition = rowYPosition + pfrowheight
          dec rowCounter
          lda rowCounter
          cmp # 1
          bcc GravityBottomCalcDone
GravityBottomCalcDone:


GravityBottomCalcDone
                    let playerY[temp1] = rowYPosition - PlayerSpriteHeight
          ;; Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
                    let playerState[temp1] = playerState[temp1]
          lda temp1
          asl
          tax
          lda playerState,x
          lda temp1
          asl
          tax
          sta playerState,x & ($FF ^ 4)
          lda temp6
          cmp # 3
          bne CheckRoboTitoBottomLanding
                    let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 8)
CheckRoboTitoBottomLanding:

          If RoboTito, set stretch permission on landing at bottom
          lda temp6
          cmp CharacterRoboTito
          bne GravityNextPlayerLabel
          jmp SetRoboTitoStretchPermission
GravityNextPlayerLabel:


.pend

GravityNextPlayer .proc
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

.pend

