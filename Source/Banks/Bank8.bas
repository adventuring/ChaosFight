          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Physics system (gravity, movement, special abilities, fall damage) + screen layout +
          rem   health bars

          bank 8

          rem Code segment
#include "Source/Data/CharacterPhysicsTables.bas"

          asm
Bank8DataEnds
end

#include "Source/Routines/ApplyMomentumAndRecovery.bas"
#include "Source/Routines/InputHandleAllPlayers.bas"
#include "Source/Routines/HandleGuardInput.bas"
#include "Source/Routines/ProcessAttackInput.bas"
#include "Source/Routines/InputHandleLeftPortPlayerFunction.bas"
#include "Source/Routines/InputHandleRightPortPlayerFunction.bas"
#include "Source/Routines/UpdatePlayerMovementSingle.bas"
#include "Source/Routines/UpdatePlayerMovement.bas"
#include "Source/Routines/Physics.bas"
#include "Source/Routines/FallDamage.bas"

          asm
Bank8CodeEnds
end
