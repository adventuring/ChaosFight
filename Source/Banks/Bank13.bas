          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 13

          rem ColdStart falls through to MainLoop (which is now in Bank
          rem 14)
#include "Source/Routines/ColdStart.bas"
          rem ChangeGameMode.bas and MainLoop.bas moved to Bank 14
          
          rem Input and movement routines moved from Bank 11
#include "Source/Routines/PlayerInput.bas"
#include "Source/Routines/MovementSystem.bas"
          rem CharacterControls.bas contains character-specific jump and
          rem down handlers
          rem   referenced by PlayerInput.bas via on...goto statements
