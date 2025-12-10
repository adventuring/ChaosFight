;;; ChaosFight - Source/Routines/InputHandleLeftPortPlayerFunction.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

InputHandleLeftPortPlayerFunction:

          ;;
          ;; LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)
          ;;
          ;; INPUT: temp1 = player index (0 or 2)
          ;; USES: joy0left, joy0right, joy0up, joy0down, joy0fire
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
          ;; if temp2 >= 13 then goto DoneLeftPortMovement
          lda temp2
          cmp # 13

          bcc skip_243

          jmp DoneLeftPortMovement

skip_243:

          ;; Process left/right movement (with playfield collision for
          ;; flying characters)
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
          bne skip_33

          jmp IHLP_FlyingMovement

skip_33:

          lda temp5
          cmp # 2
          bne skip_4346

          jmp IHLP_FlyingMovement

skip_4346:

          ;; Standard horizontal movement (uses shared routine)
          ;; Cross-bank call to ProcessStandardMovement in bank 13
          lda # >(return_point_1-1)
          pha
          lda # <(return_point_1-1)
          pha
          lda # >(ProcessStandardMovement-1)
          pha
          lda # <(ProcessStandardMovement-1)
          pha
          ldx # 12
          jmp BS_jsr

return_point_1:

DoneLeftPortMovement:

IHLP_FlyingMovement .proc
          ;; Tail call: goto instead of gosub to save 2 bytes on sta

          jmp HandleFlyingCharacterMovement

IHLP_DoneFlyingLeftRight:

          ;; Process UP input for character-specific behaviors
          ;; Returns with temp3 = 1 if UP used for jump, 0 if special ability
          jsr HandleUpInput

          ;; Process jump input from enhanced buttons (must be identical
          ;; effect to HandleUpInput for all characters)
          ;; Cross-bank call to ProcessJumpInput in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ProcessJumpInput-1)
          pha
          lda # <(ProcessJumpInput-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:

InputDoneLeftPortJump

          ;; Process down/guard input
          ;; Cross-bank call to HandleGuardInput in bank 12
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(HandleGuardInput-1)
          pha
          lda # <(HandleGuardInput-1)
          pha
                    ldx # 11
          jmp BS_jsr
return_point_ihlpf2:


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
return_point_ihlpf3:

InputDoneLeftPortAttack

          rts
.pend

