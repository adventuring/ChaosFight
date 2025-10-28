          rem ChaosFight - Source/Routines/PlayerRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER SPRITE RENDERING
          rem =================================================================
          rem Handles sprite positioning, colors, and graphics for all players.
          rem
          rem SPRITE ASSIGNMENTS:
          rem   2-player mode: player0=P1, player1=P2
          rem   4-player mode: player0=P1, player1=P2, missile1=P3, ball=P4
          rem
          rem MISSILE SPRITES:
          rem   Projectiles use missile0 and missile1 when not used for P3/P4
          rem
          rem AVAILABLE VARIABLES:
          rem   PlayerX[0-3], PlayerY[0-3] - Positions
          rem   PlayerState[0-3] - State flags
          rem   PlayerRecoveryFrames[0-3] - Hitstun frames
          rem   Missile1Active, Missile2Active - Projectile states
          rem   Missile1X, Missile1Y, Missile2X, Missile2Y - Projectile positions
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

          rem Set missile/ball positions for players 3 & 4 in 4-player mode
          rem Only enable if player is registered AND alive (health > 0)
          if QuadtariDetected && SelectedChar3 != 0 && PlayerHealth[2] > 0 then
                    missile1x = PlayerX[2]
                    missile1y = PlayerY[2]
                    ENAM1 = 1
          else
                    ENAM1 = 0
          endif

          if QuadtariDetected && SelectedChar4 != 0 && PlayerHealth[3] > 0 then
                    ballx = PlayerX[3]
                    bally = PlayerY[3]
                    ENABL = 1
          else
                    ENABL = 0
          endif

          rem Set missile positions for projectiles
          rem (only if not used for players 3/4)
          if Missile1Active && !(QuadtariDetected && SelectedChar3 != 0) then
                    missile0x = Missile1X
                    missile0y = Missile1Y
                    ENAM0 = 1
          else
                    ENAM0 = 0
          endif

          if Missile2Active && !(QuadtariDetected && SelectedChar4 != 0) then
                    missile1x = Missile2X
                    missile1y = Missile2Y
                    ENAM1 = 1
          else
                    ENAM1 = 0
          endif
          
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
          temp6 = 0  : rem SECAM: Always use color mode (no B&W support)
#else
          temp6 = switchbw ^ ColorBWOverride  : rem Effective B&W state
#endif
          
          rem Set Player 1 color and sprite
          if PlayerRecoveryFrames[0] > 0 then
                    if temp6 then
                              COLUP0 = ColGrey(6)  : rem Dark grey for hurt (B&W)
                    else
                              rem Load character color from XCF artwork (dimmer for hurt)
                              temp1 = PlayerChar[0]  : rem Character index
                              temp2 = 1  : rem Hurt state
                              gosub LoadCharacterColors
                    endif
          else
                    if temp6 then
                              COLUP0 = ColGrey(14)  : rem Bright grey - Player 1 (B&W)
                    else
                              rem Load character color from XCF artwork
                              temp1 = PlayerChar[0]  : rem Character index
                              temp2 = 0  : rem Normal state
                              gosub LoadCharacterColors
                    endif
          endif

          rem Load sprite data from character definition
          temp1 = PlayerChar[0]  : rem Character index
          temp2 = 0  : rem Animation frame (0=idle, 1=running)
          gosub LoadCharacterSprite

          rem Set Player 2 color and sprite
          if PlayerRecoveryFrames[1] > 0 then
                    if temp6 then
                              COLUP1 = ColGrey(4)  : rem Medium grey for hurt (B&W)
                    else
                              rem Load character color from XCF artwork (dimmer for hurt)
                              temp1 = PlayerChar[1]  : rem Character index
                              temp2 = 1  : rem Hurt state
                              gosub LoadCharacterColors
                    endif
          else
                    if temp6 then
                              COLUP1 = ColGrey(10)  : rem Medium-bright grey - Player 2 (B&W)
                    else
                              rem Load character color from XCF artwork
                              temp1 = PlayerChar[1]  : rem Character index
                              temp2 = 0  : rem Normal state
                              gosub LoadCharacterColors
                    endif
          endif

          rem Load sprite data from character definition
          temp1 = PlayerChar[1]  : rem Character index
          temp2 = 0  : rem Animation frame (0=idle, 1=running)
          gosub LoadCharacterSprite

          rem Set colors for Players 3 & 4 (missile1/ball sprites)
          rem Only apply color if player is registered AND alive
          if QuadtariDetected && SelectedChar3 != 0 && PlayerHealth[2] > 0 then
                    if PlayerRecoveryFrames[2] > 0 then
                              if temp6 then
                                        COLUPF = ColGrey(3)  : rem Dark grey for hurt (B&W)
                              else
                                        COLUPF = ColYellow(6)  : rem Dark yellow for hurt (Color)
                              endif
                    else
                              if temp6 then
                                        COLUPF = ColGrey(8)  : rem Medium grey - Player 3 (B&W)
                              else
                                        COLUPF = ColYellow(12)  : rem Bright yellow - Player 3 (Color)
                              endif
                    endif
          else
                    rem Set playfield to white when Player 3 not active
                    COLUPF = ColGrey(14)  : rem White (always)
          endif

          if QuadtariDetected && SelectedChar4 != 0 && PlayerHealth[3] > 0 then
                    if PlayerRecoveryFrames[3] > 0 then
                              if temp6 then
                                        COLUBK = ColGrey(2)  : rem Very dark grey for hurt (B&W)
                              else
                                        COLUBK = ColGreen(6)  : rem Dark green for hurt (Color)
                              endif
                    else
                              if temp6 then
                                        COLUBK = ColGrey(6)  : rem Dark-medium grey - Player 4 (B&W)
                              else
                                        COLUBK = ColGreen(12)  : rem Bright green - Player 4 (Color)
                              endif
                    endif
          else
                    rem Set background to black when Player 4 not active
                    COLUBK = ColGrey(0)  : rem Black
          endif
          
          return

          rem =================================================================
          rem DISPLAY HEALTH
          rem =================================================================
          rem Shows health status for all active players.
          rem Flashes sprites when health is critically low.
DisplayHealth
          rem Flash Player 1 sprite if health is low (but not during recovery)
          if PlayerHealth[0] < 25 && PlayerRecoveryFrames[0] = 0 then
                    if frame & 8 then player0x = 200  : rem Hide sprite
          endif

          rem Flash Player 2 sprite if health is low
          if PlayerHealth[1] < 25 && PlayerRecoveryFrames[1] = 0 then
                    if frame & 8 then player1x = 200
          endif

          rem Flash Player 3 sprite if health is low (but alive)
          if QuadtariDetected && SelectedChar3 != 0 && PlayerHealth[2] > 0 then
                    if PlayerHealth[2] < 25 && PlayerRecoveryFrames[2] = 0 then
                              if frame & 8 then missile1x = 200
                    endif
          endif

          rem Flash Player 4 sprite if health is low (but alive)
          if QuadtariDetected && SelectedChar4 != 0 && PlayerHealth[3] > 0 then
                    if PlayerHealth[3] < 25 && PlayerRecoveryFrames[3] = 0 then
                              if frame & 8 then ballx = 200
                    endif
          endif
          
          rem Draw health bars in playfield
          gosub DrawHealthBars
          
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
          rem
          rem Health bars are drawn using pfpixel and appropriate colors.
          rem Each bar is 32 pixels wide (max health = 100, scale to 32 pixels).
DrawHealthBars
          dim HealthBarLength = temp5
          
          rem Calculate effective B&W mode (accounts for 7800 Pause toggle)
#ifdef TV_SECAM
          temp6 = 0  : rem SECAM: Always use color mode
#else
          temp6 = switchbw ^ ColorBWOverride
#endif
          
          rem Draw Player 1 health bar
          HealthBarLength = PlayerHealth[0] / 3  : rem Scale 0-100 to 0-32
          if HealthBarLength > 32 then HealthBarLength = 32
          if temp6 then
                    COLUPF = ColGrey(14)  : rem White (B&W)
          else
                    COLUPF = ColBlue(12)  : rem Bright blue (Color)
          endif
          gosub DrawHealthBarRow0
          
          rem Draw Player 2 health bar
          HealthBarLength = PlayerHealth[1] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          if temp6 then
                    COLUPF = ColGrey(10)  : rem Medium-bright grey (B&W)
          else
                    COLUPF = ColRed(12)  : rem Bright red (Color)
          endif
          gosub DrawHealthBarRow1
          
          rem Draw Player 3 & 4 bars if Quadtari active and player alive
          if QuadtariDetected then
                    if SelectedChar3 != 0 && PlayerHealth[2] > 0 then
                              rem Player 3 health bar
                              HealthBarLength = PlayerHealth[2] / 3
                              if HealthBarLength > 32 then HealthBarLength = 32
                              if temp6 then
                                        COLUPF = ColGrey(8)  : rem Medium grey (B&W)
                              else
                                        COLUPF = ColYellow(12)  : rem Bright yellow (Color)
                              endif
                              gosub DrawHealthBarRow2
                    endif
                    
                    if SelectedChar4 != 0 && PlayerHealth[3] > 0 then
                              rem Player 4 health bar
                              HealthBarLength = PlayerHealth[3] / 3
                              if HealthBarLength > 32 then HealthBarLength = 32
                              if temp6 then
                                        COLUPF = ColGrey(6)  : rem Dark-medium grey (B&W)
                              else
                                        COLUPF = ColGreen(12)  : rem Bright green (Color)
                              endif
                              gosub DrawHealthBarRow3
                    endif
          endif
          
          return

          rem =================================================================
          rem HEALTH BAR ROW DRAWING HELPERS
          rem =================================================================
          rem These subroutines draw a single row of health bar at different
          rem Y positions. They use HealthBarLength (temp6) to determine width.

DrawHealthBarRow0
          rem Draw health bar at row 0 (top of screen)
          rem Clear the row first
          pfpixel 0 0 off : pfpixel 1 0 off : pfpixel 2 0 off : pfpixel 3 0 off
          pfpixel 4 0 off : pfpixel 5 0 off : pfpixel 6 0 off : pfpixel 7 0 off
          pfpixel 8 0 off : pfpixel 9 0 off : pfpixel 10 0 off : pfpixel 11 0 off
          pfpixel 12 0 off : pfpixel 13 0 off : pfpixel 14 0 off : pfpixel 15 0 off
          pfpixel 16 0 off : pfpixel 17 0 off : pfpixel 18 0 off : pfpixel 19 0 off
          pfpixel 20 0 off : pfpixel 21 0 off : pfpixel 22 0 off : pfpixel 23 0 off
          pfpixel 24 0 off : pfpixel 25 0 off : pfpixel 26 0 off : pfpixel 27 0 off
          pfpixel 28 0 off : pfpixel 29 0 off : pfpixel 30 0 off : pfpixel 31 0 off
          
          rem Draw filled portion
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
                    pfpixel PixelIndex 0 on
          next
          return

DrawHealthBarRow1
          rem Draw health bar at row 1
          pfpixel 0 1 off : pfpixel 1 1 off : pfpixel 2 1 off : pfpixel 3 1 off
          pfpixel 4 1 off : pfpixel 5 1 off : pfpixel 6 1 off : pfpixel 7 1 off
          pfpixel 8 1 off : pfpixel 9 1 off : pfpixel 10 1 off : pfpixel 11 1 off
          pfpixel 12 1 off : pfpixel 13 1 off : pfpixel 14 1 off : pfpixel 15 1 off
          pfpixel 16 1 off : pfpixel 17 1 off : pfpixel 18 1 off : pfpixel 19 1 off
          pfpixel 20 1 off : pfpixel 21 1 off : pfpixel 22 1 off : pfpixel 23 1 off
          pfpixel 24 1 off : pfpixel 25 1 off : pfpixel 26 1 off : pfpixel 27 1 off
          pfpixel 28 1 off : pfpixel 29 1 off : pfpixel 30 1 off : pfpixel 31 1 off
          
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
                    pfpixel PixelIndex 1 on
          next
          return

DrawHealthBarRow2
          rem Draw health bar at row 2
          pfpixel 0 2 off : pfpixel 1 2 off : pfpixel 2 2 off : pfpixel 3 2 off
          pfpixel 4 2 off : pfpixel 5 2 off : pfpixel 6 2 off : pfpixel 7 2 off
          pfpixel 8 2 off : pfpixel 9 2 off : pfpixel 10 2 off : pfpixel 11 2 off
          pfpixel 12 2 off : pfpixel 13 2 off : pfpixel 14 2 off : pfpixel 15 2 off
          pfpixel 16 2 off : pfpixel 17 2 off : pfpixel 18 2 off : pfpixel 19 2 off
          pfpixel 20 2 off : pfpixel 21 2 off : pfpixel 22 2 off : pfpixel 23 2 off
          pfpixel 24 2 off : pfpixel 25 2 off : pfpixel 26 2 off : pfpixel 27 2 off
          pfpixel 28 2 off : pfpixel 29 2 off : pfpixel 30 2 off : pfpixel 31 2 off
          
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
                    pfpixel PixelIndex 2 on
          next
          return

DrawHealthBarRow3
          rem Draw health bar at row 3
          pfpixel 0 3 off : pfpixel 1 3 off : pfpixel 2 3 off : pfpixel 3 3 off
          pfpixel 4 3 off : pfpixel 5 3 off : pfpixel 6 3 off : pfpixel 7 3 off
          pfpixel 8 3 off : pfpixel 9 3 off : pfpixel 10 3 off : pfpixel 11 3 off
          pfpixel 12 3 off : pfpixel 13 3 off : pfpixel 14 3 off : pfpixel 15 3 off
          pfpixel 16 3 off : pfpixel 17 3 off : pfpixel 18 3 off : pfpixel 19 3 off
          pfpixel 20 3 off : pfpixel 21 3 off : pfpixel 22 3 off : pfpixel 23 3 off
          pfpixel 24 3 off : pfpixel 25 3 off : pfpixel 26 3 off : pfpixel 27 3 off
          pfpixel 28 3 off : pfpixel 29 3 off : pfpixel 30 3 off : pfpixel 31 3 off
          
          dim PixelIndex = temp7
          for PixelIndex = 0 to HealthBarLength
                    pfpixel PixelIndex 3 on
          next
          return

