          rem ChaosFight - Source/Banks/Bank12.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Input system (movement, player input, guard effects)
          bank 12
          asm
Bank13DataEnds
end

          asm
CheckPlayerCollisionStart
end
#include "Source/Routines/CheckPlayerCollision.bas"
          asm
CheckPlayerCollisionEnd
            echo "// Bank 12: ", [CheckPlayerCollisionEnd - CheckPlayerCollisionStart]d, " bytes = CheckPlayerCollision"
ControllerDetectionStart
end
#include "Source/Routines/ControllerDetection.bas"
          asm
ControllerDetectionEnd
            echo "// Bank 12: ", [ControllerDetectionEnd - ControllerDetectionStart]d, " bytes = ControllerDetection"
GetPlayerAnimationStateFunctionStart
end
#include "Source/Routines/GetPlayerAnimationStateFunction.bas"
          asm
GetPlayerAnimationStateFunctionEnd
            echo "// Bank 12: ", [GetPlayerAnimationStateFunctionEnd - GetPlayerAnimationStateFunctionStart]d, " bytes = GetPlayerAnimationStateFunction"
PlayerPhysicsGravityStart
end
#include "Source/Routines/PlayerPhysicsGravity.bas"
          asm
PlayerPhysicsGravityEnd
            echo "// Bank 12: ", [PlayerPhysicsGravityEnd - PlayerPhysicsGravityStart]d, " bytes = PlayerPhysicsGravity"
InitializeMovementSystemStart
end
#include "Source/Routines/InitializeMovementSystem.bas"
          asm
InitializeMovementSystemEnd
            echo "// Bank 12: ", [InitializeMovementSystemEnd - InitializeMovementSystemStart]d, " bytes = InitializeMovementSystem"
ConstrainToScreenStart
end
#include "Source/Routines/ConstrainToScreen.bas"
          asm
ConstrainToScreenEnd
            echo "// Bank 12: ", [ConstrainToScreenEnd - ConstrainToScreenStart]d, " bytes = ConstrainToScreen"
AddVelocitySubpixelYStart
end
#include "Source/Routines/AddVelocitySubpixelY.bas"
          asm
AddVelocitySubpixelYEnd
            echo "// Bank 12: ", [AddVelocitySubpixelYEnd - AddVelocitySubpixelYStart]d, " bytes = AddVelocitySubpixelY"
ProcessStandardMovementStart
end
#include "Source/Routines/ProcessStandardMovement.bas"
          asm
ProcessStandardMovementEnd
            echo "// Bank 12: ", [ProcessStandardMovementEnd - ProcessStandardMovementStart]d, " bytes = ProcessStandardMovement"
ConsoleHandlingStart
end
#include "Source/Routines/ConsoleHandling.bas"
          asm
ConsoleHandlingEnd
            echo "// Bank 12: ", [ConsoleHandlingEnd - ConsoleHandlingStart]d, " bytes = ConsoleHandling"
TriggerEliminationEffectsStart
end
#include "Source/Routines/TriggerEliminationEffects.bas"
          asm
TriggerEliminationEffectsEnd
            echo "// Bank 12: ", [TriggerEliminationEffectsEnd - TriggerEliminationEffectsStart]d, " bytes = TriggerEliminationEffects"
IsPlayerEliminatedStart
end
#include "Source/Routines/IsPlayerEliminated.bas"
          asm
IsPlayerEliminatedEnd
            echo "// Bank 12: ", [IsPlayerEliminatedEnd - IsPlayerEliminatedStart]d, " bytes = IsPlayerEliminated"
;; IsPlayerAlive has been inlined at all call sites (FIXME #1252)
CharacterDownHandlersStart
end
#include "Source/Routines/CharacterDownHandlers.bas"
          asm
CharacterDownHandlersEnd
            echo "// Bank 12: ", [CharacterDownHandlersEnd - CharacterDownHandlersStart]d, " bytes = CharacterDownHandlers"
Bank13CodeEnds
end
