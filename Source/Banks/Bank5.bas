          rem ChaosFight - Source/Banks/Bank5.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 5
          
          rem Bank 5 dedicated to character art only - leave room for animation frames
          rem Character sprite data for characters 24-31 (replicas of 8-15)
          rem Character 24 = Character 8 (Frooty), Character 25 = Character 9 (Nefertem), etc.
          #include "Source/Generated/Frooty.bas"
          #include "Source/Generated/Nefertem.bas"
          #include "Source/Generated/NinjishGuy.bas"
          #include "Source/Generated/PorkChop.bas"
          #include "Source/Generated/RadishGoblin.bas"
          #include "Source/Generated/RoboTito.bas"
          #include "Source/Generated/Ursulo.bas"
          #include "Source/Generated/VegDog.bas"
          
          rem Character art lookup routines for Bank 5 (characters 24-31)
          include "Source/Routines/CharacterArt_Bank5.s"
