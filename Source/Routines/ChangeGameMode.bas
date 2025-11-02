          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ChangeGameMode
          rem Stop/clear music when changing game modes
          rem This ensures music doesn't carry over between screens
          gosub bank16 StopMusic
          
          on gameMode goto SetupPublisherPreamble, SetupAuthorPreamble, SetupTitle, SetupCharacterSelect, SetupFallingAnimation, SetupLevelSelect, SetupGame, SetupWinner
          