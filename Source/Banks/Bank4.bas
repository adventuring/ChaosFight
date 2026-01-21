          rem ChaosFight - Source/Banks/Bank4.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (24-31): Character24-30, MethHound
          bank 4
          asm
Bank5DataStart
Character24DataStart
end
#include "Source/Generated/Character24.bas"
          asm
Character24DataEnd
            echo "// Bank 4: ", [Character24DataEnd - Character24DataStart]d, " bytes = Character24 data"
Character25DataStart
end
#include "Source/Generated/Character25.bas"
          asm
Character25DataEnd
            echo "// Bank 4: ", [Character25DataEnd - Character25DataStart]d, " bytes = Character25 data"
Character26DataStart
end
#include "Source/Generated/Character26.bas"
          asm
Character26DataEnd
            echo "// Bank 4: ", [Character26DataEnd - Character26DataStart]d, " bytes = Character26 data"
Character27DataStart
end
#include "Source/Generated/Character27.bas"
          asm
Character27DataEnd
            echo "// Bank 4: ", [Character27DataEnd - Character27DataStart]d, " bytes = Character27 data"
Character28DataStart
end
#include "Source/Generated/Character28.bas"
          asm
Character28DataEnd
            echo "// Bank 4: ", [Character28DataEnd - Character28DataStart]d, " bytes = Character28 data"
Character29DataStart
end
#include "Source/Generated/Character29.bas"
          asm
Character29DataEnd
            echo "// Bank 4: ", [Character29DataEnd - Character29DataStart]d, " bytes = Character29 data"
Character30DataStart
end
#include "Source/Generated/Character30.bas"
          asm
Character30DataEnd
            echo "// Bank 4: ", [Character30DataEnd - Character30DataStart]d, " bytes = Character30 data"
MethHoundDataStart
end
#include "Source/Generated/MethHound.bas"
          asm
MethHoundDataEnd
            echo "// Bank 4: ", [MethHoundDataEnd - MethHoundDataStart]d, " bytes = MethHound data"
Bank5DataEnds
end

          asm
            ;; Character art lookup routines for Bank 4:(characters 24-31)
CharacterArtBank5Start
#include "Source/Routines/CharacterArtBank5.s"
CharacterArtBank5End
            echo "// Bank 4: ", [CharacterArtBank5End - CharacterArtBank5Start]d, " bytes = Character Art lookup routines"
Bank5CodeEnds
end
