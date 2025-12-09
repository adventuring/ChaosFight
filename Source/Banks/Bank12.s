;;; ChaosFight - Source/Banks/Bank12.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Input system (movement, player input, guard effects)

          ;; Set file offset for Bank 12 at the top of the file
          .offs (12 * $1000) - $f000  ; Adjust file offset for Bank 12
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

Bank12DataEnds:

CheckPlayerCollisionStart:
.include "Source/Routines/CheckPlayerCollision.s"
CheckPlayerCollisionEnd:
            .warn format("// Bank 12: %d bytes = CheckPlayerCollision", [CheckPlayerCollisionEnd - CheckPlayerCollisionStart])
ControllerDetectionStart:
.include "Source/Routines/ControllerDetection.s"
ControllerDetectionEnd:
            .warn format("// Bank 12: %d bytes = ControllerDetection", [ControllerDetectionEnd - ControllerDetectionStart])
GetPlayerAnimationStateFunctionStart:
.include "Source/Routines/GetPlayerAnimationStateFunction.s"
GetPlayerAnimationStateFunctionEnd:
            .warn format("// Bank 12: %d bytes = GetPlayerAnimationStateFunction", [GetPlayerAnimationStateFunctionEnd - GetPlayerAnimationStateFunctionStart])
PlayerPhysicsGravityStart:
.include "Source/Routines/PlayerPhysicsGravity.s"
PlayerPhysicsGravityEnd:
            .warn format("// Bank 12: %d bytes = PlayerPhysicsGravity", [PlayerPhysicsGravityEnd - PlayerPhysicsGravityStart])
InitializeMovementSystemStart:
.include "Source/Routines/InitializeMovementSystem.s"
InitializeMovementSystemEnd:
            .warn format("// Bank 12: %d bytes = InitializeMovementSystem", [InitializeMovementSystemEnd - InitializeMovementSystemStart])
ConstrainToScreenStart:
.include "Source/Routines/ConstrainToScreen.s"
ConstrainToScreenEnd:
            .warn format("// Bank 12: %d bytes = ConstrainToScreen", [ConstrainToScreenEnd - ConstrainToScreenStart])
AddVelocitySubpixelYStart:
.include "Source/Routines/AddVelocitySubpixelY.s"
AddVelocitySubpixelYEnd:
            .warn format("// Bank 12: %d bytes = AddVelocitySubpixelY", [AddVelocitySubpixelYEnd - AddVelocitySubpixelYStart])
ProcessStandardMovementStart:
.include "Source/Routines/ProcessStandardMovement.s"
ProcessStandardMovementEnd:
            .warn format("// Bank 12: %d bytes = ProcessStandardMovement", [ProcessStandardMovementEnd - ProcessStandardMovementStart])
ConsoleHandlingStart:
.include "Source/Routines/ConsoleHandling.s"
ConsoleHandlingEnd:
            .warn format("// Bank 12: %d bytes = ConsoleHandling", [ConsoleHandlingEnd - ConsoleHandlingStart])
TriggerEliminationEffectsStart:
.include "Source/Routines/TriggerEliminationEffects.s"
TriggerEliminationEffectsEnd:
            .warn format("// Bank 12: %d bytes = TriggerEliminationEffects", [TriggerEliminationEffectsEnd - TriggerEliminationEffectsStart])
IsPlayerEliminatedStart:
.include "Source/Routines/IsPlayerEliminated.s"
IsPlayerEliminatedEnd:
            .warn format("// Bank 12: %d bytes = IsPlayerEliminated", [IsPlayerEliminatedEnd - IsPlayerEliminatedStart])
IsPlayerAliveStart:
.include "Source/Routines/IsPlayerAlive.s"
IsPlayerAliveEnd:
            .warn format("// Bank 12: %d bytes = IsPlayerAlive", [IsPlayerAliveEnd - IsPlayerAliveStart])
CharacterDownHandlersStart:
.include "Source/Routines/CharacterDownHandlers.s"
CharacterDownHandlersEnd:
            .warn format("// Bank 12: %d bytes = CharacterDownHandlers", [CharacterDownHandlersEnd - CharacterDownHandlersStart])
Bank12CodeEnds:

          ;; Include BankSwitching.s in Bank 12
          ;; Wrap in .block to create namespace Bank12BS (avoids duplicate definitions)
Bank12BS: .block
          current_bank = 12
                    ;; Set file offset and CPU address for bankswitch code
          ;; File offset: (12 * $1000) + ($FFE0 - bscode_length - $F000) = $12FC8
          ;; CPU address: $FFE0 - bscode_length = $FFC8
          ;; Use .org to set file offset, then * = to set CPU address
          ;; Code appears at $ECA but should be at $FC8, difference is $FE
          ;; So adjust .org by $FE
          * = $FFE0 - bscode_length
          
          
          .include "Source/Common/BankSwitching.s"
          .bend
