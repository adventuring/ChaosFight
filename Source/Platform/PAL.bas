          rem ChaosFight - Source/Platform/PAL.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Licensed under Creative Commons Attribution-NonCommercial
          rem   4.0 International
          rem See LICENSE file for full terms

#define TV_PAL

          rem Define assembly-level TV standard constants BEFORE including Preamble.bas
          rem so they’re available when MultiSpriteSuperChip.s uses ifconst _TV_PAL
          asm
_TV_PAL   SET 1
end

#include "Source/Common/Preamble.bas"

          rem TVStandard is automatically set by batariBASIC based on ’set tv pal’
          set tv pal
#include "Source/Banks/Banks.bas"

