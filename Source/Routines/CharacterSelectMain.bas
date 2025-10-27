          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER SELECT - MAIN LOOP
          rem =================================================================
          rem Main character selection screen with Quadtari support.
          rem Players cycle through 16 characters and lock in their choice.
          rem
          rem FLOW:
          rem   1. Detect Quadtari adapter
          rem   2. Initialize selections (all unlocked)
          rem   3. Loop: handle input with multiplexing
          rem   4. Update animations
          rem   5. Draw screen
          rem   6. Check if ready to proceed
          rem
          rem QUADTARI MULTIPLEXING:
          rem   Even frames (QtController=0): joy0=P1, joy1=P2
          rem   Odd frames (QtController=1): joy0=P3, joy1=P4
          rem
          rem AVAILABLE VARIABLES:
          rem   PlayerChar(0-3) - Selected character indices (0-15)
          rem   PlayerLocked(0-3) - Lock state (0=unlocked, 1=locked)
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   ReadyCount - Number of locked players
          rem =================================================================

CharacterSelect1
          rem Initialize character selections
          PlayerChar(0) = 0
          PlayerChar(1) = 0
          PlayerChar(2) = 0
          PlayerChar(3) = 0
          PlayerLocked(0) = 0
          PlayerLocked(1) = 0
          PlayerLocked(2) = 0
          PlayerLocked(3) = 0
          QuadtariDetected = 0
          
          rem Initialize character select animations
          CharSelectAnimTimer = 0
          CharSelectAnimState = 0
          CharSelectCharIndex = 0
          CharSelectAnimFrame = 0

          rem Check for Quadtari adapter
          gosub DetectQuadtari

          COLUBK = ColBlue(8)

CharacterSelect1Loop
          rem Quadtari controller multiplexing
          if QtController then goto HandleQuadtariControllers
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then
                    PlayerChar(0) = PlayerChar(0) - 1
                    if PlayerChar(0) < 0 then PlayerChar(0) = 15
                    PlayerLocked(0) = 0
          endif
          if joy0right then
                    PlayerChar(0) = PlayerChar(0) + 1
                    if PlayerChar(0) > 15 then PlayerChar(0) = 0
                    PlayerLocked(0) = 0
          endif
          if joy0up || joy0down then PlayerLocked(0) = 0
          if joy0fire then PlayerLocked(0) = 1

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then
                    PlayerChar(1) = PlayerChar(1) - 1
                    if PlayerChar(1) < 0 then PlayerChar(1) = 15
                    PlayerLocked(1) = 0
          endif
          if joy1right then
                    PlayerChar(1) = PlayerChar(1) + 1
                    if PlayerChar(1) > 15 then PlayerChar(1) = 0
                    PlayerLocked(1) = 0
          endif
          if joy1up || joy1down then PlayerLocked(1) = 0
          if joy1fire then PlayerLocked(1) = 1
          
          QtController = 1
          goto HandleInputComplete

HandleQuadtariControllers
          rem Handle Player 3 input (joy0 on odd frames)
          if QuadtariDetected then
                    if joy0left then
                              PlayerChar(2) = PlayerChar(2) - 1
                              if PlayerChar(2) < 0 then PlayerChar(2) = 15
                              PlayerLocked(2) = 0
                    endif
                    if joy0right then
                              PlayerChar(2) = PlayerChar(2) + 1
                              if PlayerChar(2) > 15 then PlayerChar(2) = 0
                              PlayerLocked(2) = 0
                    endif
                    if joy0up || joy0down then PlayerLocked(2) = 0
                    if joy0fire then PlayerLocked(2) = 1
          endif

          rem Handle Player 4 input (joy1 on odd frames)
          if QuadtariDetected then
                    if joy1left then
                              PlayerChar(3) = PlayerChar(3) - 1
                              if PlayerChar(3) < 0 then PlayerChar(3) = 15
                              PlayerLocked(3) = 0
                    endif
                    if joy1right then
                              PlayerChar(3) = PlayerChar(3) + 1
                              if PlayerChar(3) > 15 then PlayerChar(3) = 0
                              PlayerLocked(3) = 0
                    endif
                    if joy1up || joy1down then PlayerLocked(3) = 0
                    if joy1fire then PlayerLocked(3) = 1
          endif
          
          QtController = 0

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
          if PlayerLocked(0) then ReadyCount = ReadyCount + 1
          if PlayerLocked(1) then ReadyCount = ReadyCount + 1
          if QuadtariDetected then
                    if PlayerLocked(2) then ReadyCount = ReadyCount + 1
                    if PlayerLocked(3) then ReadyCount = ReadyCount + 1
          endif

          rem Check if enough players are ready
          if QuadtariDetected then
                    if ReadyCount >= 2 then goto CharacterSelectComplete1
          else
                    if PlayerLocked(0) then goto CharacterSelectComplete1
          endif
          return

CharacterSelectComplete1
          rem Store final selections
          SelectedChar1 = PlayerChar(0)
          SelectedChar2 = PlayerChar(1)
          SelectedChar3 = PlayerChar(2)
          SelectedChar4 = PlayerChar(3)
          return

