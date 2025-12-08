          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (0-7): Bernie, Curler, DragonOfStorms, ZoeRyen,
          rem   FatTony, Megax, Harpy, KnightGuy + MissileCollision routine
          bank 1
          asm
            ORG $1100
            RORG $F100
end
          asm
            if . != $F100
              echo "Bank 1:not starting at $f100"
              err
            endif
Bank2DataStart
BernieDataStart
end
#include "Source/Generated/Bernie.bas"
          asm
BernieDataEnd
            echo "// Bank 1: ", [BernieDataEnd - BernieDataStart]d, " bytes = Bernie data"
CurlerDataStart
end
#include "Source/Generated/Curler.bas"
          asm
CurlerDataEnd
            echo "// Bank 1: ", [CurlerDataEnd - CurlerDataStart]d, " bytes = Curler data"
DragonOfStormsDataStart
end
#include "Source/Generated/DragonOfStorms.bas"
          asm
DragonOfStormsDataEnd
            echo "// Bank 1: ", [DragonOfStormsDataEnd - DragonOfStormsDataStart]d, " bytes = Dragon Of Storms data"
ZoeRyenDataStart
end
#include "Source/Generated/ZoeRyen.bas"
          asm
ZoeRyenDataEnd
            echo "// Bank 1: ", [ZoeRyenDataEnd - ZoeRyenDataStart]d, " bytes = Zoe Ryen data"
FatTonyDataStart
end
#include "Source/Generated/FatTony.bas"
          asm
FatTonyDataEnd
            echo "// Bank 1: ", [FatTonyDataEnd - FatTonyDataStart]d, " bytes = Fat Tony data"
MegaxDataStart
end
#include "Source/Generated/Megax.bas"
          asm
MegaxDataEnd
            echo "// Bank 1: ", [MegaxDataEnd - MegaxDataStart]d, " bytes = Megax data"
HarpyDataStart
end
#include "Source/Generated/Harpy.bas"
          asm
HarpyDataEnd
            echo "// Bank 1: ", [HarpyDataEnd - HarpyDataStart]d, " bytes = Harpy data"
KnightGuyDataStart
end
#include "Source/Generated/KnightGuy.bas"
          asm
KnightGuyDataEnd
            echo "// Bank 1: ", [KnightGuyDataEnd - KnightGuyDataStart]d, " bytes = Knight Guy data"
Bank2DataEnds
end

          asm
            ;; Character art lookup routines for Bank 1:(characters 0-7)
CharacterArtBank2Start
            #include "Source/Routines/CharacterArtBank2.s"
CharacterArtBank2End
            echo "// Bank 1: ", [CharacterArtBank2End - CharacterArtBank2Start]d, " bytes = Character Art lookup routines"
Bank2CodeEnds
end
