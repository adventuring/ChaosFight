          rem ChaosFight - Source/Routines/ControllerDetection.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem CONTROLLER HARDWARE SUPPORT:
          rem - CX-40 Joystick: Standard 2600 joystick
          rem - Genesis 3-Button: Enhanced controller with Button C
          rem - Joy2b+ Enhanced: Enhanced controller with Buttons II/III
          rem - Quadtari 4-Player: Frame multiplexing for 4 players
          rem - Buttons II/III (Joy2b+) use paddle ports INPT0-3, require different reading
          rem Console and controller detection for 7800, Quadtari, Genesis, Joy2b+

          rem 7800 detection method based on Grizzards by Bruce-Robert Pocock
          rem Genesis detection method based on Grizzards by Bruce-Robert Pocock

          rem =================================================================
          rem CONSOLE DETECTION (7800 vs 2600)
          rem =================================================================
          rem Detect if running on Atari 7800 for enhanced features
          rem Method: Check magic bytes in $D0/$D1 set by BIOS
          
DetectConsole
          rem Atari 7800 BIOS sets $D0=$2C and $D1=$A9 when loading cartridge
          rem Check these before any other detection to avoid corrupting values
          
          rem Read memory locations $D0 and $D1 to check for 7800 BIOS signature
          rem Using inline assembly for direct zero-page memory access
          
          rem Temporarily disable 7800 detection due to inline asm issues
          Console7800Detected = 0
          
          rem Fall through to controller detection

          rem =================================================================
          rem CONTROLLER DETECTION
          rem =================================================================
          rem Re-detect controllers each time Game Select pressed or title reached
          rem Note: Genesis/Joy2b+ detection is contrary to Quadtari
          
DetectControllers
          rem Reset detection flags
          ControllerStatus = 0
#ifndef TV_SECAM
          ColorBWOverride = 0
          PauseButtonPrev = 0
#endif
          
          rem Check for Quadtari (4 joysticks via multiplexing)
          rem CANONICAL METHOD: Check INPT0-3 paddle ports for Quadtari signature
          rem Quadtari presents specific button patterns on paddle ports
          rem Left side: INPT0 LOW + INPT1 HIGH, or Right side: INPT2 LOW + INPT3 HIGH
          
          rem Check left side controllers (INPT0/INPT1)
          if INPT0{7} then goto CheckRightSide
          if !INPT1{7} then goto CheckRightSide
          goto QuadtariFound
CheckRightSide
          
          rem Check right side controllers (INPT2/INPT3) 
          if INPT2{7} then goto NoQuadtari
          if !INPT3{7} then goto NoQuadtari
          goto QuadtariFound
NoQuadtari
          
          rem Quadtari not detected
          ControllerStatus = ControllerStatus & ClearQuadtariDetected
          goto CheckGenesis

QuadtariFound
          ControllerStatus = ControllerStatus | SetQuadtariDetected
          return

CheckGenesis
          
          rem Check for Genesis controller
          rem Genesis controllers pull INPT0 and INPT1 HIGH when idle
          rem Method: Ground paddle ports via VBLANK, wait a frame, check levels
          
          rem First check for Quadtari (takes priority over multi-button controllers)
          gosub DetectQuadtari
          if QuadtariDetected then return
          
          rem Detect Genesis/MegaDrive controllers using correct method
          gosub DetectGenesisControllers
          
          rem Detect Joy2b+ controllers (if no Genesis detected)
          gosub DetectJoy2bPlusControllers
          
          return

          rem =================================================================
          rem GENESIS/MEGADRIVE CONTROLLER DETECTION
          rem =================================================================
          rem Based on DetectGenesis.s - correct implementation
DetectGenesisControllers
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
          if !INPT0{7} then goto NoGenesisLeft
          if !INPT1{7} then goto NoGenesisLeft
          
          rem Genesis detected on left port
          ControllerStatus = ControllerStatus | SetLeftPortGenesis
          rem Set LeftPortGenesis bit
          
NoGenesisLeft
          rem Check INPT2 - Genesis controllers pull HIGH when idle  
          if !INPT2{7} then goto NoGenesisRight
          if !INPT3{7} then goto NoGenesisRight
          
          rem Genesis detected on right port
          ControllerStatus = ControllerStatus | SetRightPortGenesis
          rem Set RightPortGenesis bit
          
NoGenesisRight
          return

          rem =================================================================
          rem JOY2BPLUS CONTROLLER DETECTION  
          rem =================================================================
DetectJoy2bPlusControllers
          rem Joy2b+ controllers pull all three paddle ports HIGH when idle
          rem Check left port (INPT0, INPT1, INPT4)
          if !INPT0{7} then goto NoJoy2bPlusLeft
          if !INPT1{7} then goto NoJoy2bPlusLeft
          if !INPT4{7} then goto NoJoy2bPlusLeft
          
          rem Joy2b+ detected on left port
          ControllerStatus = ControllerStatus | SetLeftPortJoy2bPlus
          rem Set LeftPortJoy2bPlus bit
          
NoJoy2bPlusLeft
          rem Check right port (INPT2, INPT3, INPT5)
          if !INPT2{7} then goto NoJoy2bPlusRight
          if !INPT3{7} then goto NoJoy2bPlusRight
          if !INPT5{7} then goto NoJoy2bPlusRight
          
          rem Joy2b+ detected on right port
          ControllerStatus = ControllerStatus | SetRightPortJoy2bPlus
          rem Set RightPortJoy2bPlus bit
          
NoJoy2bPlusRight
          return

          rem =================================================================
          rem GENESIS/MEGADRIVE CONTROLLER DETECTION
          rem =================================================================
          rem Based on DetectGenesis.s - correct implementation
DetectGenesisControllers
          rem Ground paddle ports (INPT0-3) using VBLANK
          VBLANK = VBlankGroundINPT0123
          
          rem Wait one frame for discharge
          drawscreen
          
          rem Wait for next frame top
          drawscreen
          
          rem Check INPT0 - Genesis pulls HIGH when idle
          if !INPT0{7} then goto NoLeftGenesis
          
          rem Check INPT1 - Genesis pulls HIGH when idle  
          if !INPT1{7} then goto NoLeftGenesis
          
          rem Genesis detected on left port
          ControllerStatus = ControllerStatus | SetLeftPortGenesis
          goto CheckRightGenesis
          
NoLeftGenesis
          rem Check right port (INPT2/INPT3) for Genesis
          if !INPT2{7} then goto NoRightGenesis
          if !INPT3{7} then goto NoRightGenesis
          
          rem Genesis detected on right port
          ControllerStatus = ControllerStatus | SetRightPortGenesis
          goto GenesisDetectionComplete
          
NoRightGenesis
GenesisDetectionComplete
          rem Restore normal VBLANK
          VBLANK = $00
          return

          rem =================================================================
          rem JOY2BPLUS CONTROLLER DETECTION  
          rem =================================================================
DetectJoy2bPlusControllers
          rem Only check if no Genesis controllers detected
          if LeftPortGenesis then return
          if RightPortGenesis then return
          
          rem Ground paddle ports again for Joy2b+ detection
          VBLANK = VBlankGroundINPT0123
          drawscreen
          drawscreen
          
          rem Check left port for Joy2b+ (INPT0, INPT1, INPT4)
          if !INPT0{7} then goto CheckRightJoy2bPlus
          if !INPT1{7} then goto CheckRightJoy2bPlus
          if !INPT4{7} then goto CheckRightJoy2bPlus
          
          rem Joy2b+ detected on left port
          ControllerStatus = ControllerStatus | SetLeftPortJoy2bPlus
          goto Joy2bPlusDetectionComplete
          
CheckRightJoy2bPlus
          rem Check right port for Joy2b+ (INPT2, INPT3, INPT5)
          if !INPT2{7} then goto Joy2bPlusDetectionComplete
          if !INPT3{7} then goto Joy2bPlusDetectionComplete
          if !INPT5{7} then goto Joy2bPlusDetectionComplete
          
          rem Joy2b+ detected on right port
          ControllerStatus = ControllerStatus | SetRightPortJoy2bPlus
          
Joy2bPlusDetectionComplete
          rem Restore normal VBLANK
          VBLANK = $00
          return

          rem =================================================================
          rem 7800 PAUSE BUTTON HANDLER
          rem =================================================================
          rem On Atari 7800, Pause button toggles Color/B&W override
          rem This allows players to switch between color and B&W without
          rem flipping the physical switch on the console
          
Check7800PauseButton
          rem Only process if running on 7800
          if !Console7800Detected then return
          
          rem 7800 Pause button detection via Color/B&W switch
          rem On 7800, Color/B&W switch becomes momentary pause button
          
#ifndef TV_SECAM
          rem Check if pause button just pressed (use switchbw for Color/B&W switch)
          if switchbw then PauseNotPressed
          
          rem Button is pressed (low)
          if !PauseButtonPrev then return
          
          rem Button just pressed! Toggle Color/B&W override
          PauseButtonPrev = 0
          ColorBWOverride = ColorBWOverride ^ 1 
          rem XOR to toggle 0<->1
          
          return
#endif

          rem =================================================================
          rem QUADTARI MULTIPLEXING
          rem =================================================================
          rem Handle frame-based controller multiplexing for 4 players
          
UpdateQuadtariInputs
          rem Only run if Quadtari detected
          if !QuadtariDetected then return
          
          rem Alternate between reading players 1-2 and players 3-4
          rem Use qtcontroller to determine which pair to read
          if qtcontroller then goto ReadPlayers34
          goto ReadPlayers12

ReadPlayers12
          rem Even frames: read players 1 & 2
          rem joy0 and joy1 automatically read from physical ports
          rem Quadtari multiplexing handled by hardware
          rem No additional processing needed - joy0/joy1 are already correct
          return

ReadPlayers34
          rem Odd frames: read players 3 & 4  
          rem joy0 and joy1 now read players 3 & 4 via Quadtari multiplexing
          rem Hardware automatically switches which players are active
          rem No additional processing needed - joy0/joy1 are already correct
          return

PauseNotPressed
          rem Button not pressed, update previous state
          PauseButtonPrev = 1
          return

