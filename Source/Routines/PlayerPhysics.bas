          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER PHYSICS
          rem =================================================================
          rem Handles gravity, momentum, collisions, and recovery for all players.

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
PhysicsApplyGravity
          rem Player 1
          if (PlayerState[0] & 4) <> 0 then Player1GravityDone
          PlayerY[0] = PlayerY[0] + 1
          if PlayerY[0] < 80 then Player1GravityDone
          PlayerY[0] = 80
          PlayerState[0] = PlayerState[0] & NOT 4
Player1GravityDone
          
          rem Player 2
          if (PlayerState[1] & 4) <> 0 then Player2GravityDone
          PlayerY[1] = PlayerY[1] + 1
          if PlayerY[1] < 80 then Player2GravityDone
          PlayerY[1] = 80
          PlayerState[1] = PlayerState[1] & NOT 4
Player2GravityDone
          
          rem Player 3 (Quadtari only)
          if 0 = (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Jump
          if SelectedChar3 = 255 then goto SkipPlayer3Jump
          if (PlayerState[2] & 4) <> 0 then goto SkipPlayer3Jump
          PlayerY[2] = PlayerY[2] + 1
          if PlayerY[2] < 80 then goto SkipPlayer3Jump
          PlayerY[2] = 80 : PlayerState[2] = PlayerState[2] & NOT 4
SkipPlayer3Jump
          
          rem Player 4 (Quadtari only)
          if 0 = (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Jump
          if SelectedChar4 = 255 then goto SkipPlayer4Jump
          if (PlayerState[3] & 4) <> 0 then goto SkipPlayer4Jump
          PlayerY[3] = PlayerY[3] + 1
          if PlayerY[3] < 80 then goto SkipPlayer4Jump
          PlayerY[3] = 80 : PlayerState[3] = PlayerState[3] & NOT 4
SkipPlayer4Jump
          
          return

          rem =================================================================
          rem APPLY MOMENTUM AND RECOVERY
          rem =================================================================
          rem Updates recovery frames and applies momentum during hitstun.
          rem Momentum gradually decays over time.
ApplyMomentumAndRecovery
          rem Player 1
          if PlayerRecoveryFrames[0] > 0 then PlayerRecoveryFrames[0] = PlayerRecoveryFrames[0] - 1 : PlayerX[0] = PlayerX[0] + PlayerMomentumX[0]
          if PlayerRecoveryFrames[0] = 0 then goto SkipPlayer0Momentum
          if PlayerMomentumX[0] <= 0 then goto CheckPlayer0NegativeMomentum
          PlayerMomentumX[0] = PlayerMomentumX[0] - 1
          goto SkipPlayer0Momentum
CheckPlayer0NegativeMomentum
          if PlayerMomentumX[0] >= 0 then goto SkipPlayer0Momentum
          PlayerMomentumX[0] = PlayerMomentumX[0] + 1
SkipPlayer0Momentum

          rem Player 2
          if PlayerRecoveryFrames[1] > 0 then PlayerRecoveryFrames[1] = PlayerRecoveryFrames[1] - 1 : PlayerX[1] = PlayerX[1] + PlayerMomentumX[1]
          if PlayerRecoveryFrames[1] = 0 then goto SkipPlayer1Momentum
          if PlayerMomentumX[1] <= 0 then goto CheckPlayer1NegativeMomentum
          PlayerMomentumX[1] = PlayerMomentumX[1] - 1
          goto SkipPlayer1Momentum
CheckPlayer1NegativeMomentum
          if PlayerMomentumX[1] >= 0 then goto SkipPlayer1Momentum
          PlayerMomentumX[1] = PlayerMomentumX[1] + 1
SkipPlayer1Momentum

          rem Player 3 (Quadtari only)
          if 0 = (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Recovery
          if SelectedChar3 = 255 then goto SkipPlayer3Recovery
          if PlayerRecoveryFrames[2] = 0 then goto SkipPlayer3Recovery
          PlayerRecoveryFrames[2] = PlayerRecoveryFrames[2] - 1 : PlayerX[2] = PlayerX[2] + PlayerMomentumX[2]
          if PlayerMomentumX[2] <= 0 then goto CheckPlayer3NegativeMomentum
          PlayerMomentumX[2] = PlayerMomentumX[2] - 1
          goto SkipPlayer3Recovery
CheckPlayer3NegativeMomentum
          if PlayerMomentumX[2] >= 0 then goto SkipPlayer3Recovery
          PlayerMomentumX[2] = PlayerMomentumX[2] + 1
SkipPlayer3Recovery

          rem Player 4 (Quadtari only)
          if 0 = (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Recovery
          if SelectedChar4 = 255 then goto SkipPlayer4Recovery
          if PlayerRecoveryFrames[3] = 0 then goto SkipPlayer4Recovery
          PlayerRecoveryFrames[3] = PlayerRecoveryFrames[3] - 1 : PlayerX[3] = PlayerX[3] + PlayerMomentumX[3]
          if PlayerMomentumX[3] <= 0 then goto CheckPlayer4NegativeMomentum
          PlayerMomentumX[3] = PlayerMomentumX[3] - 1
          goto SkipPlayer4Recovery
CheckPlayer4NegativeMomentum
          if PlayerMomentumX[3] >= 0 then goto SkipPlayer4Recovery
          PlayerMomentumX[3] = PlayerMomentumX[3] + 1
SkipPlayer4Recovery
          
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
          if 0 = (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Bounds
          if SelectedChar3 = 255 then goto SkipPlayer3Bounds
          goto ApplyPlayer3Bounds
          goto SkipPlayer3Bounds
ApplyPlayer3Bounds
          if PlayerX[2] < 10 then PlayerX[2] = 10
          if PlayerX[2] > 150 then PlayerX[2] = 150
          if PlayerY[2] < 20 then PlayerY[2] = 20
          if PlayerY[2] > 80 then PlayerY[2] = 80
SkipPlayer3Bounds

          rem Player 4 (Quadtari only)
          if 0 = (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Bounds
          if SelectedChar4 = 255 then goto SkipPlayer4Bounds
          goto ApplyPlayer4Bounds
          goto SkipPlayer4Bounds
ApplyPlayer4Bounds
          if PlayerX[3] < 10 then PlayerX[3] = 10
          if PlayerX[3] > 150 then PlayerX[3] = 150
          if PlayerY[3] < 20 then PlayerY[3] = 20
          if PlayerY[3] > 80 then PlayerY[3] = 80
SkipPlayer4Bounds
          
          return

          rem =================================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem =================================================================
          rem Checks collisions between players (for pushing, not damage).
          rem Players can walk through each other but are slightly pushed apart.
CheckAllPlayerCollisions
          dim Distance = temp2
          
          rem Check Player 1 vs Player 2
          if PlayerX[0] >= PlayerX[1] then Distance = PlayerX[0] - PlayerX[1] else Distance = PlayerX[1] - PlayerX[0]
if Distance < 16 then 
if PlayerX[0] < PlayerX[1] then 
          PlayerX[0] = PlayerX[0] - 1
          PlayerX[1] = PlayerX[1] + 1

          PlayerX[0] = PlayerX[0] + 1
          PlayerX[1] = PlayerX[1] - 1
          
          
          
          rem Check other player combinations if Quadtari active
          if 0 = (ControllerStatus & SetQuadtariDetected) then return
          
          rem Check Player 1 vs Player 3
if SelectedChar3 <> 255 then 
          if PlayerX[0] >= PlayerX[2] then Distance = PlayerX[0] - PlayerX[2] else Distance = PlayerX[2] - PlayerX[0]
if Distance < 16 then 
if PlayerX[0] < PlayerX[2] then 
          PlayerX[0] = PlayerX[0] - 1
          PlayerX[2] = PlayerX[2] + 1

          PlayerX[0] = PlayerX[0] + 1
          PlayerX[2] = PlayerX[2] - 1
          
          
          
          
          rem Check Player 1 vs Player 4
if SelectedChar4 <> 255 then 
          if PlayerX[0] >= PlayerX[3] then Distance = PlayerX[0] - PlayerX[3] else Distance = PlayerX[3] - PlayerX[0]
if Distance < 16 then 
if PlayerX[0] < PlayerX[3] then 
          PlayerX[0] = PlayerX[0] - 1
          PlayerX[3] = PlayerX[3] + 1

          PlayerX[0] = PlayerX[0] + 1
          PlayerX[3] = PlayerX[3] - 1
          
          
          
          
          rem Check Player 2 vs Player 3
if SelectedChar3 <> 255 then 
          if PlayerX[1] >= PlayerX[2] then Distance = PlayerX[1] - PlayerX[2] else Distance = PlayerX[2] - PlayerX[1]
if Distance < 16 then 
if PlayerX[1] < PlayerX[2] then 
          PlayerX[1] = PlayerX[1] - 1
          PlayerX[2] = PlayerX[2] + 1

          PlayerX[1] = PlayerX[1] + 1
          PlayerX[2] = PlayerX[2] - 1
          
          
          
          
          rem Check Player 2 vs Player 4
if SelectedChar4 <> 255 then 
          if PlayerX[1] >= PlayerX[3] then Distance = PlayerX[1] - PlayerX[3] else Distance = PlayerX[3] - PlayerX[1]
if Distance < 16 then 
if PlayerX[1] < PlayerX[3] then 
          PlayerX[1] = PlayerX[1] - 1
          PlayerX[3] = PlayerX[3] + 1

          PlayerX[1] = PlayerX[1] + 1
          PlayerX[3] = PlayerX[3] - 1
          
          
          
          
          rem Check Player 3 vs Player 4
if SelectedChar3 = 255 then goto SkipP3vsP4
if SelectedChar4 = 255 then goto SkipP3vsP4 
          Distance = 0
SkipP3vsP4
          if PlayerX[2] >= PlayerX[3] then Distance = PlayerX[2] - PlayerX[3] else Distance = PlayerX[3] - PlayerX[2]
if Distance < 16 then 
if PlayerX[2] < PlayerX[3] then 
          PlayerX[2] = PlayerX[2] - 1
          PlayerX[3] = PlayerX[3] + 1

          PlayerX[2] = PlayerX[2] + 1
          PlayerX[3] = PlayerX[3] - 1
          
          
          
          
          return

