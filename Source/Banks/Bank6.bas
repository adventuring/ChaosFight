          rem ChaosFight - Source/Banks/Bank6.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character selection system (main/render)

          bank 6

          asm
Bank6DataEnds
end

          rem Character select routines
#include "Source/Routines/PlayerLockedHelpers.bas"
#include "Source/Routines/CharacterSelectRender.bas"
#include "Source/Routines/CharacterSelectEntry.bas"
#include "Source/Routines/SetSpritePositions.bas"
#include "Source/Routines/SetPlayerSprites.bas"
#include "Source/Routines/ApplyGuardColor.bas"
#include "Source/Routines/RestoreNormalPlayerColor.bas"
#include "Source/Routines/CheckGuardCooldown.bas"
#include "Source/Routines/StartGuard.bas"
#include "Source/Routines/UpdateSingleGuardTimer.bas"
#include "Source/Routines/UpdateGuardTimers.bas"
#include "Source/Routines/BeginFallingAnimation.bas"
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"

#include "Source/Routines/MovementApplyGravity.bas"
#include "Source/Routines/GetPlayerPosition.bas"
#include "Source/Routines/GetPlayerVelocity.bas"
#include "Source/Routines/SetPlayerPosition.bas"
#include "Source/Routines/SetPlayerVelocity.bas"
#include "Source/Routines/ApplyFriction.bas"

#include "Source/Routines/CharacterSelectFire.bas"
#include "Source/Routines/CharacterSelectHelpers.bas"

          rem Winner announcement routines moved from Bank 12 to prevent overflow
#include "Source/Routines/WinnerAnnouncement.bas"
#include "Source/Routines/BeginWinnerAnnouncement.bas"


          asm
Bank6CodeEnds
end
