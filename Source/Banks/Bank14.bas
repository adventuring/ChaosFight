          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Console handling (detection, controllers, game mode transitions,
          rem   character controls, startup routines)

          bank 14

          rem Routines moved from Bank 1 - not needed for drawscreen
          rem calls
          rem These are called before/after drawscreen, not during it
          
          rem Console detection and handling moved to Bank 13
          
          rem Player locked helpers
#include "Source/Routines/ColdStart.bas"
#include "Source/Routines/BeginAttractMode.bas"
#include "Source/Routines/AttractMode.bas"
#include "Source/Routines/MovementSystem.bas"
#include "Source/Routines/PlayerInput.bas"
#include "Source/Routines/CharacterControlsJump.bas"

