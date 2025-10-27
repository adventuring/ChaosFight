          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER PHYSICS
          rem =================================================================
          rem Handles gravity, momentum, collisions, and recovery for all players.
          rem
          rem AVAILABLE VARIABLES:
          rem   PlayerX[0-3], PlayerY[0-3] - Positions
          rem   PlayerState[0-3] - State flags
          rem   PlayerMomentumX[0-3] - Horizontal momentum
          rem   PlayerRecoveryFrames[0-3] - Recovery (hitstun) frames remaining
          rem   QuadtariDetected - Whether 4-player mode active
          rem   SelectedChar3, SelectedChar4 - Player 3/4 selections
          rem =================================================================

          rem =================================================================
          rem APPLY GRAVITY
          rem =================================================================
          rem Applies gravity to all jumping players, landing them when they
          rem reach the ground level (Y=80).
ApplyGravity
          rem Player 1
          if IsPlayerJumping(PlayerState[0]) then
                    PlayerY[0] = PlayerY[0] + 1
                    if PlayerY[0] >= 80 then
                              PlayerY[0] = 80
                              PlayerState[0] = ClearPlayerJumping(PlayerState[0])
                    endif
          endif
          
          rem Player 2
          if IsPlayerJumping(PlayerState[1]) then
                    PlayerY[1] = PlayerY[1] + 1
                    if PlayerY[1] >= 80 then
                              PlayerY[1] = 80
                              PlayerState[1] = ClearPlayerJumping(PlayerState[1])
                    endif
          endif
          
          rem Player 3 (Quadtari only)
          if QuadtariDetected && SelectedChar3 != 0 then
                    if IsPlayerJumping(PlayerState[2]) then
                              PlayerY[2] = PlayerY[2] + 1
                              if PlayerY[2] >= 80 then
                                        PlayerY[2] = 80
                                        PlayerState[2] = ClearPlayerJumping(PlayerState[2])
                              endif
                    endif
          endif
          
          rem Player 4 (Quadtari only)
          if QuadtariDetected && SelectedChar4 != 0 then
                    if IsPlayerJumping(PlayerState[3]) then
                              PlayerY[3] = PlayerY[3] + 1
                              if PlayerY[3] >= 80 then
                                        PlayerY[3] = 80
                                        PlayerState[3] = ClearPlayerJumping(PlayerState[3])
                              endif
                    endif
          endif
          
          return

          rem =================================================================
          rem APPLY MOMENTUM AND RECOVERY
          rem =================================================================
          rem Updates recovery frames and applies momentum during hitstun.
          rem Momentum gradually decays over time.
ApplyMomentumAndRecovery
          rem Player 1
          if PlayerRecoveryFrames[0] > 0 then
                    PlayerRecoveryFrames[0] = PlayerRecoveryFrames[0] - 1
                    PlayerX[0] = PlayerX[0] + PlayerMomentumX[0]
                    rem Decay momentum
                    if PlayerMomentumX[0] > 0 then
                              PlayerMomentumX[0] = PlayerMomentumX[0] - 1
                    else
                              if PlayerMomentumX[0] < 0 then PlayerMomentumX[0] = PlayerMomentumX[0] + 1
                    endif
          endif

          rem Player 2
          if PlayerRecoveryFrames[1] > 0 then
                    PlayerRecoveryFrames[1] = PlayerRecoveryFrames[1] - 1
                    PlayerX[1] = PlayerX[1] + PlayerMomentumX[1]
                    if PlayerMomentumX[1] > 0 then
                              PlayerMomentumX[1] = PlayerMomentumX[1] - 1
                    else
                              if PlayerMomentumX[1] < 0 then PlayerMomentumX[1] = PlayerMomentumX[1] + 1
                    endif
          endif

          rem Player 3 (Quadtari only)
          if QuadtariDetected && SelectedChar3 != 0 then
                    if PlayerRecoveryFrames[2] > 0 then
                              PlayerRecoveryFrames[2] = PlayerRecoveryFrames[2] - 1
                              PlayerX[2] = PlayerX[2] + PlayerMomentumX[2]
                              if PlayerMomentumX[2] > 0 then
                                        PlayerMomentumX[2] = PlayerMomentumX[2] - 1
                              else
                                        if PlayerMomentumX[2] < 0 then PlayerMomentumX[2] = PlayerMomentumX[2] + 1
                              endif
                    endif
          endif

          rem Player 4 (Quadtari only)
          if QuadtariDetected && SelectedChar4 != 0 then
                    if PlayerRecoveryFrames[3] > 0 then
                              PlayerRecoveryFrames[3] = PlayerRecoveryFrames[3] - 1
                              PlayerX[3] = PlayerX[3] + PlayerMomentumX[3]
                              if PlayerMomentumX[3] > 0 then
                                        PlayerMomentumX[3] = PlayerMomentumX[3] - 1
                              else
                                        if PlayerMomentumX[3] < 0 then PlayerMomentumX[3] = PlayerMomentumX[3] + 1
                              endif
                    endif
          endif
          
          return

          rem =================================================================
          rem CHECK BOUNDARY COLLISIONS
          rem =================================================================
          rem Prevents players from moving off-screen.
CheckBoundaryCollisions
          rem Player 1
          if PlayerX[0] < 10 then PlayerX[0] = 10
          if PlayerX[0] > 150 then PlayerX[0] = 150
          if PlayerY[0] < 20 then PlayerY[0] = 20
          if PlayerY[0] > 80 then PlayerY[0] = 80

          rem Player 2
          if PlayerX[1] < 10 then PlayerX[1] = 10
          if PlayerX[1] > 150 then PlayerX[1] = 150
          if PlayerY[1] < 20 then PlayerY[1] = 20
          if PlayerY[1] > 80 then PlayerY[1] = 80

          rem Player 3 (Quadtari only)
          if QuadtariDetected && SelectedChar3 != 0 then
                    if PlayerX[2] < 10 then PlayerX[2] = 10
                    if PlayerX[2] > 150 then PlayerX[2] = 150
                    if PlayerY[2] < 20 then PlayerY[2] = 20
                    if PlayerY[2] > 80 then PlayerY[2] = 80
          endif

          rem Player 4 (Quadtari only)
          if QuadtariDetected && SelectedChar4 != 0 then
                    if PlayerX[3] < 10 then PlayerX[3] = 10
                    if PlayerX[3] > 150 then PlayerX[3] = 150
                    if PlayerY[3] < 20 then PlayerY[3] = 20
                    if PlayerY[3] > 80 then PlayerY[3] = 80
          endif
          
          return

          rem =================================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem =================================================================
          rem Checks collisions between players (for pushing, not damage).
          rem Players can walk through each other but are slightly pushed apart.
CheckAllPlayerCollisions
          dim Distance = temp2
          
          rem Check Player 1 vs Player 2
          Distance = PlayerX[0] - PlayerX[1]
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if PlayerX[0] < PlayerX[1] then
                              PlayerX[0] = PlayerX[0] - 1
                              PlayerX[1] = PlayerX[1] + 1
                    else
                              PlayerX[0] = PlayerX[0] + 1
                              PlayerX[1] = PlayerX[1] - 1
                    endif
          endif
          
          rem Check other player combinations if Quadtari active
          if !QuadtariDetected then return
          
          rem Check Player 1 vs Player 3
          if SelectedChar3 != 0 then
                    Distance = PlayerX[0] - PlayerX[2]
                    if Distance < 0 then Distance = -Distance
                    if Distance < 16 then
                              if PlayerX[0] < PlayerX[2] then
                                        PlayerX[0] = PlayerX[0] - 1
                                        PlayerX[2] = PlayerX[2] + 1
                              else
                                        PlayerX[0] = PlayerX[0] + 1
                                        PlayerX[2] = PlayerX[2] - 1
                              endif
                    endif
          endif
          
          rem Check Player 1 vs Player 4
          if SelectedChar4 != 0 then
                    Distance = PlayerX[0] - PlayerX[3]
                    if Distance < 0 then Distance = -Distance
                    if Distance < 16 then
                              if PlayerX[0] < PlayerX[3] then
                                        PlayerX[0] = PlayerX[0] - 1
                                        PlayerX[3] = PlayerX[3] + 1
                              else
                                        PlayerX[0] = PlayerX[0] + 1
                                        PlayerX[3] = PlayerX[3] - 1
                              endif
                    endif
          endif
          
          rem Check Player 2 vs Player 3
          if SelectedChar3 != 0 then
                    Distance = PlayerX[1] - PlayerX[2]
                    if Distance < 0 then Distance = -Distance
                    if Distance < 16 then
                              if PlayerX[1] < PlayerX[2] then
                                        PlayerX[1] = PlayerX[1] - 1
                                        PlayerX[2] = PlayerX[2] + 1
                              else
                                        PlayerX[1] = PlayerX[1] + 1
                                        PlayerX[2] = PlayerX[2] - 1
                              endif
                    endif
          endif
          
          rem Check Player 2 vs Player 4
          if SelectedChar4 != 0 then
                    Distance = PlayerX[1] - PlayerX[3]
                    if Distance < 0 then Distance = -Distance
                    if Distance < 16 then
                              if PlayerX[1] < PlayerX[3] then
                                        PlayerX[1] = PlayerX[1] - 1
                                        PlayerX[3] = PlayerX[3] + 1
                              else
                                        PlayerX[1] = PlayerX[1] + 1
                                        PlayerX[3] = PlayerX[3] - 1
                              endif
                    endif
          endif
          
          rem Check Player 3 vs Player 4
          if SelectedChar3 != 0 && SelectedChar4 != 0 then
                    Distance = PlayerX[2] - PlayerX[3]
                    if Distance < 0 then Distance = -Distance
                    if Distance < 16 then
                              if PlayerX[2] < PlayerX[3] then
                                        PlayerX[2] = PlayerX[2] - 1
                                        PlayerX[3] = PlayerX[3] + 1
                              else
                                        PlayerX[2] = PlayerX[2] + 1
                                        PlayerX[3] = PlayerX[3] - 1
                              endif
                    endif
          endif
          
          return

