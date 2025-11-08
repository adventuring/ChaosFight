          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 14

          rem Routines moved from Bank 1 - not needed for drawscreen
          rem calls
          rem These are called before/after drawscreen, not during it
          
          rem Console detection moved to Bank 6 for space optimization
#include "Source/Routines/ControllerDetection.bas"
#include "Source/Routines/ConsoleHandling.bas"
          
          rem Game mode transitions
#include "Source/Routines/ChangeGameMode.bas"
          
          rem Player locked helpers
#include "Source/Routines/CharacterControls.bas"
#include "Source/Routines/GuardEffects.bas"
