          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          on GameMode gosub PublisherPrelude, AuthorsPrelude, TitleScreen, CharacterSelect1, FallingAnimation, LevelSelect, GameLoop, WinnerAnnouncement
          drawscreen
          goto MainLoop
