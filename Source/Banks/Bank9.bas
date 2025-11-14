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
#include "Source/Generated/Art.AtariAge.s"
#include "Source/Generated/Art.AtariAgeText.s"
#include "Source/Generated/Art.ChaosFight.s"
#include "Source/Generated/Art.Author.s"
          ; Colors must be included here, right after bitmap data,
          ;   before titlescreen.s includes other files that advance past $f500
#include "Source/TitleScreen/titlescreen_colors.s"
end

          asm
Bank9DataEnds
end

          asm
#include "Source/TitleScreen/asm/titlescreen.s"
end
#include "Source/Routines/TitleScreenRender.bas"
#include "Source/Routines/CharacterSelectMain.bas"
          rem PublisherPrelude moved to Bank 14 for ROM balance

          asm
Bank9CodeEnds

 ; Generate Bank 9's bankswitching code and Bank 10's ORG immediately after Bank 9 ends
 ; This must come before any Bank 10 content to prevent "Origin Reverse-indexed" errors
 ; Order: Bank 9 ORG -> Bank 9 bankswitching code -> Bank 10 ORG
 ifconst bscode_length
  if Bank9CodeEnds <= ($FFE0 - bscode_length)
   ; Set position for Bank 9's bankswitching code
   ORG $FFE0-bscode_length
   RORG $FFE0-bscode_length
   
   ; Generate start_bank8 label (Bank 9 uses 0-based index: bank - 1 = 8)
   ; The compiler generates start_bank%d where %d = bank - 1
start_bank8
   include "Source/Common/BankSwitching.s"
   
   ; Now set position for Bank 10's bankswitching code
   ORG $9FE0-bscode_length
   RORG $FFE0-bscode_length
  else
   echo "ERROR: Bank 9 overflowed - cannot generate bankswitching code ORG for Bank 10"
  endif
 endif
end
