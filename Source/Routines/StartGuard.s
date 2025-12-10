;;; ChaosFight - Source/Routines/StartGuard.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


StartGuard:
.proc
          ;;
          ;; Start Guard
          ;; Activate guard state for the specified player.
          ;; Input: temp1 = player index (0-3)
          ;; GuardTimerMaxFrames (constant) = guard duration in
          ;; frames
          ;;
          ;; Output: playerState[] guard bit set, playerTimers_W[] set
          ;; to guard duration
          ;;
          ;; Mutates: playerState[] (guard bit set), playerTimers_W[]
          ;; (set to GuardTimerMaxFrames)
          ;;
          ;; Called Routines: None
          ;; Constraints: None
          ;; Set guard bit in playerState
          let playerState[temp1] = playerState[temp1] | 2

          ;; Set guard duration timer using GuardTimerMaxFrames (TV-standard aware)
          ;; Store guard duration timer in playerTimers array
          ;; This timer will be decremented each frame until it reaches 0
          lda temp1
          asl
          tax
          lda # GuardTimerMaxFrames
          sta playerTimers_W,x

          rts

.pend

