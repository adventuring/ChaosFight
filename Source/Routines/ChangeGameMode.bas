          rem ChaosFight - Source/Routines/ChangeGameMode.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem CHANGE GAME MODE
          rem ==========================================================
          rem Centralized game mode switching dispatcher.
          rem Calls appropriate Begin* setup routine for the new
          rem   gameMode.
          rem After setup completes, MainLoop dispatches to the
          rem   appropriate loop.

ChangeGameMode
          on gameMode goto SetupPublisherPrelude, SetupAuthorPrelude, SetupTitle, SetupCharacterSelect, SetupFallingAnimation, SetupArenaSelect, SetupGame, SetupWinner, SetupAttract
          return
          
SetupPublisherPrelude
          gosub bank9 BeginPublisherPrelude
          return
          
SetupAuthorPrelude
          gosub bank9 BeginAuthorPrelude
          return
          
SetupTitle
          gosub bank9 BeginTitleScreen
          return
          
SetupCharacterSelect
          rem Character select uses its own internal flow
          rem No separate Begin function needed - setup is handled
          rem   inline
          return
          
SetupFallingAnimation
          gosub bank12 BeginFallingAnimation
          return
          
SetupArenaSelect
          gosub bank12 BeginArenaSelect
          return

SetupGame
          gosub bank11 BeginGameLoop
          rem BeginGameLoop resets gameplay state and returns
          rem MainLoop will dispatch to GameMainLoop based on gameMode =
          rem   ModeGame
          return

SetupWinner
          gosub bank12 BeginWinnerAnnouncement
          return

SetupAttract
          gosub bank9 BeginAttractMode
          return
