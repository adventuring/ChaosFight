          rem ChaosFight - Source/Banks/Bank7.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Missile system (tables, physics, collision) + combat system

          bank 7

          asm
CharacterMissileTablesStart
end
#include "Source/Data/CharacterMissileTables.bas"
          asm
CharacterMissileTablesEnd
            echo "// Bank 7: ", [CharacterMissileTablesEnd - CharacterMissileTablesStart]d, " bytes = CharacterMissileTables"
CharacterMissileDataStart
end
#include "Source/Routines/CharacterMissileData.bas"
          asm
CharacterMissileDataEnd
            echo "// Bank 7: ", [CharacterMissileDataEnd - CharacterMissileDataStart]d, " bytes = CharacterMissileData"
CharacterDataTablesStart
end
#include "Source/Data/CharacterDataTables.bas"
          asm
CharacterDataTablesEnd
            echo "// Bank 7: ", [CharacterDataTablesEnd - CharacterDataTablesStart]d, " bytes = CharacterDataTables"
Bank7DataEnds
end

          asm
BudgetedMissileCollisionsStart
end
#include "Source/Routines/BudgetedMissileCollisionCheck.bas"
          asm
BudgetedMissileCollisionsEnd
            echo "// Bank 7: ", [BudgetedMissileCollisionsEnd - BudgetedMissileCollisionsStart]d, " bytes = BudgetedMissileCollisions"
          asm
MissileSystemStart
end
#include "Source/Routines/MissileSystem.bas"
          asm
MissileSystemEnd
            echo "// Bank 7: ", [MissileSystemEnd - MissileSystemStart]d, " bytes = MissileSystem"
MissileCharacterHandlersStart
end
#include "Source/Routines/MissileCharacterHandlers.bas"
          asm
MissileCharacterHandlersEnd
            echo "// Bank 7: ", [MissileCharacterHandlersEnd - MissileCharacterHandlersStart]d, " bytes = MissileCharacterHandlers"
CombatStart
end
#include "Source/Routines/Combat.bas"
          asm
CombatEnd
            echo "// Bank 7: ", [CombatEnd - CombatStart]d, " bytes = Combat"
          asm
PerformGenericAttackStart
end
#include "Source/Routines/PerformGenericAttack.bas"
          asm
PerformGenericAttackEnd
            echo "// Bank 7: ", [PerformGenericAttackEnd - PerformGenericAttackStart]d, " bytes = PerformGenericAttack"
FlyingMovementHelpersStart
end
#include "Source/Routines/FlyingMovementHelpers.bas"
          asm
FlyingMovementHelpersEnd
            echo "// Bank 7: ", [FlyingMovementHelpersEnd - FlyingMovementHelpersStart]d, " bytes = FlyingMovementHelpers"
Bank7CodeEnds
end
