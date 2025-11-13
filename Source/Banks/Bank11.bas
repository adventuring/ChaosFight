          rem ChaosFight - Source/Banks/Bank11.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Gameplay loop (init/main/collision resolution/animation) + attack support data

          bank 11

          asm
Bank11DataEnds
end

#include "Source/Routines/GameLoopInit.bas"
#include "Source/Routines/GameLoopMain.bas"
#include "Source/Routines/PlayerCollisionResolution.bas"
#include "Source/Routines/AnimationSystem.bas"

          asm
Bank11CodeEnds
end
