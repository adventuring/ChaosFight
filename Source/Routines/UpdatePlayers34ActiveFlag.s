;;; ChaosFight - Source/Routines/UpdatePlayers34ActiveFlag.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdatePlayers34ActiveFlag .proc
          ;; Update Players34Active flag when players 3/4 are present.
          ;; Returns: Far (return otherbank)
          ;; Input: playerCharacter[] (global array), playerHealth[], controllerStatus
          ;; Output: controllerStatus updated with Players34Active flag
          ;; Clear flag first
          lda controllerStatus
          and # ClearPlayers34Active
          sta controllerStatus

          ;; Check if Player 3 is active (selected and not eliminated)
          ;; If playerCharacter[2] = NoCharacter, then CheckPlayer4ActiveFlag
          lda # 2
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          beq CheckPlayer4ActiveFlag
          ;; If playerHealth[2] = 0, then CheckPlayer4ActiveFlag
          lda # 2
          asl
          tax
          lda playerHealth,x
          beq CheckPlayer4ActiveFlag
          lda # 2
          asl
          tax
          lda playerHealth,x
          bne SetPlayer3Active

          jmp CheckPlayer4ActiveFlag

SetPlayer3Active:
          ;; Player 3 is active
          lda controllerStatus
          ora # SetPlayers34Active
          sta controllerStatus

.pend

CheckPlayer4ActiveFlag .proc
          ;; Check if Player 4 is active (selected and not eliminated)
          ;; Returns: Far (return otherbank)
          ;; If playerCharacter[3] = NoCharacter, then UpdatePlayers34ActiveDone
          lda # 3
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          beq UpdatePlayers34ActiveDone
          ;; If playerHealth[3] = 0, then UpdatePlayers34ActiveDone
          lda # 3
          asl
          tax
          lda playerHealth,x
          bne SetPlayer4Active

          jmp UpdatePlayers34ActiveDone

SetPlayer4Active:
          ;; Player 4 is active
          lda controllerStatus
          ora # SetPlayers34Active
          sta controllerStatus

UpdatePlayers34ActiveDone:
          ;; Returns: Far (return otherbank)
          jmp BS_return

.pend

