
BeginAttractMode .proc

          ;;
          ;; ChaosFight - Source/Routines/BeginAttractMode.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; BEGIN ATTRACT MODE - Setup Routine
          ;;
          ;; Setup routine for Attract Mode. Sets initial state only.
          ;; Called from ChangeGameMode when transitioning to
          ;; ModeAttract.
          ;; Attract mode is entered after 3 minutes of title screen
          ;; inactivity.
          ;; It automatically loops back to Publisher Prelude to
          ;; restart the sequence.
          ;; Setup routine for Attract Mode - sets initial state only
          ;;
          ;; Input: None (called from ChangeGameMode)
          ;;
          ;; Output: COLUBK set
          ;;
          ;; Mutates: COLUBK (TIA register)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Called from ChangeGameMode when transitioning
          ;; to ModeAttract
          ;; Attract mode immediately transitions to
          ;; Publisher Prelude (handled in AttractMode
          ;; loop)
          ;; Initialize Attract Mode
          ;; Background: black (COLUBK starts black, no need to set)
          ;; BeginAttractMode is called cross-bank from SetupAttract
          ;; (cross-bank call to BeginAttractMode bank14 forces BS_jsr even though same bank)
          ;; so it must return with return otherbank to match
          jmp BS_return
          ;; Reset title screen timers for next cycle
          ;; titleParadeTimer will be reset when we return to title
          ;; screen
          ;; Note: Attract mode immediately transitions to Publisher
          ;; Prelude
          ;; This is handled in the AttractMode loop

.pend

