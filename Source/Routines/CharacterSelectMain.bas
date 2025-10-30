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

CharacterSelect1
          rem Set screen layout for character select (32×32 admin layout)
          gosub SetAdminScreenLayout
          
          rem Initialize character selections
          PlayerChar[0] = 0
          PlayerChar[1] = 0
          PlayerChar[2] = 0
          PlayerChar[3] = 0
          PlayerLocked[0] = 0
          PlayerLocked[1] = 0
          PlayerLocked[2] = 0
          PlayerLocked[3] = 0
          ControllerStatus = ControllerStatus & ClearQuadtariDetected
          
          rem Initialize character select animations
          CharSelectAnimTimer = 0
          CharSelectAnimState = 0
          CharSelectCharIndex = 0
          CharSelectAnimFrame = 0

          rem Check for Quadtari adapter
          gosub DetectQuadtari

          COLUBK = ColGray(0)

CharacterSelect1Loop
          rem Quadtari controller multiplexing
          if qtcontroller then goto HandleQuadtariControllers
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then goto HandlePlayer0Left
          goto SkipPlayer0Left
HandlePlayer0Left
          PlayerChar[0] = PlayerChar[0] - 1
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = MaxCharacter
          PlayerLocked[0] = 0
SkipPlayer0Left
          if joy0right then goto HandlePlayer0Right
          goto SkipPlayer0Right
HandlePlayer0Right
          PlayerChar[0] = PlayerChar[0] + 1
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = 0
          PlayerLocked[0] = 0
SkipPlayer0Right
          if joy0up || joy0down then PlayerLocked[0] = 0
          if joy0fire then PlayerLocked[0] = 1

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then goto HandlePlayer1Left
          goto SkipPlayer1Left
HandlePlayer1Left
          PlayerChar[1] = PlayerChar[1] - 1
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = MaxCharacter
          PlayerLocked[1] = 0
SkipPlayer1Left
          if joy1right then goto HandlePlayer1Right
          goto SkipPlayer1Right
HandlePlayer1Right
          PlayerChar[1] = PlayerChar[1] + 1
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = 0
          PlayerLocked[1] = 0
SkipPlayer1Right
          if joy1up || joy1down then PlayerLocked[1] = 0
          if joy1fire then PlayerLocked[1] = 1
          
          qtcontroller = 1
          goto HandleInputComplete

HandleQuadtariControllers
          rem Handle Player 3 input (joy0 on odd frames)
          if ControllerStatus & SetQuadtariDetected then goto HandlePlayer3Input
          goto SkipPlayer3Input
HandlePlayer3Input
          if joy0left then goto HandlePlayer3Left
          goto SkipPlayer3Left
HandlePlayer3Left
          PlayerChar[2] = PlayerChar[2] - 1
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = MaxCharacter
          PlayerLocked[2] = 0
SkipPlayer3Left
          if joy0right then goto HandlePlayer3Right
          goto SkipPlayer3Right
HandlePlayer3Right
          PlayerChar[2] = PlayerChar[2] + 1
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = 0
          PlayerLocked[2] = 0
SkipPlayer3Right
          if joy0up || joy0down then PlayerLocked[2] = 0
          if joy0fire then PlayerLocked[2] = 1
SkipPlayer3Input

          rem Handle Player 4 input (joy1 on odd frames)
          if ControllerStatus & SetQuadtariDetected then goto HandlePlayer4Input
          goto SkipPlayer4Input
HandlePlayer4Input
          if joy1left then goto HandlePlayer4Left
          goto SkipPlayer4Left
HandlePlayer4Left
          PlayerChar[3] = PlayerChar[3] - 1
          if PlayerChar[3] > MaxCharacter then PlayerChar[3] = MaxCharacter
          PlayerLocked[3] = 0
SkipPlayer4Left
          if joy1right then goto HandlePlayer4Right
          goto SkipPlayer4Right
HandlePlayer4Right
          PlayerChar[3] = PlayerChar[3] + 1
          if PlayerChar[3] > MaxCharacter then PlayerChar[3] = 0
          PlayerLocked[3] = 0
SkipPlayer4Right
          if joy1up || joy1down then PlayerLocked[3] = 0
          if joy1fire then PlayerLocked[3] = 1
SkipPlayer4Input
          
          
          qtcontroller = 0

HandleInputComplete
          rem Update character select animations
          gosub UpdateCharacterSelectAnimations

          rem Check if all players are ready to start
          gosub CheckAllPlayersReady1

          rem Draw character selection screen
          gosub DrawCharacterSelect1

          drawscreen
          goto CharacterSelect1Loop

          rem =================================================================
          rem CHECK IF READY TO PROCEED
          rem =================================================================
CheckAllPlayersReady1
          ReadyCount = 0

          rem Count locked players
          if PlayerLocked[0] then ReadyCount = ReadyCount + 1
          if PlayerLocked[1] then ReadyCount = ReadyCount + 1
          if ControllerStatus & SetQuadtariDetected then goto CountQuadtariPlayers
          goto SkipQuadtariPlayers
CountQuadtariPlayers
          if PlayerLocked[2] then ReadyCount = ReadyCount + 1
          if PlayerLocked[3] then ReadyCount = ReadyCount + 1
SkipQuadtariPlayers

          rem Check if enough players are ready
          if ControllerStatus & SetQuadtariDetected then goto CheckQuadtariReady
          if PlayerLocked[0] then goto CharacterSelectComplete1
          goto CheckReadyComplete
CheckQuadtariReady
          if ReadyCount >= 2 then goto CharacterSelectComplete1
CheckReadyComplete
          
          return

CharacterSelectComplete1
          rem Store final selections
          SelectedChar1 = PlayerChar[0]
          SelectedChar2 = PlayerChar[1]
          SelectedChar3 = PlayerChar[2]
          SelectedChar4 = PlayerChar[3]
          return

