;;; Chaos Fight - Source/TitleScreen/titlescreen_colors.s
;;; This is a generated file, do not edit.
;;; Color tables, PF1, PF2, and background for all titlescreen bitmaps
;;; Combined at $f4f5 (after bitmap data at $f100-$f400)
;;; Must end at $f5a9 to allow titledrawscreen at f5a9 (180 bytes)

   rorg $f4f5

;;; Include color tables, PF1, PF2, and background for all titlescreen bitmaps
          include "Source/Generated/Art.AtariAge.colors.s"
          include "Source/Generated/Art.AtariAgeText.colors.s"
          include "Source/Generated/Art.ChaosFight.colors.s"
          include "Source/Generated/Art.Author.colors.s"
