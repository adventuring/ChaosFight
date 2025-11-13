          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Physics system (gravity, movement, special abilities) + screen layout +
          rem   health bars


          rem Code segment
#include "Source/Data/CharacterPhysicsTables.bas"

          asm
Bank8DataEnds
end

#include "Source/Routines/PlayerInput.bas"
#include "Source/Routines/PlayerPhysicsGravity.bas"
#include "Source/Routines/UpdatePlayerMovementSingle.bas"
#include "Source/Routines/UpdatePlayerMovement.bas"
#include "Source/Routines/SetPlayerVelocity.bas"
#include "Source/Routines/SetPlayerPosition.bas"
#include "Source/Routines/GetPlayerPosition.bas"
#include "Source/Routines/GetPlayerVelocity.bas"
#include "Source/Routines/MovementApplyGravity.bas"
#include "Source/Routines/AddVelocitySubpixelY.bas"
#include "Source/Routines/ApplyFriction.bas"
#include "Source/Routines/CheckPlayerCollision.bas"
#include "Source/Routines/ConstrainToScreen.bas"
#include "Source/Routines/InitializeMovementSystem.bas"
#include "Source/Routines/FallDamage.bas"
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"
#include "Source/Routines/HealthBarSystem.bas"
#include "Source/Routines/Physics.bas"
#include "Source/Routines/CharacterDamage.bas"
#include "Source/Routines/SetSpritePositions.bas"
#include "Source/Routines/SetPlayerSprites.bas"
#include "Source/Routines/DisplayHealth.bas"

          asm
Bank8CodeEnds
end
