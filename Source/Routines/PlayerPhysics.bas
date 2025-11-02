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
          if (playerState[0] & 4) <> 0 then Player1GravityDone
          playerY[0] = playerY[0] + 1
          if playerY[0] < 80 then Player1GravityDone
          playerY[0] = 80
          playerState[0] = playerState[0] & NOT 4
Player1GravityDone
          
          rem Player 2
          if (playerState[1] & 4) <> 0 then Player2GravityDone
          playerY[1] = playerY[1] + 1
          if playerY[1] < 80 then Player2GravityDone
          playerY[1] = 80
          playerState[1] = playerState[1] & NOT 4
Player2GravityDone
          
          rem Player 3 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Jump
          if selectedChar3 = 255 then goto SkipPlayer3Jump
          if (playerState[2] & 4) <> 0 then goto SkipPlayer3Jump
          playerY[2] = playerY[2] + 1
          if playerY[2] < 80 then goto SkipPlayer3Jump
          playerY[2] = 80 : playerState[2] = playerState[2] & NOT 4
SkipPlayer3Jump
          
          rem Player 4 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Jump
          if selectedChar4 = 255 then goto SkipPlayer4Jump
          if (playerState[3] & 4) <> 0 then goto SkipPlayer4Jump
          playerY[3] = playerY[3] + 1
          if playerY[3] < 80 then goto SkipPlayer4Jump
          playerY[3] = 80 : playerState[3] = playerState[3] & NOT 4
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
          if ! playerRecoveryFrames[0] then goto SkipPlayer0Momentum
          if playerMomentumX[0] <= 0 then goto CheckPlayer0NegativeMomentum
          let playerMomentumX[0] = playerMomentumX[0] - 1
          goto SkipPlayer0Momentum
CheckPlayer0NegativeMomentum
          if playerMomentumX[0] >= 0 then goto SkipPlayer0Momentum
          let playerMomentumX[0] = playerMomentumX[0] + 1
SkipPlayer0Momentum

          rem Player 2
          if playerRecoveryFrames[1] > 0 then let playerRecoveryFrames[1] = playerRecoveryFrames[1] - 1 : let playerX[1] = playerX[1] + playerMomentumX[1]
          if ! playerRecoveryFrames[1] then goto SkipPlayer1Momentum
          if playerMomentumX[1] <= 0 then goto CheckPlayer1NegativeMomentum
          let playerMomentumX[1] = playerMomentumX[1] - 1
          goto SkipPlayer1Momentum
CheckPlayer1NegativeMomentum
          if playerMomentumX[1] >= 0 then goto SkipPlayer1Momentum
          let playerMomentumX[1] = playerMomentumX[1] + 1
SkipPlayer1Momentum

          rem Player 3 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Recovery
          if selectedChar3 = 255 then goto SkipPlayer3Recovery
          if ! playerRecoveryFrames[2] then goto SkipPlayer3Recovery
          let playerRecoveryFrames[2] = playerRecoveryFrames[2] - 1 : let playerX[2] = playerX[2] + playerMomentumX[2]
          if playerMomentumX[2] <= 0 then goto CheckPlayer3NegativeMomentum
          let playerMomentumX[2] = playerMomentumX[2] - 1
          goto SkipPlayer3Recovery
CheckPlayer3NegativeMomentum
          if playerMomentumX[2] >= 0 then goto SkipPlayer3Recovery
          let playerMomentumX[2] = playerMomentumX[2] + 1
SkipPlayer3Recovery

          rem Player 4 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Recovery
          if selectedChar4 = 255 then goto SkipPlayer4Recovery
          if ! playerRecoveryFrames[3] then goto SkipPlayer4Recovery
          let playerRecoveryFrames[3] = playerRecoveryFrames[3] - 1 : let playerX[3] = playerX[3] + playerMomentumX[3]
          if playerMomentumX[3] <= 0 then goto CheckPlayer4NegativeMomentum
          let playerMomentumX[3] = playerMomentumX[3] - 1
          goto SkipPlayer4Recovery
CheckPlayer4NegativeMomentum
          if playerMomentumX[3] >= 0 then goto SkipPlayer4Recovery
          let playerMomentumX[3] = playerMomentumX[3] + 1
SkipPlayer4Recovery
          
          return

          rem =================================================================
          rem CHECK BOUNDARY COLLISIONS
          rem =================================================================
          rem Prevents players from moving off-screen.
CheckBoundaryCollisions
          rem Player 1
          if playerX[0] < 10 then playerX[0] = 10
          if playerX[0] > 150 then playerX[0] = 150
          if playerY[0] < 20 then playerY[0] = 20
          if playerY[0] > 80 then playerY[0] = 80

          rem Player 2
          if playerX[1] < 10 then playerX[1] = 10
          if playerX[1] > 150 then playerX[1] = 150
          if playerY[1] < 20 then playerY[1] = 20
          if playerY[1] > 80 then playerY[1] = 80

          rem Player 3 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Bounds
          if selectedChar3 = 255 then goto SkipPlayer3Bounds
          goto ApplyPlayer3Bounds
          goto SkipPlayer3Bounds
ApplyPlayer3Bounds
          if playerX[2] < 10 then playerX[2] = 10
          if playerX[2] > 150 then playerX[2] = 150
          if playerY[2] < 20 then playerY[2] = 20
          if playerY[2] > 80 then playerY[2] = 80
SkipPlayer3Bounds

          rem Player 4 (Quadtari only)
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Bounds
          if selectedChar4 = 255 then goto SkipPlayer4Bounds
          goto ApplyPlayer4Bounds
          goto SkipPlayer4Bounds
ApplyPlayer4Bounds
          if playerX[3] < 10 then playerX[3] = 10
          if playerX[3] > 150 then playerX[3] = 150
          if playerY[3] < 20 then playerY[3] = 20
          if playerY[3] > 80 then playerY[3] = 80
SkipPlayer4Bounds
          
          return

          rem =================================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem =================================================================
          rem Checks collisions between players (for pushing, not damage).
          rem Players can walk through each other but are slightly pushed apart.
CheckAllPlayerCollisions
          rem Check Player 1 vs Player 2
          if playerX[0] >= playerX[1] then temp2 = playerX[0] - playerX[1] else temp2 = playerX[1] - playerX[0]
          if temp2 < 16 then if playerX[0] < playerX[1] then playerX[0] = playerX[0] - 1 : playerX[1] = playerX[1] + 1 : goto SkipP1P2Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[1] = playerX[1] - 1
SkipP1P2Sep
          
          
          
          rem Check other player combinations if Quadtari active
          if ! (controllerStatus & SetQuadtariDetected) then return
          
          rem Check Player 1 vs Player 3
          if selectedChar3 <> 255 then goto DoP1P3Check else goto SkipP1P3Check
DoP1P3Check
          if playerX[0] >= playerX[2] then temp2 = playerX[0] - playerX[2] else temp2 = playerX[2] - playerX[0]
          if temp2 < 16 then if playerX[0] < playerX[2] then playerX[0] = playerX[0] - 1 : playerX[2] = playerX[2] + 1 : goto SkipP1P3Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[2] = playerX[2] - 1
SkipP1P3Sep
SkipP1P3Check
          
          
          
          
          rem Check Player 1 vs Player 4
          if selectedChar4 <> 255 then goto DoP1P4Check else goto SkipP1P4Check
DoP1P4Check
          if playerX[0] >= playerX[3] then temp2 = playerX[0] - playerX[3] else temp2 = playerX[3] - playerX[0]
          if temp2 < 16 then if playerX[0] < playerX[3] then playerX[0] = playerX[0] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP1P4Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[3] = playerX[3] - 1
SkipP1P4Sep
SkipP1P4Check
          
          
          
          
          rem Check Player 2 vs Player 3
          if selectedChar3 <> 255 then goto DoP2P3Check else goto SkipP2P3Check
DoP2P3Check
          if playerX[1] >= playerX[2] then temp2 = playerX[1] - playerX[2] else temp2 = playerX[2] - playerX[1]
          if temp2 < 16 then if playerX[1] < playerX[2] then playerX[1] = playerX[1] - 1 : playerX[2] = playerX[2] + 1 : goto SkipP2P3Sep
          if temp2 < 16 then playerX[1] = playerX[1] + 1 : playerX[2] = playerX[2] - 1
SkipP2P3Sep
SkipP2P3Check
          
          
          
          
          rem Check Player 2 vs Player 4
          if selectedChar4 <> 255 then goto DoP2P4Check else goto SkipP2P4Check
DoP2P4Check
          if playerX[1] >= playerX[3] then temp2 = playerX[1] - playerX[3] else temp2 = playerX[3] - playerX[1]
          if temp2 < 16 then if playerX[1] < playerX[3] then playerX[1] = playerX[1] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP2P4Sep
          if temp2 < 16 then playerX[1] = playerX[1] + 1 : playerX[3] = playerX[3] - 1
SkipP2P4Sep
SkipP2P4Check
          
          
          
          
          rem Check Player 3 vs Player 4
          if selectedChar3 = 255 then goto SkipP3vsP4
          if selectedChar4 = 255 then goto SkipP3vsP4 
          if playerX[2] >= playerX[3] then temp2 = playerX[2] - playerX[3] else temp2 = playerX[3] - playerX[2]
          if temp2 < 16 then if playerX[2] < playerX[3] then playerX[2] = playerX[2] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP3P4Sep
          if temp2 < 16 then playerX[2] = playerX[2] + 1 : playerX[3] = playerX[3] - 1
SkipP3P4Sep
          
          
          
          
          return

