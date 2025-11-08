MainLoop
          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Centralized RESET handling - check before any mode
          rem dispatch
          rem RESET must work from any screen/state (title, gameplay,
          rem   pause, preludes, win/lose, menus)
          rem
          rem Input: switchreset (hardware) = reset switch state
          rem        gameMode (global) = current game mode (0-7)
          rem
          rem Output: Dispatches to mode-specific handlers
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: WarmStart (bank11), PublisherPreludeMain
          rem (bank9),
          rem   AuthorPrelude (bank9), TitleScreenMain (bank9),
          rem   CharacterSelectInputEntry (bank10), FallingAnimation1
          rem   (bank12),
          rem   ArenaSelect1 (bank12), GameMainLoop (bank11),
          rem   WinnerAnnouncement (bank12), UpdateMusic (bank1),
          rem   titledrawscreen (bank9)
          rem
          rem Constraints: Must be colocated with MainLoopContinue,
          rem MainLoopDrawScreen
          if switchreset then gosub WarmStart bank11 : goto MainLoopContinue : rem Entry point for entire game loop
          
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
          rem
          rem Input: gameMode (global) = current game mode (0-7)
          rem
          rem Output: Dispatches to MainLoopDrawScreen
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: UpdateMusic (bank1) - accesses music
          rem state variables
          if gameMode < 3 then gosub UpdateMusic bank1 : goto MainLoopDrawScreen : rem Constraints: Must be colocated with MainLoop, MainLoopDrawScreen
          if gameMode = 7 then gosub UpdateMusic bank1 : goto MainLoopDrawScreen
MainLoopDrawScreen
          rem Other modes (3-6) don’t need audio updates here - handled
          rem   in their subroutines
          rem Admin screens (0-2) use titlescreen kernel, others use
          rem   standard drawscreen
          rem
          rem Input: gameMode (global) = current game mode (0-7)
          rem
          rem Output: Screen rendered via titledrawscreen or drawscreen
          rem
          rem Mutates: Screen state (TIA registers, playfield, sprites)
          rem
          rem Called Routines: titledrawscreen (bank9) - accesses title
          rem screen state
          rem
          rem Constraints: Must be colocated with MainLoop,
          rem MainLoopContinue
          rem              Entry point for entire game loop
          if gameMode < 3 then gosub titledrawscreen bank9 else drawscreen : rem Titlescreen graphics and kernel are in Bank 9
          goto MainLoop
