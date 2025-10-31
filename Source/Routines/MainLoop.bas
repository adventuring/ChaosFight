          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          on GameMode gosub PublisherPreamble, AuthorPreamble, TitleScreen, SelInEntry, FallingAnimation1, LevelSelect1, GameMainLoop, WinnerAnnouncement
          drawscreen
          goto MainLoop
