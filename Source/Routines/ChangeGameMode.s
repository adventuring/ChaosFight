
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
          ;; Use on...goto with near thunks (on...goto is near-call-only)
          ;; Thunks ensure labels resolve correctly within same bank
          ;; Thunks are placed at end of file to prevent fall-through
          ;; Note: on...goto pushes 2 bytes then immediately pops them (net zero stack change)
          jmp CGM_ThunkPublisherPrelude
          ;; Safety exit if gameMode is invalid
          jsr BS_return

.pend

SetupPublisherPrelude .proc
          ;; Setup Publisher Prelude mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModePublisherPrelude (0)
          ;;
          ;; Output: Publisher prelude state initialized
          ;;
          ;; Mutates: Publisher prelude state variables (via
          ;; BeginPublisherPrelude)
          ;;
          ;; Called Routines: BeginPublisherPrelude (bank14) - accesses
          ;; prelude sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta

          ;; jmp BeginPublisherPrelude (duplicate)

.pend

SetupAuthorPrelude .proc
          ;; Setup Author Prelude mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeAuthorPrelude (1)
          ;;
          ;; Output: Author prelude state initialized
          ;;
          ;; Mutates: Author prelude state variables (via
          ;; BeginAuthorPrelude)
          ;;
          ;; Called Routines: BeginAuthorPrelude (bank14) - accesses
          ;; prelude sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta

          ;; jmp BeginAuthorPrelude (duplicate)

.pend

SetupTitle .proc
          ;; Setup Title Screen mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: gameMode (global) = ModeTitle (2)
          ;;
          ;; Output: Title screen state initialized
          ;;
          ;; Mutates: Title screen state variables (via
          ;; BeginTitleScreen)
          ;;
          ;; Called Routines: BeginTitleScreen (bank14) - accesses title
          ;; screen sta

          ;; Constraints: Must be colocated with ChangeGameMode
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta

          ;; jmp BeginTitleScreen (duplicate)

.pend

SetupCharacterSelect .proc
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; Returns: Far (return otherbank)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; jsr BS_return (duplicate)

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
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; Cross-bank call to BeginFallingAnimation in bank 14
          lda # >(return_point-1)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BeginFallingAnimation-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BeginFallingAnimation-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 13
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; jsr BS_return (duplicate)

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
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; Cross-bank call to BeginArenaSelect in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BeginArenaSelect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BeginArenaSelect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; Cross-bank call to BeginGameLoop in bank 11
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BeginGameLoop-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BeginGameLoop-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 10 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; Cross-bank call to BeginWinnerAnnouncement in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BeginWinnerAnnouncement-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BeginWinnerAnnouncement-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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
          ;; CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          ;; ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          ;; OPTIMIZATION: Tail call to save 4 bytes on sta

          ;; jmp BeginAttractMode (duplicate)
          ;; ============================================================
          ;; Near thunks for on...goto jump table
          ;; Placed at end to prevent accidental fall-through
          ;; ============================================================

.pend

CGM_ThunkPublisherPrelude .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupPublisherPrelude (duplicate)

.pend

CGM_ThunkAuthorPrelude .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupAuthorPrelude (duplicate)

.pend

CGM_ThunkTitle .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupTitle (duplicate)

.pend

CGM_ThunkCharacterSelect .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupCharacterSelect (duplicate)

CGM_ThunkFallingAnimation
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupFallingAnimation (duplicate)

.pend

CGM_ThunkArenaSelect .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupArenaSelect (duplicate)

.pend

CGM_ThunkGame .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupGame (duplicate)

.pend

CGM_ThunkWinner .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupWinner (duplicate)

.pend

CGM_ThunkAttract .proc
          ;; Near thunk - same bank jump
          ;; Returns: Far (return otherbank)
          ;; jmp SetupAttract (duplicate)

.pend

