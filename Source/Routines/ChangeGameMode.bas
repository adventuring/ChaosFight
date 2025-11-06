          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem CHANGE GAME MODE
          rem ==========================================================
          rem Centralized game mode switching dispatcher.
          rem Calls appropriate Begin* setup routine for the new
          rem   gameMode.
          rem After setup completes, MainLoop dispatches to the
          rem   appropriate loop.

ChangeGameMode
          rem Centralized game mode switching dispatcher
          rem Input: gameMode (global) = target game mode (0-8)
          rem Output: Dispatches to appropriate Setup* routine
          rem Mutates: None (dispatcher only)
          rem Called Routines: Various Begin* routines (see Setup* functions below)
          rem Constraints: Must be colocated with all Setup* functions (called via on...goto)
          on gameMode goto SetupPublisherPrelude, SetupAuthorPrelude, SetupTitle, SetupCharacterSelect, SetupFallingAnimation, SetupArenaSelect, SetupGame, SetupWinner, SetupAttract
          return
          
SetupPublisherPrelude
          rem Setup Publisher Prelude mode
          rem Input: gameMode (global) = ModePublisherPrelude (0)
          rem Output: Publisher prelude state initialized
          rem Mutates: Publisher prelude state variables (via BeginPublisherPrelude)
          rem Called Routines: BeginPublisherPrelude (bank9) - accesses prelude state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginPublisherPrelude bank9
          return
          
SetupAuthorPrelude
          rem Setup Author Prelude mode
          rem Input: gameMode (global) = ModeAuthorPrelude (1)
          rem Output: Author prelude state initialized
          rem Mutates: Author prelude state variables (via BeginAuthorPrelude)
          rem Called Routines: BeginAuthorPrelude (bank9) - accesses prelude state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginAuthorPrelude bank9
          return
          
SetupTitle
          rem Setup Title Screen mode
          rem Input: gameMode (global) = ModeTitle (2)
          rem Output: Title screen state initialized
          rem Mutates: Title screen state variables (via BeginTitleScreen)
          rem Called Routines: BeginTitleScreen (bank9) - accesses title screen state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginTitleScreen bank9
          return
          
SetupCharacterSelect
          rem Character select uses its own internal flow
          rem No separate Begin function needed - setup is handled
          rem   inline
          rem Input: gameMode (global) = ModeCharacterSelect (3)
          rem Output: None (character select handles its own setup)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with ChangeGameMode
          return
          
SetupFallingAnimation
          rem Setup Falling Animation mode
          rem Input: gameMode (global) = ModeFallingAnimation (4)
          rem Output: Falling animation state initialized
          rem Mutates: Falling animation state variables (via BeginFallingAnimation)
          rem Called Routines: BeginFallingAnimation (bank12) - accesses animation state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginFallingAnimation bank12
          return
          
SetupArenaSelect
          rem Setup Arena Select mode
          rem Input: gameMode (global) = ModeArenaSelect (5)
          rem Output: Arena select state initialized
          rem Mutates: Arena select state variables (via BeginArenaSelect)
          rem Called Routines: BeginArenaSelect (bank12) - accesses arena select state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginArenaSelect bank12
          return

SetupGame
          rem Setup Game mode
          rem Input: gameMode (global) = ModeGame (6)
          rem Output: Game state initialized
          rem Mutates: Game state variables (via BeginGameLoop)
          rem Called Routines: BeginGameLoop (bank11) - accesses game state
          rem Constraints: Must be colocated with ChangeGameMode
          rem BeginGameLoop resets gameplay state and returns
          rem MainLoop will dispatch to GameMainLoop based on gameMode =
          rem   ModeGame
          gosub BeginGameLoop bank11
          return

SetupWinner
          rem Setup Winner Announcement mode
          rem Input: gameMode (global) = ModeWinner (7)
          rem Output: Winner announcement state initialized
          rem Mutates: Winner announcement state variables (via BeginWinnerAnnouncement)
          rem Called Routines: BeginWinnerAnnouncement (bank12) - accesses winner state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginWinnerAnnouncement bank12
          return

SetupAttract
          rem Setup Attract Mode
          rem Input: gameMode (global) = ModeAttract (8)
          rem Output: Attract mode state initialized
          rem Mutates: Attract mode state variables (via BeginAttractMode)
          rem Called Routines: BeginAttractMode (bank9) - accesses attract mode state
          rem Constraints: Must be colocated with ChangeGameMode
          gosub BeginAttractMode bank9
          return
