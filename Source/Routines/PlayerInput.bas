          rem ChaosFight - Source/Routines/PlayerInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER INPUT HANDLING
          rem =================================================================
          rem All input handling for the four players, with character-specific
          rem control logic dispatched to character-specific subroutines.

          rem QUADTARI MULTIPLEXING:
          rem   Even frames (qtcontroller=0): joy0=Player1, joy1=Player2
          rem   Odd frames (qtcontroller=1): joy0=Player3, joy1=Player4

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   playerX[0-3] - X positions
          rem   playerY[0-3] - Y positions
          rem   playerState[0-3] - State flags (attacking, guarding, jumping, etc.)
          rem   playerChar[0-3] - Character type indices (0-15)
          rem   playerMomentumX[0-3] - Horizontal momentum
          rem   controllerStatus - Packed controller detection status
          rem   qtcontroller - Multiplexing state (0=P1/P2, 1=P3/P4)

          rem STATE FLAGS (in playerState):
          rem   Bit 0: Facing (1 = right, 0 = left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (disabled during hitstun)
          rem   Bits 4-7: Animation state

          rem CHARACTER INDICES (0-15):
          rem   0=Bernie, 1=Curler, 2=Dragon of Storms, 3=Zoe Ryen, 4=FatTony, 5=Megax,
          rem   6=Harpy, 7=Knight, 8=Frooty, 9=Nefertem, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Shamone
          rem =================================================================

          rem Main input handler for all players
InputHandleAllPlayers
          if qtcontroller then goto InputHandleQuadtariPlayers
          
          rem Even frame: Handle Players 1 & 2 - only if alive  
          currentPlayer = 0 : gosub IsPlayerAlive
          if temp2 = 0 then goto InputSkipPlayer0Input
          if (playerState[0] & 8) <> 0 then goto InputSkipPlayer0Input
          currentPlayer = 0 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer0Input
          
          currentPlayer = 1 : gosub IsPlayerAlive
          if temp2 = 0 then goto InputSkipPlayer1Input
          if (playerState[1] & 8) <> 0 then goto InputSkipPlayer1Input
          goto InputHandlePlayer1
          
          goto InputSkipPlayer1Input
          
InputHandlePlayer1
          currentPlayer = 1 : gosub InputHandleRightPortPlayer 
          rem Player 1 uses Joy1
InputSkipPlayer1Input
          
          qtcontroller = 1 
          rem Switch to odd frame
          return

InputHandleQuadtariPlayers
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and alive)
          if !(controllerStatus & SetQuadtariDetected) then goto InputSkipPlayer3Input
          if selectedChar3 = 0 then goto InputSkipPlayer3Input
                    currentPlayer = 2 : gosub IsPlayerAlive
          if temp2 = 0 then goto InputSkipPlayer3Input
          if (playerState[2] & 8) <> 0 then goto InputSkipPlayer3Input
          currentPlayer = 2 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer3Input
          if !(controllerStatus & SetQuadtariDetected) then goto InputSkipPlayer4Input
          if selectedChar4 = 0 then goto InputSkipPlayer4Input
                    currentPlayer = 3 : gosub IsPlayerAlive
          if temp2 = 0 then goto InputSkipPlayer4Input
          if (playerState[3] & 8) <> 0 then goto InputSkipPlayer4Input
          currentPlayer = 3 : gosub InputHandleRightPortPlayer
          
InputSkipPlayer4Input
          
          
          qtcontroller = 0 
          rem Switch back to even frame
          return

          rem =================================================================
          rem LEFT PORT PLAYER INPUT HANDLER (Joy0 - Players 1 & 3)
          rem =================================================================
          rem INPUT: currentPlayer = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
InputHandleLeftPortPlayer
          rem Process left/right movement (with playfield collision for flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks for horizontal movement
          temp5 = playerChar[currentPlayer]
          if temp5 = 8 then goto FrootyDragonOfStormsLeftRightMovement
          if temp5 = 2 then goto FrootyDragonOfStormsLeftRightMovement
          
          rem Standard horizontal movement (no collision check)
          if joy0left then playerX[currentPlayer] = playerX[currentPlayer] - 1 : playerState[currentPlayer] = playerState[currentPlayer] & NOT 1 : playerMomentumX[currentPlayer] = 255
          if joy0right then playerX[currentPlayer] = playerX[currentPlayer] + 1 : playerState[currentPlayer] = playerState[currentPlayer] | 1 : playerMomentumX[currentPlayer] = 1
          goto SkipFlyingLeftRight
          
FrootyDragonOfStormsLeftRightMovement
          rem Flying characters: check playfield collision before horizontal movement
          rem Check left movement
          if joy0left then goto CheckLeftCollision
          goto CheckRightMovement
CheckLeftCollision
          rem Convert player position to playfield coordinates
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the left
          if temp2 <= 0 then goto CheckRightMovement
          rem Already at left edge
          temp3 = temp2 - 1
          rem temp3 = column to the left
          rem Check player current row (check both top and bottom of sprite)
          temp4 = playerY[currentPlayer]
          temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then goto CheckRightMovement
          rem Blocked, cannot move left
          rem Also check bottom row (feet)
          temp4 = temp4 + 16
          temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then goto MoveLeftOK
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then goto CheckRightMovement
          rem Blocked at bottom too
MoveLeftOK
          let playerX[currentPlayer] = playerX[currentPlayer] - 1
          let playerState[currentPlayer] = playerState[currentPlayer] & NOT 1
          let playerMomentumX[currentPlayer] = 255
CheckRightMovement
          rem Check right movement
          if !joy0right then goto SkipFlyingLeftRight
          rem Convert player position to playfield coordinates
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the right
          if temp2 >= 31 then goto SkipFlyingLeftRight
          rem Already at right edge
          temp3 = temp2 + 1
          rem temp3 = column to the right
          rem Check player current row (check both top and bottom of sprite)
          temp4 = playerY[currentPlayer]
          temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then goto SkipFlyingLeftRight
          rem Blocked, cannot move right
          rem Also check bottom row (feet)
          temp4 = temp4 + 16
          temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then goto MoveRightOK
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then goto SkipFlyingLeftRight
          rem Blocked at bottom too
MoveRightOK
          let playerX[currentPlayer] = playerX[currentPlayer] + 1
          let playerState[currentPlayer] = playerState[currentPlayer] | 1
          let playerMomentumX[currentPlayer] = 1
SkipFlyingLeftRight

          rem Process UP input for character-specific behaviors
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy0up then goto SkipUpInputHandling
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if playerChar[currentPlayer] = 15 then playerChar[currentPlayer] = 31 : goto SkipJumpInput
          rem Switch Shamone -> MethHound
          if playerChar[currentPlayer] = 31 then playerChar[currentPlayer] = 15 : goto SkipJumpInput
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          if playerChar[currentPlayer] = 0 then goto BernieFallThrough
          
          rem Check Harpy flap (Character 6)
          if playerChar[currentPlayer] = 6 then goto HarpyFlap
          
          rem For all other characters, UP is jump
          goto NormalJumpInput
          
BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall through 1-row floors)
          gosub BernieJump
          goto SkipJumpInput
          
HarpyFlap
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          gosub HarpyJump
          goto SkipJumpInput
          
NormalJumpInput
          rem Process jump input (UP + enhanced buttons)
          temp3 = 1
          rem Jump pressed flag (UP pressed)
          goto SkipUpInputHandling
          
SkipJumpInput
          temp3 = 0 
          rem No jump (UP used for special ability)
          
SkipUpInputHandling
          rem Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons only
          if playerChar[currentPlayer] = 15 then goto ShamoneJumpCheckEnhanced
          if playerChar[currentPlayer] = 31 then goto ShamoneJumpCheckEnhanced
          if playerChar[currentPlayer] = 0 then goto ShamoneJumpCheckEnhanced
          if playerChar[currentPlayer] = 6 then goto ShamoneJumpCheckEnhanced
          rem Bernie and Harpy also use enhanced buttons for jump
          
          rem Check Genesis/Joy2b+ Button C/II (INPT0 for Player 1, INPT2 for Player 3)
          if currentPlayer = 0 then goto CheckPlayer1Buttons
          goto InputSkipPlayer1Buttons
CheckPlayer1Buttons
          if !controllerStatus{0} then goto CheckPlayer1Joy2bPlus
          if !INPT0{7} then temp3 = 1
          goto InputSkipPlayer1Buttons
CheckPlayer1Joy2bPlus
          if !controllerStatus{1} then goto InputSkipPlayer1Buttons
          if !INPT0{7} then temp3 = 1
InputSkipPlayer1Buttons
          if currentPlayer = 2 then goto CheckPlayer3Buttons
          goto InputSkipPlayer3Buttons
CheckPlayer3Buttons
          if !controllerStatus{0} then goto CheckPlayer3Joy2bPlus
          if !INPT0{7} then temp3 = 1
          goto InputSkipPlayer3Buttons
CheckPlayer3Joy2bPlus
          if !controllerStatus{1} then goto InputSkipPlayer3Buttons
          if !INPT0{7} then temp3 = 1
InputSkipPlayer3Buttons
EnhancedJumpDone0
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as Shamone)
          if temp3 = 0 then InputSkipLeftPortJump
          if (playerState[currentPlayer] & 4) <> 0 then InputSkipLeftPortJump
          temp4 = playerChar[currentPlayer] 
          rem Character type
          rem Map MethHound (31) to ShamoneJump handler
          if temp4 = 31 then temp4 = 15
          rem Use Shamone jump for MethHound
                    on temp4 goto BernieJump, CurlerJump, DragonOfStormsJump, ZoeRyenJump, FatTonyJump, MegaxJump, HarpyJump, KnightJump, FrootyJump, NefertemJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, ShamoneJump
InputSkipLeftPortJump

          

          rem Process down/guard input
          rem Map MethHound (31) to ShamoneDown handler
          if joy0down then 
            temp4 = playerChar[currentPlayer]
            if temp4 = 31 then temp4 = 15
            rem Use Shamone guard for MethHound
            on temp4 goto BernieDown, CurlerDown, DragonOfStormsDown, ZoeRyenDown, FatTonyDown, MegaxDown, HarpyDown, KnightDown, FrootyDown, NefertemDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, ShamoneDown
          if !joy0down then playerState[currentPlayer] = playerState[currentPlayer] & NOT 2
          
          
          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          if !joy0fire then goto InputSkipLeftPortAttack
          if (playerState[currentPlayer] & 1) <> 0 then InputSkipLeftPortAttack
          temp4 = playerChar[currentPlayer]
          if temp4 = 31 then temp4 = 15
          rem Use Shamone attack for MethHound
          on temp4 goto BernieAttack, CurlerAttack, DragonOfStormsAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
InputSkipLeftPortAttack
          
          
          return

          rem =================================================================
          rem RIGHT PORT PLAYER INPUT HANDLER (Joy1 - Players 2 & 4)
          rem =================================================================
          rem INPUT: currentPlayer = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
InputHandleRightPortPlayer
          rem Process left/right movement (with playfield collision for flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks for horizontal movement
          temp5 = playerChar[currentPlayer]
          if temp5 = 8 then goto FrootyDragonOfStormsLeftRightMovementRight
          if temp5 = 2 then goto FrootyDragonOfStormsLeftRightMovementRight
          
          rem Standard horizontal movement (no collision check)
          if joy1left then
                    let playerX[currentPlayer] = playerX[currentPlayer] - 1
          let playerState[currentPlayer] = playerState[currentPlayer] & NOT 1 
          rem Face left
                    let playerMomentumX[currentPlayer] = 255
          
          if joy1right then
                    let playerX[currentPlayer] = playerX[currentPlayer] + 1
          let playerState[currentPlayer] = playerState[currentPlayer] | 1  
          rem Face right
                    let playerMomentumX[currentPlayer] = 1
          goto SkipFlyingLeftRightRight
          
FrootyDragonOfStormsLeftRightMovementRight
          rem Flying characters: check playfield collision before horizontal movement
          rem Check left movement
          if joy1left then goto CheckLeftCollisionRight
          goto CheckRightMovementRight
CheckLeftCollisionRight
          rem Convert player position to playfield coordinates
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the left
          if temp2 <= 0 then goto CheckRightMovementRight
          rem Already at left edge
          temp3 = temp2 - 1
          rem temp3 = column to the left
          rem Check player current row (check both top and bottom of sprite)
          temp4 = playerY[currentPlayer]
          temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then goto CheckRightMovementRight
          rem Blocked, cannot move left
          rem Also check bottom row (feet)
          temp4 = temp4 + 16
          temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then goto MoveLeftOKRight
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then goto CheckRightMovementRight
          rem Blocked at bottom too
MoveLeftOKRight
          let playerX[currentPlayer] = playerX[currentPlayer] - 1
          let playerState[currentPlayer] = playerState[currentPlayer] & NOT 1
          let playerMomentumX[currentPlayer] = 255
CheckRightMovementRight
          rem Check right movement
          if !joy1right then goto SkipFlyingLeftRightRight
          rem Convert player position to playfield coordinates
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the right
          if temp2 >= 31 then goto SkipFlyingLeftRightRight
          rem Already at right edge
          temp3 = temp2 + 1
          rem temp3 = column to the right
          rem Check player current row (check both top and bottom of sprite)
          temp4 = playerY[currentPlayer]
          temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then goto SkipFlyingLeftRightRight
          rem Blocked, cannot move right
          rem Also check bottom row (feet)
          temp4 = temp4 + 16
          temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then goto MoveRightOKRight
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then goto SkipFlyingLeftRightRight
          rem Blocked at bottom too
MoveRightOKRight
          let playerX[currentPlayer] = playerX[currentPlayer] + 1
          let playerState[currentPlayer] = playerState[currentPlayer] | 1
          let playerMomentumX[currentPlayer] = 1
SkipFlyingLeftRightRight
          

          rem Process UP input for character-specific behaviors (right port)
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy1up then goto SkipUpInputHandlingRight
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if playerChar[currentPlayer] = 15 then playerChar[currentPlayer] = 31 : goto SkipJumpInputRight
          rem Switch Shamone -> MethHound
          if playerChar[currentPlayer] = 31 then playerChar[currentPlayer] = 15 : goto SkipJumpInputRight
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          if playerChar[currentPlayer] = 0 then goto BernieFallThroughRight
          
          rem Check Harpy flap (Character 6)
          if playerChar[currentPlayer] = 6 then goto HarpyFlapRight
          
          rem For all other characters, UP is jump
          goto NormalJumpInputRight
          
BernieFallThroughRight
          rem Bernie UP input handled in BernieJump routine (fall through 1-row floors)
          gosub BernieJump
          goto SkipJumpInputRight
          
HarpyFlapRight
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          gosub HarpyJump
          goto SkipJumpInputRight
          
NormalJumpInputRight
          rem Process jump input (UP + enhanced buttons)
          temp3 = 1
          rem Jump pressed flag (UP pressed)
          goto SkipUpInputHandlingRight
          
SkipJumpInputRight
          temp3 = 0 
          rem No jump (UP used for special ability)
          
SkipUpInputHandlingRight
          rem Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons only
          if playerChar[currentPlayer] = 15 then goto ShamoneJumpCheckEnhancedRight
          if playerChar[currentPlayer] = 31 then goto ShamoneJumpCheckEnhancedRight
          if playerChar[currentPlayer] = 0 then goto ShamoneJumpCheckEnhancedRight
          if playerChar[currentPlayer] = 6 then goto ShamoneJumpCheckEnhancedRight
          rem Bernie and Harpy also use enhanced buttons for jump
          
          rem Check Genesis/Joy2b+ Button C/II (INPT2 for Player 2, INPT2 for Player 4)
          if currentPlayer = 1 then goto CheckPlayer2Buttons
          goto SkipPlayer2Buttons
CheckPlayer2Buttons
          if !(controllerStatus & $04) then goto CheckPlayer2Joy2bPlus
          if !(INPT2 & $80) then temp3 = 1
          goto SkipPlayer2Buttons
CheckPlayer2Joy2bPlus
          if !(controllerStatus & $08) then goto SkipPlayer2Buttons
          if !(INPT2 & $80) then temp3 = 1
SkipPlayer2Buttons
          if currentPlayer = 3 then goto CheckPlayer4Buttons
          goto SkipPlayer4Buttons
CheckPlayer4Buttons
          if !RightPortGenesis then goto CheckPlayer4Joy2bPlus
          if !INPT2{7} then temp3 = 1
          goto SkipPlayer4Buttons
CheckPlayer4Joy2bPlus
          if !RightPortJoy2bPlus then goto SkipPlayer4Buttons
          if !INPT2{7} then temp3 = 1
SkipPlayer4Buttons
EnhancedJumpDone1
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as Shamone)
          if temp3 = 0 then InputSkipRightPortJump
          if (playerState[currentPlayer] & 4) <> 0 then InputSkipRightPortJump
          temp4 = playerChar[currentPlayer] 
          rem Character type
          rem Map MethHound (31) to ShamoneJump handler
          if temp4 = 31 then temp4 = 15
          rem Use Shamone jump for MethHound
                    on temp4 goto BernieJump, CurlerJump, DragonOfStormsJump, ZoeRyenJump, FatTonyJump, MegaxJump, HarpyJump, KnightJump, FrootyJump, NefertemJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, ShamoneJump
InputSkipRightPortJump
          
          

          rem Process down/guard input
          rem Map MethHound (31) to ShamoneDown handler
          if joy1down then
          temp4 = playerChar[currentPlayer] 
            if temp4 = 31 then temp4 = 15
            rem Use Shamone guard for MethHound
                    on temp4 goto BernieDown, CurlerDown, DragonOfStormsDown, ZoeRyenDown, FatTonyDown, MegaxDown, HarpyDown, KnightDown, FrootyDown, NefertemDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, ShamoneDown

          let playerState[currentPlayer] = playerState[currentPlayer] & NOT 2 
          rem Clear guard bit
          
          
          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          if !joy1fire then goto InputSkipRightPortAttack
          if (playerState[currentPlayer] & 1) <> 0 then InputSkipRightPortAttack
          temp4 = playerChar[currentPlayer] 
          if temp4 = 31 then temp4 = 15
          rem Use Shamone attack for MethHound
                    on temp4 goto BernieAttack, CurlerAttack, DragonOfStormsAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
InputSkipRightPortAttack
          
          
          return

          rem =================================================================
          rem PAUSE BUTTON HANDLING WITH DEBOUNCING
          rem =================================================================
          rem Handles SELECT switch and Joy2b+ Button III with proper debouncing
          rem Uses pauseButtonPrev for debouncing state
          
HandlePauseInput
          rem Check SELECT switch (always available)
          temp1 = 0
          if switchselect then temp1 = 1
          
          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for Player 2)
          if LeftPortJoy2bPlus then goto CheckJoy2bButtons
          if RightPortJoy2bPlus then goto CheckJoy2bButtons
          goto Joy2bPauseDone
CheckJoy2bButtons
          if !INPT1{7} then temp1 = 1 
          rem Player 1 Button III
          if !INPT3{7} then temp1 = 1 
          rem Player 2 Button III
Joy2bPauseDone
          
          rem Debounce: only toggle if button just pressed (was 0, now 1)
          if temp1 = 0 then goto SkipPauseToggle
          if pauseButtonPrev then goto SkipPauseToggle
          let gameState = gameState ^ 1 
          rem Toggle pause (0<->1)
SkipPauseToggle
          
          
          rem Update previous button state for next frame
          let pauseButtonPrev = temp1
          
          return

          rem =================================================================
          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC ROUTINES
          rem =================================================================
          rem The original InputHandlePlayer1, HandlePlayer2Input, HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

