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
          ;; Set temp2 = playerState[temp1] / 16
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; Block movement during attack windup/execute/recovery
          ;; if temp2 >= 13 then jmp DoneLeftPortMovement
          lda temp2
          cmp # 13

          bcc CheckGuardStatus

          jmp DoneLeftPortMovement

CheckGuardStatus:

          ;; Process left/right movement (with playfield collision for
          ;; flying characters)
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
          bne CheckDragonOfStorms

          jmp IHLP_FlyingMovement

CheckDragonOfStorms:

          lda temp5
          cmp # 2
          bne IHLPF_ProcessStandardMovementLabel

          jmp IHLP_FlyingMovement

IHLPF_ProcessStandardMovementLabel:

          ;; Standard horizontal movement (uses shared routine)
          ;; Cross-bank call to ProcessStandardMovement in bank 12
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(IHLPF_ProcessStandardMovementReturn-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: IHLPF_ProcessStandardMovementReturn hi (encoded)]
          lda # <(IHLPF_ProcessStandardMovementReturn-1)
          pha
          ;; STACK PICTURE: [SP+1: IHLPF_ProcessStandardMovementReturn hi (encoded)] [SP+0: IHLPF_ProcessStandardMovementReturn lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ProcessStandardMovement-1)
          pha
          ;; STACK PICTURE: [SP+2: IHLPF_ProcessStandardMovementReturn hi (encoded)] [SP+1: IHLPF_ProcessStandardMovementReturn lo] [SP+0: ProcessStandardMovement hi (raw)]
          lda # <(ProcessStandardMovement-1)
          pha
          ;; STACK PICTURE: [SP+3: IHLPF_ProcessStandardMovementReturn hi (encoded)] [SP+2: IHLPF_ProcessStandardMovementReturn lo] [SP+1: ProcessStandardMovement hi (raw)] [SP+0: ProcessStandardMovement lo]
          ldx # 12
          jmp BS_jsr

IHLPF_ProcessStandardMovementReturn:

DoneLeftPortMovement:

IHLP_FlyingMovement .proc
          ;; Tail call: jmp instead of cross-bank call to to save 2 bytes on sta

          jmp HandleFlyingCharacterMovement

IHLP_DoneFlyingLeftRight:

          ;; Process UP input for character-specific behaviors
          ;; Returns with temp3 = 1 if UP used for jump, 0 if special ability
          jsr HandleUpInput

          ;; Process jump input from enhanced buttons (must be identical
          ;; effect to HandleUpInput for all characters)
          ;; Same-bank call to ProcessJumpInput (Bank 7) - saves 2 bytes vs cross-bank
          jsr ProcessJumpInput

InputDoneLeftPortJump

          ;; Process down/guard input
          ;; Cross-bank call to HandleGuardInput in bank 11
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(IHLPF_CCJReturn-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: IHLPF_CCJReturn hi (encoded)]
          lda # <(IHLPF_CCJReturn-1)
          pha
          ;; STACK PICTURE: [SP+1: IHLPF_CCJReturn hi (encoded)] [SP+0: IHLPF_CCJReturn lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(HandleGuardInput-1)
          pha
          ;; STACK PICTURE: [SP+2: IHLPF_CCJReturn hi (encoded)] [SP+1: IHLPF_CCJReturn lo] [SP+0: HandleGuardInput hi (raw)]
          lda # <(HandleGuardInput-1)
          pha
          ;; STACK PICTURE: [SP+3: IHLPF_CCJReturn hi (encoded)] [SP+2: IHLPF_CCJReturn lo] [SP+1: HandleGuardInput hi (raw)] [SP+0: HandleGuardInput lo]
          ldx # 11
          jmp BS_jsr
IHLPF_CCJReturn:


          ;; Process attack input
          ;; Cross-bank call to ProcessAttackInput in bank 9
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(IHLPF_ProcessAttackInputReturn-1)) & $0f) | $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: IHLPF_ProcessAttackInputReturn hi (encoded)]
          lda # <(IHLPF_ProcessAttackInputReturn-1)
          pha
          ;; STACK PICTURE: [SP+1: IHLPF_ProcessAttackInputReturn hi (encoded)] [SP+0: IHLPF_ProcessAttackInputReturn lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ProcessAttackInput-1)
          pha
          ;; STACK PICTURE: [SP+2: IHLPF_ProcessAttackInputReturn hi (encoded)] [SP+1: IHLPF_ProcessAttackInputReturn lo] [SP+0: ProcessAttackInput hi (raw)]
          lda # <(ProcessAttackInput-1)
          pha
          ;; STACK PICTURE: [SP+3: IHLPF_ProcessAttackInputReturn hi (encoded)] [SP+2: IHLPF_ProcessAttackInputReturn lo] [SP+1: ProcessAttackInput hi (raw)] [SP+0: ProcessAttackInput lo]
          ldx # 9
          jmp BS_jsr
IHLPF_ProcessAttackInputReturn:

InputDoneLeftPortAttack

          rts
.pend

