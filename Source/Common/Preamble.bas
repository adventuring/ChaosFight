          rem ChaosFight - Source/Common/Preamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          asm
; CRITICAL: Define bscode_length before any code that uses it
; Match actual 64kSC bankswitch stub size (see Tools/batariBASIC/includes/banksw.asm ;size=42)
; $2A = 42 bytes, so bankswitch code runs right up to $FFE0 before EFSC header
            ifnconst bscode_length
bscode_length EQU $2A
            endif
end

#include "Source/Common/AssemblyConfig.bas"

#include "Source/Common/Colors.h"
#include "Source/Common/Constants.bas"
#include "Source/Common/Enums.bas"
#include "Source/Common/Macros.bas"
#include "Source/Common/Variables.bas"

          asm
#include "Source/Common/MultiSpriteSuperChip.s"
end

          asm
#include "Source/Common/ScoreTable.s"
end