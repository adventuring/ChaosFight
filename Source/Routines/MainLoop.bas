          rem ChaosFight - Source/Routines/MainLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MainLoop
          gosub CharacterSelect
          gosub FallingAnimation
          gosub LevelSelect
          gosub GameLoop
          goto MainLoop