          rem ChaosFight - Source/Routines/CharacterCycleUtils.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem Character cycling utility functions moved for bank optimization
          if temp3 = 1 then goto SelectP2LeftWrap
          temp1 = NoCharacter
          return

CSLWrapPlayer0Left
          temp1 = RandomCharacter
          return
          
SelectP2LeftWrap
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not
          if !(controllerStatus & SetQuadtariDetected) then goto SelectP2LeftWrapCPU
          rem both NO)
          rem Check if P3 or P4 are NOT both NO
          if playerCharacter[2] = NoCharacter then goto CheckP4_LeftWrap
          temp1 = NoCharacter
          return
SelectP2LeftWrapCPU
          temp1 = CPUCharacter
          return
CheckP4_LeftWrap
          if playerCharacter[3] = NoCharacter then goto BothNO_LeftWrap
          temp1 = NoCharacter
          return
BothNO_LeftWrap
          temp1 = CPUCharacter
          rem Both P3 and P4 are NO, so P2 wraps to CPU
          return
          
CycleFromRandom
          rem RandomCharacter(253) left cycle: direction-dependent
          rem P1: ... Random → 15 → 14 → ...
          rem P2: ... Random → NO (if available) → CPU OR Random → 15
          rem P3/P4: Random → NO
          rem Check if this is P2 with NO available
          if temp3 = 1 then goto SelectP2LeftFromRandom
          rem P1 or P3/P4: Random left goes to NO (P3/P4) or 15 (P1)
          if temp3 = 0 then goto CycleFromRandomPlayer0
          rem P1 → 15
          temp1 = NoCharacter
          rem P3/P4 → NO
          return

CycleFromRandomPlayer0
          temp1 = MaxCharacter
          return
          
SelectP2LeftFromRandom
          rem P2 left from Random: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then goto SelectP2LeftFromRandomMax
          rem Check if P3 or P4 are NOT both NO
          if playerCharacter[2] = NoCharacter then CheckP4_LeftFromRandom
          temp1 = NoCharacter
          return

SelectP2LeftFromRandomMax
          temp1 = MaxCharacter
          return
CheckP4_LeftFromRandom
          if playerCharacter[3] = NoCharacter then BothNO_LeftFromRandom
          temp1 = NoCharacter
          return
BothNO_LeftFromRandom
          temp1 = MaxCharacter
          rem Both P3 and P4 are NO, so NO not available, go to 15
          return
          
CycleFromCPU
          rem CPUCharacter(254) left cycle: goes to RandomCharacter(253)
          rem   for all players
          rem For P2, this is the left direction from CPU
          rem P2 left from CPU: if NO available, NO → Random, else
          rem   Random
          rem Actually, left from CPU means we’re decrementing, so CPU
          rem   is after Random
          rem The cycle is: ... Random → CPU → Random ...
          rem So left from CPU should go to Random (we already have
          temp1 = RandomCharacter
          rem   this)
          return
          
CycleFromNO
          rem NoCharacter(255) left cycle: direction-dependent
          rem P2 with NO available: NO → CPU (left), NO → Random (right)
          rem P3/P4: NO → Random (both directions since NO is start/end)
          rem For left cycle (decrement): P2 goes from NO to CPU
          if temp3 = 1 then goto CycleFromNOPlayer2
          rem P2 left from NO → CPU
          temp1 = RandomCharacter
          rem P3/P4: NO → Random
          return

CycleFromNOPlayer2
          temp1 = CPUCharacter
          return
          
CycleCharacterRight
          if temp1 = RandomCharacter then goto CycleRightFromRandom
          rem Increment character with special value wraparound
