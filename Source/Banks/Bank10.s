;;; ChaosFight - Source/Banks/Bank10.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Gameplay loop (init/main/collision resolution/animation)

          ;; Set file offset for Bank 10 at the top of the file
          .offs (10 * $1000) - $f000  ; Adjust file offset for Bank 10
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

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
                    ;; Set file offset and CPU address for bankswitch code
          ;; File offset: (10 * $1000) + ($FFE0 - bscode_length - $F000) = $10FC8
          ;; CPU address: $FFE0 - bscode_length = $FFC8
          ;; Use .org to set file offset, then * = to set CPU address
          ;; Code appears at $ECA but should be at $FC8, difference is $FE
          ;; So adjust .org by $FE
          * = $FFE0 - bscode_length
          
          
          .include "Source/Common/BankSwitching.s"
          .bend
