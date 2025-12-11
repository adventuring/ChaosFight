;;; ChaosFight - Source/Routines/DisplayHealth.s

;;; Copyright © 2025 Bruce-Robert Pocock.

DisplayHealth .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;;
          ;; Display Health
          ;;
          ;; Health display is handled by HealthBarSystem (UpdatePlayer12HealthBars,
          ;; UpdatePlayer34HealthBars). This routine is a no-op placeholder for
          ;; compatibility with existing call sites.
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          jmp BS_return

.pend

