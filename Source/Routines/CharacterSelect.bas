          rem ChaosFight - Source/Routines/CharacterSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CharacterSelect
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

          rem Check for Quadtari (simplified - would need actual detection)
          QuadtariDetected = 0

          COLUBK = ColBlue(8)

CharacterSelectLoop
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
          gosub CheckAllPlayersReady

          rem Draw character selection screen
          gosub DrawCharacterSelect

          drawscreen
          goto CharacterSelectLoop

          rem Check if all players are ready
CheckAllPlayersReady
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
                    if ReadyCount >= 2 then goto CharacterSelectComplete
          if !QuadtariDetected then
                    if Player1Locked then goto CharacterSelectComplete
          return

          rem Draw character selection screen
DrawCharacterSelect
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0 : pf3 = 0
          pf4 = 0 : pf5 = 0 : pf6 = 0 : pf7 = 0
          pf8 = 0 : pf9 = 0 : pf10 = 0 : pf11 = 0

          rem Draw Player 1 selection (top left) with number
          player0x = 40 : player0y = 40
          gosub DrawCharacterSprite

          rem Draw "1" indicator below Player 1 using playfield
          gosub DrawPlayerNumber

          rem Draw Player 2 selection (top right) with number
          player1x = 120 : player1y = 40
          gosub DrawCharacterSprite

          rem Draw "2" indicator below Player 2 using playfield
          gosub DrawPlayerNumber

          rem Draw Player 3 selection (bottom left) if Quadtari detected
          if QuadtariDetected then
                    player0x = 40 : player0y = 80
                    gosub DrawCharacterSprite

                    rem Draw "3" indicator below Player 3 using playfield
                    gosub DrawPlayerNumber

          rem Draw Player 4 selection (bottom right) if Quadtari detected
          if QuadtariDetected then
                    player1x = 120 : player1y = 80
                    gosub DrawCharacterSprite

                    rem Draw "4" indicator below Player 4 using playfield
                    gosub DrawPlayerNumber

          rem Draw locked status indicators (playfield blocks framing characters)
          gosub DrawLockedIndicators

          return

          rem Draw locked status indicators
DrawLockedIndicators
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
DrawPlayerNumber
          rem This function draws the player number (1-4) below the character
          rem using playfield pixels in a simple digit pattern
          rem Player numbers are determined by position in the grid

          rem Player 1 (top left) - draw "1"
          if player0x = 40 && player0y = 40 then
                    pf8 = pf8 | %00001000
                    pf9 = pf9 | %00011000
                    pf10 = pf10 | %00001000
                    pf11 = pf11 | %00001000

          rem Player 2 (top right) - draw "2"
          if player1x = 120 && player1y = 40 then
                    pf8 = pf8 | %00010000
                    pf9 = pf9 | %00001000
                    pf10 = pf10 | %00010000
                    pf11 = pf11 | %00010000

          rem Player 3 (bottom left) - draw "3"
          if player0x = 40 && player0y = 80 then
                    pf8 = pf8 | %00001000
                    pf9 = pf9 | %00001000
                    pf10 = pf10 | %00001000
                    pf11 = pf11 | %00001000

          rem Player 4 (bottom right) - draw "4"
          if player1x = 120 && player1y = 80 then
                    pf8 = pf8 | %00010000
                    pf9 = pf9 | %00010000
                    pf10 = pf10 | %00010000
                    pf11 = pf11 | %00010000
          return

          rem Draw character sprite
DrawCharacterSprite
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

CharacterSelectComplete
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