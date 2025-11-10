          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
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

#include "Source/Routines/TitleScreenRender.bas"
#include "Source/Routines/TitleScreenMain.bas"
#include "Source/Routines/BeginTitleScreen.bas"
#include "Source/Routines/TitleCharacterParade.bas"
#include "Source/Routines/FontRendering.bas"
#include "Source/Data/WinnerScreen.bas"
#include "Source/Data/CharacterThemeSongIndices.bas"
#include "Source/Data/CharacterDataTables.bas"
#include "Source/Data/CharacterPhysicsTables.bas"
#include "Source/Routines/FallDamage.bas"

rem Define missing draw_bmp_48x2_X for titlescreen minikernels
asm
draw_bmp_48x2_X
	; Generic 48x2 bitmap display kernel
	; This is called by the individual minikernels
	ldx aux2
	beq draw_bmp_48x2_X_done

draw_bmp_48x2_X_loop
	lda (aux5),y
	sta wsync
	sta GRP0
	lda (aux4),y
	sta COLUP0
	lda (aux3),y
	sta COLUP1
	dey
	dex
	bne draw_bmp_48x2_X_loop

draw_bmp_48x2_X_done
	rts
end
