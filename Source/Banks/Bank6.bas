          rem ChaosFight - Source/Banks/Bank6.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character selection system (main/render)

          asm
Bank6DataEnds
end

          rem Character select routines
#include "Source/Routines/PlayerLockedHelpers.bas"
#include "Source/Routines/CharacterSelectRender.bas"
#include "Source/Routines/CharacterSelectEntry.bas"

          asm
Bank6CodeEnds
end
