          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER PHYSICS
          rem =================================================================
          rem Handles gravity, momentum, collisions, and recovery for all players.

          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem   playerMomentumX[0-3] - Horizontal momentum
          rem   playerRecoveryFrames[0-3] - Recovery (hitstun) frames remaining
          rem   QuadtariDetected - Whether 4-player mode active
          rem   selectedChar3, selectedChar4 - Player 3/4 selections
          rem =================================================================

          rem =================================================================
          rem APPLY GRAVITY
          rem =================================================================
          rem Applies gravity to all jumping players, landing them when they
          rem reach the ground level (Y=80).
PhysicsApplyGravity
          rem Player 1
          if (playerState[0] & 4) = 0 then ApplyPlayer1Gravity
          goto Player1GravityDone
ApplyPlayer1Gravity
          rem Skip gravity for Frooty (8) and DragonOfStorms (2)
          if playerChar[0] = 2 then Player1GravityDone
          if playerChar[0] = 8 then Player1GravityDone
          rem Skip gravity for RoboTito when latched to ceiling
          if playerChar[0] = 13 then RoboTitoGravity1
          goto RoboTitoGravityDone1
RoboTitoGravity1
          if (characterStateFlags[0] & 1) = 0 then ApplyPlayer1GravityAfterCheck
          goto Player1GravityDone
ApplyPlayer1GravityAfterCheck
          rem Not latched to ceiling, apply gravity
RoboTitoGravityDone1
          rem Apply slow gravity for Harpy in flight mode but not diving
          if playerChar[0] = 6 then Player1HarpyGravity
          let playerY[0] = playerY[0] + 1
          goto Player1GravityCheck
Player1HarpyGravity
          rem Harpy slow gravity: 50% speed unless diving
          if (characterStateFlags[0] & 4) = 0 then Player1SlowGravity
          goto Player1NormalGravity
Player1SlowGravity
          rem Not diving: slow gravity
          let playerY[0] = playerY[0] + 1
          goto Player1GravityCheck
Player1NormalGravity
          let playerY[0] = playerY[0] + 1
Player1GravityCheck
          if playerY[0] < 80 then Player1GravityDone
          let playerY[0] = 80
          let playerState[0] = playerState[0] & 251
          rem Reset Harpy flight energy and clear dive flag on landing
          if playerChar[0] = 6 then let harpyFlightEnergy_W[0] = 60
          rem Reset to full energy (60 frames = 1 second at 60fps)
          if playerChar[0] = 6 then characterStateFlags[0] = characterStateFlags[0] & 251
          rem Clear dive mode flag (bit 2)
Player1GravityDone
          
          rem Player 2
          if (playerState[1] & 4) = 0 then ApplyPlayer2Gravity
          goto Player2GravityDone
ApplyPlayer2Gravity
          rem Skip gravity for Frooty (8) and DragonOfStorms (2)
          if playerChar[1] = 2 then Player2GravityDone
          if playerChar[1] = 8 then Player2GravityDone
          rem Skip gravity for RoboTito when latched to ceiling
          if playerChar[1] = 13 then RoboTitoGravity2
          goto RoboTitoGravityDone2
RoboTitoGravity2
          if (characterStateFlags[1] & 1) = 0 then ApplyPlayer2GravityAfterCheck
          goto Player2GravityDone
ApplyPlayer2GravityAfterCheck
          rem Not latched to ceiling, apply gravity
RoboTitoGravityDone2
          rem Apply slow gravity for Harpy in flight mode but not diving
          if playerChar[1] = 6 then Player2HarpyGravity
          let playerY[1] = playerY[1] + 1
          goto Player2GravityCheck
Player2HarpyGravity
          rem Harpy slow gravity: 50% speed unless diving
          if (characterStateFlags[1] & 4) = 0 then Player2SlowGravity
          goto Player2NormalGravity
Player2SlowGravity
          rem Not diving: slow gravity
          let playerY[1] = playerY[1] + 1
          goto Player2GravityCheck
Player2NormalGravity
          let playerY[1] = playerY[1] + 1
Player2GravityCheck
          if playerY[1] < 80 then Player2GravityDone
          let playerY[1] = 80
          let playerState[1] = playerState[1] & 251
          rem Reset Harpy flight energy and clear dive flag on landing
          if playerChar[1] = 6 then let harpyFlightEnergy_W[1] = 60
          rem Reset to full energy (60 frames = 1 second at 60fps)
          if playerChar[1] = 6 then characterStateFlags[1] = characterStateFlags[1] & 251
          rem Clear dive mode flag (bit 2)
Player2GravityDone
          
          rem Player 3 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then SkipPlayer3Jump
          if selectedChar3  = 255 then SkipPlayer3Jump
          if (playerState[2] & 4) = 0 then ApplyPlayer3Gravity
          goto SkipPlayer3Jump
ApplyPlayer3Gravity
          rem Skip gravity for Frooty (8) and DragonOfStorms (2)
          if playerChar[2] = 2 then SkipPlayer3Jump
          if playerChar[2] = 8 then SkipPlayer3Jump
          rem Skip gravity for RoboTito when latched to ceiling
          if playerChar[2] = 13 then RoboTitoGravity3
          goto RoboTitoGravityDone3
RoboTitoGravity3
          if (characterStateFlags[2] & 1) = 0 then ApplyPlayer3GravityAfterCheck
          goto SkipPlayer3Jump
ApplyPlayer3GravityAfterCheck
          rem Not latched to ceiling, apply gravity
RoboTitoGravityDone3
          rem Apply slow gravity for Harpy in flight mode but not diving
          if playerChar[2] = 6 then Player3HarpyGravity
          let playerY[2] = playerY[2] + 1
          goto Player3GravityCheck
Player3HarpyGravity
          rem Harpy slow gravity: 50% speed unless diving
          if (characterStateFlags[2] & 4) = 0 then Player3SlowGravity
          goto Player3NormalGravity
Player3SlowGravity
          rem Not diving: slow gravity
          let playerY[2] = playerY[2] + 1
          goto Player3GravityCheck
Player3NormalGravity
          let playerY[2] = playerY[2] + 1
Player3GravityCheck
          if playerY[2] < 80 then SkipPlayer3Jump
          let playerY[2] = 80 : playerState[2] = playerState[2] & 251
          rem Reset Harpy flight energy and clear dive flag on landing
          if playerChar[2] = 6 then let harpyFlightEnergy_W[2] = 60
          rem Reset to full energy (60 frames = 1 second at 60fps)
          if playerChar[2] = 6 then characterStateFlags[2] = characterStateFlags[2] & 251
          rem Clear dive mode flag (bit 2)
SkipPlayer3Jump
          
          rem Player 4 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then SkipPlayer4Jump
          if selectedChar4  = 255 then SkipPlayer4Jump
          if (playerState[3] & 4) = 0 then ApplyPlayer4Gravity
          goto SkipPlayer4Jump
ApplyPlayer4Gravity
          rem Skip gravity for Frooty (8) and DragonOfStorms (2)
          if playerChar[3] = 2 then SkipPlayer4Jump
          if playerChar[3] = 8 then SkipPlayer4Jump
          rem Skip gravity for RoboTito when latched to ceiling
          if playerChar[3] = 13 then RoboTitoGravity4
          goto RoboTitoGravityDone4
RoboTitoGravity4
          if (characterStateFlags[3] & 1) = 0 then ApplyPlayer4GravityAfterCheck
          goto SkipPlayer4Jump
ApplyPlayer4GravityAfterCheck
          rem Not latched to ceiling, apply gravity
RoboTitoGravityDone4
          rem Apply slow gravity for Harpy in flight mode but not diving
          if playerChar[3] = 6 then Player4HarpyGravity
          let playerY[3] = playerY[3] + 1
          goto Player4GravityCheck
Player4HarpyGravity
          rem Harpy slow gravity: 50% speed unless diving
          if (characterStateFlags[3] & 4) = 0 then Player4SlowGravity
          goto Player4NormalGravity
Player4SlowGravity
          rem Not diving: slow gravity
          let playerY[3] = playerY[3] + 1
          goto Player4GravityCheck
Player4NormalGravity
          let playerY[3] = playerY[3] + 1
Player4GravityCheck
          if playerY[3] < 80 then SkipPlayer4Jump
          let playerY[3] = 80 : playerState[3] = playerState[3] & 251
          rem Reset Harpy flight energy and clear dive flag on landing
          if playerChar[3] = 6 then let harpyFlightEnergy_W[3] = 60
          rem Reset to full energy (60 frames = 1 second at 60fps)
          if playerChar[3] = 6 then characterStateFlags[3] = characterStateFlags[3] & 251
          rem Clear dive mode flag (bit 2)
SkipPlayer4Jump
          
          return

          rem =================================================================
          rem APPLY MOMENTUM AND RECOVERY
          rem =================================================================
          rem Updates recovery frames and applies momentum during hitstun.
          rem Momentum gradually decays over time.
ApplyMomentumAndRecovery
          rem Player 1
          if playerRecoveryFrames[0] > 0 then let playerRecoveryFrames[0] = playerRecoveryFrames[0] - 1 : let playerX[0] = playerX[0] + playerMomentumX[0]
          if ! playerRecoveryFrames[0] then SkipPlayer0Momentum
          if playerMomentumX[0] <= 0 then CheckPlayer0NegativeMomentum
          let playerMomentumX[0] = playerMomentumX[0] - 1
          goto SkipPlayer0Momentum
CheckPlayer0NegativeMomentum
          if playerMomentumX[0] >= 0 then SkipPlayer0Momentum
          let playerMomentumX[0] = playerMomentumX[0] + 1
SkipPlayer0Momentum

          rem Player 2
          if playerRecoveryFrames[1] > 0 then let playerRecoveryFrames[1] = playerRecoveryFrames[1] - 1 : let playerX[1] = playerX[1] + playerMomentumX[1]
          if ! playerRecoveryFrames[1] then SkipPlayer1Momentum
          if playerMomentumX[1] <= 0 then CheckPlayer1NegativeMomentum
          let playerMomentumX[1] = playerMomentumX[1] - 1
          goto SkipPlayer1Momentum
CheckPlayer1NegativeMomentum
          if playerMomentumX[1] >= 0 then SkipPlayer1Momentum
          let playerMomentumX[1] = playerMomentumX[1] + 1
SkipPlayer1Momentum

          rem Player 3 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then SkipPlayer3Recovery
          if selectedChar3  = 255 then SkipPlayer3Recovery
          if ! playerRecoveryFrames[2] then SkipPlayer3Recovery
          let playerRecoveryFrames[2] = playerRecoveryFrames[2] - 1 : let playerX[2] = playerX[2] + playerMomentumX[2]
          if playerMomentumX[2] <= 0 then CheckPlayer3NegativeMomentum
          let playerMomentumX[2] = playerMomentumX[2] - 1
          goto SkipPlayer3Recovery
CheckPlayer3NegativeMomentum
          if playerMomentumX[2] >= 0 then SkipPlayer3Recovery
          let playerMomentumX[2] = playerMomentumX[2] + 1
SkipPlayer3Recovery

          rem Player 4 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then SkipPlayer4Recovery
          if selectedChar4  = 255 then SkipPlayer4Recovery
          if ! playerRecoveryFrames[3] then SkipPlayer4Recovery
          let playerRecoveryFrames[3] = playerRecoveryFrames[3] - 1 : let playerX[3] = playerX[3] + playerMomentumX[3]
          if playerMomentumX[3] <= 0 then CheckPlayer4NegativeMomentum
          let playerMomentumX[3] = playerMomentumX[3] - 1
          goto SkipPlayer4Recovery
CheckPlayer4NegativeMomentum
          if playerMomentumX[3] >= 0 then SkipPlayer4Recovery
          let playerMomentumX[3] = playerMomentumX[3] + 1
SkipPlayer4Recovery
          
          return

          rem =================================================================
          rem CHECK BOUNDARY COLLISIONS
          rem =================================================================
          rem Prevents players from moving off-screen.
          rem When falling off bottom: Bernie respawns at top, others die instantly.
CheckBoundaryCollisions
          rem Player 1
          if playerX[0] < 10 then playerX[0] = 10
          if playerX[0] > 150 then playerX[0] = 150
          if playerY[0] < 20 then playerY[0] = 20
          if playerY[0] > 80 then CheckPlayer0Falling
          goto SkipPlayer0Falling
CheckPlayer0Falling
          rem Check if Bernie (character 0) - respawn at top
          if playerChar[0] = 0 then RespawnBernie0
          rem All other characters: instant kill
          let playerHealth[0] = 0
          goto SkipPlayer0Falling
RespawnBernie0
          rem Bernie respawns at top of screen at same X position
          let playerY[0] = 20
SkipPlayer0Falling

          rem Player 2
          if playerX[1] < 10 then playerX[1] = 10
          if playerX[1] > 150 then playerX[1] = 150
          if playerY[1] < 20 then playerY[1] = 20
          if playerY[1] > 80 then CheckPlayer1Falling
          goto SkipPlayer1Falling
CheckPlayer1Falling
          rem Check if Bernie (character 0) - respawn at top
          if playerChar[1] = 0 then RespawnBernie1
          rem All other characters: instant kill
          let playerHealth[1] = 0
          goto SkipPlayer1Falling
RespawnBernie1
          rem Bernie respawns at top of screen at same X position
          let playerY[1] = 20
SkipPlayer1Falling

          rem Player 3 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then SkipPlayer3Bounds
          if selectedChar3  = 255 then SkipPlayer3Bounds
          goto ApplyPlayer3Bounds
          goto SkipPlayer3Bounds
ApplyPlayer3Bounds
          if playerX[2] < 10 then playerX[2] = 10
          if playerX[2] > 150 then playerX[2] = 150
          if playerY[2] < 20 then playerY[2] = 20
          if playerY[2] > 80 then CheckPlayer2Falling
          goto SkipPlayer2Falling
CheckPlayer2Falling
          rem Check if Bernie (character 0) - respawn at top
          if playerChar[2] = 0 then RespawnBernie2
          rem All other characters: instant kill
          let playerHealth[2] = 0
          goto SkipPlayer2Falling
RespawnBernie2
          rem Bernie respawns at top of screen at same X position
          let playerY[2] = 20
SkipPlayer2Falling
SkipPlayer3Bounds

          rem Player 4 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then SkipPlayer4Bounds
          if selectedChar4  = 255 then SkipPlayer4Bounds
          goto ApplyPlayer4Bounds
          goto SkipPlayer4Bounds
ApplyPlayer4Bounds
          if playerX[3] < 10 then playerX[3] = 10
          if playerX[3] > 150 then playerX[3] = 150
          if playerY[3] < 20 then playerY[3] = 20
          if playerY[3] > 80 then CheckPlayer3Falling
          goto SkipPlayer3Falling
CheckPlayer3Falling
          rem Check if Bernie (character 0) - respawn at top
          if playerChar[3] = 0 then RespawnBernie3
          rem All other characters: instant kill
          let playerHealth[3] = 0
          goto SkipPlayer3Falling
RespawnBernie3
          rem Bernie respawns at top of screen at same X position
          let playerY[3] = 20
SkipPlayer3Falling
SkipPlayer4Bounds
          
          return

          rem =================================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem =================================================================
          rem Checks collisions between players (for pushing, not damage).
          rem Players can walk through each other but are slightly pushed apart.
CheckAllPlayerCollisions
          rem Check Player 1 vs Player 2
          if playerX[0] >= playerX[1] then CalcP1vsP2AbsDiffP
          temp2 = playerX[1] - playerX[0]
          goto SkipCalcP1vsP2DiffP
CalcP1vsP2AbsDiffP
          temp2 = playerX[0] - playerX[1]
SkipCalcP1vsP2DiffP
          if temp2 < 16 then if playerX[0] < playerX[1] then playerX[0] = playerX[0] - 1 : playerX[1] = playerX[1] + 1 : goto SkipP1P2Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[1] = playerX[1] - 1
SkipP1P2Sep
          
          
          
          rem Check other player combinations if Quadtari active
          if ! (controllerStatus & SetQuadtariDetected) then return
          
          rem Check Player 1 vs Player 3
          if selectedChar3 = 255 then goto SkipP1P3Check
          goto DoP1P3Check
DoP1P3Check
          if playerX[0] >= playerX[2] then CalcP1vsP3AbsDiffP
          temp2 = playerX[2] - playerX[0]
          goto SkipCalcP1vsP3DiffP
CalcP1vsP3AbsDiffP
          temp2 = playerX[0] - playerX[2]
SkipCalcP1vsP3DiffP
          if temp2 < 16 then if playerX[0] < playerX[2] then playerX[0] = playerX[0] - 1 : playerX[2] = playerX[2] + 1 : goto SkipP1P3Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[2] = playerX[2] - 1
SkipP1P3Sep
SkipP1P3Check
          
          
          
          
          rem Check Player 1 vs Player 4
          if selectedChar4 = 255 then goto SkipP1P4Check
          goto DoP1P4Check
DoP1P4Check
          if playerX[0] >= playerX[3] then CalcP1vsP4AbsDiffP
          temp2 = playerX[3] - playerX[0]
          goto SkipCalcP1vsP4DiffP
CalcP1vsP4AbsDiffP
          temp2 = playerX[0] - playerX[3]
SkipCalcP1vsP4DiffP
          if temp2 < 16 then if playerX[0] < playerX[3] then playerX[0] = playerX[0] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP1P4Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[3] = playerX[3] - 1
SkipP1P4Sep
SkipP1P4Check
          
          
          
          
          rem Check Player 2 vs Player 3
          if selectedChar3 = 255 then goto SkipP2P3Check
          goto DoP2P3Check
DoP2P3Check
          if playerX[1] >= playerX[2] then CalcP2vsP3AbsDiffP
          temp2 = playerX[2] - playerX[1]
          goto SkipCalcP2vsP3DiffP
CalcP2vsP3AbsDiffP
          temp2 = playerX[1] - playerX[2]
SkipCalcP2vsP3DiffP
          if temp2 < 16 then if playerX[1] < playerX[2] then playerX[1] = playerX[1] - 1 : playerX[2] = playerX[2] + 1 : goto SkipP2P3Sep
          if temp2 < 16 then playerX[1] = playerX[1] + 1 : playerX[2] = playerX[2] - 1
SkipP2P3Sep
SkipP2P3Check
          
          
          
          
          rem Check Player 2 vs Player 4
          if selectedChar4 = 255 then goto SkipP2P4Check
          goto DoP2P4Check
DoP2P4Check
          if playerX[1] >= playerX[3] then CalcP2vsP4AbsDiffP
          temp2 = playerX[3] - playerX[1]
          goto SkipCalcP2vsP4DiffP
CalcP2vsP4AbsDiffP
          temp2 = playerX[1] - playerX[3]
SkipCalcP2vsP4DiffP
          if temp2 < 16 then if playerX[1] < playerX[3] then playerX[1] = playerX[1] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP2P4Sep
          if temp2 < 16 then playerX[1] = playerX[1] + 1 : playerX[3] = playerX[3] - 1
SkipP2P4Sep
SkipP2P4Check
          
          
          
          
          rem Check Player 3 vs Player 4
          if selectedChar3  = 255 then goto SkipP3vsP4
          if selectedChar4  = 255 then goto SkipP3vsP4
          if playerX[2] >= playerX[3] then CalcP3vsP4AbsDiffP
          temp2 = playerX[3] - playerX[2]
          goto SkipCalcP3vsP4DiffP
CalcP3vsP4AbsDiffP
          temp2 = playerX[2] - playerX[3]
SkipCalcP3vsP4DiffP
          if temp2 < 16 then if playerX[2] < playerX[3] then playerX[2] = playerX[2] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP3P4Sep
          if temp2 < 16 then playerX[2] = playerX[2] + 1 : playerX[3] = playerX[3] - 1
SkipP3P4Sep
          
          
          
          
          return

