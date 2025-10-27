          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          gosub ColdStart
          gosub PublisherPrelude
          gosub AuthorsPrelude
          gosub TitleScreen
          gosub CharacterSelect
          gosub FallingAnimation
          gosub LevelSelect
          gosub GameLoop
          gosub WinnerAnnouncement
          goto MainLoop