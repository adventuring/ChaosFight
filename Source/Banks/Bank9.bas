          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Titlescreen System
          rem Graphics assets, titlescreen kernel, preambles, attract mode,
          rem   winner screen data, character data tables

          bank 9

          rem data must precede code
          rem all Title Screen modes must be in this bank
          rem Bitmap data is packed at page-aligned addresses:
          rem   Art.AtariAge.s at $f100 (bmp_48x2_1)
          rem   Art.AtariAgeText.s at $f200 (bmp_48x2_2)
          rem   Art.ChaosFight.s at $f300 (bmp_48x2_3)
          rem   Art.Author.s at $f400 (bmp_48x2_4)
          rem Colors, PF1, PF2, and background are at $f500 (in titlescreen_colors.s)
          asm
Bank9DataStart
ArtAtariAgeStart
#include "Source/Generated/Art.AtariAge.s"
ArtAtariAgeEnd
            echo "// Bank 9: ", [ArtAtariAgeEnd - ArtAtariAgeStart]d, " bytes = Art.AtariAge"
ArtAtariAgeTextStart
#include "Source/Generated/Art.AtariAgeText.s"
ArtAtariAgeTextEnd
            echo "// Bank 9: ", [ArtAtariAgeTextEnd - ArtAtariAgeTextStart]d, " bytes = Art.AtariAgeText"
ArtChaosFightStart
#include "Source/Generated/Art.ChaosFight.s"
ArtChaosFightEnd
            echo "// Bank 9: ", [ArtChaosFightEnd - ArtChaosFightStart]d, " bytes = Art.ChaosFight"
ArtAuthorStart
#include "Source/Generated/Art.Author.s"
ArtAuthorEnd
            echo "// Bank 9: ", [ArtAuthorEnd - ArtAuthorStart]d, " bytes = Art.Author"
            ; Colors must be included here, right after bitmap data,
            ;   before titlescreen.s includes other files that advance past $f500
TitlescreenColorsStart
#include "Source/TitleScreen/titlescreen_colors.s"
TitlescreenColorsEnd
            echo "// Bank 9: ", [TitlescreenColorsEnd - TitlescreenColorsStart]d, " bytes = titlescreen_colors"
Bank9DataEnds
end

          asm
TitlescreenAsmStart
#include "Source/TitleScreen/asm/titlescreen.s"
TitlescreenAsmEnd
            echo "// Bank 9: ", [TitlescreenAsmEnd - TitlescreenAsmStart]d, " bytes = titlescreen.s"
TitleScreenRenderStart
end
#include "Source/Routines/TitleScreenRender.bas"
          asm
TitleScreenRenderEnd
            echo "// Bank 9: ", [TitleScreenRenderEnd - TitleScreenRenderStart]d, " bytes = TitleScreenRender"
CharacterSelectMainStart
end
#include "Source/Routines/CharacterSelectMain.bas"
          asm
CharacterSelectMainEnd
            echo "// Bank 9: ", [CharacterSelectMainEnd - CharacterSelectMainStart]d, " bytes = CharacterSelectMain"
Bank9CodeEnds
end

