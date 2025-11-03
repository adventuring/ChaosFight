          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHANGE GAME MODE
          rem =================================================================
          rem Centralized game mode switching dispatcher.
          rem Calls appropriate Begin* setup routine for the new gameMode.
          rem After setup completes, MainLoop dispatches to the appropriate loop.

ChangeGameMode
          on gameMode goto SetupPublisherPrelude, SetupAuthorPrelude, SetupTitle, SetupCharacterSelect, SetupFallingAnimation, SetupLevelSelect, SetupGame, SetupWinner, SetupAttract
          return
          
SetupPublisherPrelude
          rem Publisher Preamble uses its own internal flow
          rem No separate Begin function needed - setup is handled inline
          return

SetupAuthorPrelude
          gosub BeginAuthorPrelude
          return

SetupTitle
          rem Title screen uses its own internal flow
          rem No separate Begin function needed - setup is handled inline
          return

SetupCharacterSelect
          rem Character select uses its own internal flow
          rem No separate Begin function needed - setup is handled inline
          return

SetupFallingAnimation
          gosub BeginFallingAnimation
          return

SetupLevelSelect
          gosub BeginLevelSelect
          return

SetupGame
          gosub BeginGameLoop
          rem BeginGameLoop handles transition internally
          return

SetupWinner
          gosub BeginWinnerAnnouncement
          return

SetupAttract
          gosub BeginAttractMode
          return
