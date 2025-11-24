          rem ChaosFight - Source/Banks/Bank13.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Input system (movement, player input, guard effects)

          bank 13

          asm
Bank13DataEnds
end

          asm
CheckPlayerCollisionStart
end
#include "Source/Routines/CheckPlayerCollision.bas"
          asm
CheckPlayerCollisionEnd
            echo "// Bank 13: ", [CheckPlayerCollisionEnd - CheckPlayerCollisionStart]d, " bytes = CheckPlayerCollision"
ControllerDetectionStart
end
#include "Source/Routines/ControllerDetection.bas"
          asm
ControllerDetectionEnd
            echo "// Bank 13: ", [ControllerDetectionEnd - ControllerDetectionStart]d, " bytes = ControllerDetection"
GetPlayerAnimationStateFunctionStart
end
#include "Source/Routines/GetPlayerAnimationStateFunction.bas"
          asm
GetPlayerAnimationStateFunctionEnd
            echo "// Bank 13: ", [GetPlayerAnimationStateFunctionEnd - GetPlayerAnimationStateFunctionStart]d, " bytes = GetPlayerAnimationStateFunction"
PlayerPhysicsGravityStart
end
#include "Source/Routines/PlayerPhysicsGravity.bas"
          asm
PlayerPhysicsGravityEnd
            echo "// Bank 13: ", [PlayerPhysicsGravityEnd - PlayerPhysicsGravityStart]d, " bytes = PlayerPhysicsGravity"
InitializeMovementSystemStart
end
#include "Source/Routines/InitializeMovementSystem.bas"
          asm
InitializeMovementSystemEnd
            echo "// Bank 13: ", [InitializeMovementSystemEnd - InitializeMovementSystemStart]d, " bytes = InitializeMovementSystem"
ConstrainToScreenStart
end
#include "Source/Routines/ConstrainToScreen.bas"
          asm
ConstrainToScreenEnd
            echo "// Bank 13: ", [ConstrainToScreenEnd - ConstrainToScreenStart]d, " bytes = ConstrainToScreen"
AddVelocitySubpixelYStart
end
#include "Source/Routines/AddVelocitySubpixelY.bas"
          asm
AddVelocitySubpixelYEnd
            echo "// Bank 13: ", [AddVelocitySubpixelYEnd - AddVelocitySubpixelYStart]d, " bytes = AddVelocitySubpixelY"
ProcessStandardMovementStart
end
#include "Source/Routines/ProcessStandardMovement.bas"
          asm
ProcessStandardMovementEnd
            echo "// Bank 13: ", [ProcessStandardMovementEnd - ProcessStandardMovementStart]d, " bytes = ProcessStandardMovement"
ConsoleHandlingStart
end
#include "Source/Routines/ConsoleHandling.bas"
          asm
ConsoleHandlingEnd
            echo "// Bank 13: ", [ConsoleHandlingEnd - ConsoleHandlingStart]d, " bytes = ConsoleHandling"
TriggerEliminationEffectsStart
end
#include "Source/Routines/TriggerEliminationEffects.bas"
          asm
TriggerEliminationEffectsEnd
            echo "// Bank 13: ", [TriggerEliminationEffectsEnd - TriggerEliminationEffectsStart]d, " bytes = TriggerEliminationEffects"
GetCharacterAttackTypeStart
end
#include "Source/Routines/GetCharacterAttackType.bas"
          asm
GetCharacterAttackTypeEnd
            echo "// Bank 13: ", [GetCharacterAttackTypeEnd - GetCharacterAttackTypeStart]d, " bytes = GetCharacterAttackType"
IsCharacterRangedStart
end
#include "Source/Routines/IsCharacterRanged.bas"
          asm
IsCharacterRangedEnd
            echo "// Bank 13: ", [IsCharacterRangedEnd - IsCharacterRangedStart]d, " bytes = IsCharacterRanged"
IsCharacterMeleeStart
end
#include "Source/Routines/IsCharacterMelee.bas"
          asm
IsCharacterMeleeEnd
            echo "// Bank 13: ", [IsCharacterMeleeEnd - IsCharacterMeleeStart]d, " bytes = IsCharacterMelee"
IsPlayerEliminatedStart
end
#include "Source/Routines/IsPlayerEliminated.bas"
          asm
IsPlayerEliminatedEnd
            echo "// Bank 13: ", [IsPlayerEliminatedEnd - IsPlayerEliminatedStart]d, " bytes = IsPlayerEliminated"
IsPlayerAliveStart
end
#include "Source/Routines/IsPlayerAlive.bas"
          asm
IsPlayerAliveEnd
            echo "// Bank 13: ", [IsPlayerAliveEnd - IsPlayerAliveStart]d, " bytes = IsPlayerAlive"
CharacterControlsDownStart
end
#include "Source/Routines/CharacterControlsDown.bas"
          asm
CharacterControlsDownEnd
            echo "// Bank 13: ", [CharacterControlsDownEnd - CharacterControlsDownStart]d, " bytes = CharacterControlsDown"
Bank13CodeEnds
end
