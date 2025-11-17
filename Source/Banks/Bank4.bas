          rem ChaosFight - Source/Banks/Bank4.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (16-23): Character16-23 (placeholders) + FallingAnimation routine

          bank 4

          rem Bank 4 dedicated to character art only - leave room for
          rem   animation frames
          rem Character sprite data for characters 16-23
#include "Source/Generated/Character16.bas"
#include "Source/Generated/Character17.bas"
#include "Source/Generated/Character18.bas"
#include "Source/Generated/Character19.bas"
#include "Source/Generated/Character20.bas"
#include "Source/Generated/Character21.bas"
#include "Source/Generated/Character22.bas"
#include "Source/Generated/Character23.bas"

          asm
Bank4DataEnds
end

          asm
          ; rem Character art lookup routines for Bank 4 (characters
          ; rem   16-23)
#include "Source/Routines/CharacterArtBank4.s"
Bank4CodeEnds
            ORG $3FE0 - bscode_length
            RORG $FFE0 - bscode_length
            include "Source/Common/BankSwitching.s"
end
