          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Physics system (gravity, movement, special abilities) + screen layout +
          rem   health bars


          rem Code segment
#include "Source/Data/CharacterPhysicsTables.bas"

Bank8DataEnds

#include "Source/Routines/PlayerInput.bas"
#include "Source/Routines/PlayerPhysicsGravity.bas"
#include "Source/Routines/MovementSystem.bas"
#include "Source/Routines/FallDamage.bas"
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"
#include "Source/Routines/HealthBarSystem.bas"
#include "Source/Routines/Physics.bas"

Bank8CodeEnds
