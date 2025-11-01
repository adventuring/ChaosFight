          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 14
          
          rem Level data
          #include "Source/Routines/LevelData.bas"
          
          rem Console detection (must be before controller detection)
          #include "Source/Routines/ConsoleDetection.bas"
          
          rem Controller detection
          #include "Source/Routines/ControllerDetection.bas"

          #if 0
          rem Music system disabled pending proper implementation (#162, #243)
          #include "Source/Routines/MusicSystem.bas"
          #endif
