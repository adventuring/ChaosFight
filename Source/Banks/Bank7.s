;;; ChaosFight - Source/Banks/Bank7.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Physics system (gravity, movement, special abilities, fall damage) + screen layout +
          ;; health bars

          ;; Set file offset for Bank 7 at the top of the file
          .offs (7 * $1000) - $f000  ; Adjust file offset for Bank 7
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

          ;; Code segment
CharacterPhysicsTablesStart:
.include "Source/Data/CharacterPhysicsTables.s"
CharacterPhysicsTablesEnd:
            .warn format("// Bank 7: %d bytes = CharacterPhysicsTables", [CharacterPhysicsTablesEnd - CharacterPhysicsTablesStart])
Bank7DataEnds:

ApplyMomentumAndRecoveryStart:
.include "Source/Routines/ApplyMomentumAndRecovery.s"
ApplyMomentumAndRecoveryEnd:
            .warn format("// Bank 7: %d bytes = ApplyMomentumAndRecovery", [ApplyMomentumAndRecoveryEnd - ApplyMomentumAndRecoveryStart])
InputHandleAllPlayersStart:
.include "Source/Routines/InputHandleAllPlayers.s"
InputHandleAllPlayersEnd:
            .warn format("// Bank 7: %d bytes = InputHandleAllPlayers", [InputHandleAllPlayersEnd - InputHandleAllPlayersStart])
HandleUpInputStart:
.include "Source/Routines/HandleUpInput.s"
HandleUpInputEnd:
            .warn format("// Bank 7: %d bytes = HandleUpInput", [HandleUpInputEnd - HandleUpInputStart])
ProcessUpActionStart:
.include "Source/Routines/ProcessUpAction.s"
ProcessUpActionEnd:
            .warn format("// Bank 7: %d bytes = ProcessUpAction", [ProcessUpActionEnd - ProcessUpActionStart])
InputHandleLeftPortPlayerFunctionStart:
.include "Source/Routines/InputHandleLeftPortPlayerFunction.s"
InputHandleLeftPortPlayerFunctionEnd:
            .warn format("// Bank 7: %d bytes = InputHandleLeftPortPlayerFunction", [InputHandleLeftPortPlayerFunctionEnd - InputHandleLeftPortPlayerFunctionStart])
InputHandleRightPortPlayerFunctionStart:
.include "Source/Routines/InputHandleRightPortPlayerFunction.s"
InputHandleRightPortPlayerFunctionEnd:
            .warn format("// Bank 7: %d bytes = InputHandleRightPortPlayerFunction", [InputHandleRightPortPlayerFunctionEnd - InputHandleRightPortPlayerFunctionStart])
UpdatePlayerMovementSingleStart:
.include "Source/Routines/UpdatePlayerMovementSingle.s"
UpdatePlayerMovementSingleEnd:
            .warn format("// Bank 7: %d bytes = UpdatePlayerMovementSingle", [UpdatePlayerMovementSingleEnd - UpdatePlayerMovementSingleStart])
UpdatePlayerMovementStart:
.include "Source/Routines/UpdatePlayerMovement.s"
UpdatePlayerMovementEnd:
            .warn format("// Bank 7: %d bytes = UpdatePlayerMovement", [UpdatePlayerMovementEnd - UpdatePlayerMovementStart])
FallDamageStart:
.include "Source/Routines/FallDamage.s"
FallDamageEnd:
            .warn format("// Bank 7: %d bytes = FallDamage", [FallDamageEnd - FallDamageStart])
ProcessJumpInputStart:
.include "Source/Routines/ProcessJumpInput.s"
DispatchCharacterJumpStart:
.include "Source/Routines/DispatchCharacterJump.s"
DispatchCharacterJumpEnd:
            .warn format("// Bank 7: %d bytes = DispatchCharacterJump", [DispatchCharacterJumpEnd - DispatchCharacterJumpStart])
MissileCollisionStart:
.include "Source/Routines/MissileCollision.s"
BudgetedPlayerCollisionsStart:
.include "Source/Routines/BudgetedPlayerCollisions.s"
FrootyAttackStart:
.include "Source/Routines/FrootyAttack.s"
FrootyAttackEnd:
            .warn format("// Bank 7: %d bytes = FrootyAttack", [FrootyAttackEnd - FrootyAttackStart])
Bank7CodeEnds:

          ;; Include BankSwitching.s in Bank 7
          ;; Wrap in .block to create namespace Bank7BS (avoids duplicate definitions)
Bank7BS: .block
          current_bank = 7
                    ;; Set file offset and CPU address for bankswitch code
          ;; File offset: (7 * $1000) + ($FFE0 - bscode_length - $F000) = $7FC8
          ;; CPU address: $FFE0 - bscode_length = $FFC8
          ;; Use .org to set file offset, then * = to set CPU address
          ;; Code appears at $ECA but should be at $FC8, difference is $FE
          ;; So adjust .org by $FE
          * = $FFE0 - bscode_length
          
          
          .include "Source/Common/BankSwitching.s"
          .bend
