          rem ChaosFight - Source/Banks/Bank2.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 2
          
          rem Character sprite data for characters 0-7
          rem Bank 2 dedicated to character art only - leave room for animation frames
          #include "Source/Generated/Bernie.bas"
          #include "Source/Generated/Curler.bas"
          #include "Source/Generated/Dragonet.bas"
          #include "Source/Generated/EXOPilot.bas"
          #include "Source/Generated/FatTony.bas"
          #include "Source/Generated/Megax.bas"
          #include "Source/Generated/Harpy.bas"
          #include "Source/Generated/KnightGuy.bas"

          rem Character art lookup routines for Bank 2 (characters 0-7 and 16-23)
          include "Source/Routines/CharacterArt_Bank2.s"
