          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 14

          rem Routines moved from Bank 1 - not needed for drawscreen
          rem calls
          rem These are called before/after drawscreen, not during it
          
          rem Console detection and handling
#include "Source/Routines/ConsoleDetection.bas"
#include "Source/Routines/ControllerDetection.bas"
#include "Source/Routines/ConsoleHandling.bas"
          
          rem Character art location system
#include "Source/Routines/SpriteLoaderCharacterArt.bas"
          
          rem Game mode transitions
#include "Source/Routines/ChangeGameMode.bas"
          
          rem Player locked helpers
#include "Source/Routines/PlayerLockedHelpers.bas"