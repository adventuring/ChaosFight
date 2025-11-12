          rem ChaosFight - Source/Banks/Bank3.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem ASSET BANK: Character Art Assets (separate memory budget)
          rem Character sprites (8-15): Frooty, Nefertem, NinjishGuy, PorkChop,
          rem   RadishGoblin, RoboTito, Ursulo, Shamone + PlayerRendering routine


          rem Character sprite data for characters 8-15
          rem Bank 3 dedicated to character art only - leave room for
          rem   animation frames
#include "Source/Generated/Frooty.bas"
#include "Source/Generated/Nefertem.bas"
#include "Source/Generated/NinjishGuy.bas"
#include "Source/Generated/PorkChop.bas"
#include "Source/Generated/RadishGoblin.bas"
#include "Source/Generated/RoboTito.bas"
#include "Source/Generated/Ursulo.bas"
#include "Source/Generated/Shamone.bas"

          asm
          ; rem Character art lookup routines for Bank 3 (characters 8-15
          ; rem   and 24-31)
#include "Source/Routines/CharacterArtBank3.s"
end
