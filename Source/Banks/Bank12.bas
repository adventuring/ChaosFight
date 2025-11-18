          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character data system (definitions, cycles, fall damage) +
          rem Titlescreen graphics and kernel

          bank 12

          rem Character data tables
#include "Source/Data/CharacterThemeSongIndices.bas"

          asm
Bank12DataEnds
end

#include "Source/Routines/UpdateAttackCooldowns.bas"
#include "Source/Routines/PlayerInput.bas"
#include "Source/Routines/CharacterDamage.bas"
#include "Source/Routines/DeactivatePlayerMissiles.bas"
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"

          asm
Bank12CodeEnds
end
