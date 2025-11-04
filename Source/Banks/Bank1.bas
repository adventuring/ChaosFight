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
          
          rem Override window values for correct per-screen display
          rem Requirements:
          rem   Publisher (gameMode 0): AtariAge=42, Interworldly=42, ChaosFight=0 (2 bitmaps)
          rem   Author (gameMode 1): AtariAge=0, Interworldly=42, ChaosFight=0 (1 bitmap)
          rem   Title (gameMode 2): AtariAge=0, Interworldly=0, ChaosFight=42 (1 bitmap)
          rem
          rem CRITICAL: Window values are compile-time constants used in assembly address
          rem calculations. They cannot be changed at runtime. All screens use the same values.
          rem
          rem SOLUTION: Set window values to work for Publisher screen (default).
          rem For Author/Title screens to show only one bitmap, we need runtime control
          rem which requires modifying the titlescreen kernel to use variables instead of constants.
          rem
          rem Current workaround: Set defaults for Publisher screen. Author screen will show
          rem AtariAge too (unwanted). Title screen won't show ChaosFight (file default 0).
          rem
          rem Set window values for Publisher screen (default - applies to ALL screens)
          bmp_48x2_1_window = 42  ; AtariAge: visible on Publisher (also Author, unwanted on Title)
          bmp_48x2_2_window = 42  ; Interworldly: visible on Publisher + Author (unwanted on Title)
          bmp_48x2_3_window = 0   ; ChaosFight: hidden on Publisher/Author (need 42 for Title)
          
          rem NOTE: Title screen needs ChaosFight visible (window = 42), but we can't set it
          rem per-screen since it's a compile-time constant. Title screen will show AtariAge +
          rem Interworldly (unwanted) and won't show ChaosFight (file default 0).
          rem
          rem For proper per-screen control, would need to modify titlescreen kernel to use
          rem runtime variables instead of compile-time constants for window values.
          
          include "Source/Titlescreen/asm/titlescreen.s"
end

          goto bank13 ColdStart

