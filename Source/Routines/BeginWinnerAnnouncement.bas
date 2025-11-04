          rem ChaosFight - Source/Routines/BeginWinnerAnnouncement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem BEGIN WINNER ANNOUNCEMENT - Setup routine
          rem =================================================================
          rem Setup routine for Winner Announcement mode. Sets initial state only.
          rem Called from ChangeGameMode when transitioning to ModeWinner.

BeginWinnerAnnouncement
          dim BWA_winnerPlayerIndex = temp1
          dim BWA_characterIndex = temp2
          dim BWA_songID = temp1
          
          rem Initialize Winner Announcement mode
          rem winnerPlayerIndex should already be set by game end logic (FindWinner in PlayerElimination.bas)
          
          rem Set admin screen layout (32×32 for character display)
          gosub bank8 SetAdminScreenLayout
          
          rem Set background color (B&W safe)
          COLUBK = ColGray(0)
          
          rem Initialize win screen timer (starts at 0, increments each frame)
          rem Auto-advance after WinScreenAutoAdvanceFrames (600 frames = 10 seconds at 60fps)
          let winScreenTimer = 0
          
          rem Initialize display rank (starts at 0, may be updated by DisplayWinScreen if implemented)
          let displayRank = 0
          
          rem Get winner's character index
          let BWA_winnerPlayerIndex = winnerPlayerIndex
          if BWA_winnerPlayerIndex = 0 then let BWA_characterIndex = PlayerChar[0]
          if BWA_winnerPlayerIndex = 1 then let BWA_characterIndex = PlayerChar[1]
          if BWA_winnerPlayerIndex = 2 then let BWA_characterIndex = PlayerChar[2]
          if BWA_winnerPlayerIndex = 3 then let BWA_characterIndex = PlayerChar[3]
          
          rem Look up full song ID from mapping table (table contains song ID constants)
          let BWA_songID = CharacterThemeSongIndices[BWA_characterIndex]
          
          rem Start winner's character theme song
          let temp1 = BWA_songID
          gosub bank16 StartMusic
          
          return

