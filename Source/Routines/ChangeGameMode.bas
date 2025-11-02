          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ChangeGameMode
          rem Stop/clear music when changing game modes
          rem This ensures music doesn't carry over between screens
          gosub bank16 StopMusic
          
          on gameMode goto SetupPublisherPreamble, SetupAuthorPreamble, SetupTitle, SetupCharacterSelect, SetupFallingAnimation, SetupLevelSelect, SetupGame, SetupWinner
          
          rem =================================================================
          rem GAME MODE SETUP FUNCTIONS
          rem =================================================================
          rem These functions initialize each game mode, including music
          rem =================================================================
          
SetupPublisherPreamble
          rem Publisher preamble (gameMode 0) - AtariToday.mscz
          LET temp1 = SongPublisher
          gosub bank16 StartMusic
          rem Initialize preamble timer
          preambleTimer = 0
          return
          
SetupAuthorPreamble
          rem Author preamble (gameMode 1) - Interworldly.mscz
          LET temp1 = SongAuthor
          gosub bank16 StartMusic
          rem Initialize preamble timer
          preambleTimer = 0
          return
          
SetupTitle
          rem Title screen (gameMode 2) - ChaosFight.mscz
          LET temp1 = SongTitle
          gosub bank16 StartMusic
          return
          
SetupCharacterSelect
          rem Character select (gameMode 3) - no music
          return
          
SetupFallingAnimation
          rem Falling animation (gameMode 4) - no music
          return
          
SetupLevelSelect
          rem Level select (gameMode 5) - no music
          return
          
SetupGame
          rem Game mode (gameMode 6) - no music, sound effects only
          return
          
SetupWinner
          rem Winner screen (gameMode 7) - GameOver.mscz or Victory.mscz
          rem Determine win/lose based on winnerPlayerIndex and play appropriate music
          rem TODO: Determine win vs lose state and set temp1 accordingly
          rem For now, default to Victory
          LET temp1 = SongVictory
          gosub bank16 StartMusic
          return
          