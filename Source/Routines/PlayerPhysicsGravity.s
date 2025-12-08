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
          ;; permission (via PAG_SetRoboTitoStretchPermission),
          ;; missileStretchHeight_W[] (global SCRAM array) = stretch
          ;; missile heights (via PAG_SetRoboTitoStretchPermission),
          ;; rowYPosition, rowCounter (global) = calculation
          ;; temporaries
          ;; Called Routines: AddVelocitySubpixelY (bank8) - adds
          ;; gravity to vertical velocity,
          ;; CCJ_ConvertPlayerXToPlayfieldColumn (bank12) - converts player
          ;; × to playfield column,y divided by 16 (pfrowheight is always 16)
          ;; row height, PAG_SetRoboTitoStretchPermission - sets
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
          ;; if temp1 >= 2 then goto GravityPlayerCheck
          ;; lda temp1 (duplicate)
          cmp 2

          bcc skip_545

          jmp skip_545

          skip_545:
          ;; jmp GravityCheckCharacter (duplicate)

.pend

GravityPlayerCheck .proc
          ;; Players 0-1 always active
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; cmp # 0 (duplicate)
          bne skip_6440
          ;; jmp GravityNextPlayer (duplicate)
skip_6440:

          ;; ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then goto GravityNextPlayer
          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_935 (duplicate)
          ;; lda 2 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_935 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_935:

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_7553 (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_7553 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_7553:


          ;; ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then goto GravityNextPlayer
          ;; lda temp1 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_6267 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_6267 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_6267:

          ;; lda temp1 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_5972 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_5972 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_5972:



.pend

GravityCheckCharacter .proc
                    ;; let temp6 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; Skip gravity for characters that do not have it
          ;; Frooty (8): Permanent flight, no gravity
          ;; Dragon of Storms (2): Permanent flight, no gravity
          ;; lda temp6 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_269 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_269:

          ;; (hovering/flying like Frooty)
          ;; lda temp6 (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_1278 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_1278:

          ;; RoboTito (13): Skip gravity when latched to ceiling
                    ;; if temp6 = CharacterRoboTito && (characterStateFlags_R[temp1] & 1) then goto GravityNextPlayer
          ;; If NOT jumping, skip gravity (player is on ground)
          ;; lda playerState[temp1] (duplicate)
          ;; and PlayerStateBitJumping (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6848 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_6848:

          ;; Vertical velocity is persistently tracked using playerVelocityY[]
          ;; and playerVelocityYL[] arrays (8.8 fixed-point format).
          ;; Gravity acceleration is applied to the stored velocity each frame.
          ;; Determine gravity acceleration rate based on character
          ;; (8.8 fixed-point subpixel)
          ;; Uses tunable constants from Constants.bas for easy
          ;; adjustment
          ;; lda GravityNormal (duplicate)
          ;; sta gravityRate (duplicate)
          ;; Default gravity acceleration (normal rate)
          ;; Harpy: reduced gravity rate
          ;; lda temp6 (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_8052 (duplicate)
          ;; lda GravityReduced (duplicate)
          ;; sta gravityRate (duplicate)
skip_8052:

          ;; Apply gravity acceleration to velocity subpixel part
          ;; Use optimized inline addition instead of subroutine call
                    ;; let subpixelAccumulator = playerVelocityYL[temp1] + gravityRate         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityYL,x (duplicate)
          ;; sta subpixelAccumulator (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
          ;; lda temp3 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bcc skip_6766 (duplicate)
          ;; ;; let playerVelocityY[temp1] = playerVelocityY[temp1] + 1
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          inc playerVelocityY,x

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerVelocityY,x (duplicate)
skip_6766:

          ;; Apply terminal velocity cap (prevents infinite
          ;; acceleration)
          ;; Check if velocity exceeds terminal velocity (positive =
          ;; downward)
                    ;; if playerVelocityY[temp1] > TerminalVelocity then let playerVelocityY[temp1] = TerminalVelocity : let playerVelocityYL[temp1] = 0
          ;; Check playfield collision for ground detection (downward)
          ;; Convert player X position to playfield column (0-31)
          ;; CRITICAL: Inlined CCJ_ConvertPlayerXToPlayfieldColumn to avoid cross-bank call and stack imbalance
          ;; Input: temp1 = player index
          ;; Output: temp2 = playfield column (saved to temp6)
                    ;; let temp2 = playerX[temp1]          lda temp1          asl          tax          lda playerX,x          sta temp2
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

          ;; Save playfield column (temp2 will be overwritten)
          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Calculate row where player feet are (bottom of sprite)
          ;; Feet are at playerY + PlayerSpriteHeight (16 pixels)
                    ;; let temp3 = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 + PlayerSpriteHeight (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; Divide by pfrowheight (16) using 4 right shifts
          ;; lda temp3 (duplicate)
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; feetRow = row where feet are
          ;; lda temp2 (duplicate)
          ;; sta temp4 (duplicate)
          ;; Check if there is a playfield pixel in the row below the
          ;; feet
          ;; If feet are in row N, check row N+1 for ground
          ;; Feet are at or below bottom of playfield, continue falling
          ;; if temp4 >= pfrows then goto GravityNextPlayer
          ;; lda temp4 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_6144 (duplicate)

          ;; jmp skip_6144 (duplicate)

          skip_6144:
          ;; rowBelow = row below feet
          ;; lda temp4 (duplicate)
          clc
          adc # 1
          ;; sta temp5 (duplicate)
          ;; Beyond playfield bounds, check if at bottom
          ;; if temp5 >= pfrows then goto GravityCheckBottom
          ;; lda temp5 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_9021 (duplicate)

          ;; jmp skip_9021 (duplicate)

          skip_9021:
          ;; Check if playfield pixel exists in row below feet
          ;; Track pfread result (1 = ground pixel set)
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp5 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 15
          ;; jmp BS_jsr (duplicate)
return_point:

                    ;; if temp1 then let temp3 = 1          lda temp1          beq skip_9151
skip_9151:
          ;; jmp skip_9151 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp1 (duplicate)
          ;; Ground detected! Skip standard landing logic for Radish Goblin (bounce system handles it)
          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_2593 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_2593:

          ;; Radish Goblin uses bounce movement system, skip standard landing
          ;; lda temp6 (duplicate)
          ;; cmp CharacterRadishGoblin (duplicate)
          ;; bne skip_4433 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
skip_4433:

          ;; Standard landing logic for all other characters
          ;; Zero Y velocity (stop falling)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
          ;; Calculate Y position for top of ground row using repeated
          ;; addition
          ;; Loop to add pfrowheight to rowYPosition, rowBelow times
          ;; lda # 0 (duplicate)
          ;; sta rowYPosition (duplicate)
          ;; lda temp5 (duplicate)
          ;; sta rowCounter (duplicate)
          ;; lda rowCounter (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8902 (duplicate)
          ;; jmp GravityRowCalcDone (duplicate)
skip_8902:


.pend

GravityRowCalcLoop .proc
                    ;; let rowYPosition = rowYPosition + pfrowheight
          dec rowCounter
          ;; lda rowCounter (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bcc skip_4709 (duplicate)
skip_4709:


GravityRowCalcDone
          ;; rowYPosition now contains rowBelow × pfrowheight (Y
          ;; position of top of ground row)
          ;; Clamp playerY so feet are at top of ground row
                    ;; let playerY[temp1] = rowYPosition - PlayerSpriteHeight
          ;; Also sync subpixel position
                    ;; let playerSubpixelY_W[temp1] = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerSubpixelY_W,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelY_WL,x (duplicate)
          ;; Clear jumping flag (bit 2, not bit 4 - fix bit number)
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitJumping)
          ;; Clear bit 2 (jumping flag)
          ;; Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
          ;; lda temp6 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_9278 (duplicate)
                    ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 8)
skip_9278:

          ;; If RoboTito, set stretch permission on landing
          ;; lda temp6 (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_6986 (duplicate)
          ;; jmp PAG_SetRoboTitoStretchPermission (duplicate)
skip_6986:

          ;; jmp GravityNextPlayer (duplicate)

PAG_SetRoboTitoStretchPermission
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
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta characterSpecialAbility_W,x (duplicate)
          ;; Clear stretch missile height on landing (not stretching)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta missileStretchHeight_W,x (duplicate)
          ;; CRITICAL: Called via goto from PhysicsApplyGravity, must continue to GravityNextPlayer
          ;; Do not return - use goto to continue the loop
          ;; jmp GravityNextPlayer (duplicate)

.pend

GravityCheckBottom .proc
          ;; At bottom of playfield - treat as ground if feet are at
          ;; bottom row
          ;; Not at bottom row yet
                    ;; if temp4 < pfrows - 1 then goto GravityNextPlayer
          ;; Skip standard landing logic for Radish Goblin (bounce system handles it)
          ;; Radish Goblin uses bounce movement system, skip standard landing
          ;; lda temp6 (duplicate)
          ;; cmp CharacterRadishGoblin (duplicate)
          ;; bne skip_4433 (duplicate)
          ;; jmp GravityNextPlayer (duplicate)
;; skip_4433: (duplicate)

          ;; Bottom row is always ground - clamp to bottom
          ;; Calculate (pfrows - 1) × pfrowheight using repeated
          ;; addition
          ;; lda # 0 (duplicate)
          ;; sta rowYPosition (duplicate)
          ;; lda pfrows (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta rowCounter (duplicate)
          ;; lda rowCounter (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_2049 (duplicate)
          ;; jmp GravityBottomCalcDone (duplicate)
skip_2049:


.pend

GravityBottomCalcLoop .proc
                    ;; let rowYPosition = rowYPosition + pfrowheight
          ;; dec rowCounter (duplicate)
          ;; lda rowCounter (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bcc skip_7553 (duplicate)
;; skip_7553: (duplicate)


GravityBottomCalcDone
                    ;; let playerY[temp1] = rowYPosition - PlayerSpriteHeight
          ;; Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
                    ;; let playerState[temp1] = playerState[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerState,x & ($FF ^ 4) (duplicate)
          ;; lda temp6 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_9278 (duplicate)
                    ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 8)
;; skip_9278: (duplicate)

          ;; If RoboTito, set stretch permission on landing at bottom
          ;; lda temp6 (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_6986 (duplicate)
          ;; jmp PAG_SetRoboTitoStretchPermission (duplicate)
;; skip_6986: (duplicate)


.pend

GravityNextPlayer .proc
          ;; Move to next player
          ;; inc temp1 (duplicate)
          ;; ;; if temp1 < 4 then goto GravityLoop          lda temp1          cmp 4          bcs .skip_5570          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 4 (duplicate)
          bcs skip_8875
          goto_label:

          ;; jmp goto_label (duplicate)
skip_8875:

          ;; lda temp1 (duplicate)
          ;; cmp # 4 (duplicate)
          ;; bcs skip_6080 (duplicate)
          ;; jmp goto_label (duplicate)
skip_6080:

          
          jsr BS_return

.pend

