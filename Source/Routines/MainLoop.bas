          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          if gameMode = 0 then gosub bank9 PublisherPreamble : goto MainLoopContinue
          if gameMode = 1 then gosub bank9 AuthorPreamble : goto MainLoopContinue
          if gameMode = 2 then gosub bank9 TitleScreenMain : goto MainLoopContinue
          if gameMode = 3 then gosub bank10 CharacterSelectInputEntry : goto MainLoopContinue
          if gameMode = 4 then gosub bank12 FallingAnimation1 : goto MainLoopContinue
          if gameMode = 5 then gosub bank12 LevelSelect1 : goto MainLoopContinue
          if gameMode = 6 then gosub bank11 GameMainLoop : goto MainLoopContinue
          if gameMode = 7 then gosub bank12 WinnerAnnouncement : goto MainLoopContinue
          if gameMode = 8 then gosub bank12 AttractMode : goto MainLoopContinue
MainLoopContinue
          rem Call music handler for preambles, title screen, winner, and attract mode
          rem Sound handler for game modes
          if gameMode < 3 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          if gameMode = 7 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          if gameMode = 8 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          gosub bank15 PlaySoundEffect
MainLoopDrawScreen
          drawscreen
          goto MainLoop
