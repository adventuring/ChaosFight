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
#include "Source/Routines/UpdateAttackCooldowns.bas"
#include "Source/Routines/PlayerCollisionResolution.bas"
#include "Source/Routines/AnimationSystem.bas"

          rem Player position/velocity getter/setter routines moved from Bank 14 for ROM balance
#include "Source/Routines/GetPlayerPosition.bas"
#include "Source/Routines/GetPlayerVelocity.bas"
#include "Source/Routines/SetPlayerPosition.bas"
#include "Source/Routines/SetPlayerVelocity.bas"

          rem Physics helper routines moved from Bank 14 for ROM balance
#include "Source/Routines/InitializeMovementSystem.bas"
#include "Source/Routines/AddVelocitySubpixelY.bas"
#include "Source/Routines/ApplyFriction.bas"

          asm
Bank11CodeEnds
            include "Source/Common/BankSwitching.s"
end
