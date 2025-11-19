          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Physics system (gravity, movement, special abilities, fall damage) + screen layout +
          rem   health bars

          bank 8

          rem Code segment
          asm
CharacterPhysicsTablesStart
end
#include "Source/Data/CharacterPhysicsTables.bas"
          asm
CharacterPhysicsTablesEnd
            echo "// Bank 8: ", [CharacterPhysicsTablesEnd - CharacterPhysicsTablesStart]d, " bytes = CharacterPhysicsTables"
Bank8DataEnds
end

          asm
ApplyMomentumAndRecoveryStart
end
#include "Source/Routines/ApplyMomentumAndRecovery.bas"
          asm
ApplyMomentumAndRecoveryEnd
            echo "// Bank 8: ", [ApplyMomentumAndRecoveryEnd - ApplyMomentumAndRecoveryStart]d, " bytes = ApplyMomentumAndRecovery"
InputHandleAllPlayersStart
end
#include "Source/Routines/InputHandleAllPlayers.bas"
          asm
InputHandleAllPlayersEnd
            echo "// Bank 8: ", [InputHandleAllPlayersEnd - InputHandleAllPlayersStart]d, " bytes = InputHandleAllPlayers"
HandleGuardInputStart
end
#include "Source/Routines/HandleGuardInput.bas"
          asm
HandleGuardInputEnd
            echo "// Bank 8: ", [HandleGuardInputEnd - HandleGuardInputStart]d, " bytes = HandleGuardInput"
ProcessAttackInputStart
end
#include "Source/Routines/ProcessAttackInput.bas"
          asm
ProcessAttackInputEnd
            echo "// Bank 8: ", [ProcessAttackInputEnd - ProcessAttackInputStart]d, " bytes = ProcessAttackInput"
InputHandleLeftPortPlayerFunctionStart
end
#include "Source/Routines/InputHandleLeftPortPlayerFunction.bas"
          asm
InputHandleLeftPortPlayerFunctionEnd
            echo "// Bank 8: ", [InputHandleLeftPortPlayerFunctionEnd - InputHandleLeftPortPlayerFunctionStart]d, " bytes = InputHandleLeftPortPlayerFunction"
InputHandleRightPortPlayerFunctionStart
end
#include "Source/Routines/InputHandleRightPortPlayerFunction.bas"
          asm
InputHandleRightPortPlayerFunctionEnd
            echo "// Bank 8: ", [InputHandleRightPortPlayerFunctionEnd - InputHandleRightPortPlayerFunctionStart]d, " bytes = InputHandleRightPortPlayerFunction"
UpdatePlayerMovementSingleStart
end
#include "Source/Routines/UpdatePlayerMovementSingle.bas"
          asm
UpdatePlayerMovementSingleEnd
            echo "// Bank 8: ", [UpdatePlayerMovementSingleEnd - UpdatePlayerMovementSingleStart]d, " bytes = UpdatePlayerMovementSingle"
UpdatePlayerMovementStart
end
#include "Source/Routines/UpdatePlayerMovement.bas"
          asm
UpdatePlayerMovementEnd
            echo "// Bank 8: ", [UpdatePlayerMovementEnd - UpdatePlayerMovementStart]d, " bytes = UpdatePlayerMovement"
PhysicsStart
end
#include "Source/Routines/Physics.bas"
          asm
PhysicsEnd
            echo "// Bank 8: ", [PhysicsEnd - PhysicsStart]d, " bytes = Physics"
FallDamageStart
end
#include "Source/Routines/FallDamage.bas"
          asm
FallDamageEnd
            echo "// Bank 8: ", [FallDamageEnd - FallDamageStart]d, " bytes = FallDamage"
ScreenLayoutStart
end
#include "Source/Routines/ScreenLayout.bas"
          asm
ScreenLayoutEnd
            echo "// Bank 8: ", [ScreenLayoutEnd - ScreenLayoutStart]d, " bytes = ScreenLayout"
ProcessJumpInputStart
end
#include "Source/Routines/ProcessJumpInput.bas"
          asm
ProcessJumpInputEnd
            echo "// Bank 8: ", [ProcessJumpInputEnd - ProcessJumpInputStart]d, " bytes = ProcessJumpInput"
MissileCollisionStart
end
#include "Source/Routines/MissileCollision.bas"
          asm
MissileCollisionEnd
            echo "// Bank 8: ", [MissileCollisionEnd - MissileCollisionStart]d, " bytes = MissileCollision"
Bank8CodeEnds
end
