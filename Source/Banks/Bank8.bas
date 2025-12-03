          rem ChaosFight - Source/Banks/Bank8.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
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
HandleUpInputStart
end
#include "Source/Routines/HandleUpInput.bas"
          asm
HandleUpInputEnd
            echo "// Bank 8: ", [HandleUpInputEnd - HandleUpInputStart]d, " bytes = HandleUpInput"
ProcessUpActionStart
end
#include "Source/Routines/ProcessUpAction.bas"
          asm
ProcessUpActionEnd
            echo "// Bank 8: ", [ProcessUpActionEnd - ProcessUpActionStart]d, " bytes = ProcessUpAction"
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
FallDamageStart
end
#include "Source/Routines/FallDamage.bas"
          asm
FallDamageEnd
            echo "// Bank 8: ", [FallDamageEnd - FallDamageStart]d, " bytes = FallDamage"
ProcessJumpInputStart
end
#include "Source/Routines/ProcessJumpInput.bas"
          asm
ProcessJumpInputEnd
            echo "// Bank 8: ", [ProcessJumpInputEnd - ProcessJumpInputStart]d, " bytes = ProcessJumpInput"
          asm
DispatchCharacterJumpStart
end
#include "Source/Routines/DispatchCharacterJump.bas"
          asm
DispatchCharacterJumpEnd
            echo "// Bank 8: ", [DispatchCharacterJumpEnd - DispatchCharacterJumpStart]d, " bytes = DispatchCharacterJump"
MissileCollisionStart
end
#include "Source/Routines/MissileCollision.bas"
          asm
MissileCollisionEnd
            echo "// Bank 8: ", [MissileCollisionEnd - MissileCollisionStart]d, " bytes = MissileCollision"
          asm
BudgetedPlayerCollisionsStart
end
#include "Source/Routines/BudgetedPlayerCollisions.bas"
          asm
BudgetedPlayerCollisionsEnd
            echo "// Bank 8: ", [BudgetedPlayerCollisionsEnd - BudgetedPlayerCollisionsStart]d, " bytes = BudgetedPlayerCollisions"
          asm
FrootyAttackStart
end
#include "Source/Routines/FrootyAttack.bas"
          asm
FrootyAttackEnd
            echo "// Bank 8: ", [FrootyAttackEnd - FrootyAttackStart]d, " bytes = FrootyAttack"
Bank8CodeEnds
end
