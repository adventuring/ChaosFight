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
          
          rem Character art lookup routines for Bank 4 (characters
          rem   16-23)
          asm
#include "Routines/CharacterArtBank4.s"
end

          rem Define _length constants using label subtraction after data
          rem   blocks are included
          rem batariBASIC auto-generates these but calculates them incorrectly
          rem   due to label ordering in bank-switched code
          rem Formula: CharacterXXFrames_length = end_label - start_label
          rem   where end_label is .skipL0XXXX and start_label is CharacterXXFrames
          asm
Character16Frames_length = .skipL01599 - Character16Frames
Character16FrameMap_length = .skipL01600 - Character16FrameMap
Character17Frames_length = .skipL01605 - Character17Frames
Character17FrameMap_length = .skipL01606 - Character17FrameMap
Character18Frames_length = .skipL01611 - Character18Frames
Character18FrameMap_length = .skipL01612 - Character18FrameMap
Character19Frames_length = .skipL01617 - Character19Frames
Character19FrameMap_length = .skipL01618 - Character19FrameMap
Character20Frames_length = .skipL01623 - Character20Frames
Character20FrameMap_length = .skipL01624 - Character20FrameMap
Character21Frames_length = .skipL01629 - Character21Frames
Character21FrameMap_length = .skipL01630 - Character21FrameMap
Character22Frames_length = .skipL01635 - Character22Frames
Character22FrameMap_length = .skipL01636 - Character22FrameMap
Character23Frames_length = .skipL01641 - Character23Frames
Character23FrameMap_length = .skipL01642 - Character23FrameMap
end
