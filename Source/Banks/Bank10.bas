          rem ChaosFight - Source/Banks/Bank10.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Sprite rendering (character art loader, player rendering, elimination) +
          rem   character attacks system and falling animation controller

          asm
Bank10DataEnds
end

#include "Source/Routines/SpriteLoaderCharacterArt.bas"
#include "Source/Routines/CharacterAttacks.bas"
#include "Source/Routines/ApplyGuardColor.bas"
#include "Source/Routines/RestoreNormalPlayerColor.bas"
#include "Source/Routines/CheckGuardCooldown.bas"
#include "Source/Routines/StartGuard.bas"
#include "Source/Routines/UpdateGuardTimers.bas"
#include "Source/Routines/UpdateSingleGuardTimer.bas"
#include "Source/Routines/PlayerPhysicsCollisions.bas"
#include "Source/Routines/FallingAnimation.bas"

          asm
Bank10CodeEnds
end
