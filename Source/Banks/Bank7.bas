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
CheckRoboTitoStretchMissileCollisionsStart
end
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"
          asm
CheckRoboTitoStretchMissileCollisionsEnd
            echo "// Bank 7: ", [CheckRoboTitoStretchMissileCollisionsEnd - CheckRoboTitoStretchMissileCollisionsStart]d, " bytes = CheckRoboTitoStretchMissileCollisions"
          asm
BudgetedMissileCollisionsStart
end
#include "Source/Routines/BudgetedMissileCollisions.bas"
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
Bank7CodeEnds
end
