;;; ChaosFight - Source/Routines/InputHandleRightPortPlayerFunction.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

InputHandleRightPortPlayerFunction
;; InputHandleRightPortPlayerFunction (duplicate)

          ;;
          ;; RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
          ;;
          ;; INPUT: temp1 = player index (1 or 3)
          ;; USES: joy1left, joy1right, joy1up, joy1down, joy1fire
          ;; Cache animation state at start (used for movement, jump,
          lda temp1
          sta currentPlayer
          ;; and attack checks)
          ;; block movement during attack animations (states 13-15)
                    ;; let temp2 = playerState[temp1] / 16         
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; Block movement during attack windup/execute/recovery
          ;; if temp2 >= 13 then goto DoneRightPortMovement
          ;; lda temp2 (duplicate)
          cmp 13

          bcc skip_9612

          jmp skip_9612

          skip_9612:

          ;; Process left/right movement (with playfield collision for
          ;; flying characters)
          ;; Check if player is guarding - guard blocks movement
                    ;; let temp6 = playerState[temp1] & 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; Guarding - block movement
                    ;; if temp6 then goto DoneRightPortMovement
          ;; lda temp6 (duplicate)
          beq skip_7029
          ;; jmp DoneRightPortMovement (duplicate)
skip_7029:

          ;; Frooty (8) and Dragon of Storms (2) need collision checks
          ;; for horizontal movement
                    ;; let temp5 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp5 (duplicate)
          ;; cmp # 8 (duplicate)
          bne skip_3821
          ;; jmp IHRP_FlyingMovement (duplicate)
skip_3821:

          ;; lda temp5 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_2215 (duplicate)
          ;; jmp IHRP_FlyingMovement (duplicate)
skip_2215:


          ;; Standard horizontal movement (uses shared routine)
          ;; Cross-bank call to ProcessStandardMovement in bank 13
          ;; lda # >(return_point_1_L83-1) (duplicate)
          pha
          ;; lda # <(return_point_1_L83-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ProcessStandardMovement-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ProcessStandardMovement-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 12
          ;; jmp BS_jsr (duplicate)
return_point_1_L83:


DoneRightPortMovement

IHRP_FlyingMovement .proc
          ;; Tail call: goto instead of gosub to save 2 bytes on sta

          ;; jmp HandleFlyingCharacterMovement (duplicate)
IHRP_DoneFlyingLeftRight

          ;; Process UP input for character-specific behaviors
          ;; Returns with temp3 = 1 if UP used for jump, 0 if special ability
          jsr HandleUpInput

          ;; Process jump input from enhanced buttons (must be identical
          ;; effect to HandleUpInput for all characters)
          ;; Cross-bank call to ProcessJumpInput in bank 8
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ProcessJumpInput-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ProcessJumpInput-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 7 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

InputDoneRightPortJump

          ;; Process down/guard input (fully inlined to save 2 bytes on sta

          ;; Check joy1down (right port uses joy1)
          ;; lda joy1down (duplicate)
          ;; bne skip_8210 (duplicate)
          ;; jmp IHRP_CheckGuardRelease (duplicate)
skip_8210:


.pend

IHRP_HandleDownPressed .proc
          ;; DOWN pressed - dispatch to character-specific down handler
                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)
          ;; if temp4 >= 32 then goto IHRP_ProcessAttack
          ;; lda temp4 (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_104 (duplicate)

          ;; jmp skip_104 (duplicate)

          skip_104:
          ;; lda temp4 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_7070 (duplicate)
          ;; jmp DragonOfStormsDown (duplicate)
skip_7070:

          ;; lda temp4 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bne skip_7956 (duplicate)
          ;; jmp HarpyDown (duplicate)
skip_7956:

          ;; lda temp4 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bne skip_8836 (duplicate)
          ;; jmp FrootyDown (duplicate)
skip_8836:

          ;; lda temp4 (duplicate)
          ;; cmp # 13 (duplicate)
          ;; bne skip_4027 (duplicate)
          ;; jmp IHRP_HandleRoboTitoDown (duplicate)
skip_4027:

          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          ;; jmp StandardGuard (duplicate)

.pend

IHRP_HandleRoboTitoDown .proc
          ;; Cross-bank call to RoboTitoDown in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; lda temp2 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_9606 (duplicate)
          ;; jmp IHRP_ProcessAttack (duplicate)
skip_9606:

          ;; jmp StandardGuard (duplicate)

.pend

IHRP_CheckGuardRelease .proc
          ;; DOWN released - check for early guard release (inlined to save 2 bytes)
                    ;; let temp6 = playerState[temp1] & PlayerStateBitGuarding         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; Not guarding, nothing to do
          ;; lda temp6 (duplicate)
          ;; bne skip_8955 (duplicate)
          ;; jmp IHRP_ProcessAttack (duplicate)
skip_8955:

          ;; Stop guard early and start cooldown
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          ;; Start cooldown timer
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda GuardTimerMaxFrames (duplicate)
          ;; sta playerTimers_W,x (duplicate)

.pend

IHRP_ProcessAttack .proc
          ;; Process attack input
          ;; Cross-bank call to ProcessAttackInput in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ProcessAttackInput-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ProcessAttackInput-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

InputDoneRightPortAttack

          rts
.pend

