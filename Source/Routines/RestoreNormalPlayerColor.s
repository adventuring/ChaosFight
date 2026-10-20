;;; ChaosFight - Source/Routines/RestoreNormalPlayerColor.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


RestoreNormalPlayerColor .block
          ;; Provide shared entry point for restoring normal player colors
          ;; after guard tinting. Color reload executed by rendering code.
          ;;
          ;; Input: temp1 = player index (0-3)
          ;;
          ;; Output: None
          ;;
          ;; Mutates: temp4 (loads character index for downstream routines)
          ;; Set temp4 = playerCharacter[temp1]
          lda temp1
          tax
          lda playerCharacter,x
          sta temp4
          rts

.bend

