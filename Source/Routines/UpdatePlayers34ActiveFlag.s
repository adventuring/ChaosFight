;;; ChaosFight - Source/Routines/UpdatePlayers34ActiveFlag.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdatePlayers34ActiveFlag .proc
          ;; Update Players34Active flag when players 3/4 are present.
          ;; Returns: Far (return otherbank)
          ;; Input: playerCharacter[] (global array), playerHealth[], controllerStatus
          ;; Output: controllerStatus updated with Players34Active flag
          ;; Clear flag first
          lda controllerStatus
          and ClearPlayers34Active
          sta controllerStatus

          ;; Check if Player 3 is active (selected and not eliminated)

                    ;; if playerCharacter[2] = NoCharacter then CheckPlayer4ActiveFlag
                    ;; if playerHealth[2] = 0 then CheckPlayer4ActiveFlag
          ;; lda # 2 (duplicate)
          asl
          tax
          ;; lda playerHealth,x (duplicate)
          bne skip_7632
          jmp CheckPlayer4ActiveFlag
skip_7632:
          ;; Player 3 is active
          ;; lda controllerStatus (duplicate)
          ora SetPlayers34Active
          ;; sta controllerStatus (duplicate)

.pend

CheckPlayer4ActiveFlag .proc
          ;; Check if Player 4 is active (selected and not eliminated)
          ;; Returns: Far (return otherbank)
                    ;; if playerCharacter[3] = NoCharacter then UpdatePlayers34ActiveDone
                    ;; if playerHealth[3] = 0 then UpdatePlayers34ActiveDone
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_3251 (duplicate)
          ;; jmp UpdatePlayers34ActiveDone (duplicate)
skip_3251:
          ;; Player 4 is active
          ;; lda controllerStatus (duplicate)
          ;; ora SetPlayers34Active (duplicate)
          ;; sta controllerStatus (duplicate)
UpdatePlayers34ActiveDone
          ;; Returns: Far (return otherbank)
;; UpdatePlayers34ActiveDone (duplicate)
          jsr BS_return


.pend

