;;; ChaosFight - Source/Routines/GetPlayerAnimationStateFunction.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

GetPlayerAnimationStateFunction
;;; Returns: Far (return otherbank)
;; GetPlayerAnimationStateFunction (duplicate)

          ;; Animation State Helper
          ;; Input: temp1 = player index (0-3), playerState[]
          ;; Output: temp2 = animation state (bits 4-7 of playerState)
          ;; Mutates: temp2 (used as return otherbank value)
          ;; Called Routines: None
          ;; Constraints: None
          ;; Shift right by 4 (divide by 16) to get animation sta

                    ;; let temp2 = playerState[temp1] / 16         
          lda temp1
          asl
          tax
          ;; lda playerState,x (duplicate)
          sta temp2
          ;; (0-15)
          jsr BS_return


