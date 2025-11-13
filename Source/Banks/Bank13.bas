          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Input system (movement, player input, guard effects)

          bank 13

          asm
Bank13DataEnds
end

#include "Source/Routines/CharacterControlsDown.bas"
#include "Source/Routines/ConsoleHandling.bas"
#include "Source/Routines/CharacterControlsJump.bas"

          asm
Bank13CodeEnds
end
