          rem ChaosFight - Source/Routines/ConsoleHandling.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CONSOLE SWITCH HANDLING
          rem =================================================================
          rem Handles Atari 2600 console switches during gameplay.

          rem SWITCHES:
          rem   switchreset - Game Reset → instant hard reboot (calls ColdStart)
          rem   switchselect - Game Select → toggle pause
          rem   switchbw - Color/B&W → handled in rendering

          rem AVAILABLE VARIABLES:
          rem   gameState - 0=normal play, 1=paused
          rem =================================================================

          rem Main console switch handler
HandleConsoleSwitches
          rem Game Reset switch - instant hard reboot (clears vars, reinitializes hardware)
          if switchreset then goto ColdStart

          rem Game Select switch or Joy2B+ Button III - toggle pause mode
          temp2 = 0 
          rem Check Player 1 buttons
          gosub CheckEnhancedPause
          if !temp1 then goto SkipPlayer1Pause
          rem Re-detect controllers when Select is pressed
          gosub bank14 DetectControllers
          if gameState = 0 then gameState = 1 : goto Player1PauseDone
          let gameState = 0
Player1PauseDone
          rem Debounce - wait for button release
          drawscreen
          return
SkipPlayer1Pause
          
          
          temp2 = 1 
          rem Check Player 2 buttons
          gosub CheckEnhancedPause
          if !temp1 then goto SkipPlayer2Pause
          rem Re-detect controllers when Select is pressed
          gosub bank14 DetectControllers
          if gameState = 0 then gameState = 1 : goto Player2PauseDone
          let gameState = 0
Player2PauseDone
          rem Debounce - wait for button release
          drawscreen
          return
SkipPlayer2Pause
          

          rem Color/B&W switch - re-detect controllers when toggled
          gosub CheckColorBWToggle
          
#ifndef TV_SECAM
          rem 7800 Pause button - toggle Color/B&W mode (not in SECAM)
          gosub Check7800Pause
#endif

          return

          rem =================================================================
          rem COLOR/B&W SWITCH CHANGE DETECTION
          rem =================================================================
          rem Re-detect controllers when Color/B&W switch is toggled
          
CheckColorBWToggle
          rem Check if Color/B&W switch state has changed
          temp6 = switchbw
          if temp6 = colorBWPrevious then goto SkipColorBWChange
          gosub bank14 DetectControllers
          let colorBWPrevious = switchbw
SkipColorBWChange
          return

