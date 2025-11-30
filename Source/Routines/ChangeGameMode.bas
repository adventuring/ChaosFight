ChangeGameMode
          rem Returns: Far (return otherbank)
          asm

ChangeGameMode



end
          rem
          rem Returns: Far (return otherbank)
          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem Change Game Mode
          rem Centralized game mode switching dispatcher.
          rem Calls appropriate Begin* setup routine for the new
          rem   gameMode.
          rem After setup completes, MainLoop dispatches to the
          rem   appropriate loop.
          rem Centralized game mode switching dispatcher
          rem
          rem Input: gameMode (global) = target game mode (0-8)
          rem
          rem Output: Dispatches to appropriate Setup* routine
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: Various Begin* routines (see Setup*
          rem functions below)
          rem
          rem Constraints: Must be colocated with all Setup* functions
          rem (called via if...goto)
          rem Use on...goto with near thunks (on...goto is near-call-only)
          rem Thunks ensure labels resolve correctly within same bank
          rem Thunks are placed at end of file to prevent fall-through
          on gameMode goto CGM_ThunkPublisherPrelude CGM_ThunkAuthorPrelude CGM_ThunkTitle CGM_ThunkCharacterSelect CGM_ThunkFallingAnimation CGM_ThunkArenaSelect CGM_ThunkGame CGM_ThunkWinner CGM_ThunkAttract
          rem Safety exit if gameMode is invalid
          return otherbank

SetupPublisherPrelude
          rem Setup Publisher Prelude mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: gameMode (global) = ModePublisherPrelude (0)
          rem
          rem Output: Publisher prelude state initialized
          rem
          rem Mutates: Publisher prelude state variables (via
          rem BeginPublisherPrelude)
          rem
          rem Called Routines: BeginPublisherPrelude (bank14) - accesses
          rem prelude state
          rem Constraints: Must be colocated with ChangeGameMode
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginPublisherPrelude

          return otherbank

SetupAuthorPrelude
          rem Setup Author Prelude mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: gameMode (global) = ModeAuthorPrelude (1)
          rem
          rem Output: Author prelude state initialized
          rem
          rem Mutates: Author prelude state variables (via
          rem BeginAuthorPrelude)
          rem
          rem Called Routines: BeginAuthorPrelude (bank14) - accesses
          rem prelude state
          rem Constraints: Must be colocated with ChangeGameMode
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginAuthorPrelude

          return otherbank

SetupTitle
          rem Setup Title Screen mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: gameMode (global) = ModeTitle (2)
          rem
          rem Output: Title screen state initialized
          rem
          rem Mutates: Title screen state variables (via
          rem BeginTitleScreen)
          rem
          rem Called Routines: BeginTitleScreen (bank14) - accesses title
          rem screen state
          rem Constraints: Must be colocated with ChangeGameMode
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginTitleScreen

          return otherbank

SetupCharacterSelect
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem Returns: Far (return otherbank)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          return otherbank

SetupFallingAnimation
          rem Character select uses its own internal flow
          rem Returns: Far (return otherbank)
          rem No separate Begin function needed - setup is handled
          rem   inline
          rem
          rem Input: gameMode (global) = ModeCharacterSelect (3)
          rem
          rem Output: None (character select handles its own setup)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with ChangeGameMode
          rem Setup Falling Animation mode
          rem
          rem Input: gameMode (global) = ModeFallingAnimation (4)
          rem
          rem Output: Falling animation state initialized
          rem
          rem Mutates: Falling animation state variables (via
          rem BeginFallingAnimation)
          rem
          rem Called Routines: BeginFallingAnimation (bank12) - accesses
          rem animation state
          rem Constraints: Must be colocated with ChangeGameMode
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginFallingAnimation bank12

          return otherbank

SetupArenaSelect
          rem Setup Arena Select mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: gameMode (global) = ModeArenaSelect (5)
          rem
          rem Output: Arena select state initialized
          rem
          rem Mutates: Arena select state variables (via
          rem BeginArenaSelect)
          rem
          rem Called Routines: BeginArenaSelect (bank12) - accesses
          rem arena select state
          rem Constraints: Must be colocated with ChangeGameMode
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginArenaSelect bank12

          return otherbank

SetupGame
          rem Setup Game mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: gameMode (global) = ModeGame (6)
          rem
          rem Output: Game state initialized
          rem
          rem Mutates: Game state variables (via BeginGameLoop)
          rem
          rem Called Routines: BeginGameLoop (bank11) - accesses game
          rem state
          rem
          rem Constraints: Must be colocated with ChangeGameMode
          rem BeginGameLoop resets gameplay state and returns
          rem MainLoop will dispatch to GameMainLoop when gameMode = ModeGame
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginGameLoop bank11

          return otherbank

SetupWinner
          rem Setup Winner Announcement mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: gameMode (global) = ModeWinner (7)
          rem
          rem Output: Winner announcement state initialized
          rem
          rem Mutates: Winner announcement state variables (via
          rem BeginWinnerAnnouncement)
          rem
          rem Called Routines: BeginWinnerAnnouncement (bank12) -
          rem accesses winner state
          rem Constraints: Must be colocated with ChangeGameMode
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginWinnerAnnouncement bank12

          return otherbank

SetupAttract
          rem Setup Attract Mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: gameMode (global) = ModeAttract (8)
          rem
          rem Output: Attract mode state initialized
          rem
          rem Mutates: Attract mode state variables (via
          rem BeginAttractMode)
          rem
          rem Called Routines: BeginAttractMode (bank14) - accesses
          rem attract mode state
          rem Constraints: Must be colocated with ChangeGameMode
          rem CRITICAL: on gameMode goto pushes 2 bytes then immediately pops them (net zero)
          rem ChangeGameMode is called cross-bank, so all return otherbank paths must use return otherbank
          gosub BeginAttractMode

          return otherbank
          rem ============================================================
          rem Near thunks for on...goto jump table
          rem Placed at end to prevent accidental fall-through
          rem ============================================================

CGM_ThunkPublisherPrelude
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupPublisherPrelude

CGM_ThunkAuthorPrelude
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupAuthorPrelude

CGM_ThunkTitle
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupTitle

CGM_ThunkCharacterSelect
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupCharacterSelect

CGM_ThunkFallingAnimation
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupFallingAnimation

CGM_ThunkArenaSelect
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupArenaSelect

CGM_ThunkGame
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupGame

CGM_ThunkWinner
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupWinner

CGM_ThunkAttract
          rem Near thunk - same bank jump
          rem Returns: Far (return otherbank)
          goto SetupAttract
