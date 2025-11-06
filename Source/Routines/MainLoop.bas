          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          rem Centralized RESET handling - check before any mode dispatch
          rem RESET must work from any screen/state (title, gameplay,
          rem   pause, preambles, win/lose, menus)
          if switchreset then gosub bank11 WarmStart : goto MainLoopContinue
          
          if gameMode = 0 then gosub bank9 PublisherPreambleMain : goto MainLoopContinue
          if gameMode = 1 then gosub bank9 AuthorPreamble : goto MainLoopContinue
          if gameMode = 2 then gosub bank9 TitleScreenMain : goto MainLoopContinue
          if gameMode = 3 then gosub bank10 CharacterSelectInputEntry : goto MainLoopContinue
          if gameMode = 4 then gosub bank12 FallingAnimation1 : goto MainLoopContinue
          if gameMode = 5 then gosub bank12 ArenaSelect1 : goto MainLoopContinue
          if gameMode = 6 then gosub bank11 GameMainLoop : goto MainLoopContinue
          gosub bank12 WinnerAnnouncement
MainLoopContinue
          rem Call music handler for preambles, title screen, and winner
          rem   screen
          if gameMode < 3 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          if gameMode = 7 then gosub bank16 UpdateMusic : goto MainLoopDrawScreen
          rem Other modes (3-6) don’t need audio updates here - handled
          rem   in their subroutines
MainLoopDrawScreen
          rem Admin screens (0-2) use titlescreen kernel, others use
          rem   standard drawscreen
          rem Titlescreen graphics are in Bank 14 (same bank as MainLoop and drawscreen)
          if gameMode < 3 then gosub titledrawscreen bank14 else drawscreen
          goto MainLoop
