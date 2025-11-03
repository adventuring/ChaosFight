          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ChangeGameMode
          rem Stop/clear music when changing game modes
          rem This ensures music doesn’t carry over between screens
          gosub bank16 StopMusic
          
          on gameMode goto SetupPublisherPreamble, SetupAuthorPreamble, SetupTitle, SetupCharacterSelect, SetupFallingAnimation, SetupLevelSelect, SetupGame, SetupWinner
          
          rem =================================================================
          rem GAME MODE SETUP FUNCTIONS
          rem =================================================================
          rem These functions initialize each game mode, including music
          rem =================================================================
          
SetupPublisherPreamble
          rem Publisher preamble (gameMode 0) - AtariToday.mscz
          temp1 = SongPublisher
          gosub bank16 StartMusic
          rem Initialize preamble timer
          let preambleTimer = 0
          return
          
SetupAuthorPreamble
          rem Author preamble (gameMode 1) - Interworldly.mscz
          temp1 = SongAuthor
          gosub bank16 StartMusic
          rem Initialize preamble timer
          let preambleTimer = 0
          return
          
SetupTitle
          rem Title screen (gameMode 2) - ChaosFight.mscz
          temp1 = SongTitle
          gosub bank16 StartMusic
          
          rem Initialize title screen state
          COLUBK = ColGray(0)
          
          rem Initialize character parade
          let titleParadeTimer = 0
          let titleParadeChar = 0
          let titleParadeX = 0
          let titleParadeActive = 0
          
          return
          
SetupCharacterSelect
          rem Character select (gameMode 3) - no music
          
          rem Initialize character selections
          let playerChar[0] = 0
          let playerChar[1] = CPUCharacter
          let playerChar[2] = NoCharacter
          let playerChar[3] = NoCharacter
          let playerLocked[0] = 0
          let playerLocked[1] = 0
          let playerLocked[2] = 0
          let playerLocked[3] = 0
          
          rem Initialize random selection flags
          let randomSelectFlags[0] = 0
          let randomSelectFlags[1] = 0
          let randomSelectFlags[2] = 0
          let randomSelectFlags[3] = 0
          
          rem Initialize character select animation states
          let charSelectPlayerAnimFrame[0] = 0
          let charSelectPlayerAnimFrame[1] = 0
          let charSelectPlayerAnimFrame[2] = 0
          let charSelectPlayerAnimFrame[3] = 0
          let charSelectPlayerAnimSeq[0] = 0
          let charSelectPlayerAnimSeq[1] = 0
          let charSelectPlayerAnimSeq[2] = 0
          let charSelectPlayerAnimSeq[3] = 0
          
          rem Clear Quadtari detection (will be re-detected)
          let controllerStatus = controllerStatus & ClearQuadtariDetected
          
          rem Initialize legacy character select animations (for backwards compat)
          let charSelectAnimTimer = 0
          let charSelectAnimState = 0
          rem Start with idle animation
          let charSelectCharIndex = 0
          rem Start with first character
          let charSelectAnimFrame = 0
          
          rem Check for Quadtari adapter
          gosub bank6 SelDetectQuad
          
          rem Special rule: If Quadtari detected, P2 defaults to NO instead of CPU
          rem (because in 4-player mode, P2 is treated like P3/P4, not 2-player mode)
          rem Actually, re-reading requirement: "NO" is option for P2 if either P3 or P4 are NOT NO
          rem This is more complex - P2 can be CPU OR NO depending on P3/P4 state
          rem For now, just keep P2 as CPU in all cases - this will be handled by cycling logic
          
          rem Set background color (B&W safe)
          let COLUBK = ColGray(0)
          rem Always black background
          
          rem Initialize Quadtari controller multiplexing
          let qtcontroller = 0
          
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
          temp1 = SongVictory
          gosub bank16 StartMusic
          return
          