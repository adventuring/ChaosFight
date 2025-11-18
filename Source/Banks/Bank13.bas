          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Input system (movement, player input, guard effects)

          bank 13

          asm
Bank13DataEnds
end

#include "Source/Routines/CheckPlayerCollision.bas"
#include "Source/Routines/ControllerDetection.bas"
#include "Source/Routines/GetPlayerAnimationStateFunction.bas"
#include "Source/Routines/PlayerPhysicsGravity.bas"
#include "Source/Routines/InitializeMovementSystem.bas"
#include "Source/Routines/ConstrainToScreen.bas"
#include "Source/Routines/AddVelocitySubpixelY.bas"
#include "Source/Routines/ProcessStandardMovement.bas"
#include "Source/Routines/CharacterControlsDown.bas"
#include "Source/Routines/CharacterControlsJump.bas"
#include "Source/Routines/ConsoleHandling.bas"
#include "Source/Routines/TriggerEliminationEffects.bas"
#include "Source/Routines/AnimationSystem.bas"
#include "Source/Routines/GetCharacterAttackType.bas"
#include "Source/Routines/IsCharacterRanged.bas"
#include "Source/Routines/IsCharacterMelee.bas"
#include "Source/Routines/IsPlayerEliminated.bas"
#include "Source/Routines/IsPlayerAlive.bas"
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"

          asm
Bank13CodeEnds
end
