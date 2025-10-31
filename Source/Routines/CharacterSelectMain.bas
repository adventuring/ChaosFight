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
          rem   PlayerChar[0-3) - Selected character indices (0-15)
          rem   PlayerLocked[0-3) - Lock state (0=unlocked, 1=locked)
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   ReadyCount - Number of locked players
          rem =================================================================

SelInEntry
          

SelInLoop
          rem Quadtari controller multiplexing
          if qtcontroller then goto SelInHandleQuad
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then goto SelInP0Left
          goto SelInSkipP0Left
SelInP0Left
          PlayerChar[0] = PlayerChar[0] - 1
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = MaxCharacter
          PlayerLocked[0] = 0
SelInSkipP0Left
          if joy0right then goto SelInP0Right
          goto SelInSkipP0Right
SelInP0Right
          PlayerChar[0] = PlayerChar[0] + 1
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = 0
          PlayerLocked[0] = 0
SelInSkipP0Right
          if joy0up || joy0down then PlayerLocked[0] = 0
          if joy0fire then PlayerLocked[0] = 1

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then goto SelInP1Left
          goto SelInSkipP1Left
SelInP1Left
          PlayerChar[1] = PlayerChar[1] - 1
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = MaxCharacter
          PlayerLocked[1] = 0
SelInSkipP1Left
          if joy1right then goto SelInP1Right
          goto SelInSkipP1Right
SelInP1Right
          PlayerChar[1] = PlayerChar[1] + 1
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = 0
          PlayerLocked[1] = 0
SelInSkipP1Right
          if joy1up || joy1down then PlayerLocked[1] = 0
          if joy1fire then PlayerLocked[1] = 1
          
          qtcontroller = 1
          goto SelInComplete

SelInHandleQuad
          rem Handle Player 3 input (joy0 on odd frames)
          if ControllerStatus & SetQuadtariDetected then goto SelInHandleP3
          goto SelInSkipP3
SelInHandleP3
          if joy0left then goto SelInP3Left
          goto SelInSkipP3Left
SelInP3Left
          PlayerChar[2] = PlayerChar[2] - 1
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = MaxCharacter
          PlayerLocked[2] = 0
SelInSkipP3Left
          if joy0right then goto SelInP3Right
          goto SelInSkipP3Right
SelInP3Right
          PlayerChar[2] = PlayerChar[2] + 1
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = 0
          PlayerLocked[2] = 0
SelInSkipP3Right
          if joy0up || joy0down then PlayerLocked[2] = 0
          if joy0fire then PlayerLocked[2] = 1
SelInSkipP3

          rem Handle Player 4 input (joy1 on odd frames)
          if ControllerStatus & SetQuadtariDetected then goto SelInHandleP4
          goto SelInSkipP4
SelInHandleP4
          if joy1left then goto SelInP4Left
          goto SelInSkipP4Left
SelInP4Left
          PlayerChar[3] = PlayerChar[3] - 1
          if PlayerChar[3] > MaxCharacter then PlayerChar[3] = MaxCharacter
          PlayerLocked[3] = 0
SelInSkipP4Left
          if joy1right then goto SelInP4Right
          goto SelInSkipP4Right
SelInP4Right
          PlayerChar[3] = PlayerChar[3] + 1
          if PlayerChar[3] > MaxCharacter then PlayerChar[3] = 0
          PlayerLocked[3] = 0
SelInSkipP4Right
          if joy1up || joy1down then PlayerLocked[3] = 0
          if joy1fire then PlayerLocked[3] = 1
SelInSkipP4
          
          
          qtcontroller = 0

SelInComplete
          rem Update character select animations
          gosub SelectUpdateAnimations

          rem Check if all players are ready to start
          gosub SelInCheckReady

          rem Draw character selection screen
          gosub SelectDrawScreen

          drawscreen
          goto SelInLoop

          rem =================================================================
          rem CHECK IF READY TO PROCEED
          rem =================================================================
SelInCheckReady
          ReadyCount = 0

          rem Count locked players
          if PlayerLocked[0] then ReadyCount = ReadyCount + 1
          if PlayerLocked[1] then ReadyCount = ReadyCount + 1
          if ControllerStatus & SetQuadtariDetected then goto SelInCountQuad
          goto SelInSkipQuad
SelInCountQuad
          if PlayerLocked[2] then ReadyCount = ReadyCount + 1
          if PlayerLocked[3] then ReadyCount = ReadyCount + 1
SelInSkipQuad

          rem Check if enough players are ready
          if ControllerStatus & SetQuadtariDetected then goto SelInQuadReady
          if PlayerLocked[0] then goto SelInFinish
          goto SelInReadyDone
SelInQuadReady
          if ReadyCount >= 2 then goto SelInFinish
SelInReadyDone
          
          return

SelInFinish
          rem Store final selections
          SelectedChar1 = PlayerChar[0]
          SelectedChar2 = PlayerChar[1]
          SelectedChar3 = PlayerChar[2]
          SelectedChar4 = PlayerChar[3]
          return

