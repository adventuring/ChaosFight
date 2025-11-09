          rem ChaosFight - Source/Banks/Bank2.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

          bank 2

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
          ;; Character art lookup routines for Bank 2 (characters 0-7)
#include "Source/Routines/CharacterArtBank2.s"
end

          rem RoboTito stretch missile collision detection
          rem Moved from Bank 9 for space optimization
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"
