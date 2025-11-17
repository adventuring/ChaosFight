          rem ChaosFight - Source/Routines/HandlePauseInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

HandlePauseInput
          rem
          rem Pause Button Handling With Debouncing
          rem Handles SELECT switch and Joy2b+ Button III with proper
          rem   debouncing
          rem Uses pauseButtonPrev for debouncing state
          let temp1 = 0
          rem Check SELECT switch (always available)
          if switchselect then temp1 = 1

          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for
          rem Player 2)
          if LeftPortJoy2bPlus then if !INPT1{7} then temp1 = 1
          if RightPortJoy2bPlus then if !INPT3{7} then temp1 = 1
Joy2bPauseDone
          rem Player 2 Button III

          rem Debounce: only toggle if button just pressed (was 0, now
          rem 1)
          if temp1 = 0 then DonePauseToggle
          if pauseButtonPrev then DonePauseToggle
          let gameState = gameState ^ 1
DonePauseToggle
          rem Toggle pause (0<->1)


          let pauseButtonPrev = temp1
          rem Update previous button state for next frame

          return

