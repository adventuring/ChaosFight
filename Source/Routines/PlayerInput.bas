GetPlayerAnimationState
          rem
          rem ChaosFight - Source/Routines/PlayerInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Player Input Handling
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
          rem PlayerCharacter[0-3] - Character type indices (0-MaxCharacter)
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
          rem
          rem 6=Harpy, 7=KnightGuy, 8=Frooty, 9=Nefertem, 10=NinjishGuy,
          rem 11=PorkChop, 12=RadishGoblin, 13=RoboTito, 14=Ursulo,
          rem   15=Shamone
          rem Animation State Helper
          rem Extracts animation state (bits 4-7) from playerState
          rem
          rem INPUT: temp1 = player index (0-3)
          rem
          rem OUTPUT: temp2 = animation state (0-15)
          rem Uses: ActionAttackWindup=13, ActionAttackExecute=14,
          rem   ActionAttackRecovery=15
          rem Extracts animation state (bits 4-7) from playerState
          rem
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem
          rem Output: temp2 = animation state (0-15)
          rem
          rem Mutates: temp2 (set to animation state)
          rem
          rem Called Routines: None
          dim GPAS_playerIndex = temp1 : rem Constraints: None
          dim GPAS_animationState = temp2
          let GPAS_animationState = playerState[GPAS_playerIndex] & 240
          let GPAS_animationState = GPAS_animationState / 16 : rem Mask bits 4-7 (value 240 = %11110000)
          rem Shift right by 4 (divide by 16) to get animation state
          rem   (0-15)
          return

ShouldPreserveFacing
          rem
          rem Check If Facing Should Be Preserved
          rem Returns 1 if facing should be preserved (during
          rem   hurt/recovery states),
          rem 0 if facing can be updated normally.
          rem Preserves facing during: recovery/hitstun (bit 3) OR hurt
          rem   animation states (5-9)
          rem
          rem INPUT: temp1 = player index (0-3)
          rem
          rem OUTPUT: temp3 = 1 if facing should be preserved, 0 if can
          rem   update
          rem
          rem EFFECTS: Uses temp2 for animation state check
          rem Returns 1 if facing should be preserved (during
          rem hurt/recovery states), 0 if facing can be updated normally
          rem
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem
          rem Output: temp3 = 1 if facing should be preserved, 0 if can
          rem update
          rem
          rem Mutates: temp2, temp3 (used for calculations)
          rem
          rem Called Routines: GetPlayerAnimationState - accesses temp1,
          rem temp2, playerState[]
          rem
          rem Constraints: Must be colocated with SPF_PreserveYes,
          rem SPF_PreserveNo (called via goto)
          dim SPF_playerIndex = temp1
          dim SPF_animationState = temp2
          dim SPF_preserveFlag = temp3
          if (playerState[SPF_playerIndex] & 8) then SPF_PreserveYes : rem Check recovery/hitstun flag (bit 3)
          rem Bit 3 set = in recovery, preserve facing
          
          rem Check animation state for hurt states (5-9)
          rem ActionHit=5, ActionFallBack=6, ActionFallDown=7,
          gosub GetPlayerAnimationState : rem ActionFallen=8, ActionRecovering=9
          let SPF_animationState = temp2
          if SPF_animationState < 5 then SPF_PreserveNo
          if SPF_animationState > 9 then SPF_PreserveNo : rem Animation state < 5, allow facing update
          rem Animation state > 9, allow facing update
          
SPF_PreserveYes
          rem In hurt/recovery state, preserve facing
          rem
          rem Input: None (called from ShouldPreserveFacing)
          rem
          rem Output: temp3 set to 1
          rem
          rem Mutates: temp3 (set to 1)
          rem
          rem Called Routines: None
          let SPF_preserveFlag = 1 : rem Constraints: Must be colocated with ShouldPreserveFacing, SPF_PreserveNo
          let temp3 = SPF_preserveFlag
          return
          
SPF_PreserveNo
          rem Not in hurt/recovery state, allow facing update
          rem
          rem Input: None (called from ShouldPreserveFacing)
          rem
          rem Output: temp3 set to 0
          rem
          rem Mutates: temp3 (set to 0)
          rem
          rem Called Routines: None
          let SPF_preserveFlag = 0 : rem Constraints: Must be colocated with ShouldPreserveFacing, SPF_PreserveYes
          let temp3 = SPF_preserveFlag
          return

InputHandleAllPlayers
          rem Main input handler for all players
          rem Main input handler for all players with Quadtari
          rem multiplexing
          rem
          rem Input: qtcontroller (global) = multiplexing state
          rem (0=P1/P2, 1=P3/P4)
          rem        ControllerStatus (global) = controller detection
          rem        state
          rem        selectedCharacter3_R, selectedCharacter4_R (global SCRAM) =
          rem        character selections
          rem        PlayerState[] (global array) = player state flags
          rem
          rem Output: Input processed for active players, qtcontroller
          rem toggled
          rem
          rem Mutates: temp1, temp2 (used for calculations),
          rem currentPlayer (set to 0-3),
          rem         qtcontroller (toggled between 0 and 1)
          rem
          rem Called Routines: IsPlayerAlive - checks if player is
          rem alive,
          rem   InputHandleLeftPortPlayer, InputHandleRightPortPlayer -
          rem   handle input for left/right port players
          rem
          rem Constraints: Must be colocated with InputSkipPlayer0Input,
          rem InputSkipPlayer1Input,
          rem              InputHandlePlayer1,
          rem              InputHandleQuadtariPlayers,
          rem              InputSkipPlayer3Input,
          dim IHAP_isAlive = temp2 : rem              InputSkipPlayer4Input (all called via goto or gosub)
          if qtcontroller then goto InputHandleQuadtariPlayers
          
          rem Even frame: Handle Players 1 & 2 - only if alive  
          let currentPlayer = 0 : gosub IsPlayerAlive
          let IHAP_isAlive = temp2
          if IHAP_isAlive = 0 then InputSkipPlayer0Input
          if (PlayerState[0] & 8) then InputSkipPlayer0Input
          let temp1 = 0 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer0Input
          rem Skip Player 0 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with InputHandleAllPlayers
          
          let currentPlayer = 1 : gosub IsPlayerAlive
          let IHAP_isAlive = temp2
          if IHAP_isAlive = 0 then InputSkipPlayer1Input
          if (PlayerState[1] & 8) then InputSkipPlayer1Input
          goto InputHandlePlayer1
          
          goto InputSkipPlayer1Input
          
InputHandlePlayer1
          rem Handle Player 1 input (right port)
          rem
          rem Input: temp1 (set to 1), PlayerState[] (global array)
          rem
          rem Output: Player 1 input processed
          rem
          rem Mutates: temp1 (set to 1), player state (via
          rem InputHandleRightPortPlayer)
          rem
          rem Called Routines: InputHandleRightPortPlayer - handles
          rem right port player input
          let temp1 = 1 : gosub InputHandleRightPortPlayer : rem Constraints: Must be colocated with InputHandleAllPlayers, InputSkipPlayer1Input
InputSkipPlayer1Input
          rem Player 1 uses Joy1
          return
InputHandleQuadtariPlayers
          rem Skip Player 1 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with InputHandleAllPlayers
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and
          rem alive)
          rem
          rem Input: ControllerStatus (global), selectedCharacter3_R,
          rem selectedCharacter4_R (global SCRAM),
          rem        PlayerState[] (global array)
          rem
          rem Output: Input processed for Players 3 & 4 if conditions
          rem met, qtcontroller reset to 0
          rem
          rem Mutates: temp1, temp2 (used for calculations),
          rem currentPlayer (set to 2-3),
          rem         qtcontroller (reset to 0)
          rem
          rem Called Routines: IsPlayerAlive - checks if player is
          rem alive,
          rem   InputHandleLeftPortPlayer, InputHandleRightPortPlayer -
          rem   handle input for left/right port players
          rem
          rem Constraints: Must be colocated with InputHandleAllPlayers,
          rem InputSkipPlayer3Input,
          dim IHQP_isAlive = temp2 : rem              InputSkipPlayer4Input
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and
          if !(ControllerStatus & SetQuadtariDetected) then InputSkipPlayer3Input : rem   alive)
          if selectedCharacter3_R = 0 then InputSkipPlayer3Input
          let currentPlayer = 2 : gosub IsPlayerAlive
          let IHQP_isAlive = temp2
          if IHQP_isAlive = 0 then InputSkipPlayer3Input
          if (PlayerState[2] & 8) then InputSkipPlayer3Input
          let temp1 = 2 : gosub InputHandleLeftPortPlayer
          
InputSkipPlayer3Input
          rem Skip Player 3 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          if !(ControllerStatus & SetQuadtariDetected) then InputSkipPlayer4Input : rem Constraints: Must be colocated with InputHandleQuadtariPlayers
          if selectedCharacter4_R = 0 then InputSkipPlayer4Input
          let currentPlayer = 3 : gosub IsPlayerAlive
          let IHQP_isAlive = temp2
          if IHQP_isAlive = 0 then InputSkipPlayer4Input
          if (PlayerState[3] & 8) then InputSkipPlayer4Input
          let temp1 = 3 : gosub InputHandleRightPortPlayer
          
InputSkipPlayer4Input
          rem Skip Player 4 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem InputHandleQuadtariPlayers
          
          
          qtcontroller = 0 
          rem Switch back to even frame
          return

DispatchCharacterJump
          rem
          rem Shared Character Dispatch Subroutines
          rem These subroutines replace duplicate dispatch blocks
          rem throughout
          rem   the input handlers
          rem
          rem INPUT: temp4 = character type (0-31)
          rem
          rem OUTPUT: Dispatches to appropriate character-specific
          rem routine
          
          dim DCJ_characterType = temp4
          rem Dispatch to character-specific jump handler (0-31)
          if DCJ_characterType < 8 then on DCJ_characterType goto BernieJump CurlerJump DragonetJump ZoeRyenJump FatTonyJump MegaxJump HarpyJump KnightGuyJump : rem MethHound (31) uses ShamoneJump handler
          if DCJ_characterType < 8 then return
          let DCJ_characterType = DCJ_characterType - 8
          if DCJ_characterType < 8 then on DCJ_characterType goto FrootyJump NefertemJump NinjishGuyJump PorkChopJump RadishGoblinJump RoboTitoJump UrsuloJump ShamoneJump
          if DCJ_characterType < 8 then return
          let DCJ_characterType = DCJ_characterType - 8
          if DCJ_characterType < 8 then on DCJ_characterType goto Character16Jump Character17Jump Character18Jump Character19Jump Character20Jump Character21Jump Character22Jump Character23Jump
          if DCJ_characterType < 8 then return
          let DCJ_characterType = DCJ_characterType - 8
          if DCJ_characterType = 0 then goto Character24Jump
          if DCJ_characterType = 1 then goto Character25Jump
          if DCJ_characterType = 2 then goto Character26Jump
          if DCJ_characterType = 3 then goto Character27Jump
          if DCJ_characterType = 4 then goto Character28Jump
          if DCJ_characterType = 5 then goto Character29Jump
          if DCJ_characterType = 6 then goto Character30Jump
          if DCJ_characterType = 7 then goto ShamoneJump
          return
          
DispatchCharacterDown
          dim DCD_characterType = temp4
          rem Dispatch to character-specific down handler (0-31)
          if DCD_characterType < 8 then on DCD_characterType goto BernieDown CurlerDown DragonetDown ZoeRyenDown FatTonyDown MegaxDown HarpyDown KnightGuyDown : rem MethHound (31) uses ShamoneDown handler
          if DCD_characterType < 8 then return
          let DCD_characterType = DCD_characterType - 8
          if DCD_characterType < 8 then on DCD_characterType goto FrootyDown NefertemDown NinjishGuyDown PorkChopDown RadishGoblinDown RoboTitoDown UrsuloDown ShamoneDown
          if DCD_characterType < 8 then return
          let DCD_characterType = DCD_characterType - 8
          if DCD_characterType < 8 then on DCD_characterType goto Character16Down Character17Down Character18Down Character19Down Character20Down Character21Down Character22Down Character23Down
          if DCD_characterType < 8 then return
          let DCD_characterType = DCD_characterType - 8
          if DCD_characterType = 0 then goto Character24Down
          if DCD_characterType = 1 then goto Character25Down
          if DCD_characterType = 2 then goto Character26Down
          if DCD_characterType = 3 then goto Character27Down
          if DCD_characterType = 4 then goto Character28Down
          if DCD_characterType = 5 then goto Character29Down
          if DCD_characterType = 6 then goto Character30Down
          if DCD_characterType = 7 then goto ShamoneDown
          return
          
DispatchCharacterAttack
          dim DCA_characterType = temp4
          rem Dispatch to character-specific attack handler (0-31)
          rem MethHound (31) uses ShamoneAttack handler
          if DCA_characterType < 8 then on DCA_characterType goto gotoBernieAttack gotoCurlerAttack gotoDragonetAttack gotoZoeRyenAttack gotoFatTonyAttack gotoMegaxAttack gotoHarpyAttack gotoKnightGuyAttack : rem Use trampoline labels for cross-bank references (Bank 11)
          if DCA_characterType < 8 then return
          let DCA_characterType = DCA_characterType - 8
          if DCA_characterType < 8 then on DCA_characterType goto gotoFrootyAttack gotoNefertemAttack gotoNinjishGuyAttack gotoPorkChopAttack gotoRadishGoblinAttack gotoRoboTitoAttack gotoUrsuloAttack gotoShamoneAttack
          if DCA_characterType < 8 then return
          let DCA_characterType = DCA_characterType - 8
          if DCA_characterType < 8 then on DCA_characterType goto gotoCharacter16Attack gotoCharacter17Attack gotoCharacter18Attack gotoCharacter19Attack gotoCharacter20Attack gotoCharacter21Attack gotoCharacter22Attack gotoCharacter23Attack
          if DCA_characterType < 8 then return
          let DCA_characterType = DCA_characterType - 8
          if DCA_characterType = 0 then goto gotoCharacter24Attack
          if DCA_characterType = 1 then goto gotoCharacter25Attack
          if DCA_characterType = 2 then goto gotoCharacter26Attack
          if DCA_characterType = 3 then goto gotoCharacter27Attack
          if DCA_characterType = 4 then goto gotoCharacter28Attack
          if DCA_characterType = 5 then goto gotoCharacter29Attack
          if DCA_characterType = 6 then goto gotoCharacter30Attack
          if DCA_characterType = 7 then goto gotoShamoneAttack
          return
          
gotoBernieAttack
          rem
          rem ATTACK TRAMPOLINE FUNCTIONS (bank 11 →
          rem Characterattacks.bas)
          rem Local trampoline labels that jump to Bank 11 attack
          rem handlers
          rem This allows on/goto to work with cross-bank references
          
          goto BernieAttack bank11
          
gotoCurlerAttack
          goto CurlerAttack bank11
          
gotoDragonetAttack
          goto DragonetAttack bank11
          
gotoZoeRyenAttack
          goto ZoeRyenAttack bank11
          
gotoFatTonyAttack
          goto FatTonyAttack bank11
          
gotoMegaxAttack
          goto MegaxAttack bank11
          
gotoHarpyAttack
          goto HarpyAttack bank11
          
gotoKnightGuyAttack
          goto KnightGuyAttack bank11
          
gotoFrootyAttack
          goto FrootyAttack bank11
          
gotoNefertemAttack
          goto NefertemAttack bank11
          
gotoNinjishGuyAttack
          goto NinjishGuyAttack bank11
          
gotoPorkChopAttack
          goto PorkChopAttack bank11
          
gotoRadishGoblinAttack
          goto RadishGoblinAttack bank11
          
gotoRoboTitoAttack
          goto RoboTitoAttack bank11
          
gotoUrsuloAttack
          goto UrsuloAttack bank11
          
gotoShamoneAttack
          goto ShamoneAttack bank11
          
gotoCharacter16Attack
          rem Character 16-23 attack handlers (future characters)
          goto Character16Attack bank11
          
gotoCharacter17Attack
          goto Character17Attack bank11
          
gotoCharacter18Attack
          goto Character18Attack bank11
          
gotoCharacter19Attack
          goto Character19Attack bank11
          
gotoCharacter20Attack
          goto Character20Attack bank11
          
gotoCharacter21Attack
          goto Character21Attack bank11
          
gotoCharacter22Attack
          goto Character22Attack bank11
          
gotoCharacter23Attack
          goto Character23Attack bank11
          
gotoCharacter24Attack
          rem Character 24-30 attack handlers (future characters)
          goto Character24Attack bank11
          
gotoCharacter25Attack
          goto Character25Attack bank11
          
gotoCharacter26Attack
          goto Character26Attack bank11
          
gotoCharacter27Attack
          goto Character27Attack bank11
          
gotoCharacter28Attack
          goto Character28Attack bank11
          
gotoCharacter29Attack
          goto Character29Attack bank11
          
gotoCharacter30Attack
          goto Character30Attack bank11

CheckEnhancedJumpButton
          rem
          rem Shared Enhanced Button Check
          rem Checks Genesis/Joy2b+ Button C/II for jump input
          rem
          rem INPUT: temp1 = player index (0-3)
          rem
          rem OUTPUT: temp3 = 1 if jump button pressed, 0 otherwise
          rem Uses: INPT0 for players 0,2; INPT2 for players 1,3
          dim CEJB_playerIndex = temp1
          dim CEJB_jumpPressed = temp3
          let CEJB_jumpPressed = 0 : rem Initialize to no jump
          if CEJB_playerIndex = 0 then CEJB_CheckPlayer0 : rem Player 0 or 2: Check INPT0
          if CEJB_playerIndex = 2 then CEJB_CheckPlayer3
          if CEJB_playerIndex = 1 then CEJB_CheckPlayer2 : rem Player 1 or 3: Check INPT2
          if CEJB_playerIndex = 3 then CEJB_CheckPlayer4
          goto CEJB_Done
CEJB_CheckPlayer0
          if !ControllerStatus{0} then CEJB_CheckPlayer0Joy2bPlus : rem Player 0: Check Genesis controller
          if !INPT0{7} then let CEJB_jumpPressed = 1
          goto CEJB_Done
CEJB_CheckPlayer0Joy2bPlus
          if !ControllerStatus{1} then CEJB_Done : rem Player 0: Check Joy2b+ controller
          if !INPT0{7} then let CEJB_jumpPressed = 1
          goto CEJB_Done
CEJB_CheckPlayer3
          if !ControllerStatus{0} then CEJB_CheckPlayer3Joy2bPlus : rem Player 3: Check Genesis controller
          if !INPT0{7} then let CEJB_jumpPressed = 1
          goto CEJB_Done
CEJB_CheckPlayer3Joy2bPlus
          if !ControllerStatus{1} then CEJB_Done : rem Player 3: Check Joy2b+ controller
          if !INPT0{7} then let CEJB_jumpPressed = 1
          goto CEJB_Done
CEJB_CheckPlayer2
          if !(ControllerStatus & $04) then CEJB_CheckPlayer2Joy2bPlus : rem Player 2: Check Genesis controller
          if !(INPT2 & $80) then let CEJB_jumpPressed = 1
          goto CEJB_Done
CEJB_CheckPlayer2Joy2bPlus
          if !(ControllerStatus & $08) then CEJB_Done : rem Player 2: Check Joy2b+ controller
          if !(INPT2 & $80) then let CEJB_jumpPressed = 1
          goto CEJB_Done
CEJB_CheckPlayer4
          if !RightPortGenesis then CEJB_CheckPlayer4Joy2bPlus : rem Player 4: Check Genesis controller
          if !INPT2{7} then let CEJB_jumpPressed = 1
          goto CEJB_Done
CEJB_CheckPlayer4Joy2bPlus
          if !RightPortJoy2bPlus then CEJB_Done : rem Player 4: Check Joy2b+ controller
          if !INPT2{7} then let CEJB_jumpPressed = 1
CEJB_Done
          let temp3 = CEJB_jumpPressed
          return

HandleGuardInput
          rem
          rem Shared Guard Input Handling
          rem Handles down/guard input for both ports
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0down for players 0,2; joy1down for players 1,3
          dim HGI_playerIndex = temp1
          dim HGI_characterType = temp4
          dim HGI_guardState = temp2
          dim HGI_joyDown = temp5
          rem Determine which joy port to use based on player index
          if HGI_playerIndex = 0 then HGI_CheckJoy0 : rem Players 0,2 use joy0; Players 1,3 use joy1
          if HGI_playerIndex = 2 then HGI_CheckJoy0
          if !joy1down then goto HGI_CheckGuardRelease : rem Players 1,3 use joy1
          goto HGI_HandleDownPressed
HGI_CheckJoy0
          if !joy0down then goto HGI_CheckGuardRelease : rem Players 0,2 use joy0
HGI_HandleDownPressed
          let HGI_characterType = PlayerCharacter[HGI_playerIndex] : rem DOWN pressed - dispatch to character-specific down handler
          let temp4 = HGI_characterType
          gosub DispatchCharacterDown
          return
HGI_CheckGuardRelease
          let HGI_guardState = PlayerState[HGI_playerIndex] & 2 : rem DOWN released - check for early guard release
          if !HGI_guardState then return
          rem Not guarding, nothing to do
          let PlayerState[HGI_playerIndex] = PlayerState[HGI_playerIndex] & (255 - PlayerStateBitGuarding) : rem Stop guard early and start cooldown
          let playerTimers_W[HGI_playerIndex] = GuardTimerMaxFrames
          rem Start cooldown timer
          return

ConvertPlayerXToPlayfieldColumn
          rem
          rem Playfield Coordinate Conversion
          rem Converts player X position to playfield column index
          rem
          rem INPUT: temp1 = player index (0-3)
          rem
          rem OUTPUT: temp2 = playfield column (0-31)
          dim CPXTPC_playerIndex = temp1 : rem MUTATES: temp2 (return value)
          dim CPXTPC_pfColumn = temp2
          let CPXTPC_pfColumn = PlayerX[CPXTPC_playerIndex] : rem Convert player position to playfield coordinates
          let CPXTPC_pfColumn = CPXTPC_pfColumn - ScreenInsetX
          let CPXTPC_pfColumn = CPXTPC_pfColumn / 4
          if CPXTPC_pfColumn > 31 then let CPXTPC_pfColumn = 31 : rem pfColumn = playfield column
          if CPXTPC_pfColumn & $80 then let CPXTPC_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          let temp2 = CPXTPC_pfColumn
          return

HandleFlyingCharacterMovement
          rem
          rem Shared Flying Character Movement
          rem Handles horizontal movement with collision for flying
          rem   characters (Frooty, Dragon of Storms)
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0left/joy0right for players 0,2;
          rem joy1left/joy1right
          dim HFCM_playerIndex = temp1 : rem for players 1,3
          dim HFCM_pfColumn = temp2
          dim HFCM_checkColumn = temp3
          dim HFCM_playerY = temp4
          dim HFCM_pfRow = temp6
          rem Determine which joy port to use based on player index
          if HFCM_playerIndex = 0 then HFCM_UseJoy0 : rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if HFCM_playerIndex = 2 then HFCM_UseJoy0
          if joy1left then HFCM_CheckLeftCollision : rem Players 1,3 use joy1
          goto HFCM_CheckRightMovement
HFCM_UseJoy0
          if joy0left then HFCM_CheckLeftCollision : rem Players 0,2 use joy0
          goto HFCM_CheckRightMovement
HFCM_CheckLeftCollision
          gosub ConvertPlayerXToPlayfieldColumn : rem Convert player position to playfield coordinates
          let HFCM_pfColumn = temp2
          if HFCM_pfColumn <= 0 then goto HFCM_CheckRightMovement : rem Check column to the left
          let HFCM_checkColumn = HFCM_pfColumn - 1 : rem Already at left edge
          rem checkColumn = column to the left
          let HFCM_playerY = PlayerY[HFCM_playerIndex] : rem Check player current row (check both top and bottom of sprite)
          let temp2 = HFCM_playerY
          gosub DivideByPfrowheight
          let HFCM_pfRow = temp2
          rem pfRow = top row
          if pfread(HFCM_checkColumn, HFCM_pfRow) then goto HFCM_CheckRightMovement : rem Check if blocked in current row
          rem Blocked, cannot move left
          let HFCM_playerY = HFCM_playerY + 16 : rem Also check bottom row (feet)
          let temp2 = HFCM_playerY
          gosub DivideByPfrowheight
          let HFCM_pfRow = temp2
          if HFCM_pfRow >= pfrows then goto HFCM_MoveLeftOK
          if pfread(HFCM_checkColumn, HFCM_pfRow) then goto HFCM_CheckRightMovement : rem Do not check if beyond screen
HFCM_MoveLeftOK
          rem Blocked at bottom too
          let playerVelocityX[HFCM_playerIndex] = 255 : rem Apply leftward velocity impulse (double-width sprite: 16px width)
          rem -1 in 8-bit twos complement: 256 - 1 = 255
          let playerVelocityXL[HFCM_playerIndex] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem (knockback, hitstun)
          let temp1 = HFCM_playerIndex
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[HFCM_playerIndex] = PlayerState[HFCM_playerIndex] & (255 - PlayerStateBitFacing)
HFCM_CheckRightMovement
          if HFCM_playerIndex = 0 then HFCM_CheckRightJoy0 : rem Determine which joy port to use for right movement
          if HFCM_playerIndex = 2 then HFCM_CheckRightJoy0
          if !joy1right then goto HFCM_DoneFlyingMovement : rem Players 1,3 use joy1
          goto HFCM_DoRightMovement
HFCM_CheckRightJoy0
          if !joy0right then goto HFCM_DoneFlyingMovement : rem Players 0,2 use joy0
HFCM_DoRightMovement
          gosub ConvertPlayerXToPlayfieldColumn : rem Convert player position to playfield coordinates
          let HFCM_pfColumn = temp2
          if HFCM_pfColumn >= 31 then goto HFCM_DoneFlyingMovement : rem Check column to the right
          let HFCM_checkColumn = HFCM_pfColumn + 1 : rem Already at right edge
          rem checkColumn = column to the right
          let HFCM_playerY = PlayerY[HFCM_playerIndex] : rem Check player current row (check both top and bottom of sprite)
          let temp2 = HFCM_playerY
          gosub DivideByPfrowheight
          let HFCM_pfRow = temp2
          rem pfRow = top row
          if pfread(HFCM_checkColumn, HFCM_pfRow) then goto HFCM_DoneFlyingMovement : rem Check if blocked in current row
          rem Blocked, cannot move right
          let HFCM_playerY = HFCM_playerY + 16 : rem Also check bottom row (feet)
          let temp2 = HFCM_playerY
          gosub DivideByPfrowheight
          let HFCM_pfRow = temp2
          if HFCM_pfRow >= pfrows then goto HFCM_MoveRightOK
          if pfread(HFCM_checkColumn, HFCM_pfRow) then goto HFCM_DoneFlyingMovement : rem Do not check if beyond screen
HFCM_MoveRightOK
          rem Blocked at bottom too
          let playerVelocityX[HFCM_playerIndex] = 1 : rem Apply rightward velocity impulse
          let playerVelocityXL[HFCM_playerIndex] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem (knockback, hitstun)
          let temp1 = HFCM_playerIndex
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[HFCM_playerIndex] = PlayerState[HFCM_playerIndex] | 1
HFCM_DoneFlyingMovement
          return

InputHandleLeftPortPlayer
          rem
          rem LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)
          rem
          rem INPUT: temp1 = player index (0 or 2)
          dim IHLP_playerIndex = temp1 : rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
          dim IHLP_animationState = temp2
          dim IHLP_characterType = temp5
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationState : rem   block movement during attack animations (states 13-15)
          let IHLP_animationState = temp2
          if IHLP_animationState >= 13 then DoneLeftPortMovement
          rem Block movement during attack windup/execute/recovery
          
          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let IHLP_characterType = PlayerCharacter[IHLP_playerIndex] : rem   for horizontal movement
          if IHLP_characterType = 8 then IHLP_FlyingMovement
          if IHLP_characterType = 2 then IHLP_FlyingMovement
          
          rem Standard horizontal movement (modifies velocity, not
          rem position)
          rem Left movement: set negative velocity (255 in 8-bit twos
          rem complement = -1)
          if !joy0left then goto IHLP_DoneLeftMovement
          let playerVelocityX[IHLP_playerIndex] = 255
          let playerVelocityXL[IHLP_playerIndex] = 0
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[IHLP_playerIndex] = PlayerState[IHLP_playerIndex] & (255 - PlayerStateBitFacing)
IHLP_DoneLeftMovement
          if !joy0right then goto IHLP_DoneRightMovement : rem Right movement: set positive velocity
          let playerVelocityX[IHLP_playerIndex] = 1
          let playerVelocityXL[IHLP_playerIndex] = 0
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[IHLP_playerIndex] = PlayerState[IHLP_playerIndex] | 1
IHLP_DoneRightMovement
          goto IHLP_DoneFlyingLeftRight
DoneLeftPortMovement
IHLP_FlyingMovement
          gosub HandleFlyingCharacterMovement
IHLP_DoneFlyingLeftRight

          dim SUIH_jumpPressed = temp3
          dim EJ_jumpPressed = temp3
          dim EJ_characterType = temp4
          rem Process UP input for character-specific behaviors
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          if !joy0up then goto DoneUpInputHandling : rem - Harpy: flap to fly (Character 6)
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerCharacter[IHLP_playerIndex] = 15 then let PlayerCharacter[IHLP_playerIndex] = 31 : goto DoneJumpInput
          if PlayerCharacter[IHLP_playerIndex] = 31 then let PlayerCharacter[IHLP_playerIndex] = 15 : goto DoneJumpInput : rem Switch Shamone -> MethHound
          rem Switch MethHound -> Shamone
          
          if PlayerCharacter[IHLP_playerIndex] = 0 then BernieFallThrough : rem Check Bernie fall-through (Character 0)
          
          if PlayerCharacter[IHLP_playerIndex] = 6 then HarpyFlap : rem Check Harpy flap (Character 6)
          
          goto NormalJumpInput : rem For all other characters, UP is jump
          
BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump : rem   through 1-row floors)
          goto DoneJumpInput
          
HarpyFlap
          gosub HarpyJump : rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInput
          
NormalJumpInput
          let SUIH_jumpPressed = 1 : rem Process jump input (UP + enhanced buttons)
          goto DoneUpInputHandling : rem Jump pressed flag (UP pressed)
          
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
          if PlayerCharacter[IHLP_playerIndex] = 15 then goto ShamoneJumpCheckEnhanced : rem   only
          if PlayerCharacter[IHLP_playerIndex] = 31 then goto ShamoneJumpCheckEnhanced
          if PlayerCharacter[IHLP_playerIndex] = 0 then goto ShamoneJumpCheckEnhanced
          if PlayerCharacter[IHLP_playerIndex] = 6 then goto ShamoneJumpCheckEnhanced
          rem Bernie and Harpy also use enhanced buttons for jump
          
          gosub CheckEnhancedJumpButton : rem Check Genesis/Joy2b+ Button C/II
          let SUIH_jumpPressed = temp3
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          let EJ_jumpPressed = SUIH_jumpPressed : rem   Shamone)
          if EJ_jumpPressed = 0 then InputSkipLeftPortJump
          if (PlayerState[IHLP_playerIndex] & 4) then InputSkipLeftPortJump
          rem Use cached animation state - block jump during attack
          if IHLP_animationState >= 13 then InputSkipLeftPortJump : rem   animations (states 13-15)
          let EJ_characterType = PlayerCharacter[IHLP_playerIndex] : rem Block jump during attack windup/execute/recovery
          let temp4 = EJ_characterType
          gosub DispatchCharacterJump
InputSkipLeftPortJump

          

          gosub HandleGuardInput : rem Process down/guard input
          
          
          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          rem Use cached animation state - block attack input during
          rem attack
          if IHLP_animationState >= 13 then InputSkipLeftPortAttack : rem   animations (states 13-15)
          rem Block attack input during attack windup/execute/recovery
          let temp2 = PlayerState[temp1] & 2 : rem Check if player is guarding - guard blocks attacks
          if temp2 then InputSkipLeftPortAttack
          if !joy0fire then InputSkipLeftPortAttack : rem Guarding - block attack input
          if (PlayerState[temp1] & PlayerStateBitFacing) then InputSkipLeftPortAttack
          let temp4 = PlayerCharacter[temp1]
          gosub DispatchCharacterAttack
InputSkipLeftPortAttack
          
          
          return

InputHandleRightPortPlayer
          rem
          rem RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
          rem
          rem INPUT: temp1 = player index (1 or 3)
          dim IHRP_playerIndex = temp1 : rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
          dim IHRP_animationState = temp2
          dim IHRP_characterType = temp5
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationState : rem   block movement during attack animations (states 13-15)
          let IHRP_animationState = temp2
          if IHRP_animationState >= 13 then DoneRightPortMovement
          rem Block movement during attack windup/execute/recovery
          
          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          let temp6 = PlayerState[temp1] & 2 : rem Check if player is guarding - guard blocks movement
          if temp6 then DoneRightPortMovement
          rem Guarding - block movement
          
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = PlayerCharacter[temp1] : rem   for horizontal movement
          if temp5 = 8 then IHRP_FlyingMovement
          if temp5 = 2 then IHRP_FlyingMovement
          
          if !joy1left then goto IHRP_DoneLeftMovement : rem Standard horizontal movement (no collision check)
          let playerVelocityX[temp1] = 255 : rem Apply leftward velocity impulse
          rem -1 in 8-bit twos complement: 256 - 1 = 255
          let playerVelocityXL[temp1] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitFacing)
IHRP_DoneLeftMovement
          
          if !joy1right then goto IHRP_DoneRightMovement
          let playerVelocityX[temp1] = 1 : rem Apply rightward velocity impulse
          let playerVelocityXL[temp1] = 0
          rem NOTE: Preserve facing during hurt/recovery states
          rem (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] | 1
IHRP_DoneRightMovement
          goto IHRP_DoneFlyingLeftRight
          
DoneRightPortMovement
IHRP_FlyingMovement
          gosub HandleFlyingCharacterMovement
IHRP_DoneFlyingLeftRight
          

          rem Process UP input for character-specific behaviors (right
          rem   port)
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          if !joy1up then goto DoneUpInputHandlingRight : rem - Harpy: flap to fly (Character 6)
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerCharacter[temp1] = 15 then let PlayerCharacter[temp1] = 31 : goto DoneJumpInputRight
          if PlayerCharacter[temp1] = 31 then let PlayerCharacter[temp1] = 15 : goto DoneJumpInputRight : rem Switch Shamone -> MethHound
          rem Switch MethHound -> Shamone
          
          if PlayerCharacter[temp1] = 0 then BernieFallThroughRight : rem Check Bernie fall-through (Character 0)
          
          if PlayerCharacter[temp1] = 6 then HarpyFlapRight : rem Check Harpy flap (Character 6)
          
          goto NormalJumpInputRight : rem For all other characters, UP is jump
          
BernieFallThroughRight
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump : rem   through 1-row floors)
          goto DoneJumpInputRight
          
HarpyFlapRight
          gosub HarpyJump : rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInputRight
          
NormalJumpInputRight
          let temp3 = 1 : rem Process jump input (UP + enhanced buttons)
          goto DoneUpInputHandlingRight : rem Jump pressed flag (UP pressed)
          
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
          if PlayerCharacter[temp1] = 15 then goto ShamoneJumpCheckEnhancedRight : rem   only
          if PlayerCharacter[temp1] = 31 then goto ShamoneJumpCheckEnhancedRight
          if PlayerCharacter[temp1] = 0 then goto ShamoneJumpCheckEnhancedRight
          if PlayerCharacter[temp1] = 6 then goto ShamoneJumpCheckEnhancedRight
          rem Bernie and Harpy also use enhanced buttons for jump
          
          gosub CheckEnhancedJumpButton : rem Check Genesis/Joy2b+ Button C/II
          rem temp3 already set by CheckEnhancedJumpButton
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          if temp3 = 0 then InputSkipRightPortJump : rem   Shamone)
          if (PlayerState[temp1] & 4) then InputSkipRightPortJump
          rem Use cached animation state - block jump during attack
          if IHRP_animationState >= 13 then InputSkipRightPortJump : rem   animations (states 13-15)
          let temp4 = PlayerCharacter[temp1] : rem Block jump during attack windup/execute/recovery
          gosub DispatchCharacterJump
InputSkipRightPortJump

          

          gosub HandleGuardInput : rem Process down/guard input
          
          
          rem Process attack input
          rem Use cached animation state - block attack input during
          rem attack
          if IHRP_animationState >= 13 then InputSkipRightPortAttack : rem   animations (states 13-15)
          rem Block attack input during attack windup/execute/recovery
          let temp2 = PlayerState[temp1] & 2 : rem Check if player is guarding - guard blocks attacks
          if temp2 then InputSkipRightPortAttack
          if !joy1fire then InputSkipRightPortAttack : rem Guarding - block attack input
          if (PlayerState[temp1] & PlayerStateBitFacing) then InputSkipRightPortAttack
          let temp4 = PlayerCharacter[temp1]
          gosub DispatchCharacterAttack
InputSkipRightPortAttack
          
          
          return

          rem
          rem Pause Button Handling With Debouncing
          rem Handles SELECT switch and Joy2b+ Button III with proper
          rem   debouncing
          rem Uses PauseButtonPrev for debouncing state
          
HandlePauseInput
          let temp1 = 0 : rem Check SELECT switch (always available)
          if switchselect then temp1 = 1
          
          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for
          if LeftPortJoy2bPlus then CheckJoy2bButtons : rem   Player 2)
          if RightPortJoy2bPlus then CheckJoy2bButtons
          goto Joy2bPauseDone
CheckJoy2bButtons
          if !INPT1{7} then temp1 = 1 
          if !INPT3{7} then temp1 = 1 : rem Player 1 Button III
Joy2bPauseDone
          rem Player 2 Button III
          
          rem Debounce: only toggle if button just pressed (was 0, now
          if temp1 = 0 then DonePauseToggle : rem   1)
          if PauseButtonPrev then DonePauseToggle
          let GameState  = GameState ^ 1
DonePauseToggle
          rem Toggle pause (0<->1)
          
          
          let PauseButtonPrev  = temp1 : rem Update previous button state for next frame
          
          return

          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC
          rem   ROUTINES
          rem The original InputHandlePlayer1, HandlePlayer2Input,
          rem   HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into
          rem   HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

