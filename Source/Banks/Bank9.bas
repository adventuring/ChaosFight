          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Titlescreen System
          rem Graphics assets, titlescreen kernel, preambles, attract mode,
          rem   winner screen data, character data tables


          rem data must precede code
          rem all Title Screen modes must be in this bank
          asm
          include "vcs.h"
          include "macro.h"

          ORG $A000
          RORG $F000

#include "Source/Generated/Art.AtariAge.s"
#include "Source/Generated/Art.AtariAgeText.s"
#include "Source/Generated/Art.Author.s"
#include "Source/Generated/Art.ChaosFight.s"
#include "Source/TitleScreen/asm/titlescreen.s"
end

#include "Source/Routines/TitleScreenRender.bas"
#include "Source/Routines/CharacterSelectMain.bas"
