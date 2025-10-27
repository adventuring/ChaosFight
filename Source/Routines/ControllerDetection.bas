          rem ChaosFight - Source/Routines/ControllerDetection.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Controller detection for Quadtari, Genesis, Joy2b+

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
          
          rem Check for Quadtari (4 joysticks via multiplexing)
          rem Read INPT4 and INPT5 multiple times across frames
          rem If patterns indicate multiplexing, Quadtari is present
          temp1 = INPT4
          temp2 = INPT5
          
          rem Wait one frame
          drawscreen
          
          temp3 = INPT4
          temp4 = INPT5
          
          rem If values changed without button press, likely Quadtari
          if temp1 != temp3 || temp2 != temp4 then
            QuadtariDetected = 1
            return
          endif
          
          rem Check for Genesis controller (6-button detection)
          rem Genesis controllers have extra buttons on INPT1
          temp1 = INPT1
          if temp1 & $40 then
            rem Genesis controller detected
            GenesisDetected = 1
            return
          endif
          
          rem Check for Joy2b+ (Sega Master System style)
          rem Joy2b+ uses both fire buttons
          temp1 = INPT4
          temp2 = SWCHA
          if temp1 & $80 then
            rem Could be Joy2b+
            Joy2bPlusDetected = 1
            return
          endif
          
          rem Default to standard 2 joysticks
          return

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

