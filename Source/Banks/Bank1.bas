          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1

          rem Titlescreen graphics moved to Bank 14 (with MainLoop, drawscreen, arenas, font, sprites)
          rem Override window values AFTER includes for correct
          rem   per-screen display
          rem Window values: 42 = visible, 0 = hidden
          rem Requirements per screen:
          rem Publisher (gameMode 0): AtariAge logo (48x2_1)=42,
          rem   AtariAgeText (48x2_2)=42, others=0 (2 bitmaps)
          rem Author (gameMode 1): BRP (48x2_4)=42, others=0 (1
          rem   bitmap)
          rem Title (gameMode 2): ChaosFight (48x2_3)=42, others=0 (1
          rem   bitmap)
          rem
          rem   height
          rem Note: Generated Art.*.s files already define window and
          rem values as 42. These definitions are included above in the
          rem   asm blocks, so we do NOT redefine them here to avoid
          rem   multiply-defined label errors.
          rem Runtime window control is handled via
          rem   titlescreenWindow1/2/3/4 variables set per screen
          rem If runtime window = 0, minikernel will not draw (Y register
          rem   will be -1)
          
          rem NOTE: Runtime window control implemented via
          rem   titlescreenWindow1/2/3 variables
          rem Screen routines call
          rem   SetPublisherWindowValues/SetAuthorWindowValues/
          rem   SetTitleWindowValues to set runtime window values
          rem   before drawing. Kernel checks
          rem   runtime variables first,
          rem falling back to compile-time constants if runtime
          rem   variables not defined.

          goto bank13 ColdStart

