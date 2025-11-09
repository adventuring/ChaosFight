          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

MainLoop
          rem Dispatches game modes and handles reset entry point
          rem Inputs: switchreset (hardware), gameMode (global 0-7)
          rem Outputs: Dispatches to mode-specific handlers
          rem Mutates: None; dispatcher only
          rem Calls: WarmStart bank13, PublisherPreludeMain bank14, AuthorPrelude bank14,
          rem        TitleScreenMain bank9, CharacterSelectInputEntry bank6,
          rem        FallingAnimation1 bank12, ArenaSelect1 bank12,
          rem        GameMainLoop bank11, WinnerAnnouncement bank12,
          rem        UpdateMusic bank1, titledrawscreen bank9
          rem Constraints: Must remain colocated with MainLoopContinue/MainLoopDrawScreen

          rem Entry point for entire game loop
          if switchreset then gosub WarmStart bank13 : goto MainLoopContinue

          rem Optimized: Use on/gosub for space efficiency
          on gameMode gosub MainLoopModePublisherPrelude MainLoopModeAuthorPrelude MainLoopModeTitleScreen MainLoopModeCharacterSelect MainLoopModeFallingAnimation MainLoopModeArenaSelect MainLoopModeGameMain MainLoopModeWinnerAnnouncement
          goto MainLoopContinue

MainLoopModePublisherPrelude
          rem tail call
          goto PublisherPreludeMain bank14

MainLoopModeAuthorPrelude
          rem tail call
          goto AuthorPrelude bank14

MainLoopModeTitleScreen
          rem tail call
          goto TitleScreenMain bank9

MainLoopModeCharacterSelect
          rem tail call
          goto CharacterSelectInputEntry bank6

MainLoopModeFallingAnimation
          rem tail call
          goto FallingAnimation1 bank12

MainLoopModeArenaSelect
          rem tail call
          goto ArenaSelect1 bank12

MainLoopModeGameMain
          rem tail call
          goto GameMainLoop bank11

MainLoopModeWinnerAnnouncement
          rem tail call
          goto WinnerAnnouncement bank12
MainLoopContinue
          rem Routes audio updates after per-mode execution
          rem Inputs: gameMode (global 0-7)
          rem Outputs: Falls through to MainLoopDrawScreen
          rem Mutates: None; dispatcher only
          rem Calls: UpdateMusic bank1; colocated with MainLoop/MainLoopDrawScreen
          rem Notes: Modes 3-6 handle audio updates in their own routines

          if gameMode < 3 then goto MainLoopContinueUpdateMusic
          if gameMode = 7 then goto MainLoopContinueUpdateMusic
          goto MainLoopDrawScreen

MainLoopContinueUpdateMusic
          gosub UpdateMusic bank1
MainLoopDrawScreen
          rem Renders the appropriate screen for the current game mode
          rem Inputs: gameMode (global 0-7)
          rem Outputs: Screen rendered via titledrawscreen or drawscreen
          rem Mutates: TIA registers, playfield, sprite state
          rem Calls: titledrawscreen bank9 (title screens); colocated with MainLoop
          rem Notes: Modes 3-6 funnel through mode-specific draw logic

          rem Titlescreen graphics and kernel reside in bank9
          if gameMode < 3 then gosub DrawTitleScreen bank9
          if gameMode >= 3 then drawscreen
          goto MainLoop
