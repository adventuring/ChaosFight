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
          dim BWA_themeSongIndex = temp3
          dim BWA_songID = temp1
          
          rem Initialize Winner Announcement mode
          rem winnerPlayerIndex should already be set by game end logic
          
          rem Set background color (B&W safe)
          COLUBK = ColGray(0)
          
          rem Initialize display state
          rem displayRank and winScreenTimer are managed by DisplayWinScreen
          
          rem Note: winnerPlayerIndex, displayRank, winScreenTimer should be
          rem initialized by game end logic in PlayerElimination.bas
          
          rem Get winner's character index
          let BWA_winnerPlayerIndex = winnerPlayerIndex
          if BWA_winnerPlayerIndex = 0 then let BWA_characterIndex = PlayerChar[0]
          if BWA_winnerPlayerIndex = 1 then let BWA_characterIndex = PlayerChar[1]
          if BWA_winnerPlayerIndex = 2 then let BWA_characterIndex = PlayerChar[2]
          if BWA_winnerPlayerIndex = 3 then let BWA_characterIndex = PlayerChar[3]
          
          rem Look up theme song index from mapping table
          let BWA_themeSongIndex = CharacterThemeSongIndices[BWA_characterIndex]
          
          rem Calculate song ID: character theme songs start after main songs
          rem (Main songs are 0-4: Title, Interworldly, AtariToday, Victory, GameOver)
          let BWA_songID = BWA_themeSongIndex + MusicCharacterThemeBase
          
          rem Start winner's character theme song
          let temp1 = BWA_songID
          gosub bank16 StartMusic
          
          return

