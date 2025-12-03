          rem ChaosFight - Source/Routines/HandlePauseInput.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

HandlePauseInput
          rem
          rem Pause Button Handling With Debouncing
          rem Handles SELECT switch and Joy2b+ Button III with proper
          rem   debouncing
          rem Uses SystemFlagPauseButtonPrev bit in systemFlags for debouncing
          rem Check SELECT switch (always available)
          let temp1 = 0
          if switchselect then let temp1 = 1

          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for
          rem Player 2)
          if LeftPortJoy2bPlus then if !INPT1{7} then let temp1 = 1
          if RightPortJoy2bPlus then if !INPT3{7} then let temp1 = 1
Joy2bPauseDone
          rem Player 2 Button III

          rem Debounce: only toggle if button just pressed (was 0, now
          rem 1)
          if temp1 = 0 then goto DonePauseToggle
          rem Toggle pause flag in systemFlags
          if systemFlags & SystemFlagPauseButtonPrev then goto DonePauseToggle
          if systemFlags & SystemFlagGameStatePaused then let systemFlags = systemFlags & ClearSystemFlagGameStatePaused else systemFlags = systemFlags | SystemFlagGameStatePaused
DonePauseToggle
          rem Toggle pause (0<->1)


          rem Update pause button previous state in systemFlags
          rem Update previous button state for next frame
          if temp1 then let systemFlags = systemFlags | SystemFlagPauseButtonPrev else systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev

          return thisbank
