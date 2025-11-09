          rem ChaosFight - Source/Banks/Bank5.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

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

#include "Source/Routines/PlayerInput.bas"

          asm
          ; rem Character art lookup routines for Bank 5 (characters
          ; rem   24-31)
#include "Source/Routines/CharacterArtBank5.s"
end


          rem batariBASIC auto-generates _length constants for data
          rem blocks
          rem Manual calculations removed - let batariBASIC handle them
          rem to avoid unresolved local label issues
