WarmStart
          rem
          rem ChaosFight - Source/Routines/ConsoleHandling.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Console Switch Handling
          rem Handles Atari 2600 console switches during gameplay.
          rem SWITCHES:
          rem   switchreset - Game Reset → return to publisher prelude
          rem   switchselect - Game Select → toggle pause
          rem   switchbw - Color/B&W → handled in rendering
          rem
          rem AVAILABLE VARIABLES:
          rem   play, 1=paused
          rem systemFlags - Bit 4 (SystemFlagGameStatePaused): 0=normal
          rem Warm Start / Reset Handler
          rem
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
          rem Handles game reset from any screen/state
          rem
          rem Input: None (called from MainLoop on RESET)
          rem
          rem Output: gameMode set to ModePublisherPrelude,
          rem ChangeGameMode called, TIA registers initialized
          rem
          rem Mutates: systemFlags (paused flag cleared), frame (reset
          rem to 0), gameMode (set to ModePublisherPrelude),
          rem         COLUBK, COLUPF, COLUP0, _COLUP1 (TIA color
          rem         registers),
          rem         AUDC0, AUDV0, AUDC1, AUDV1 (TIA audio registers),
          rem         ENAM0, ENAM1, ENABL (sprite enable registers)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          rem
          rem Constraints: Entry point for warm start/reset (called from
          rem MainLoop)
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused : rem Step 1: Clear critical game state variables
          rem Clear paused flag (0 = normal, not paused, not ending)
          rem Frame counter is automatically managed by batariBASIC
          rem kernel
          
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
          
          rem Step 4: Clear sprite enable registers
          ENAM0 = 0
          ENAM1 = 0
          ENABL = 0
          
          let gameMode = ModePublisherPrelude : rem Step 5: Reset game mode to startup sequence
          gosub ChangeGameMode bank14
          
          return
          rem Reset complete - return to MainLoop which will dispatch to
          rem   new mode

HandleConsoleSwitches
          rem Main console switch handler
          rem NOTE: RESET is now handled in MainLoop via centralized
          rem   WarmStart call
          rem This function only handles pause/select switches
          rem Handle console switches during gameplay (pause/select,
          rem Color/B&W, 7800 pause)
          rem
          rem Input: switchselect (hardware) = Game Select switch state
          rem        switchbw (hardware) = Color/B&W switch state
          rem        systemFlags (global) = system flags
          rem        (SystemFlagGameStatePaused)
          rem        temp2 (parameter) = player index for
          rem        CheckEnhancedPause (0 or 1)
          rem
          rem Output: systemFlags updated (pause state toggled),
          rem DetectControllers called if Select pressed
          rem
          rem Mutates: systemFlags (pause state toggled), temp1, temp2
          rem (passed to CheckEnhancedPause),
          rem         colorBWPrevious_W (updated via CheckColorBWToggle)
          rem
          rem Called Routines: CheckEnhancedPause - accesses controller
          rem state, temp2,
          rem   DetectControllers (bank14) - accesses controller
          rem   detection state,
          rem   CheckColorBWToggle - accesses switchbw,
          rem   colorBWPrevious_R,
          rem   Check7800PauseButton - accesses 7800 pause button state
          rem
          rem Constraints: Must be colocated with DonePlayer1Pause,
          rem Player1PauseDone,
          rem              DonePlayer2Pause, Player2PauseDone (all
          rem              called via goto)

          rem Game Select switch or Joy2B+ Button III - toggle pause
          let temp2 = 0 : rem   mode
          gosub CheckEnhancedPause : rem Check Player 1 buttons
          if !temp1 then DonePlayer1Pause
          gosub DetectControllers bank14 : rem Re-detect controllers when Select is pressed
          if !(systemFlags & SystemFlagGameStatePaused) then let systemFlags = systemFlags | SystemFlagGameStatePaused:goto Player1PauseDone
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
Player1PauseDone
          rem Debounce - wait for button release (drawscreen called by
          rem MainLoop)
          return
DonePlayer1Pause
          
          
          let temp2 = 1 
          gosub CheckEnhancedPause : rem Check Player 2 buttons
          if !temp1 then DonePlayer2Pause
          gosub DetectControllers bank14 : rem Re-detect controllers when Select is pressed
          if !(systemFlags & SystemFlagGameStatePaused) then let systemFlags = systemFlags | SystemFlagGameStatePaused
          if !(systemFlags & SystemFlagGameStatePaused) then Player2PauseDone
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
Player2PauseDone
          rem Debounce - wait for button release (drawscreen called by
          rem MainLoop)
          return
DonePlayer2Pause
          

          gosub CheckColorBWToggle : rem Color/B&W switch - re-detect controllers when toggled
          
#ifndef TV_SECAM
          rem 7800 Pause button - toggle Color/B&W mode (not in SECAM)
          goto Check7800PauseButton : rem tail call
#endif

          return

          rem
          rem Color/B&W switch change detection (triggers controller re-detect)
          
CheckColorBWToggle
          rem Check switch state and trigger DetectControllers when it flips
          rem
          rem Input: switchbw (hardware) = Color/B&W switch state
          rem        colorBWPrevious_R (global SCRAM) = previous
          rem        Color/B&W switch state
          rem
          rem Output: colorBWPrevious_W updated, DetectControllers
          rem called if switch changed
          rem
          rem Mutates: temp1 (switch changed flag), temp6 (used for
          rem switchbw read),
          rem         colorBWPrevious_W (updated if switch changed)
          rem
          rem Called Routines: DetectControllers (bank14) - accesses
          rem controller detection state
          rem Constraints: Must be colocated with DoneSwitchChange (called via goto)
          
          rem Check if Color/B&W switch state has changed
          temp6 = switchbw
          let temp1 = 0
          if temp6 = colorBWPrevious_R then DoneSwitchChange
          let temp1 = 1
          gosub DetectControllers bank14
          let colorBWPrevious_W = switchbw
DoneSwitchChange
          rem Color/B&W switch change check complete (label only, no
          rem execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CheckColorBWToggle

          rem Check if colorBWOverride changed (7800 pause button)
          rem Note: colorBWOverride does not have a previous value
          rem stored,
          rem   so we check it every frame (NTSC/PAL only, not SECAM).
          rem   This is acceptable since it is only toggled by button
          rem   press,
          rem   not continuously. If needed, we could add a previous
          rem   value
          rem   variable.
          
          if temp1 then ReloadArenaColorsNow : rem Reload arena colors if switch or override changed
          rem Note: colorBWOverride check handled in
          rem Check7800PauseButton
          rem   (NTSC/PAL only, not SECAM)
          
          return

ReloadArenaColorsNow
          gosub ReloadArenaColors bank14 : rem Reload arena colors with current switch state
          return

DisplayPausedScreen
          rem Display paused screen
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
          gosub DrawCharacter : rem ASCII P
          temp1 = temp1 + 6
          
          rem A
          temp4 = 10 
          gosub DrawCharacter : rem ASCII A
          temp1 = temp1 + 6
          
          rem U
          temp4 = 30 
          gosub DrawCharacter : rem ASCII U
          temp1 = temp1 + 6
          
          rem S
          temp4 = 28 
          gosub DrawCharacter : rem ASCII S
          temp1 = temp1 + 6
          
          rem E
          temp4 = 14 
          gosub DrawCharacter : rem ASCII E
          temp1 = temp1 + 6
          
          rem D
          temp4 = 13 
          rem ASCII D
          goto DrawCharacter : rem tail call
          

