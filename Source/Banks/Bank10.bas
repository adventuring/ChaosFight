          rem ChaosFight - Source/Banks/Bank10.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Sprite rendering (character art loader, player rendering, elimination) +
          rem   character attacks system and falling animation controller

          asm
            ECHO "End of Bank 9 at ", .
end
          bank 10

          asm
            ECHO "Start of Bank 10 data at ", .
Bank10DataEnds
            ECHO "End of Bank 10 data (no data) at ", .
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
Bank10CodeEnds
#include "Source/Common/BankSwitching.s"
end
