;;; ChaosFight - Source/Banks/Bank13.s
;;;Copyright © 2025 Bruce-Robert Pocock.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Console handling (detection, controllers, game mode transitions,
          ;; character controls, startup routines)

          ;; Set file offset for Bank 13 at the top of the file
          .offs (13 * $1000) - $f000  ; Adjust file offset for Bank 13

Bank13DataEnds:

          ;; Include Randomize routine (local implementation, not std_routines.asm)
.include "Source/Common/Randomize.s"
Bank13AfterRandomize:

.include "Source/Routines/BeginTitleScreen.s"
Bank13AfterBeginTitleScreen:
.include "Source/Routines/BeginPublisherPrelude.s"
Bank13AfterBeginPublisherPrelude:
.include "Source/Routines/PublisherPrelude.s"
Bank13AfterPublisherPrelude:
.include "Source/Routines/ChangeGameMode.s"
Bank13AfterChangeGameMode:
.include "Source/Routines/BeginAuthorPrelude.s"
Bank13AfterBeginAuthorPrelude:
.include "Source/Routines/BeginAttractMode.s"
Bank13AfterBeginAttractMode:
.include "Source/Routines/ColdStart.s"
Bank13AfterColdStart:
.include "Source/Routines/InitializeSpritePointers.s"
Bank13AfterSpritePointerInit:
.include "Source/Routines/TitleScreenMain.s"
Bank13AfterTitleScreenMain:
.include "Source/Routines/TitleCharacterParade.s"
Bank13AfterTitleCharacterParade:
.include "Source/Routines/AttractMode.s"
Bank13AfterAttractMode:
.include "Source/Routines/AuthorPrelude.s"
Bank13AfterAuthorPrelude:
.include "Source/Routines/LoadCharacterColors.s"
Bank13AfterLoadCharacterColors:
.include "Source/Routines/HandlePauseInput.s"
Bank13AfterHandlePauseInput:
.include "Source/Routines/BeginArenaSelect.s"
Bank13AfterBeginArenaSelect:
.include "Source/Routines/ArenaSelect.s"
Bank13AfterArenaSelect:
.include "Source/Routines/ArenaReloadUtils.s"
Bank13AfterArenaReloadUtils:
.include "Source/Routines/BeginFallingAnimation.s"
Bank13AfterBeginFallingAnimation:
.include "Source/Routines/WinnerAnnouncement.s"
Bank13AfterWinnerAnnouncement:
.include "Source/Routines/BeginWinnerAnnouncement.s"
Bank13AfterBeginWinnerAnnouncement:
.include "Source/Routines/UpdatePlayers34ActiveFlag.s"
Bank13AfterUpdatePlayers34ActiveFlag:
.include "Source/Routines/CountRemainingPlayers.s"
Bank13AfterCountRemainingPlayers:
.include "Source/Routines/FindLastEliminated.s"
Bank13AfterFindLastEliminated:
.include "Source/Routines/FindWinner.s"
Bank13AfterFindWinner:
.include "Source/Routines/CheckPlayerElimination.s"
Bank13AfterCheckPlayerElimination:
.include "Source/Routines/CheckAllPlayerEliminations.s"
Bank13AfterCheckAllPlayerEliminations:

Bank13CodeEnds:
           .warn format("// Bank 13: %d bytes = Randomize", [Bank13AfterRandomize - Bank13DataEnds])
           .warn format("// Bank 13: %d bytes = BeginTitleScreen", [Bank13AfterBeginTitleScreen - Bank13AfterRandomize])
           .warn format("// Bank 13: %d bytes = BeginPublisherPrelude", [Bank13AfterBeginPublisherPrelude - Bank13AfterBeginTitleScreen])
           .warn format("// Bank 13: %d bytes = PublisherPrelude", [Bank13AfterPublisherPrelude - Bank13AfterBeginPublisherPrelude])
           .warn format("// Bank 13: %d bytes = ChangeGameMode", [Bank13AfterChangeGameMode - Bank13AfterPublisherPrelude])
           .warn format("// Bank 13: %d bytes = BeginAuthorPrelude", [Bank13AfterBeginAuthorPrelude - Bank13AfterChangeGameMode])
           .warn format("// Bank 13: %d bytes = BeginAttractMode", [Bank13AfterBeginAttractMode - Bank13AfterBeginAuthorPrelude])
           .warn format("// Bank 13: %d bytes = ColdStart", [Bank13AfterColdStart - Bank13AfterBeginAttractMode])
           .warn format("// Bank 13: %d bytes = SpritePointerInit", [Bank13AfterSpritePointerInit - Bank13AfterColdStart])
           .warn format("// Bank 13: %d bytes = TitleScreenMain", [Bank13AfterTitleScreenMain - Bank13AfterSpritePointerInit])
           .warn format("// Bank 13: %d bytes = TitleCharacterParade", [Bank13AfterTitleCharacterParade - Bank13AfterTitleScreenMain])
           .warn format("// Bank 13: %d bytes = AttractMode", [Bank13AfterAttractMode - Bank13AfterTitleCharacterParade])
           .warn format("// Bank 13: %d bytes = AuthorPrelude", [Bank13AfterAuthorPrelude - Bank13AfterAttractMode])
           .warn format("// Bank 13: %d bytes = LoadCharacterColors", [Bank13AfterLoadCharacterColors - Bank13AfterAuthorPrelude])
           .warn format("// Bank 13: %d bytes = HandlePauseInput", [Bank13AfterHandlePauseInput - Bank13AfterLoadCharacterColors])
           .warn format("// Bank 13: %d bytes = BeginArenaSelect", [Bank13AfterBeginArenaSelect - Bank13AfterHandlePauseInput])
           .warn format("// Bank 13: %d bytes = ArenaSelect", [Bank13AfterArenaSelect - Bank13AfterBeginArenaSelect])
           .warn format("// Bank 13: %d bytes = ArenaReloadUtils", [Bank13AfterArenaReloadUtils - Bank13AfterArenaSelect])
           .warn format("// Bank 13: %d bytes = BeginFallingAnimation", [Bank13AfterBeginFallingAnimation - Bank13AfterArenaReloadUtils])
           .warn format("// Bank 13: %d bytes = WinnerAnnouncement", [Bank13AfterWinnerAnnouncement - Bank13AfterBeginFallingAnimation])
           .warn format("// Bank 13: %d bytes = BeginWinnerAnnouncement", [Bank13AfterBeginWinnerAnnouncement - Bank13AfterWinnerAnnouncement])
           .warn format("// Bank 13: %d bytes = UpdatePlayers34ActiveFlag", [Bank13AfterUpdatePlayers34ActiveFlag - Bank13AfterBeginWinnerAnnouncement])
           .warn format("// Bank 13: %d bytes = CountRemainingPlayers", [Bank13AfterCountRemainingPlayers - Bank13AfterUpdatePlayers34ActiveFlag])
           .warn format("// Bank 13: %d bytes = FindLastEliminated", [Bank13AfterFindLastEliminated - Bank13AfterCountRemainingPlayers])
           .warn format("// Bank 13: %d bytes = FindWinner", [Bank13AfterFindWinner - Bank13AfterFindLastEliminated])
           .warn format("// Bank 13: %d bytes = CheckPlayerElimination", [Bank13AfterCheckPlayerElimination - Bank13AfterFindWinner])
           .warn format("// Bank 13: %d bytes = CheckAllPlayerEliminations", [Bank13AfterCheckAllPlayerEliminations - Bank13AfterCheckPlayerElimination])

          ;; Include BankSwitching.s in Bank 13
          ;; Wrap in .block to create namespace Bank13BS (avoids duplicate definitions)
Bank13BS: .block
          current_bank = 13
          * = $FFE0 - bscode_length  ;;; CPU address: Bankswitch code starts here, ends just before $FFE0
          ;; Note: .offs was set at top of file, no need to reset it
          .include "Source/Common/BankSwitching.s"
          .bend
