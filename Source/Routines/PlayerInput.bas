          rem ChaosFight - Source/Routines/PlayerInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem PLAYER INPUT HANDLING
          rem ==========================================================
          rem All input handling for the four players, with
          rem   character-specific
          rem control logic dispatched to character-specific
          rem   subroutines.

          rem QUADTARI MULTIPLEXING:
          rem   Even frames (qtcontroller=0): joy0=Player1, joy1=Player2
          rem   Odd frames (qtcontroller=1): joy0=Player3, joy1=Player4

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   PlayerX[0-3] - X positions
          rem   PlayerY[0-3] - Y positions
          rem PlayerState[0-3] - State flags (attacking, guarding,
          rem   jumping, etc.)
          rem PlayerChar[0-3] - Character type indices (0-MaxCharacter)
          rem playerVelocityX[0-3] - Horizontal velocity (8.8
          rem   fixed-point)
          rem playerVelocityXL[0-3] - Horizontal velocity fractional
          rem   part
          rem   ControllerStatus - Packed controller detection status
          rem   qtcontroller - Multiplexing state (0=P1/P2, 1=P3/P4)

          rem STATE FLAGS (in PlayerState):
          rem   Bit 0: Facing (1 = right, 0 = left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (disabled during hitstun)
          rem   Bits 4-7: Animation state

          rem CHARACTER INDICES (0-MaxCharacter):
          rem 0=Bernie, 1=Curler, 2=Dragon of Storms, 3=ZoeRyen,
          rem   4=FatTony, 5=Megax,
          rem 6=Harpy, 7=KnightGuy, 8=Frooty, 9=Nefertem, 10=NinjishGuy,
          rem 11=PorkChop, 12=RadishGoblin, 13=RoboTito, 14=Ursulo,
          rem   15=Shamone
          rem ==========================================================

          rem ==========================================================
          rem ANIMATION STATE HELPER
          rem ==========================================================
          rem Extracts animation state (bits 4-7) from playerState
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = animation state (0-15)
          rem Uses: ActionAttackWindup=13, ActionAttackExecute=14,
          rem   ActionAttackRecovery=15
GetPlayerAnimationState
          dim GPAS_playerIndex = temp1
          dim GPAS_animationState = temp2
          let GPAS_animationState = playerState[GPAS_playerIndex] & 240
          rem Mask bits 4-7 (value 240 = %11110000)
          let GPAS_animationState = GPAS_animationState / 16
          rem Shift right by 4 (divide by 16) to get animation state
          rem   (0-15)
          return

          rem ==========================================================
          rem CHECK IF FACING SHOULD BE PRESERVED
          rem ==========================================================
          rem Returns 1 if facing should be preserved (during
          rem   hurt/recovery states),
          rem 0 if facing can be updated normally.
          rem Preserves facing during: recovery/hitstun (bit 3) OR hurt
          rem   animation states (5-9)
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp3 = 1 if facing should be preserved, 0 if can
          rem   update
          rem EFFECTS: Uses temp2 for animation state check
ShouldPreserveFacing
          dim SPF_playerIndex = temp1
          dim SPF_animationState = temp2
          dim SPF_preserveFlag = temp3
          rem Check recovery/hitstun flag (bit 3)
          if (playerState[SPF_playerIndex] & 8) then SPF_PreserveYes
          rem Bit 3 set = in recovery, preserve facing
          
          rem Check animation state for hurt states (5-9)
          rem ActionHit=5, ActionFallBack=6, ActionFallDown=7,
          rem   ActionFallen=8, ActionRecovering=9
          gosub GetPlayerAnimationState
          let SPF_animationState = temp2
          if SPF_animationState < 5 then SPF_PreserveNo
          rem Animation state < 5, allow facing update
          if SPF_animationState > 9 then SPF_PreserveNo
          rem Animation state > 9, allow facing update
          
SPF_PreserveYes
          rem In hurt/recovery state, preserve facing
          let SPF_preserveFlag = 1
          let temp3 = SPF_preserveFlag
          return
          
SPF_PreserveNo
          rem Not in hurt/recovery state, allow facing update
          let SPF_preserveFlag = 0
          let temp3 = SPF_preserveFlag
          return

          rem Main input handler for all players
InputHandleAllPlayers
          dim IHAP_isAlive = temp2
          if qtcontroller then goto InputHandleQuadtariPlayers
          
          rem Even frame: Handle Players 1 & 2 - only if alive  
          let currentPlayer = 0 : gosub IsPlayerAlive
          let IHAP_isAlive = temp2
          if IHAP_isAlive = 0 then InputSkipPlayer0Input
          if (PlayerState[0] & 8) then InputSkipPlayer0Input
          let temp1 = 0 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer0Input
          
          let currentPlayer = 1 : gosub IsPlayerAlive
          let IHAP_isAlive = temp2
          if IHAP_isAlive = 0 then InputSkipPlayer1Input
          if (PlayerState[1] & 8) then InputSkipPlayer1Input
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
          dim IHQP_isAlive = temp2
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and
          rem   alive)
          if !(ControllerStatus & SetQuadtariDetected) then InputSkipPlayer3Input
          if selectedChar3_R = 0 then InputSkipPlayer3Input
          let currentPlayer = 2 : gosub IsPlayerAlive
          let IHQP_isAlive = temp2
          if IHQP_isAlive = 0 then InputSkipPlayer3Input
          if (PlayerState[2] & 8) then InputSkipPlayer3Input
          let temp1 = 2 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer3Input
          if !(ControllerStatus & SetQuadtariDetected) then InputSkipPlayer4Input
          if selectedChar4_R = 0 then InputSkipPlayer4Input
          let currentPlayer = 3 : gosub IsPlayerAlive
          let IHQP_isAlive = temp2
          if IHQP_isAlive = 0 then InputSkipPlayer4Input
          if (PlayerState[3] & 8) then InputSkipPlayer4Input
          let temp1 = 3 : gosub InputHandleRightPortPlayer
          
InputSkipPlayer4Input
          
          
          qtcontroller = 0 
          rem Switch back to even frame
          return

          rem ==========================================================
          rem LEFT PORT PLAYER INPUT HANDLER (Joy0 - Players 1 & 3)
          rem ==========================================================
          rem INPUT: temp1 = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
InputHandleLeftPortPlayer
          dim IHLP_playerIndex = temp1
          dim IHLP_animationState = temp2
          dim IHLP_characterType = temp5
          rem Check animation state - block movement during attack
          rem   animations (states 13-15)
          gosub GetPlayerAnimationState
          let IHLP_animationState = temp2
          if IHLP_animationState >= 13 then DoneLeftPortMovement
          rem Block movement during attack windup/execute/recovery
          
          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          rem   for horizontal movement
          let IHLP_characterType = PlayerChar[IHLP_playerIndex]
          if IHLP_characterType = 8 then FrootyDragonetLeftRightMovement
          if IHLP_characterType = 2 then FrootyDragonetLeftRightMovement
          
          rem Standard horizontal movement (modifies velocity, not
          rem   position)
          rem Left movement: set negative velocity (255 in 8-bit two's
          rem   complement = -1)
          if !joy0left then goto DoneLeftMovement
          let playerVelocityX[IHLP_playerIndex] = 255
          let playerVelocityXL[IHLP_playerIndex] = 0
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[IHLP_playerIndex] = PlayerState[IHLP_playerIndex] & (255 - PlayerStateBitFacing)
DoneLeftMovement
          rem Right movement: set positive velocity
          if !joy0right then goto DoneRightMovement
          let playerVelocityX[IHLP_playerIndex] = 1
          let playerVelocityXL[IHLP_playerIndex] = 0
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[IHLP_playerIndex] = PlayerState[IHLP_playerIndex] | 1
DoneRightMovement
          goto DoneFlyingLeftRight
DoneLeftPortMovement
          
FrootyDragonetLeftRightMovement
          dim FDLRM_pfColumn = temp2
          dim FDLRM_leftColumn = temp3
          dim FDLRM_playerY = temp4
          dim FDLRM_pfRow = temp6
          rem Flying characters: check playfield collision before
          rem   horizontal movement
          if joy0left then CheckLeftCollision
          goto CheckRightMovement
CheckLeftCollision
          rem Convert player position to playfield coordinates
          let FDLRM_pfColumn = PlayerX[IHLP_playerIndex]
          let FDLRM_pfColumn = FDLRM_pfColumn - ScreenInsetX
          let FDLRM_pfColumn = FDLRM_pfColumn / 4
          rem pfColumn = playfield column
          if FDLRM_pfColumn > 31 then FDLRM_pfColumn = 31
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if FDLRM_pfColumn & $80 then FDLRM_pfColumn = 0
          rem Check column to the left
          if FDLRM_pfColumn <= 0 then goto CheckRightMovement
          rem Already at left edge
          let FDLRM_leftColumn = FDLRM_pfColumn - 1
          rem leftColumn = column to the left
          rem Check player current row (check both top and bottom of
          rem   sprite)
          let FDLRM_playerY = PlayerY[IHLP_playerIndex]
          let temp2 = FDLRM_playerY
          gosub DivideByPfrowheight
          let FDLRM_pfRow = temp2
          rem pfRow = top row
          rem Check if blocked in current row
          if pfread(FDLRM_leftColumn, FDLRM_pfRow) then CheckRightMovement
          rem Blocked, cannot move left
          rem Also check bottom row (feet)
          let FDLRM_playerY = FDLRM_playerY + 16
          let temp2 = FDLRM_playerY
          gosub DivideByPfrowheight
          let FDLRM_pfRow = temp2
          if FDLRM_pfRow >= pfrows then MoveLeftOK
          rem Do not check if beyond screen
          if pfread(FDLRM_leftColumn, FDLRM_pfRow) then CheckRightMovement
          rem Blocked at bottom too
MoveLeftOK
          rem Apply leftward velocity impulse (double-width sprite: 16px
          rem   width)
          let playerVelocityX[IHLP_playerIndex] = 255
          rem -1 in 8-bit two’s complement: 256 - 1 = 255
          let playerVelocityXL[IHLP_playerIndex] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem   (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[IHLP_playerIndex] = PlayerState[IHLP_playerIndex] & (255 - PlayerStateBitFacing)
CheckRightMovement
          dim CRM_pfColumn = temp2
          dim CRM_rightColumn = temp3
          dim CRM_playerY = temp4
          dim CRM_pfRow = temp6
          if !joy0right then goto DoneFlyingLeftRight
          rem Convert player position to playfield coordinates
          let CRM_pfColumn = PlayerX[IHLP_playerIndex]
          let CRM_pfColumn = CRM_pfColumn - ScreenInsetX
          let CRM_pfColumn = CRM_pfColumn / 4
          rem pfColumn = playfield column
          if CRM_pfColumn > 31 then CRM_pfColumn = 31
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if CRM_pfColumn & $80 then CRM_pfColumn = 0
          rem Check column to the right
          if CRM_pfColumn >= 31 then goto DoneFlyingLeftRight
          rem Already at right edge
          let CRM_rightColumn = CRM_pfColumn + 1
          rem rightColumn = column to the right
          rem Check player current row (check both top and bottom of
          rem   sprite)
          let CRM_playerY = PlayerY[IHLP_playerIndex]
          let temp2 = CRM_playerY
          gosub DivideByPfrowheight
          let CRM_pfRow = temp2
          rem pfRow = top row
          rem Check if blocked in current row
          if pfread(CRM_rightColumn, CRM_pfRow) then DoneFlyingLeftRight
          rem Blocked, cannot move right
          rem Also check bottom row (feet)
          let CRM_playerY = CRM_playerY + 16
          let temp2 = CRM_playerY
          gosub DivideByPfrowheight
          let CRM_pfRow = temp2
          if CRM_pfRow >= pfrows then MoveRightOK
          rem Do not check if beyond screen
          if pfread(CRM_rightColumn, CRM_pfRow) then DoneFlyingLeftRight
          rem Blocked at bottom too
MoveRightOK
          rem Apply rightward velocity impulse
          let playerVelocityX[IHLP_playerIndex] = 1
          let playerVelocityXL[IHLP_playerIndex] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem   (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[IHLP_playerIndex] = PlayerState[IHLP_playerIndex] | 1
DoneFlyingLeftRight

          dim SUIH_jumpPressed = temp3
          dim EJ_jumpPressed = temp3
          dim EJ_characterType = temp4
          rem Process UP input for character-specific behaviors
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy0up then goto DoneUpInputHandling
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerChar[IHLP_playerIndex] = 15 then let PlayerChar[IHLP_playerIndex] = 31 : goto DoneJumpInput
          rem Switch Shamone -> MethHound
          if PlayerChar[IHLP_playerIndex] = 31 then let PlayerChar[IHLP_playerIndex] = 15 : goto DoneJumpInput
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          if PlayerChar[IHLP_playerIndex] = 0 then BernieFallThrough
          
          rem Check Harpy flap (Character 6)
          if PlayerChar[IHLP_playerIndex] = 6 then HarpyFlap
          
          rem For all other characters, UP is jump
          goto NormalJumpInput
          
BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall
          rem   through 1-row floors)
          gosub BernieJump
          goto DoneJumpInput
          
HarpyFlap
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          gosub HarpyJump
          goto DoneJumpInput
          
NormalJumpInput
          rem Process jump input (UP + enhanced buttons)
          let SUIH_jumpPressed = 1
          rem Jump pressed flag (UP pressed)
          goto DoneUpInputHandling
          
DoneJumpInput
          let SUIH_jumpPressed = 0 
          rem No jump (UP used for special ability)
          
DoneUpInputHandling
          rem Process jump input from enhanced buttons (Genesis/Joy2b+
          rem   Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump
          rem   via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced
          rem   buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons
          rem   only
          if PlayerChar[IHLP_playerIndex] = 15 then goto ShamoneJumpCheckEnhanced
          if PlayerChar[IHLP_playerIndex] = 31 then goto ShamoneJumpCheckEnhanced
          if PlayerChar[IHLP_playerIndex] = 0 then goto ShamoneJumpCheckEnhanced
          if PlayerChar[IHLP_playerIndex] = 6 then goto ShamoneJumpCheckEnhanced
          rem Bernie and Harpy also use enhanced buttons for jump
          
          rem Check Genesis/Joy2b+ Button C/II (INPT0 for Player 1,
          rem   INPT2 for Player 3)
          if IHLP_playerIndex = 0 then CheckPlayer1Buttons
          goto InputSkipPlayer1Buttons
CheckPlayer1Buttons
          if !ControllerStatus{0} then CheckPlayer1Joy2bPlus
          if !INPT0{7} then SUIH_jumpPressed = 1
          goto InputSkipPlayer1Buttons
CheckPlayer1Joy2bPlus
          if !ControllerStatus{1} then InputSkipPlayer1Buttons
          if !INPT0{7} then SUIH_jumpPressed = 1
InputSkipPlayer1Buttons
          if IHLP_playerIndex = 2 then CheckPlayer3Buttons
          goto InputSkipPlayer3Buttons
CheckPlayer3Buttons
          if !ControllerStatus{0} then CheckPlayer3Joy2bPlus
          if !INPT0{7} then SUIH_jumpPressed = 1
          goto InputSkipPlayer3Buttons
CheckPlayer3Joy2bPlus
          if !ControllerStatus{1} then InputSkipPlayer3Buttons
          if !INPT0{7} then SUIH_jumpPressed = 1
InputSkipPlayer3Buttons
EnhancedJumpDone0
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          rem   Shamone)
          let EJ_jumpPressed = SUIH_jumpPressed
          if EJ_jumpPressed = 0 then InputSkipLeftPortJump
          if (PlayerState[IHLP_playerIndex] & 4) then InputSkipLeftPortJump
          rem Check animation state - block jump during attack
          rem   animations (states 13-15)
          gosub GetPlayerAnimationState
          let IHLP_animationState = temp2
          if IHLP_animationState >= 13 then InputSkipLeftPortJump
          rem Block jump during attack windup/execute/recovery
          let EJ_characterType = PlayerChar[IHLP_playerIndex]
          rem Dispatch to character-specific jump handler (0-31)
          rem MethHound (31) uses ShamoneJump handler
          if EJ_characterType < 8 then on EJ_characterType goto BernieJump, CurlerJump, DragonetJump, ZoeRyenJump, FatTonyJump, MegaxJump, HarpyJump, KnightGuyJump
          if EJ_characterType < 8 then goto DoneLeftPortJumpDispatch
          let EJ_characterType = EJ_characterType - 8
          if EJ_characterType < 8 then on EJ_characterType goto FrootyJump, NefertemJump, NinjishGuyJump, PorkChopJump, RadishGoblinJump, RoboTitoJump, UrsuloJump, ShamoneJump
          if EJ_characterType < 8 then goto DoneLeftPortJumpDispatch
          let EJ_characterType = EJ_characterType - 8
          if EJ_characterType < 8 then on EJ_characterType goto Char16Jump, Char17Jump, Char18Jump, Char19Jump, Char20Jump, Char21Jump, Char22Jump, Char23Jump
          if EJ_characterType < 8 then goto DoneLeftPortJumpDispatch
          let EJ_characterType = EJ_characterType - 8
          on EJ_characterType goto Char24Jump, Char25Jump, Char26Jump, Char27Jump, Char28Jump, Char29Jump, Char30Jump, ShamoneJump
DoneLeftPortJumpDispatch
InputSkipLeftPortJump

          

          dim GDIL_characterType = temp4
          dim GDIL_guardState = temp2
          rem Process down/guard input
          if joy0down then 
            let GDIL_characterType = PlayerChar[IHLP_playerIndex]
            rem Dispatch to character-specific down handler (0-31)
            rem MethHound (31) uses ShamoneDown handler
            let temp4 = GDIL_characterType
            if temp4 < 8 then on temp4 goto BernieDown, CurlerDown, DragonetDown, ZoeRyenDown, FatTonyDown, MegaxDown, HarpyDown, KnightGuyDown
            if temp4 < 8 then goto DoneLeftPortDownDispatch
            temp4 = temp4 - 8
            if temp4 < 8 then on temp4 goto FrootyDown, NefertemDown, NinjishGuyDown, PorkChopDown, RadishGoblinDown, RoboTitoDown, UrsuloDown, ShamoneDown
            if temp4 < 8 then goto DoneLeftPortDownDispatch
            temp4 = temp4 - 8
            if temp4 < 8 then on temp4 goto Char16Down, Char17Down, Char18Down, Char19Down, Char20Down, Char21Down, Char22Down, Char23Down
            if temp4 < 8 then goto DoneLeftPortDownDispatch
            temp4 = temp4 - 8
            on temp4 goto Char24Down, Char25Down, Char26Down, Char27Down, Char28Down, Char29Down, Char30Down, ShamoneDown
DoneLeftPortDownDispatch
            goto GuardInputDoneLeft
          
          rem DOWN released - check for early guard release
          let GDIL_guardState = PlayerState[IHLP_playerIndex] & 2
          if GDIL_guardState then StopGuardEarlyLeft
          rem Not guarding, nothing to do
          goto GuardInputDoneLeft
          
StopGuardEarlyLeft
          rem Stop guard early and start cooldown
          let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitGuarding)
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
          
GuardInputDoneLeft
          
          
          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          rem Check animation state - block attack input during attack
          rem   animations (states 13-15)
          gosub GetPlayerAnimationState
          if temp2 >= 13 then InputSkipLeftPortAttack
          rem Block attack input during attack windup/execute/recovery
          rem Check if player is guarding - guard blocks attacks
          let temp2 = PlayerState[temp1] & 2
          if temp2 then InputSkipLeftPortAttack
          rem Guarding - block attack input
          if !joy0fire then InputSkipLeftPortAttack
          if (PlayerState[temp1] & PlayerStateBitFacing) then InputSkipLeftPortAttack
          let temp4 = PlayerChar[temp1]
          rem Dispatch to character-specific attack handler (0-31)
          rem MethHound (31) uses ShamoneAttack handler
          if temp4 < 8 then on temp4 goto BernieAttack, CurlerAttack, DragonetAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack
          if temp4 < 8 then goto DoneLeftPortAttackDispatch
          temp4 = temp4 - 8
          if temp4 < 8 then on temp4 goto FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
          if temp4 < 8 then goto DoneLeftPortAttackDispatch
          temp4 = temp4 - 8
          if temp4 < 8 then on temp4 goto Char16Attack, Char17Attack, Char18Attack, Char19Attack, Char20Attack, Char21Attack, Char22Attack, Char23Attack
          if temp4 < 8 then goto DoneLeftPortAttackDispatch
          temp4 = temp4 - 8
          on temp4 goto Char24Attack, Char25Attack, Char26Attack, Char27Attack, Char28Attack, Char29Attack, Char30Attack, ShamoneAttack
DoneLeftPortAttackDispatch
InputSkipLeftPortAttack
          
          
          return

          rem ==========================================================
          rem RIGHT PORT PLAYER INPUT HANDLER (Joy1 - Players 2 & 4)
          rem ==========================================================
          rem INPUT: temp1 = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
InputHandleRightPortPlayer
          rem Check animation state - block movement during attack
          rem   animations (states 13-15)
          gosub GetPlayerAnimationState
          if temp2 >= 13 then DoneRightPortMovement
          rem Block movement during attack windup/execute/recovery
          
          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Check if player is guarding - guard blocks movement
          let temp6 = PlayerState[temp1] & 2
          if temp6 then DoneRightPortMovement
          rem Guarding - block movement
          
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          rem   for horizontal movement
          let temp5 = PlayerChar[temp1]
          if temp5 = 8 then FrootyDragonetLeftRightMovementRight
          if temp5 = 2 then FrootyDragonetLeftRightMovementRight
          
          rem Standard horizontal movement (no collision check)
          if !joy1left then goto DoneLeftMovementRight
          rem Apply leftward velocity impulse
          let playerVelocityX[temp1] = 255
          rem -1 in 8-bit two's complement: 256 - 1 = 255
          let playerVelocityXL[temp1] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem   (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitFacing)
DoneLeftMovementRight
          
          if !joy1right then goto DoneRightMovementRight
          rem Apply rightward velocity impulse
          let playerVelocityX[temp1] = 1
          let playerVelocityXL[temp1] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem   (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] | 1
DoneRightMovementRight
          goto DoneFlyingLeftRightRight
          
DoneRightPortMovement
          
FrootyDragonetLeftRightMovementRight
          rem Flying characters: check playfield collision before
          rem   horizontal movement
          if joy1left then CheckLeftCollisionRight
          goto CheckRightMovementRight
CheckLeftCollisionRight
          rem Convert player position to playfield coordinates
          let temp2 = PlayerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp2 & $80 then temp2 = 0
          if temp2 > 31 then temp2 = 31
          rem Check column to the left
          if temp2 <= 0 then goto CheckRightMovementRight
          rem Already at left edge
          let temp3 = temp2 - 1
          rem temp3 = column to the left
          rem Check player current row (check both top and bottom of
          rem   sprite)
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
          rem Apply leftward velocity impulse (double-width sprite: 16px
          rem   width)
          let playerVelocityX[temp1] = 255
          rem -1 in 8-bit two’s complement: 256 - 1 = 255
          let playerVelocityXL[temp1] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem   (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitFacing)
CheckRightMovementRight
          if !joy1right then goto DoneFlyingLeftRightRight
          rem Convert player position to playfield coordinates
          let temp2 = PlayerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          rem   result ≥ 128
          rem Check for wraparound: if subtraction wrapped negative,
          if temp2 & $80 then temp2 = 0
          if temp2 > 31 then temp2 = 31
          rem Check column to the right
          if temp2 >= 31 then goto DoneFlyingLeftRightRight
          rem Already at right edge
          let temp3 = temp2 + 1
          rem temp3 = column to the right
          rem Check player current row (check both top and bottom of
          rem   sprite)
          let temp4 = PlayerY[temp1]
          let temp6 = temp4 / pfrowheight
          rem temp6 = top row
          rem Check if blocked in current row
          if pfread(temp3, temp6) then DoneFlyingLeftRightRight
          rem Blocked, cannot move right
          rem Also check bottom row (feet)
          let temp4 = temp4 + 16
          let temp6 = temp4 / pfrowheight
          if temp6 >= pfrows then MoveRightOKRight
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then DoneFlyingLeftRightRight
          rem Blocked at bottom too
MoveRightOKRight
          rem Apply rightward velocity impulse (double-width sprite:
          rem   16px width)
          let playerVelocityX[temp1] = 1
          let playerVelocityXL[temp1] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem   (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] | 1
DoneFlyingLeftRightRight
          

          rem Process UP input for character-specific behaviors (right
          rem   port)
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy1up then goto DoneUpInputHandlingRight
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerChar[temp1] = 15 then let PlayerChar[temp1] = 31 : goto DoneJumpInputRight
          rem Switch Shamone -> MethHound
          if PlayerChar[temp1] = 31 then let PlayerChar[temp1] = 15 : goto DoneJumpInputRight
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          if PlayerChar[temp1] = 0 then BernieFallThroughRight
          
          rem Check Harpy flap (Character 6)
          if PlayerChar[temp1] = 6 then HarpyFlapRight
          
          rem For all other characters, UP is jump
          goto NormalJumpInputRight
          
BernieFallThroughRight
          rem Bernie UP input handled in BernieJump routine (fall
          rem   through 1-row floors)
          gosub BernieJump
          goto DoneJumpInputRight
          
HarpyFlapRight
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          gosub HarpyJump
          goto DoneJumpInputRight
          
NormalJumpInputRight
          rem Process jump input (UP + enhanced buttons)
          let temp3 = 1
          rem Jump pressed flag (UP pressed)
          goto DoneUpInputHandlingRight
          
DoneJumpInputRight
          let temp3 = 0 
          rem No jump (UP used for special ability)
          
DoneUpInputHandlingRight
          rem Process jump input from enhanced buttons (Genesis/Joy2b+
          rem   Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump
          rem   via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced
          rem   buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons
          rem   only
          if PlayerChar[temp1] = 15 then goto ShamoneJumpCheckEnhancedRight
          if PlayerChar[temp1] = 31 then goto ShamoneJumpCheckEnhancedRight
          if PlayerChar[temp1] = 0 then goto ShamoneJumpCheckEnhancedRight
          if PlayerChar[temp1] = 6 then goto ShamoneJumpCheckEnhancedRight
          rem Bernie and Harpy also use enhanced buttons for jump
          
          rem Check Genesis/Joy2b+ Button C/II (INPT2 for Player 2,
          rem   INPT2 for Player 4)
          if temp1 = 1 then CheckPlayer2Buttons
          goto DonePlayer2Buttons
CheckPlayer2Buttons
          if !(ControllerStatus & $04) then CheckPlayer2Joy2bPlus
          if !(INPT2 & $80) then temp3 = 1
          goto DonePlayer2Buttons
CheckPlayer2Joy2bPlus
          if !(ControllerStatus & $08) then DonePlayer2Buttons
          if !(INPT2 & $80) then temp3 = 1
DonePlayer2Buttons
          if temp1 = 3 then CheckPlayer4Buttons
          goto DonePlayer4Buttons
CheckPlayer4Buttons
          if !RightPortGenesis then CheckPlayer4Joy2bPlus
          if !INPT2{7} then temp3 = 1
          goto DonePlayer4Buttons
CheckPlayer4Joy2bPlus
          if !RightPortJoy2bPlus then DonePlayer4Buttons
          if !INPT2{7} then temp3 = 1
DonePlayer4Buttons
EnhancedJumpDone1
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          rem   Shamone)
          if temp3 = 0 then InputSkipRightPortJump
          if (PlayerState[temp1] & 4) then InputSkipRightPortJump
          rem Check animation state - block jump during attack
          rem   animations (states 13-15)
          gosub GetPlayerAnimationState
          if temp2 >= 13 then InputSkipRightPortJump
          rem Block jump during attack windup/execute/recovery
          let temp4 = PlayerChar[temp1]
          rem Dispatch to character-specific jump handler (0-31)
          rem MethHound (31) uses ShamoneJump handler
          if temp4 < 8 then on temp4 goto BernieJump, CurlerJump, DragonetJump, ZoeRyenJump, FatTonyJump, MegaxJump, HarpyJump, KnightGuyJump
          if temp4 < 8 then goto DoneRightPortJumpDispatch
          temp4 = temp4 - 8
          if temp4 < 8 then on temp4 goto FrootyJump, NefertemJump, NinjishGuyJump, PorkChopJump, RadishGoblinJump, RoboTitoJump, UrsuloJump, ShamoneJump
          if temp4 < 8 then goto DoneRightPortJumpDispatch
          temp4 = temp4 - 8
          if temp4 < 8 then on temp4 goto Char16Jump, Char17Jump, Char18Jump, Char19Jump, Char20Jump, Char21Jump, Char22Jump, Char23Jump
          if temp4 < 8 then goto DoneRightPortJumpDispatch
          temp4 = temp4 - 8
          on temp4 goto Char24Jump, Char25Jump, Char26Jump, Char27Jump, Char28Jump, Char29Jump, Char30Jump, ShamoneJump
DoneRightPortJumpDispatch
InputSkipRightPortJump

          

          rem Process down/guard input
          if joy1down then
          let temp4 = PlayerChar[temp1] 
            rem Dispatch to character-specific down handler (0-31)
            rem MethHound (31) uses ShamoneDown handler
            if temp4 < 8 then on temp4 goto BernieDown, CurlerDown, DragonetDown, ZoeRyenDown, FatTonyDown, MegaxDown, HarpyDown, KnightGuyDown
            if temp4 < 8 then goto DoneRightPortDownDispatch
            temp4 = temp4 - 8
            if temp4 < 8 then on temp4 goto FrootyDown, NefertemDown, NinjishGuyDown, PorkChopDown, RadishGoblinDown, RoboTitoDown, UrsuloDown, ShamoneDown
            if temp4 < 8 then goto DoneRightPortDownDispatch
            temp4 = temp4 - 8
            if temp4 < 8 then on temp4 goto Char16Down, Char17Down, Char18Down, Char19Down, Char20Down, Char21Down, Char22Down, Char23Down
            if temp4 < 8 then goto DoneRightPortDownDispatch
            temp4 = temp4 - 8
            on temp4 goto Char24Down, Char25Down, Char26Down, Char27Down, Char28Down, Char29Down, Char30Down, ShamoneDown
DoneRightPortDownDispatch
            goto GuardInputDoneRight
          
          rem DOWN released - check for early guard release
          let temp2 = PlayerState[temp1] & 2
          if temp2 then StopGuardEarlyRight
          rem Not guarding, nothing to do
          goto GuardInputDoneRight
          
StopGuardEarlyRight
          rem Stop guard early and start cooldown
          let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitGuarding)
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
          
GuardInputDoneRight
          
          
          rem Process attack input
          rem Check animation state - block attack input during attack
          rem   animations (states 13-15)
          gosub GetPlayerAnimationState
          if temp2 >= 13 then InputSkipRightPortAttack
          rem Block attack input during attack windup/execute/recovery
          rem Check if player is guarding - guard blocks attacks
          let temp2 = PlayerState[temp1] & 2
          if temp2 then InputSkipRightPortAttack
          rem Guarding - block attack input
          if !joy1fire then InputSkipRightPortAttack
          if (PlayerState[temp1] & PlayerStateBitFacing) then InputSkipRightPortAttack
          let temp4 = PlayerChar[temp1] 
          rem Dispatch to character-specific attack handler (0-31)
          rem MethHound (31) uses ShamoneAttack handler
          if temp4 < 8 then on temp4 goto BernieAttack, CurlerAttack, DragonetAttack, ZoeRyenAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack
          if temp4 < 8 then goto DoneRightPortAttackDispatch
          temp4 = temp4 - 8
          if temp4 < 8 then on temp4 goto FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, ShamoneAttack
          if temp4 < 8 then goto DoneRightPortAttackDispatch
          temp4 = temp4 - 8
          if temp4 < 8 then on temp4 goto Char16Attack, Char17Attack, Char18Attack, Char19Attack, Char20Attack, Char21Attack, Char22Attack, Char23Attack
          if temp4 < 8 then goto DoneRightPortAttackDispatch
          temp4 = temp4 - 8
          on temp4 goto Char24Attack, Char25Attack, Char26Attack, Char27Attack, Char28Attack, Char29Attack, Char30Attack, ShamoneAttack
DoneRightPortAttackDispatch
InputSkipRightPortAttack
          
          
          return

          rem ==========================================================
          rem PAUSE BUTTON HANDLING WITH DEBOUNCING
          rem ==========================================================
          rem Handles SELECT switch and Joy2b+ Button III with proper
          rem   debouncing
          rem Uses PauseButtonPrev for debouncing state
          
HandlePauseInput
          rem Check SELECT switch (always available)
          let temp1 = 0
          if switchselect then temp1 = 1
          
          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for
          rem   Player 2)
          if LeftPortJoy2bPlus then CheckJoy2bButtons
          if RightPortJoy2bPlus then CheckJoy2bButtons
          goto Joy2bPauseDone
CheckJoy2bButtons
          if !INPT1{7} then temp1 = 1 
          rem Player 1 Button III
          if !INPT3{7} then temp1 = 1 
          rem Player 2 Button III
Joy2bPauseDone
          
          rem Debounce: only toggle if button just pressed (was 0, now
          rem   1)
          if temp1 = 0 then DonePauseToggle
          if PauseButtonPrev then DonePauseToggle
          let GameState  = GameState ^ 1
          rem Toggle pause (0<->1)
DonePauseToggle
          
          
          rem Update previous button state for next frame
          let PauseButtonPrev  = temp1
          
          return

          rem ==========================================================
          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC
          rem   ROUTINES
          rem ==========================================================
          rem The original InputHandlePlayer1, HandlePlayer2Input,
          rem   HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into
          rem   HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

