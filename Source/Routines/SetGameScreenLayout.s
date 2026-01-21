
SetGameScreenLayout .proc
          ;; Set screen layout for all screens (32×8) with health bar
          ;; Returns: Far (return otherbank)
          ;; space
          ;;
          ;; Input: None
          ;;
          ;; Output: pfrowheight set to ScreenPfRowHeight, pfrows set to ScreenPfRows
          ;;
          ;; Mutates: pfrowheight (set to ScreenPfRowHeight), pfrows (set to ScreenPfRows)
          ;;
          ;; Called Routines: None
          ;; Constraints: Called for all screen layouts
          lda # ScreenPfRowHeight
          sta pfrowheight
          lda # ScreenPfRows
          sta pfrows
          jmp BS_return

.pend

