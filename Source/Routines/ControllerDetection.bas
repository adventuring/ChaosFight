          rem ControllerDetection.bas - Console and controller detection

CtrlDetConsole
          rem Console detection (7800 vs 2600) - calls ConsoleDetHW
          gosub ConsoleDetHW

          rem
          rem Fall through to controller detection

DetectPads
          asm
DetectPads
end
          rem Re-detect controllers (monotonic upgrade only)
          rem Public entry point used by console handling and character select flows
          rem Input: controllerStatus (global) = existing capabilities, INPT0-5 = paddle port states
          rem Output: controllerStatus updated with any newly detected capabilities
          rem Constraints: Upgrades only – never clears previously detected hardware
          let temp1 = controllerStatus
          let temp2 = 0
#ifndef TV_SECAM
          let systemFlags = systemFlags & ClearSystemFlagColorBWOverride
          let systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev
#endif
          rem Check for Quadtari
          if INPT0{7} then CDP_CheckRightSide
          if !INPT1{7} then CDP_CheckRightSide
          goto CDP_QuadtariFound
CDP_CheckRightSide
          if INPT2{7} then goto CDP_CheckGenesis
          if !INPT3{7} then goto CDP_CheckGenesis
          rem fall through to CDP_QuadtariFound

CDP_QuadtariFound
          let temp2 = temp2 | SetQuadtariDetected
          goto CDP_MergeStatus

CDP_CheckGenesis
          rem Check for Genesis controller (only if Quadtari not already
          rem   detected)
          rem If Quadtari was previously detected, skip all other
          rem detection
          if temp1 & SetQuadtariDetected then CDP_MergeStatus

          rem Genesis controllers pull INPT0 and INPT1 HIGH when idle
          rem Method: Ground paddle ports via VBLANK, wait a frame,
          rem   check levels
          gosub CDP_DetectGenesis
          rem Detect Genesis/MegaDrive controllers using correct method

          rem Detect Joy2b+ controllers (if no Genesis detected)
          rem Skip Joy2B+ detection if Genesis already exists (existing
          rem or newly detected)
          if temp1 & SetLeftPortGenesis then CDP_MergeStatus
          if temp1 & SetRightPortGenesis then CDP_MergeStatus
          if temp2 & SetLeftPortGenesis then CDP_MergeStatus
          if temp2 & SetRightPortGenesis then CDP_MergeStatus
          gosub CDP_DetectJoy2bPlus

CDP_MergeStatus
          rem Merge new detections with existing capabilities (monotonic
          rem   upgrade)
          rem OR new status with existing - this ensures upgrades only,
          let controllerStatus = temp1 | temp2
          rem   never downgrades

          return otherbank

CDP_DetectGenesis
          asm
CDP_DetectGenesis

end
          rem
          rem Genesis Detection Subroutine
          rem Detect Genesis/MegaDrive controllers by grounding paddle
          rem ports and checking levels
          rem
          rem Input: temp2 (temp2) = new detection status,
          rem INPT0-3 (hardware registers) = paddle port states, VBLANK
          rem (TIA register) = vertical blank register
          rem
          rem Output: temp2 (temp2) = updated with Genesis
          rem detection flags (SetLeftPortGenesis, SetRightPortGenesis)
          rem
          rem Mutates: temp2 (temp2 updated), VBLANK (TIA
          rem register) = temporarily set to ground ports, drawscreen
          rem called multiple times
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must ground ports via VBLANK and wait
          rem multiple frames for proper detection
          rem Ground paddle ports (INPT0-3) during VBLANK
          VBLANK = VBlankGroundINPT0123

          rem Wait for screen top (equivalent to .WaitScreenTop)
          drawscreen

          rem Wait for screen bottom (equivalent to .WaitScreenBottom)
          drawscreen

          rem Wait for screen top again (equivalent to .WaitScreenTop)
          drawscreen

          rem Restore normal VBLANK
          VBLANK = $00

          rem Check INPT0 - Genesis controllers pull HIGH when idle

          if !INPT0{7} then CDP_NoGenesisLeft
          if !INPT1{7} then CDP_NoGenesisLeft

          let temp2 = temp2 | SetLeftPortGenesis
          rem Genesis detected on left port
          rem Set LeftPortGenesis bit

CDP_NoGenesisLeft
          rem Check INPT2 - Genesis controllers pull HIGH when idle
          if !INPT2{7} then CDP_NoGenesisRight
          if !INPT3{7} then CDP_NoGenesisRight

          let temp2 = temp2 | SetRightPortGenesis
          rem Genesis detected on right port
          rem Set RightPortGenesis bit

CDP_NoGenesisRight
          return otherbank

CDP_DetectJoy2bPlus
          asm
CDP_DetectJoy2bPlus

end
          rem
          rem Joy2bplus Detection Subroutine
          rem Detect Joy2b+ enhanced controllers by checking paddle port
          rem states
          rem
          rem Input: temp1 (temp1) = existing controller
          rem status, temp2 (temp2) = new detection status,
          rem INPT0-5 (hardware registers) = paddle port states
          rem
          rem Output: temp2 (temp2) = updated with Joy2b+
          rem detection flags (SetLeftPortJoy2bPlus,
          rem SetRightPortJoy2bPlus)
          rem
          rem Mutates: temp2 (temp2 updated)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only checks if no Genesis controllers
          rem detected (redundant check for safety)
          rem Only check if no Genesis controllers detected (existing or
          rem   newly detected)
          rem This check is redundant since caller already checks, but
          rem kept for safety
          if temp1 & SetLeftPortGenesis then return
          if temp1 & SetRightPortGenesis then return
          if temp2 & SetLeftPortGenesis then return
          if temp2 & SetRightPortGenesis then return

          rem Joy2b+ controllers pull all three paddle ports HIGH when
          rem   idle
          rem Check left port (INPT0, INPT1, INPT4)
          if !INPT0{7} then CDP_NoJoy2Left
          if !INPT1{7} then CDP_NoJoy2Left
          if !INPT4{7} then CDP_NoJoy2Left

          let temp2 = temp2 | SetLeftPortJoy2bPlus
          rem Joy2b+ detected on left port
          rem Set LeftPortJoy2bPlus bit

CDP_NoJoy2Left
          rem Check right port (INPT2, INPT3, INPT5)
          if !INPT2{7} then CDP_NoJoy2Right
          if !INPT3{7} then CDP_NoJoy2Right
          if !INPT5{7} then CDP_NoJoy2Right

          let temp2 = temp2 | SetRightPortJoy2bPlus
          rem Joy2b+ detected on right port
          rem Set RightPortJoy2bPlus bit

CDP_NoJoy2Right
          return otherbank


          rem
          rem 7800 Pause Button Handler
          rem On Atari 7800, Pause button toggles Color/B&W override
          rem This allows players to switch between color and B&W
          rem   without
          rem flipping the physical switch on the console

Check7800Pause
          asm
Check7800Pause
end
          rem Handle 7800 pause button (toggles Color/B&W override on
          rem 7800 console)
          rem
          rem Input: systemFlags (global) = system flags (bit 7 =
          rem SystemFlag7800, bit 6 = SystemFlagColorBWOverride, bit 5 =
          rem SystemFlagPauseButtonPrev), switchbw (global) = Color/B&W
          rem switch state
          rem
          rem Output: systemFlags (global) = updated with
          rem ColorBWOverride toggled, arena colors reloaded
          rem
          rem Mutates: systemFlags (global) = system flags
          rem
          rem Called Routines: ReloadArenaColors (bank14) - reloads
          rem arena colors after override change
          rem
          rem Constraints: Only processes on 7800 console
          rem (SystemFlag7800 set), not available on SECAM
          rem Only process if running on 7800 (bit 7 of systemFlags)
          if (systemFlags & SystemFlag7800) = 0 then return

          rem 7800 Pause button detection via Color/B&W switch
          rem On 7800, Color/B&W switch becomes momentary pause button

#ifndef TV_SECAM
          rem Check if pause button just pressed (use switchbw for Color/B&W switch)
          if switchbw then PauseNotPressed

          rem Button is pressed (low)
          if (systemFlags & SystemFlagPauseButtonPrev) = 0 then return

          rem Button just pressed! Toggle Color/B&W override (bit 6)
          let systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev
          if systemFlags & SystemFlagColorBWOverride then let systemFlags = systemFlags & ClearSystemFlagColorBWOverride : goto ToggleBWDone
          let systemFlags = systemFlags | SystemFlagColorBWOverride
ToggleBWDone
          rem XOR to toggle 0<->1 (done via if/else above)

          rem Reload arena colors with new override state
          gosub ReloadArenaColors bank14
#endif

          return otherbank

          rem
          rem Quadtari Multiplexing
          rem Handle frame-based controller multiplexing for 4 players

UpdateQuadIn
          rem Handle Quadtari frame-based controller multiplexing for 4
          rem players
          rem
          rem Input: QuadtariDetected (global) = Quadtari detection
          rem flag, qtcontroller (global) = multiplexing state (0=P1/P2,
          rem 1=P3/P4)
          rem
          rem Output: Controller input read for appropriate player pair
          rem
          rem Mutates: None (Quadtari hardware handles multiplexing
          rem automatically)
          rem
          rem Called Routines: ReadPlayers12 (if even frame),
          rem ReadPlayers34 (if odd frame)
          rem
          rem Constraints: Only runs if Quadtari detected
          rem Only run if Quadtari detected
          if !QuadtariDetected then return

          rem Alternate between reading players 1-2 and players 3-4
          rem Use qtcontroller to determine which pair to read
          if qtcontroller then ReadPlayers34
          rem fall through to ReadPlayers12

ReadPlayers12
          return otherbank
          rem Read players 1 & 2 (even frames, qtcontroller=0)
          rem
          rem Input: qtcontroller (global) = multiplexing state (0 for
          rem P1/P2)
          rem
          rem Output: joy0, joy1 (hardware registers) = player 1 & 2
          rem input
          rem
          rem Mutates: None (Quadtari hardware handles multiplexing
          rem automatically)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only called when qtcontroller=0
          rem Even frames: read players 1 & 2
          rem joy0 and joy1 automatically read from physical ports
          rem Quadtari multiplexing handled by hardware
          rem No additional processing needed - joy0/joy1 are already
          rem   correct

ReadPlayers34
          return otherbank
          rem Read players 3 & 4 (odd frames, qtcontroller=1)
          rem
          rem Input: qtcontroller (global) = multiplexing state (1 for
          rem P3/P4)
          rem
          rem Output: joy0, joy1 (hardware registers) = player 3 & 4
          rem input
          rem
          rem Mutates: None (Quadtari hardware handles multiplexing
          rem automatically)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only called when qtcontroller=1
          rem Odd frames: read players 3 & 4
          rem joy0 and joy1 now read players 3 & 4 via Quadtari
          rem   multiplexing
          rem Hardware automatically switches which players are active
          rem No additional processing needed - joy0/joy1 are already
          rem   correct

PauseNotPressed
          let systemFlags = systemFlags | SystemFlagPauseButtonPrev
          rem Button not pressed, update previous state (set bit 5)
          return otherbank


