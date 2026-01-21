
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
          ;; Only reachable via cross-bank call to from MainLoop
          ;; Set gameMode = ModePublisherPrelude cross-bank call to ChangeGameMode bank14
          lda # ModePublisherPrelude
          sta gameMode
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterChangeGameModeAttract-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterChangeGameModeAttract hi (encoded)]
          lda # <(AfterChangeGameModeAttract-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterChangeGameModeAttract hi (encoded)] [SP+0: AfterChangeGameModeAttract lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterChangeGameModeAttract hi (encoded)] [SP+1: AfterChangeGameModeAttract lo] [SP+0: ChangeGameMode hi (raw)]
          lda # <(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterChangeGameModeAttract hi (encoded)] [SP+2: AfterChangeGameModeAttract lo] [SP+1: ChangeGameMode hi (raw)] [SP+0: ChangeGameMode lo]
          ldx # 13
          jmp BS_jsr

AfterChangeGameModeAttract:

          rts

.pend

