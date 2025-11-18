          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Console handling (detection, controllers, game mode transitions,
          rem   character controls, startup routines)

          bank 14

          asm
Bank14DataEnds
end

#include "Source/Routines/BeginTitleScreen.bas"
#include "Source/Routines/BeginPublisherPrelude.bas"
#include "Source/Routines/PublisherPrelude.bas"
#include "Source/Routines/ControllerDetection.bas"
#include "Source/Routines/ConsoleDetection.bas"
#include "Source/Routines/ChangeGameMode.bas"
#include "Source/Routines/BeginAuthorPrelude.bas"
#include "Source/Routines/BeginAttractMode.bas"
#include "Source/Routines/ColdStart.bas"
#include "Source/Routines/SpritePointerInit.bas"
#include "Source/Routines/TitleScreenMain.bas"
#include "Source/Routines/TitleCharacterParade.bas"
#include "Source/Routines/TitlescreenWindowControl.bas"
#include "Source/Routines/AttractMode.bas"
#include "Source/Routines/AuthorPrelude.bas"
#include "Source/Routines/LoadCharacterColors.bas"

          asm
Bank14CodeEnds
end
