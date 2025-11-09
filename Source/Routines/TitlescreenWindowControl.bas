SetPublisherWindowValues
          rem
          rem ChaosFight - Source/Routines/TitlescreenWindowControl.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem Titlescreen Window Control
          rem
          rem Screen-specific window value initialization for
          rem   titlescreen kernel.
          rem Window values control which bitmaps display on each
          rem   screen.
          rem Requirements:
          rem
          rem Publisher (gameMode 0): AtariAge logo + AtariAge text (2
          rem   bitmaps)
          rem Author (gameMode 1): Interworldly only (1 bitmap) - needs
          rem   different slot
          rem   Title (gameMode 2): ChaosFight only (1 bitmap)
          rem NOTE: Window values are compile-time constants in the
          rem   titlescreen kernel.
          rem These routines set window values via assembly if the
          rem   kernel supports
          rem runtime modification. Otherwise, window values must be set
          rem   at compile time.
          rem Initialize window values for Publisher screen
          rem Shows: AtariAge logo (bmp_48x2_1) + AtariAge text
          rem   (bmp_48x2_2)
          rem Hides: ChaosFight (bmp_48x2_3), BRP (bmp_48x2_4)
          rem Set runtime window values for Publisher screen (2 bitmaps
          rem   visible)
          rem
          rem Input: None
          rem
          rem Output: titlescreenWindow1-4 set for Publisher screen
          rem
          rem Mutates: titlescreenWindow1, titlescreenWindow2,
          rem titlescreenWindow3, titlescreenWindow4
          rem
          rem Called Routines: None
          rem Constraints: None
          let titlescreenWindow1 = 42  ; AtariAge logo visible
          let titlescreenWindow2 = 42  ; AtariAgeText visible
          let titlescreenWindow3 = 0   ; ChaosFight hidden
          let titlescreenWindow4 = 0   ; BRP hidden
          return
          
SetAuthorWindowValues
          rem Initialize window values for Author screen
          rem Shows: BRP (slot 4)
          rem Hides: AtariAge logo (bmp_48x2_1), AtariAgeText
          rem   (bmp_48x2_2), ChaosFight (bmp_48x2_3)
          rem Set runtime window values for Author screen (BRP
          rem   visible in slot 4)
          rem
          rem Input: None
          rem
          rem Output: titlescreenWindow1-4 set for Author screen
          rem
          rem Mutates: titlescreenWindow1, titlescreenWindow2,
          rem titlescreenWindow3, titlescreenWindow4
          rem
          rem Called Routines: None
          rem Constraints: None
          let titlescreenWindow1 = 0   ; AtariAge logo hidden
          let titlescreenWindow2 = 0   ; AtariAgeText hidden
          let titlescreenWindow3 = 0   ; ChaosFight hidden
          let titlescreenWindow4 = 42  ; BRP visible
          return
          
SetTitleWindowValues
          rem Initialize window values for Title screen
          rem Shows: ChaosFight (bmp_48x2_3) only
          rem Hides: AtariAge logo (bmp_48x2_1), AtariAgeText
          rem   (bmp_48x2_2), BRP (bmp_48x2_4)
          rem Set runtime window values for Title screen (1 bitmap
          rem   visible)
          rem
          rem Input: None
          rem
          rem Output: titlescreenWindow1-4 set for Title screen
          rem
          rem Mutates: titlescreenWindow1, titlescreenWindow2,
          rem titlescreenWindow3, titlescreenWindow4
          rem
          rem Called Routines: None
          rem Constraints: None
          let titlescreenWindow1 = 0   ; AtariAge logo hidden
          let titlescreenWindow2 = 0   ; AtariAgeText hidden
          let titlescreenWindow3 = 42  ; ChaosFight visible
          let titlescreenWindow4 = 0   ; Interworldly hidden
          return

