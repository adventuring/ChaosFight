          rem ChaosFight - Source/Banks/Bank2.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (8-15): Frooty, Nefertem, NinjishGuy, PorkChop,
          rem   RadishGoblin, RoboTito, Ursulo, Shamone
          bank 2
          asm
Bank3DataStart
FrootyDataStart
end
#include "Source/Generated/Frooty.bas"
          asm
FrootyDataEnd
            echo "// Bank 2: ", [FrootyDataEnd - FrootyDataStart]d, " bytes = Frooty data"
NefertemDataStart
end
#include "Source/Generated/Nefertem.bas"
          asm
NefertemDataEnd
            echo "// Bank 2: ", [NefertemDataEnd - NefertemDataStart]d, " bytes = Nefertem data"
NinjishGuyDataStart
end
#include "Source/Generated/NinjishGuy.bas"
          asm
NinjishGuyDataEnd
            echo "// Bank 2: ", [NinjishGuyDataEnd - NinjishGuyDataStart]d, " bytes = NinjishGuy data"
PorkChopDataStart
end
#include "Source/Generated/PorkChop.bas"
          asm
PorkChopDataEnd
            echo "// Bank 2: ", [PorkChopDataEnd - PorkChopDataStart]d, " bytes = PorkChop data"
RadishGoblinDataStart
end
#include "Source/Generated/RadishGoblin.bas"
          asm
RadishGoblinDataEnd
            echo "// Bank 2: ", [RadishGoblinDataEnd - RadishGoblinDataStart]d, " bytes = RadishGoblin data"
RoboTitoDataStart
end
#include "Source/Generated/RoboTito.bas"
          asm
RoboTitoDataEnd
            echo "// Bank 2: ", [RoboTitoDataEnd - RoboTitoDataStart]d, " bytes = RoboTito data"
UrsuloDataStart
end
#include "Source/Generated/Ursulo.bas"
          asm
UrsuloDataEnd
            echo "// Bank 2: ", [UrsuloDataEnd - UrsuloDataStart]d, " bytes = Ursulo data"
ShamoneDataStart
end
#include "Source/Generated/Shamone.bas"
          asm
ShamoneDataEnd
            echo "// Bank 2: ", [ShamoneDataEnd - ShamoneDataStart]d, " bytes = Shamone data"
Bank3DataEnds
end

          asm
            ;; Character art lookup routines for Bank 2:(characters 8-15)
CharacterArtBank3Start
#include "Source/Routines/CharacterArtBank3.s"
CharacterArtBank3End
            echo "// Bank 2: ", [CharacterArtBank3End - CharacterArtBank3Start]d, " bytes = Character Art lookup routines"
Bank3CodeEnds
end
