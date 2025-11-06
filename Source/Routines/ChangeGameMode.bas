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
          gosub BeginPublisherPrelude bank9
          return
          
SetupAuthorPrelude
          gosub BeginAuthorPrelude bank9
          return
          
SetupTitle
          gosub BeginTitleScreen bank9
          return
          
SetupCharacterSelect
          rem Character select uses its own internal flow
          rem No separate Begin function needed - setup is handled
          rem   inline
          return
          
SetupFallingAnimation
          gosub BeginFallingAnimation bank12
          return
          
SetupArenaSelect
          gosub BeginArenaSelect bank12
          return

SetupGame
          gosub BeginGameLoop bank11
          rem BeginGameLoop resets gameplay state and returns
          rem MainLoop will dispatch to GameMainLoop based on gameMode =
          rem   ModeGame
          return

SetupWinner
          gosub BeginWinnerAnnouncement bank12
          return

SetupAttract
          gosub BeginAttractMode bank9
          return
