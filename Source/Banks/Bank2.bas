          rem ChaosFight - Source/Banks/Bank2.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (0-7): Bernie, Curler, DragonOfStorms, ZoeRyen,
          rem   FatTony, Megax, Harpy, KnightGuy + MissileCollision routine

          bank 2
          asm
            if . != $F100
              err
            endif
end

          rem Character sprite data for characters 0-7
          rem Bank 2 dedicated to character art only - leave room for
          rem   animation frames
#include "Source/Generated/Bernie.bas"
#include "Source/Generated/Curler.bas"
#include "Source/Generated/DragonOfStorms.bas"
#include "Source/Generated/ZoeRyen.bas"
#include "Source/Generated/FatTony.bas"
#include "Source/Generated/Megax.bas"
#include "Source/Generated/Harpy.bas"
#include "Source/Generated/KnightGuy.bas"

          asm
Bank2DataEnds
end

          asm
          ;; Character art lookup routines for Bank 2 (characters 0-7)
#include "Source/Routines/CharacterArtBank2.s"
Bank2CodeEnds
end
