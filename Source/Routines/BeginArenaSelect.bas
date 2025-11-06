          rem ChaosFight - Source/Routines/BeginArenaSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Begin Arena Select
          rem
          rem Setup routine for Arena Select screen.
          rem Initializes arena selection state and screen layout.
          rem Called from ChangeGameMode when entering arena select mode
          rem   (gameMode 5).
          rem
          rem NOTE: File is named BeginArenaSelect.bas (normalized from
          rem   BeginLevelSelect.bas for consistency).
          rem Function name is BeginArenaSelect (Arena Select is preferred
          rem   terminology in codebase per Requirements.md).

BeginArenaSelect
          rem Setup routine for Arena Select screen - initializes arena selection state and screen layout
          rem Input: None (called from ChangeGameMode)
          rem Output: selectedArena_W initialized, fireHoldTimer_W initialized, screen layout set,
          rem         COLUBK set, playfield cleared
          rem Mutates: selectedArena_W (set to 0), fireHoldTimer_W (set to 0),
          rem         pfrowheight, pfrows (set via SetAdminScreenLayout),
          rem         COLUBK (TIA register), pf0-pf5 (playfield registers)
          rem Called Routines: SetAdminScreenLayout (bank8) - sets screen layout
          rem Constraints: Called from ChangeGameMode when entering arena select mode (gameMode 5)
          rem Initialize arena selection state
          let selectedArena_W = 0
          rem Start at arena 1 (0-indexed, displays as 1)
          let fireHoldTimer_W = 0
          rem Initialize fire hold timer (for returning to Character
          rem   Select)
          
          rem Set admin screen layout (32×32 for character display)
          gosub SetAdminScreenLayout bank8
          
          rem Set background color (B&W safe)
          let COLUBK = ColGray(0)
          
          rem Clear playfield (will be drawn by ArenaSelect1 loop)
          pf0 = 0
          pf1 = 0
          pf2 = 0
          pf3 = 0
          pf4 = 0
          pf5 = 0
          
          return


