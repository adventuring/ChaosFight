          rem ChaosFight - Source/Banks/Bank6.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character selection system (main/render)

          bank 6

          asm
Bank6DataEnds = .
end

          rem Character select routines
#include "Source/Routines/PlayerLockedHelpers.bas"
#include "Source/Routines/CharacterSelectRender.bas"
#include "Source/Routines/CharacterSelectEntry.bas"

          rem Health display routines (HealthBarSystem here, DisplayHealth in Bank 12)
#include "Source/Routines/HealthBarSystem.bas"

          rem Sprite rendering routines moved from Bank 10 for ROM balance
#include "Source/Routines/SetSpritePositions.bas"
#include "Source/Routines/SetPlayerSprites.bas"

          rem Guard system routines moved from Bank 10 for ROM balance
#include "Source/Routines/ApplyGuardColor.bas"
#include "Source/Routines/RestoreNormalPlayerColor.bas"
#include "Source/Routines/CheckGuardCooldown.bas"
#include "Source/Routines/StartGuard.bas"
#include "Source/Routines/UpdateSingleGuardTimer.bas"
#include "Source/Routines/UpdateGuardTimers.bas"

          rem Falling animation setup routine
#include "Source/Routines/BeginFallingAnimation.bas"

          rem CheckRoboTitoStretchMissileCollisions moved back from Bank 12 for ROM balance
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"

          asm
Bank6CodeEnds = .
end
