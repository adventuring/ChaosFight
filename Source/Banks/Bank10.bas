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
BudgetedPlayerCollisionsStart
end
#include "Source/Routines/BudgetedPlayerCollisions.bas"
          asm
BudgetedPlayerCollisionsEnd
            echo "// Bank 10: ", [BudgetedPlayerCollisionsEnd - BudgetedPlayerCollisionsStart]d, " bytes = BudgetedPlayerCollisions"
          asm
CharacterAttacksDispatchStart
end
#include "Source/Routines/CharacterAttacksDispatch.bas"
          asm
CharacterAttacksDispatchEnd
            echo "// Bank 10: ", [CharacterAttacksDispatchEnd - CharacterAttacksDispatchStart]d, " bytes = CharacterAttacksDispatch"
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
DispatchCharacterJumpStart
end
#include "Source/Routines/DispatchCharacterJump.bas"
          asm
DispatchCharacterJumpEnd
            echo "// Bank 10: ", [DispatchCharacterJumpEnd - DispatchCharacterJumpStart]d, " bytes = DispatchCharacterJump"

Bank10CodeEnds
end
