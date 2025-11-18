          rem ChaosFight - Source/Banks/Bank11.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Gameplay loop (init/main/collision resolution/animation)

          bank 11

          asm
Bank11DataEnds
end

#include "Source/Routines/GameLoopInit.bas"
#include "Source/Routines/GameLoopMain.bas"
#include "Source/Routines/UpdateAttackCooldowns.bas"
#include "Source/Routines/PlayerCollisionResolution.bas"

#include "Source/Routines/InitializeMovementSystem.bas"

          rem Movement routines moved from Bank 10/12/13/14 to prevent overflow
          rem Animation moved to Bank 10 to prevent Bank 11 overflow
#include "Source/Routines/HandleFlyingCharacterMovement.bas"

          asm
Bank11CodeEnds
end
