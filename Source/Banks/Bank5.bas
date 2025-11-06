          rem ChaosFight - Source/Banks/Bank5.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 5
          
          rem Bank 5 dedicated to character art only - leave room for
          rem   animation frames
          rem Character sprite data for characters 24-31
          
#include "Source/Generated/Character24.bas"
          asm
Character24Frames_end:
Character24FrameMap_end:
Character24Frames_length = Character24Frames_end - Character24Frames
Character24FrameMap_length = Character24FrameMap_end - Character24FrameMap
end

#include "Source/Generated/Character25.bas"
          asm
Character25Frames_end:
Character25FrameMap_end:
Character25Frames_length = Character25Frames_end - Character25Frames
Character25FrameMap_length = Character25FrameMap_end - Character25FrameMap
end

#include "Source/Generated/Character26.bas"
          asm
Character26Frames_end:
Character26FrameMap_end:
Character26Frames_length = Character26Frames_end - Character26Frames
Character26FrameMap_length = Character26FrameMap_end - Character26FrameMap
end

#include "Source/Generated/Character27.bas"
          asm
Character27Frames_end:
Character27FrameMap_end:
Character27Frames_length = Character27Frames_end - Character27Frames
Character27FrameMap_length = Character27FrameMap_end - Character27FrameMap
end

#include "Source/Generated/Character28.bas"
          asm
Character28Frames_end:
Character28FrameMap_end:
Character28Frames_length = Character28Frames_end - Character28Frames
Character28FrameMap_length = Character28FrameMap_end - Character28FrameMap
end

#include "Source/Generated/Character29.bas"
          asm
Character29Frames_end:
Character29FrameMap_end:
Character29Frames_length = Character29Frames_end - Character29Frames
Character29FrameMap_length = Character29FrameMap_end - Character29FrameMap
end

#include "Source/Generated/Character30.bas"
          asm
Character30Frames_end:
Character30FrameMap_end:
Character30Frames_length = Character30Frames_end - Character30Frames
Character30FrameMap_length = Character30FrameMap_end - Character30FrameMap
end

#include "Source/Generated/MethHound.bas"
          
          rem Character art lookup routines for Bank 5 (characters
          rem   24-31)
          asm
#include "Source/Routines/CharacterArtBank5.s"
end
