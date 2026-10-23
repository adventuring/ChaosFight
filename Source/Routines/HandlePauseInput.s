;;; ChaosFight - Source/Routines/HandlePauseInput.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HandlePauseInput .block
          ;;
          ;; Pause Button Handling With Debouncing
          ;; Handles SELECT switch and Joy2b+ Button III with proper
          ;; debouncing
          ;; Uses SystemFlagPauseButtonPrev bit in systemFlags for debouncing
          ;; Check SELECT switch (always available)
          lda # 0
          sta temp1
          lda SWCHB
          eor # SWCHBSelect
          and # SWCHBSelect
          beq SkipSelectSwitch
          lda # 1
          sta temp1

SkipSelectSwitch:

          ;; Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for
          ;; Player 2)
          lda # LeftPortJoy2bPlus
          beq SkipLeftPortJoy2bPause
          lda INPT1
          bmi SkipLeftPortJoy2bPause
          lda # 1
          sta temp1

SkipLeftPortJoy2bPause:
          lda # RightPortJoy2bPlus
          beq SkipRightPortJoy2bPause
          lda INPT3
          bmi SkipRightPortJoy2bPause
          lda # 1
          sta temp1

SkipRightPortJoy2bPause:

Joy2bPauseDone:
          ;; Player 2 Button III

          ;; Debounce: only toggle if button just pressed (was 0, now
          ;; 1)
          lda temp1
          bne CheckPauseButtonPrev

          jmp DonePauseToggle

CheckPauseButtonPrev:

          ;; Toggle pause flag in systemFlags
          ;; if systemFlags & SystemFlagPauseButtonPrev then jmp DonePauseToggle
          lda systemFlags
          and # SystemFlagPauseButtonPrev
          beq TogglePauseState

          jmp DonePauseToggle

TogglePauseState:
          lda systemFlags
          and # SystemFlagGameStatePaused
          beq SetPauseFlag

          lda systemFlags
          and # ClearSystemFlagGameStatePaused
          sta systemFlags
          jmp PauseToggleDone

SetPauseFlag:
          lda systemFlags
          ora # SystemFlagGameStatePaused
          sta systemFlags

PauseToggleDone:

DonePauseToggle:
          ;; Toggle pause (0<->1)

          ;; Update pause button previous state in systemFlags
          ;; Update previous button state for next frame
          lda temp1
          beq ClearPauseButtonPrev

          lda systemFlags
          ora # SystemFlagPauseButtonPrev
          sta systemFlags
          jmp UpdatePauseButtonPrevDone

ClearPauseButtonPrev:
          lda systemFlags
          and # ClearSystemFlagPauseButtonPrev
          sta systemFlags

UpdatePauseButtonPrevDone:

          rts

.bend

