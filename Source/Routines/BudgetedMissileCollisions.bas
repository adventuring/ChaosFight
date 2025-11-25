          rem ChaosFight - Source/Routines/BudgetedMissileCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

BudgetedMissileCollisionCheck
          rem Budget Missile Collision Detection
          rem Check missile collisions for at most 2 missiles per frame.
          rem
          rem SCHEDULE (2-player mode):
          rem   Even frames: Check Game Player 0 missile collisions
          rem   Odd frames: Check Game Player 1 missile collisions
          rem
          rem SCHEDULE (4-player mode):
          rem   Frame 0: Check Game Player 0 missile vs all players
          rem   Frame 1: Check Game Player 1 missile vs all players
          rem   Frame 2: Check Game Player 2 missile vs all players
          rem   Frame 3: Check Game Player 3 missile vs all players
          rem Use missileActive bit flags: bit 0 = Player 0, bit 1 = Player 1,
          rem bit 2 = Player 2, bit 3 = Player 3
          rem Use CheckAllMissileCollisions from MissileCollision.bas which checks one player missile
          if (controllerStatus & SetQuadtariDetected) = 0 then BudgetedMissileCollisionCheck2P

          rem 4-player mode: check one missile per frame
          let temp1 = framePhase
          rem framePhase 0-3 maps to Game Players 0-3
          rem Calculate bit flag using O(1) array lookup: BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1]
          let temp4 = missileActive & temp6
          if temp4 then gosub CheckAllMissileCollisions bank8
          return

BudgetedMissileCollisionCheck2P
          rem Simple 2-player mode: alternate missiles
          let temp1 = frame & 1
          rem Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          rem   BitMask[playerIndex] (1, 2, 4, 8)
          rem Calculate bit flag using O(1) array lookup:
          let temp6 = BitMask[temp1]
          let temp4 = missileActive & temp6
          if temp4 then gosub CheckAllMissileCollisions bank8
          return



