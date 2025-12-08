          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Sprite rendering (character art loader, player rendering, elimination) +
          rem   character attacks system and falling animation controller
          bank 9
          asm
Bank10DataEnds
end

          asm
PlayerBoundaryCollisionsStart
end
#include "Source/Routines/PlayerBoundaryCollisions.bas"
          asm
PlayerBoundaryCollisionsEnd
            echo "// Bank 9: ", [PlayerBoundaryCollisionsEnd - PlayerBoundaryCollisionsStart]d, " bytes = PlayerBoundaryCollisions"
PlayerPlayfieldCollisionsStart
end
#include "Source/Routines/PlayerPlayfieldCollisions.bas"
          asm
PlayerPlayfieldCollisionsEnd
            echo "// Bank 9: ", [PlayerPlayfieldCollisionsEnd - PlayerPlayfieldCollisionsStart]d, " bytes = PlayerPlayfieldCollisions"
          asm
CharacterAttacksDispatchStart
end
#include "Source/Routines/CharacterAttacksDispatch.bas"
          asm
CharacterAttacksDispatchEnd
            echo "// Bank 9: ", [CharacterAttacksDispatchEnd - CharacterAttacksDispatchStart]d, " bytes = CharacterAttacksDispatch"
          asm
ProcessAttackInputStart
end
#include "Source/Routines/ProcessAttackInput.bas"
          asm
ProcessAttackInputEnd
            echo "// Bank 9: ", [ProcessAttackInputEnd - ProcessAttackInputStart]d, " bytes = ProcessAttackInput"
          asm
BernieAttackStart
end
#include "Source/Routines/BernieAttack.bas"
          asm
BernieAttackEnd
            echo "// Bank 9: ", [BernieAttackEnd - BernieAttackStart]d, " bytes = BernieAttack"
          asm
HarpyAttackStart
end
#include "Source/Routines/HarpyAttack.bas"
          asm
HarpyAttackEnd
            echo "// Bank 9: ", [HarpyAttackEnd - HarpyAttackStart]d, " bytes = HarpyAttack"
          asm
UrsuloAttackStart
end
#include "Source/Routines/UrsuloAttack.bas"
          asm
UrsuloAttackEnd
            echo "// Bank 9: ", [UrsuloAttackEnd - UrsuloAttackStart]d, " bytes = UrsuloAttack"
          asm
ShamoneAttackStart
end
#include "Source/Routines/ShamoneAttack.bas"
          asm
ShamoneAttackEnd
            echo "// Bank 9: ", [ShamoneAttackEnd - ShamoneAttackStart]d, " bytes = ShamoneAttack"
RoboTitoJumpStart
end
#include "Source/Routines/RoboTitoJump.bas"
          asm
RoboTitoJumpEnd
            echo "// Bank 9: ", [RoboTitoJumpEnd - RoboTitoJumpStart]d, " bytes = RoboTitoJump"
          asm
CheckRoboTitoStretchMissileCollisionsStart
end
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"
          asm
CheckRoboTitoStretchMissileCollisionsEnd
            echo "// Bank 9: ", [CheckRoboTitoStretchMissileCollisionsEnd - CheckRoboTitoStretchMissileCollisionsStart]d, " bytes = CheckRoboTitoStretchMissileCollisions"
          asm
ScreenLayoutStart
end
#include "Source/Routines/SetGameScreenLayout.bas"
          asm
ScreenLayoutEnd
            echo "// Bank 9: ", [ScreenLayoutEnd - ScreenLayoutStart]d, " bytes = ScreenLayout"

Bank10CodeEnds
end
