;;; ChaosFight - Source/Routines/ProcessJumpInput.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


ProcessJumpInput .proc

          ;;
          ;; Returns: Far (return otherbank)
          ;; Shared Jump Input Handler
          ;; Handles jump input from enhanced buttons (Genesis Button C, Joy2B+ Button II)
          ;; UP = Button C = Button II (no exceptions)
          ;;
          ;; INPUT: temp1 = player index (0-3), temp2 = cached animation sta

          ;;
          ;; OUTPUT: Jump or character-specific behavior executed if conditions met
          ;;
          ;; Mutates: temp3, temp4, temp6, playerCharacter[], playerState[],
          ;; playerY[], characterStateFlags_W[]
          ;;
          ;; Called Routines: CheckEnhancedJumpButton (bank10),
          ;; ProcessUpAction (thisbank) - executes character-specific behavior
          ;;
          ;; Constraints: Must be colocated with ProcessUpAction in same bank

          ;; Check enhanced button first (sets temp3 = 1 if pressed, 0 otherwise)
          ;; Check Genesis/Joy2b+ Button C/II
          ;; Cross-bank call to CheckEnhancedJumpButton in bank 10
          lda # >(return_point-1)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckEnhancedJumpButton-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckEnhancedJumpButton-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 9
          jmp BS_jsr
return_point:


          ;; If enhanced button not pressed, return (no action)
          jsr BS_return

          ;; Execute character-specific UP action (UP = Button C = Button II)
          ;; jsr ProcessUpAction (duplicate)

          ;; jsr BS_return (duplicate)

.pend

