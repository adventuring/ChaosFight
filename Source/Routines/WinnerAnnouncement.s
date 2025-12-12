;;; ChaosFight - Source/Routines/WinnerAnnouncement.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


WinnerAnnouncementLoop .proc
          ;; Winner announcement mode per-frame loop
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: joy0fire, joy1fire (hardware) = button sta

          ;; switchselect (hardware) = select switch sta

          ;; Output: Dispatches to WinnerAdvanceToCharacterSelect or returns
          ;;
          ;; Called Routines: DisplayWinScreen (bank16) - accesses
          ;; winner screen sta

          ;;
          ;; Constraints: Must be colocated with WinnerAdvanceToCharacterSelect
          ;; Check for button press to advance immediately
          ;; If joy0fire, then WinnerAdvanceToCharacterSelect
          lda joy0fire
          beq CheckJoy1Fire
          jmp WinnerAdvanceToCharacterSelect

CheckJoy1Fire:

          ;; If joy1fire, then WinnerAdvanceToCharacterSelect
          lda joy1fire
          beq CheckSelectSwitch
          jmp WinnerAdvanceToCharacterSelect

CheckSelectSwitch:

          ;; If switchselect, then WinnerAdvanceToCharacterSelect
          lda switchselect
          beq DisplayWinScreen

          jmp WinnerAdvanceToCharacterSelect

DisplayWinScreen:

          ;; Display win screen and continue loop
          ;; drawscreen called by MainLoop
          ;; Cross-bank call to DisplayWinScreen in bank 16
          lda # >(AfterDisplayWinScreen-1)
          pha
          lda # <(AfterDisplayWinScreen-1)
          pha
          lda # >(DisplayWinScreen-1)
          pha
          lda # <(DisplayWinScreen-1)
          pha
          ldx # 13
          jmp BS_jsr

AfterDisplayWinScreen:

          jmp BS_return

.pend

WinnerAdvanceToCharacterSelect .proc
          ;; Transition to title screen (per issue #483 requirement)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from WinnerAnnouncementLoop)
          ;;
          ;; Output: gameMode set to ModeTitle, ChangeGameMode called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: ChangeGameMode (bank14) - accesses game
          ;; mode sta

          ;; Constraints: Must be colocated with WinnerAnnouncementLoop
          lda # ModeTitle
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(AfterChangeGameModeWinner-1)
          pha
          lda # <(AfterChangeGameModeWinner-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
          ldx # 13
          jmp BS_jsr
AfterChangeGameModeWinner:


          jmp BS_return

.pend

