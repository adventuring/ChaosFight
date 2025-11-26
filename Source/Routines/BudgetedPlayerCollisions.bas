          rem ChaosFight - Source/Routines/BudgetedPlayerCollisions.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

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
          rem Always check P1 vs P2 (most important)
          gosub CheckCollisionP1vsP2

          rem Skip other checks if not Quadtari
          if (controllerStatus & SetQuadtariDetected) = 0 then return

          rem Check additional pairs based on frame phase
          if framePhase = 0 then BPC_Phase0
          if framePhase = 1 then BPC_Phase1
          if framePhase = 2 then BPC_Phase2
          return thisbank
BPC_Phase0
          if playerCharacter[2] = NoCharacter then return
          gosub CheckCollisionP1vsP3
          return thisbank
BPC_Phase1
          if playerCharacter[3] <> NoCharacter then gosub CheckCollisionP1vsP4
          if playerCharacter[2] = NoCharacter then return
          gosub CheckCollisionP2vsP3
          return thisbank
BPC_Phase2
          if playerCharacter[3] <> NoCharacter then gosub CheckCollisionP2vsP4
          if playerCharacter[2] = NoCharacter then return
          if playerCharacter[3] = NoCharacter then return
          gosub CheckCollisionP3vsP4
          return thisbank
CheckCollisionP1vsP2
          asm
CheckCollisionP1vsP2
end
          let temp3 = 0
          let temp4 = 1
          gosub CheckCollisionPair
          return thisbank
CheckCollisionPair
          asm
CheckCollisionPair
end
          rem Input: temp3 = player 1 index, temp4 = player 2 index
          rem Output: separates players if collision detected
          if playerX[temp3] >= playerX[temp4] then BPC_CalcDiff
          let temp2 = playerX[temp4] - playerX[temp3]
          goto BPC_CheckSep
BPC_CalcDiff
          let temp2 = playerX[temp3] - playerX[temp4]
BPC_CheckSep
          if temp2 >= 16 then return
          if playerX[temp3] < playerX[temp4] then BPC_SepLeft
          let playerX[temp3] = playerX[temp3] + 1
          let playerX[temp4] = playerX[temp4] - 1
          return thisbank
BPC_SepLeft
          let playerX[temp3] = playerX[temp3] - 1
          let playerX[temp4] = playerX[temp4] + 1
          return thisbank
CheckCollisionP1vsP3
          asm
CheckCollisionP1vsP3
end
          let temp3 = 0
          let temp4 = 2
          gosub CheckCollisionPair
          return thisbank
CheckCollisionP1vsP4
          asm
CheckCollisionP1vsP4
end
          let temp3 = 0
          let temp4 = 3
          gosub CheckCollisionPair
          return thisbank
CheckCollisionP2vsP3
          asm
CheckCollisionP2vsP3
end
          let temp3 = 1
          let temp4 = 2
          gosub CheckCollisionPair
          return thisbank
CheckCollisionP2vsP4
          asm
CheckCollisionP2vsP4
end
          let temp3 = 1
          let temp4 = 3
          gosub CheckCollisionPair
          return thisbank
CheckCollisionP3vsP4
          asm
CheckCollisionP3vsP4
end
          let temp3 = 2
          let temp4 = 3
          gosub CheckCollisionPair
          return thisbank


