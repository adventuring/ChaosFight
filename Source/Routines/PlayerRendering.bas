          rem ChaosFight - Source/Routines/PlayerRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER SPRITE RENDERING
          rem =================================================================
          rem Handles sprite positioning, colors, and graphics for all players.

          rem SPRITE ASSIGNMENTS (MULTISPRITE KERNEL):
          rem   Participant 1 (array [0]): P0 sprite (player0x/player0y, COLUP0)
          rem   Participant 2 (array [1]): P1 sprite (player1x/player1y, COLUP1, virtual _P1)
          rem   Participant 3 (array [2]): P2 sprite (player2x/player2y, COLUP2)
          rem   Participant 4 (array [3]): P3 sprite (player3x/player3y, COLUP3)

          rem MISSILE SPRITES:
          rem   2-player mode: missile0 = Participant 1, missile1 = Participant 2 (no multiplexing)
          rem   4-player mode: missile0 and missile1 multiplexed between all 4 participants (even/odd frames)

          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem   playerRecoveryFrames[0-3] - Hitstun frames
          rem   missileActive (bit flags) - Projectile states (bit 0=P0, bit 1=P1, bit 2=P2, bit 3=P3)
          rem   missileX[0-3], missileY[0-3] - Projectile positions
          rem   QuadtariDetected, selectedChar3, selectedChar4
          rem =================================================================

          rem =================================================================
          rem SET SPRITE POSITIONS
          rem =================================================================
          rem Updates hardware sprite position registers for all active entities.
SetSpritePositions
          rem Set player sprite positions
          player0x = playerX[0]
          player0y = playerY[0]
          player1x = playerX[1]
          player1y = playerY[1]

          rem Set positions for participants 3 & 4 in 4-player mode (multisprite kernel)
          rem Participant 3 (array [2]): P2 sprite (player2x/player2y, COLUP2)
          rem Participant 4 (array [3]): P3 sprite (player3x/player3y, COLUP3)
          rem Missiles are available for projectiles since participants use proper sprites
          
          rem Set Participant 3 position (array [2] → P2 sprite)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Position
          if selectedChar3 = 255 then goto SkipPlayer3Position
          if ! playerHealth[2] then goto SkipPlayer3Position
                    let player2x = playerX[2]
                    let player2y = playerY[2]
SkipPlayer3Position
          
          rem Set Participant 4 position (array [3] → P3 sprite)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Position
          if selectedChar4 = 255 then goto SkipPlayer4Position
          if ! playerHealth[3] then goto SkipPlayer4Position
                    let player3x = playerX[3]
                    let player3y = playerY[3]
SkipPlayer4Position
          

          rem Set missile positions for projectiles
          rem Hardware missiles: missile0 and missile1 (only 2 physical missiles available on TIA)
          rem In 2-player mode: missile0 = Participant 1, missile1 = Participant 2 (no multiplexing needed)
          rem In 4-player mode: Use frame multiplexing to support 4 logical missiles with 2 hardware missiles:
          rem   Even frames: missile0 = Participant 1 (array [0]), missile1 = Participant 2 (array [1])
          rem   Odd frames:  missile0 = Participant 3 (array [2]), missile1 = Participant 4 (array [3])
          rem Use missileActive bit flags: bit 0 = Participant 1, bit 1 = Participant 2, bit 2 = Participant 3, bit 3 = Participant 4
          
          rem Check if participants 3 or 4 are active (selected and not eliminated)
          rem Use this flag instead of QuadtariDetected for missile multiplexing
          rem because we only need to multiplex when participants 3 or 4 are actually in the game
          if !(controllerStatus & SetPlayers34Active) then goto RenderMissiles2Player
          
          rem 4-player mode: Use frame multiplexing
          temp6 = frame & 1
          rem 0 = even frame (Participants 1-2), 1 = odd frame (Participants 3-4)
          
          if temp6 = 0 then goto RenderMissilesEvenFrame
          
          rem Odd frame: Render Participants 3-4 missiles
          rem Participant 3 missile (array [2], bit 2) → missile0
          ENAM0 = 0
          temp4 = missileActive & 4
          if temp4 then missile0x = missileX[2] : missile0y = missileY[2] : ENAM0 = 1
          
          rem Participant 4 missile (array [3], bit 3) → missile1
          ENAM1 = 0
          temp4 = missileActive & 8
          if temp4 then missile1x = missileX[3] : missile1y = missileY[3] : ENAM1 = 1
          return
          
RenderMissilesEvenFrame
          rem Even frame: Render Participants 1-2 missiles
          rem Participant 1 missile (array [0], bit 0) → missile0
          ENAM0 = 0 
          temp4 = missileActive & 1
          if temp4 then missile0x = missileX[0] : missile0y = missileY[0] : ENAM0 = 1
          
          rem Participant 2 missile (array [1], bit 1) → missile1
          ENAM1 = 0 
          temp4 = missileActive & 2
          if temp4 then missile1x = missileX[1] : missile1y = missileY[1] : ENAM1 = 1
          return
          
RenderMissiles2Player
          rem 2-player mode: No multiplexing needed, assign missiles directly
          rem Participant 1 (array [0]) missile (missile0, P0 sprite)
          ENAM0 = 0 
          temp4 = missileActive & 1
          if temp4 then missile0x = missileX[0] : missile0y = missileY[0] : ENAM0 = 1
          
          rem Participant 2 (array [1]) missile (missile1, P1 sprite)
          ENAM1 = 0 
          temp4 = missileActive & 2
          if temp4 then missile1x = missileX[1] : missile1y = missileY[1] : ENAM1 = 1
          
          return

          rem =================================================================
          rem SET PLAYER SPRITES
          rem =================================================================
          rem Sets colors and graphics for all player sprites.
          rem Colors change based on hurt state and color/B&W switch.
          rem On 7800, Pause button can override Color/B&W setting.
SetPlayerSprites
          rem Set Player 1 color and sprite
          rem Color mode: Use solid player color or dimmer when hurt
          if playerRecoveryFrames[0] > 0 then COLUP0 = ColIndigo(6) : goto Player1ColorDone 
          rem Hurt: dimmer indigo
          let temp1 = playerChar[0] : let temp2 = 0 : gosub bank10 LoadCharacterColors : goto Player1ColorDone 
          rem Normal: solid player color
          
Player1ColorDone

          rem Load sprite data from character definition
          let temp1 = playerChar[0] 
          rem Character index
          let temp2 = 0 
          rem Animation frame (0=idle, 1=running)
          gosub bank10 LoadCharacterSprite

          rem Set Player 2 color and sprite
          rem Color mode: Use solid player color or dimmer when hurt
          if playerRecoveryFrames[1] > 0 then COLUP1 = ColRed(6) : goto Player2ColorDone 
          rem Hurt: dimmer red
          let temp1 = playerChar[1] : let temp2 = 0 : gosub bank10 LoadCharacterColors : goto Player2ColorDone 
          rem Normal: solid player color
          
Player2ColorDone

          rem Load sprite data from character definition
          let temp1 = playerChar[1] 
          rem Character index
          let temp2 = 0 
          rem Animation frame (0=idle, 1=running)
          gosub bank10 LoadCharacterSprite

          rem Set colors for Players 3 & 4 (multisprite kernel)
          rem Players 3 & 4 have independent COLUP2/COLUP3 registers
          rem No color inheritance issues with proper multisprite implementation
          
          rem Set Player 3 color and sprite (if active)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Sprite
          if selectedChar3 = 255 then goto SkipPlayer3Sprite
          if ! playerHealth[2] then goto SkipPlayer3Sprite
          
          rem Color mode: Use solid player color or dimmer when hurt
          if playerRecoveryFrames[2] > 0 then COLUP2 = ColYellow(6) : goto Player3ColorDone
          rem Hurt: dimmer yellow
          let temp1 = playerChar[2] : let temp2 = 0 : gosub bank10 LoadCharacterColors : goto Player3ColorDone
          rem Normal: solid player color
          
Player3ColorDone

          rem Load sprite data from character definition
          let temp1 = playerChar[2]
          rem Character index
          let temp2 = 0
          rem Animation frame (0=idle, 1=running)
          gosub bank10 LoadCharacterSprite
          
SkipPlayer3Sprite

          rem Set Player 4 color and sprite (if active)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Sprite
          if selectedChar4 = 255 then goto SkipPlayer4Sprite
          if ! playerHealth[3] then goto SkipPlayer4Sprite
          
          rem Color mode: Use solid player color or dimmer when hurt
          if playerRecoveryFrames[3] > 0 then COLUP3 = ColGreen(6) : goto Player4ColorDone
          rem Hurt: dimmer green
          let temp1 = playerChar[3] : let temp2 = 0 : gosub bank10 LoadCharacterColors : goto Player4ColorDone
          rem Normal: solid player color
          
Player4ColorDone

          rem Load sprite data from character definition
          let temp1 = playerChar[3]
          rem Character index
          let temp2 = 0
          rem Animation frame (0=idle, 1=running)
          gosub bank10 LoadCharacterSprite
          
SkipPlayer4Sprite
          
          return

          rem =================================================================
          rem DISPLAY HEALTH
          rem =================================================================
          rem Shows health status for all active players.
          rem Flashes sprites when health is critically low.
DisplayHealth
          rem Flash Participant 1 sprite (array [0], P0) if health is low (but not during recovery)
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[0] >= 25 then goto SkipParticipant1Flash
          if playerRecoveryFrames[0] <> 0 then goto SkipParticipant1Flash
          if frame & 8 then player0x = 200 
          rem Hide P0 sprite
SkipParticipant1Flash

          rem Flash Participant 2 sprite (array [1], P1) if health is low
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[1] >= 25 then goto SkipParticipant2Flash
          if playerRecoveryFrames[1] <> 0 then goto SkipParticipant2Flash
                    if frame & 8 then player1x = 200
SkipPlayer1Flash

          rem Flash Player 3 sprite if health is low (but alive)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Flash
          if selectedChar3 = 255 then goto SkipPlayer3Flash
          if ! playerHealth[2] then goto SkipPlayer3Flash
          if playerHealth[2] >= 25 then goto SkipPlayer3Flash
          if playerRecoveryFrames[2] <> 0 then goto SkipPlayer3Flash
          if frame & 8 then player2x = 200 
          rem Player 3 uses player2 sprite
SkipPlayer3Flash

          rem Flash Player 4 sprite if health is low (but alive)
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Flash
          if selectedChar4 = 255 then goto SkipPlayer4Flash
          if ! playerHealth[3] then goto SkipPlayer4Flash
          if playerHealth[3] >= 25 then goto SkipPlayer4Flash
          if playerRecoveryFrames[3] <> 0 then goto SkipPlayer4Flash
          if frame & 8 then player3x = 200 
          rem Player 4 uses player3 sprite
SkipPlayer4Flash
          
          rem Draw health bars in playfield
          gosub bank8 DrawHealthBars
          
          return

          rem =================================================================
          rem DRAW HEALTH BARS
          rem =================================================================
          rem Correctly used: Player 1 is pfscore bar 1. Player 2 is pfscore bar 2.
          rem Player 3 is left 2 digits of score, 4 is right two.
          
          rem FIXME: This code may not implement the requirements at all.
          
DrawHealthBars
          dim HealthBarLength = temp5
          
          rem Draw Player 1 health bar
          let HealthBarLength = playerHealth[0] / 3 
          rem Scale 0-100 to 0-32
          if HealthBarLength > 32 then LET HealthBarLength = 32
          COLUPF = ColBlue(12) 
          rem Bright blue
          gosub bank8 DrawHealthBarRow0
          
          rem Draw Player 2 health bar
          let HealthBarLength = playerHealth[1] / 3
          if HealthBarLength > 32 then LET HealthBarLength = 32
          COLUPF = ColRed(12) 
          rem Bright red
          gosub bank8 DrawHealthBarRow1
          
          rem Draw Player 3 & 4 bars if Quadtari active and player alive
          if controllerStatus & SetQuadtariDetected then goto DrawP3P4Health else goto SkipP3P4Health
DrawP3P4Health
          if selectedChar3 <> 255 && playerHealth[2] > 0 then goto DrawP3Health else goto SkipP3Health
DrawP3Health
          rem Player 3 health bar
          let HealthBarLength = playerHealth[2] / 3
          if HealthBarLength > 32 then LET HealthBarLength = 32
          COLUPF = ColYellow(12)
          rem Bright yellow
          gosub bank8 DrawHealthBarRow2
SkipP3Health
          
          if selectedChar4 <> 255 && playerHealth[3] > 0 then goto DrawP4Health else goto SkipP4Health
DrawP4Health
          rem Player 4 health bar
          let HealthBarLength = playerHealth[3] / 3
          if HealthBarLength > 32 then LET HealthBarLength = 32
          COLUPF = ColGreen(12)
          rem Bright green
          gosub bank8 DrawHealthBarRow3
SkipP4Health
SkipP3P4Health
          
          return

          rem =================================================================
          rem HEALTH BAR ROW DRAWING HELPERS
          rem =================================================================
          rem These subroutines draw a single row of health bar at different
          rem Y positions. They use HealthBarLength (temp6) to determine width.

DrawHealthBarRow0
          rem Draw filled portion
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
          rem pfpixel PixelIndex 0 on
          next
          return

DrawHealthBarRow1
          rem Draw health bar at row 1
          rem pfpixel 0 1 off : pfpixel 1 1 off : pfpixel 2 1 off : pfpixel 3 1 off
          rem pfpixel 4 1 off : pfpixel 5 1 off : pfpixel 6 1 off : pfpixel 7 1 off
          rem pfpixel 8 1 off : pfpixel 9 1 off : pfpixel 10 1 off : pfpixel 11 1 off
          rem pfpixel 12 1 off : pfpixel 13 1 off : pfpixel 14 1 off : pfpixel 15 1 off
          rem pfpixel 16 1 off : pfpixel 17 1 off : pfpixel 18 1 off : pfpixel 19 1 off
          rem pfpixel 20 1 off : pfpixel 21 1 off : pfpixel 22 1 off : pfpixel 23 1 off
          rem pfpixel 24 1 off : pfpixel 25 1 off : pfpixel 26 1 off : pfpixel 27 1 off
          rem pfpixel 28 1 off : pfpixel 29 1 off : pfpixel 30 1 off : pfpixel 31 1 off
          
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
          rem pfpixel PixelIndex 1 on
          next
          return

DrawHealthBarRow2
          rem Draw health bar at row 2
          rem pfpixel 0 2 off : pfpixel 1 2 off : pfpixel 2 2 off : pfpixel 3 2 off
          rem pfpixel 4 2 off : pfpixel 5 2 off : pfpixel 6 2 off : pfpixel 7 2 off
          rem pfpixel 8 2 off : pfpixel 9 2 off : pfpixel 10 2 off : pfpixel 11 2 off
          rem pfpixel 12 2 off : pfpixel 13 2 off : pfpixel 14 2 off : pfpixel 15 2 off
          rem pfpixel 16 2 off : pfpixel 17 2 off : pfpixel 18 2 off : pfpixel 19 2 off
          rem pfpixel 20 2 off : pfpixel 21 2 off : pfpixel 22 2 off : pfpixel 23 2 off
          rem pfpixel 24 2 off : pfpixel 25 2 off : pfpixel 26 2 off : pfpixel 27 2 off
          rem pfpixel 28 2 off : pfpixel 29 2 off : pfpixel 30 2 off : pfpixel 31 2 off
          
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
          rem pfpixel PixelIndex 2 on
          next
          return

DrawHealthBarRow3
          rem Draw health bar at row 3
          rem pfpixel 0 3 off : pfpixel 1 3 off : pfpixel 2 3 off : pfpixel 3 3 off
          rem pfpixel 4 3 off : pfpixel 5 3 off : pfpixel 6 3 off : pfpixel 7 3 off
          rem pfpixel 8 3 off : pfpixel 9 3 off : pfpixel 10 3 off : pfpixel 11 3 off
          rem pfpixel 12 3 off : pfpixel 13 3 off : pfpixel 14 3 off : pfpixel 15 3 off
          rem pfpixel 16 3 off : pfpixel 17 3 off : pfpixel 18 3 off : pfpixel 19 3 off
          rem pfpixel 20 3 off : pfpixel 21 3 off : pfpixel 22 3 off : pfpixel 23 3 off
          rem pfpixel 24 3 off : pfpixel 25 3 off : pfpixel 26 3 off : pfpixel 27 3 off
          rem pfpixel 28 3 off : pfpixel 29 3 off : pfpixel 30 3 off : pfpixel 31 3 off
          
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
          rem pfpixel PixelIndex 3 on
          next
          return

