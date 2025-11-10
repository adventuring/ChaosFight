BeginWinnerAnnouncement
          rem
          rem ChaosFight - Source/Routines/BeginWinnerAnnouncement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem BEGIN WINNER ANNOUNCEMENT - Setup Routine
          rem Setup routine for Winner Announcement mode. Sets initial
          rem   state only.
          rem Called from ChangeGameMode when transitioning to
          rem   ModeWinner.

          rem Setup routine for Winner Announcement mode - sets initial
          rem state only
          rem
          rem Input: winnerPlayerIndex (global) = winner player index
          rem (set by game end logic)
          rem        PlayerCharacter[] (global array) = player character
          rem        selections
          rem        CharacterThemeSongIndices[] (global array) =
          rem        character theme song mapping
          rem
          rem Output: screen layout set, COLUBK set, winScreenTimer
          rem initialized, displayRank initialized,
          rem         music started with winner’s character theme
          rem
          rem Mutates: pfrowheight, pfrows (set via
          rem SetGameScreenLayout),
          rem         COLUBK (TIA register), winScreenTimer (set to 0),
          rem         displayRank (set to 0),
          rem         temp1, temp2 (used for character/song lookup)
          rem
          rem Called Routines: SetGameScreenLayout (bank7) - sets
          rem screen layout,
          rem   StartMusic (bank1) - starts winner’s character theme
          rem   song
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModeWinner
          rem              winnerPlayerIndex must be set by game end
          rem              logic (FindWinner in PlayerElimination.bas)
          
          rem Initialize Winner Announcement mode
          rem winnerPlayerIndex should already be set by game end logic
          rem   (FindWinner in PlayerElimination.bas)
          
          gosub SetGameScreenLayout bank7
          rem Set screen layout (32×8 for character display)
          
          rem Set background color (B&W safe)
          COLUBK = ColGray(0)
          
          rem Initialize win screen timer (starts at 0, increments each
          rem   frame)
          rem Auto-advance after WinScreenAutoAdvanceFrames (600 frames
          let winScreenTimer_W = 0
          rem = 10 seconds at 60fps)
          
          rem Initialize display rank (starts at 0, may be updated by
          let displayRank_W = 0
          rem   DisplayWinScreen if implemented)
          
          let temp1 = winnerPlayerIndex_R
          rem Get winner’s character index
          if temp1 = 0 then temp2 = PlayerCharacter[0]
          if temp1 = 1 then temp2 = PlayerCharacter[1]
          if temp1 = 2 then temp2 = PlayerCharacter[2]
          if temp1 = 3 then temp2 = PlayerCharacter[3]
          
          rem Look up full song ID from mapping table (table contains
          let temp1 = CharacterThemeSongIndices[temp2]
          rem   song ID constants)
          
          rem Start winner’s character theme song
          gosub StartMusic bank1
          
          return

