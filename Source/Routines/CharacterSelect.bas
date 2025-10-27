          rem ChaosFight - Source/Routines/CharacterSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CharacterSelect1
          rem Initialize character selections
          PlayerChar(0) = 0
          PlayerChar(1) = 0
          PlayerChar(2) = 0
          PlayerChar(3) = 0
          PlayerLocked(0) = 0
          PlayerLocked(1) = 0
          PlayerLocked(2) = 0
          PlayerLocked(3) = 0
          QuadtariDetected = 0

          rem Check for Quadtari adapter
          gosub DetectQuadtari

          COLUBK = ColBlue(8)

CharacterSelect1Loop
          rem Quadtari controller multiplexing:
          rem On even frames (QtController=0): handle controllers 0 and 1
          rem On odd frames (QtController=1): handle controllers 2 and 3 (if Quadtari detected)
          
          if QtController then goto HandleQuadtariControllers
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then PlayerChar(0) = PlayerChar(0) - 1 : if PlayerChar(0) < 0 then PlayerChar(0) = 15 : PlayerLocked(0) = 0
          if joy0right then PlayerChar(0) = PlayerChar(0) + 1 : if PlayerChar(0) > 15 then PlayerChar(0) = 0 : PlayerLocked(0) = 0
          if joy0up then PlayerLocked(0) = 0  : rem Unlock by moving up
          if joy0down then PlayerLocked(0) = 0 : rem Unlock by moving down
          if joy0fire then PlayerLocked(0) = 1

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then PlayerChar(1) = PlayerChar(1) - 1 : if PlayerChar(1) < 0 then PlayerChar(1) = 15 : PlayerLocked(1) = 0
          if joy1right then PlayerChar(1) = PlayerChar(1) + 1 : if PlayerChar(1) > 15 then PlayerChar(1) = 0 : PlayerLocked(1) = 0
          if joy1up then PlayerLocked(1) = 0  : rem Unlock by moving up
          if joy1down then PlayerLocked(1) = 0 : rem Unlock by moving down
          if joy1fire then PlayerLocked(1) = 1
          
          QtController = 1  rem Switch to odd frame mode for next iteration
          goto HandleInputComplete

HandleQuadtariControllers
          rem Handle Player 3 input (joy0 on odd frames, Quadtari only)
          if QuadtariDetected then
                    if joy0left then PlayerChar(2) = PlayerChar(2) - 1 : if PlayerChar(2) < 0 then PlayerChar(2) = 15 : PlayerLocked(2) = 0
                    if joy0right then PlayerChar(2) = PlayerChar(2) + 1 : if PlayerChar(2) > 15 then PlayerChar(2) = 0 : PlayerLocked(2) = 0
                    if joy0up then PlayerLocked(2) = 0  : rem Unlock by moving up
                    if joy0down then PlayerLocked(2) = 0 : rem Unlock by moving down
                    if joy0fire then PlayerLocked(2) = 1

          rem Handle Player 4 input (joy1 on odd frames, Quadtari only)
          if QuadtariDetected then
                    if joy1left then PlayerChar(3) = PlayerChar(3) - 1 : if PlayerChar(3) < 0 then PlayerChar(3) = 15 : PlayerLocked(3) = 0
                    if joy1right then PlayerChar(3) = PlayerChar(3) + 1 : if PlayerChar(3) > 15 then PlayerChar(3) = 0 : PlayerLocked(3) = 0
                    if joy1up then PlayerLocked(3) = 0  : rem Unlock by moving up
                    if joy1down then PlayerLocked(3) = 0 : rem Unlock by moving down
                    if joy1fire then PlayerLocked(3) = 1
          
          QtController = 0  rem Switch back to even frame mode for next iteration

HandleInputComplete

          rem Check if all players are ready to start
          gosub CheckAllPlayersReady1

          rem Draw character selection screen
          gosub DrawCharacterSelect1

          drawscreen
          goto CharacterSelect1Loop

          rem Check if all players are ready
CheckAllPlayersReady1
          ReadyCount = 0

          rem Count locked players
          if PlayerLocked(0) then ReadyCount = ReadyCount + 1
          if PlayerLocked(1) then ReadyCount = ReadyCount + 1
          if QuadtariDetected then
                    if PlayerLocked(2) then ReadyCount = ReadyCount + 1
                    if PlayerLocked(3) then ReadyCount = ReadyCount + 1

          rem Check if enough players are ready
          if QuadtariDetected then
                    rem Need at least 2 players ready
                    if ReadyCount >= 2 then goto CharacterSelectComplete1
          if !QuadtariDetected then
                    if PlayerLocked(0) then goto CharacterSelectComplete1
          return

          rem Draw character selection screen
DrawCharacterSelect1
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0
          pf3 = 0 : pf4 = 0 : pf5 = 0

          rem Draw Player 1 selection (top left) with number
          player0x = 40 : player0y = 40
          gosub DrawCharacterSprite1

          rem Draw "1" indicator below Player 1 using playfield
          gosub DrawPlayerNumber1

          rem Draw Player 2 selection (top right) with number
          player1x = 120 : player1y = 40
          gosub DrawCharacterSprite1

          rem Draw "2" indicator below Player 2 using playfield
          gosub DrawPlayerNumber1

          rem Draw Player 3 selection (bottom left) if Quadtari detected
          if QuadtariDetected then
                    player0x = 40 : player0y = 80
                    gosub DrawCharacterSprite1

                    rem Draw "3" indicator below Player 3 using playfield
                    gosub DrawPlayerNumber1

          rem Draw Player 4 selection (bottom right) if Quadtari detected
          if QuadtariDetected then
                    player1x = 120 : player1y = 80
                    gosub DrawCharacterSprite1

                    rem Draw "4" indicator below Player 4 using playfield
                    gosub DrawPlayerNumber1

          rem Draw locked status indicators (playfield blocks framing characters)
          gosub DrawLockedIndicators1

          return

          rem Draw locked status indicators
DrawLockedIndicators1
          rem Draw playfield blocks around locked characters
          if PlayerLocked(0) then
                    rem Draw border around Player 1
                    pf0 = pf0 | %10000000
                    pf1 = pf1 | %00000001

          if PlayerLocked(1) then
                    rem Draw border around Player 2
                    pf0 = pf0 | %00001000
                    pf1 = pf1 | %00010000

          if QuadtariDetected && PlayerLocked(2) then
                    rem Draw border around Player 3
                    pf0 = pf0 | %10000000
                    pf1 = pf1 | %00000001

          if QuadtariDetected && PlayerLocked(3) then
                    rem Draw border around Player 4
                    pf0 = pf0 | %00001000
                    pf1 = pf1 | %00010000
          return

          rem Draw player number indicator
DrawPlayerNumber1
          rem This function draws the player number (1-4) below the character
          rem using playfield pixels in a simple digit pattern
          rem Player numbers are determined by position in the grid

          rem Player 1 (top left) - draw "1"
          if player0x = 40 && player0y = 40 then
                    pf0 = pf0 | %00001000
                    pf1 = pf1 | %00011000
                    pf2 = pf2 | %00001000
                    pf3 = pf3 | %00001000

          rem Player 2 (top right) - draw "2"
          if player1x = 120 && player1y = 40 then
                    pf3 = pf3 | %00010000
                    pf4 = pf4 | %00001000
                    pf5 = pf5 | %00010000

          rem Player 3 (bottom left) - draw "3"
          if player0x = 40 && player0y = 80 then
                    pf0 = pf0 | %00001000
                    pf1 = pf1 | %00001000
                    pf2 = pf2 | %00001000
                    pf3 = pf3 | %00001000

          rem Player 4 (bottom right) - draw "4"
          if player1x = 120 && player1y = 80 then
                    pf3 = pf3 | %00010000
                    pf4 = pf4 | %00010000
                    pf5 = pf5 | %00010000
          return

          rem Draw character sprite
DrawCharacterSprite1
          rem This would draw the selected character sprite
          rem Each character has unique 8x16 graphics with unique colors per scanline
          rem For now, using a simple placeholder
          player0:
          %00011000
          %00111100
          %01111110
          %00011000
          %00011000
          %00011000
          %00011000
          %00011000
          end
          return

CharacterSelectComplete1
          rem Character selection complete
          rem Store selected characters for use in game
          SelectedChar1 = PlayerChar(0)
          SelectedChar2 = PlayerChar(1)
          SelectedChar3 = PlayerChar(2)
          SelectedChar4 = PlayerChar(3)

          rem Proceed to falling animation
          return

          rem Detect Quadtari adapter
DetectQuadtari
          rem Quadtari detection: check INPT port states
          rem Left side: INPT0 and INPT1 should have opposite states when buttons are pressed
          rem Right side: INPT2 and INPT3 should have opposite states when buttons are pressed
          rem If both sides show this pattern, Quadtari is detected
          
          rem Check left side (controllers 0 and 1)
          if !INPT0{7} && INPT1{7} then qtLeftOk
          if INPT0{7} && !INPT1{7} then qtLeftOk
          goto qtNotDetected
          
qtLeftOk
          rem Check right side (controllers 2 and 3)
          if !INPT2{7} && INPT3{7} then qtRightOk
          if INPT2{7} && !INPT3{7} then qtRightOk
          goto qtNotDetected
          
qtRightOk
          rem Quadtari detected
          QuadtariDetected = 1
          return
          
qtNotDetected
          rem Quadtari not detected
          QuadtariDetected = 0
          return