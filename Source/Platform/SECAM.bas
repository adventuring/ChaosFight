          rem ChaosFight - Source/Platform/SECAM.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Licensed under Creative Commons Attribution-NonCommercial
          rem   4.0 International
          rem See LICENSE file for full terms

#define TV_SECAM
          const TVStandard = SECAM
          rem batariBASIC lacks SECAM timing keyword; use PAL timing with SECAM defines
          set tv pal

#include "Source/Common/Preamble.bas"
#include "Source/Banks/Banks.bas"
