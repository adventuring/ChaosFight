BeginWinnerAnnouncement
          rem Returns: Far (return otherbank)
          asm
BeginWinnerAnnouncement

end
          rem
          rem Returns: Far (return otherbank)
          rem ChaosFight - Source/Routines/BeginWinnerAnnouncement.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
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
          rem        playerCharacter[] (global array) = player character
          rem        selections
          rem        CharacterThemeSongIndices[] (global array) =
          rem        character theme song mapping
          rem
          rem Output: screen layout set, COLUBK set, displayRank initialized,
          rem         music started with winner’s character theme
          rem
          rem Mutates: pfrowheight, pfrows (set via
          rem SetGameScreenLayout),
          rem         COLUBK (TIA register),
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
          rem              logic (FindWinner.bas)

          rem Initialize Winner Announcement mode
          rem winnerPlayerIndex should already be set by game end logic
          rem   (FindWinner.bas)

          rem Set screen layout (32×8 for character display) - inlined
          let pfrowheight = ScreenPfRowHeight
          let pfrows = ScreenPfRows

          rem Background: black (COLUBK starts black, no need to set)

          rem Initialize display rank (starts at 0, may be updated by
          rem   DisplayWinScreen if implemented)
          let displayRank_W = 0

          rem Get winner’s character index
          let temp1 = winnerPlayerIndex_R
          if temp1 = 0 then let temp2 = playerCharacter[0]

          if temp1 = 1 then let temp2 = playerCharacter[1]

          if temp1 = 2 then let temp2 = playerCharacter[2]

          if temp1 = 3 then let temp2 = playerCharacter[3]

          rem Look up full song ID from mapping table (table contains
          rem   song ID constants)
          let temp1 = CharacterThemeSongIndices[temp2]

          rem Start winner’s character theme song
          gosub StartMusic bank15

          return otherbank
