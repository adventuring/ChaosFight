          rem ChaosFight - Source/Banks/Bank2.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (0-7): Bernie, Curler, DragonOfStorms, ZoeRyen,
          rem   FatTony, Megax, Harpy, KnightGuy + MissileCollision routine

          bank 2

          asm
            ;; Global aliases for BankSwitching.s local labels
            ;; These must be defined in Bank 2 (after Bank 1’s BankSwitching.s has been processed)
            ;; because the local labels (.BS_return, .BS_jsr) are only visible after Bank 1 is complete.
            ;; Each bank has its own .BS_return and .BS_jsr local labels, but these global aliases
            ;; allow external code (like the RETURN macro) to reference the current bank’s entry points.
            BS_return = .BS_return
            BS_jsr = .BS_jsr
end

          asm
            ORG $1100
            RORG $F100
end
          asm
            if . != $F100
              echo "Bank 2 not starting at $f100"
              err
            endif
Bank2DataStart
BernieDataStart
end
#include "Source/Generated/Bernie.bas"
          asm
BernieDataEnd
            echo "// Bank 2: ", [BernieDataEnd - BernieDataStart]d, " bytes = Bernie data"
CurlerDataStart
end
#include "Source/Generated/Curler.bas"
          asm
CurlerDataEnd
            echo "// Bank 2: ", [CurlerDataEnd - CurlerDataStart]d, " bytes = Curler data"
DragonOfStormsDataStart
end
#include "Source/Generated/DragonOfStorms.bas"
          asm
DragonOfStormsDataEnd
            echo "// Bank 2: ", [DragonOfStormsDataEnd - DragonOfStormsDataStart]d, " bytes = Dragon Of Storms data"
ZoeRyenDataStart
end
#include "Source/Generated/ZoeRyen.bas"
          asm
ZoeRyenDataEnd
            echo "// Bank 2: ", [ZoeRyenDataEnd - ZoeRyenDataStart]d, " bytes = Zoe Ryen data"
FatTonyDataStart
end
#include "Source/Generated/FatTony.bas"
          asm
FatTonyDataEnd
            echo "// Bank 2: ", [FatTonyDataEnd - FatTonyDataStart]d, " bytes = Fat Tony data"
MegaxDataStart
end
#include "Source/Generated/Megax.bas"
          asm
MegaxDataEnd
            echo "// Bank 2: ", [MegaxDataEnd - MegaxDataStart]d, " bytes = Megax data"
HarpyDataStart
end
#include "Source/Generated/Harpy.bas"
          asm
HarpyDataEnd
            echo "// Bank 2: ", [HarpyDataEnd - HarpyDataStart]d, " bytes = Harpy data"
KnightGuyDataStart
end
#include "Source/Generated/KnightGuy.bas"
          asm
KnightGuyDataEnd
            echo "// Bank 2: ", [KnightGuyDataEnd - KnightGuyDataStart]d, " bytes = Knight Guy data"
Bank2DataEnds
end

          asm
            ;; Character art lookup routines for Bank 2 (characters 0-7)
CharacterArtBank2Start
            #include "Source/Routines/CharacterArtBank2.s"
CharacterArtBank2End
            echo "// Bank 2: ", [CharacterArtBank2End - CharacterArtBank2Start]d, " bytes = Character Art lookup routines"
Bank2CodeEnds
end
