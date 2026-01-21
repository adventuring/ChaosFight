;;; ChaosFight - Source/Banks/Bank5.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Character selection system (main/render)

          ;; Set file offset for Bank 5 at the top of the file
          .offs (5 * $1000) - $f000  ; Adjust file offset for Bank 5
          * = $F000
          .rept 256
          .byte $ff
          .endrept
HealthBarPatternsStart:
.include "Source/Data/HealthBarPatterns.s"
HealthBarPatternsEnd:
            .warn format("// Bank 5: %d bytes = HealthBarPatterns", [HealthBarPatternsEnd - HealthBarPatternsStart])
Bank5DataEnds:

          ;; Character select routines
PlayerLockedHelpersStart:
.include "Source/Routines/PlayerLockedHelpers.s"
PlayerLockedHelpersEnd:
            .warn format("// Bank 5: %d bytes = PlayerLockedHelpers", [PlayerLockedHelpersEnd - PlayerLockedHelpersStart])
CharacterSelectRenderStart:
.include "Source/Routines/CharacterSelectRender.s"
CharacterSelectRenderEnd:
            .warn format("// Bank 5: %d bytes = CharacterSelectRender", [CharacterSelectRenderEnd - CharacterSelectRenderStart])
CharacterSelectEntryStart:
.include "Source/Routines/CharacterSelectEntry.s"
CharacterSelectEntryEnd:
            .warn format("// Bank 5: %d bytes = CharacterSelectEntry", [CharacterSelectEntryEnd - CharacterSelectEntryStart])
SetSpritePositionsStart:
.include "Source/Routines/SetSpritePositions.s"
SetSpritePositionsEnd:
            .warn format("// Bank 5: %d bytes = SetSpritePositions", [SetSpritePositionsEnd - SetSpritePositionsStart])
SetPlayerSpritesStart:
.include "Source/Routines/SetPlayerSprites.s"
SetPlayerSpritesEnd:
            .warn format("// Bank 5: %d bytes = SetPlayerSprites", [SetPlayerSpritesEnd - SetPlayerSpritesStart])
ApplyGuardColorStart:
.include "Source/Routines/ApplyGuardColor.s"
ApplyGuardColorEnd:
            .warn format("// Bank 5: %d bytes = ApplyGuardColor", [ApplyGuardColorEnd - ApplyGuardColorStart])
RestoreNormalPlayerColorStart:
.include "Source/Routines/RestoreNormalPlayerColor.s"
RestoreNormalPlayerColorEnd:
            .warn format("// Bank 5: %d bytes = RestoreNormalPlayerColor", [RestoreNormalPlayerColorEnd - RestoreNormalPlayerColorStart])
CheckGuardCooldownStart:
.include "Source/Routines/CheckGuardCooldown.s"
CheckGuardCooldownEnd:
            .warn format("// Bank 5: %d bytes = CheckGuardCooldown", [CheckGuardCooldownEnd - CheckGuardCooldownStart])
StartGuardStart:
.include "Source/Routines/StartGuard.s"
StartGuardEnd:
            .warn format("// Bank 5: %d bytes = StartGuard", [StartGuardEnd - StartGuardStart])
UpdateSingleGuardTimerStart:
.include "Source/Routines/UpdateSingleGuardTimer.s"
UpdateSingleGuardTimerEnd:
            .warn format("// Bank 5: %d bytes = UpdateSingleGuardTimer", [UpdateSingleGuardTimerEnd - UpdateSingleGuardTimerStart])
UpdateGuardTimersStart:
.include "Source/Routines/UpdateGuardTimers.s"
UpdateGuardTimersEnd:
            .warn format("// Bank 5: %d bytes = UpdateGuardTimers", [UpdateGuardTimersEnd - UpdateGuardTimersStart])
CharacterSelectFireStart:
.include "Source/Routines/CharacterSelectFire.s"
CharacterSelectFireEnd:
            .warn format("// Bank 5: %d bytes = CharacterSelectFire", [CharacterSelectFireEnd - CharacterSelectFireStart])
CharacterSelectHelpersStart:
.include "Source/Routines/SelectStickLeft.s"
CharacterSelectHelpersEnd:
            .warn format("// Bank 5: %d bytes = CharacterSelectHelpers", [CharacterSelectHelpersEnd - CharacterSelectHelpersStart])
MovePlayerToTargetStart:
.include "Source/Routines/MovePlayerToTarget.s"
FramePhaseSchedulerStart:
.include "Source/Routines/UpdateFramePhase.s"
BudgetedHealthBarsStart:
.include "Source/Routines/BudgetedHealthBars.s"
BudgetedHealthBarsEnd:
            .warn format("// Bank 5: %d bytes = BudgetedHealthBars", [BudgetedHealthBarsEnd - BudgetedHealthBarsStart])
Bank5CodeEnds:

          ;; Include BankSwitching.s in Bank 5
          ;; Wrap in .block to create namespace Bank5BS (avoids duplicate definitions)
Bank5BS: .block
          current_bank = 5
          .include "Source/Common/BankSwitching.s"
          .bend
