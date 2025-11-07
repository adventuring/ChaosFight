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
          if gameMode = 0 then goto SetupPublisherPrelude
          if gameMode = 1 then goto SetupAuthorPrelude
          if gameMode = 2 then goto SetupTitle
          if gameMode = 3 then goto SetupCharacterSelect
          if gameMode = 4 then goto SetupFallingAnimation
          if gameMode = 5 then goto SetupArenaSelect
          if gameMode = 6 then goto SetupGame
          if gameMode = 7 then goto SetupWinner
          if gameMode = 8 then goto SetupAttract
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
          rem Called Routines: BeginPublisherPrelude (bank9) - accesses
          rem prelude state
          gosub BeginPublisherPrelude bank9 : rem Constraints: Must be colocated with ChangeGameMode
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
          rem Called Routines: BeginAuthorPrelude (bank9) - accesses
          rem prelude state
          gosub BeginAuthorPrelude bank9 : rem Constraints: Must be colocated with ChangeGameMode
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
          rem Called Routines: BeginTitleScreen (bank9) - accesses title
          rem screen state
          gosub BeginTitleScreen bank9 : rem Constraints: Must be colocated with ChangeGameMode
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
          rem Called Routines: BeginFallingAnimation (bank12) - accesses
          rem animation state
          gosub BeginFallingAnimation bank12 : rem Constraints: Must be colocated with ChangeGameMode
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
          gosub BeginArenaSelect bank12 : rem Constraints: Must be colocated with ChangeGameMode
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
          rem MainLoop will dispatch to GameMainLoop based on gameMode =
          gosub BeginGameLoop bank11 : rem   ModeGame
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
          gosub BeginWinnerAnnouncement bank12 : rem Constraints: Must be colocated with ChangeGameMode
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
          rem Called Routines: BeginAttractMode (bank9) - accesses
          rem attract mode state
          gosub BeginAttractMode bank9 : rem Constraints: Must be colocated with ChangeGameMode
          return
