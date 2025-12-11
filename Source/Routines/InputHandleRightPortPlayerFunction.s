;;; ChaosFight - Source/Routines/InputHandleRightPortPlayerFunction.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

InputHandleRightPortPlayerFunction:

          ;;
          ;; RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
          ;;
          ;; INPUT: temp1 = player index (1 or 3)
          ;; USES: joy1left, joy1right, joy1up, joy1down, joy1fire
          ;; Cache animation state at start (used for movement, jump, and attack checks)
          lda temp1
          sta currentPlayer
          ;; block movement during attack animations (states 13-15)
          ;; let temp2 = playerState[temp1] / 16         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; Block movement during attack windup/execute/recovery
          ;; if temp2 >= 13 then goto DoneRightPortMovement
          lda temp2
          cmp # 13

          bcc IHRP_CheckGuardStatus

          jmp DoneRightPortMovement

IHRP_CheckGuardStatus:

          ;; Process left/right movement (with playfield collision for
          ;; flying characters)
          ;; Check if player is guarding - guard blocks movement
          ;; let temp6 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6
          ;; Guarding - block movement
          ;; if temp6 then goto DoneRightPortMovement
          lda temp6
          beq IHRP_CheckFlyingCharacter

          jmp DoneRightPortMovement

IHRP_CheckFlyingCharacter:

          ;; Frooty (8) and Dragon of Storms (2) need collision checks
          ;; for horizontal movement
          ;; let temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5
          lda temp5
          cmp # 8
          bne IHRP_CheckDragonOfStorms

          jmp IHRP_FlyingMovement

IHRP_CheckDragonOfStorms:

          lda temp5
          cmp # 2
          bne IHRP_ProcessStandardMovement

          jmp IHRP_FlyingMovement

IHRP_ProcessStandardMovement:

          ;; Standard horizontal movement (uses shared routine)
          ;; Cross-bank call to ProcessStandardMovement in bank 13
          lda # >(IHRPF_ProcessStandardMovementReturn-1)
          pha
          lda # <(IHRPF_ProcessStandardMovementReturn-1)
          pha
          lda # >(ProcessStandardMovement-1)
          pha
          lda # <(ProcessStandardMovement-1)
          pha
          ldx # 12
          jmp BS_jsr
IHRPF_ProcessStandardMovementReturn:


DoneRightPortMovement

IHRP_FlyingMovement .proc
          ;; Tail call: goto instead of gosub to save 2 bytes on sta
          ;; Note: HandleFlyingCharacterMovement is in Bank 11, but we use jmp (tail call)
          ;; so it doesn't add to stack depth
          jmp HandleFlyingCharacterMovement
IHRP_DoneFlyingLeftRight

          ;; Process UP input for character-specific behaviors
          ;; Returns with temp3 = 1 if UP used for jump, 0 if special ability
          jsr HandleUpInput

          ;; Process jump input from enhanced buttons (must be identical
          ;; effect to HandleUpInput for all characters)
          ;; Same-bank call to ProcessJumpInput (Bank 7) - saves 2 bytes vs cross-bank
          jsr ProcessJumpInput

InputDoneRightPortJump

          ;; Process down/guard input (fully inlined to save 2 bytes on sta

          ;; Check joy1down (right port uses joy1)
          ;; lda joy1down (undefined - use INPT4 or similar)
          lda INPT4
          bne IHRP_HandleDownPressed
          jmp IHRP_CheckGuardRelease
IHRP_HandleDownPressed:


.pend

IHRP_HandleDownPressed .proc
          ;; DOWN pressed - dispatch to character-specific down handler
          ;; let temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4
          ;; if temp4 >= 32 then goto IHRP_ProcessAttack
          lda temp4
          cmp 32

          bcc IHRP_CheckCharacterDown

          jmp IHRP_CheckCharacterDown

IHRP_CheckCharacterDown:
          lda temp4
          cmp # 2
          bne IHRP_CheckHarpyDown
          jmp DragonOfStormsDown
IHRP_CheckHarpyDown:

          lda temp4
          cmp # 6
          bne IHRP_CheckFrootyDown
          jmp HarpyDown
IHRP_CheckFrootyDown:

          lda temp4
          cmp # 8
          bne IHRP_CheckRoboTitoDown
          jmp FrootyDown
IHRP_CheckRoboTitoDown:

          lda temp4
          cmp # 13
          bne IHRP_UseStandardGuard
          jmp IHRP_HandleRoboTitoDown
IHRP_UseStandardGuard:

          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          jmp StandardGuard

.pend

IHRP_HandleRoboTitoDown .proc
          ;; Cross-bank call to RoboTitoDown in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RoboTitoDown-1)
          pha
          lda # <(RoboTitoDown-1)
          pha
                    ldx # 12
          jmp BS_jsr

          lda temp2
          cmp # 1
          bne IHRP_UseStandardGuard
          jmp IHRP_ProcessAttack

          jmp StandardGuard

.pend

IHRP_CheckGuardRelease .proc
          ;; DOWN released - check for early guard release (inlined to save 2 bytes)
          ;; let temp6 = playerState[temp1] & PlayerStateBitGuarding         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6
          ;; Not guarding, nothing to do
          lda temp6
          bne StopGuardEarly
          jmp IHRP_ProcessAttack
StopGuardEarly:

          ;; Stop guard early and start cooldown
          ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          ;; Start cooldown timer
          lda temp1
          asl
          tax
          lda GuardTimerMaxFrames
          sta playerTimers_W,x

.pend

IHRP_ProcessAttack .proc
          ;; Process attack input
          ;; Cross-bank call to ProcessAttackInput in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ProcessAttackInput-1)
          pha
          lda # <(ProcessAttackInput-1)
          pha
                    ldx # 9
          jmp BS_jsr

InputDoneRightPortAttack

          rts
.pend

