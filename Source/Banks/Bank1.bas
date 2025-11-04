          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1

          rem Titlescreen kernel for 48×42 bitmaps on admin screens (×2 drawing style)
          rem Include generated bitmap art files (assembly format - wrap in asm blocks)
          rem Window values control which bitmaps display on each screen:
          rem   - Publisher (gameMode 0): AtariAge + Interworldly (2 bitmaps)
          rem   - Author (gameMode 1): Interworldly (1 bitmap)
          rem   - Title (gameMode 2): ChaosFight (1 bitmap)
          rem Window values are compile-time constants set in bitmap .s files.
          rem Default values:
          rem   - Art.AtariAge.s: bmp_48x2_1_window = 42 (Publisher screen)
          rem   - Art.Interworldly.s: bmp_48x2_2_window = 42 (Publisher + Author screens)
          rem   - Art.ChaosFight.s: bmp_48x2_3_window = 0 (hidden by default, overridden per screen)
          asm
          include "Source/Generated/Art.AtariAge.s"
          include "Source/Generated/Art.Interworldly.s"
          include "Source/Generated/Art.ChaosFight.s"
          
          rem Override window values AFTER includes for correct per-screen display
          rem Window values: 42 = visible, 0 = hidden
          rem CRITICAL: These are compile-time constants - cannot change at runtime
          rem Requirements per screen:
          rem   Publisher (gameMode 0): AtariAge=42, Interworldly=42, ChaosFight=0 (2 bitmaps)
          rem   Author (gameMode 1): AtariAge=0, Interworldly=42, ChaosFight=0 (1 bitmap)
          rem   Title (gameMode 2): AtariAge=0, Interworldly=0, ChaosFight=42 (1 bitmap)
          rem
          rem SOLUTION: Since window values are compile-time constants used in assembly
          rem calculations, we cannot change them at runtime. We set defaults that work
          rem for Publisher screen. For Author/Title screens to show only one bitmap,
          rem we need screen-specific window overrides via conditional compilation or
          rem separate builds. For now, we set to Publisher defaults and document limitation.
          
          rem Set window values for Publisher screen (default)
          rem These values apply to ALL screens - compile-time constant limitation
          bmp_48x2_1_window = 42  ; AtariAge: visible on Publisher
          bmp_48x2_2_window = 42  ; Interworldly: visible on Publisher + Author
          bmp_48x2_3_window = 0   ; ChaosFight: hidden on Publisher/Author, visible on Title
          
          rem NOTE: These window values are compile-time constants and apply to ALL screens.
          rem Author screen will also show AtariAge (can't hide without conditional compilation).
          rem Title screen won't show ChaosFight (file default is 0, we need 42 but can't set per-screen).
          rem For proper per-screen control, would need:
          rem   1. Conditional compilation with screen-specific constants
          rem   2. Separate builds for each screen
          rem   3. Kernel modification to use variables instead of constants
          
          include "Source/Titlescreen/asm/titlescreen.s"
end

          goto bank13 ColdStart

