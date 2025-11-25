          rem ChaosFight - Source/Platform/SECAM.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Licensed under Creative Commons Attribution-NonCommercial
          rem   4.0 International
          rem See LICENSE file for full terms

#define TV_SECAM

#include "Source/Common/Preamble.bas"

          rem TVStandard is automatically set by batariBASIC based on "set tv pal"
          rem batariBASIC lacks SECAM timing keyword; use PAL timing with SECAM defines
          rem Note: TVStandard will be 2 (PAL) but _TV_SECAM define distinguishes SECAM mode
          set tv pal
#include "Source/Banks/Banks.bas"
