          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER SELECT - PER-FRAME LOOP
          rem =================================================================
          rem Per-frame character selection screen with Quadtari support.
          rem Called from MainLoop each frame (gameMode 3).
          rem Players cycle through NumCharacters characters and lock in their choice.
          rem
          rem Setup is handled by SetupCharacterSelect in ChangeGameMode.bas
          rem This function processes one frame and returns.

          rem FLOW PER FRAME:
          rem   1. Handle input with Quadtari multiplexing
          rem   2. Update animations
          rem   3. Check if ready to proceed
          rem   4. Draw screen
          rem   5. Return to MainLoop

          rem QUADTARI MULTIPLEXING:
          rem   Even frames (qtcontroller=0): joy0=P1, joy1=P2
          rem   Odd frames (qtcontroller=1): joy0=P3, joy1=P4

          rem AVAILABLE VARIABLES:
          rem   playerChar[0-3) - Selected character indices (0-15)
          rem   playerLocked[0-3) - Lock state (0=unlocked, 1=locked)
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   readyCount - Number of locked players
          rem =================================================================

CharacterSelectInputEntry
          rem Check for controller re-detection on Select/Pause/ColorB&W switches
          gosub CharacterSelectCheckControllerRescan
          
          rem Quadtari controller multiplexing
          if qtcontroller then CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then CharacterSelectPlayer0Left
          goto CharacterSelectSkipPlayer0Left
CharacterSelectPlayer0Left
          let temp1 = playerChar[0] : let temp3 = 0
          gosub CycleCharacterLeft
          let playerChar[0] = temp1
          let playerLocked[0] = 0
          rem Play navigation sound
          let temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer0Left
          if joy0right then CharacterSelectPlayer0Right
          goto CharacterSelectSkipPlayer0Right
CharacterSelectPlayer0Right
          temp1 = playerChar[0] : temp3 = 0
          gosub CycleCharacterRight
          let playerChar[0] = temp1
          let playerLocked[0] = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer0Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then playerLocked[0] = 0 : goto CharacterSelectPlayer0LockClearDone
          if joy0down then playerLocked[0] = 0
CharacterSelectPlayer0LockClearDone
          if joy0fire then CharacterSelectPlayer0Fire
          goto CharacterSelectSkipPlayer0Fire
CharacterSelectPlayer0Fire
          rem Check if RandomCharacter selected - needs random selection
          if playerChar[0] = RandomCharacter then CharacterSelectPlayer0Random
          rem Check for handicap mode (down+fire = 75% health)
          if joy0down then CharacterSelectPlayer0FireHandicap
          let playerLocked[0] = 1
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer0Fire
CharacterSelectPlayer0FireHandicap
          let playerLocked[0] = 2
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer0Fire
CharacterSelectPlayer0Random
          rem Random selection initiated - will be handled by CharacterSelectHandleRandomRolls
          rem Store handicap flag if down was held
          if joy0down then randomSelectFlags[0] = $80
          if !joy0down then randomSelectFlags[0] = 0
          rem For now, just initiate random roll by leaving playerChar[0]=RandomCharacter
          rem and NOT locking yet - the roll handler will lock when valid
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          rem Fall through - character will stay as RandomCharacter until roll succeeds
CharacterSelectSkipPlayer0Fire

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then CharacterSelectPlayer1Left
          goto CharacterSelectSkipPlayer1Left
CharacterSelectPlayer1Left
          temp1 = playerChar[1] : temp3 = 1
          gosub CycleCharacterLeft
          let playerChar[1] = temp1
          let playerLocked[1] = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer1Left
          if joy1right then CharacterSelectPlayer1Right
          goto CharacterSelectSkipPlayer1Right
CharacterSelectPlayer1Right
          temp1 = playerChar[1] : temp3 = 1
          gosub CycleCharacterRight
          let playerChar[1] = temp1
          let playerLocked[1] = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer1Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then playerLocked[1] = 0 : goto CharacterSelectPlayer1LockClearDone
          if joy1down then playerLocked[1] = 0
CharacterSelectPlayer1LockClearDone
          if joy1fire then CharacterSelectPlayer1Fire
          goto CharacterSelectSkipPlayer1Fire
CharacterSelectPlayer1Fire
          rem Check if RandomCharacter selected - needs random selection
          if playerChar[1] = RandomCharacter then CharacterSelectPlayer1Random
          rem Check for handicap mode (down+fire = 75% health)
          if joy1down then CharacterSelectPlayer1FireHandicap
          let playerLocked[1] = 1
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer1Fire
CharacterSelectPlayer1FireHandicap
          let playerLocked[1] = 2
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer1Fire
CharacterSelectPlayer1Random
          rem Random selection initiated - will be handled by CharacterSelectHandleRandomRolls
          rem Store handicap flag if down was held
          if joy1down then randomSelectFlags[1] = $80
          if !joy1down then randomSelectFlags[1] = 0
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          rem Fall through - character will stay as RandomCharacter until roll succeeds
CharacterSelectSkipPlayer1Fire
          
          let qtcontroller = 1
          goto CharacterSelectInputComplete

CharacterSelectHandleQuadtari
          rem Handle Player 3 input (joy0 on odd frames)
          if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer3
          goto CharacterSelectSkipPlayer3
CharacterSelectHandlePlayer3
          if joy0left then CharacterSelectPlayer3Left
          goto CharacterSelectSkipPlayer3Left
CharacterSelectPlayer3Left
          temp1 = playerChar[2] : temp3 = 2
          gosub CycleCharacterLeft
          let playerChar[2] = temp1
          let playerLocked[2] = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer3Left
          if joy0right then CharacterSelectPlayer3Right
          goto CharacterSelectSkipPlayer3Right
CharacterSelectPlayer3Right
          temp1 = playerChar[2] : temp3 = 2
          gosub CycleCharacterRight
          let playerChar[2] = temp1
          let playerLocked[2] = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer3Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then playerLocked[2] = 0 : goto CharacterSelectPlayer2LockClearDone
          if joy0down then playerLocked[2] = 0
CharacterSelectPlayer2LockClearDone
          if joy0fire then CharacterSelectPlayer3Fire
          goto CharacterSelectSkipPlayer3Fire
CharacterSelectPlayer3Fire
          rem Check if RandomCharacter selected - needs random selection
          if playerChar[2] = RandomCharacter then CharacterSelectPlayer3Random
          rem Check for handicap mode (down+fire = 75% health)
          if joy0down then CharacterSelectPlayer3FireHandicap
          let playerLocked[2] = 1
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer3Fire
CharacterSelectPlayer3FireHandicap
          let playerLocked[2] = 2
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer3Fire
CharacterSelectPlayer3Random
          rem Random selection initiated - will be handled by CharacterSelectHandleRandomRolls
          rem Store handicap flag if down was held
          if joy0down then randomSelectFlags[2] = $80
          if !joy0down then randomSelectFlags[2] = 0
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          rem Fall through - character will stay as RandomCharacter until roll succeeds
CharacterSelectSkipPlayer3Fire
CharacterSelectSkipPlayer3

          rem Handle Player 4 input (joy1 on odd frames)
          if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer4
          goto CharacterSelectSkipPlayer4
CharacterSelectHandlePlayer4
          if joy1left then CharacterSelectPlayer4Left
          goto CharacterSelectSkipPlayer4Left
CharacterSelectPlayer4Left
          temp1 = playerChar[3] : temp3 = 3
          gosub CycleCharacterLeft
          let playerChar[3] = temp1
          let playerLocked[3] = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer4Left
          if joy1right then CharacterSelectPlayer4Right
          goto CharacterSelectSkipPlayer4Right
CharacterSelectPlayer4Right
          temp1 = playerChar[3] : temp3 = 3
          gosub CycleCharacterRight
          let playerChar[3] = temp1
          let playerLocked[3] = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
CharacterSelectSkipPlayer4Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then playerLocked[3] = 0 : goto CharacterSelectPlayer3LockClearDone
          if joy1down then playerLocked[3] = 0
CharacterSelectPlayer3LockClearDone
          if joy1fire then CharacterSelectPlayer4Fire
          goto CharacterSelectSkipPlayer4Fire
CharacterSelectPlayer4Fire
          rem Check if RandomCharacter selected - needs random selection
          if playerChar[3] = RandomCharacter then CharacterSelectPlayer4Random
          rem Check for handicap mode (down+fire = 75% health)
          if joy1down then CharacterSelectPlayer4FireHandicap
          let playerLocked[3] = 1
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer4Fire
CharacterSelectPlayer4FireHandicap
          let playerLocked[3] = 2
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          goto CharacterSelectSkipPlayer4Fire
CharacterSelectPlayer4Random
          rem Random selection initiated - will be handled by CharacterSelectHandleRandomRolls
          rem Store handicap flag if down was held
          if joy1down then randomSelectFlags[3] = $80
          if !joy1down then randomSelectFlags[3] = 0
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          rem Fall through - character will stay as RandomCharacter until roll succeeds
CharacterSelectSkipPlayer4Fire
CharacterSelectSkipPlayer4
          
          
          let qtcontroller = 0

CharacterSelectInputComplete
          rem Handle random character re-rolls if any players need it
          gosub CharacterSelectHandleRandomRolls
          
          rem Update character select animations
          gosub SelectUpdateAnimations

          rem Check if all players are ready to start (may transition to next mode)
          gosub CharacterSelectCheckReady

          rem Draw character selection screen
          gosub SelectDrawScreen

          drawscreen
          return

          rem =================================================================
          rem RANDOM CHARACTER ROLL HANDLER
          rem =================================================================
          rem Re-roll random selections until valid (0-15), then lock
          
CharacterSelectHandleRandomRolls
          rem Check each player for pending random roll
          if playerChar[0] = RandomCharacter then CharacterSelectRollPlayer0
          if playerChar[1] = RandomCharacter then CharacterSelectRollPlayer1
          if controllerStatus & SetQuadtariDetected then CharacterSelectCheckRollQuadtari
          goto CharacterSelectRollsDone
          
CharacterSelectCheckRollQuadtari
          if playerChar[2] = RandomCharacter then CharacterSelectRollPlayer2
          if playerChar[3] = RandomCharacter then CharacterSelectRollPlayer3
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer0
          rem Roll 5-bit random: rand & 31 (0-31)
          temp2 = rand & 31
          rem If > 15, stay as RandomCharacter and retry next frame
          if temp2 > MaxCharacter then CharacterSelectRollsDone
          rem Valid! Set character and lock with normal or handicap
          playerChar[0] = temp2
          if randomSelectFlags[0] then goto CharacterSelectLockPlayer0Handicap
          let playerLocked[0] = 1
          goto CharacterSelectLockPlayer0Done
CharacterSelectLockPlayer0Handicap
          let playerLocked[0] = 2
CharacterSelectLockPlayer0Done
          randomSelectFlags[0] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer1
          temp2 = rand & 31
          if temp2 > MaxCharacter then CharacterSelectRollsDone
          playerChar[1] = temp2
          if randomSelectFlags[1] then goto CharacterSelectLockPlayer1Handicap
          let playerLocked[1] = 1
          goto CharacterSelectLockPlayer1Done
CharacterSelectLockPlayer1Handicap
          let playerLocked[1] = 2
CharacterSelectLockPlayer1Done
          randomSelectFlags[1] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer2
          temp2 = rand & 31
          if temp2 > MaxCharacter then CharacterSelectRollsDone
          playerChar[2] = temp2
          if randomSelectFlags[2] then goto CharacterSelectLockPlayer2Handicap
          let playerLocked[2] = 1
          goto CharacterSelectLockPlayer2Done
CharacterSelectLockPlayer2Handicap
          let playerLocked[2] = 2
CharacterSelectLockPlayer2Done
          randomSelectFlags[2] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer3
          temp2 = rand & 31
          if temp2 > MaxCharacter then CharacterSelectRollsDone
          playerChar[3] = temp2
          if randomSelectFlags[3] then goto CharacterSelectLockPlayer3Handicap
          let playerLocked[3] = 1
          goto CharacterSelectLockPlayer3Done
CharacterSelectLockPlayer3Handicap
          let playerLocked[3] = 2
CharacterSelectLockPlayer3Done
          randomSelectFlags[3] = 0
          
CharacterSelectRollsDone
          return
          
          rem =================================================================
          rem CHECK IF READY TO PROCEED
          rem =================================================================
CharacterSelectCheckReady
          rem 2-player mode: P1 must be locked AND (P2 locked OR P2 on CPU)
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariReady
          if !playerLocked[0] then CharacterSelectReadyDone
          rem P1 is locked, check P2
          if playerLocked[1] then CharacterSelectFinish
          rem P2 not locked, check if on CPU
          if playerChar[1] = CPUCharacter then CharacterSelectFinish
          goto CharacterSelectReadyDone
          
CharacterSelectQuadtariReady
          rem 4-player mode: Count players who are ready (locked OR on CPU/NO)
          let readyCount = 0
          rem Count P1 ready
          if playerLocked[0] then readyCount = readyCount + 1
          if !playerLocked[0] && playerChar[0] = CPUCharacter then readyCount = readyCount + 1
          if !playerLocked[0] && playerChar[0] = NoCharacter then readyCount = readyCount + 1
          rem Count P2 ready
          if playerLocked[1] then readyCount = readyCount + 1
          if !playerLocked[1] && playerChar[1] = CPUCharacter then readyCount = readyCount + 1
          if !playerLocked[1] && playerChar[1] = NoCharacter then readyCount = readyCount + 1
          rem Count P3 ready
          if playerLocked[2] then readyCount = readyCount + 1
          if !playerLocked[2] && playerChar[2] = CPUCharacter then readyCount = readyCount + 1
          if !playerLocked[2] && playerChar[2] = NoCharacter then readyCount = readyCount + 1
          rem Count P4 ready
          if playerLocked[3] then readyCount = readyCount + 1
          if !playerLocked[3] && playerChar[3] = CPUCharacter then readyCount = readyCount + 1
          if !playerLocked[3] && playerChar[3] = NoCharacter then readyCount = readyCount + 1
          if readyCount >= 2 then CharacterSelectFinish
          
CharacterSelectReadyDone
          return

CharacterSelectFinish
          rem Store final selections
          let selectedChar1 = playerChar[0]
          let selectedChar2 = playerChar[1]
          let selectedChar3 = playerChar[2]
          let selectedChar4 = playerChar[3]
          
          rem Transition to falling animation
          let gameMode = ModeFallingAnimation
          gosub bank13 ChangeGameMode
          return

          rem =================================================================
          rem CHARACTER CYCLING HELPERS
          rem =================================================================
          rem Handle wraparound cycling for characters with special values
          rem Input: temp1 = playerChar value, temp2 = direction (0=left, 1=right), temp3 = player number
          rem Output: temp1 = new playerChar value
          
CycleCharacterLeft
          rem Decrement character with special value wraparound
          rem P1: RandomCharacter(253) ↔ 0 ↔ 15 ↔ RandomCharacter
          rem P2: CPUCharacter(254) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔ CPUCharacter
          rem P3/P4: NoCharacter(255) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔ NoCharacter
          
          rem Check if we’re at a special value
          if temp1 = RandomCharacter then CycleFromRandom : return
          if temp1 = CPUCharacter then CycleFromCPU : return
          if temp1 = NoCharacter then CycleFromNO : return
          
          rem Normal character (0-15): decrement
          rem Check if we’re at 0 before decrementing (need to wrap to special)
          if !temp1 then CharacterSelectLeftWrapCheck
          temp1 = temp1 - 1
          return
          
CharacterSelectLeftWrapCheck
          rem After 0, wrap to player-specific special character
          if temp3 = 0 then temp1 = RandomCharacter : return
          if temp3 = 1 then SelectP2LeftWrap
          temp1 = NoCharacter
          return
          
SelectP2LeftWrap
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not both NO)
          if !(controllerStatus & SetQuadtariDetected) then temp1 = CPUCharacter : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] != NoCharacter then temp1 = NoCharacter : return
          if playerChar[3] != NoCharacter then temp1 = NoCharacter : return
          rem Both P3 and P4 are NO, so P2 wraps to CPU
          temp1 = CPUCharacter
          return
          
CycleFromRandom
          rem RandomCharacter(253) left cycle: direction-dependent
          rem P1: ... Random → 15 → 14 → ...
          rem P2: ... Random → NO (if available) → CPU OR Random → 15
          rem P3/P4: Random → NO
          rem Check if this is P2 with NO available
          if temp3 = 1 then SelectP2LeftFromRandom
          rem P1 or P3/P4: Random left goes to NO (P3/P4) or 15 (P1)
          if temp3 = 0 then temp1 = MaxCharacter : return  : rem P1 → 15
          rem P3/P4 → NO
          temp1 = NoCharacter
          return
          
SelectP2LeftFromRandom
          rem P2 left from Random: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then temp1 = MaxCharacter : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] != NoCharacter then temp1 = NoCharacter : return
          if playerChar[3] != NoCharacter then temp1 = NoCharacter : return
          rem Both P3 and P4 are NO, so NO not available, go to 15
          temp1 = MaxCharacter
          return
          
CycleFromCPU
          rem CPUCharacter(254) left cycle: goes to RandomCharacter(253) for all players
          rem For P2, this is the left direction from CPU
          rem P2 left from CPU: if NO available, NO → Random, else Random
          rem Actually, left from CPU means we’re decrementing, so CPU is after Random
          rem The cycle is: ... Random → CPU → Random ...
          rem So left from CPU should go to Random (we already have this)
          temp1 = RandomCharacter
          return
          
CycleFromNO
          rem NoCharacter(255) left cycle: direction-dependent
          rem P2 with NO available: NO → CPU (left), NO → Random (right)
          rem P3/P4: NO → Random (both directions since NO is start/end)
          rem For left cycle (decrement): P2 goes from NO to CPU
          if temp3 = 1 then temp1 = CPUCharacter : return  : rem P2 left from NO → CPU
          rem P3/P4: NO → Random
          temp1 = RandomCharacter
          return
          
CycleCharacterRight
          rem Increment character with special value wraparound
          if temp1 = RandomCharacter then CycleRightFromRandom : return
          if temp1 = CPUCharacter then CycleRightFromCPU : return
          if temp1 = NoCharacter then CycleRightFromNO : return
          
          rem Normal character (0-15): increment
          temp1 = temp1 + 1
          rem Check if we went past 15 (wrap to RandomCharacter)
          if temp1 > MaxCharacter then CharacterSelectRightWrapCheck
          return
          
CharacterSelectRightWrapCheck
          rem After 15, go to RandomCharacter instead of wrapping to 0
          temp1 = RandomCharacter
          return
          
CycleRightFromRandom
          rem RandomCharacter(253) goes to special for each player
          if temp3 = 0 then temp1 = 0 : return
          if temp3 = 1 then SelectP2RightFromRandom
          temp1 = NoCharacter
          return
          
SelectP2RightFromRandom
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not both NO)
          if !(controllerStatus & SetQuadtariDetected) then temp1 = CPUCharacter : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] != NoCharacter then temp1 = NoCharacter : return
          if playerChar[3] != NoCharacter then temp1 = NoCharacter : return
          rem Both P3 and P4 are NO, so P2 goes to CPU
          temp1 = CPUCharacter
          return
          
CycleRightFromCPU
          rem CPUCharacter(254) wraps based on player
          rem P1: CPU → Random → ...
          rem P2: CPU → NO (if available) → Random → ... OR CPU → Random
          rem P3/P4: Should not reach CPU, but handle gracefully
          if temp3 = 1 then SelectP2RightFromCPU
          goto CycleRightFromCPUDone
SelectP2RightFromCPU
          rem P2 from CPU: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then temp1 = RandomCharacter : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] != NoCharacter then temp1 = NoCharacter : return
          if playerChar[3] != NoCharacter then temp1 = NoCharacter : return
          rem Both P3 and P4 are NO, so skip NO and go to Random
          temp1 = RandomCharacter
          return
CycleRightFromCPUDone
          rem Default for P1 or other players (not P2)
          temp1 = RandomCharacter
          return
          
CycleRightFromNO
          rem NoCharacter(255) goes to 0
          temp1 = 0
          return
          
          rem =================================================================
          rem CHARACTER SELECT DRAWING FUNCTIONS
          rem =================================================================

SelectDrawScreen
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0 : pf3 = 0 : pf4 = 0 : pf5 = 0
          
          rem Draw Player 1 selection (top left)
          player0x = 56 : player0y = 40
          gosub SelectDrawSprite
          gosub SelectDrawNumber
          
          rem Draw Player 2 selection (top right)
          player1x = 104 : player1y = 40
          gosub SelectDrawSprite
          gosub SelectDrawNumber
          
          rem Draw Player 3 selection (bottom left) if Quadtari
          if controllerStatus & SetQuadtariDetected then SelectDrawP3
          goto SelectSkipP3
SelectDrawP3
          player0x = 56 : player0y = 80
          gosub SelectDrawSprite
          gosub SelectDrawNumber
          
          rem Draw Player 4 selection (bottom right) if Quadtari
          if controllerStatus & SetQuadtariDetected then SelectDrawP4
          goto SelectSkipP4
SelectDrawP4
          player1x = 104 : player1y = 80
          gosub SelectDrawSprite
          gosub SelectDrawNumber
SelectSkipP3
SelectSkipP4
          
          rem Draw locked status indicators
          gosub SelectDrawLocks
          return
          
SelectDrawSprite
          rem Draw character sprite based on current position and playerChar
          rem Determine which player based on position
          temp3 = 255  : rem Initialize to invalid
          if player0x = 56 then SelectDeterminePlayerP0
          if player1x = 104 then SelectDeterminePlayerP1
          goto SelectDrawSpriteDone
          
SelectDeterminePlayerP0
          if player0y = 40 then temp3 = 0 : goto SelectLoadSprite
          if player0y = 80 then temp3 = 2 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
          
SelectDeterminePlayerP1
          if player1y = 40 then temp3 = 1 : goto SelectLoadSprite
          if player1y = 80 then temp3 = 3 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
          
SelectLoadSprite
          rem Load sprite for determined player
          if temp3 > 3 then SelectDrawSpriteDone
          dim temp3_player_save = temp6
          let temp3_player_save = temp3  : rem Save player number
          temp1 = playerChar[temp3_player_save]
          
          rem Use character select animation state
          rem charSelectPlayerAnimSeq has animation sequence (bit 0: 0=idle, 1=walk)
          rem charSelectPlayerAnimFrame has animation frame counter (0-7)
          rem Map to proper animation action: 0=idle (AnimIdle=1), 1=walk (AnimWalking=3)
          if charSelectPlayerAnimSeq[temp3_player_save] then SelectLoadWalkingSprite
          
          rem Idle animation
          temp2 = charSelectPlayerAnimFrame[temp3_player_save]  : rem frame
          rem LocateCharacterArt expects: temp1=char, temp2=frame, temp3=action, temp4=player
          temp3 = 1  : rem AnimIdle = 1
          temp4 = temp3_player_save
          gosub bank10 LocateCharacterArt
          goto SelectLoadSpriteColor
          
SelectLoadWalkingSprite
          rem Walking animation
          temp2 = charSelectPlayerAnimSeq[temp3_player_save]  : rem Use sequence counter as frame (0-3 for 4-frame walk)
          temp3 = 3  : rem AnimWalking = 3
          temp4 = temp3_player_save
          gosub bank10 LocateCharacterArt
          
SelectLoadSpriteColor
          rem Now set player color
          temp1 = playerChar[temp3_player_save]
          temp2 = 0  : rem not hurt
          temp3 = temp3_player_save  : rem player number
          temp4 = 0  : rem not flashing
          gosub LoadCharacterColors
          
          let temp3 = temp3_player_save  : rem Restore temp3 for possible future use
          
SelectDrawSpriteDone
          return
          
SelectDrawNumber
          rem Draw player number indicator below character
          rem Determine which player based on position (same as SelectDrawSprite logic)
          rem Check if we have valid player position
          if player0x = 56 then SelectNumberPlayerP0
          if player1x = 104 then SelectNumberPlayerP1
          rem No valid position, skip number
          goto SelectDrawNumberDone
          
SelectNumberPlayerP0
          if player0y = 40 then temp1 = 0 : goto NumberPositionCalculate
          if player0y = 80 then temp1 = 2 : goto NumberPositionCalculate
          goto SelectDrawNumberDone
          
SelectNumberPlayerP1
          if player1y = 40 then temp1 = 1 : goto NumberPositionCalculate
          if player1y = 80 then temp1 = 3 : goto NumberPositionCalculate
          goto SelectDrawNumberDone
          
NumberPositionCalculate
          rem temp1 now has player index (0-3)
          rem Determine X and Y positions and which sprite to use
          rem P1 (index 0): x=56, y=48, sprite=player0
          rem P2 (index 1): x=104, y=48, sprite=player1
          rem P3 (index 2): x=56, y=88, sprite=player0
          rem P4 (index 3): x=104, y=88, sprite=player1
          
          if !temp1 then SelectNumberP1  : rem P1 (0)
          if temp1 = 1 then SelectNumberP2  : rem P2 (1)
          if temp1 = 2 then SelectNumberP3  : rem P3 (2)
          goto SelectNumberP4  : rem P4 (3)
          
SelectNumberP1
          temp2 = 56 : temp3 = 48 : temp5 = 0 : temp4 = ColIndigo(14) : goto DrawNumberDigit
          rem P1: left, top row, player0, indigo
          
SelectNumberP2
          temp2 = 104 : temp3 = 48 : temp5 = 1 : temp4 = ColRed(14) : goto DrawNumberDigit
          rem P2: right, top row, player1, red
          
SelectNumberP3
          temp2 = 56 : temp3 = 88 : temp5 = 0 : temp4 = ColYellow(14) : goto DrawNumberDigit
          rem P3: left, bottom row, player0, yellow
          
SelectNumberP4
          temp2 = 104 : temp3 = 88 : temp5 = 1 : temp4 = ColGreen(14)
          rem P4: right, bottom row, player1, green
          
DrawNumberDigit
          rem temp1 already has player index (0-3), convert to digit (1-4)
          temp1 = temp1 + 1
          rem temp2=X, temp3=Y, temp4=color, temp5=sprite already set
          rem Call DrawDigit with these parameters (DrawPlayerNumber expects temp1=digit, temp2=X, temp3=Y, temp4=color, temp5=sprite)
          gosub bank10 DrawDigit
          
SelectDrawNumberDone
          return
          
SelectDrawLocks
          rem Draw locked status borders using playfield
          if playerLocked[0] then SelectDrawP0Border
          goto SelectSkipP0Border
SelectDrawP0Border
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
SelectSkipP0Border
          
          if playerLocked[1] then SelectDrawP1Border
          goto SelectSkipP1Border
SelectDrawP1Border
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
SelectSkipP1Border
          
          if controllerStatus & SetQuadtariDetected then SelectCheckP2Lock
          goto SelectSkipCheckP2Lock
SelectCheckP2Lock
          if playerLocked[2] then SelectDrawP2Border
          if playerLocked[3] then SelectDrawP3Border
SelectSkipCheckP2Lock
          return
          
SelectDrawP2Border
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
          return
          
SelectDrawP3Border
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
          return
          
          rem =================================================================
          rem ANIMATION UPDATES
          rem =================================================================

SelectUpdateAnimations
          rem Update character select animations for all players
          rem Players cycle through idle/walk animations to show selected characters
          rem Each player updates independently with staggered timing
          
          rem Update Player 1 animations (characters)
          if playerLocked[0] then SelectSkipPlayer0Anim  : rem Locked players don’t animate
          if playerChar[0] = CPUCharacter then SelectSkipPlayer0Anim  : rem CPU doesn’t animate
          if playerChar[0] = NoCharacter then SelectSkipPlayer0Anim  : rem NO doesn’t animate
          if playerChar[0] = RandomCharacter then SelectSkipPlayer0Anim  : rem Random doesn’t animate
          let temp1 = 0
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer0Anim
          rem Update Player 2 animations
          if playerLocked[1] then SelectSkipPlayer1Anim
          if playerChar[1] = CPUCharacter then SelectSkipPlayer1Anim
          if playerChar[1] = NoCharacter then SelectSkipPlayer1Anim
          if playerChar[1] = RandomCharacter then SelectSkipPlayer1Anim
          let temp1 = 1
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer1Anim
          rem Update Player 3 animations (if Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then SelectSkipPlayer23Anim
          if playerLocked[2] then SelectSkipPlayer2Anim
          if playerChar[2] = NoCharacter then SelectSkipPlayer2Anim
          if playerChar[2] = RandomCharacter then SelectSkipPlayer2Anim
          let temp1 = 2
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer2Anim
          rem Update Player 4 animations (if Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then SelectSkipPlayer23Anim
          if playerLocked[3] then SelectSkipPlayer23Anim
          if playerChar[3] = NoCharacter then SelectSkipPlayer23Anim
          if playerChar[3] = RandomCharacter then SelectSkipPlayer23Anim
          let temp1 = 3
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer23Anim
          return
          
          rem =================================================================
          rem UPDATE INDIVIDUAL PLAYER ANIMATION
          rem =================================================================
          
SelectUpdatePlayerAnim
          rem Update animation for a single player
          rem Input: temp1 = player index (0-3)
          rem Increment frame counter
          let charSelectPlayerAnimFrame[temp1] = charSelectPlayerAnimFrame[temp1] + 1
          
          rem Check if it’s time to advance frame (every 6 frames for 10fps at 60fps)
          if charSelectPlayerAnimFrame[temp1] >= AnimationFrameDelay then SelectAdvanceAnimFrame
          return
          
SelectAdvanceAnimFrame
          rem Reset frame counter
          let charSelectPlayerAnimFrame[temp1] = 0
          
          rem Check current animation sequence
          if !charSelectPlayerAnimSeq[temp1] then SelectAdvanceIdleAnim
          rem Walking animation: cycle through 4 frames (0-3)
          rem Use bit 0-1 of sequence counter
          let charSelectPlayerAnimSeq[temp1] = (charSelectPlayerAnimSeq[temp1] + 1) & 3
          
          rem After 4 walk frames (frame 3→0), switch to idle
          if charSelectPlayerAnimSeq[temp1] then return
          rem Switch back to idle after walk cycle
          let charSelectPlayerAnimSeq[temp1] = 0
          
          rem Toggle to walk sequence after idle
          rem Just set sequence flag to 1 (walk) for next cycle
          goto SelectAnimWaitForToggle
          
SelectAdvanceIdleAnim
          rem Idle animation cycles every 60 frames, then toggles to walk
          rem Use higher bit in sequence to count idle cycles
          rem Every 60 frames (10 idle animations), toggle to walk
          if frame & 63 then return  : rem Check every 64 frames roughly
          
          rem Toggle to walk
          let charSelectPlayerAnimSeq[temp1] = 1  : rem Start walking
          return
          
SelectAnimWaitForToggle
          rem Just return, toggling handled above
          return

          rem =================================================================
          rem CONTROLLER RESCAN DETECTION
          rem =================================================================
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          rem to handle Quadtari being connected/disconnected
          
CharacterSelectCheckControllerRescan
          rem Check for Game Select or Pause button press
          if switchselect then CharacterSelectDoRescan
          rem Check for Color/B&W switch toggle
          temp6 = switchbw
          if temp6 = colorBWPrevious_R then CharacterSelectRescanDone
          rem Switch toggled, do rescan
          gosub bank6 SelDetectQuad
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
          
CharacterSelectDoRescan
          rem Re-detect Quadtari via bank6
          gosub bank6 SelDetectQuad
          rem Debounce - wait for switch release
          drawscreen
          
CharacterSelectRescanDone
          return

