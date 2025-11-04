          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1

          rem Titlescreen kernel for 48×42 bitmaps on admin screens (×2 drawing style)
          rem Include generated bitmap art files (assembly format - wrap in asm blocks)
          rem Window values control which bitmaps display on each screen:
          rem   - Publisher (gameMode 0): AtariAge logo (48x2_1) + AtariAge text (48x2_2) (2 bitmaps)
          rem   - Author (gameMode 1): Interworldly (1 bitmap) - needs different slot
          rem   - Title (gameMode 2): ChaosFight (1 bitmap)
          rem Window values are compile-time constants set in bitmap .s files.
          rem Bitmap slot assignments:
          rem   - 48x2_1: AtariAge logo (Publisher)
          rem   - 48x2_2: AtariAgeText text (Publisher)
          rem   - 48x2_3: ChaosFight logo (Title)
          rem   - 48x2_4: Interworldly logo (Author)
          asm
          include "Source/Generated/Art.AtariAge.s"
          include "Source/Generated/Art.AtariAgeText.s"
          include "Source/Generated/Art.ChaosFight.s"
          include "Source/Generated/Art.Interworldly.s"
          
          rem Override window values AFTER includes for correct per-screen display
          rem Window values: 42 = visible, 0 = hidden
          rem Requirements per screen:
          rem   Publisher (gameMode 0): AtariAge logo (48x2_1)=42, AtariAgeText (48x2_2)=42, others=0 (2 bitmaps)
          rem   Author (gameMode 1): Interworldly (48x2_4)=42, others=0 (1 bitmap)
          rem   Title (gameMode 2): ChaosFight (48x2_3)=42, others=0 (1 bitmap)
          rem
          rem Set compile-time window values to 42 (maximum) for all bitmaps
          rem This ensures address calculations are always correct regardless of runtime window values
          rem Runtime window control is handled via titlescreenWindow1/2/3 variables set per screen
          rem If runtime window = 0, minikernel won't draw (Y register will be -1)
          bmp_48x2_1_window = 42  ; AtariAge logo: compile-time default (runtime controls visibility)
          bmp_48x2_2_window = 42  ; AtariAgeText: compile-time default (runtime controls visibility)
          bmp_48x2_3_window = 42  ; ChaosFight: compile-time default (runtime controls visibility)
          
          rem NOTE: Runtime window control implemented via titlescreenWindow1/2/3 variables
          rem Screen routines call SetPublisherWindowValues/SetAuthorWindowValues/SetTitleWindowValues
          rem to set runtime window values before drawing. Kernel checks runtime variables first,
          rem falling back to compile-time constants if runtime variables not defined.
          
          include "Source/Titlescreen/asm/titlescreen.s"
end

          goto bank13 ColdStart

