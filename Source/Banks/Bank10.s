;;; ChaosFight - Source/Banks/Bank10.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Gameplay loop (init/main/collision resolution/animation)

          ;; Set file offset for Bank 10 at the top of the file
          .offs (10 * $1000) - $f000  ; Adjust file offset for Bank 10
          * = $F000
          .rept 256
          .byte $ff
          .endrept
Bank10DataEnds:

GameLoopInitStart:
.include "Source/Routines/GameLoopInit.s"
GameLoopMainStart:
.include "Source/Routines/GameLoopMain.s"
PlayerCollisionResolutionStart:
.include "Source/Routines/PlayerCollisionResolution.s"
PlayerCollisionResolutionEnd:
            .warn format("// Bank 10: %d bytes = PlayerCollisionResolution", [PlayerCollisionResolutionEnd - PlayerCollisionResolutionStart])
DisplayHealthStart:
.include "Source/Routines/DisplayHealth.s"
HealthBarSystemStart:
.include "Source/Routines/HealthBarSystem.s"
FallingAnimationStart:
.include "Source/Routines/FallingAnimation.s"
VblankHandlersStart:
.include "Source/Routines/VblankHandlers.s"
VblankHandlersEnd:
            .warn format("// Bank 10: %d bytes = VblankHandlers", [VblankHandlersEnd - VblankHandlersStart])
Bank10CodeEnds:

          ;; Include BankSwitching.s in Bank 10
          ;; Wrap in .block to create namespace Bank10BS (avoids duplicate definitions)
Bank10BS: .block
          current_bank = 10
          .include "Source/Common/BankSwitching.s"
          .bend
