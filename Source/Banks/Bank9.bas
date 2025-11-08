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
#include "Source/Routines/PlayerLockedHelpers.bas"
#include "Source/Routines/CharacterAttacks.bas"
#include "Source/Routines/PerformMeleeAttack.bas"
#include "Source/Routines/PerformRangedAttack.bas"

          rem Moved from Bank 11 for space optimization
#include "Source/Routines/CheckRoboTitoStretchMissileCollisions.bas"

          asm
          ;;  Titlescreen graphics and kernel (moved from Bank 1)
          ;;  Titlescreen graphics for admin screens (48×42 bitmaps)
          ;;  Override window values AFTER includes for correct
          ;;  per-screen display
          ;;  Window values: 42 = visible, 0 = hidden
          ;;  Requirements per screen:
          ;;  Publisher (gameMode 0): AtariAge logo (48x2_1)=42,
          ;;    AtariAgeText (48x2_2)=42, others=0 (2 bitmaps)
          ;;  Author (gameMode 1): BRP (48x2_4)=42, others=0 (1 bitmap)
          ;;  Title (gameMode 2): ChaosFight (48x2_3)=42, others=0 (1
          ;;  bitmap)
          ;;  Note: Generated Art.*.s files already define window and
          ;;  values as 42.
          ;;    These definitions are included above in the asm blocks,
          ;;    so we do NOT
          ;;    redefine them here to avoid multiply-defined label
          ;;    errors.
          ;;  Runtime window control is handled via
          ;;  titlescreenWindow1/2/3/4 variables
          ;;    set per screen. If runtime window = 0, minikernel will
          ;;    not draw
          ;;    (Y register will be -1)
          ;;  NOTE: Runtime window control implemented via
          ;;  titlescreenWindow1/2/3 variables.
          ;;    Screen routines call
          ;;    SetPublisherWindowValues/SetAuthorWindowValues/
          ;;    SetTitleWindowValues to set runtime window values before
          ;;    drawing.
          ;;    Kernel checks runtime variables first, falling back to
          ;;    compile-time
          ;;    constants if runtime variables not defined.
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


