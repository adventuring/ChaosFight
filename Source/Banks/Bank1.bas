          rem ChaosFight - Source/Banks/Bank1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 1

          rem MainLoop, drawscreen, arenas, numeric font, titlescreen graphics, and special sprites
          rem must all be in Bank 1 for EF bankswitching (kernel is in Bank 1)
          
          rem Titlescreen graphics for admin screens (48×42 bitmaps)
          rem Override window values AFTER includes for correct per-screen display
          rem Window values: 42 = visible, 0 = hidden
          rem Requirements per screen:
          rem Publisher (gameMode 0): AtariAge logo (48x2_1)=42,
          rem   AtariAgeText (48x2_2)=42, others=0 (2 bitmaps)
          rem Author (gameMode 1): BRP (48x2_4)=42, others=0 (1 bitmap)
          rem Title (gameMode 2): ChaosFight (48x2_3)=42, others=0 (1 bitmap)
          rem Note: Generated Art.*.s files already define window and values as 42.
          rem   These definitions are included above in the asm blocks, so we do NOT
          rem   redefine them here to avoid multiply-defined label errors.
          rem Runtime window control is handled via titlescreenWindow1/2/3/4 variables
          rem   set per screen. If runtime window = 0, minikernel will not draw
          rem   (Y register will be -1)
          rem NOTE: Runtime window control implemented via titlescreenWindow1/2/3 variables.
          rem   Screen routines call SetPublisherWindowValues/SetAuthorWindowValues/
          rem   SetTitleWindowValues to set runtime window values before drawing.
          rem   Kernel checks runtime variables first, falling back to compile-time
          rem   constants if runtime variables not defined.
          asm
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

          rem Special sprites and numeric font
#include "Source/Data/SpecialSprites.bas"
#include "Source/Routines/FontRendering.bas"

          rem Arena data (includes playfield and pfcolors data)
#include "Source/Routines/ArenaLoader.bas"

          rem Console detection and handling
#include "Source/Routines/ConsoleDetection.bas"
#include "Source/Routines/ControllerDetection.bas"
#include "Source/Routines/ConsoleHandling.bas"
          
          rem Character art location system
#include "Source/Routines/SpriteLoaderCharacterArt.bas"
          
          rem Game mode transitions
#include "Source/Routines/ChangeGameMode.bas"
          
          rem Main loop and drawscreen
#include "Source/Routines/MainLoop.bas"
          
          rem Player locked helpers
#include "Source/Routines/PlayerLockedHelpers.bas"

          goto ColdStart bank13

