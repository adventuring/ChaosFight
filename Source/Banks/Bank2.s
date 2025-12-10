;;; ChaosFight - Source/Banks/Bank2.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;ASSET BANK: Character Art Assets (separate memory budget)
;;;Character sprites (8-15): Frooty, Nefertem, NinjishGuy, PorkChop,
          ;; RadishGoblin, RoboTito, Ursulo, Shamone

          ;; Set file offset for Bank 2 at the top of the file
          .offs (2 * $1000) - $f000  ; Adjust file offset for Bank 2
          * = $F000
          .rept 256
          .byte $ff
          .endrept
Bank2DataStart:
FrootyDataStart:
.include "Source/Generated/Frooty.s"
FrootyDataEnd:
            .warn format("// Bank 2: %d bytes = Frooty data", [FrootyDataEnd - FrootyDataStart])
NefertemDataStart:
.include "Source/Generated/Nefertem.s"
NefertemDataEnd:
            .warn format("// Bank 2: %d bytes = Nefertem data", [NefertemDataEnd - NefertemDataStart])
NinjishGuyDataStart:
.include "Source/Generated/NinjishGuy.s"
NinjishGuyDataEnd:
            .warn format("// Bank 2: %d bytes = NinjishGuy data", [NinjishGuyDataEnd - NinjishGuyDataStart])
PorkChopDataStart:
.include "Source/Generated/PorkChop.s"
PorkChopDataEnd:
            .warn format("// Bank 2: %d bytes = PorkChop data", [PorkChopDataEnd - PorkChopDataStart])
RadishGoblinDataStart:
.include "Source/Generated/RadishGoblin.s"
RadishGoblinDataEnd:
            .warn format("// Bank 2: %d bytes = RadishGoblin data", [RadishGoblinDataEnd - RadishGoblinDataStart])
RoboTitoDataStart:
.include "Source/Generated/RoboTito.s"
RoboTitoDataEnd:
            .warn format("// Bank 2: %d bytes = RoboTito data", [RoboTitoDataEnd - RoboTitoDataStart])
UrsuloDataStart:
.include "Source/Generated/Ursulo.s"
UrsuloDataEnd:
            .warn format("// Bank 2: %d bytes = Ursulo data", [UrsuloDataEnd - UrsuloDataStart])
ShamoneDataStart:
.include "Source/Generated/Shamone.s"
ShamoneDataEnd:
            .warn format("// Bank 2: %d bytes = Shamone data", [ShamoneDataEnd - ShamoneDataStart])
Bank2DataEnds:

            ;; Character art lookup routines for Bank 2:(characters 8-15)
CharacterArtBank3Start:
.include "Source/Routines/CharacterArtBank3.s"
CharacterArtBank3End:
            .warn format("// Bank 2: %d bytes = Character Art lookup routines", [CharacterArtBank3End - CharacterArtBank3Start])
Bank2CodeEnds:

          ;; Include BankSwitching.s in Bank 2
          ;; Wrap in .block to create namespace Bank2BS (avoids duplicate definitions)
Bank2BS: .block
          current_bank = 2
          .include "Source/Common/BankSwitching.s"
          .bend
