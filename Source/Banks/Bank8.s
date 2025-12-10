;;; ChaosFight - Source/Banks/Bank8.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;SPECIAL PURPOSE BANK: Titlescreen System
;;;Graphics assets, titlescreen kernel, preambles, attract mode,
          ;; winner screen data, character data tables

          ;; Set file offset for Bank 8 at the top of the file
          .offs (8 * $1000) - $f000  ; Adjust file offset for Bank 8
          * = $F000
          .rept 256
          .byte $ff
          .endrept
          ;; data must precede code
          ;; all Title Screen modes must be in this bank
          ;; Bitmap data is packed at page-aligned addresses:
          ;; Art.AtariAge.s at $f100 (bmp_48x2_1)
          ;; Art.AtariAgeText.s at $f200 (bmp_48x2_2)
          ;; Art.ChaosFight.s at $f300 (bmp_48x2_3)
          ;; Art.Author.s at $f400 (bmp_48x2_4)
          ;; Colors, PF1, PF2, and background are at $f500 (in titlescreen_colors.s)
Bank8DataStart:
ArtAtariAgeStart:
.include "Source/Generated/Art.AtariAge.s"
ArtAtariAgeEnd:
            .warn format("// Bank 8: %d bytes = Art.AtariAge", [ArtAtariAgeEnd - ArtAtariAgeStart])
ArtAtariAgeTextStart:
.include "Source/Generated/Art.AtariAgeText.s"
ArtAtariAgeTextEnd:
            .warn format("// Bank 8: %d bytes = Art.AtariAgeText", [ArtAtariAgeTextEnd - ArtAtariAgeTextStart])
ArtChaosFightStart:
.include "Source/Generated/Art.ChaosFight.s"
ArtChaosFightEnd:
            .warn format("// Bank 8: %d bytes = Art.ChaosFight", [ArtChaosFightEnd - ArtChaosFightStart])
ArtAuthorStart:
.include "Source/Generated/Art.Author.s"
ArtAuthorEnd:
            .warn format("// Bank 8: %d bytes = Art.Author", [ArtAuthorEnd - ArtAuthorStart])
            ; Colors must be included here, right after bitmap data,
            ;   before titlescreen.s includes other files that advance past $f500
TitlescreenColorsStart:
.include "Source/TitleScreen/titlescreen_colors.s"
TitlescreenColorsEnd:
            .warn format("// Bank 8: %d bytes = titlescreen_colors", [TitlescreenColorsEnd - TitlescreenColorsStart])
            ; Optional bitmap index offsets (all are 0) - data must be in data segment
bmp_48x2_1_index_value:
bmp_48x2_2_index_value:
bmp_48x2_3_index_value:
bmp_48x2_4_index_value:
          .byte 0
Bank8DataEnds:

TitlescreenAsmStart:
.include "Source/TitleScreen/asm/titlescreen.s"
TitlescreenAsmEnd:
            .warn format("// Bank 8: %d bytes = titlescreen.s", [TitlescreenAsmEnd - TitlescreenAsmStart])
TitleScreenRenderStart:
.include "Source/Routines/TitleScreenRender.s"
TitleScreenRenderEnd:
            .warn format("// Bank 8: %d bytes = TitleScreenRender", [TitleScreenRenderEnd - TitleScreenRenderStart])
CharacterSelectMainStart:
.include "Source/Routines/CharacterSelectMain.s"
CharacterSelectMainEnd:
            .warn format("// Bank 8: %d bytes = CharacterSelectMain", [CharacterSelectMainEnd - CharacterSelectMainStart])
SpriteLoaderCharacterArtStart:
.include "Source/Routines/SpriteLoaderCharacterArt.s"
SpriteLoaderCharacterArtEnd:
            .warn format("// Bank 8: %d bytes = SpriteLoaderCharacterArt", [SpriteLoaderCharacterArtEnd - SpriteLoaderCharacterArtStart])
Bank8CodeEnds:

          ;; Include BankSwitching.s in Bank 8
          ;; Wrap in .block to create namespace Bank8BS (avoids duplicate definitions)
Bank8BS: .block
          current_bank = 8

          .include "Source/Common/BankSwitching.s"
          .bend
