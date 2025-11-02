          rem ChaosFight - Source/Routines/ConsoleHandling.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CONSOLE SWITCH HANDLING
          rem =================================================================
          rem Handles Atari 2600 console switches during gameplay.

          rem SWITCHES:
          rem   switchreset - Game Reset → return to character select
          rem   switchselect - Game Select → toggle pause
          rem   switchbw - Color/B&W → handled in rendering

          rem AVAILABLE VARIABLES:
          rem   gameState - 0=normal play, 1=paused
          rem =================================================================

          rem Main console switch handler
HandleConsoleSwitches
          rem Game Reset switch - return to character selection
          if switchreset then goto CharacterSelect

          rem Game Select switch or Joy2B+ Button III - toggle pause mode
          temp2 = 0 
          rem Check Player 1 buttons
          gosub CheckEnhancedPause
          if !temp1 then SkipPlayer1Pause
          rem Re-detect controllers when Select is pressed
          gosub bank14 DetectControllers
          if gameState = 0 then gameState = 1
          if gameState = 0 then Player1PauseDone
          gameState = 0
Player1PauseDone
          rem Debounce - wait for button release
          drawscreen
          return
SkipPlayer1Pause
          
          
          temp2 = 1 
          rem Check Player 2 buttons
          gosub CheckEnhancedPause
          if !temp1 then SkipPlayer2Pause
          rem Re-detect controllers when Select is pressed
          gosub bank14 DetectControllers
          if gameState = 0 then gameState = 1
          if gameState = 0 then Player2PauseDone
          gameState = 0
Player2PauseDone
          rem Debounce - wait for button release
          drawscreen
          return
SkipPlayer2Pause
          

          rem Color/B&W switch - re-detect controllers when toggled
          gosub CheckColorBWToggle
          
#ifndef TV_SECAM
          rem 7800 Pause button - toggle Color/B&W mode (not in SECAM)
          gosub Check7800PauseButton
#endif

          return

          rem =================================================================
          rem COLOR/B&W SWITCH CHANGE DETECTION
          rem =================================================================
          rem Re-detect controllers when Color/B&W switch is toggled
          
CheckColorBWToggle
          rem Check if Color/B&W switch state has changed
          temp6 = switchbw
          if temp6 = colorBWPrevious then SkipColorBWChange
          gosub bank14 DetectControllers
          colorBWPrevious = switchbw
SkipColorBWChange
          return

          rem Display paused screen
DisplayPausedScreen
          rem Display "PAUSED" message using built-in font system
          rem Center the text on screen
          temp1 = 40 
          rem X position (centered)
          temp2 = 45 
          rem Y position (middle of screen)
          temp3 = 14 
          rem Color (white)
          
          rem Draw each character of "PAUSED"
          rem P
          temp4 = 25 
          rem ASCII "P"
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem A
          temp4 = 10 
          rem ASCII "A"
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem U
          temp4 = 30 
          rem ASCII "U"
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem S
          temp4 = 28 
          rem ASCII "S"
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem E
          temp4 = 14 
          rem ASCII "E"
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem D
          temp4 = 13 
          rem ASCII "D"
          gosub DrawCharacter
          
          return

