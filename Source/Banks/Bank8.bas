          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Physics system (gravity, movement, special abilities) + screen layout +
          rem   health bars

          bank 8

          rem Code segment
#include "Source/Data/CharacterPhysicsTables.bas"

          asm
Bank8DataEnds
end

#include "Source/Routines/GetPlayerAnimationStateFunction.bas"
          rem ConstrainToScreen moved from Bank 13 for ROM balance (physics-related)
#include "Source/Routines/ConstrainToScreen.bas"
          rem ApplyMomentumAndRecovery moved from Bank 10 for ROM balance
#include "Source/Routines/ApplyMomentumAndRecovery.bas"
          rem AddVelocitySubpixelY moved from Bank 11 for ROM balance
#include "Source/Routines/AddVelocitySubpixelY.bas"
#include "Source/Routines/InputHandleAllPlayers.bas"
#include "Source/Routines/HandleGuardInput.bas"
#include "Source/Routines/HandleFlyingCharacterMovement.bas"
#include "Source/Routines/ProcessStandardMovement.bas"
#include "Source/Routines/ProcessUpInput.bas"
#include "Source/Routines/ProcessJumpInput.bas"
#include "Source/Routines/ProcessAttackInput.bas"
#include "Source/Routines/InputHandleLeftPortPlayerFunction.bas"
#include "Source/Routines/InputHandleRightPortPlayerFunction.bas"
#include "Source/Routines/HandlePauseInput.bas"
#include "Source/Routines/UpdatePlayerMovementSingle.bas"
#include "Source/Routines/UpdatePlayerMovement.bas"
#include "Source/Routines/Physics.bas"

          asm
Bank8CodeEnds
end
