          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          if GameMode = 0 then gosub bank9 PublisherPreamble : goto MainLoopContinue
          if GameMode = 1 then gosub bank9 AuthorPreamble : goto MainLoopContinue
          if GameMode = 2 then gosub bank9 TitleScreenMain : goto MainLoopContinue
          if GameMode = 3 then gosub bank10 CharacterSelectInputEntry : goto MainLoopContinue
          if GameMode = 4 then gosub bank12 FallingAnimation1 : goto MainLoopContinue
          if GameMode = 5 then gosub bank12 LevelSelect1 : goto MainLoopContinue
          if GameMode = 6 then gosub bank11 GameMainLoop : goto MainLoopContinue
          gosub bank12 WinnerAnnouncement
MainLoopContinue
          rem Call music handler for preambles and title screen, sound handler for game modes
          if GameMode < 3 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          if GameMode = 7 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          gosub bank15 PlaySoundEffect
MainLoopDrawScreen
          drawscreen
          goto MainLoop
