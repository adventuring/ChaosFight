          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          if gameMode = 0 then gosub bank9 PublisherPreamble : goto MainLoopContinue
          if gameMode = 1 then gosub bank9 AuthorPreamble : goto MainLoopContinue
          if gameMode = 2 then gosub bank9 TitleScreenMain : goto MainLoopContinue
          if gameMode = 3 then gosub bank10 CharacterSelectInputEntry : goto MainLoopContinue
          if gameMode = 4 then gosub bank12 FallingAnimation1 : goto MainLoopContinue
          if gameMode = 5 then gosub bank12 ArenaSelect1 : goto MainLoopContinue
          if gameMode = 6 then gosub bank11 GameMainLoop : goto MainLoopContinue
          gosub bank12 WinnerAnnouncement
MainLoopContinue
          rem Call music handler for preambles, title screen, and winner screen
          if gameMode < 3 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          if gameMode = 7 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          rem Other modes (3-6) don’t need audio updates here - handled in their subroutines
MainLoopDrawScreen
          drawscreen
          goto MainLoop
