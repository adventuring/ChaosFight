          rem ChaosFight - Source/Platform/SECAM.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Licensed under Creative Commons Attribution-NonCommercial
          rem   4.0 International
          rem See LICENSE file for full terms

#define TV_SECAM

          rem Define assembly-level TV standard constants BEFORE including Preamble.bas
          rem so they’re available when MultiSpriteSuperChip.s uses ifconst _TV_SECAM
          asm
_TV_SECAM SET 1
end

#include "Source/Common/Preamble.bas"

          rem TVStandard is automatically set by batariBASIC based on ’set tv pal’
          rem batariBASIC lacks SECAM timing keyword; use PAL timing with SECAM defines
          rem Note: TVStandard will be 2 (PAL) but _TV_SECAM define distinguishes SECAM mode
          set tv pal
#include "Source/Banks/Banks.bas"
