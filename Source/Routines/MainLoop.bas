          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          rem Centralized RESET handling - check before any mode dispatch
          rem RESET must work from any screen/state (title, gameplay,
          rem   pause, preludes, win/lose, menus)
          if switchreset then gosub WarmStart bank11 : goto MainLoopContinue
          
          if gameMode = 0 then gosub PublisherPreludeMain bank9 : goto MainLoopContinue
          if gameMode = 1 then gosub AuthorPrelude bank9 : goto MainLoopContinue
          if gameMode = 2 then gosub TitleScreenMain bank9 : goto MainLoopContinue
          if gameMode = 3 then gosub CharacterSelectInputEntry bank10 : goto MainLoopContinue
          if gameMode = 4 then gosub FallingAnimation1 bank12 : goto MainLoopContinue
          if gameMode = 5 then gosub ArenaSelect1 bank12 : goto MainLoopContinue
          if gameMode = 6 then gosub GameMainLoop bank11 : goto MainLoopContinue
          gosub WinnerAnnouncement bank12
MainLoopContinue
          rem Call music handler for preludes, title screen, and winner
          rem   screen
          if gameMode < 3 then gosub UpdateMusic bank16 : goto MainLoopDrawScreen
          if gameMode = 7 then gosub UpdateMusic bank16 : goto MainLoopDrawScreen
          rem Other modes (3-6) don’t need audio updates here - handled
          rem   in their subroutines
MainLoopDrawScreen
          rem Admin screens (0-2) use titlescreen kernel, others use
          rem   standard drawscreen
          rem Titlescreen graphics are in Bank 1 (same bank as MainLoop and drawscreen)
          if gameMode < 3 then gosub titledrawscreen bank1 else drawscreen
          goto MainLoop
