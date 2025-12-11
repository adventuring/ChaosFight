;;; ChaosFight - Source/Routines/ProcessAttackInput.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




ProcessAttackInput .proc




          ;;
          ;; Returns: Far (return otherbank)

          ;; Shared Attack Input Handler

          ;; Handles attack input (fire button) for both ports

          ;; Uses temp1 & 2 pattern to select joy0 vs joy1

          ;;
          ;; INPUT: temp1 = player index (0-3), temp2 = cached animation sta


          ;; Uses: joy0fire for players 0,2; joy1fire for players 1,3

          ;;
          ;; OUTPUT: Attack executed if conditions met

          ;;
          ;; Mutates: temp2, temp4, playerCharacter[]

          ;;
          ;; Called Routines: DispatchCharacterAttack (bank10)

          ;;
          ;; Constraints: Must be colocated with PAI_UseJoy0 helper

          ;; Process attack input

          ;; Map MethHound (31) to ShamoneAttack handler

          ;; Use cached animation state - block attack input during attack

          ;; animations (states 13-15)

          ;; Block attack input during attack windup/execute/recovery

          jmp BS_return

          ;; Check if player is guarding - guard blocks attacks

          ;; Set temp2 = playerState[temp1] & 2
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Guarding - block attack input

          jmp BS_return

          ;; Determine which joy port to use based on player index



          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          ;; Players 1,3 use joy1
          ;; If temp1 & 2 = 0, then PAI_UseJoy0
          lda temp1
          and # 2
          bne PAI_UseJoy1
          jmp PAI_UseJoy0

PAI_UseJoy1:
          jmp BS_return

          jmp PAI_ExecuteAttack



.pend

PAI_UseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          jmp BS_return



.pend

PAI_ExecuteAttack .proc
          ;; Returns: Far (return otherbank)

          jmp BS_return

          ;; Set temp4 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; Cross-bank call to DispatchCharacterAttack in bank 10
          lda # >(AfterDispatchCharacterAttack-1)
          pha
          lda # <(AfterDispatchCharacterAttack-1)
          pha
          lda # >(DispatchCharacterAttack-1)
          pha
          lda # <(DispatchCharacterAttack-1)
          pha
                    ldx # 9
          jmp BS_jsr
AfterDispatchCharacterAttack:


          jmp BS_return



.pend

