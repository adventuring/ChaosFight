          rem ChaosFight - Source/Banks/Bank7.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Missile system (tables, physics, collision) + combat system

          bank 7

#include "Source/Data/CharacterMissileTables.bas"
#include "Source/Routines/CharacterMissileData.bas"
#include "Source/Data/CharacterDataTables.bas"

          asm
Bank7DataEnds
end

#include "Source/Routines/CharacterAttacksDispatch.bas"
#include "Source/Routines/PerformRangedAttack.bas"
#include "Source/Routines/PerformMeleeAttack.bas"
#include "Source/Routines/MissileSystem.bas"
#include "Source/Routines/MissileCharacterHandlers.bas"
#include "Source/Routines/Combat.bas"

          asm
Bank7CodeEnds
end
