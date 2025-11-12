          rem ConsoleHandling.bas - Console switch handling
WarmStart
          rem Warm Start / Reset Handler
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
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
          rem Step 1: Clear critical game state variables
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

          let gameMode = ModePublisherPrelude
          rem Step 5: Reset game mode to startup sequence
          gosub ChangeGameMode bank14

          return
          rem Reset complete - return to MainLoop which will dispatch to
          rem   new mode

HandleConsoleSwitches
          rem Main console switch handler

          rem Game Select switch or Joy2B+ Button III - toggle pause
          let temp2 = 0
          rem   mode
          gosub CheckEnhancedPause
          rem Check Player 1 buttons
          if !temp1 then DonePlayer1Pause
          gosub CtrlDetPads bank14
          rem Re-detect controllers when Select is pressed
          if (systemFlags & SystemFlagGameStatePaused) = 0 then let systemFlags = systemFlags | SystemFlagGameStatePaused:goto Player1PauseDone
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
Player1PauseDone
          rem Debounce - wait for button release (drawscreen called by
          rem MainLoop)
          return
DonePlayer1Pause


          let temp2 = 1
          gosub CheckEnhancedPause
          rem Check Player 2 buttons
          if !temp1 then DonePlayer2Pause
          gosub CtrlDetPads bank14
          rem Re-detect controllers when Select is pressed
          if (systemFlags & SystemFlagGameStatePaused) = 0 then let systemFlags = systemFlags | SystemFlagGameStatePaused : goto Player2PauseDone
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused
Player2PauseDone
          rem Debounce - wait for button release (drawscreen called by
          rem MainLoop)
          return
DonePlayer2Pause


          gosub CheckColorBWToggle
          rem Color/B&W switch - re-detect controllers when toggled

#ifndef TV_SECAM
          rem 7800 Pause button - toggle Color/B&W mode (not in SECAM)
          goto Check7800Pause bank14
          rem tail call
#endif

          return

CheckEnhancedPause
          rem Check if pause buttons are pressed (console Game Select switch or enhanced controller buttons)
          rem Game Select switch (always) + Joy2B+ Button III (INPT1/INPT3) or Genesis Button C (INPT0/INPT2)
          rem
          rem Input: temp2 = player index (0=Player 1, 1=Player 2)
          rem        controllerStatus (global) = controller capabilities
          rem        switchselect (hardware) = Game Select switch
          rem        INPT0-3 (hardware) = paddle port states
          rem
          rem Output: temp1 = 1 if any pause button pressed, 0 otherwise
          rem
          rem Mutates: temp1
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp1 = 0
          rem Default to no pause button pressed

          rem Always check Game Select switch first (works with any controller)
          if switchselect then let temp1 = 1 : return

          rem Then check enhanced pause buttons for the specified player
          rem Joy2B+ Button III uses different registers than Button II/C

          if temp2 = 0 then goto CEP_CheckPlayer1
          if temp2 = 1 then goto CEP_CheckPlayer2
          return

CEP_CheckPlayer1
          rem Player 1: Check Genesis Button C (INPT0) or Joy2B+ Button III (INPT1)
          if controllerStatus & SetLeftPortGenesis then if !INPT0{7} then let temp1 = 1
          if controllerStatus & SetLeftPortJoy2bPlus then if !INPT1{7} then let temp1 = 1
          return

CEP_CheckPlayer2
          rem Player 2: Check Genesis Button C (INPT2) or Joy2B+ Button III (INPT3)
          if controllerStatus & SetRightPortGenesis then if (INPT2 & $80) = 0 then let temp1 = 1
          if controllerStatus & SetRightPortJoy2bPlus then if (INPT3 & $80) = 0 then let temp1 = 1
          return

          rem
          rem Color/B&W switch change detection (triggers controller re-detect)

CheckColorBWToggle
          rem Check switch state and trigger CtrlDetPads when it flips
          rem
          rem Input: switchbw (hardware) = Color/B&W switch state
          rem        colorBWPrevious_R (global SCRAM) = previous
          rem        Color/B&W switch state
          rem
          rem Output: colorBWPrevious_W updated, CtrlDetPads
          rem called if switch changed
          rem
          rem Mutates: temp1 (switch changed flag), temp6 (used for
          rem switchbw read),
          rem         colorBWPrevious_W (updated if switch changed)
          rem
          rem Called Routines: CtrlDetPads (bank14) - accesses
          rem controller detection state
          rem Constraints: Must be colocated with DoneSwitchChange (called via goto)

          rem Optimized: Check Color/B&W switch state change directly
          let temp6 = 0
          if switchbw then let temp6 = 1
          if temp6 = colorBWPrevious_R then DoneSwitchChange
          gosub CtrlDetPads bank14
          let colorBWPrevious_W = temp6
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

          rem Reload arena colors if switch or override changed

          if temp1 then ReloadArenaColorsNow
          rem Note: colorBWOverride check handled in
          rem Check7800PauseButton
          rem   (NTSC/PAL only, not SECAM)

          return

ReloadArenaColorsNow
          gosub ReloadArenaColors bank12
          rem Reload arena colors with current switch state
          return
