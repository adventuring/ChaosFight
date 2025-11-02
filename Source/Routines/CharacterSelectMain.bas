          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER SELECT - MAIN LOOP
          rem =================================================================
          rem Main character selection screen with Quadtari support.
          rem Players cycle through 16 characters and lock in their choice.

          rem FLOW:
          rem   1. Detect Quadtari adapter
          rem   2. Initialize selections (all unlocked)
          rem   3. Loop: handle input with multiplexing
          rem   4. Update animations
          rem   5. Draw screen
          rem   6. Check if ready to proceed

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
          

CharacterSelectInputLoop
          rem Quadtari controller multiplexing
          if qtcontroller then goto CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then goto CharacterSelectPlayer0Left
          goto CharacterSelectSkipPlayer0Left
CharacterSelectPlayer0Left
          playerChar[0] = playerChar[0] - 1
          if playerChar[0] > MaxCharacter then playerChar[0] = MaxCharacter
          playerLocked[0] = 0
CharacterSelectSkipPlayer0Left
          if joy0right then goto CharacterSelectPlayer0Right
          goto CharacterSelectSkipPlayer0Right
CharacterSelectPlayer0Right
          playerChar[0] = playerChar[0] + 1
          if playerChar[0] > MaxCharacter then playerChar[0] = 0
          playerLocked[0] = 0
CharacterSelectSkipPlayer0Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then playerLocked[0] = 0 : goto CharacterSelectPlayer0LockClearDone
          if joy0down then playerLocked[0] = 0
CharacterSelectPlayer0LockClearDone
          if joy0fire then playerLocked[0] = 1

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then goto CharacterSelectPlayer1Left
          goto CharacterSelectSkipPlayer1Left
CharacterSelectPlayer1Left
          playerChar[1] = playerChar[1] - 1
          if playerChar[1] > MaxCharacter then playerChar[1] = MaxCharacter
          playerLocked[1] = 0
CharacterSelectSkipPlayer1Left
          if joy1right then goto CharacterSelectPlayer1Right
          goto CharacterSelectSkipPlayer1Right
CharacterSelectPlayer1Right
          playerChar[1] = playerChar[1] + 1
          if playerChar[1] > MaxCharacter then playerChar[1] = 0
          playerLocked[1] = 0
CharacterSelectSkipPlayer1Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then playerLocked[1] = 0 : goto CharacterSelectPlayer1LockClearDone
          if joy1down then playerLocked[1] = 0
CharacterSelectPlayer1LockClearDone
          if joy1fire then playerLocked[1] = 1
          
          qtcontroller = 1
          goto CharacterSelectInputComplete

CharacterSelectHandleQuadtari
          rem Handle Player 3 input (joy0 on odd frames)
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectHandlePlayer3
          goto CharacterSelectSkipPlayer3
CharacterSelectHandlePlayer3
          if joy0left then goto CharacterSelectPlayer3Left
          goto CharacterSelectSkipPlayer3Left
CharacterSelectPlayer3Left
          playerChar[2] = playerChar[2] - 1
          if playerChar[2] > MaxCharacter then playerChar[2] = MaxCharacter
          playerLocked[2] = 0
CharacterSelectSkipPlayer3Left
          if joy0right then goto CharacterSelectPlayer3Right
          goto CharacterSelectSkipPlayer3Right
CharacterSelectPlayer3Right
          playerChar[2] = playerChar[2] + 1
          if playerChar[2] > MaxCharacter then playerChar[2] = 0
          playerLocked[2] = 0
CharacterSelectSkipPlayer3Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then playerLocked[2] = 0 : goto CharacterSelectPlayer2LockClearDone
          if joy0down then playerLocked[2] = 0
CharacterSelectPlayer2LockClearDone
          if joy0fire then playerLocked[2] = 1
CharacterSelectSkipPlayer3

          rem Handle Player 4 input (joy1 on odd frames)
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectHandlePlayer4
          goto CharacterSelectSkipPlayer4
CharacterSelectHandlePlayer4
          if joy1left then goto CharacterSelectPlayer4Left
          goto CharacterSelectSkipPlayer4Left
CharacterSelectPlayer4Left
          playerChar[3] = playerChar[3] - 1
          if playerChar[3] > MaxCharacter then playerChar[3] = MaxCharacter
          playerLocked[3] = 0
CharacterSelectSkipPlayer4Left
          if joy1right then goto CharacterSelectPlayer4Right
          goto CharacterSelectSkipPlayer4Right
CharacterSelectPlayer4Right
          playerChar[3] = playerChar[3] + 1
          if playerChar[3] > MaxCharacter then playerChar[3] = 0
          playerLocked[3] = 0
CharacterSelectSkipPlayer4Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then playerLocked[3] = 0 : goto CharacterSelectPlayer3LockClearDone
          if joy1down then playerLocked[3] = 0
CharacterSelectPlayer3LockClearDone
          if joy1fire then playerLocked[3] = 1
CharacterSelectSkipPlayer4
          
          
          qtcontroller = 0

CharacterSelectInputComplete
          rem Update character select animations
          gosub SelectUpdateAnimations

          rem Check if all players are ready to start
          gosub CharacterSelectCheckReady

          rem Draw character selection screen
          gosub SelectDrawScreen

          drawscreen
          goto CharacterSelectInputLoop

          rem =================================================================
          rem CHECK IF READY TO PROCEED
          rem =================================================================
CharacterSelectCheckReady
          readyCount = 0

          rem Count locked players
          if playerLocked[0] then readyCount = readyCount + 1
          if playerLocked[1] then readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectCountQuadtari
          goto CharacterSelectSkipQuadtari
CharacterSelectCountQuadtari
          if playerLocked[2] then readyCount = readyCount + 1
          if playerLocked[3] then readyCount = readyCount + 1
CharacterSelectSkipQuadtari

          rem Check if enough players are ready
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectQuadtariReady
          if playerLocked[0] then goto CharacterSelectFinish
          goto CharacterSelectReadyDone
CharacterSelectQuadtariReady
          if readyCount >= 2 then goto CharacterSelectFinish
CharacterSelectReadyDone
          
          return

CharacterSelectFinish
          rem Store final selections
          selectedChar1 = playerChar[0]
          selectedChar2 = playerChar[1]
          selectedChar3 = playerChar[2]
          selectedChar4 = playerChar[3]
          return

