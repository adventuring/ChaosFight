          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER SELECT - PER-FRAME LOOP
          rem =================================================================
          rem Per-frame character selection screen with Quadtari support.
          rem Called from MainLoop each frame (gameMode 3).
          rem Players cycle through 16 characters and lock in their choice.
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
          rem Quadtari controller multiplexing
          if qtcontroller then CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then CharacterSelectPlayer0Left
          goto CharacterSelectSkipPlayer0Left
CharacterSelectPlayer0Left
          let playerChar[0] = playerChar[0] - 1
          if playerChar[0] > MaxCharacter then playerChar[0] = MaxCharacter
          let playerLocked[0] = 0
CharacterSelectSkipPlayer0Left
          if joy0right then CharacterSelectPlayer0Right
          goto CharacterSelectSkipPlayer0Right
CharacterSelectPlayer0Right
          let playerChar[0] = playerChar[0] + 1
          if playerChar[0] > MaxCharacter then playerChar[0] = 0
          let playerLocked[0] = 0
CharacterSelectSkipPlayer0Right
          rem Use skip-over pattern to avoid complex || operator
          let if joy0up then playerLocked[0] = 0 : goto CharacterSelectPlayer0LockClearDone
          let if joy0down then playerLocked[0] = 0
CharacterSelectPlayer0LockClearDone
          let if joy0fire then playerLocked[0] = 1

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then CharacterSelectPlayer1Left
          goto CharacterSelectSkipPlayer1Left
CharacterSelectPlayer1Left
          let playerChar[1] = playerChar[1] - 1
          if playerChar[1] > MaxCharacter then playerChar[1] = MaxCharacter
          let playerLocked[1] = 0
CharacterSelectSkipPlayer1Left
          if joy1right then CharacterSelectPlayer1Right
          goto CharacterSelectSkipPlayer1Right
CharacterSelectPlayer1Right
          let playerChar[1] = playerChar[1] + 1
          if playerChar[1] > MaxCharacter then playerChar[1] = 0
          let playerLocked[1] = 0
CharacterSelectSkipPlayer1Right
          rem Use skip-over pattern to avoid complex || operator
          let if joy1up then playerLocked[1] = 0 : goto CharacterSelectPlayer1LockClearDone
          let if joy1down then playerLocked[1] = 0
CharacterSelectPlayer1LockClearDone
          let if joy1fire then playerLocked[1] = 1
          
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
          let playerChar[2] = playerChar[2] - 1
          if playerChar[2] > MaxCharacter then playerChar[2] = MaxCharacter
          let playerLocked[2] = 0
CharacterSelectSkipPlayer3Left
          if joy0right then CharacterSelectPlayer3Right
          goto CharacterSelectSkipPlayer3Right
CharacterSelectPlayer3Right
          let playerChar[2] = playerChar[2] + 1
          if playerChar[2] > MaxCharacter then playerChar[2] = 0
          let playerLocked[2] = 0
CharacterSelectSkipPlayer3Right
          rem Use skip-over pattern to avoid complex || operator
          let if joy0up then playerLocked[2] = 0 : goto CharacterSelectPlayer2LockClearDone
          let if joy0down then playerLocked[2] = 0
CharacterSelectPlayer2LockClearDone
          let if joy0fire then playerLocked[2] = 1
CharacterSelectSkipPlayer3

          rem Handle Player 4 input (joy1 on odd frames)
          if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer4
          goto CharacterSelectSkipPlayer4
CharacterSelectHandlePlayer4
          if joy1left then CharacterSelectPlayer4Left
          goto CharacterSelectSkipPlayer4Left
CharacterSelectPlayer4Left
          let playerChar[3] = playerChar[3] - 1
          if playerChar[3] > MaxCharacter then playerChar[3] = MaxCharacter
          let playerLocked[3] = 0
CharacterSelectSkipPlayer4Left
          if joy1right then CharacterSelectPlayer4Right
          goto CharacterSelectSkipPlayer4Right
CharacterSelectPlayer4Right
          let playerChar[3] = playerChar[3] + 1
          if playerChar[3] > MaxCharacter then playerChar[3] = 0
          let playerLocked[3] = 0
CharacterSelectSkipPlayer4Right
          rem Use skip-over pattern to avoid complex || operator
          let if joy1up then playerLocked[3] = 0 : goto CharacterSelectPlayer3LockClearDone
          let if joy1down then playerLocked[3] = 0
CharacterSelectPlayer3LockClearDone
          let if joy1fire then playerLocked[3] = 1
CharacterSelectSkipPlayer4
          
          
          let qtcontroller = 0

CharacterSelectInputComplete
          rem Update character select animations
          gosub SelectUpdateAnimations

          rem Check if all players are ready to start (may transition to next mode)
          gosub CharacterSelectCheckReady

          rem Draw character selection screen
          gosub SelectDrawScreen

          drawscreen
          return

          rem =================================================================
          rem CHECK IF READY TO PROCEED
          rem =================================================================
CharacterSelectCheckReady
          let readyCount  = 0

          rem Count locked players
          if playerLocked[0] then readyCount = readyCount + 1
          if playerLocked[1] then readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then CharacterSelectCountQuadtari
          goto CharacterSelectSkipQuadtari
CharacterSelectCountQuadtari
          if playerLocked[2] then readyCount = readyCount + 1
          if playerLocked[3] then readyCount = readyCount + 1
CharacterSelectSkipQuadtari

          rem Check if enough players are ready
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariReady
          if playerLocked[0] then CharacterSelectFinish
          goto CharacterSelectReadyDone
CharacterSelectQuadtariReady
          let if readyCount > = 2 then CharacterSelectFinish
CharacterSelectReadyDone
          
          return

CharacterSelectFinish
          rem Store final selections
          let selectedChar1 = playerChar[0]
          let selectedChar2 = playerChar[1]
          let selectedChar3 = playerChar[2]
          let selectedChar4 = playerChar[3]
          
          rem Transition to falling animation
          gameMode = ModeFallingAnimation
          gosub bank13 ChangeGameMode
          return

