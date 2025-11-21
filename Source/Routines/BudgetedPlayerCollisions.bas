          rem ChaosFight - Source/Routines/BudgetedPlayerCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

BudgetedCollisionCheck
          rem Budget Collision Detection
          rem Instead of checking all 6 collision pairs every frame in 4-player mode,
          rem check 2 pairs per frame. This spreads the work across 3 frames.
          rem
          rem COLLISION PAIRS (4-player mode):
          rem   Pair 0: P1 vs P2 (always checked, most important)
          rem   Pair 1: P1 vs P3
          rem   Pair 2: P1 vs P4
          rem   Pair 3: P2 vs P3
          rem   Pair 4: P2 vs P4
          rem   Pair 5: P3 vs P4
          rem
          rem SCHEDULE:
          rem   Frame 0: Pairs 0, 1 (P1 vs P2, P1 vs P3)
          rem   Frame 1: Pairs 2, 3 (P1 vs P4, P2 vs P3)
          rem   Frame 2: Pairs 4, 5 (P2 vs P4, P3 vs P4)
          rem   Frame 3: Pairs 0, 1 (repeat)
          gosub CheckCollisionP1vsP2
          rem Always check P1 vs P2 (most important)

          rem Skip other checks if not Quadtari
          if (controllerStatus & SetQuadtariDetected) = 0 then return

          rem Check additional pairs based on frame phase
          if framePhase = 0 then CheckPhase0Collisions
          if framePhase = 1 then CheckPhase1Collisions
          goto DonePhase0And1Collisions
CheckPhase0Collisions
          if playerCharacter[2] = NoCharacter then DoneFramePhaseChecks
          gosub CheckCollisionP1vsP3
          goto DoneFramePhaseChecks
CheckPhase1Collisions
          if playerCharacter[3] = NoCharacter then CheckPhase1P3
          gosub CheckCollisionP1vsP4
CheckPhase1P3
          if playerCharacter[2] = NoCharacter then DoneFramePhaseChecks
          gosub CheckCollisionP2vsP3
          goto DoneFramePhaseChecks
DonePhase0And1Collisions
          if framePhase = 2 then CheckPhase2Collisions
          goto DonePhase2Collisions
CheckPhase2Collisions
          if playerCharacter[3] = NoCharacter then DoneCheckP2vsP4
          gosub CheckCollisionP2vsP4
DoneCheckP2vsP4
          if playerCharacter[2] = NoCharacter then DoneCheckP3vsP4
          if playerCharacter[3] = NoCharacter then DoneCheckP3vsP4
          gosub CheckCollisionP3vsP4
DoneCheckP3vsP4
DonePhase2Collisions
DoneFramePhaseChecks
          return

CheckCollisionP1vsP2
          asm
CheckCollisionP1vsP2
end
          rem Individual collision check routines
          if playerX[0] >= playerX[1] then CalcP1vsP2AbsDiff
          let temp2 = playerX[1] - playerX[0]
          goto DoneCalcP1vsP2Diff
CalcP1vsP2AbsDiff
          let temp2 = playerX[0] - playerX[1]
DoneCalcP1vsP2Diff
          if temp2 >= CollisionSeparationDistance then DonePlayerSeparation

          rem Separate players based on their relative positions
          rem If P0 is left of P1, move P0 left and P1 right
          if playerX[0] < playerX[1] then SeparateP0Left

          let playerX[0] = playerX[0] + 1
          rem Else P0 is right of P1, move P0 right and P1 left
          let playerX[1] = playerX[1] - 1
          goto DonePlayerSeparation

SeparateP0Left
          let playerX[0] = playerX[0] - 1
          let playerX[1] = playerX[1] + 1
DonePlayerSeparation
          return

CheckCollisionP1vsP3
          asm
CheckCollisionP1vsP3
end
          if playerX[0] >= playerX[2] then CalcP1vsP3AbsDiff
          let temp2 = playerX[2] - playerX[0]
          goto DoneCalcP1vsP3Diff
CalcP1vsP3AbsDiff
          let temp2 = playerX[0] - playerX[2]
DoneCalcP1vsP3Diff
          if temp2 < 16 then CheckCollisionP1vsP3Aux
          return

CheckCollisionP1vsP3Aux
          if playerX[0] < playerX[2] then let playerX[0] = playerX[0] - 1
          if playerX[0] < playerX[2] then let playerX[2] = playerX[2] + 1
          if playerX[0] < playerX[2] then return
          let playerX[0] = playerX[0] + 1
          let playerX[2] = playerX[2] - 1
          return

CheckCollisionP1vsP4
          asm
CheckCollisionP1vsP4
end
          if playerX[0] >= playerX[3] then CalcP1vsP4AbsDiff
          let temp2 = playerX[3] - playerX[0]
          goto DoneCalcP1vsP4Diff
CalcP1vsP4AbsDiff
          let temp2 = playerX[0] - playerX[3]
DoneCalcP1vsP4Diff
          if temp2 < 16 then CheckCollisionP1vsP4Aux
          return

CheckCollisionP1vsP4Aux
          if playerX[0] < playerX[3] then let playerX[0] = playerX[0] - 1
          if playerX[0] < playerX[3] then let playerX[3] = playerX[3] + 1
          if playerX[0] < playerX[3] then return
          let playerX[0] = playerX[0] + 1
          let playerX[3] = playerX[3] - 1
          return

CheckCollisionP2vsP3
          asm
CheckCollisionP2vsP3
end
          if playerX[1] >= playerX[2] then CalcP2vsP3AbsDiff
          let temp2 = playerX[2] - playerX[1]
          goto DoneCalcP2vsP3Diff
CalcP2vsP3AbsDiff
          let temp2 = playerX[1] - playerX[2]
DoneCalcP2vsP3Diff
          if temp2 < 16 then CheckCollisionP2vsP3Aux
          return

CheckCollisionP2vsP3Aux
          if playerX[1] < playerX[2] then let playerX[1] = playerX[1] - 1
          if playerX[1] < playerX[2] then let playerX[2] = playerX[2] + 1
          if playerX[1] < playerX[2] then return
          let playerX[1] = playerX[1] + 1
          let playerX[2] = playerX[2] - 1
          return

CheckCollisionP2vsP4
          asm
CheckCollisionP2vsP4
end
          if playerX[1] >= playerX[3] then CalcP2vsP4AbsDiff
          let temp2 = playerX[3] - playerX[1]
          goto DoneCalcP2vsP4Diff
CalcP2vsP4AbsDiff
          let temp2 = playerX[1] - playerX[3]
DoneCalcP2vsP4Diff
          if temp2 < 16 then CheckCollisionP2vsP4Aux
          return

CheckCollisionP2vsP4Aux
          if playerX[1] < playerX[3] then let playerX[1] = playerX[1] - 1
          if playerX[1] < playerX[3] then let playerX[3] = playerX[3] + 1
          if playerX[1] < playerX[3] then return
          let playerX[1] = playerX[1] + 1
          let playerX[3] = playerX[3] - 1
          return

CheckCollisionP3vsP4
          asm
CheckCollisionP3vsP4
end
          if playerX[2] >= playerX[3] then CalcP3vsP4AbsDiff
          let temp2 = playerX[3] - playerX[2]
          goto DoneCalcP3vsP4Diff
CalcP3vsP4AbsDiff
          let temp2 = playerX[2] - playerX[3]
DoneCalcP3vsP4Diff
          if temp2 < 16 then CheckCollisionP3vsP4Aux
          return

CheckCollisionP3vsP4Aux
          if playerX[2] < playerX[3] then let playerX[2] = playerX[2] - 1
          if playerX[2] < playerX[3] then let playerX[3] = playerX[3] + 1
          if playerX[2] < playerX[3] then return
          let playerX[2] = playerX[2] + 1
          let playerX[3] = playerX[3] - 1
          return


