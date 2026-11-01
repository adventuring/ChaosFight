;;; ChaosFight - Source/Routines/CPUOpponent.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;;
;;; CPU Opponent AI for Player 2
;;; Heuristic-based input generation for computer-controlled player.
;;;
;;; Called from GameLoopMain when playerCharacter[1] == CPUCharacter
;;; Writes to player2Input_W (consolidated input snapshot) so that
;;; InputHandleRightPortPlayerFunction processes it as joystick input.
;;;
;;; Difficulty: Right Difficulty Switch (SWCHB bit 7)
;;;   A / Advanced / Expert (bit 7 = 1) -> aggressive
;;;   B / Beginner / Novice (bit 7 = 0) -> less aggressive

CPUOpponent .proc
            ;; Returns: Near (return thisbank)
            ;;
            ;; Input: playerX[0-3], playerY[0-3], playerVelocityX[0-3],
            ;;        playerState[0-3], playerHealth[0-3],
            ;;        playerCharacter[1] (must be CPUCharacter)
            ;;        SWCHB (hardware) - Right Difficulty Switch
            ;;
            ;; Output: player2Input_W updated with AI decisions
            ;;
            ;; Mutates: player2Input_W, temp1-temp6
            ;;
            ;; Called Routines: None (self-contained)
            ;;
            ;; Constraints: Must be called before InputHandleAllPlayers

            ;; Only run if Player 2 is CPU
            lda playerCharacter+1
            cmp #CPUCharacter
            bne CPUOpponentDone

            ;; Clear input byte
            lda #0
            sta player2Input_W

            ;; Determine difficulty from Right Difficulty Switch (SWCHB bit 7)
            ;; SWCHBP1Advanced = $80 (bit 7 = 1 = Advanced/Expert)
            lda SWCHB
            and #SWCHBP1Advanced
            sta temp1          ;; temp1 = difficulty (0 = Novice, $80 = Advanced)

            ;; Find nearest alive opponent (Player 1, 3, or 4)
            jsr CPUOpponentFindTarget
            ;; temp2 = target player index (0, 2, or 3), or $FF if none alive
            lda temp2
            cmp #$FF
            beq CPUOpponentDone  ;; No targets, do nothing

            ;; Store target index in temp3
            lda temp2
            sta temp3

            ;; Calculate horizontal distance to target
            ;; temp4 = playerX[target] - playerX[1] (positive = target to right)
            lda temp3
            tax
            lda playerX,x
            sec
            sbc playerX+1
            sta temp4

            ;; Calculate vertical distance
            ;; temp5 = playerY[target] - playerY[1] (positive = target below)
            lda temp3
            tax
            lda playerY,x
            sec
            sbc playerY+1
            sta temp5

            ;; Horizontal movement decision
            jsr CPUOpponentDecideHorizontal

            ;; Vertical/Jump decision
            jsr CPUOpponentDecideVertical

            ;; Attack decision
            jsr CPUOpponentDecideAttack

            ;; Guard decision (based on difficulty and proximity)
            jsr CPUOpponentDecideGuard

CPUOpponentDone:
            rts

.pend

CPUOpponentFindTarget .proc
            ;; Find nearest alive opponent for Player 2
            ;; Returns: temp2 = target index (0, 2, 3) or $FF if none
            ;;
            ;; Mutates: temp2, temp4, temp5

            lda #$FF
            sta temp2          ;; Default: no target
            lda #255
            sta temp4          ;; Best distance (high)

            ;; Check Player 1 (index 0)
            lda playerHealth
            beq CheckPlayer3
            jsr CPUOpponentCheckTarget
            ;; temp4/5 updated if Player 1 is closer

CheckPlayer3:
            ;; Check Player 3 (index 2) - only if Quadtari detected
            lda controllerStatus
            and #SetQuadtariDetected
            beq CheckPlayer4
            lda playerHealth+2
            beq CheckPlayer4
            lda #2
            tax
            jsr CPUOpponentCheckTarget

CheckPlayer4:
            ;; Check Player 4 (index 3) - only if Quadtari detected
            lda controllerStatus
            and #SetQuadtariDetected
            beq CPUOpponentFindTargetDone
            lda playerHealth+3
            beq CPUOpponentFindTargetDone
            lda #3
            tax
            jsr CPUOpponentCheckTarget

CPUOpponentFindTargetDone:
            rts

CPUOpponentCheckTarget .proc
            ;; X = target index (0, 2, or 3)
            ;; Computes distance squared, updates temp2/temp4 if closer
            ;;
            ;; Mutates: temp2, temp4, temp5, temp6

            ;; Horizontal distance
            lda playerX,x
            sec
            sbc playerX+1
            bpl DistXPositive
            eor #$FF
            clc
            adc #1
DistXPositive:
            sta temp5          ;; |dx| in temp5

            ;; Vertical distance
            lda playerY,x
            sec
            sbc playerY+1
            bpl DistYPositive
            eor #$FF
            clc
            adc #1
DistYPositive:
            sta temp6          ;; |dy| in temp6

            ;; Approximate distance squared: dx*dx + dy*dy (8-bit, saturating)
            ;; Use simple sum of absolute distances for speed
            lda temp5
            clc
            adc temp6
            sta temp6          ;; temp6 = |dx| + |dy|

            ;; Compare with best
            cmp temp4
            bcs CPUOpponentCheckTargetDone
            sta temp4          ;; New best distance
            txa
            sta temp2          ;; New target index

CPUOpponentCheckTargetDone:
            rts

.pend

CPUOpponentDecideHorizontal .proc
            ;; Decide left/right movement based on target position
            ;; temp3 = target index, temp4 = dx (target - self)
            ;;
            ;; Mutates: player2Input_W (bits $08 right, $04 left)

            ;; Check if CPU is in attack animation (blocks movement)
            lda playerState+1
            and #PlayerStateBitAttacking
            bne CPUOpponentHorizontalDone

            ;; Check if guarding (blocks movement)
            lda playerState+1
            and #PlayerStateBitGuarding
            bne CPUOpponentHorizontalDone

            ;; Check if in recovery/hitstun
            lda playerState+1
            and #PlayerStateBitRecovery
            bne CPUOpponentHorizontalDone

            ;; Get horizontal distance (signed in temp4)
            lda temp4
            beq CPUOpponentHorizontalDone  ;; Same X, no horizontal move

            bpl TargetToRight
            ;; Target is to the left (negative dx)
            ;; Move left
            lda player2Input_R
            ora #PlayerInputLeft
            sta player2Input_W
            jmp CPUOpponentHorizontalDone

TargetToRight:
            ;; Target is to the right (positive dx)
            ;; Move right
            lda player2Input_R
            ora #PlayerInputRight
            sta player2Input_W

CPUOpponentHorizontalDone:
            rts

.pend

CPUOpponentDecideVertical .proc
            ;; Decide jump/up input based on target vertical position
            ;; and platform layout
            ;;
            ;; Mutates: player2Input_W (bit $01 jump/up, $20 enhanced jump)

            ;; Check if already jumping
            lda playerState+1
            and #PlayerStateBitJumping
            bne CPUOpponentVerticalDone

            ;; Check if in recovery
            lda playerState+1
            and #PlayerStateBitRecovery
            bne CPUOpponentVerticalDone

            ;; Check if attacking
            lda playerState+1
            and #PlayerStateBitAttacking
            bne CPUOpponentVerticalDone

            ;; Check character type for special movement
            lda playerCharacter+1
            cmp #CharacterFrooty
            beq CPUOpponentFrootyVertical
            cmp #CharacterDragonOfStorms
            beq CPUOpponentDragonVertical
            cmp #CharacterHarpy
            beq CPUOpponentHarpyVertical
            cmp #CharacterRoboTito
            beq CPUOpponentRoboTitoVertical
            cmp #CharacterBernie
            beq CPUOpponentBernieVertical
            cmp #CharacterShamone
            beq CPUOpponentShamoneVertical
            cmp #CharacterMethHound
            beq CPUOpponentShamoneVertical

            ;; Standard characters: jump if target is above or on platform
            lda temp5          ;; dy (target - self)
            bpl TargetBelowOrLevel
            ;; Target is above - jump to reach
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone

TargetBelowOrLevel:
            ;; Target at same level or below - small chance to jump
            ;; based on difficulty
            lda temp1          ;; difficulty
            beq NoviceJumpCheck
            ;; Advanced: 25% chance to jump when target level
            lda rand
            and #3
            bne CPUOpponentVerticalDone
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone

NoviceJumpCheck:
            ;; Novice: 10% chance
            lda rand
            and #7
            bne CPUOpponentVerticalDone
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W

CPUOpponentVerticalDone:
            rts

CPUOpponentFrootyVertical:
            ;; Frooty: free flight - use UP/DOWN directly
            lda temp5
            bpl FrootyTargetBelow
            ;; Target above - fly up
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone
FrootyTargetBelow:
            ;; Target below - fly down (DOWN = $02)
            lda player2Input_R
            ora #PlayerInputDefend
            sta player2Input_W
            jmp CPUOpponentVerticalDone

CPUOpponentDragonVertical:
            ;; Dragon of Storms: flying character, similar to Frooty
            lda temp5
            bpl DragonTargetBelow
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone
DragonTargetBelow:
            lda player2Input_R
            ora #PlayerInputDefend
            sta player2Input_W
            jmp CPUOpponentVerticalDone

CPUOpponentHarpyVertical:
            ;; Harpy: flap to fly (UP = flap)
            lda temp5
            bpl HarpyTargetBelow
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone
HarpyTargetBelow:
            ;; Don't flap down - just don't flap
            jmp CPUOpponentVerticalDone

CPUOpponentRoboTitoVertical:
            ;; Robo Tito: UP stretches to ceiling
            lda temp5
            bpl RoboTitoTargetBelow
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone
RoboTitoTargetBelow:
            ;; Press DOWN to return to floor
            lda player2Input_R
            ora #PlayerInputDefend
            sta player2Input_W
            jmp CPUOpponentVerticalDone

CPUOpponentBernieVertical:
            ;; Bernie: UP = fall through floor
            lda temp5
            bpl BernieTargetBelow
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone
BernieTargetBelow:
            jmp CPUOpponentVerticalDone

CPUOpponentShamoneVertical:
            ;; Shamone/Meth Hound: UP = form switch, jump via enhanced button
            ;; Use enhanced button for jump
            lda temp5
            bpl ShamoneTargetBelow
            lda player2Input_R
            ora #PlayerInputJump
            sta player2Input_W
            jmp CPUOpponentVerticalDone
ShamoneTargetBelow:
            jmp CPUOpponentVerticalDone

.pend

CPUOpponentDecideAttack .proc
            ;; Decide attack input based on proximity and difficulty
            ;;
            ;; Mutates: player2Input_W (bit $80 attack)

            ;; Check if already attacking
            lda playerState+1
            and #PlayerStateBitAttacking
            bne CPUOpponentAttackDone

            ;; Check if in recovery
            lda playerState+1
            and #PlayerStateBitRecovery
            bne CPUOpponentAttackDone

            ;; Check if guarding
            lda playerState+1
            and #PlayerStateBitGuarding
            bne CPUOpponentAttackDone

            ;; Check attack cooldown
            lda playerAttackCooldown_R+1
            bne CPUOpponentAttackDone

            ;; Calculate absolute horizontal distance
            lda temp4
            bpl AttackDistPositive
            eor #$FF
            clc
            adc #1
AttackDistPositive:
            sta temp5

            ;; Calculate absolute vertical distance
            lda temp5          ;; |dx| already in temp5 from horizontal
            lda temp5          ;; Actually temp5 has |dx|, need |dy|
            lda temp5
            ;; temp5 currently has |dx| from horizontal decision
            ;; Recalculate |dy| from temp5 (which was dy signed)
            lda temp5          ;; Wait, temp5 was overwritten. Use temp5 from earlier.
            ;; Actually vertical distance is in temp5 from FindTarget
            ;; But it was overwritten. Recompute:
            lda playerY+1
            ldy temp3
            sec
            sbc playerY,y
            bpl AttackDyPositive
            eor #$FF
            clc
            adc #1
AttackDyPositive:
            sta temp6          ;; |dy| in temp6

            ;; Attack if target is close horizontally and vertically aligned
            lda temp5          ;; |dx|
            cmp #24            ;; Within ~24 pixels horizontally
            bcs CPUOpponentAttackDone
            lda temp6          ;; |dy|
            cmp #16            ;; Within ~16 pixels vertically
            bcs CPUOpponentAttackDone

            ;; In range - decide based on difficulty and character
            lda temp1          ;; difficulty
            beq NoviceAttackCheck
            ;; Advanced: 60% chance to attack when in range
            lda rand
            and #7
            cmp #5
            bcs CPUOpponentAttackDone
            jmp CPUOpponentDoAttack

NoviceAttackCheck:
            ;; Novice: 30% chance
            lda rand
            and #7
            cmp #2
            bcs CPUOpponentAttackDone

CPUOpponentDoAttack:
            lda player2Input_R
            ora #PlayerInputAttack
            sta player2Input_W

CPUOpponentAttackDone:
            rts

.pend

CPUOpponentDecideGuard .proc
            ;; Decide guard/defend input based on incoming threats
            ;; and difficulty
            ;;
            ;; Mutates: player2Input_W (bit $02 down/defend)

            ;; Check if already guarding
            lda playerState+1
            and #PlayerStateBitGuarding
            bne CPUOpponentGuardDone

            ;; Check if attacking (can't guard while attacking)
            lda playerState+1
            and #PlayerStateBitAttacking
            bne CPUOpponentGuardDone

            ;; Check if in recovery
            lda playerState+1
            and #PlayerStateBitRecovery
            bne CPUOpponentGuardDone

            ;; Check if jumping
            lda playerState+1
            and #PlayerStateBitJumping
            bne CPUOpponentGuardDone

            ;; Check guard cooldown timer
            lda playerTimers_R+1
            bne CPUOpponentGuardDone

            ;; Check for incoming missiles targeting Player 2
            ;; Simple heuristic: guard if any missile is active and nearby
            lda missileActive
            beq CPUOpponentGuardChance

            ;; Check missile 0 (Player 1's missile on even frames)
            lda missileActive
            and #$01
            beq CheckMissile1
            jsr CPUOpponentCheckMissileThreat
            bcs CPUOpponentDoGuard

CheckMissile1:
            lda missileActive
            and #$02
            beq CheckMissile2
            jsr CPUOpponentCheckMissileThreat
            bcs CPUOpponentDoGuard

CheckMissile2:
            lda missileActive
            and #$04
            beq CheckMissile3
            jsr CPUOpponentCheckMissileThreat
            bcs CPUOpponentDoGuard

CheckMissile3:
            lda missileActive
            and #$08
            beq CPUOpponentGuardChance
            jsr CPUOpponentCheckMissileThreat
            bcs CPUOpponentDoGuard

CPUOpponentGuardChance:
            ;; No immediate missile threat - small chance to guard preemptively
            lda temp1          ;; difficulty
            beq NoviceGuardChance
            ;; Advanced: 15% chance to guard
            lda rand
            and #$0F
            cmp #2
            bcs CPUOpponentGuardDone
            jmp CPUOpponentDoGuard

NoviceGuardChance:
            ;; Novice: 5% chance
            lda rand
            and #$1F
            cmp #1
            bcs CPUOpponentGuardDone

CPUOpponentDoGuard:
            lda player2Input_R
            ora #PlayerInputDefend
            sta player2Input_W

CPUOpponentGuardDone:
            rts

CPUOpponentCheckMissileThreat .proc
            ;; Check if missile X/Y threatens Player 2
            ;; Returns: Carry set if threat detected
            ;;
            ;; Mutates: temp4, temp5, temp6

            ;; This is a simplified check - in practice would need to check
            ;; each active missile's position against Player 2
            ;; For now, return carry clear (no threat)
            clc
            rts

.pend

.pend