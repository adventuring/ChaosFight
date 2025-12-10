;;; ChaosFight - Source/Banks/Bank3.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;ASSET BANK: Character Art Assets (separate memory budget)
;;;Character sprites (16-23)

          ;; Set file offset for Bank 3 at the top of the file
          .offs (3 * $1000) - $f000  ; Adjust file offset for Bank 3
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

Bank3DataStart:
Character16DataStart:
.include "Source/Generated/Character16.s"
Character16DataEnd:
            .warn format("// Bank 3: %d bytes = Character16 data", [Character16DataEnd - Character16DataStart])
Character17DataStart:
.include "Source/Generated/Character17.s"
Character17DataEnd:
            .warn format("// Bank 3: %d bytes = Character17 data", [Character17DataEnd - Character17DataStart])
Character18DataStart:
.include "Source/Generated/Character18.s"
Character18DataEnd:
            .warn format("// Bank 3: %d bytes = Character18 data", [Character18DataEnd - Character18DataStart])
Character19DataStart:
.include "Source/Generated/Character19.s"
Character19DataEnd:
            .warn format("// Bank 3: %d bytes = Character19 data", [Character19DataEnd - Character19DataStart])
Character20DataStart:
.include "Source/Generated/Character20.s"
Character20DataEnd:
            .warn format("// Bank 3: %d bytes = Character20 data", [Character20DataEnd - Character20DataStart])
Character21DataStart:
.include "Source/Generated/Character21.s"
Character21DataEnd:
            .warn format("// Bank 3: %d bytes = Character21 data", [Character21DataEnd - Character21DataStart])
Character22DataStart:
.include "Source/Generated/Character22.s"
Character22DataEnd:
            .warn format("// Bank 3: %d bytes = Character22 data", [Character22DataEnd - Character22DataStart])
Character23DataStart:
.include "Source/Generated/Character23.s"
Character23DataEnd:
            .warn format("// Bank 3: %d bytes = Character23 data", [Character23DataEnd - Character23DataStart])
Bank3DataEnds:

            ;; Character art lookup routines for Bank 3:(characters
            ;;   16-23)
CharacterArtBank4Start:
.include "Source/Routines/CharacterArtBank4.s"
CharacterArtBank4End:
            .warn format("// Bank 3: %d bytes = Character Art lookup routines", [CharacterArtBank4End - CharacterArtBank4Start])
Bank3CodeEnds:

          ;; Include BankSwitching.s in Bank 3
          ;; Wrap in .block to create namespace Bank3BS (avoids duplicate definitions)
          ;; Note: BankSwitching.s now sets * = $FFE0 - bscode_length internally
Bank3BS: .block
          current_bank = 3
          .include "Source/Common/BankSwitching.s"
          .bend
