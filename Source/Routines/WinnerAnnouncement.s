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
          if joy0fire then WinnerAdvanceToCharacterSelect
          lda joy0fire
          beq skip_8169
          jmp WinnerAdvanceToCharacterSelect
skip_8169:

          if joy1fire then WinnerAdvanceToCharacterSelect
          lda joy1fire
          beq skip_810
          jmp WinnerAdvanceToCharacterSelect
skip_810:

          if switchselect then WinnerAdvanceToCharacterSelect
          lda switchselect
          beq skip_9664
          jmp WinnerAdvanceToCharacterSelect
skip_9664:

          ;; Display win screen and continue loop
          ;; drawscreen called by MainLoop
          ;; Cross-bank call to DisplayWinScreen in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DisplayWinScreen-1)
          pha
          lda # <(DisplayWinScreen-1)
          pha
          ldx # 13
          jmp BS_jsr
return_point:


          jsr BS_return

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
          lda ModeTitle
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
          ldx # 13
          jmp BS_jsr
return_point:


          jsr BS_return

.pend

