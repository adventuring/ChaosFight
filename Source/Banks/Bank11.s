;;; ChaosFight - Source/Banks/Bank11.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Character data system (definitions, cycles, fall damage) +
          ;; Titlescreen graphics and kernel

          ;; Set file offset for Bank 11 at the top of the file
          .offs (11 * $1000) - $f000  ; Adjust file offset for Bank 11
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

          ;; Character data tables
.include "Source/Data/CharacterThemeSongIndices.s"

Bank11DataEnds:

.include "Source/Routines/UpdateAttackCooldowns.s"
Bank11AfterUpdateAttackCooldowns:
.include "Source/Routines/HandleFlyingCharacterMovement.s"
Bank11AfterHandleFlyingCharacterMovement:
.include "Source/Routines/HandleGuardInput.s"
Bank11AfterHandleGuardInput:
.include "Source/Routines/StandardGuard.s"
Bank11AfterStandardGuard:
.include "Source/Routines/RadishGoblinMovement.s"
Bank11AfterRadishGoblinMovement:
.include "Source/Routines/CharacterControlsJump.s"
Bank11AfterCharacterControlsJump:
.include "Source/Routines/AnimationSystem.s"
Bank11AfterAnimationSystem:
.include "Source/Routines/DeactivatePlayerMissiles.s"
Bank11AfterDeactivatePlayerMissiles:

Bank11CodeEnds:
           .warn format("// Bank 11: %d bytes = UpdateAttackCooldowns", [Bank11AfterUpdateAttackCooldowns - Bank11DataEnds])
           .warn format("// Bank 11: %d bytes = HandleFlyingCharacterMovement", [Bank11AfterHandleFlyingCharacterMovement - Bank11AfterUpdateAttackCooldowns])
           .warn format("// Bank 11: %d bytes = HandleGuardInput", [Bank11AfterHandleGuardInput - Bank11AfterHandleFlyingCharacterMovement])
           .warn format("// Bank 11: %d bytes = StandardGuard", [Bank11AfterStandardGuard - Bank11AfterHandleGuardInput])
           .warn format("// Bank 11: %d bytes = RadishGoblinMovement", [Bank11AfterRadishGoblinMovement - Bank11AfterStandardGuard])
           .warn format("// Bank 11: %d bytes = CharacterControlsJump", [Bank11AfterCharacterControlsJump - Bank11AfterRadishGoblinMovement])
           .warn format("// Bank 11: %d bytes = AnimationSystem", [Bank11AfterAnimationSystem - Bank11AfterCharacterControlsJump])
           .warn format("// Bank 11: %d bytes = DeactivatePlayerMissiles", [Bank11AfterDeactivatePlayerMissiles - Bank11AfterAnimationSystem])

          ;; Include BankSwitching.s in Bank 11
          ;; Wrap in .block to create namespace Bank11BS (avoids duplicate definitions)
Bank11BS: .block
          current_bank = 11
                    ;; Set file offset and CPU address for bankswitch code
          ;; File offset: (11 * $1000) + ($FFE0 - bscode_length - $F000) = $11FC8
          ;; CPU address: $FFE0 - bscode_length = $FFC8
          ;; Use .org to set file offset, then * = to set CPU address
          ;; Code appears at $ECA but should be at $FC8, difference is $FE
          ;; So adjust .org by $FE
          * = $FFE0 - bscode_length
          
          
          .include "Source/Common/BankSwitching.s"
          .bend
