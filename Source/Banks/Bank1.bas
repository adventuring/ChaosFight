          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1
          
          rem Entry point - far goto to ColdStart in Bank 0
          rem ColdStart falls through to MainLoop in same bank
          goto bank0 ColdStart
          
          #if 0
          rem Music system temporarily disabled pending proper implementation (#162, #243)
          #include "Source/Routines/MusicSystem.bas"
          #endif
          
          rem WinScreen moved to Bank 7 to free space
          rem VisualEffects moved to Bank 8 to free space  
          rem ScreenLayout moved to Bank 8 to free space

