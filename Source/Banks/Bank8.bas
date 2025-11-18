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
#include "Source/Routines/ConstrainToScreen.bas"
#include "Source/Routines/ApplyMomentumAndRecovery.bas"
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
