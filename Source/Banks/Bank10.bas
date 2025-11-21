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
PlayerBoundaryCollisionsStart
end
#include "Source/Routines/PlayerBoundaryCollisions.bas"
          asm
PlayerBoundaryCollisionsEnd
            echo "// Bank 10: ", [PlayerBoundaryCollisionsEnd - PlayerBoundaryCollisionsStart]d, " bytes = PlayerBoundaryCollisions"
PlayerPlayfieldCollisionsStart
end
#include "Source/Routines/PlayerPlayfieldCollisions.bas"
          asm
PlayerPlayfieldCollisionsEnd
            echo "// Bank 10: ", [PlayerPlayfieldCollisionsEnd - PlayerPlayfieldCollisionsStart]d, " bytes = PlayerPlayfieldCollisions"
          asm
CharacterAttacksDispatchStart
end
#include "Source/Routines/CharacterAttacksDispatch.bas"
          asm
CharacterAttacksDispatchEnd
            echo "// Bank 10: ", [CharacterAttacksDispatchEnd - CharacterAttacksDispatchStart]d, " bytes = CharacterAttacksDispatch"
          asm
ProcessAttackInputStart
end
#include "Source/Routines/ProcessAttackInput.bas"
          asm
ProcessAttackInputEnd
            echo "// Bank 10: ", [ProcessAttackInputEnd - ProcessAttackInputStart]d, " bytes = ProcessAttackInput"
          asm
BernieAttackStart
end
#include "Source/Routines/BernieAttack.bas"
          asm
BernieAttackEnd
            echo "// Bank 10: ", [BernieAttackEnd - BernieAttackStart]d, " bytes = BernieAttack"
          asm
HarpyAttackStart
end
#include "Source/Routines/HarpyAttack.bas"
          asm
HarpyAttackEnd
            echo "// Bank 10: ", [HarpyAttackEnd - HarpyAttackStart]d, " bytes = HarpyAttack"
          asm
UrsuloAttackStart
end
#include "Source/Routines/UrsuloAttack.bas"
          asm
UrsuloAttackEnd
            echo "// Bank 10: ", [UrsuloAttackEnd - UrsuloAttackStart]d, " bytes = UrsuloAttack"
          asm
ShamoneAttackStart
end
#include "Source/Routines/ShamoneAttack.bas"
          asm
ShamoneAttackEnd
            echo "// Bank 10: ", [ShamoneAttackEnd - ShamoneAttackStart]d, " bytes = ShamoneAttack"
          asm
DispatchCharacterJumpStart
end
#include "Source/Routines/DispatchCharacterJump.bas"
          asm
DispatchCharacterJumpEnd
            echo "// Bank 10: ", [DispatchCharacterJumpEnd - DispatchCharacterJumpStart]d, " bytes = DispatchCharacterJump"
          asm
CheckRoboTitoStretchMissileCollisionsStart
end
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"
          asm
CheckRoboTitoStretchMissileCollisionsEnd
            echo "// Bank 10: ", [CheckRoboTitoStretchMissileCollisionsEnd - CheckRoboTitoStretchMissileCollisionsStart]d, " bytes = CheckRoboTitoStretchMissileCollisions"
          asm
ScreenLayoutStart
end
#include "Source/Routines/ScreenLayout.bas"
          asm
ScreenLayoutEnd
            echo "// Bank 10: ", [ScreenLayoutEnd - ScreenLayoutStart]d, " bytes = ScreenLayout"

Bank10CodeEnds
end
