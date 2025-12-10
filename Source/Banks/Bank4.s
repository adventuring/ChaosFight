;;; ChaosFight - Source/Banks/Bank4.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;ASSET BANK: Character Art Assets (separate memory budget)
;;;Character sprites (24-31): Character24-30, MethHound

          ;; Set file offset for Bank 4 at the top of the file
          .offs (4 * $1000) - $f000  ; Adjust file offset for Bank 4
          * = $F000
          .rept 256
          .byte $ff
          .endrept
Bank4DataStart:
Character24DataStart:
.include "Source/Generated/Character24.s"
Character24DataEnd:
            .warn format("// Bank 4: %d bytes = Character24 data", [Character24DataEnd - Character24DataStart])
Character25DataStart:
.include "Source/Generated/Character25.s"
Character25DataEnd:
            .warn format("// Bank 4: %d bytes = Character25 data", [Character25DataEnd - Character25DataStart])
Character26DataStart:
.include "Source/Generated/Character26.s"
Character26DataEnd:
            .warn format("// Bank 4: %d bytes = Character26 data", [Character26DataEnd - Character26DataStart])
Character27DataStart:
.include "Source/Generated/Character27.s"
Character27DataEnd:
            .warn format("// Bank 4: %d bytes = Character27 data", [Character27DataEnd - Character27DataStart])
Character28DataStart:
.include "Source/Generated/Character28.s"
Character28DataEnd:
            .warn format("// Bank 4: %d bytes = Character28 data", [Character28DataEnd - Character28DataStart])
Character29DataStart:
.include "Source/Generated/Character29.s"
Character29DataEnd:
            .warn format("// Bank 4: %d bytes = Character29 data", [Character29DataEnd - Character29DataStart])
Character30DataStart:
.include "Source/Generated/Character30.s"
Character30DataEnd:
            .warn format("// Bank 4: %d bytes = Character30 data", [Character30DataEnd - Character30DataStart])
MethHoundDataStart:
.include "Source/Generated/MethHound.s"
MethHoundDataEnd:
            .warn format("// Bank 4: %d bytes = MethHound data", [MethHoundDataEnd - MethHoundDataStart])
Bank4DataEnds:

            ;; Character art lookup routines for Bank 4:(characters 24-31)
CharacterArtBank5Start:
.include "Source/Routines/CharacterArtBank5.s"
CharacterArtBank5End:
            .warn format("// Bank 4: %d bytes = Character Art lookup routines", [CharacterArtBank5End - CharacterArtBank5Start])
Bank4CodeEnds:

          ;; Include BankSwitching.s in Bank 4
          ;; Wrap in .block to create namespace Bank4BS (avoids duplicate definitions)
Bank4BS: .block
          current_bank = 4
          .include "Source/Common/BankSwitching.s"
          .bend
