          rem ChaosFight - Source/Routines/CharacterSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CharacterSelect1
          dim Player1Char = a
          dim Player2Char = b
          dim Player3Char = c
          dim Player4Char = d
          dim Player1Locked = e
          dim Player2Locked = f
          dim Player3Locked = g
          dim Player4Locked = h
          dim QuadtariDetected = i

          rem Initialize character selections
          Player1Char = 0
          Player2Char = 0
          Player3Char = 0
          Player4Char = 0
          Player1Locked = 0
          Player2Locked = 0
          Player3Locked = 0
          Player4Locked = 0
          QuadtariDetected = 0

          rem Check for Quadtari adapter
          gosub DetectQuadtari

          COLUBK = ColBlue(8)

CharacterSelect1Loop
          rem Handle Player 1 input (always available)
          if joy0left then Player1Char = Player1Char - 1 : if Player1Char < 0 then Player1Char = 15 : Player1Locked = 0
          if joy0right then Player1Char = Player1Char + 1 : if Player1Char > 15 then Player1Char = 0 : Player1Locked = 0
          if joy0up then Player1Locked = 0  : rem Unlock by moving up
          if joy0down then Player1Locked = 0 : rem Unlock by moving down
          if joy0fire then Player1Locked = 1

          rem Handle Player 2 input (always available)
          if joy1left then Player2Char = Player2Char - 1 : if Player2Char < 0 then Player2Char = 15 : Player2Locked = 0
          if joy1right then Player2Char = Player2Char + 1 : if Player2Char > 15 then Player2Char = 0 : Player2Locked = 0
          if joy1up then Player2Locked = 0  : rem Unlock by moving up
          if joy1down then Player2Locked = 0 : rem Unlock by moving down
          if joy1fire then Player2Locked = 1

          rem Handle Player 3 input (Quadtari only)
          if QuadtariDetected then
                    if joy2left then Player3Char = Player3Char - 1 : if Player3Char < 0 then Player3Char = 15 : Player3Locked = 0
                    if joy2right then Player3Char = Player3Char + 1 : if Player3Char > 15 then Player3Char = 0 : Player3Locked = 0
                    if joy2up then Player3Locked = 0  : rem Unlock by moving up
                    if joy2down then Player3Locked = 0 : rem Unlock by moving down
                    if joy2fire then Player3Locked = 1

          rem Handle Player 4 input (Quadtari only)
          if QuadtariDetected then
                    if joy3left then Player4Char = Player4Char - 1 : if Player4Char < 0 then Player4Char = 15 : Player4Locked = 0
                    if joy3right then Player4Char = Player4Char + 1 : if Player4Char > 15 then Player4Char = 0 : Player4Locked = 0
                    if joy3up then Player4Locked = 0  : rem Unlock by moving up
                    if joy3down then Player4Locked = 0 : rem Unlock by moving down
                    if joy3fire then Player4Locked = 1

          rem Check if all players are ready to start
          gosub CheckAllPlayersReady1

          rem Draw character selection screen
          gosub DrawCharacterSelect1

          drawscreen
          goto CharacterSelect1Loop

          rem Check if all players are ready
CheckAllPlayersReady1
          dim ReadyCount = a
          ReadyCount = 0

          rem Count locked players
          if Player1Locked then ReadyCount = ReadyCount + 1
          if Player2Locked then ReadyCount = ReadyCount + 1
          if QuadtariDetected then
                    if Player3Locked then ReadyCount = ReadyCount + 1
                    if Player4Locked then ReadyCount = ReadyCount + 1

          rem Check if enough players are ready
          if QuadtariDetected then
                    rem Need at least 2 players ready
                    if ReadyCount >= 2 then goto CharacterSelect1Complete
          if !QuadtariDetected then
                    if Player1Locked then goto CharacterSelect1Complete
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
          if Player1Locked then
                    rem Draw border around Player 1
                    pf0 = pf0 | %10000000
                    pf1 = pf1 | %00000001

          if Player2Locked then
                    rem Draw border around Player 2
                    pf0 = pf0 | %00001000
                    pf1 = pf1 | %00010000

          if QuadtariDetected && Player3Locked then
                    rem Draw border around Player 3
                    pf0 = pf0 | %10000000
                    pf1 = pf1 | %00000001

          if QuadtariDetected && Player4Locked then
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

CharacterSelect1Complete
          rem Character selection complete
          rem Store selected characters for use in game
          dim SelectedChar1 = a
          dim SelectedChar2 = b
          dim SelectedChar3 = c
          dim SelectedChar4 = d

          SelectedChar1 = Player1Char
          SelectedChar2 = Player2Char
          SelectedChar3 = Player3Char
          SelectedChar4 = Player4Char

          rem Proceed to falling animation
          return

          rem Detect Quadtari adapter
DetectQuadtari
          rem Check for Quadtari by testing input port states
          rem In batariBASIC, we can check the input port variables
          rem INPT0-INPT3 should have specific patterns for Quadtari detection

          rem Simple detection: check if any input is active
          rem In a real implementation, this would check for the specific Quadtari signature
          if joy2left || joy2right || joy2up || joy2down || joy2fire || joy3left || joy3right || joy3up || joy3down || joy3fire then
                    QuadtariDetected = 1
          else
                    QuadtariDetected = 0
          endif
          return