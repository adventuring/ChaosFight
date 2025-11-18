          rem ChaosFight - Source/Banks/Bank10.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Sprite rendering (character art loader, player rendering, elimination) +
          rem   character attacks system and falling animation controller

          bank 10

          asm
Bank10DataEnds = .
end

#include "Source/Routines/SpriteLoaderCharacterArt.bas"
#include "Source/Routines/BernieAttack.bas"
#include "Source/Routines/HarpyAttack.bas"
#include "Source/Routines/UrsuloAttack.bas"
#include "Source/Routines/ShamoneAttack.bas"
#include "Source/Routines/PlayerPhysicsCollisions.bas"
#include "Source/Routines/FallingAnimation.bas"
#include "Source/Routines/PlayerPhysicsGravity.bas"

          asm
Bank10CodeEnds = .
end
