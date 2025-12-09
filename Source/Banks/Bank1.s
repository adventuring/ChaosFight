;;; ChaosFight - Source/Banks/Bank1.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;ASSET BANK: Character Art Assets (separate memory budget)
;;;Character sprites (0-7): Bernie, Curler, DragonOfStorms, ZoeRyen,
          ;; FatTony, Megax, Harpy, KnightGuy + MissileCollision routine

          ;; Set file offset for Bank 1 at the top of the file
          .offs (1 * $1000) - $f000  ; Adjust file offset for Bank 1

          ;; Scram shadow (256 bytes of $FF) at file space $1000-$10FF (CPU space $F000-$F0FF)
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100
          .if * != $F100
              .error "Bank 1: not starting at $f100"
          .fi
Bank1DataStart:
BernieDataStart:
.include "Source/Generated/Bernie.s"
BernieDataEnd:
            .warn format("// Bank 1: %d bytes = Bernie data", [BernieDataEnd - BernieDataStart])
CurlerDataStart:
.include "Source/Generated/Curler.s"
CurlerDataEnd:
            .warn format("// Bank 1: %d bytes = Curler data", [CurlerDataEnd - CurlerDataStart])
DragonOfStormsDataStart:
.include "Source/Generated/DragonOfStorms.s"
DragonOfStormsDataEnd:
            .warn format("// Bank 1: %d bytes = Dragon Of Storms data", [DragonOfStormsDataEnd - DragonOfStormsDataStart])
ZoeRyenDataStart:
.include "Source/Generated/ZoeRyen.s"
ZoeRyenDataEnd:
            .warn format("// Bank 1: %d bytes = Zoe Ryen data", [ZoeRyenDataEnd - ZoeRyenDataStart])
FatTonyDataStart:
.include "Source/Generated/FatTony.s"
FatTonyDataEnd:
            .warn format("// Bank 1: %d bytes = Fat Tony data", [FatTonyDataEnd - FatTonyDataStart])
MegaxDataStart:
.include "Source/Generated/Megax.s"
MegaxDataEnd:
            .warn format("// Bank 1: %d bytes = Megax data", [MegaxDataEnd - MegaxDataStart])
HarpyDataStart:
.include "Source/Generated/Harpy.s"
HarpyDataEnd:
            .warn format("// Bank 1: %d bytes = Harpy data", [HarpyDataEnd - HarpyDataStart])
KnightGuyDataStart:
.include "Source/Generated/KnightGuy.s"
KnightGuyDataEnd:
            .warn format("// Bank 1: %d bytes = Knight Guy data", [KnightGuyDataEnd - KnightGuyDataStart])
Bank1DataEnds:

            ;; Character art lookup routines for Bank 1:(characters 0-7)
CharacterArtBank2Start:
            .include "Source/Routines/CharacterArtBank2.s"
CharacterArtBank2End:
            .warn format("// Bank 1: %d bytes = Character Art lookup routines", [CharacterArtBank2End - CharacterArtBank2Start])
Bank1CodeEnds:

          ;; CRITICAL: Jump to bank switching code location to avoid placing code in gap
          ;; Set CPU address before block to ensure no code is placed in the gap between
          ;; Bank1CodeEnds and the bank switching code
          * = $FFE0 - bscode_length
          .if * < Bank1CodeEnds
              .error format("Bank 1 overflow: Code ends at $%04x but bank switching starts at $%04x", Bank1CodeEnds, *)
          .fi

          ;; Include BankSwitching.s in Bank 1
          ;; Wrap in .block to create namespace Bank1BS (avoids duplicate definitions)
          ;; Note: * = is set above, so BankSwitching.s will be placed at the correct address
Bank1BS: .block
          current_bank = 1
          .include "Source/Common/BankSwitching.s"
          .bend
