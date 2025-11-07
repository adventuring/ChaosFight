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
          rem SetAdminScreenLayout),
          rem         COLUBK (TIA register), winScreenTimer (set to 0),
          rem         displayRank (set to 0),
          rem         temp1, temp2 (used for character/song lookup)
          rem
          rem Called Routines: SetAdminScreenLayout (bank8) - sets
          rem screen layout,
          rem   StartMusic (bank16) - starts winner’s character theme
          rem   song
          rem
          rem Constraints: Called from ChangeGameMode when transitioning
          rem to ModeWinner
          rem              winnerPlayerIndex must be set by game end
          rem              logic (FindWinner in PlayerElimination.bas)
          dim BWA_winnerPlayerIndex = temp1
          dim BWA_characterIndex = temp2
          dim BWA_songID = temp1
          
          rem Initialize Winner Announcement mode
          rem winnerPlayerIndex should already be set by game end logic
          rem   (FindWinner in PlayerElimination.bas)
          
          gosub SetAdminScreenLayout bank8 : rem Set admin screen layout (32×32 for character display)
          
          rem Set background color (B&W safe)
          COLUBK = ColGray(0)
          
          rem Initialize win screen timer (starts at 0, increments each
          rem   frame)
          rem Auto-advance after WinScreenAutoAdvanceFrames (600 frames
          let winScreenTimer = 0 : rem = 10 seconds at 60fps)
          
          rem Initialize display rank (starts at 0, may be updated by
          let displayRank = 0 : rem   DisplayWinScreen if implemented)
          
          let BWA_winnerPlayerIndex = winnerPlayerIndex : rem Get winner’s character index
          if BWA_winnerPlayerIndex = 0 then let BWA_characterIndex = PlayerCharacter[0]
          if BWA_winnerPlayerIndex = 1 then let BWA_characterIndex = PlayerCharacter[1]
          if BWA_winnerPlayerIndex = 2 then let BWA_characterIndex = PlayerCharacter[2]
          if BWA_winnerPlayerIndex = 3 then let BWA_characterIndex = PlayerCharacter[3]
          
          rem Look up full song ID from mapping table (table contains
          let BWA_songID = CharacterThemeSongIndices[BWA_characterIndex] : rem   song ID constants)
          
          rem Start winner’s character theme song
          gosub StartMusic bank16
          
          return

