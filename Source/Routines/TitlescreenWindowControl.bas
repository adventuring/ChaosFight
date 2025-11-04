          rem ChaosFight - Source/Routines/TitlescreenWindowControl.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem TITLESCREEN WINDOW CONTROL
          rem =================================================================
          rem Screen-specific window value initialization for titlescreen kernel.
          rem Window values control which bitmaps display on each screen.
          rem
          rem Requirements:
          rem   Publisher (gameMode 0): AtariAge logo + AtariAge text (2 bitmaps)
          rem   Author (gameMode 1): Interworldly only (1 bitmap) - needs different slot
          rem   Title (gameMode 2): ChaosFight only (1 bitmap)
          rem
          rem NOTE: Window values are compile-time constants in the titlescreen kernel.
          rem These routines set window values via assembly if the kernel supports
          rem runtime modification. Otherwise, window values must be set at compile time.
          rem =================================================================
          
          rem Initialize window values for Publisher screen
          rem Shows: AtariAge logo (bmp_48x2_1) + AtariAge text (bmp_48x2_2)
          rem Hides: ChaosFight (bmp_48x2_3)
SetPublisherWindowValues
          rem Set runtime window values for Publisher screen (2 bitmaps visible)
          let titlescreenWindow1 = 42  ; AtariAge logo visible
          let titlescreenWindow2 = 42  ; AtariAgeText visible
          let titlescreenWindow3 = 0   ; ChaosFight hidden
          return
          
          rem Initialize window values for Author screen
          rem Shows: Interworldly (uses slot 3, same as ChaosFight - switched at runtime)
          rem Hides: AtariAge logo (bmp_48x2_1), AtariAgeText (bmp_48x2_2)
          rem NOTE: Interworldly and ChaosFight both use slot 3 - bitmap data is switched via includes
SetAuthorWindowValues
          rem Set runtime window values for Author screen (Interworldly visible in slot 3)
          let titlescreenWindow1 = 0   ; AtariAge logo hidden
          let titlescreenWindow2 = 0   ; AtariAgeText hidden
          let titlescreenWindow3 = 42  ; Interworldly visible (same slot as ChaosFight, different bitmap)
          return
          
          rem Initialize window values for Title screen
          rem Shows: ChaosFight (bmp_48x2_3) only
          rem Hides: AtariAge logo (bmp_48x2_1), AtariAgeText (bmp_48x2_2)
SetTitleWindowValues
          rem Set runtime window values for Title screen (1 bitmap visible)
          let titlescreenWindow1 = 0   ; AtariAge logo hidden
          let titlescreenWindow2 = 0   ; AtariAgeText hidden
          let titlescreenWindow3 = 42  ; ChaosFight visible
          return

