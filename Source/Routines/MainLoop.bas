          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          asm
MainLoop
end
          rem Dispatches game modes and handles reset entry point
          rem Inputs: switchreset (hardware), gameMode (global 0-7)
          rem Outputs: Dispatches to mode-specific handlers
          rem Mutates: None; dispatcher only
          rem Calls: WarmStart bank13, PublisherPreludeMain bank14, AuthorPrelude bank14,
          rem        TitleScreenMain bank14, CharacterSelectInputEntry bank9,
          rem        FallingAnimation1 bank11, ArenaSelect1 bank14,
          rem        GameMainLoop bank11, WinnerAnnouncementLoop bank12,
          rem        PlayMusic bank1, titledrawscreen bank9
          rem Constraints: Must remain colocated with MainLoopDrawScreen

          rem Entry point for entire game loop
          rem Increment frame counter (used for frame budgeting and timing)
          let frame = frame + 1
          if switchreset then gosub WarmStart bank13
          ; fall through to continue

          rem Optimized: Use on/gosub for space efficiency
          on gameMode gosub MainLoopModePublisherPrelude MainLoopModeAuthorPrelude MainLoopModeTitleScreen MainLoopModeCharacterSelect MainLoopModeFallingAnimation MainLoopModeArenaSelect MainLoopModeGameMain MainLoopModeWinnerAnnouncement
          ; fall through to continue

MainLoopModePublisherPrelude
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub PublisherPreludeMain bank14
          return

MainLoopModeAuthorPrelude
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub AuthorPrelude bank14
          return

MainLoopModeTitleScreen
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub TitleScreenMain bank14
          return

MainLoopModeCharacterSelect
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub CharacterSelectInputEntry bank9
          return

MainLoopModeFallingAnimation
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub FallingAnimation1 bank11
          return

MainLoopModeArenaSelect
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub ArenaSelect1 bank14
          return

MainLoopModeGameMain
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub GameMainLoop bank11
          return

MainLoopModeWinnerAnnouncement
          rem CRITICAL: Cannot use tail call (goto) for cross-bank calls
          rem Must use gosub to preserve return address for return otherbank
          gosub WinnerAnnouncementLoop bank12
          return
MainLoopContinue
          rem Routes audio updates after per-mode execution
          rem Inputs: gameMode (global 0-7)
          rem Outputs: Falls through to MainLoopDrawScreen
          rem Mutates: None; dispatcher only
          rem Calls: PlayMusic bank1 (for modes < 3 and mode 7); colocated with MainLoop/MainLoopDrawScreen
          rem Notes: Modes 3-6 handle audio updates in their own routines

          rem Check if music update is needed for game modes < 3 or mode 7
          if gameMode < 3 then goto PlayMusic bank1
          if gameMode = 7 then goto PlayMusic bank1
SkipMusicUpdate
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
          goto MainLoop bank16
