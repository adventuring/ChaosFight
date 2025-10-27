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
          if QuadtariDetected && SelectedChar3 != 0 then
                    missile1x = PlayerX[2]
                    missile1y = PlayerY[2]
                    ENAM1 = 1
          else
                    ENAM1 = 0
          endif

          if QuadtariDetected && SelectedChar4 != 0 then
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
SetPlayerSprites
          rem Set Player 1 color and sprite
          if PlayerRecoveryFrames[0] > 0 then
                    COLUP0 = ColIndigo(6)  : rem Dark indigo for hurt
          else
                    if switchbw then
                              COLUP0 = ColIndigo(12)  : rem Bright indigo
                    else
                              rem TODO: Load from XCF artwork colors
                              COLUP0 = ColIndigo(12)
                    endif
          endif

          rem TODO: Load sprite data from character definition
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

          rem Set Player 2 color and sprite
          if PlayerRecoveryFrames[1] > 0 then
                    COLUP1 = ColRed(6)  : rem Dark red for hurt
          else
                    if switchbw then
                              COLUP1 = ColRed(12)  : rem Bright red
                    else
                              rem TODO: Load from XCF artwork colors
                              COLUP1 = ColRed(12)
                    endif
          endif

          rem TODO: Load sprite data from character definition
          player1:
          %00011000
          %00111100
          %01111110
          %00011000
          %00011000
          %00011000
          %00011000
          %00011000
          end

          rem Set colors for Players 3 & 4
          if QuadtariDetected && SelectedChar3 != 0 then
                    if PlayerRecoveryFrames[2] > 0 then
                              COLUPF = ColYellow(6)  : rem Dark yellow for hurt
                    else
                              if switchbw then
                                        COLUPF = ColYellow(12)
                              else
                                        COLUPF = ColYellow(12)
                              endif
                    endif
          endif

          if QuadtariDetected && SelectedChar4 != 0 then
                    if PlayerRecoveryFrames[3] > 0 then
                              COLUBK = ColGreen(6)  : rem Dark green for hurt
                    else
                              if switchbw then
                                        COLUBK = ColGreen(12)
                              else
                                        COLUBK = ColGreen(12)
                              endif
                    endif
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

          rem Flash Player 3 sprite if health is low
          if QuadtariDetected && SelectedChar3 != 0 then
                    if PlayerHealth[2] < 25 && PlayerRecoveryFrames[2] = 0 then
                              if frame & 8 then missile1x = 200
                    endif
          endif

          rem Flash Player 4 sprite if health is low
          if QuadtariDetected && SelectedChar4 != 0 then
                    if PlayerHealth[3] < 25 && PlayerRecoveryFrames[3] = 0 then
                              if frame & 8 then ballx = 200
                    endif
          endif
          
          return

