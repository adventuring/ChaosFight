          rem ChaosFight - Source/Routines/BeginWinnerAnnouncement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem BEGIN WINNER ANNOUNCEMENT - Setup routine
          rem ==========================================================
          rem Setup routine for Winner Announcement mode. Sets initial
          rem   state only.
          rem Called from ChangeGameMode when transitioning to
          rem   ModeWinner.

BeginWinnerAnnouncement
          rem Setup routine for Winner Announcement mode - sets initial state only
          rem Input: winnerPlayerIndex (global) = winner player index (set by game end logic)
          rem        PlayerChar[] (global array) = player character selections
          rem        CharacterThemeSongIndices[] (global array) = character theme song mapping
          rem Output: screen layout set, COLUBK set, winScreenTimer initialized, displayRank initialized,
          rem         music started with winner's character theme
          rem Mutates: pfrowheight, pfrows (set via SetAdminScreenLayout),
          rem         COLUBK (TIA register), winScreenTimer (set to 0), displayRank (set to 0),
          rem         temp1, temp2 (used for character/song lookup)
          rem Called Routines: SetAdminScreenLayout (bank8) - sets screen layout,
          rem   StartMusic (bank16) - starts winner's character theme song
          rem Constraints: Called from ChangeGameMode when transitioning to ModeWinner
          rem              winnerPlayerIndex must be set by game end logic (FindWinner in PlayerElimination.bas)
          dim BWA_winnerPlayerIndex = temp1
          dim BWA_characterIndex = temp2
          dim BWA_songID = temp1
          
          rem Initialize Winner Announcement mode
          rem winnerPlayerIndex should already be set by game end logic
          rem   (FindWinner in PlayerElimination.bas)
          
          rem Set admin screen layout (32×32 for character display)
          gosub SetAdminScreenLayout bank8
          
          rem Set background color (B&W safe)
          COLUBK = ColGray(0)
          
          rem Initialize win screen timer (starts at 0, increments each
          rem   frame)
          rem Auto-advance after WinScreenAutoAdvanceFrames (600 frames
          rem   = 10 seconds at 60fps)
          let winScreenTimer = 0
          
          rem Initialize display rank (starts at 0, may be updated by
          rem   DisplayWinScreen if implemented)
          let displayRank = 0
          
          rem Get winner's character index
          let BWA_winnerPlayerIndex = winnerPlayerIndex
          if BWA_winnerPlayerIndex = 0 then let BWA_characterIndex = PlayerChar[0]
          if BWA_winnerPlayerIndex = 1 then let BWA_characterIndex = PlayerChar[1]
          if BWA_winnerPlayerIndex = 2 then let BWA_characterIndex = PlayerChar[2]
          if BWA_winnerPlayerIndex = 3 then let BWA_characterIndex = PlayerChar[3]
          
          rem Look up full song ID from mapping table (table contains
          rem   song ID constants)
          let BWA_songID = CharacterThemeSongIndices[BWA_characterIndex]
          
          rem Start winner's character theme song
          let temp1 = BWA_songID
          gosub StartMusic bank16
          
          return

