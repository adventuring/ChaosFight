          rem ChaosFight - Source/Banks/Bank10.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Gameplay loop (init/main/collision resolution/animation)
          bank 10
          asm
Bank11DataEnds
end

          asm
GameLoopInitStart
end
#include "Source/Routines/GameLoopInit.bas"
          asm
GameLoopInitEnd
            echo "// Bank 10: ", [GameLoopInitEnd - GameLoopInitStart]d, " bytes = GameLoopInit"
          asm
GameLoopMainStart
end
#include "Source/Routines/GameLoopMain.bas"
          asm
GameLoopMainEnd
            echo "// Bank 10: ", [GameLoopMainEnd - GameLoopMainStart]d, " bytes = GameLoopMain"
          asm
PlayerCollisionResolutionStart
end
#include "Source/Routines/PlayerCollisionResolution.bas"
          asm
PlayerCollisionResolutionEnd
            echo "// Bank 10: ", [PlayerCollisionResolutionEnd - PlayerCollisionResolutionStart]d, " bytes = PlayerCollisionResolution"
end
          asm
DisplayHealthStart
end
#include "Source/Routines/DisplayHealth.bas"
          asm
DisplayHealthEnd
            echo "// Bank 10: ", [DisplayHealthEnd - DisplayHealthStart]d, " bytes = DisplayHealth"
          asm
HealthBarSystemStart
end
#include "Source/Routines/HealthBarSystem.bas"
          asm
HealthBarSystemEnd
            echo "// Bank 10: ", [HealthBarSystemEnd - HealthBarSystemStart]d, " bytes = HealthBarSystem"
          asm
FallingAnimationStart
end
#include "Source/Routines/FallingAnimation.bas"
          asm
FallingAnimationEnd
            echo "// Bank 10: ", [FallingAnimationEnd - FallingAnimationStart]d, " bytes = FallingAnimation"
          asm
VblankHandlersStart
end
#include "Source/Routines/VblankHandlers.bas"
          asm
VblankHandlersEnd
            echo "// Bank 10: ", [VblankHandlersEnd - VblankHandlersStart]d, " bytes = VblankHandlers"
Bank11CodeEnds
end
