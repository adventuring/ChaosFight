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
          rem   PlayerX[0-3] - X positions
          rem   PlayerY[0-3] - Y positions
          rem   PlayerState[0-3] - State flags (attacking, guarding, jumping, etc.)
          rem   PlayerChar[0-3] - Character type indices (0-15)
          rem   PlayerMomentumX[0-3] - Horizontal momentum
          rem   ControllerStatus - Packed controller detection status
          rem   qtcontroller - Multiplexing state (0=P1/P2, 1=P3/P4)

          rem STATE FLAGS (in PlayerState):
          rem   Bit 0: Facing (1 = right, 0 = left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (disabled during hitstun)
          rem   Bits 4-7: Animation state

          rem CHARACTER INDICES (0-15):
          rem   0=Bernie, 1=Curler, 2=Dragonet, 3=ZoeRyen, 4=FatTony, 5=Megax,
          rem   6=Harpy, 7=KnightGuy, 8=Frooty, 9=Nefertem, 10=NinjishGuy,
          rem   11=PorkChop, 12=RadishGoblin, 13=RoboTito, 14=Ursulo, 15=Shamone
          rem =================================================================

          rem Main input handler for all players
InputHandleAllPlayers
          if qtcontroller then goto InputHandleQuadtariPlayers
          
          rem Even frame: Handle Players 1 & 2 - only if alive  
          let temp1 = 0 : gosub IsPlayerAlive
          if temp2 = 0 then InputSkipPlayer0Input
          if (PlayerState[0] & 8) <> 0 then InputSkipPlayer0Input
          let temp1 = 0 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer0Input
          
          let temp1 = 1 : gosub IsPlayerAlive
          if temp2 = 0 then InputSkipPlayer1Input
          if (PlayerState[1] & 8) <> 0 then InputSkipPlayer1Input
          goto InputHandlePlayer1
          
          goto InputSkipPlayer1Input
          
InputHandlePlayer1
          let temp1 = 1 : gosub InputHandleRightPortPlayer 
          rem Player 1 uses Joy1
InputSkipPlayer1Input
          
          qtcontroller = 1 
          rem Switch to odd frame
          return

InputHandleQuadtariPlayers
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and alive)
          if !(ControllerStatus & SetQuadtariDetected) then InputSkipPlayer3Input
          if SelectedChar3 = 0 then InputSkipPlayer3Input
                    temp1 = 2 : gosub IsPlayerAlive
          if temp2 = 0 then InputSkipPlayer3Input
          if (PlayerState[2] & 8) <> 0 then InputSkipPlayer3Input
          let temp1 = 2 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer3Input
          if !(ControllerStatus & SetQuadtariDetected) then InputSkipPlayer4Input
          if SelectedChar4 = 0 then InputSkipPlayer4Input
                    temp1 = 3 : gosub IsPlayerAlive
          if temp2 = 0 then InputSkipPlayer4Input
          if (PlayerState[3] & 8) <> 0 then InputSkipPlayer4Input
          let temp1 = 3 : gosub InputHandleRightPortPlayer
          
InputSkipPlayer4Input
          
          
          qtcontroller = 0 
          rem Switch back to even frame
          return

          rem =================================================================
          rem LEFT PORT PLAYER INPUT HANDLER (Joy0 - Players 1 & 3)
          rem =================================================================
          rem INPUT: temp1 = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
InputHandleLeftPortPlayer
          rem Process left/right movement (with playfield collision for flying characters)
          rem Frooty (8) and Dragonet (2) need collision checks for horizontal movement
          let temp5 = PlayerChar[temp1]
          if temp5 = 8 then FrootyDragonetLeftRightMovement
          if temp5 = 2 then FrootyDragonetLeftRightMovement
          
          rem Standard horizontal movement (no collision check)
          if joy0left then PlayerX[temp1] = PlayerX[temp1] - 1 : PlayerState[temp1] = PlayerState[temp1] & 254 : PlayerMomentumX[temp1] = 255
          if joy0right then PlayerX[temp1] = PlayerX[temp1] + 1 : PlayerState[temp1] = PlayerState[temp1] | 1 : PlayerMomentumX[temp1] = 1
          goto SkipFlyingLeftRight
          
FrootyDragonetLeftRightMovement
          rem Flying characters: check playfield collision before horizontal movement
          rem Check left movement
          if joy0left then CheckLeftCollision
          goto CheckRightMovement
CheckLeftCollision
          rem Convert player position to playfield coordinates
          let temp2 = PlayerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the left
          if temp2 <= 0 then goto CheckRightMovement
          rem Already at left edge
          let temp3 = temp2 - 1
          rem temp3 = column to the left
          rem Check player current row (check both top and bottom of sprite)
          let temp4 = PlayerY[temp1]
          let temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then CheckRightMovement
          rem Blocked, cannot move left
          rem Also check bottom row (feet)
          let temp4 = temp4 + 16
          let temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then MoveLeftOK
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then CheckRightMovement
          rem Blocked at bottom too
MoveLeftOK
          let PlayerX[temp1] = PlayerX[temp1] - 1
          let PlayerState[temp1] = PlayerState[temp1] & 254
          let PlayerMomentumX[temp1] = 255
CheckRightMovement
          rem Check right movement
          if !joy0right then goto SkipFlyingLeftRight
          rem Convert player position to playfield coordinates
          let temp2 = PlayerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the right
          if temp2 >= 31 then goto SkipFlyingLeftRight
          rem Already at right edge
          let temp3 = temp2 + 1
          rem temp3 = column to the right
          rem Check player current row (check both top and bottom of sprite)
          let temp4 = PlayerY[temp1]
          let temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then SkipFlyingLeftRight
          rem Blocked, cannot move right
          rem Also check bottom row (feet)
          let temp4 = temp4 + 16
          let temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then MoveRightOK
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then SkipFlyingLeftRight
          rem Blocked at bottom too
MoveRightOK
          let PlayerX[temp1] = PlayerX[temp1] + 1
          let PlayerState[temp1] = PlayerState[temp1] | 1
          let PlayerMomentumX[temp1] = 1
SkipFlyingLeftRight

          rem Process UP input for character-specific behaviors
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy0up then goto SkipUpInputHandling
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerChar[temp1] = 15 then PlayerChar[temp1] = 31 : goto SkipJumpInput
          rem Switch Shamone -> MethHound
          if PlayerChar[temp1] = 31 then PlayerChar[temp1] = 15 : goto SkipJumpInput
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          if PlayerChar[temp1] = 0 then BernieFallThrough
          
          rem Check Harpy flap (Character 6)
          if PlayerChar[temp1] = 6 then HarpyFlap
          
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
          let temp3 = 1
          rem Jump pressed flag (UP pressed)
          goto SkipUpInputHandling
          
SkipJumpInput
          let temp3 = 0 
          rem No jump (UP used for special ability)
          
SkipUpInputHandling
          rem Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons only
          if PlayerChar[temp1] = 15 then goto ShamoneJumpCheckEnhanced
          if PlayerChar[temp1] = 31 then goto ShamoneJumpCheckEnhanced
          if PlayerChar[temp1] = 0 then goto ShamoneJumpCheckEnhanced
          if PlayerChar[temp1] = 6 then goto ShamoneJumpCheckEnhanced
          rem Bernie and Harpy also use enhanced buttons for jump
          
          rem Check Genesis/Joy2b+ Button C/II (INPT0 for Player 1, INPT2 for Player 3)
          if temp1 = 0 then CheckPlayer1Buttons
          goto InputSkipPlayer1Buttons
CheckPlayer1Buttons
          if !ControllerStatus{0} then CheckPlayer1Joy2bPlus
          if !INPT0{7} then temp3 = 1
          goto InputSkipPlayer1Buttons
CheckPlayer1Joy2bPlus
          if !ControllerStatus{1} then InputSkipPlayer1Buttons
          if !INPT0{7} then temp3 = 1
InputSkipPlayer1Buttons
          if temp1 = 2 then CheckPlayer3Buttons
          goto InputSkipPlayer3Buttons
CheckPlayer3Buttons
          if !ControllerStatus{0} then CheckPlayer3Joy2bPlus
          if !INPT0{7} then temp3 = 1
          goto InputSkipPlayer3Buttons
CheckPlayer3Joy2bPlus
          if !ControllerStatus{1} then InputSkipPlayer3Buttons
          if !INPT0{7} then temp3 = 1
InputSkipPlayer3Buttons
EnhancedJumpDone0
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as Shamone)
          if temp3 = 0 then InputSkipLeftPortJump
          if (PlayerState[temp1] & 4) <> 0 then InputSkipLeftPortJump
          let temp4 = PlayerChar[temp1] 
          rem Character type
          rem Map MethHound (31) to ShamoneJump handler
          if temp4 = 31 then temp4 = 15
          rem Use Shamone jump for MethHound
                    on temp4 goto BernieJump, CurlerJump, DragonetJump, ZoeRyenJump, FatTonyJump, MegaxJump, HarpyJump, KnightGuyJump, FrootyJump, NefertemJump, NinjishGuyJump, PorkChopJump, RadishGoblinJump, RoboTitoJump, UrsuloJump, ShamoneJump
InputSkipLeftPortJump

          

          rem Process down/guard input
          rem Map MethHound (31) to ShamoneDown handler
          if joy0down then 
            temp4 = PlayerChar[temp1]
            if temp4 = 31 then temp4 = 15
            rem Use Shamone guard for MethHound
            on temp4 goto BernieDown, CurlerDown, DragonetDown, ZoeRyenDown, FatTonyDown, MegaxDown, HarpyDown, KnightGuyDown, FrootyDown, NefertemDown, NinjishGuyDown, PorkChopDown, RadishGoblinDown, RoboTitoDown, UrsuloDown, ShamoneDown
            goto GuardInputDoneLeft
          
          rem DOWN released - check for early guard release
          let temp2 = PlayerState[temp1] & 2
          if temp2 then StopGuardEarlyLeft
          rem Not guarding, nothing to do
          goto GuardInputDoneLeft
          
StopGuardEarlyLeft
          rem Stop guard early and start cooldown
          PlayerState[temp1] = PlayerState[temp1] & 253
          rem Clear guard bit
          let playerTimers[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
          
GuardInputDoneLeft
          
          
          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          rem Check if player is guarding - guard blocks attacks
          let temp2 = PlayerState[temp1] & 2
          if temp2 then InputSkipLeftPortAttack
          rem Guarding - block attack input
          if !joy0fire then InputSkipLeftPortAttack
          if (PlayerState[temp1] & 1) <> 0 then InputSkipLeftPortAttack
          let temp4 = PlayerChar[temp1]
          if temp4 = 31 then temp4 = 15
          rem Use Shamone attack for MethHound
          on temp4 goto BernieAttack, CurlerAttack, DragonetAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
InputSkipLeftPortAttack
          
          
          return

          rem =================================================================
          rem RIGHT PORT PLAYER INPUT HANDLER (Joy1 - Players 2 & 4)
          rem =================================================================
          rem INPUT: temp1 = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
InputHandleRightPortPlayer
          rem Process left/right movement (with playfield collision for flying characters)
          rem Check if player is guarding - guard blocks movement
          let temp6 = PlayerState[temp1] & 2
          if temp6 then SkipRightPortMovement
          rem Guarding - block movement
          
          rem Frooty (8) and Dragonet (2) need collision checks for horizontal movement
          let temp5 = PlayerChar[temp1]
          if temp5 = 8 then FrootyDragonetLeftRightMovementRight
          if temp5 = 2 then FrootyDragonetLeftRightMovementRight
          
          rem Standard horizontal movement (no collision check)
          if joy1left then
                    let PlayerX[temp1] = PlayerX[temp1] - 1
          let PlayerState[temp1] = PlayerState[temp1] & 254
          rem Face left
                    let PlayerMomentumX[temp1] = 255
          
          if joy1right then
                    let PlayerX[temp1] = PlayerX[temp1] + 1
          let PlayerState[temp1] = PlayerState[temp1] | 1
          rem Face right
                    let PlayerMomentumX[temp1] = 1
          goto SkipFlyingLeftRightRight
          
SkipRightPortMovement
          
FrootyDragonetLeftRightMovementRight
          rem Flying characters: check playfield collision before horizontal movement
          rem Check left movement
          if joy1left then CheckLeftCollisionRight
          goto CheckRightMovementRight
CheckLeftCollisionRight
          rem Convert player position to playfield coordinates
          let temp2 = PlayerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the left
          if temp2 <= 0 then goto CheckRightMovementRight
          rem Already at left edge
          let temp3 = temp2 - 1
          rem temp3 = column to the left
          rem Check player current row (check both top and bottom of sprite)
          let temp4 = PlayerY[temp1]
          let temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then CheckRightMovementRight
          rem Blocked, cannot move left
          rem Also check bottom row (feet)
          let temp4 = temp4 + 16
          let temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then MoveLeftOKRight
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then CheckRightMovementRight
          rem Blocked at bottom too
MoveLeftOKRight
          let PlayerX[temp1] = PlayerX[temp1] - 1
          let PlayerState[temp1] = PlayerState[temp1] & 254
          let PlayerMomentumX[temp1] = 255
CheckRightMovementRight
          rem Check right movement
          if !joy1right then goto SkipFlyingLeftRightRight
          rem Convert player position to playfield coordinates
          let temp2 = PlayerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          rem Check column to the right
          if temp2 >= 31 then goto SkipFlyingLeftRightRight
          rem Already at right edge
          let temp3 = temp2 + 1
          rem temp3 = column to the right
          rem Check player current row (check both top and bottom of sprite)
          let temp4 = PlayerY[temp1]
          let temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then SkipFlyingLeftRightRight
          rem Blocked, cannot move right
          rem Also check bottom row (feet)
          let temp4 = temp4 + 16
          let temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then MoveRightOKRight
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then SkipFlyingLeftRightRight
          rem Blocked at bottom too
MoveRightOKRight
          let PlayerX[temp1] = PlayerX[temp1] + 1
          let PlayerState[temp1] = PlayerState[temp1] | 1
          let PlayerMomentumX[temp1] = 1
SkipFlyingLeftRightRight
          

          rem Process UP input for character-specific behaviors (right port)
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy1up then goto SkipUpInputHandlingRight
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerChar[temp1] = 15 then PlayerChar[temp1] = 31 : goto SkipJumpInputRight
          rem Switch Shamone -> MethHound
          if PlayerChar[temp1] = 31 then PlayerChar[temp1] = 15 : goto SkipJumpInputRight
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          if PlayerChar[temp1] = 0 then BernieFallThroughRight
          
          rem Check Harpy flap (Character 6)
          if PlayerChar[temp1] = 6 then HarpyFlapRight
          
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
          let temp3 = 1
          rem Jump pressed flag (UP pressed)
          goto SkipUpInputHandlingRight
          
SkipJumpInputRight
          let temp3 = 0 
          rem No jump (UP used for special ability)
          
SkipUpInputHandlingRight
          rem Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons only
          if PlayerChar[temp1] = 15 then goto ShamoneJumpCheckEnhancedRight
          if PlayerChar[temp1] = 31 then goto ShamoneJumpCheckEnhancedRight
          if PlayerChar[temp1] = 0 then goto ShamoneJumpCheckEnhancedRight
          if PlayerChar[temp1] = 6 then goto ShamoneJumpCheckEnhancedRight
          rem Bernie and Harpy also use enhanced buttons for jump
          
          rem Check Genesis/Joy2b+ Button C/II (INPT2 for Player 2, INPT2 for Player 4)
          if temp1 = 1 then CheckPlayer2Buttons
          goto SkipPlayer2Buttons
CheckPlayer2Buttons
          if !(ControllerStatus & $04) then CheckPlayer2Joy2bPlus
          if !(INPT2 & $80) then temp3 = 1
          goto SkipPlayer2Buttons
CheckPlayer2Joy2bPlus
          if !(ControllerStatus & $08) then SkipPlayer2Buttons
          if !(INPT2 & $80) then temp3 = 1
SkipPlayer2Buttons
          if temp1 = 3 then CheckPlayer4Buttons
          goto SkipPlayer4Buttons
CheckPlayer4Buttons
          if !RightPortGenesis then CheckPlayer4Joy2bPlus
          if !INPT2{7} then temp3 = 1
          goto SkipPlayer4Buttons
CheckPlayer4Joy2bPlus
          if !RightPortJoy2bPlus then SkipPlayer4Buttons
          if !INPT2{7} then temp3 = 1
SkipPlayer4Buttons
EnhancedJumpDone1
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as Shamone)
          if temp3 = 0 then InputSkipRightPortJump
          if (PlayerState[temp1] & 4) <> 0 then InputSkipRightPortJump
          let temp4 = PlayerChar[temp1] 
          rem Character type
          rem Map MethHound (31) to ShamoneJump handler
          if temp4 = 31 then temp4 = 15
          rem Use Shamone jump for MethHound
                    on temp4 goto BernieJump, CurlerJump, DragonetJump, ZoeRyenJump, FatTonyJump, MegaxJump, HarpyJump, KnightGuyJump, FrootyJump, NefertemJump, NinjishGuyJump, PorkChopJump, RadishGoblinJump, RoboTitoJump, UrsuloJump, ShamoneJump
InputSkipRightPortJump

          

          rem Process down/guard input
          rem Map MethHound (31) to ShamoneDown handler
          if joy1down then
          let temp4 = PlayerChar[temp1] 
            if temp4 = 31 then temp4 = 15
            rem Use Shamone guard for MethHound
                    on temp4 goto BernieDown, CurlerDown, DragonetDown, ZoeRyenDown, FatTonyDown, MegaxDown, HarpyDown, KnightGuyDown, FrootyDown, NefertemDown, NinjishGuyDown, PorkChopDown, RadishGoblinDown, RoboTitoDown, UrsuloDown, ShamoneDown
            goto GuardInputDoneRight
          
          rem DOWN released - check for early guard release
          let temp2 = PlayerState[temp1] & 2
          if temp2 then StopGuardEarlyRight
          rem Not guarding, nothing to do
          goto GuardInputDoneRight
          
StopGuardEarlyRight
          rem Stop guard early and start cooldown
          PlayerState[temp1] = PlayerState[temp1] & 253
          rem Clear guard bit
          let playerTimers[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
          
GuardInputDoneRight
          
          
          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          rem Check if player is guarding - guard blocks attacks
          let temp2 = PlayerState[temp1] & 2
          if temp2 then InputSkipRightPortAttack
          rem Guarding - block attack input
          if !joy1fire then InputSkipRightPortAttack
          if (PlayerState[temp1] & 1) <> 0 then InputSkipRightPortAttack
          let temp4 = PlayerChar[temp1] 
          if temp4 = 31 then temp4 = 15
          rem Use Shamone attack for MethHound
                    on temp4 goto BernieAttack, CurlerAttack, DragonetAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
InputSkipRightPortAttack
          
          
          return

          rem =================================================================
          rem PAUSE BUTTON HANDLING WITH DEBOUNCING
          rem =================================================================
          rem Handles SELECT switch and Joy2b+ Button III with proper debouncing
          rem Uses PauseButtonPrev for debouncing state
          
HandlePauseInput
          rem Check SELECT switch (always available)
          let temp1 = 0
          if switchselect then temp1 = 1
          
          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for Player 2)
          if LeftPortJoy2bPlus then CheckJoy2bButtons
          if RightPortJoy2bPlus then CheckJoy2bButtons
          goto Joy2bPauseDone
CheckJoy2bButtons
          if !INPT1{7} then temp1 = 1 
          rem Player 1 Button III
          if !INPT3{7} then temp1 = 1 
          rem Player 2 Button III
Joy2bPauseDone
          
          rem Debounce: only toggle if button just pressed (was 0, now 1)
          if temp1 = 0 then SkipPauseToggle
          if PauseButtonPrev then SkipPauseToggle
          let GameState  = GameState ^ 1
          rem Toggle pause (0<->1)
SkipPauseToggle
          
          
          rem Update previous button state for next frame
          let PauseButtonPrev  = temp1
          
          return

          rem =================================================================
          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC ROUTINES
          rem =================================================================
          rem The original InputHandlePlayer1, HandlePlayer2Input, HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

