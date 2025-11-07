BeginArenaSelect
          rem
          rem ChaosFight - Source/Routines/BeginArenaSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Begin Arena Select
          rem
          rem Setup routine for Arena Select screen.
          rem Initializes arena selection state and screen layout.
          rem Called from ChangeGameMode when entering arena select mode
          rem   (gameMode 5).
          rem NOTE: File is named BeginArenaSelect.bas (normalized from
          rem   BeginLevelSelect.bas for consistency).
          rem Function name is BeginArenaSelect (Arena Select is
          rem preferred
          rem   terminology in codebase per Requirements.md).

          rem Setup routine for Arena Select screen - initializes arena
          rem selection state and screen layout
          rem
          rem Input: None (called from ChangeGameMode)
          rem
          rem Output: selectedArena_W initialized, fireHoldTimer_W
          rem initialized, screen layout set,
          rem         COLUBK set, playfield cleared
          rem
          rem Mutates: selectedArena_W (set to 0), fireHoldTimer_W (set
          rem to 0),
          rem         pfrowheight, pfrows (set via
          rem         SetAdminScreenLayout),
          rem         COLUBK (TIA register), pf0-pf5 (playfield
          rem         registers)
          rem
          rem Called Routines: SetAdminScreenLayout (bank8) - sets
          rem screen layout
          rem
          rem Constraints: Called from ChangeGameMode when entering
          rem arena select mode (gameMode 5)
          let selectedArena_W = 0 : rem Initialize arena selection state
          let fireHoldTimer_W = 0 : rem Start at arena 1 (0-indexed, displays as 1)
          rem Initialize fire hold timer (for returning to Character
          rem   Select)
          
          gosub SetAdminScreenLayout bank8 : rem Set admin screen layout (32×32 for character display)
          
          let COLUBK = ColGray(0) : rem Set background color (B&W safe)
          
          rem Clear playfield (will be drawn by ArenaSelect1 loop)
          pf0 = 0
          pf1 = 0
          pf2 = 0
          pf3 = 0
          pf4 = 0
          pf5 = 0
          
          return


