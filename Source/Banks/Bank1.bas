          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1
          #include "Source/Routines/ColdStart.bas"
          #include "Source/Routines/MainLoop.bas"
          
          rem Game mode main loop routines
          #include "Source/Routines/TitleScreenMain.bas"

          #if 0
          rem Music system temporarily disabled pending proper implementation (#162, #243)
          #include "Source/Routines/MusicSystem.bas"
          #endif
          #include "Source/Data/SpecialSprites.bas"
          
          rem WinScreen moved to Bank 7 to free space
          rem VisualEffects moved to Bank 8 to free space  
          rem ScreenLayout moved to Bank 8 to free space

