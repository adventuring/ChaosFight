          rem ChaosFight - Source/Banks/Bank2.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 2
          #include "Source/Routines/LevelData.bas"          
          rem Platform-specific character data
          #ifdef TV_NTSC
          #include "Source/Generated/Characters.NTSC.bas"
          #endif
          
          #ifdef TV_PAL
          #include "Source/Generated/Characters.PAL.bas"
          #endif
          
          #ifdef TV_SECAM
          #include "Source/Generated/Characters.SECAM.bas"
          #endif
          end

