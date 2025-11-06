          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          rem Centralized RESET handling - check before any mode dispatch
          rem RESET must work from any screen/state (title, gameplay,
          rem   pause, preludes, win/lose, menus)
          rem Input: switchreset (hardware) = reset switch state
          rem        gameMode (global) = current game mode (0-7)
          rem Output: Dispatches to mode-specific handlers
          rem Mutates: None (dispatcher only)
          rem Called Routines: WarmStart (bank11), PublisherPreludeMain (bank9),
          rem   AuthorPrelude (bank9), TitleScreenMain (bank9),
          rem   CharacterSelectInputEntry (bank10), FallingAnimation1 (bank12),
          rem   ArenaSelect1 (bank12), GameMainLoop (bank11),
          rem   WinnerAnnouncement (bank12), UpdateMusic (bank16),
          rem   titledrawscreen (bank9)
          rem Constraints: Must be colocated with MainLoopContinue, MainLoopDrawScreen
          rem              Entry point for entire game loop
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
          rem Input: gameMode (global) = current game mode (0-7)
          rem Output: Dispatches to MainLoopDrawScreen
          rem Mutates: None (dispatcher only)
          rem Called Routines: UpdateMusic (bank16) - accesses music state variables
          rem Constraints: Must be colocated with MainLoop, MainLoopDrawScreen
          if gameMode < 3 then gosub UpdateMusic bank16 : goto MainLoopDrawScreen
          if gameMode = 7 then gosub UpdateMusic bank16 : goto MainLoopDrawScreen
          rem Other modes (3-6) don't need audio updates here - handled
          rem   in their subroutines
MainLoopDrawScreen
          rem Admin screens (0-2) use titlescreen kernel, others use
          rem   standard drawscreen
          rem Input: gameMode (global) = current game mode (0-7)
          rem Output: Screen rendered via titledrawscreen or drawscreen
          rem Mutates: Screen state (TIA registers, playfield, sprites)
          rem Called Routines: titledrawscreen (bank9) - accesses title screen state
          rem Constraints: Must be colocated with MainLoop, MainLoopContinue
          rem              Entry point for entire game loop
          rem Titlescreen graphics and kernel are in Bank 9
          if gameMode < 3 then gosub titledrawscreen bank9 else drawscreen
          goto MainLoop
