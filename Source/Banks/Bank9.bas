          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Titlescreen System
          rem Graphics assets, titlescreen kernel, preambles, attract mode,
          rem   winner screen data, character data tables

          bank 9

          rem data must precede code
          rem all Title Screen modes must be in this bank
          asm
#include "Source/Generated/Art.AtariAge.s"
#include "Source/Generated/Art.AtariAgeText.s"
#include "Source/Generated/Art.Author.s"
#include "Source/Generated/Art.ChaosFight.s"
#include "Source/TitleScreen/asm/titlescreen.s"
end

          rem Core Title Screen assets (graphics data, kernel, and render function)
#include "Source/Routines/TitleScreenRender.bas"

#include "Source/Routines/BeginTitleScreen.bas"
#include "Source/Routines/TitleScreenMain.bas"
#include "Source/Routines/TitleCharacterParade.bas"

          rem these may be relocated anywhere, if needed.
