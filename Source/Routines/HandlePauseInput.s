;;; ChaosFight - Source/Routines/HandlePauseInput.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HandlePauseInput .proc
          ;;
          ;; Pause Button Handling With Debouncing
          ;; Handles SELECT switch and Joy2b+ Button III with proper
          ;; debouncing
          ;; Uses SystemFlagPauseButtonPrev bit in systemFlags for debouncing
          ;; Check SELECT switch (always available)
          lda # 0
          sta temp1
                    if switchselect then let temp1 = 1          lda switchselect          beq skip_7014
skip_7014:
          jmp skip_7014

          ;; Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for
          ;; Player 2)
                    if LeftPortJoy2bPlus then if !INPT1{7} then let temp1 = 1
          lda LeftPortJoy2bPlus
          beq skip_2135
          bit INPT1
          bmi skip_2135
          lda # 1
          sta temp1
skip_2135:
                    if RightPortJoy2bPlus then if !INPT3{7} then let temp1 = 1
          lda RightPortJoy2bPlus
          beq skip_2706
          bit INPT3
          bmi skip_2706
          lda # 1
          sta temp1
skip_2706:
Joy2bPauseDone
          ;; Player 2 Button III

          ;; Debounce: only toggle if button just pressed (was 0, now
          ;; 1)
          lda temp1
          cmp # 0
          bne skip_3161
          jmp DonePauseToggle
skip_3161:

          ;; Toggle pause flag in systemFlags
                    if systemFlags & SystemFlagPauseButtonPrev then goto DonePauseToggle
          lda systemFlags
          and SystemFlagPauseButtonPrev
          beq skip_3278
          jmp DonePauseToggle
skip_3278:
                    if systemFlags & SystemFlagGameStatePaused then let systemFlags = systemFlags & ClearSystemFlagGameStatePaused else systemFlags = systemFlags | SystemFlagGameStatePaused
          lda systemFlags
          and SystemFlagGameStatePaused
          beq skip_179
          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags
          jmp end_179
skip_179:
          lda systemFlags
          ora SystemFlagGameStatePaused
          sta systemFlags
end_179:
DonePauseToggle
          ;; Toggle pause (0<->1)


          ;; Update pause button previous state in systemFlags
          ;; Update previous button state for next frame
                    if temp1 then let systemFlags = systemFlags | SystemFlagPauseButtonPrev else systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev
          lda temp1
          beq skip_6637
          lda systemFlags
          ora SystemFlagPauseButtonPrev
          sta systemFlags
          jmp end_9698
skip_6637:
          lda systemFlags
          and ClearSystemFlagPauseButtonPrev
          sta systemFlags
end_9698:

          rts

.pend

