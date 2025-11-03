          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER SELECT - MAIN LOOP
          rem =================================================================
          rem Main character selection screen with Quadtari support.
          rem Players cycle through 16 selectable characters (0-15) and lock in their choice.
          rem Note: 17 characters total currently exist (16 selectable + Meth Hound 31)
          rem Future expansion limit = 32 characters total

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
          rem   PlayerChar[0-3] - Selected character indices (0-15)
          rem   PlayerLocked[0-3] - Lock state (0=unlocked, 1=locked)
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   ReadyCount - Number of locked players
          rem =================================================================

CharacterSelectInputEntry
          

CharacterSelectInputLoop
          rem Quadtari controller multiplexing
          if qtcontroller then goto CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then goto CharacterSelectPlayer0Left
          goto CharacterSelectSkipPlayer0Left
CharacterSelectPlayer0Left
          let PlayerChar[0] = PlayerChar[0] - 1
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = MaxCharacter
          let PlayerLocked[0] = 0
CharacterSelectSkipPlayer0Left
          if joy0right then goto CharacterSelectPlayer0Right
          goto CharacterSelectSkipPlayer0Right
CharacterSelectPlayer0Right
          let PlayerChar[0] = PlayerChar[0] + 1
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = 0
          let PlayerLocked[0] = 0
CharacterSelectSkipPlayer0Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then PlayerLocked[0] = 0 : goto CharacterSelectPlayer0LockClearDone
          if joy0down then PlayerLocked[0] = 0
CharacterSelectPlayer0LockClearDone
          if joy0fire then PlayerLocked[0] = 1

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then goto CharacterSelectPlayer1Left
          goto CharacterSelectSkipPlayer1Left
CharacterSelectPlayer1Left
          let PlayerChar[1] = PlayerChar[1] - 1
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = MaxCharacter
          let PlayerLocked[1] = 0
CharacterSelectSkipPlayer1Left
          if joy1right then goto CharacterSelectPlayer1Right
          goto CharacterSelectSkipPlayer1Right
CharacterSelectPlayer1Right
          let PlayerChar[1] = PlayerChar[1] + 1
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = 0
          let PlayerLocked[1] = 0
CharacterSelectSkipPlayer1Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then PlayerLocked[1] = 0 : goto CharacterSelectPlayer1LockClearDone
          if joy1down then PlayerLocked[1] = 0
CharacterSelectPlayer1LockClearDone
          if joy1fire then PlayerLocked[1] = 1
          
          qtcontroller = 1
          goto CharacterSelectInputComplete

CharacterSelectHandleQuadtari
          rem Handle Player 3 input (joy0 on odd frames)
          if ControllerStatus & SetQuadtariDetected then goto CharacterSelectHandlePlayer3
          goto CharacterSelectSkipPlayer3
CharacterSelectHandlePlayer3
          if joy0left then goto CharacterSelectPlayer3Left
          goto CharacterSelectSkipPlayer3Left
CharacterSelectPlayer3Left
          let PlayerChar[2] = PlayerChar[2] - 1
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = MaxCharacter
          let PlayerLocked[2] = 0
CharacterSelectSkipPlayer3Left
          if joy0right then goto CharacterSelectPlayer3Right
          goto CharacterSelectSkipPlayer3Right
CharacterSelectPlayer3Right
          let PlayerChar[2] = PlayerChar[2] + 1
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = 0
          let PlayerLocked[2] = 0
CharacterSelectSkipPlayer3Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then PlayerLocked[2] = 0 : goto CharacterSelectPlayer2LockClearDone
          if joy0down then PlayerLocked[2] = 0
CharacterSelectPlayer2LockClearDone
          if joy0fire then PlayerLocked[2] = 1
CharacterSelectSkipPlayer3

          rem Handle Player 4 input (joy1 on odd frames)
          if ControllerStatus & SetQuadtariDetected then goto CharacterSelectHandlePlayer4
          goto CharacterSelectSkipPlayer4
CharacterSelectHandlePlayer4
          if joy1left then goto CharacterSelectPlayer4Left
          goto CharacterSelectSkipPlayer4Left
CharacterSelectPlayer4Left
          let PlayerChar[3] = PlayerChar[3] - 1
          if PlayerChar[3] > MaxCharacter then PlayerChar[3] = MaxCharacter
          let PlayerLocked[3] = 0
CharacterSelectSkipPlayer4Left
          if joy1right then goto CharacterSelectPlayer4Right
          goto CharacterSelectSkipPlayer4Right
CharacterSelectPlayer4Right
          let PlayerChar[3] = PlayerChar[3] + 1
          if PlayerChar[3] > MaxCharacter then PlayerChar[3] = 0
          let PlayerLocked[3] = 0
CharacterSelectSkipPlayer4Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then PlayerLocked[3] = 0 : goto CharacterSelectPlayer3LockClearDone
          if joy1down then PlayerLocked[3] = 0
CharacterSelectPlayer3LockClearDone
          if joy1fire then PlayerLocked[3] = 1
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
          let ReadyCount = 0

          rem Count locked players
          if PlayerLocked[0] then ReadyCount = ReadyCount + 1
          if PlayerLocked[1] then ReadyCount = ReadyCount + 1
          if ControllerStatus & SetQuadtariDetected then goto CharacterSelectCountQuadtari
          goto CharacterSelectSkipQuadtari
CharacterSelectCountQuadtari
          if PlayerLocked[2] then ReadyCount = ReadyCount + 1
          if PlayerLocked[3] then ReadyCount = ReadyCount + 1
CharacterSelectSkipQuadtari

          rem Check if enough players are ready
          if ControllerStatus & SetQuadtariDetected then goto CharacterSelectQuadtariReady
          if PlayerLocked[0] then goto CharacterSelectFinish
          goto CharacterSelectReadyDone
CharacterSelectQuadtariReady
          if ReadyCount >= 2 then goto CharacterSelectFinish
CharacterSelectReadyDone
          
          return

CharacterSelectFinish
          rem Store final selections
          let selectedChar1 = PlayerChar[0]
          let selectedChar2 = PlayerChar[1]
          let selectedChar3 = PlayerChar[2]
          let selectedChar4 = PlayerChar[3]
          return

          rem =================================================================
          rem UPDATE CHARACTER SELECT ANIMATIONS
          rem =================================================================
          rem Simple animation updates for character select screen.
          rem Note: DOWN button only unlocks selection, does NOT trigger animations.
SelectUpdateAnimations
          rem Basic animation timer increment (no gameplay input handling)
          let CharSelectAnimTimer = CharSelectAnimTimer + 1
          if CharSelectAnimTimer > 60 then CharSelectAnimTimer = 0 : CharSelectAnimState = rand & 3
          if CharSelectAnimState > 2 then CharSelectAnimState = 0
          let CharSelectAnimFrame = CharSelectAnimFrame + 1
          if CharSelectAnimFrame > 7 then CharSelectAnimFrame = 0
          return

          rem =================================================================
          rem DRAW CHARACTER SELECT SCREEN
          rem =================================================================
          rem Placeholder for screen drawing function
SelectDrawScreen
          rem Screen drawing handled elsewhere
          return

