
ChangeGameMode .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; ChaosFight - Source/Routines/ChangeGameMode.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; Change Game Mode
          ;; Centralized game mode switching dispatcher.
          ;; Calls appropriate Begin* setup routine for the new
          ;; gameMode.
          ;; After setup completes, MainLoop dispatches to the
          ;; appropriate loop.
          ;; Centralized game mode switching dispatcher
          ;;
          ;; Input: gameMode (global) = target game mode (0-8)
          ;;
          ;; Output: Dispatches to appropriate Setup* routine
          ;;
          ;; Mutates: None (dispatcher only)
          ;;
          ;; Called Routines: Various Begin* routines (see Setup*
          ;; functions below)
          ;;
          ;; Constraints: Must be colocated with all Setup* functions
          ;; (called via if...goto)
          ;; Use on...jmp with near thunks (on...jmp is near-call-only)
          ;; Thunks ensure labels resolve correctly within same bank
          ;; Thunks are placed at end of file to prevent fall-through
          ;; Note: on...jmp pushes 2 bytes then immediately pops them (net zero stack change)
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call (cross-bank call)
          jmp ThunkPublisherPrelude

          ;; Safety exit if gameMode is invalid
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call
          jmp BS_return

.pend

SetupPublisherPrelude .proc
          ;; Setup Publisher Prelude mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModePublisherPrelude (0)
          ;;
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;;
          ;; Output: Publisher prelude state initialized
          ;;
          ;; Mutates: Publisher prelude state variables (via
          ;; BeginPublisherPrelude)
          ;;
          ;; Called Routines: BeginPublisherPrelude (bank14) - accesses
          ;; prelude sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (tail call preserves stack, BeginPublisherPrelude will use BS_return)

          jmp BeginPublisherPrelude

.pend

SetupAuthorPrelude .proc
          ;; Setup Author Prelude mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeAuthorPrelude (1)
          ;;
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;;
          ;; Output: Author prelude state initialized
          ;;
          ;; Mutates: Author prelude state variables (via
          ;; BeginAuthorPrelude)
          ;;
          ;; Called Routines: BeginAuthorPrelude (bank14) - accesses
          ;; prelude sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (tail call preserves stack, BeginAuthorPrelude will use BS_return)

          jmp BeginAuthorPrelude

.pend

SetupTitle .proc
          ;; Setup Title Screen mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeTitle (2)
          ;;
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;;
          ;; Output: Title screen state initialized
          ;;
          ;; Mutates: Title screen state variables (via
          ;; BeginTitleScreen)
          ;;
          ;; Called Routines: BeginTitleScreen (bank14) - accesses title
          ;; screen sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (tail call preserves stack, BeginTitleScreen will use BS_return)

          jmp BeginTitleScreen

.pend

SetupCharacterSelect .proc
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; Returns: Far (return otherbank)
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call
          jmp BS_return

SetupFallingAnimation
          ;; Character select uses its own internal flow
          ;; Returns: Far (return otherbank)
          ;; No separate Begin function needed - setup is handled
          ;; inline
          ;;
          ;; Input: gameMode (global) = ModeCharacterSelect (3)
          ;;
          ;; Output: None (character select handles its own setup)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with ChangeGameMode
          ;; Setup Falling Animation mode
          ;;
          ;; Input: gameMode (global) = ModeFallingAnimation (4)
          ;;
          ;; Output: Falling animation state initialized
          ;;
          ;; Mutates: Falling animation state variables (via
          ;; BeginFallingAnimation)
          ;;
          ;; Called Routines: BeginFallingAnimation (bank12) - accesses
          ;; animation sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;; Cross-bank call to BeginFallingAnimation in bank 14
          lda # >(AfterBeginFallingAnimation-1)
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterBeginFallingAnimation hi]
          lda # <(AfterBeginFallingAnimation-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterBeginFallingAnimation hi] [SP+0: AfterBeginFallingAnimation lo]
          lda # >(BeginFallingAnimation-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterBeginFallingAnimation hi] [SP+1: AfterBeginFallingAnimation lo] [SP+0: BeginFallingAnimation hi]
          lda # <(BeginFallingAnimation-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterBeginFallingAnimation hi] [SP+2: AfterBeginFallingAnimation lo] [SP+1: BeginFallingAnimation hi] [SP+0: BeginFallingAnimation lo]
                    ldx # 13
          jmp BS_jsr
AfterBeginFallingAnimation:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from BeginFallingAnimation call, left original 4 bytes)


          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend

SetupArenaSelect .proc
          ;; Setup Arena Select mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeArenaSelect (5)
          ;;
          ;; Output: Arena select state initialized
          ;;
          ;; Mutates: Arena select state variables (via
          ;; BeginArenaSelect)
          ;;
          ;; Called Routines: BeginArenaSelect (bank12) - accesses
          ;; arena select sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;; Cross-bank call to BeginArenaSelect in bank 14
          lda # >(AfterBeginArenaSelect-1)
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterBeginArenaSelect hi]
          lda # <(AfterBeginArenaSelect-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterBeginArenaSelect hi] [SP+0: AfterBeginArenaSelect lo]
          lda # >(BeginArenaSelect-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterBeginArenaSelect hi] [SP+1: AfterBeginArenaSelect lo] [SP+0: BeginArenaSelect hi]
          lda # <(BeginArenaSelect-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterBeginArenaSelect hi] [SP+2: AfterBeginArenaSelect lo] [SP+1: BeginArenaSelect hi] [SP+0: BeginArenaSelect lo]
                    ldx # 13
          jmp BS_jsr
AfterBeginArenaSelect:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from BeginArenaSelect call, left original 4 bytes)


          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend

SetupGame .proc
          ;; Setup Game mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeGame (6)
          ;;
          ;; Output: Game state initialized
          ;;
          ;; Mutates: Game state variables (via BeginGameLoop)
          ;;
          ;; Called Routines: BeginGameLoop (bank11) - accesses game
          ;; sta

          ;;
          ;; Constraints: Must be colocated with ChangeGameMode
          ;; BeginGameLoop resets gameplay state and returns
          ;; MainLoop will dispatch to GameMainLoop when gameMode = ModeGame
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;; Cross-bank call to BeginGameLoop in bank 11
          lda # >(AfterBeginGameLoop-1)
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterBeginGameLoop hi]
          lda # <(AfterBeginGameLoop-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterBeginGameLoop hi] [SP+0: AfterBeginGameLoop lo]
          lda # >(BeginGameLoop-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterBeginGameLoop hi] [SP+1: AfterBeginGameLoop lo] [SP+0: BeginGameLoop hi]
          lda # <(BeginGameLoop-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterBeginGameLoop hi] [SP+2: AfterBeginGameLoop lo] [SP+1: BeginGameLoop hi] [SP+0: BeginGameLoop lo]
                    ldx # 10
          jmp BS_jsr
AfterBeginGameLoop:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from BeginGameLoop call, left original 4 bytes)


          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend

SetupWinner .proc
          ;; Setup Winner Announcement mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeWinner (7)
          ;;
          ;; Output: Winner announcement state initialized
          ;;
          ;; Mutates: Winner announcement state variables (via
          ;; BeginWinnerAnnouncement)
          ;;
          ;; Called Routines: BeginWinnerAnnouncement (bank12) -
          ;; accesses winner sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;; Cross-bank call to BeginWinnerAnnouncement in bank 14
          lda # >(AfterBeginWinnerAnnouncement-1)
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterBeginWinnerAnnouncement hi]
          lda # <(AfterBeginWinnerAnnouncement-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterBeginWinnerAnnouncement hi] [SP+0: AfterBeginWinnerAnnouncement lo]
          lda # >(BeginWinnerAnnouncement-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterBeginWinnerAnnouncement hi] [SP+1: AfterBeginWinnerAnnouncement lo] [SP+0: BeginWinnerAnnouncement hi]
          lda # <(BeginWinnerAnnouncement-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterBeginWinnerAnnouncement hi] [SP+2: AfterBeginWinnerAnnouncement lo] [SP+1: BeginWinnerAnnouncement hi] [SP+0: BeginWinnerAnnouncement lo]
                    ldx # 13
          jmp BS_jsr
AfterBeginWinnerAnnouncement:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from BeginWinnerAnnouncement call, left original 4 bytes)


          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend

SetupAttract .proc
          ;; Setup Attract Mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeAttract (8)
          ;;
          ;; Output: Attract mode state initialized
          ;;
          ;; Mutates: Attract mode state variables (via
          ;; BeginAttractMode)
          ;;
          ;; Called Routines: BeginAttractMode (bank14) - accesses
          ;; attract mode sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode jmp pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack (on...jmp net zero change, preserves original stack)
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (tail call preserves stack, BeginAttractMode will use BS_return)

          jmp BeginAttractMode
          ;; ============================================================
          ;; Near thunks for on...jmp jump table
          ;; Placed at end to prevent accidental fall-through
          ;; ============================================================

.pend

ThunkPublisherPrelude .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupPublisherPrelude

.pend

ThunkAuthorPrelude .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupAuthorPrelude

.pend

ThunkTitle .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupTitle

.pend

ThunkCharacterSelect .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupCharacterSelect

ThunkFallingAnimation
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupFallingAnimation

.pend

ThunkArenaSelect .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupArenaSelect

.pend

ThunkGame .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupGame

.pend

ThunkWinner .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupWinner

.pend

ThunkAttract .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          jmp SetupAttract

.pend

