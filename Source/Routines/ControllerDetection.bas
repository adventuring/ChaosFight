          rem ChaosFight - Source/Routines/ControllerDetection.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem CONTROLLER HARDWARE SUPPORT:
          rem - CX-40 Joystick: SWCHA bits 4-7 (P1) / 0-3 (P2), INPT4/5 fire
          rem - Genesis 3-Button: D-pad via SWCHA, Button B via INPT4/5, Button C via TH line
          rem - Joy2B+ Enhanced: D-pad via SWCHA, Button I via INPT4/5, Buttons II/III via INPT0-3
          rem - Quadtari 4-Player: Frame multiplexing (even=P1/P2, odd=P3/P4)
          rem - Button C (Genesis) requires SWACNT toggling for TH line access
          rem - Buttons II/III (Joy2B+) use paddle ports INPT0-3, require different reading
          rem Console and controller detection for 7800, Quadtari, Genesis, Joy2b+
          rem
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
          
          asm
          lda $D0
          cmp #$2C
          bne Not7800
          lda $D1
          cmp #$A9
          bne Not7800
          lda #1
          sta Console7800Detected
          jmp Done7800Check
Not7800:
          lda #0
          sta Console7800Detected
Done7800Check:
          end
          
          rem Fall through to controller detection

          rem =================================================================
          rem CONTROLLER DETECTION
          rem =================================================================
          rem Re-detect controllers each time Game Select pressed or title reached
          rem Note: Genesis/Joy2b+ detection is contrary to Quadtari
          
DetectControllers
          rem Reset detection flags
          QuadtariDetected = 0
          GenesisDetected = 0
          Joy2bPlusDetected = 0
#ifndef TV_SECAM
          ColorBWOverride = 0
          PauseButtonPrev = 0
#endif
          
          rem Check for Quadtari (4 joysticks via multiplexing)
          rem CANONICAL METHOD: Check INPT0-3 paddle ports for Quadtari signature
          rem Quadtari presents specific button patterns on paddle ports
          rem Left side: INPT0 LOW + INPT1 HIGH, or Right side: INPT2 LOW + INPT3 HIGH
          
          rem Check left side controllers (INPT0/INPT1)
          if !INPT0{7} && INPT1{7} then
            QuadtariDetected = 1
            return
          endif
          
          rem Check right side controllers (INPT2/INPT3) 
          if !INPT2{7} && INPT3{7} then
            QuadtariDetected = 1
            return
          endif
          
          rem Quadtari not detected
          QuadtariDetected = 0
          
          rem Check for Genesis controller
          rem Genesis controllers pull INPT0 and INPT1 HIGH when idle
          rem Method: Ground paddle ports via VBLANK, wait a frame, check levels
          
          rem Ground paddle ports (INPT0-3)
          VBLANK = $C0  : rem Enable VBLANK with paddle ground enabled
          
          rem Wait one frame for discharge
          drawscreen
          
          rem Restore normal VBLANK
          VBLANK = $00
          
          rem Check if INPT0 and INPT1 are both HIGH (Genesis signature)
          temp1 = INPT0
          temp2 = INPT1
          
          rem If both INPT0 and INPT1 have bit 7 set, Genesis detected
          if temp1 & $80 && temp2 & $80 then
            rem Genesis controller detected on Port 1
            GenesisDetected = 1
            return
          endif
          
          rem Check for Joy2b+ 
          rem Joy2b+ pulls INPT0, INPT1, and INPT2 HIGH when idle
          rem Similar detection but all three ports must be HIGH
          temp3 = INPT2
          
          if temp1 & $80 && temp2 & $80 && temp3 & $80 then
            rem Joy2b+ controller detected
            Joy2bPlusDetected = 1
            return
          endif
          
          rem Default to standard 2 joysticks
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
          
          rem Read Pause button state from INPT6 (bit 7)
          rem 0 = pressed, 1 = not pressed
          temp1 = INPT6
          
#ifndef TV_SECAM
          rem Check if button just pressed (was high, now low)
          if temp1 & $80 then
            rem Button not pressed, update previous state
            PauseButtonPrev = 1
            return
          endif
          
          rem Button is pressed (low)
          if !PauseButtonPrev then
            rem Button was already pressed last frame, ignore
            return
          endif
          
          rem Button just pressed! Toggle Color/B&W override
          PauseButtonPrev = 0
          ColorBWOverride = ColorBWOverride ^ 1  : rem XOR to toggle 0<->1
          
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
          rem Use frame counter to determine which pair to read
          if FrameCounter & 1 then
            rem Odd frames: read players 1 & 2
            rem joy0 and joy1 are automatically handled
            rem Clear player 3 & 4 inputs
            joy2left = 0
            joy2right = 0
            joy2up = 0
            joy2down = 0
            joy2fire = 0
            joy3left = 0
            joy3right = 0
            joy3up = 0
            joy3down = 0
            joy3fire = 0
          else
            rem Even frames: read players 3 & 4
            rem Map SWCHA bits to joy2 and joy3
            rem SWCHA format: P0right P0left P0down P0up P1right P1left P1down P1up
            temp1 = SWCHA
            
            rem Player 3 (mapped from P0 bits)
            if temp1 & $80 then joy2right = 0 else joy2right = 1
            if temp1 & $40 then joy2left = 0 else joy2left = 1
            if temp1 & $20 then joy2down = 0 else joy2down = 1
            if temp1 & $10 then joy2up = 0 else joy2up = 1
            
            rem Player 4 (mapped from P1 bits)
            if temp1 & $08 then joy3right = 0 else joy3right = 1
            if temp1 & $04 then joy3left = 0 else joy3left = 1
            if temp1 & $02 then joy3down = 0 else joy3down = 1
            if temp1 & $01 then joy3up = 0 else joy3up = 1
            
            rem Fire buttons
            if INPT4 & $80 then joy2fire = 0 else joy2fire = 1
            if INPT5 & $80 then joy3fire = 0 else joy3fire = 1
          endif
          
          return

