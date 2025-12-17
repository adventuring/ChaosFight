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
          ;; Set temp2 = playerState[temp1] / 16
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; Block movement during attack windup/execute/recovery
          ;; if temp2 >= 13 then jmp DoneRightPortMovement
          lda temp2
          cmp # 13

          bcc IHRP_CheckGuardStatus

          jmp DoneRightPortMovement

IHRP_CheckGuardStatus:

          ;; Process left/right movement (with playfield collision for
          ;; flying characters)
          ;; Check if player is guarding - guard blocks movement
          ;; Set temp6 = playerState[temp1] & 2
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6
          ;; Guarding - block movement
          ;; if temp6 then jmp DoneRightPortMovement
          lda temp6
          beq IHRP_CheckFlyingCharacter

          jmp DoneRightPortMovement

IHRP_CheckFlyingCharacter:

          ;; Frooty (8) and Dragon of Storms (2) need collision checks
          ;; for horizontal movement
          ;; Set temp5 = playerCharacter[temp1]
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
          ;; Cross-bank call to ProcessStandardMovement in bank 12
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(IHRPF_ProcessStandardMovementReturn-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: IHRPF_ProcessStandardMovementReturn hi (encoded)]
          lda # <(IHRPF_ProcessStandardMovementReturn-1)
          pha
          ;; STACK PICTURE: [SP+1: IHRPF_ProcessStandardMovementReturn hi (encoded)] [SP+0: IHRPF_ProcessStandardMovementReturn lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ProcessStandardMovement-1)
          pha
          ;; STACK PICTURE: [SP+2: IHRPF_ProcessStandardMovementReturn hi (encoded)] [SP+1: IHRPF_ProcessStandardMovementReturn lo] [SP+0: ProcessStandardMovement hi (raw)]
          lda # <(ProcessStandardMovement-1)
          pha
          ;; STACK PICTURE: [SP+3: IHRPF_ProcessStandardMovementReturn hi (encoded)] [SP+2: IHRPF_ProcessStandardMovementReturn lo] [SP+1: ProcessStandardMovement hi (raw)] [SP+0: ProcessStandardMovement lo]
          ldx # 12
          jmp BS_jsr
IHRPF_ProcessStandardMovementReturn:


DoneRightPortMovement

IHRP_FlyingMovement .proc
          ;; Tail call: jmp instead of cross-bank call to to save 2 bytes on sta
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
          ;; Set temp4 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4
          ;; if temp4 >= 32 then jmp IHRP_ProcessAttack
          lda temp4
          cmp # 32

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
          ;; Cross-bank call to RoboTitoDown in bank 12
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(AfterRoboTitoDownRightPort-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRoboTitoDownRightPort hi (encoded)]
          lda # <(AfterRoboTitoDownRightPort-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRoboTitoDownRightPort hi (encoded)] [SP+0: AfterRoboTitoDownRightPort lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRoboTitoDownRightPort hi (encoded)] [SP+1: AfterRoboTitoDownRightPort lo] [SP+0: RoboTitoDown hi (raw)]
          lda # <(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRoboTitoDownRightPort hi (encoded)] [SP+2: AfterRoboTitoDownRightPort lo] [SP+1: RoboTitoDown hi (raw)] [SP+0: RoboTitoDown lo]
          ldx # 12
          jmp BS_jsr
AfterRoboTitoDownRightPort:

          lda temp2
          cmp # 1
          bne IHRP_UseStandardGuard
          jmp IHRP_ProcessAttack

          jmp StandardGuard

.pend

IHRP_CheckGuardRelease .proc
          ;; DOWN released - check for early guard release (inlined to save 2 bytes)
          ;; Set temp6 = playerState[temp1] & PlayerStateBitGuarding
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
          ;; Cross-bank call to ProcessAttackInput in bank 9
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(InputDoneRightPortAttack-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: InputDoneRightPortAttack hi (encoded)]
          lda # <(InputDoneRightPortAttack-1)
          pha
          ;; STACK PICTURE: [SP+1: InputDoneRightPortAttack hi (encoded)] [SP+0: InputDoneRightPortAttack lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ProcessAttackInput-1)
          pha
          ;; STACK PICTURE: [SP+2: InputDoneRightPortAttack hi (encoded)] [SP+1: InputDoneRightPortAttack lo] [SP+0: ProcessAttackInput hi (raw)]
          lda # <(ProcessAttackInput-1)
          pha
          ;; STACK PICTURE: [SP+3: InputDoneRightPortAttack hi (encoded)] [SP+2: InputDoneRightPortAttack lo] [SP+1: ProcessAttackInput hi (raw)] [SP+0: ProcessAttackInput lo]
          ldx # 9
          jmp BS_jsr

InputDoneRightPortAttack:

          rts
.pend

