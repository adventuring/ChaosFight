          rem ChaosFight - Source/Banks/Bank4.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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
          ; rem Character art lookup routines for Bank 4 (characters
          ; rem   16-23)
#include "Source/Routines/CharacterArtBank4.s"
end

          rem batariBASIC auto-generates _length constants for data
          rem blocks
          rem Manual calculations removed - let batariBASIC handle them
          rem to avoid unresolved local label issues
