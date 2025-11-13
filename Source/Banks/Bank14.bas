          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Console handling (detection, controllers, game mode transitions,
          rem   character controls, startup routines)

          asm
Bank14DataEnds
end

          rem Routines moved from Bank 1 - not needed for drawscreen
          rem calls
          rem These are called before/after drawscreen, not during it

          rem Console detection and handling moved to Bank 13

          rem Player locked helpers
#include "Source/Routines/BeginTitleScreen.bas"
#include "Source/Routines/BeginPublisherPrelude.bas"
#include "Source/Routines/ControllerDetection.bas"
#include "Source/Routines/ConsoleDetection.bas"
#include "Source/Routines/ChangeGameMode.bas"
#include "Source/Routines/BeginAuthorPrelude.bas"
#include "Source/Routines/BeginAttractMode.bas"
#include "Source/Routines/ColdStart.bas"
#include "Source/Routines/SpritePointerInit.bas"
#include "Source/Routines/ArenaSelect.bas"
#include "Source/Routines/Combat.bas"
#include "Source/Routines/TitleScreenMain.bas"
#include "Source/Routines/TitleCharacterParade.bas"
#include "Source/Routines/TitlescreenWindowControl.bas"
#include "Source/Routines/AttractMode.bas"

          asm
Bank14CodeEnds
end
