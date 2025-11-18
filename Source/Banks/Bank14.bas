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
#include "Source/Routines/ConsoleDetection.bas"
          asm
Bank14AfterConsoleDetection
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
          if Bank14CodeEnds > ($FFE0 - bscode_length - 32)
           echo "Bank 14 file sizes (compiled code bytes):"
           echo "  BeginTitleScreen: ", [Bank14AfterBeginTitleScreen - Bank14DataEnds]d, " bytes"
           echo "  BeginPublisherPrelude: ", [Bank14AfterBeginPublisherPrelude - Bank14AfterBeginTitleScreen]d, " bytes"
           echo "  PublisherPrelude: ", [Bank14AfterPublisherPrelude - Bank14AfterBeginPublisherPrelude]d, " bytes"
           echo "  ConsoleDetection: ", [Bank14AfterConsoleDetection - Bank14AfterPublisherPrelude]d, " bytes"
           echo "  ChangeGameMode: ", [Bank14AfterChangeGameMode - Bank14AfterConsoleDetection]d, " bytes"
           echo "  BeginAuthorPrelude: ", [Bank14AfterBeginAuthorPrelude - Bank14AfterChangeGameMode]d, " bytes"
           echo "  BeginAttractMode: ", [Bank14AfterBeginAttractMode - Bank14AfterBeginAuthorPrelude]d, " bytes"
           echo "  ColdStart: ", [Bank14AfterColdStart - Bank14AfterBeginAttractMode]d, " bytes"
           echo "  SpritePointerInit: ", [Bank14AfterSpritePointerInit - Bank14AfterColdStart]d, " bytes"
           echo "  TitleScreenMain: ", [Bank14AfterTitleScreenMain - Bank14AfterSpritePointerInit]d, " bytes"
           echo "  TitleCharacterParade: ", [Bank14AfterTitleCharacterParade - Bank14AfterTitleScreenMain]d, " bytes"
           echo "  TitlescreenWindowControl: ", [Bank14AfterTitlescreenWindowControl - Bank14AfterTitleCharacterParade]d, " bytes"
           echo "  AttractMode: ", [Bank14AfterAttractMode - Bank14AfterTitlescreenWindowControl]d, " bytes"
           echo "  AuthorPrelude: ", [Bank14AfterAuthorPrelude - Bank14AfterAttractMode]d, " bytes"
           echo "  LoadCharacterColors: ", [Bank14AfterLoadCharacterColors - Bank14AfterAuthorPrelude]d, " bytes"
           echo "  HandlePauseInput: ", [Bank14AfterHandlePauseInput - Bank14AfterLoadCharacterColors]d, " bytes"
           echo "  BeginArenaSelect: ", [Bank14AfterBeginArenaSelect - Bank14AfterHandlePauseInput]d, " bytes"
           echo "  ArenaSelect: ", [Bank14AfterArenaSelect - Bank14AfterBeginArenaSelect]d, " bytes"
           echo "  ArenaReloadUtils: ", [Bank14AfterArenaReloadUtils - Bank14AfterArenaSelect]d, " bytes"
           echo "  BeginFallingAnimation: ", [Bank14AfterBeginFallingAnimation - Bank14AfterArenaReloadUtils]d, " bytes"
           echo "  WinnerAnnouncement: ", [Bank14AfterWinnerAnnouncement - Bank14AfterBeginFallingAnimation]d, " bytes"
           echo "  BeginWinnerAnnouncement: ", [Bank14AfterBeginWinnerAnnouncement - Bank14AfterWinnerAnnouncement]d, " bytes"
           echo "  UpdatePlayers34ActiveFlag: ", [Bank14AfterUpdatePlayers34ActiveFlag - Bank14AfterBeginWinnerAnnouncement]d, " bytes"
           echo "  CountRemainingPlayers: ", [Bank14AfterCountRemainingPlayers - Bank14AfterUpdatePlayers34ActiveFlag]d, " bytes"
           echo "  FindLastEliminated: ", [Bank14AfterFindLastEliminated - Bank14AfterCountRemainingPlayers]d, " bytes"
           echo "  FindWinner: ", [Bank14AfterFindWinner - Bank14AfterFindLastEliminated]d, " bytes"
           echo "  CheckPlayerElimination: ", [Bank14AfterCheckPlayerElimination - Bank14AfterFindWinner]d, " bytes"
           echo "  CheckAllPlayerEliminations: ", [Bank14AfterCheckAllPlayerEliminations - Bank14AfterCheckPlayerElimination]d, " bytes"
          else
           echo "Bank 14 file sizes (compiled code bytes):"
           echo "  BeginTitleScreen: ", [Bank14AfterBeginTitleScreen - Bank14DataEnds]d, " bytes"
           echo "  BeginPublisherPrelude: ", [Bank14AfterBeginPublisherPrelude - Bank14AfterBeginTitleScreen]d, " bytes"
           echo "  PublisherPrelude: ", [Bank14AfterPublisherPrelude - Bank14AfterBeginPublisherPrelude]d, " bytes"
           echo "  ConsoleDetection: ", [Bank14AfterConsoleDetection - Bank14AfterPublisherPrelude]d, " bytes"
           echo "  ChangeGameMode: ", [Bank14AfterChangeGameMode - Bank14AfterConsoleDetection]d, " bytes"
           echo "  BeginAuthorPrelude: ", [Bank14AfterBeginAuthorPrelude - Bank14AfterChangeGameMode]d, " bytes"
           echo "  BeginAttractMode: ", [Bank14AfterBeginAttractMode - Bank14AfterBeginAuthorPrelude]d, " bytes"
           echo "  ColdStart: ", [Bank14AfterColdStart - Bank14AfterBeginAttractMode]d, " bytes"
           echo "  SpritePointerInit: ", [Bank14AfterSpritePointerInit - Bank14AfterColdStart]d, " bytes"
           echo "  TitleScreenMain: ", [Bank14AfterTitleScreenMain - Bank14AfterSpritePointerInit]d, " bytes"
           echo "  TitleCharacterParade: ", [Bank14AfterTitleCharacterParade - Bank14AfterTitleScreenMain]d, " bytes"
           echo "  TitlescreenWindowControl: ", [Bank14AfterTitlescreenWindowControl - Bank14AfterTitleCharacterParade]d, " bytes"
           echo "  AttractMode: ", [Bank14AfterAttractMode - Bank14AfterTitlescreenWindowControl]d, " bytes"
           echo "  AuthorPrelude: ", [Bank14AfterAuthorPrelude - Bank14AfterAttractMode]d, " bytes"
           echo "  LoadCharacterColors: ", [Bank14AfterLoadCharacterColors - Bank14AfterAuthorPrelude]d, " bytes"
           echo "  HandlePauseInput: ", [Bank14AfterHandlePauseInput - Bank14AfterLoadCharacterColors]d, " bytes"
           echo "  BeginArenaSelect: ", [Bank14AfterBeginArenaSelect - Bank14AfterHandlePauseInput]d, " bytes"
           echo "  ArenaSelect: ", [Bank14AfterArenaSelect - Bank14AfterBeginArenaSelect]d, " bytes"
           echo "  ArenaReloadUtils: ", [Bank14AfterArenaReloadUtils - Bank14AfterArenaSelect]d, " bytes"
           echo "  BeginFallingAnimation: ", [Bank14AfterBeginFallingAnimation - Bank14AfterArenaReloadUtils]d, " bytes"
           echo "  WinnerAnnouncement: ", [Bank14AfterWinnerAnnouncement - Bank14AfterBeginFallingAnimation]d, " bytes"
           echo "  BeginWinnerAnnouncement: ", [Bank14AfterBeginWinnerAnnouncement - Bank14AfterWinnerAnnouncement]d, " bytes"
           echo "  UpdatePlayers34ActiveFlag: ", [Bank14AfterUpdatePlayers34ActiveFlag - Bank14AfterBeginWinnerAnnouncement]d, " bytes"
           echo "  CountRemainingPlayers: ", [Bank14AfterCountRemainingPlayers - Bank14AfterUpdatePlayers34ActiveFlag]d, " bytes"
           echo "  FindLastEliminated: ", [Bank14AfterFindLastEliminated - Bank14AfterCountRemainingPlayers]d, " bytes"
           echo "  FindWinner: ", [Bank14AfterFindWinner - Bank14AfterFindLastEliminated]d, " bytes"
           echo "  CheckPlayerElimination: ", [Bank14AfterCheckPlayerElimination - Bank14AfterFindWinner]d, " bytes"
           echo "  CheckAllPlayerEliminations: ", [Bank14AfterCheckAllPlayerEliminations - Bank14AfterCheckPlayerElimination]d, " bytes"
          endif
end
