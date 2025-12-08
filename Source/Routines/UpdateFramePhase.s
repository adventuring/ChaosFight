;;; ChaosFight - Source/Routines/FramePhaseScheduler.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateFramePhase .proc
;;; Frame Budgeting System
          ;; Manages expensive operations across multiple frames to
          ;; ensure game logic never exceeds the overscan period.
          ;; Updates framePhase (0-3) once per frame to schedule multi-frame operations.
          ;;
          ;; Input: frame (global) = global frame counter
          ;;
          ;; Output: framePhase set to frame & 3 (cycles 0, 1, 2, 3, 0, 1, 2, 3...)
          ;;
          ;; Mutates: framePhase (set to frame & 3)
          ;;
          ;; Called Routines: None
          ;; Constraints: Called once per frame at the start of game loop
          ;; Cycle 0, 1, 2, 3, 0, 1, 2, 3...
          ;; ;; let framePhase = frame & 3
          lda frame
          and # 3
          sta framePhase

          ;; lda frame (duplicate)
          ;; and # 3 (duplicate)
          ;; sta framePhase (duplicate)

          rts



.pend

