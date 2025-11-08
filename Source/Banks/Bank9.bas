          rem ChaosFight - Source/Banks/Bank9.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 9
          
          rem Title sequence and preludes
          rem Grouped together - title screen flow
          rem TitleSequence.bas has been split into separate files below
#include "Source/Routines/BeginPublisherPrelude.bas"
#include "Source/Routines/PublisherPrelude.bas"
#include "Source/Routines/BeginAuthorPrelude.bas"
#include "Source/Routines/AuthorPrelude.bas"
#include "Source/Routines/BeginTitleScreen.bas"
#include "Source/Routines/TitleScreenMain.bas"
#include "Source/Routines/TitleScreenRender.bas"
#include "Source/Routines/TitleCharacterParade.bas"
#include "Source/Routines/BeginAttractMode.bas"
#include "Source/Routines/AttractMode.bas"
          
          asm
          ; rem Titlescreen graphics and kernel (moved from Bank 1)
          ; rem Titlescreen graphics for admin screens (48×42 bitmaps)
          ; rem Override window values AFTER includes for correct
          ; rem per-screen display
          ; rem Window values: 42 = visible, 0 = hidden
          ; rem Requirements per screen:
          ; rem Publisher (gameMode 0): AtariAge logo (48x2_1)=42,
          ; rem   AtariAgeText (48x2_2)=42, others=0 (2 bitmaps)
          ; rem Author (gameMode 1): BRP (48x2_4)=42, others=0 (1 bitmap)
          ; rem Title (gameMode 2): ChaosFight (48x2_3)=42, others=0 (1
          ; rem bitmap)
          ; rem Note: Generated Art.*.s files already define window and
          ; rem values as 42.
          ; rem   These definitions are included above in the asm blocks,
          ; rem   so we do NOT
          ; rem   redefine them here to avoid multiply-defined label
          ; rem   errors.
          ; rem Runtime window control is handled via
          ; rem titlescreenWindow1/2/3/4 variables
          ; rem   set per screen. If runtime window = 0, minikernel will
          ; rem   not draw
          ; rem   (Y register will be -1)
          ; rem NOTE: Runtime window control implemented via
          ; rem titlescreenWindow1/2/3 variables.
          ; rem   Screen routines call
          ; rem   SetPublisherWindowValues/SetAuthorWindowValues/
          ; rem   SetTitleWindowValues to set runtime window values before
          ; rem   drawing.
          ; rem   Kernel checks runtime variables first, falling back to
          ; rem   compile-time
          ; rem   constants if runtime variables not defined.
#include "Source/Generated/Art.AtariAge.s"
end
          asm
#include "Source/Generated/Art.AtariAgeText.s"
end
          asm
#include "Source/Generated/Art.ChaosFight.s"
end
          asm
#include "Source/Generated/Art.BRP.s"
end
          
          asm
#include "Source/TitleScreen/asm/titlescreen.s"
end
          
          rem The title screen routines in this bank call it via gosub
          rem   titledrawscreen bank9


