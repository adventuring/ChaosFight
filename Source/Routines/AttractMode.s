
AttractMode .proc
          ;;
;;; ChaosFight - Source/Routines/AttractMode.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; ATTRACT MODE LOOP - Called From Mainloop Each Frame
          ;;
          ;; This is the main loop that runs each frame during Attract
          ;; mode.
          ;; Called repeatedly from MainLoop dispatcher.
          ;; Setup is handled by BeginAttractMode (called from
          ;; ChangeGameMode).
          ;; Attract mode automatically transitions back to Publisher
          ;; Prelude
          ;; to restart the title sequence after 3 minutes of
          ;; inactivity.
          ;; Attract mode automatically loops back to Publisher Prelude
          ;; No user interaction - just transition immediately
          ;; This creates a continuous attract loop: Publisher → Author
          ;; → Title → Attract → (repeat)
          ;;
          ;; Input: None (called from MainLoop)
          ;;
          ;; Output: gameMode set to ModePublisherPrelude,
          ;; ChangeGameMode called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: ChangeGameMode (bank14) - accesses game
          ;; mode sta

          ;;
          ;; Constraints: Entry point for attract mode (called from
          ;; MainLoop)
          ;; Only reachable via gosub from MainLoop
                    ;; let gameMode = ModePublisherPrelude : gosub ChangeGameMode bank14
          lda ModePublisherPrelude
          sta gameMode
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
          ldx # 13
          jmp BS_jsr
return_point:

          rts

.pend

