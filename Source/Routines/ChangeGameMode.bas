ChangeGameMode
          rem
          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
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
          rem Optimized: Use on...goto instead of if-else chain
          on gameMode goto SetupPublisherPrelude SetupAuthorPrelude SetupTitle SetupCharacterSelect SetupFallingAnimation SetupArenaSelect SetupGame SetupWinner SetupAttract
          return
          
SetupPublisherPrelude
          rem Setup Publisher Prelude mode
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
          gosub BeginPublisherPrelude bank14
          return
          
SetupAuthorPrelude
          rem Setup Author Prelude mode
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
          gosub BeginAuthorPrelude bank14
          return
          
SetupTitle
          rem Setup Title Screen mode
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
          gosub BeginTitleScreen bank14
          return
          
SetupCharacterSelect
          return
SetupFallingAnimation
          rem Character select uses its own internal flow
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
          rem Called Routines: BeginFallingAnimation (bank6) - accesses
          rem animation state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginFallingAnimation bank6
          return
          
SetupArenaSelect
          rem Setup Arena Select mode
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
          gosub BeginArenaSelect bank12
          return

SetupGame
          rem Setup Game mode
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
          gosub BeginGameLoop bank11
          return

SetupWinner
          rem Setup Winner Announcement mode
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
          gosub BeginWinnerAnnouncement bank12
          return

SetupAttract
          rem Setup Attract Mode
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
          gosub BeginAttractMode bank14
          return
