          rem ChaosFight - Source/Banks/Bank11.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Gameplay loop (init/main/collision resolution/animation)

          bank 11

          asm
Bank11DataEnds
end

          asm
GameLoopInitStart
end
#include "Source/Routines/GameLoopInit.bas"
          asm
GameLoopInitEnd
            echo "// Bank 11: ", [GameLoopInitEnd - GameLoopInitStart]d, " bytes = GameLoopInit"
GameLoopMainStart
end
#include "Source/Routines/GameLoopMain.bas"
          asm
GameLoopMainEnd
            echo "// Bank 11: ", [GameLoopMainEnd - GameLoopMainStart]d, " bytes = GameLoopMain"
PlayerCollisionResolutionStart
end
#include "Source/Routines/PlayerCollisionResolution.bas"
          asm
PlayerCollisionResolutionEnd
            echo "// Bank 11: ", [PlayerCollisionResolutionEnd - PlayerCollisionResolutionStart]d, " bytes = PlayerCollisionResolution"
DisplayHealthStart
end
#include "Source/Routines/DisplayHealth.bas"
          asm
DisplayHealthEnd
            echo "// Bank 11: ", [DisplayHealthEnd - DisplayHealthStart]d, " bytes = DisplayHealth"
HealthBarSystemStart
end
#include "Source/Routines/HealthBarSystem.bas"
          asm
HealthBarSystemEnd
            echo "// Bank 11: ", [HealthBarSystemEnd - HealthBarSystemStart]d, " bytes = HealthBarSystem"
          asm
FramePhaseSchedulerStart
end
#include "Source/Routines/FramePhaseScheduler.bas"
          asm
FramePhaseSchedulerEnd
            echo "// Bank 11: ", [FramePhaseSchedulerEnd - FramePhaseSchedulerStart]d, " bytes = FramePhaseScheduler"
          asm
BudgetedHealthBarsStart
end
#include "Source/Routines/BudgetedHealthBars.bas"
          asm
BudgetedHealthBarsEnd
            echo "// Bank 11: ", [BudgetedHealthBarsEnd - BudgetedHealthBarsStart]d, " bytes = BudgetedHealthBars"
FallingAnimationStart
end
#include "Source/Routines/FallingAnimation.bas"
          asm
FallingAnimationEnd
            echo "// Bank 11: ", [FallingAnimationEnd - FallingAnimationStart]d, " bytes = FallingAnimation"
Bank11CodeEnds
end
