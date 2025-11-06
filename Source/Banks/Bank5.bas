          rem ChaosFight - Source/Banks/Bank5.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 5
          
          rem Bank 5 dedicated to character art only - leave room for
          rem   animation frames
          rem Character sprite data for characters 24-31
          
          rem Forward declarations for _length constants to avoid DASM
          rem   unresolved symbol errors
          rem batariBASIC auto-generates these but calculates them incorrectly
          rem   due to label ordering in bank-switched code
          rem Formula: CharacterXXFrames_length = n = x × 16 (x >= 1)
          rem   where x is the number of frames (each frame = 16 bytes)
          rem These constants are not used, but DASM requires them to be defined
          asm
          Character24Frames_length = 1 * 16
          Character24FrameMap_length = 128
          Character25Frames_length = 1 * 16
          Character25FrameMap_length = 128
          Character26Frames_length = 1 * 16
          Character26FrameMap_length = 128
          Character27Frames_length = 1 * 16
          Character27FrameMap_length = 128
          Character28Frames_length = 1 * 16
          Character28FrameMap_length = 128
          Character29Frames_length = 1 * 16
          Character29FrameMap_length = 128
          Character30Frames_length = 1 * 16
          Character30FrameMap_length = 128
          end
          
#include "Source/Generated/Character24.bas"
#include "Source/Generated/Character25.bas"
#include "Source/Generated/Character26.bas"
#include "Source/Generated/Character27.bas"
#include "Source/Generated/Character28.bas"
#include "Source/Generated/Character29.bas"
#include "Source/Generated/Character30.bas"
#include "Source/Generated/MethHound.bas"
          
          rem Character art lookup routines for Bank 5 (characters
          rem   24-31)
          asm
#include "Source/Routines/CharacterArtBank5.s"
end
