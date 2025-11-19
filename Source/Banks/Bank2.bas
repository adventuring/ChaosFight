          rem ChaosFight - Source/Banks/Bank2.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (0-7): Bernie, Curler, DragonOfStorms, ZoeRyen,
          rem   FatTony, Megax, Harpy, KnightGuy + MissileCollision routine

          bank 2

          asm
            echo " Bank 2: Start data ", [* - 1]
            if * != $F100
                err
            endif
end

          rem Character sprite data for characters 0-7
          rem Bank 2 dedicated to character art only - leave room for
          rem   animation frames
          asm
            echo " Bank 2: Begin Bernie data ", [* - 1]
end
#include "Source/Generated/Bernie.bas"
          asm
            echo " Bank 2: Begin Curler data ", [* - 1]
end
#include "Source/Generated/Curler.bas"
          asm
            echo " Bank 2: Begin Dragon Of Storms data ", [* - 1]
end
#include "Source/Generated/DragonOfStorms.bas"
          asm
            echo " Bank 2: Begin Zoe Ryen data ", [* - 1]
end
#include "Source/Generated/ZoeRyen.bas"
          asm
            echo " Bank 2: Begin Fat Tony data ", [* - 1]
end
#include "Source/Generated/FatTony.bas"
          asm
            echo " Bank 2: Begin Megax data ", [* - 1]
end
#include "Source/Generated/Megax.bas"
          asm
            echo " Bank 2: Begin Harpy data ", [* - 1]
end
#include "Source/Generated/Harpy.bas"
          asm
            echo " Bank 2: Begin Knight Guy data ", [* - 1]
end
#include "Source/Generated/KnightGuy.bas"
          asm
            echo " Bank 2: End data ", [* - 1]
end

          asm
Bank2DataEnds

            ;; Character art lookup routines for Bank 2 (characters 0-7)
            echo " Bank 2: Begin Character Art lookup routines ", [* - 1]
#include "Source/Routines/CharacterArtBank2.s"
            echo " Bank 2: End Character Art lookup routines ", [* - 1]
Bank2CodeEnds
end
