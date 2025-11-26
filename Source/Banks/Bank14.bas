          rem ChaosFight - Source/Banks/Bank14.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem GENERAL CODE BANK (shared memory budget - 8 banks total)
          rem Console handling (detection, controllers, game mode transitions,
          rem   character controls, startup routines)

          bank 14

          asm
Bank14DataEnds
end

          rem Include Randomize routine (local implementation, not std_routines.asm)
          asm
#include "Source/Common/Randomize.s"
Bank14AfterRandomize
end

#include "Source/Routines/BeginTitleScreen.bas"
          asm
Bank14AfterBeginTitleScreen
end
#include "Source/Routines/BeginPublisherPrelude.bas"
          asm
Bank14AfterBeginPublisherPrelude
end
#include "Source/Routines/PublisherPrelude.bas"
          asm
Bank14AfterPublisherPrelude
end
#include "Source/Routines/ChangeGameMode.bas"
          asm
Bank14AfterChangeGameMode
end
#include "Source/Routines/BeginAuthorPrelude.bas"
          asm
Bank14AfterBeginAuthorPrelude
end
#include "Source/Routines/BeginAttractMode.bas"
          asm
Bank14AfterBeginAttractMode
end
#include "Source/Routines/ColdStart.bas"
          asm
Bank14AfterColdStart
end
#include "Source/Routines/SpritePointerInit.bas"
          asm
Bank14AfterSpritePointerInit
end
#include "Source/Routines/TitleScreenMain.bas"
          asm
Bank14AfterTitleScreenMain
end
#include "Source/Routines/TitleCharacterParade.bas"
          asm
Bank14AfterTitleCharacterParade
end
#include "Source/Routines/TitlescreenWindowControl.bas"
          asm
Bank14AfterTitlescreenWindowControl
end
#include "Source/Routines/AttractMode.bas"
          asm
Bank14AfterAttractMode
end
#include "Source/Routines/AuthorPrelude.bas"
          asm
Bank14AfterAuthorPrelude
end
#include "Source/Routines/LoadCharacterColors.bas"
          asm
Bank14AfterLoadCharacterColors
end
#include "Source/Routines/HandlePauseInput.bas"
          asm
Bank14AfterHandlePauseInput
end
#include "Source/Routines/BeginArenaSelect.bas"
          asm
Bank14AfterBeginArenaSelect
end
#include "Source/Routines/ArenaSelect.bas"
          asm
Bank14AfterArenaSelect
end
#include "Source/Routines/ArenaReloadUtils.bas"
          asm
Bank14AfterArenaReloadUtils
end
#include "Source/Routines/BeginFallingAnimation.bas"
          asm
Bank14AfterBeginFallingAnimation
end
#include "Source/Routines/WinnerAnnouncement.bas"
          asm
Bank14AfterWinnerAnnouncement
end
#include "Source/Routines/BeginWinnerAnnouncement.bas"
          asm
Bank14AfterBeginWinnerAnnouncement
end
#include "Source/Routines/UpdatePlayers34ActiveFlag.bas"
          asm
Bank14AfterUpdatePlayers34ActiveFlag
end
#include "Source/Routines/CountRemainingPlayers.bas"
          asm
Bank14AfterCountRemainingPlayers
end
#include "Source/Routines/FindLastEliminated.bas"
          asm
Bank14AfterFindLastEliminated
end
#include "Source/Routines/FindWinner.bas"
          asm
Bank14AfterFindWinner
end
#include "Source/Routines/CheckPlayerElimination.bas"
          asm
Bank14AfterCheckPlayerElimination
end
#include "Source/Routines/CheckAllPlayerEliminations.bas"
          asm
Bank14AfterCheckAllPlayerEliminations
end

          asm
Bank14CodeEnds
           echo "// Bank 14: ", [Bank14AfterRandomize - Bank14DataEnds]d, " bytes = Randomize"
           echo "// Bank 14: ", [Bank14AfterBeginTitleScreen - Bank14AfterRandomize]d, " bytes = BeginTitleScreen"
           echo "// Bank 14: ", [Bank14AfterBeginPublisherPrelude - Bank14AfterBeginTitleScreen]d, " bytes = BeginPublisherPrelude"
           echo "// Bank 14: ", [Bank14AfterPublisherPrelude - Bank14AfterBeginPublisherPrelude]d, " bytes = PublisherPrelude"
           echo "// Bank 14: ", [Bank14AfterChangeGameMode - Bank14AfterPublisherPrelude]d, " bytes = ChangeGameMode"
           echo "// Bank 14: ", [Bank14AfterBeginAuthorPrelude - Bank14AfterChangeGameMode]d, " bytes = BeginAuthorPrelude"
           echo "// Bank 14: ", [Bank14AfterBeginAttractMode - Bank14AfterBeginAuthorPrelude]d, " bytes = BeginAttractMode"
           echo "// Bank 14: ", [Bank14AfterColdStart - Bank14AfterBeginAttractMode]d, " bytes = ColdStart"
           echo "// Bank 14: ", [Bank14AfterSpritePointerInit - Bank14AfterColdStart]d, " bytes = SpritePointerInit"
           echo "// Bank 14: ", [Bank14AfterTitleScreenMain - Bank14AfterSpritePointerInit]d, " bytes = TitleScreenMain"
           echo "// Bank 14: ", [Bank14AfterTitleCharacterParade - Bank14AfterTitleScreenMain]d, " bytes = TitleCharacterParade"
           echo "// Bank 14: ", [Bank14AfterTitlescreenWindowControl - Bank14AfterTitleCharacterParade]d, " bytes = TitlescreenWindowControl"
           echo "// Bank 14: ", [Bank14AfterAttractMode - Bank14AfterTitlescreenWindowControl]d, " bytes = AttractMode"
           echo "// Bank 14: ", [Bank14AfterAuthorPrelude - Bank14AfterAttractMode]d, " bytes = AuthorPrelude"
           echo "// Bank 14: ", [Bank14AfterLoadCharacterColors - Bank14AfterAuthorPrelude]d, " bytes = LoadCharacterColors"
           echo "// Bank 14: ", [Bank14AfterHandlePauseInput - Bank14AfterLoadCharacterColors]d, " bytes = HandlePauseInput"
           echo "// Bank 14: ", [Bank14AfterBeginArenaSelect - Bank14AfterHandlePauseInput]d, " bytes = BeginArenaSelect"
           echo "// Bank 14: ", [Bank14AfterArenaSelect - Bank14AfterBeginArenaSelect]d, " bytes = ArenaSelect"
           echo "// Bank 14: ", [Bank14AfterArenaReloadUtils - Bank14AfterArenaSelect]d, " bytes = ArenaReloadUtils"
           echo "// Bank 14: ", [Bank14AfterBeginFallingAnimation - Bank14AfterArenaReloadUtils]d, " bytes = BeginFallingAnimation"
           echo "// Bank 14: ", [Bank14AfterWinnerAnnouncement - Bank14AfterBeginFallingAnimation]d, " bytes = WinnerAnnouncement"
           echo "// Bank 14: ", [Bank14AfterBeginWinnerAnnouncement - Bank14AfterWinnerAnnouncement]d, " bytes = BeginWinnerAnnouncement"
           echo "// Bank 14: ", [Bank14AfterUpdatePlayers34ActiveFlag - Bank14AfterBeginWinnerAnnouncement]d, " bytes = UpdatePlayers34ActiveFlag"
           echo "// Bank 14: ", [Bank14AfterCountRemainingPlayers - Bank14AfterUpdatePlayers34ActiveFlag]d, " bytes = CountRemainingPlayers"
           echo "// Bank 14: ", [Bank14AfterFindLastEliminated - Bank14AfterCountRemainingPlayers]d, " bytes = FindLastEliminated"
           echo "// Bank 14: ", [Bank14AfterFindWinner - Bank14AfterFindLastEliminated]d, " bytes = FindWinner"
           echo "// Bank 14: ", [Bank14AfterCheckPlayerElimination - Bank14AfterFindWinner]d, " bytes = CheckPlayerElimination"
           echo "// Bank 14: ", [Bank14AfterCheckAllPlayerEliminations - Bank14AfterCheckPlayerElimination]d, " bytes = CheckAllPlayerEliminations"
        
end
