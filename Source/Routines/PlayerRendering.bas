          rem ChaosFight - Source/Routines/PlayerRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER SPRITE RENDERING
          rem =================================================================
          rem Handles sprite positioning, colors, and graphics for all players.

          rem SPRITE ASSIGNMENTS (MULTISPRITE KERNEL):
          rem   Player 1: player0 sprite (COLUP0)
          rem   Player 2: player1 sprite (COLUP1)
          rem   Player 3: player2 sprite (COLUP2)
          rem   Player 4: player3 sprite (COLUP3)

          rem MISSILE SPRITES:
          rem   2-player mode: missile0 = Player 0, missile1 = Player 1 (no multiplexing)
          rem   4-player mode: missile0 and missile1 multiplexed between all 4 players (even/odd frames)

          rem AVAILABLE VARIABLES:
          rem   PlayerX[0-3], PlayerY[0-3] - Positions
          rem   PlayerState[0-3] - State flags
          rem   PlayerRecoveryFrames[0-3] - Hitstun frames
          rem   MissileActive (bit flags) - Projectile states (bit 0=P0, bit 1=P1, bit 2=P2, bit 3=P3)
          rem   MissileX[0-3], MissileY[0-3] - Projectile positions
          rem   QuadtariDetected, SelectedChar3, SelectedChar4
          rem =================================================================

          rem =================================================================
          rem SET SPRITE POSITIONS
          rem =================================================================
          rem Updates hardware sprite position registers for all active entities.
SetSpritePositions
          rem Set player sprite positions
          player0x = PlayerX[0]
          player0y = PlayerY[0]
          player1x = PlayerX[1]
          player1y = PlayerY[1]

          rem Set player positions for players 3 & 4 in 4-player mode (multisprite kernel)
          rem Player 3: player2 sprite (COLUP2), Player 4: player3 sprite (COLUP3)
          rem Missiles are available for projectiles since players use proper sprites
          
          rem Set Player 3 position (multisprite)
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Position
          if SelectedChar3 = 255 then goto SkipPlayer3Position
          if ! PlayerHealth[2] then goto SkipPlayer3Position
                    player2x = PlayerX[2]
                    player2y = PlayerY[2]
SkipPlayer3Position
          
          rem Set Player 4 position (multisprite)
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Position
          if SelectedChar4 = 255 then goto SkipPlayer4Position
          if ! PlayerHealth[3] then goto SkipPlayer4Position
                    player3x = PlayerX[3]
                    player3y = PlayerY[3]
SkipPlayer4Position
          

          rem Set missile positions for projectiles
          rem Hardware missiles: missile0 and missile1 (only 2 physical missiles available on TIA)
          rem In 2-player mode: missile0 = Player 0, missile1 = Player 1 (no multiplexing needed)
          rem In 4-player mode: Use frame multiplexing to support 4 logical missiles with 2 hardware missiles:
          rem   Even frames: missile0 = Player 0, missile1 = Player 1
          rem   Odd frames:  missile0 = Player 2, missile1 = Player 3
          rem Use MissileActive bit flags: bit 0 = Player 0, bit 1 = Player 1, bit 2 = Player 2, bit 3 = Player 3
          
          rem Check if players 3 or 4 are active (selected and not eliminated)
          rem Use this flag instead of QuadtariDetected for missile multiplexing
          rem because we only need to multiplex when players 3 or 4 are actually in the game
          if !(ControllerStatus & SetPlayers34Active) then goto RenderMissiles2Player
          
          rem 4-player mode: Use frame multiplexing
          temp6 = frame & 1
          rem 0 = even frame (Players 0-1), 1 = odd frame (Players 2-3)
          
          if temp6 = 0 then goto RenderMissilesEvenFrame
          
          rem Odd frame: Render Players 2-3 missiles
          rem Game Player 2 missile (missile0)
          ENAM0 = 0
          temp4 = MissileActive & 4
          if temp4 then missile0x = MissileX[2] : missile0y = MissileY[2] : ENAM0 = 1
          
          rem Game Player 3 missile (missile1)
          ENAM1 = 0
          temp4 = MissileActive & 8
          if temp4 then missile1x = MissileX[3] : missile1y = MissileY[3] : ENAM1 = 1
          return
          
RenderMissilesEvenFrame
          rem Even frame: Render Players 0-1 missiles
          rem Game Player 0 missile (missile0)
          ENAM0 = 0 
          temp4 = MissileActive & 1
          if temp4 then missile0x = MissileX[0] : missile0y = MissileY[0] : ENAM0 = 1
          
          rem Game Player 1 missile (missile1)
          ENAM1 = 0 
          temp4 = MissileActive & 2
          if temp4 then missile1x = MissileX[1] : missile1y = MissileY[1] : ENAM1 = 1
          return
          
RenderMissiles2Player
          rem 2-player mode: No multiplexing needed, assign missiles directly
          rem Game Player 0 missile (missile0)
          ENAM0 = 0 
          temp4 = MissileActive & 1
          if temp4 then missile0x = MissileX[0] : missile0y = MissileY[0] : ENAM0 = 1
          
          rem Game Player 1 missile (missile1)
          ENAM1 = 0 
          temp4 = MissileActive & 2
          if temp4 then missile1x = MissileX[1] : missile1y = MissileY[1] : ENAM1 = 1
          
          return

          rem =================================================================
          rem SET PLAYER SPRITES
          rem =================================================================
          rem Sets colors and graphics for all player sprites.
          rem Colors change based on hurt state and color/B&W switch.
          rem On 7800, Pause button can override Color/B&W setting.
SetPlayerSprites
          rem Determine effective B&W mode (switchbw XOR ColorBWOverride)
          rem This allows 7800 Pause button to toggle between modes
          rem On SECAM, always use colors (no luminance control available)
#ifdef TV_SECAM
          let temp6 = 0 
          rem SECAM: Always use color mode (no B&W support)
#else
          let temp6 = switchbw ^ ColorBWOverride 
          rem Effective B&W state
          
          rem Set Player 1 color and sprite
          if temp6 then goto Player1BWMode
          
          rem Color mode: Use solid player color or dimmer when hurt
          if PlayerRecoveryFrames[0] > 0 then COLUP0 = ColIndigo(6) : goto Player1ColorDone 
          rem Hurt: dimmer indigo
          let temp1 = PlayerChar[0] : let temp2 = 0 : gosub bank10 LoadCharacterColors : goto Player1ColorDone 
          rem Normal: solid player color
          
Player1BWMode
          rem B&W mode: Always use bright indigo (Player 1 color), hurt state looks the same
          COLUP0 = ColIndigo(14) 
          rem Bright indigo for Player 1
          
Player1ColorDone

          rem Load sprite data from character definition
          let temp1 = PlayerChar[0] 
          rem Character index
          let temp2 = 0 
          rem Animation frame (0=idle, 1=running)
          gosub bank10 LoadCharacterSprite

          rem Set Player 2 color and sprite
          if temp6 then goto Player2BWMode
          
          rem Color mode: Use solid player color or dimmer when hurt
          if PlayerRecoveryFrames[1] > 0 then COLUP1 = ColRed(6) : goto Player2ColorDone 
          rem Hurt: dimmer red
          let temp1 = PlayerChar[1] : let temp2 = 0 : gosub bank10 LoadCharacterColors : goto Player2ColorDone 
          rem Normal: solid player color
          
Player2BWMode
          rem B&W mode: Always use bright red (Player 2 color), hurt state looks the same
          COLUP1 = ColRed(14) 
          rem Bright red for Player 2
          
Player2ColorDone

          rem Load sprite data from character definition
          let temp1 = PlayerChar[1] 
          rem Character index
          let temp2 = 0 
          rem Animation frame (0=idle, 1=running)
          gosub bank10 LoadCharacterSprite

          rem Set colors for Players 3 & 4 (multisprite kernel)
          rem Players 3 & 4 have independent COLUP2/COLUP3 registers
          rem No color inheritance issues with proper multisprite implementation
          
          rem Set playfield color based on B&W mode
          if temp6 then COLUPF = ColGrey(14) : goto Player3Color 
          rem B&W mode: playfield is white
          rem Color mode: playfield has color-per-row (handled elsewhere)
          
Player3Color
          rem Player 3 sprite mapping (multisprite kernel)
          rem Correct mapping: Player 3 -> player2 -> COLUP2 (independent color)
          rem No color conflicts with multisprite kernel
          
Player4Color
          rem Set background color to constant black (COLUBK should not change)
          COLUBK = ColGray(0) 
          rem Always black background
          
          rem TODO: Player 4 sprite mapping needs to be fixed (Issue #70, #72)
          rem Player 4 should not use COLUBK register - needs proper sprite register
          
          return

          rem =================================================================
          rem DISPLAY HEALTH
          rem =================================================================
          rem Shows health status for all active players.
          rem Flashes sprites when health is critically low.
DisplayHealth
          rem Flash Player 1 sprite if health is low (but not during recovery)
          if PlayerHealth[0] >= 25 || PlayerRecoveryFrames[0] <> 0 then SkipPlayer0Flash
          if frame & 8 then player0x = 200 
          rem Hide sprite
SkipPlayer0Flash

          rem Flash Player 2 sprite if health is low
          if PlayerHealth[1] >= 25 || PlayerRecoveryFrames[1] <> 0 then SkipPlayer1Flash
                    if frame & 8 then player1x = 200
SkipPlayer1Flash

          rem Flash Player 3 sprite if health is low (but alive)
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Flash
          if SelectedChar3 = 255 then goto SkipPlayer3Flash
          if ! PlayerHealth[2] then goto SkipPlayer3Flash
          if PlayerHealth[2] >= 25 then goto SkipPlayer3Flash
          if PlayerRecoveryFrames[2] <> 0 then goto SkipPlayer3Flash
          if frame & 8 then player2x = 200 
          rem Player 3 uses player2 sprite
SkipPlayer3Flash

          rem Flash Player 4 sprite if health is low (but alive)
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Flash
          if SelectedChar4 = 255 then goto SkipPlayer4Flash
          if ! PlayerHealth[3] then goto SkipPlayer4Flash
          if PlayerHealth[3] >= 25 then goto SkipPlayer4Flash
          if PlayerRecoveryFrames[3] <> 0 then goto SkipPlayer4Flash
          if frame & 8 then player3x = 200 
          rem Player 4 uses player3 sprite
SkipPlayer4Flash
          
          rem Draw health bars in playfield
          gosub bank8 DrawHealthBars
          
          return

          rem =================================================================
          rem DRAW HEALTH BARS
          rem =================================================================
          rem Renders health bars at top of screen using playfield pixels.
          rem Each player gets a color-coded bar:
          rem   Player 1: Blue (top-left)
          rem   Player 2: Red (top-right)
          rem   Player 3: Yellow (bottom-left, if Quadtari active)
          rem   Player 4: Green (bottom-right, if Quadtari active)

          rem Health bars are drawn using pfpixel and appropriate colors.
          rem Each bar is 32 pixels wide (max health = 100, scale to 32 pixels).
DrawHealthBars
          dim HealthBarLength = temp5
          
          rem Calculate effective B&W mode (accounts for 7800 Pause toggle)
#ifdef TV_SECAM
          let temp6 = 0 
          rem SECAM: Always use color mode
#else
          let temp6 = switchbw ^ ColorBWOverride
          
          rem Draw Player 1 health bar
          let HealthBarLength = PlayerHealth[0] / 3 
          rem Scale 0-100 to 0-32
          if HealthBarLength > 32 then LET HealthBarLength = 32
          if temp6 then
          COLUPF = ColGrey(14) 
          rem White (B&W)

          COLUPF = ColBlue(12) 
          rem Bright blue (Color)
          
          gosub bank8 DrawHealthBarRow0
          
          rem Draw Player 2 health bar
          let HealthBarLength = PlayerHealth[1] / 3
          if HealthBarLength > 32 then LET HealthBarLength = 32
          if temp6 then
          COLUPF = ColGrey(10) 
          rem Medium-bright grey (B&W)

          COLUPF = ColRed(12) 
          rem Bright red (Color)
          
          gosub bank8 DrawHealthBarRow1
          
          rem Draw Player 3 & 4 bars if Quadtari active and player alive
if ControllerStatus & SetQuadtariDetected then 
if SelectedChar3 <> 255 && PlayerHealth[2] > 0 then 
                              rem Player 3 health bar
          let HealthBarLength = PlayerHealth[2] / 3
          if HealthBarLength > 32 then LET HealthBarLength = 32
                              if temp6 then
          COLUPF = ColGrey(8) 
          rem Medium grey (B&W)

          COLUPF = ColYellow(12) 
          rem Bright yellow (Color)
          
                              gosub bank8 DrawHealthBarRow2
          
                    
if SelectedChar4 <> 255 && PlayerHealth[3] > 0 then 
                              rem Player 4 health bar
          let HealthBarLength = PlayerHealth[3] / 3
          if HealthBarLength > 32 then LET HealthBarLength = 32
                              if temp6 then
          COLUPF = ColGrey(6) 
          rem Dark-medium grey (B&W)

          COLUPF = ColGreen(12) 
          rem Bright green (Color)
          
                              gosub bank8 DrawHealthBarRow3
          
          
          
          return

          rem =================================================================
          rem HEALTH BAR ROW DRAWING HELPERS
          rem =================================================================
          rem These subroutines draw a single row of health bar at different
          rem Y positions. They use HealthBarLength (temp6) to determine width.

DrawHealthBarRow0
          rem Draw health bar at row 0 (top of screen)
          rem Clear the row first
          rem pfpixel 0 0 off : pfpixel 1 0 off : pfpixel 2 0 off : pfpixel 3 0 off
          rem pfpixel 4 0 off : pfpixel 5 0 off : pfpixel 6 0 off : pfpixel 7 0 off
          rem pfpixel 8 0 off : pfpixel 9 0 off : pfpixel 10 0 off : pfpixel 11 0 off
          rem pfpixel 12 0 off : pfpixel 13 0 off : pfpixel 14 0 off : pfpixel 15 0 off
          rem pfpixel 16 0 off : pfpixel 17 0 off : pfpixel 18 0 off : pfpixel 19 0 off
          rem pfpixel 20 0 off : pfpixel 21 0 off : pfpixel 22 0 off : pfpixel 23 0 off
          rem pfpixel 24 0 off : pfpixel 25 0 off : pfpixel 26 0 off : pfpixel 27 0 off
          rem pfpixel 28 0 off : pfpixel 29 0 off : pfpixel 30 0 off : pfpixel 31 0 off
          
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

