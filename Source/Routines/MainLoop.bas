          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          if GameMode = 0 then gosub bank9 PublisherPreamble : goto MainLoopContinue
          if GameMode = 1 then gosub bank9 AuthorPreamble : goto MainLoopContinue
          if GameMode = 2 then gosub bank9 TitleScreen : goto MainLoopContinue
          if GameMode = 3 then gosub bank10 SelInEntry : goto MainLoopContinue
          if GameMode = 4 then gosub FallingAnimation1 : goto MainLoopContinue
          if GameMode = 5 then gosub LevelSelect1 : goto MainLoopContinue
          if GameMode = 6 then gosub bank11 GameMainLoop : goto MainLoopContinue
          gosub WinnerAnnouncement
MainLoopContinue
          drawscreen
          goto MainLoop
