          rem ChaosFight - Source/Banks/Bank5.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Character selection system (main/render)
          bank 5
          asm
HealthBarPatternsStart
end
#include "Source/Data/HealthBarPatterns.bas"
          asm
HealthBarPatternsEnd
            echo "// Bank 5: ", [HealthBarPatternsEnd - HealthBarPatternsStart]d, " bytes = HealthBarPatterns"
Bank6DataEnds
end

          rem Character select routines
          asm
PlayerLockedHelpersStart
end
#include "Source/Routines/PlayerLockedHelpers.bas"
          asm
PlayerLockedHelpersEnd
            echo "// Bank 5: ", [PlayerLockedHelpersEnd - PlayerLockedHelpersStart]d, " bytes = PlayerLockedHelpers"
CharacterSelectRenderStart
end
#include "Source/Routines/CharacterSelectRender.bas"
          asm
CharacterSelectRenderEnd
            echo "// Bank 5: ", [CharacterSelectRenderEnd - CharacterSelectRenderStart]d, " bytes = CharacterSelectRender"
CharacterSelectEntryStart
end
#include "Source/Routines/CharacterSelectEntry.bas"
          asm
CharacterSelectEntryEnd
            echo "// Bank 5: ", [CharacterSelectEntryEnd - CharacterSelectEntryStart]d, " bytes = CharacterSelectEntry"
SetSpritePositionsStart
end
#include "Source/Routines/SetSpritePositions.bas"
          asm
SetSpritePositionsEnd
            echo "// Bank 5: ", [SetSpritePositionsEnd - SetSpritePositionsStart]d, " bytes = SetSpritePositions"
SetPlayerSpritesStart
end
#include "Source/Routines/SetPlayerSprites.bas"
          asm
SetPlayerSpritesEnd
            echo "// Bank 5: ", [SetPlayerSpritesEnd - SetPlayerSpritesStart]d, " bytes = SetPlayerSprites"
ApplyGuardColorStart
end
#include "Source/Routines/ApplyGuardColor.bas"
          asm
ApplyGuardColorEnd
            echo "// Bank 5: ", [ApplyGuardColorEnd - ApplyGuardColorStart]d, " bytes = ApplyGuardColor"
RestoreNormalPlayerColorStart
end
#include "Source/Routines/RestoreNormalPlayerColor.bas"
          asm
RestoreNormalPlayerColorEnd
            echo "// Bank 5: ", [RestoreNormalPlayerColorEnd - RestoreNormalPlayerColorStart]d, " bytes = RestoreNormalPlayerColor"
CheckGuardCooldownStart
end
#include "Source/Routines/CheckGuardCooldown.bas"
          asm
CheckGuardCooldownEnd
            echo "// Bank 5: ", [CheckGuardCooldownEnd - CheckGuardCooldownStart]d, " bytes = CheckGuardCooldown"
StartGuardStart
end
#include "Source/Routines/StartGuard.bas"
          asm
StartGuardEnd
            echo "// Bank 5: ", [StartGuardEnd - StartGuardStart]d, " bytes = StartGuard"
UpdateSingleGuardTimerStart
end
#include "Source/Routines/UpdateSingleGuardTimer.bas"
          asm
UpdateSingleGuardTimerEnd
            echo "// Bank 5: ", [UpdateSingleGuardTimerEnd - UpdateSingleGuardTimerStart]d, " bytes = UpdateSingleGuardTimer"
UpdateGuardTimersStart
end
#include "Source/Routines/UpdateGuardTimers.bas"
          asm
UpdateGuardTimersEnd
            echo "// Bank 5: ", [UpdateGuardTimersEnd - UpdateGuardTimersStart]d, " bytes = UpdateGuardTimers"
CharacterSelectFireStart
end
#include "Source/Routines/CharacterSelectFire.bas"
          asm
CharacterSelectFireEnd
            echo "// Bank 5: ", [CharacterSelectFireEnd - CharacterSelectFireStart]d, " bytes = CharacterSelectFire"
CharacterSelectHelpersStart
end
#include "Source/Routines/SelectStickLeft.bas"
          asm
CharacterSelectHelpersEnd
            echo "// Bank 5: ", [CharacterSelectHelpersEnd - CharacterSelectHelpersStart]d, " bytes = CharacterSelectHelpers"
MovePlayerToTargetStart
end
#include "Source/Routines/MovePlayerToTarget.bas"
          asm
MovePlayerToTargetEnd
            echo "// Bank 5: ", [MovePlayerToTargetEnd - MovePlayerToTargetStart]d, " bytes = MovePlayerToTarget"

          asm
FramePhaseSchedulerStart
end
#include "Source/Routines/UpdateFramePhase.bas"
          asm
FramePhaseSchedulerEnd
            echo "// Bank 5: ", [FramePhaseSchedulerEnd - FramePhaseSchedulerStart]d, " bytes = FramePhaseScheduler"

          asm
BudgetedHealthBarsStart
end
#include "Source/Routines/BudgetedHealthBars.bas"
          asm
BudgetedHealthBarsEnd
            echo "// Bank 5: ", [BudgetedHealthBarsEnd - BudgetedHealthBarsStart]d, " bytes = BudgetedHealthBars"
Bank6CodeEnds
end
