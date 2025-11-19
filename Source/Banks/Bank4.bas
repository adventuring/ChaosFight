          rem ChaosFight - Source/Banks/Bank4.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (16-23)

          bank 4

          asm
Bank4DataStart
Character16DataStart
end
#include "Source/Generated/Character16.bas"
          asm
Character16DataEnd
            echo "// Bank 4: ", [Character16DataEnd - Character16DataStart]d, " bytes = Character16 data"
Character17DataStart
end
#include "Source/Generated/Character17.bas"
          asm
Character17DataEnd
            echo "// Bank 4: ", [Character17DataEnd - Character17DataStart]d, " bytes = Character17 data"
Character18DataStart
end
#include "Source/Generated/Character18.bas"
          asm
Character18DataEnd
            echo "// Bank 4: ", [Character18DataEnd - Character18DataStart]d, " bytes = Character18 data"
Character19DataStart
end
#include "Source/Generated/Character19.bas"
          asm
Character19DataEnd
            echo "// Bank 4: ", [Character19DataEnd - Character19DataStart]d, " bytes = Character19 data"
Character20DataStart
end
#include "Source/Generated/Character20.bas"
          asm
Character20DataEnd
            echo "// Bank 4: ", [Character20DataEnd - Character20DataStart]d, " bytes = Character20 data"
Character21DataStart
end
#include "Source/Generated/Character21.bas"
          asm
Character21DataEnd
            echo "// Bank 4: ", [Character21DataEnd - Character21DataStart]d, " bytes = Character21 data"
Character22DataStart
end
#include "Source/Generated/Character22.bas"
          asm
Character22DataEnd
            echo "// Bank 4: ", [Character22DataEnd - Character22DataStart]d, " bytes = Character22 data"
Character23DataStart
end
#include "Source/Generated/Character23.bas"
          asm
Character23DataEnd
            echo "// Bank 4: ", [Character23DataEnd - Character23DataStart]d, " bytes = Character23 data"
Bank4DataEnds
end

          asm
            ;; Character art lookup routines for Bank 4 (characters
            ;;   16-23)
CharacterArtBank4Start
#include "Source/Routines/CharacterArtBank4.s"
CharacterArtBank4End
            echo "// Bank 4: ", [CharacterArtBank4End - CharacterArtBank4Start]d, " bytes = Character Art lookup routines"
Bank4CodeEnds
end
