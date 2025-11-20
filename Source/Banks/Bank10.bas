          rem ChaosFight - Source/Banks/Bank10.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Sprite rendering (character art loader, player rendering, elimination) +
          rem   character attacks system and falling animation controller

          bank 10

          asm
Bank10DataEnds
end

          asm
SpriteLoaderCharacterArtStart
end
#include "Source/Routines/SpriteLoaderCharacterArt.bas"
          asm
SpriteLoaderCharacterArtEnd
            echo "// Bank 10: ", [SpriteLoaderCharacterArtEnd - SpriteLoaderCharacterArtStart]d, " bytes = SpriteLoaderCharacterArt"
FrameBudgetingStart
end
#include "Source/Routines/FrameBudgeting.bas"
          asm
FrameBudgetingEnd
            echo "// Bank 10: ", [FrameBudgetingEnd - FrameBudgetingStart]d, " bytes = FrameBudgeting"
PlayerPhysicsCollisionsStart
end
#include "Source/Routines/PlayerPhysicsCollisions.bas"
          asm
PlayerPhysicsCollisionsEnd
            echo "// Bank 10: ", [PlayerPhysicsCollisionsEnd - PlayerPhysicsCollisionsStart]d, " bytes = PlayerPhysicsCollisions"
ProcessUpInputStart
end
#include "Source/Routines/ProcessUpInput.bas"
          asm
ProcessUpInputEnd
            echo "// Bank 10: ", [ProcessUpInputEnd - ProcessUpInputStart]d, " bytes = ProcessUpInput"
CheckRoboTitoStretchMissileCollisionsStart
end
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"
          asm
CheckRoboTitoStretchMissileCollisionsEnd
            echo "// Bank 10: ", [CheckRoboTitoStretchMissileCollisionsEnd - CheckRoboTitoStretchMissileCollisionsStart]d, " bytes = CheckRoboTitoStretchMissileCollisions"
BernieAttackStart
end
#include "Source/Routines/BernieAttack.bas"
          asm
BernieAttackEnd
            echo "// Bank 10: ", [BernieAttackEnd - BernieAttackStart]d, " bytes = BernieAttack"
HarpyAttackStart
end
#include "Source/Routines/HarpyAttack.bas"
          asm
HarpyAttackEnd
            echo "// Bank 10: ", [HarpyAttackEnd - HarpyAttackStart]d, " bytes = HarpyAttack"
UrsuloAttackStart
end
#include "Source/Routines/UrsuloAttack.bas"
          asm
UrsuloAttackEnd
            echo "// Bank 10: ", [UrsuloAttackEnd - UrsuloAttackStart]d, " bytes = UrsuloAttack"
ShamoneAttackStart
end
#include "Source/Routines/ShamoneAttack.bas"
          asm
ShamoneAttackEnd
            echo "// Bank 10: ", [ShamoneAttackEnd - ShamoneAttackStart]d, " bytes = ShamoneAttack"
DispatchCharacterJumpStart
end
#include "Source/Routines/DispatchCharacterJump.bas"
          asm
DispatchCharacterJumpEnd
            echo "// Bank 10: ", [DispatchCharacterJumpEnd - DispatchCharacterJumpStart]d, " bytes = DispatchCharacterJump"
Bank10CodeEnds
end
