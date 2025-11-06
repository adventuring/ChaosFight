          rem ChaosFight - Source/Banks/Bank4.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 4
          
          rem Bank 4 dedicated to character art only - leave room for
          rem   animation frames
          rem Character sprite data for characters 16-23
          
          rem Forward declarations for _length constants to avoid DASM
          rem   unresolved symbol errors
          rem batariBASIC auto-generates these but calculates them incorrectly
          rem   due to label ordering in bank-switched code
          rem These constants are not used, but DASM requires them to be defined
          asm
          Character16Frames_length = 16
          Character16FrameMap_length = 128
          Character17Frames_length = 16
          Character17FrameMap_length = 128
          Character18Frames_length = 16
          Character18FrameMap_length = 128
          Character19Frames_length = 16
          Character19FrameMap_length = 128
          Character20Frames_length = 16
          Character20FrameMap_length = 128
          Character21Frames_length = 16
          Character21FrameMap_length = 128
          Character22Frames_length = 16
          Character22FrameMap_length = 128
          Character23Frames_length = 16
          Character23FrameMap_length = 128
          end
          
#include "Source/Generated/Character16.bas"
#include "Source/Generated/Character17.bas"
#include "Source/Generated/Character18.bas"
#include "Source/Generated/Character19.bas"
#include "Source/Generated/Character20.bas"
#include "Source/Generated/Character21.bas"
#include "Source/Generated/Character22.bas"
#include "Source/Generated/Character23.bas"
          
          rem Character art lookup routines for Bank 4 (characters
          rem   16-23)
          asm
#include "Source/Routines/CharacterArtBank4.s"
end
