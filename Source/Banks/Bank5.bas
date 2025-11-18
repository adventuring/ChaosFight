          rem ChaosFight - Source/Banks/Bank5.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (24-31): Character24-30, MethHound

          bank 5

          rem Bank 5 dedicated to character art only - leave room for
          rem   animation frames
          rem Character sprite data for characters 24-31
#include "Source/Generated/Character24.bas"
#include "Source/Generated/Character25.bas"
#include "Source/Generated/Character26.bas"
#include "Source/Generated/Character27.bas"
#include "Source/Generated/Character28.bas"
#include "Source/Generated/Character29.bas"
#include "Source/Generated/Character30.bas"
#include "Source/Generated/MethHound.bas"

          asm
Bank5DataEnds
end

          asm
          ;; Character art lookup routines for Bank 5 (characters 24-31)
#include "Source/Routines/CharacterArtBank5.s"
Bank5CodeEnds
end
