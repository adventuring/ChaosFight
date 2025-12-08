;;; ChaosFight - Source/Banks/Bank9.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Sprite rendering (character art loader, player rendering, elimination) +
          ;; character attacks system and falling animation controller

          ;; Set file offset for Bank 9 at the top of the file
          .offs (9 * $1000) - $f000  ; Adjust file offset for Bank 9

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
          * = $FFE0 - bscode_length  ;;; CPU address: Bankswitch code starts here, ends just before $FFE0
          ;; Note: .offs was set at top of file, no need to reset it
          .include "Source/Common/BankSwitching.s"
          .bend
