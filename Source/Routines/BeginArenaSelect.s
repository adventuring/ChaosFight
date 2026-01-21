
BeginArenaSelect .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; ChaosFight - Source/Routines/BeginArenaSelect.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; Begin Arena Select
          ;;
          ;; Setup routine for Arena Select screen.
          ;; Initializes arena selection state and screen layout.
          ;; Called from ChangeGameMode when entering arena select mode
          ;; (gameMode 5).
          ;; NOTE: File is named BeginArenaSelect.bas (normalized from
          ;; BeginLevelSelect.bas for consistency).
          ;; Function name is BeginArenaSelect (Arena Select is
          ;; preferred
          ;; terminology in codebase per Requirements.md).

          ;; Setup routine for Arena Select screen - initializes arena
          ;; selection state and screen layout
          ;;
          ;; Input: None (called from ChangeGameMode)
          ;;
          ;; Output: selectedArena_W initialized, fireHoldTimer_W
          ;; initialized, screen layout set,
          ;; COLUBK set, playfield cleared
          ;;
          ;; Mutates: selectedArena_W (set to 0), fireHoldTimer_W (set
          ;; to 0),
          ;; pfrowheight, pfrows (set via
          ;; SetGameScreenLayout),
          ;; COLUBK (TIA register)
          ;;
          ;; Called Routines: SetGameScreenLayout (bank7) - sets
          ;; screen layout
          ;;
          ;; Constraints: Called from ChangeGameMode when entering
          ;; arena select mode (gameMode 5)
          ;; Initialize arena selection sta

          lda # 0
          sta selectedArena_W
          ;; Start at arena 1 (0-indexed, displays as 1)
          lda # 0
          sta fireHoldTimer_W
          ;; Initialize fire hold timer (for returning to Character
          ;; Select)

          ;; Set screen layout (32×8 for character display) - inlined
          lda # ScreenPfRowHeight
          sta pfrowheight
          lda # ScreenPfRows
          sta pfrows

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Playfield layout is static; ArenaSelect renders via playfield data
          jmp BS_return

.pend

