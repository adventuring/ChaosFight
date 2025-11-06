          rem ChaosFight - Source/Routines/ConsoleHandling.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Console Switch Handling
          rem
          rem Handles Atari 2600 console switches during gameplay.

          rem SWITCHES:
          rem   switchreset - Game Reset → return to publisher prelude
          rem   switchselect - Game Select → toggle pause
          rem   switchbw - Color/B&W → handled in rendering

          rem AVAILABLE VARIABLES:
          rem   play, 1=paused
          rem systemFlags - Bit 4 (SystemFlagGameStatePaused): 0=normal
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
          rem   - Resets gameMode to ModePublisherPrelude
          rem   - Calls ChangeGameMode to transition to startup sequence
          rem ==========================================================
WarmStart
          rem Handles game reset from any screen/state
          rem Input: None (called from MainLoop on RESET)
          rem Output: gameMode set to ModePublisherPrelude, ChangeGameMode called, TIA registers initialized
          rem Mutates: systemFlags (paused flag cleared), frame (reset to 0), gameMode (set to ModePublisherPrelude),
          rem         COLUBK, COLUPF, COLUP0, _COLUP1 (TIA color registers),
          rem         AUDC0, AUDV0, AUDC1, AUDV1 (TIA audio registers),
          rem         pf0-pf5 (playfield registers), ENAM0, ENAM1, ENABL (sprite enable registers)
          rem Called Routines: ChangeGameMode (bank14) - accesses game mode state
          rem Constraints: Entry point for warm start/reset (called from MainLoop)
          rem Step 1: Clear critical game state variables
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
          rem Clear paused flag (0 = normal, not paused, not ending)
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
          let gameMode = ModePublisherPrelude
          gosub ChangeGameMode bank14
          
          rem Reset complete - return to MainLoop which will dispatch to
          rem   new mode
          return

          rem Main console switch handler
          rem NOTE: RESET is now handled in MainLoop via centralized
          rem   WarmStart call
          rem This function only handles pause/select switches
HandleConsoleSwitches
          rem Handle console switches during gameplay (pause/select, Color/B&W, 7800 pause)
          rem Input: switchselect (hardware) = Game Select switch state
          rem        switchbw (hardware) = Color/B&W switch state
          rem        systemFlags (global) = system flags (SystemFlagGameStatePaused)
          rem        temp2 (parameter) = player index for CheckEnhancedPause (0 or 1)
          rem Output: systemFlags updated (pause state toggled), DetectControllers called if Select pressed
          rem Mutates: systemFlags (pause state toggled), temp1, temp2 (passed to CheckEnhancedPause),
          rem         colorBWPrevious_W (updated via CheckColorBWToggle)
          rem Called Routines: CheckEnhancedPause - accesses controller state, temp2,
          rem   DetectControllers (bank14) - accesses controller detection state,
          rem   CheckColorBWToggle - accesses switchbw, colorBWPrevious_R,
          rem   Check7800PauseButton - accesses 7800 pause button state
          rem Constraints: Must be colocated with DonePlayer1Pause, Player1PauseDone,
          rem              DonePlayer2Pause, Player2PauseDone (all called via goto)

          rem Game Select switch or Joy2B+ Button III - toggle pause
          rem   mode
          let temp2 = 0 
          rem Check Player 1 buttons
          gosub CheckEnhancedPause
          if !temp1 then DonePlayer1Pause
          rem Re-detect controllers when Select is pressed
          gosub DetectControllers bank14
          if !(systemFlags & SystemFlagGameStatePaused) then let systemFlags = systemFlags | SystemFlagGameStatePaused:goto Player1PauseDone
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
Player1PauseDone
          rem Debounce - wait for button release (drawscreen called by MainLoop)
          return
DonePlayer1Pause
          
          
          let temp2 = 1 
          rem Check Player 2 buttons
          gosub CheckEnhancedPause
          if !temp1 then DonePlayer2Pause
          rem Re-detect controllers when Select is pressed
          gosub DetectControllers bank14
          if !(systemFlags & SystemFlagGameStatePaused) then let systemFlags = systemFlags | SystemFlagGameStatePaused
          if !(systemFlags & SystemFlagGameStatePaused) then Player2PauseDone
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
Player2PauseDone
          rem Debounce - wait for button release (drawscreen called by MainLoop)
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
          rem Re-detect controllers when Color/B&W switch is toggled
          rem Input: switchbw (hardware) = Color/B&W switch state
          rem        colorBWPrevious_R (global SCRAM) = previous Color/B&W switch state
          rem Output: colorBWPrevious_W updated, DetectControllers called if switch changed
          rem Mutates: temp1 (switch changed flag), temp6 (used for switchbw read),
          rem         colorBWPrevious_W (updated if switch changed)
          rem Called Routines: DetectControllers (bank14) - accesses controller detection state
          rem Constraints: Must be colocated with DoneSwitchChange (called via goto)
          dim CCBT_switchChanged = temp1
          dim CCBT_overrideChanged = temp2
          
          rem Check if Color/B&W switch state has changed
          temp6 = switchbw
          let CCBT_switchChanged = 0
          if temp6 = colorBWPrevious_R then DoneSwitchChange
          let CCBT_switchChanged = 1
          gosub DetectControllers bank14
          let colorBWPrevious_W = switchbw
DoneSwitchChange
          rem Color/B&W switch change check complete (label only, no execution)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with CheckColorBWToggle

          rem Check if colorBWOverride changed (7800 pause button)
          rem Note: colorBWOverride does not have a previous value stored,
          rem   so we check it every frame (NTSC/PAL only, not SECAM).
          rem   This is acceptable since it is only toggled by button press,
          rem   not continuously. If needed, we could add a previous value
          rem   variable.
          
          rem Reload arena colors if switch or override changed
          if CCBT_switchChanged then ReloadArenaColorsNow
          rem Note: colorBWOverride check handled in Check7800PauseButton
          rem   (NTSC/PAL only, not SECAM)
          
          return

ReloadArenaColorsNow
          rem Reload arena colors with current switch state
          gosub ReloadArenaColors bank14
          return

          rem Display paused screen
DisplayPausedScreen
          rem Display PAUSED message using built-in font system
          rem Center the text on screen
          temp1 = 40 
          rem X position (centered)
          temp2 = 45 
          rem Y position (middle of screen)
          temp3 = 14 
          rem Color (white)
          
          rem Draw each character of PAUSED
          rem P
          temp4 = 25 
          rem ASCII P
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem A
          temp4 = 10 
          rem ASCII A
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem U
          temp4 = 30 
          rem ASCII U
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem S
          temp4 = 28 
          rem ASCII S
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem E
          temp4 = 14 
          rem ASCII E
          gosub DrawCharacter
          temp1 = temp1 + 6
          
          rem D
          temp4 = 13 
          rem ASCII D
          rem tail call
          goto DrawCharacter
          

