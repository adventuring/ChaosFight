          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 14

          rem MainLoop, drawscreen, arenas, numeric font, titlescreen graphics, and special sprites
          rem must all be in Bank 14 for EF bankswitching
          
          rem Titlescreen graphics for admin screens (48×42 bitmaps)
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

#include "Source/Routines/ConsoleDetection.bas"
#include "Source/Routines/ControllerDetection.bas"
          
          rem Console handling moved from Bank 11
#include "Source/Routines/ConsoleHandling.bas"
          
          rem Small routines moved to free up space in other banks
#include "Source/Routines/SpriteLoaderCharacterArt.bas"
          rem SpriteLoaderCharacterArt.bas moved from Bank 10
#include "Source/Routines/ChangeGameMode.bas"
          rem ChangeGameMode.bas moved from Bank 13
#include "Source/Routines/MainLoop.bas"
          rem MainLoop.bas moved from Bank 13
#include "Source/Routines/PlayerLockedHelpers.bas"
          rem PlayerLockedHelpers.bas moved from Bank 10 (included by CharacterSelectMain.bas)