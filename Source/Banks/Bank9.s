;;; ChaosFight - Source/Banks/Bank9.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Sprite rendering (character art loader, player rendering, elimination) +
          ;; character attacks system and falling animation controller

          ;; Set file offset for Bank 9 at the top of the file
          .offs (9 * $1000) - $f000  ; Adjust file offset for Bank 9
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

Bank9DataEnds:

PlayerBoundaryCollisionsStart:
.include "Source/Routines/PlayerBoundaryCollisions.s"
PlayerBoundaryCollisionsEnd:
            .warn format("// Bank 9: %d bytes = PlayerBoundaryCollisions", [PlayerBoundaryCollisionsEnd - PlayerBoundaryCollisionsStart])
PlayerPlayfieldCollisionsStart:
.include "Source/Routines/PlayerPlayfieldCollisions.s"
CharacterAttacksDispatchStart:
.include "Source/Routines/CharacterAttacksDispatch.s"
ProcessAttackInputStart:
.include "Source/Routines/ProcessAttackInput.s"
BernieAttackStart:
.include "Source/Routines/BernieAttack.s"
HarpyAttackStart:
.include "Source/Routines/HarpyAttack.s"
UrsuloAttackStart:
.include "Source/Routines/UrsuloAttack.s"
ShamoneAttackStart:
.include "Source/Routines/ShamoneAttack.s"
ShamoneAttackEnd:
            .warn format("// Bank 9: %d bytes = ShamoneAttack", [ShamoneAttackEnd - ShamoneAttackStart])
RoboTitoJumpStart:
.include "Source/Routines/RoboTitoJump.s"
CheckRoboTitoStretchMissileCollisionsStart:
.include "Source/Routines/CheckRoboTitoStretchMissileCollisions.s"
ScreenLayoutStart:
.include "Source/Routines/SetGameScreenLayout.s"
ScreenLayoutEnd:
            .warn format("// Bank 9: %d bytes = ScreenLayout", [ScreenLayoutEnd - ScreenLayoutStart])

Bank9CodeEnds:

          ;; Include BankSwitching.s in Bank 9
          ;; Wrap in .block to create namespace Bank9BS (avoids duplicate definitions)
Bank9BS: .block
          current_bank = 9
                    ;; Set file offset and CPU address for bankswitch code
          ;; File offset: (9 * $1000) + ($FFE0 - bscode_length - $F000) = $9FC8
          ;; CPU address: $FFE0 - bscode_length = $FFC8
          ;; Use .org to set file offset, then * = to set CPU address
          ;; Code appears at $ECA but should be at $FC8, difference is $FE
          ;; So adjust .org by $FE
          * = $FFE0 - bscode_length
          
          
          .include "Source/Common/BankSwitching.s"
          .bend
