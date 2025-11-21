          rem ChaosFight - Source/Banks/Bank6.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character selection system (main/render)

          bank 6

          asm
HealthBarPatternsStart
end
#include "Source/Data/HealthBarPatterns.bas"
          asm
HealthBarPatternsEnd
            echo "// Bank 6: ", [HealthBarPatternsEnd - HealthBarPatternsStart]d, " bytes = HealthBarPatterns"
Bank6DataEnds
end

          rem Character select routines
          asm
PlayerLockedHelpersStart
end
#include "Source/Routines/PlayerLockedHelpers.bas"
          asm
PlayerLockedHelpersEnd
            echo "// Bank 6: ", [PlayerLockedHelpersEnd - PlayerLockedHelpersStart]d, " bytes = PlayerLockedHelpers"
CharacterSelectRenderStart
end
#include "Source/Routines/CharacterSelectRender.bas"
          asm
CharacterSelectRenderEnd
            echo "// Bank 6: ", [CharacterSelectRenderEnd - CharacterSelectRenderStart]d, " bytes = CharacterSelectRender"
CharacterSelectEntryStart
end
#include "Source/Routines/CharacterSelectEntry.bas"
          asm
CharacterSelectEntryEnd
            echo "// Bank 6: ", [CharacterSelectEntryEnd - CharacterSelectEntryStart]d, " bytes = CharacterSelectEntry"
SetSpritePositionsStart
end
#include "Source/Routines/SetSpritePositions.bas"
          asm
SetSpritePositionsEnd
            echo "// Bank 6: ", [SetSpritePositionsEnd - SetSpritePositionsStart]d, " bytes = SetSpritePositions"
SetPlayerSpritesStart
end
#include "Source/Routines/SetPlayerSprites.bas"
          asm
SetPlayerSpritesEnd
            echo "// Bank 6: ", [SetPlayerSpritesEnd - SetPlayerSpritesStart]d, " bytes = SetPlayerSprites"
ApplyGuardColorStart
end
#include "Source/Routines/ApplyGuardColor.bas"
          asm
ApplyGuardColorEnd
            echo "// Bank 6: ", [ApplyGuardColorEnd - ApplyGuardColorStart]d, " bytes = ApplyGuardColor"
RestoreNormalPlayerColorStart
end
#include "Source/Routines/RestoreNormalPlayerColor.bas"
          asm
RestoreNormalPlayerColorEnd
            echo "// Bank 6: ", [RestoreNormalPlayerColorEnd - RestoreNormalPlayerColorStart]d, " bytes = RestoreNormalPlayerColor"
CheckGuardCooldownStart
end
#include "Source/Routines/CheckGuardCooldown.bas"
          asm
CheckGuardCooldownEnd
            echo "// Bank 6: ", [CheckGuardCooldownEnd - CheckGuardCooldownStart]d, " bytes = CheckGuardCooldown"
StartGuardStart
end
#include "Source/Routines/StartGuard.bas"
          asm
StartGuardEnd
            echo "// Bank 6: ", [StartGuardEnd - StartGuardStart]d, " bytes = StartGuard"
UpdateSingleGuardTimerStart
end
#include "Source/Routines/UpdateSingleGuardTimer.bas"
          asm
UpdateSingleGuardTimerEnd
            echo "// Bank 6: ", [UpdateSingleGuardTimerEnd - UpdateSingleGuardTimerStart]d, " bytes = UpdateSingleGuardTimer"
UpdateGuardTimersStart
end
#include "Source/Routines/UpdateGuardTimers.bas"
          asm
UpdateGuardTimersEnd
            echo "// Bank 6: ", [UpdateGuardTimersEnd - UpdateGuardTimersStart]d, " bytes = UpdateGuardTimers"
CharacterSelectFireStart
end
#include "Source/Routines/CharacterSelectFire.bas"
          asm
CharacterSelectFireEnd
            echo "// Bank 6: ", [CharacterSelectFireEnd - CharacterSelectFireStart]d, " bytes = CharacterSelectFire"
CharacterSelectHelpersStart
end
#include "Source/Routines/CharacterSelectHelpers.bas"
          asm
CharacterSelectHelpersEnd
            echo "// Bank 6: ", [CharacterSelectHelpersEnd - CharacterSelectHelpersStart]d, " bytes = CharacterSelectHelpers"
MovePlayerToTargetStart
end
#include "Source/Routines/MovePlayerToTarget.bas"
          asm
MovePlayerToTargetEnd
            echo "// Bank 6: ", [MovePlayerToTargetEnd - MovePlayerToTargetStart]d, " bytes = MovePlayerToTarget"

          asm
FramePhaseSchedulerStart
end
#include "Source/Routines/FramePhaseScheduler.bas"
          asm
FramePhaseSchedulerEnd
            echo "// Bank 6: ", [FramePhaseSchedulerEnd - FramePhaseSchedulerStart]d, " bytes = FramePhaseScheduler"

          asm
BudgetedHealthBarsStart
end
#include "Source/Routines/BudgetedHealthBars.bas"
          asm
BudgetedHealthBarsEnd
            echo "// Bank 6: ", [BudgetedHealthBarsEnd - BudgetedHealthBarsStart]d, " bytes = BudgetedHealthBars"
Bank6CodeEnds
end
