          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

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

          rem These are still Title Screen routines and must be here too
#include "Source/Routines/BeginPublisherPrelude.bas"
#include "Source/Routines/PublisherPrelude.bas"
#include "Source/Routines/BeginAuthorPrelude.bas"
#include "Source/Routines/AuthorPrelude.bas"
#include "Source/Routines/BeginTitleScreen.bas"
#include "Source/Routines/TitleScreenMain.bas"
#include "Source/Routines/TitleScreenRender.bas"
#include "Source/Routines/TitleCharacterParade.bas"

          rem these may be relocated anywhere, if needed.
#include "Source/Routines/BeginAttractMode.bas"
#include "Source/Routines/AttractMode.bas"
