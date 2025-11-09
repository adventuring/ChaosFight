          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 13

          rem ColdStart falls through to MainLoop (which is now in Bank
          rem 14)
#include "Source/Routines/ColdStart.bas"
          rem ChangeGameMode.bas and MainLoop.bas moved to Bank 14
          
          rem Input routines moved to Bank 4 for space optimization
          rem Character selection routines moved to Bank 2 for space optimization
          rem CharacterControls.bas contains character-specific jump and
          rem down handlers
          rem   referenced by PlayerInput.bas via on...goto statements
