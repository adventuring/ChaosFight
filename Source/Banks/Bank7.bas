          rem ChaosFight - Source/Banks/Bank7.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Physics system (gravity, movement, special abilities, fall damage) + screen layout +
          rem   health bars
          bank 7
          rem Code segment
          asm
CharacterPhysicsTablesStart
end
#include "Source/Data/CharacterPhysicsTables.bas"
          asm
CharacterPhysicsTablesEnd
            echo "// Bank 7: ", [CharacterPhysicsTablesEnd - CharacterPhysicsTablesStart]d, " bytes = CharacterPhysicsTables"
Bank8DataEnds
end

          asm
ApplyMomentumAndRecoveryStart
end
#include "Source/Routines/ApplyMomentumAndRecovery.bas"
          asm
ApplyMomentumAndRecoveryEnd
            echo "// Bank 7: ", [ApplyMomentumAndRecoveryEnd - ApplyMomentumAndRecoveryStart]d, " bytes = ApplyMomentumAndRecovery"
InputHandleAllPlayersStart
end
#include "Source/Routines/InputHandleAllPlayers.bas"
          asm
InputHandleAllPlayersEnd
            echo "// Bank 7: ", [InputHandleAllPlayersEnd - InputHandleAllPlayersStart]d, " bytes = InputHandleAllPlayers"
HandleUpInputStart
end
#include "Source/Routines/HandleUpInput.bas"
          asm
HandleUpInputEnd
            echo "// Bank 7: ", [HandleUpInputEnd - HandleUpInputStart]d, " bytes = HandleUpInput"
ProcessUpActionStart
end
#include "Source/Routines/ProcessUpAction.bas"
          asm
ProcessUpActionEnd
            echo "// Bank 7: ", [ProcessUpActionEnd - ProcessUpActionStart]d, " bytes = ProcessUpAction"
InputHandleLeftPortPlayerFunctionStart
end
#include "Source/Routines/InputHandleLeftPortPlayerFunction.bas"
          asm
InputHandleLeftPortPlayerFunctionEnd
            echo "// Bank 7: ", [InputHandleLeftPortPlayerFunctionEnd - InputHandleLeftPortPlayerFunctionStart]d, " bytes = InputHandleLeftPortPlayerFunction"
InputHandleRightPortPlayerFunctionStart
end
#include "Source/Routines/InputHandleRightPortPlayerFunction.bas"
          asm
InputHandleRightPortPlayerFunctionEnd
            echo "// Bank 7: ", [InputHandleRightPortPlayerFunctionEnd - InputHandleRightPortPlayerFunctionStart]d, " bytes = InputHandleRightPortPlayerFunction"
UpdatePlayerMovementSingleStart
end
#include "Source/Routines/UpdatePlayerMovementSingle.bas"
          asm
UpdatePlayerMovementSingleEnd
            echo "// Bank 7: ", [UpdatePlayerMovementSingleEnd - UpdatePlayerMovementSingleStart]d, " bytes = UpdatePlayerMovementSingle"
UpdatePlayerMovementStart
end
#include "Source/Routines/UpdatePlayerMovement.bas"
          asm
UpdatePlayerMovementEnd
            echo "// Bank 7: ", [UpdatePlayerMovementEnd - UpdatePlayerMovementStart]d, " bytes = UpdatePlayerMovement"
FallDamageStart
end
#include "Source/Routines/FallDamage.bas"
          asm
FallDamageEnd
            echo "// Bank 7: ", [FallDamageEnd - FallDamageStart]d, " bytes = FallDamage"
ProcessJumpInputStart
end
#include "Source/Routines/ProcessJumpInput.bas"
          asm
ProcessJumpInputEnd
            echo "// Bank 7: ", [ProcessJumpInputEnd - ProcessJumpInputStart]d, " bytes = ProcessJumpInput"
          asm
DispatchCharacterJumpStart
end
#include "Source/Routines/DispatchCharacterJump.bas"
          asm
DispatchCharacterJumpEnd
            echo "// Bank 7: ", [DispatchCharacterJumpEnd - DispatchCharacterJumpStart]d, " bytes = DispatchCharacterJump"
MissileCollisionStart
end
#include "Source/Routines/MissileCollision.bas"
          asm
MissileCollisionEnd
            echo "// Bank 7: ", [MissileCollisionEnd - MissileCollisionStart]d, " bytes = MissileCollision"
          asm
BudgetedPlayerCollisionsStart
end
#include "Source/Routines/BudgetedPlayerCollisions.bas"
          asm
BudgetedPlayerCollisionsEnd
            echo "// Bank 7: ", [BudgetedPlayerCollisionsEnd - BudgetedPlayerCollisionsStart]d, " bytes = BudgetedPlayerCollisions"
          asm
FrootyAttackStart
end
#include "Source/Routines/FrootyAttack.bas"
          asm
FrootyAttackEnd
            echo "// Bank 7: ", [FrootyAttackEnd - FrootyAttackStart]d, " bytes = FrootyAttack"
Bank8CodeEnds
end
