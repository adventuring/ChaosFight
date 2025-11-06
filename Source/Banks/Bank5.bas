          rem ChaosFight - Source/Banks/Bank5.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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
          
          rem Character art lookup routines for Bank 5 (characters
          rem   24-31)
          asm
#include "Source/Routines/CharacterArtBank5.s"
end

          rem Define _length constants using label subtraction after data
          rem   blocks are included
          rem batariBASIC auto-generates these but calculates them incorrectly
          rem   due to label ordering in bank-switched code
          rem Formula: CharacterXXFrames_length = end_label - start_label
          rem   where end_label is .skipL0XXXX and start_label is CharacterXXFrames
          asm
          Character24Frames_length = .skipL01656 - Character24Frames
          Character24FrameMap_length = .skipL01657 - Character24FrameMap
          Character25Frames_length = .skipL01662 - Character25Frames
          Character25FrameMap_length = .skipL01663 - Character25FrameMap
          Character26Frames_length = .skipL01668 - Character26Frames
          Character26FrameMap_length = .skipL01669 - Character26FrameMap
          Character27Frames_length = .skipL01674 - Character27Frames
          Character27FrameMap_length = .skipL01675 - Character27FrameMap
          Character28Frames_length = .skipL01680 - Character28Frames
          Character28FrameMap_length = .skipL01681 - Character28FrameMap
          Character29Frames_length = .skipL01686 - Character29Frames
          Character29FrameMap_length = .skipL01687 - Character29FrameMap
          Character30Frames_length = .skipL01692 - Character30Frames
          Character30FrameMap_length = .skipL01693 - Character30FrameMap
          end
