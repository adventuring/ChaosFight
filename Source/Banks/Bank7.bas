          rem ChaosFight - Source/Banks/Bank7.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Missile system (tables, physics, collision) + combat system


#include "Source/Data/CharacterMissileTables.bas"
#include "Source/Routines/CharacterMissileData.bas"
#include "Source/Data/HealthBarPatterns.bas"

          asm
Bank7DataEnds
end

#include "Source/Routines/ScreenLayout.bas"
#include "Source/Routines/CharacterAttacksDispatch.bas"
#include "Source/Routines/PerformRangedAttack.bas"
#include "Source/Routines/PerformMeleeAttack.bas"
#include "Source/Routines/FrameBudgeting.bas"
#include "Source/Routines/MissileCollision.bas"
#include "Source/Routines/CharacterSelectFire.bas"
#include "Source/Routines/CharacterSelectHelpers.bas"

          asm
Bank7CodeEnds
end
