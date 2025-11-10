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
          rem         SetGameScreenLayout),
          rem         COLUBK (TIA register)
          rem
          rem Called Routines: SetGameScreenLayout (bank7) - sets
          rem screen layout
          rem
          rem Constraints: Called from ChangeGameMode when entering
          rem arena select mode (gameMode 5)
          let selectedArena_W = 0
          rem Initialize arena selection state
          let fireHoldTimer_W = 0
          rem Start at arena 1 (0-indexed, displays as 1)
          rem Initialize fire hold timer (for returning to Character
          rem   Select)
          
          gosub SetGameScreenLayout bank7
          rem Set screen layout (32×8 for character display)
          
          COLUBK = ColGray(0)
          rem Set background color (B&W safe)
          
          rem Playfield layout is static; ArenaSelect renders via playfield data
          return


