          rem ChaosFight - Source/Routines/ConsoleHandling.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem CONSOLE SWITCH HANDLING
          rem ==========================================================
          rem Handles Atari 2600 console switches during gameplay.

          rem SWITCHES:
          rem   switchreset - Game Reset → return to publisher preamble
          rem   switchselect - Game Select → toggle pause
          rem   switchbw - Color/B&W → handled in rendering

          rem AVAILABLE VARIABLES:
          rem   gameState - 0=normal play, 1=paused
          rem ==========================================================

          rem ==========================================================
          rem WARM START / RESET HANDLER
          rem ==========================================================
          rem Handles game reset from any screen/state.
          rem Clears critical state variables and reinitializes hardware
          rem   registers.
          rem Called when RESET button is pressed.
          rem
          rem EFFECTS:
          rem   - Clears game state variables
          rem   - Reinitializes TIA color and audio registers
          rem   - Resets gameMode to ModePublisherPreamble
          rem   - Calls ChangeGameMode to transition to startup sequence
          rem ==========================================================
WarmStart
          rem Step 1: Clear critical game state variables
          let gameState = 0
          rem 0 = normal (not paused, not ending)
          let frame = 0
          rem Reset frame counter
          
          rem Step 2: Reinitialize TIA color registers to safe defaults
          rem Match ColdStart initialization for consistency
          COLUBK = ColGray(0)
          rem Background: black
          COLUPF = ColGrey(14)
          rem Playfield: white
          COLUP0 = ColBlue(14)
          rem Player 0: bright blue
          _COLUP1 = ColRed(14)
          rem Player 1: bright red (multisprite kernel requires _COLUP1)
          
          rem Step 3: Initialize audio channels (silent on reset)
          AUDC0 = 0
          AUDV0 = 0
          AUDC1 = 0
          AUDV1 = 0
          
          rem Step 4: Clear playfield registers to prevent artifacts
          pf0 = 0
          pf1 = 0
          pf2 = 0
          pf3 = 0
          pf4 = 0
          pf5 = 0
          
          rem Step 5: Clear sprite enable registers
          ENAM0 = 0
          ENAM1 = 0
          ENABL = 0
          
          rem Step 6: Reset game mode to startup sequence
          let gameMode = ModePublisherPreamble
          gosub bank13 ChangeGameMode
          
          rem Reset complete - return to MainLoop which will dispatch to
          rem   new mode
          return

          rem Main console switch handler
          rem NOTE: RESET is now handled in MainLoop via centralized
          rem   WarmStart call
          rem This function only handles pause/select switches
HandleConsoleSwitches

          rem Game Select switch or Joy2B+ Button III - toggle pause
          rem   mode
          let temp2 = 0 
          rem Check Player 1 buttons
          gosub CheckEnhancedPause
          if !temp1 then DonePlayer1Pause
          rem Re-detect controllers when Select is pressed
          gosub bank14 DetectControllers
          if gameState = 0 then let gameState = 1:goto Player1PauseDone
          let gameState = 0
Player1PauseDone
          rem Debounce - wait for button release
          drawscreen
          return
DonePlayer1Pause
          
          
          let temp2 = 1 
          rem Check Player 2 buttons
          gosub CheckEnhancedPause
          if !temp1 then DonePlayer2Pause
          rem Re-detect controllers when Select is pressed
          gosub bank14 DetectControllers
          if gameState = 0 then let gameState = 1
          if gameState = 0 then Player2PauseDone
          let gameState = 0
Player2PauseDone
          rem Debounce - wait for button release
          drawscreen
          return
DonePlayer2Pause
          

          rem Color/B&W switch - re-detect controllers when toggled
          gosub CheckColorBWToggle
          
#ifndef TV_SECAM
          rem 7800 Pause button - toggle Color/B&W mode (not in SECAM)
          rem tail call
          goto Check7800PauseButton
#endif

          return

          rem ==========================================================
          rem COLOR/B&W SWITCH CHANGE DETECTION
          rem ==========================================================
          rem Re-detect controllers when Color/B&W switch is toggled
          
CheckColorBWToggle
          dim CCBT_switchChanged = temp1
          dim CCBT_overrideChanged = temp2
          
          rem Check if Color/B&W switch state has changed
          temp6 = switchbw
          let CCBT_switchChanged = 0
          if temp6 = colorBWPrevious_R then DoneSwitchChange
          let CCBT_switchChanged = 1
          gosub bank14 DetectControllers
          let colorBWPrevious_W = switchbw
DoneSwitchChange

          rem Check if colorBWOverride changed (7800 pause button)
          #ifndef TV_SECAM
          rem Note: colorBWOverride does not have a previous value
          rem   stored,
          rem so we check it every frame. This is acceptable since it is
          rem only toggled by button press, not continuously.
          rem If needed, we could add a previous value variable.
          #endif
          
          rem Reload arena colors if switch or override changed
          if CCBT_switchChanged then ReloadArenaColorsNow
          #ifndef TV_SECAM
          rem Always check override in case it was toggled
          rem (Check7800PauseButton is called after this, so we check it
          rem   here)
          rem Actually, we should check after Check7800PauseButton is
          rem   called
          rem So we will reload in that function instead
          #endif
          
          return

ReloadArenaColorsNow
          rem Reload arena colors with current switch state
          gosub bank14 ReloadArenaColors
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
          rem tail call
          goto DrawCharacter
          

