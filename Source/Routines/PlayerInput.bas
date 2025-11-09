GetPlayerAnimationState
          rem
          rem ChaosFight - Source/Routines/PlayerInput.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
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
          rem Input: temp1 = player index (0-3), playerState[]
          rem Output: temp2 = animation state (bits 4-7 of playerState)
          let temp2 = playerState[temp1] & 240
          let temp2 = temp2 / 16
          rem Mask bits 4-7 (value 240 = %11110000)
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
          rem Uses temp2 to check recovery/hurt states.
          rem Input: temp1 = player index (0-3), playerState[]
          rem Output: temp3 = 1 if facing locked, 0 otherwise
          rem Mutates: temp2, temp3
          rem Calls: GetPlayerAnimationState
          rem
          rem Constraints: Must be colocated with SPF_PreserveYes,
          rem SPF_PreserveNo (called via goto)
          rem Check recovery/hitstun flag (bit 3)
          if (playerState[temp1] & 8) then SPF_PreserveYes
          rem Bit 3 set = in recovery, preserve facing
          
          rem Check animation state for hurt states (5-9)
          rem ActionHit=5, ActionFallBack=6, ActionFallDown=7,
          gosub GetPlayerAnimationState
          rem ActionFallen=8, ActionRecovering=9
          if temp2 < 5 then SPF_PreserveNo
          rem Animation state < 5, allow facing update
          if temp2 > 9 then SPF_PreserveNo
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
          rem Constraints: Must be colocated with ShouldPreserveFacing, SPF_PreserveNo
          let temp3 = 1
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
          rem Constraints: Must be colocated with ShouldPreserveFacing, SPF_PreserveYes
          let temp3 = 0
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
          rem        playerCharacter[] (global array) = character selections
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
          rem InputSkipPlayer4Input (all called via goto or gosub)
          if qtcontroller then goto InputHandleQuadtariPlayers
          
          rem Even frame: Handle Players 1 & 2 - only if alive  
          let currentPlayer = 0 : gosub IsPlayerAlive
          if temp2 = 0 then InputDonePlayer0Input
          if (PlayerState[0] & 8) then InputDonePlayer0Input
          let temp1 = 0 : gosub InputHandleLeftPortPlayer

InputDonePlayer0Input
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
          if temp2 = 0 then InputDonePlayer1Input
          if (PlayerState[1] & 8) then InputDonePlayer1Input
          goto InputHandlePlayer1

          goto InputDonePlayer1Input

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
          rem Constraints: Must be colocated with InputHandleAllPlayers, InputSkipPlayer1Input
          let temp1 = 1
          gosub InputHandleRightPortPlayer
InputDonePlayer1Input
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
          rem Input: ControllerStatus (global), playerCharacter[] (global array),
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
          rem InputSkipPlayer4Input
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and
          rem alive)
          if !(ControllerStatus & SetQuadtariDetected) then InputDonePlayer3Input
          if playerCharacter[2] = NoCharacter then InputDonePlayer3Input
          let currentPlayer = 2 : gosub IsPlayerAlive
          if temp2 = 0 then InputDonePlayer3Input
          if (PlayerState[2] & 8) then InputDonePlayer3Input
          let temp1 = 2 : gosub InputHandleLeftPortPlayer

InputDonePlayer3Input
          rem Skip Player 3 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with InputHandleQuadtariPlayers
          if !(ControllerStatus & SetQuadtariDetected) then InputDonePlayer4Input
          if playerCharacter[3] = NoCharacter then InputDonePlayer4Input
          let currentPlayer = 3 : gosub IsPlayerAlive
          if temp2 = 0 then InputDonePlayer4Input
          if (PlayerState[3] & 8) then InputDonePlayer4Input
          let temp1 = 3 : gosub InputHandleRightPortPlayer

InputDonePlayer4Input
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

DispatchCharacterAttack
          rem Dispatch to character-specific attack handler
          gosub DispatchCharacterAttack bank10
          return
GotoBernieAttack
          rem
          rem ATTACK TRAMPOLINE FUNCTIONS (bank 11 →
          rem Characterattacks.bas)
          rem Local trampoline labels that jump to Bank 11 attack
          rem handlers
          rem This allows on/goto to work with cross-bank references

          goto BernieAttack bank9

GotoCurlerAttack
          goto CurlerAttack bank9

GotoDragonOfStormsAttack
          goto DragonOfStormsAttack bank9

GotoZoeRyenAttack
          goto ZoeRyenAttack bank9

GotoFatTonyAttack
          goto FatTonyAttack bank9

GotoMegaxAttack
          goto MegaxAttack bank9

GotoHarpyAttack
          goto HarpyAttack bank9

GotoKnightGuyAttack
          goto KnightGuyAttack bank9

GotoFrootyAttack
          goto FrootyAttack bank9

GotoNefertemAttack
          goto NefertemAttack bank9

GotoNinjishGuyAttack
          goto NinjishGuyAttack bank9

GotoPorkChopAttack
          goto PorkChopAttack bank9
          goto CEJB_Done
CEJB_CheckPlayer2Joy2bPlus
          rem Player 2: Check Joy2b+ controller
          if !(ControllerStatus & $08) then CEJB_Done
          if !(INPT2 & $80) then temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer4
          rem Player 4: Check Genesis controller
          if !RightPortGenesis then CEJB_CheckPlayer4Joy2bPlus
          if !INPT2{7} then temp3 = 1
          goto CEJB_Done
CEJB_CheckPlayer4Joy2bPlus
          rem Player 4: Check Joy2b+ controller
          if !RightPortJoy2bPlus then CEJB_Done
          if !INPT2{7} then temp3 = 1
CEJB_Done
          return

HandleGuardInput
          rem
          rem Shared Guard Input Handling
          rem Handles down/guard input for both ports
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0down for players 0,2; joy1down for players 1,3
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0; Players 1,3 use joy1
          if temp1 = 0 then HGI_CheckJoy0
          if temp1 = 2 then HGI_CheckJoy0
          rem Players 1,3 use joy1
          if !joy1down then goto HGI_CheckGuardRelease
          goto HGI_HandleDownPressed
HGI_CheckJoy0
          rem Players 0,2 use joy0
          if !joy0down then goto HGI_CheckGuardRelease
HGI_HandleDownPressed
          let temp4 = PlayerCharacter[temp1]
          rem DOWN pressed - dispatch to character-specific down handler
          gosub DispatchCharacterDown bank14
          return
HGI_CheckGuardRelease
          let temp2 = PlayerState[temp1] & 2
          rem DOWN released - check for early guard release
          if !temp2 then return
          rem Not guarding, nothing to do
          let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitGuarding)
          rem Stop guard early and start cooldown
          let playerTimers_W[temp1] = GuardTimerMaxFrames
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
          rem MUTATES: temp2 (return value)
          let temp2 = PlayerX[temp1]
          rem Convert player position to playfield coordinates
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem pfColumn = playfield column
          if temp2 > 31 then temp2 = 31
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp2 & $80 then temp2 = 0
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
          rem for players 1,3
          goto HFCM_Start
HFCM_UseJoy0
          rem Players 0,2 use joy0
          if joy0left then HFCM_CheckLeftCollision
          goto HFCM_CheckRightMovement
HFCM_CheckLeftCollision
          gosub ConvertPlayerXToPlayfieldColumn
          rem Convert player position to playfield coordinates

          rem Check column to the left

          if temp2 <= 0 then goto HFCM_CheckRightMovement
          let temp3 = temp2 - 1
          rem Already at left edge
          rem checkColumn = column to the left
          let temp4 = PlayerY[temp1]
          rem Check player current row (check both top and bottom of sprite)
          let temp2 = temp4
          gosub DivideByPfrowheight bank7
          let temp6 = temp2
          rem pfRow = top row
          rem Check if blocked in current row
          let temp5 = 0
          rem Reset left-collision flag
          if pfread(temp3, temp6) then temp5 = 1
          if temp5 = 1 then goto HFCM_CheckRightMovement
          rem Blocked, cannot move left
          let temp2 = temp4 + 16
          rem Also check bottom row (feet)
          gosub DivideByPfrowheight bank7
          let temp6 = temp2
          if temp6 >= pfrows then goto HFCM_MoveLeftOK
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then temp5 = 1
          if temp5 = 1 then goto HFCM_CheckRightMovement
HFCM_MoveLeftOK
          rem Blocked at bottom too
          let playerVelocityX[temp1] = $ff
          rem Apply leftward velocity impulse (double-width sprite: 16px width)
          let playerVelocityXL[temp1] = 0
          rem Preserve facing during hurt/recovery states (knockback, hitstun)
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitFacing)
HFCM_CheckRightMovement
          rem Determine which joy port to use for right movement
          if temp1 = 0 then HFCM_CheckRightJoy0
          if temp1 = 2 then HFCM_CheckRightJoy0
          rem Players 1,3 use joy1
          if !joy1right then goto HFCM_DoneFlyingMovement
          goto HFCM_DoRightMovement
HFCM_CheckRightJoy0
          rem Players 0,2 use joy0
          if !joy0right then goto HFCM_DoneFlyingMovement
HFCM_DoRightMovement
          gosub ConvertPlayerXToPlayfieldColumn
          rem Convert player position to playfield coordinates

          rem Check column to the right

          if temp2 >= 31 then goto HFCM_DoneFlyingMovement
          let temp3 = temp2 + 1
          rem Already at right edge
          rem checkColumn = column to the right
          let temp4 = PlayerY[temp1]
          rem Check player current row (check both top and bottom of sprite)
          let temp2 = temp4
          gosub DivideByPfrowheight bank7
          let temp6 = temp2
          rem pfRow = top row
          rem Check if blocked in current row
          let temp5 = 0
          rem Reset right-collision flag
          if pfread(temp3, temp6) then temp5 = 1
          if temp5 = 1 then goto HFCM_DoneFlyingMovement
          rem Blocked, cannot move right
          let temp4 = temp4 + 16
          rem Also check bottom row (feet)
          let temp2 = temp4
          gosub DivideByPfrowheight bank7
          let temp6 = temp2
          if temp6 >= pfrows then goto HFCM_MoveRightOK
          rem Do not check if beyond screen
          if pfread(temp3, temp6) then temp5 = 1
          if temp5 = 1 then goto HFCM_DoneFlyingMovement
HFCM_MoveRightOK
          rem Blocked at bottom too
          let playerVelocityX[temp1] = 1
          rem Apply rightward velocity impulse
          let playerVelocityXL[temp1] = 0
          rem Preserve facing during hurt/recovery states while processing right movement
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] | 1
HFCM_DoneFlyingMovement
          return

HFCM_Start
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 = 0 then HFCM_UseJoy0
          if temp1 = 2 then HFCM_UseJoy0
          rem Players 1,3 use joy1
          if joy1left then HFCM_CheckLeftCollision
          goto HFCM_CheckRightMovement

InputHandleLeftPortPlayer
          rem
          rem LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)
          rem
          rem INPUT: temp1 = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationState
          rem   block movement during attack animations (states 13-15)
          if temp2 >= 13 then DoneLeftPortMovement
          rem Block movement during attack windup/execute/recovery
          
          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = PlayerCharacter[temp1]
          rem   for horizontal movement
          if temp5 = 8 then IHLP_FlyingMovement
          if temp5 = 2 then IHLP_FlyingMovement
          
          rem Standard horizontal movement (modifies velocity, not
          rem position)
          rem Left movement: set negative velocity (255 in 8-bit twos
          rem complement = -1)
          if !joy0left then goto IHLP_DoneLeftMovement
          let playerVelocityX[temp1] = 255
          let playerVelocityXL[temp1] = 0
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitFacing)
IHLP_DoneLeftMovement
          rem Right movement: set positive velocity
          if !joy0right then goto IHLP_DoneRightMovement
          let playerVelocityX[temp1] = 1
          let playerVelocityXL[temp1] = 0
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] | 1
IHLP_DoneRightMovement
          goto IHLP_DoneFlyingLeftRight
DoneLeftPortMovement
IHLP_FlyingMovement
          gosub HandleFlyingCharacterMovement
IHLP_DoneFlyingLeftRight

          rem Process UP input for character-specific behaviors
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy0up then goto DoneUpInputHandling
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerCharacter[temp1] = 15 then let PlayerCharacter[temp1] = 31 : goto DoneJumpInput
          rem Switch Shamone -> MethHound
          if PlayerCharacter[temp1] = 31 then let PlayerCharacter[temp1] = 15 : goto DoneJumpInput
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          
          if PlayerCharacter[temp1] = 0 then BernieFallThrough
          
          rem Check Harpy flap (Character 6)
          
          if PlayerCharacter[temp1] = 6 then HarpyFlap
          
          goto NormalJumpInput
          rem For all other characters, UP is jump
          
BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump bank14
          rem   through 1-row floors)
          goto DoneJumpInput
          
HarpyFlap
          gosub HarpyJump bank14
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInput
          
NormalJumpInput
          let temp3 = 1
          rem Process jump input (UP + enhanced buttons)
          goto DoneUpInputHandling
          rem Jump pressed flag (UP pressed)
          
DoneJumpInput
          let temp3 = 0 
          rem No jump (UP used for special ability)
          
DoneUpInputHandling
          rem Process jump input from enhanced buttons (Genesis/Joy2b+
          rem   Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump
          rem   via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced
          rem   buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons
          rem only
          if PlayerCharacter[temp1] = 15 then goto ShamoneJumpCheckEnhanced
          if PlayerCharacter[temp1] = 31 then goto ShamoneJumpCheckEnhanced
          if PlayerCharacter[temp1] = 0 then goto ShamoneJumpCheckEnhanced
          if PlayerCharacter[temp1] = 6 then goto ShamoneJumpCheckEnhanced
          rem Bernie and Harpy also use enhanced buttons for jump
          
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II

          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          if temp3 = 0 then InputDoneLeftPortJump
          if (PlayerState[temp1] & 4) then InputDoneLeftPortJump
          rem Use cached animation state - block jump during attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneLeftPortJump
          let temp4 = PlayerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          gosub DispatchCharacterJump bank14
InputDoneLeftPortJump

          

          gosub HandleGuardInput
          rem Process down/guard input
          
          
          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          rem Use cached animation state - block attack input during
          rem attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneLeftPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = PlayerState[temp1] & 2
          rem Check if player is guarding - guard blocks attacks
          if temp2 then InputDoneLeftPortAttack
          rem Guarding - block attack input
          if !joy0fire then InputDoneLeftPortAttack
          if (PlayerState[temp1] & PlayerStateBitFacing) then InputDoneLeftPortAttack
          let temp4 = PlayerCharacter[temp1]
          gosub DispatchCharacterAttack bank10
InputDoneLeftPortAttack
          
          
          return

InputHandleRightPortPlayer
          rem
          rem RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
          rem
          rem INPUT: temp1 = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationState
          rem   block movement during attack animations (states 13-15)
          if temp2 >= 13 then DoneRightPortMovement
          rem Block movement during attack windup/execute/recovery
          
          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          let temp6 = PlayerState[temp1] & 2
          rem Check if player is guarding - guard blocks movement
          if temp6 then DoneRightPortMovement
          rem Guarding - block movement
          
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = PlayerCharacter[temp1]
          rem   for horizontal movement
          if temp5 = 8 then IHRP_FlyingMovement
          if temp5 = 2 then IHRP_FlyingMovement
          
          rem Standard horizontal movement (no collision check)
          
          if !joy1left then goto IHRP_DoneLeftMovement
          let playerVelocityX[temp1] = 255
          rem Apply leftward velocity impulse
          rem -1 in 8-bit twos complement: 256 - 1 = 255
          let playerVelocityXL[temp1] = 0
          rem Preserve facing during hurt/recovery states while processing right movement
          gosub ShouldPreserveFacing
          if !temp3 then let PlayerState[temp1] = PlayerState[temp1] & (255 - PlayerStateBitFacing)
IHRP_DoneLeftMovement
          
          if !joy1right then goto IHRP_DoneRightMovement
          let playerVelocityX[temp1] = 1
          rem Apply rightward velocity impulse
          let playerVelocityXL[temp1] = 0
          rem Preserve facing during hurt/recovery states (knockback, hitstun)
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
          rem - Harpy: flap to fly (Character 6)
          if !joy1up then goto DoneUpInputHandlingRight
          
          rem Check Shamone form switching first (Character 15 <-> 31)
          if PlayerCharacter[temp1] = 15 then let PlayerCharacter[temp1] = 31 : goto DoneJumpInputRight
          rem Switch Shamone -> MethHound
          if PlayerCharacter[temp1] = 31 then let PlayerCharacter[temp1] = 15 : goto DoneJumpInputRight
          rem Switch MethHound -> Shamone
          
          rem Check Bernie fall-through (Character 0)
          
          if PlayerCharacter[temp1] = 0 then BernieFallThroughRight
          
          rem Check Harpy flap (Character 6)
          
          if PlayerCharacter[temp1] = 6 then HarpyFlapRight
          
          goto NormalJumpInputRight
          rem For all other characters, UP is jump
          
BernieFallThroughRight
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump bank14
          rem   through 1-row floors)
          goto DoneJumpInputRight
          
HarpyFlapRight
          gosub HarpyJump bank14
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInputRight
          
NormalJumpInputRight
          let temp3 = 1
          rem Process jump input (UP + enhanced buttons)
          goto DoneUpInputHandlingRight
          rem Jump pressed flag (UP pressed)
          
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
          rem only
          if PlayerCharacter[temp1] = 15 then goto ShamoneJumpCheckEnhancedRight
          if PlayerCharacter[temp1] = 31 then goto ShamoneJumpCheckEnhancedRight
          if PlayerCharacter[temp1] = 0 then goto ShamoneJumpCheckEnhancedRight
          if PlayerCharacter[temp1] = 6 then goto ShamoneJumpCheckEnhancedRight
          rem Bernie and Harpy also use enhanced buttons for jump
          
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II
          rem temp3 already set by CheckEnhancedJumpButton
          
          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          rem Shamone)
          if temp3 = 0 then InputDoneRightPortJump
          if (PlayerState[temp1] & 4) then InputDoneRightPortJump
          rem Use cached animation state - block jump during attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneRightPortJump
          let temp4 = PlayerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          gosub DispatchCharacterJump bank14
InputDoneRightPortJump
          gosub HandleGuardInput
          rem Process down/guard input

          rem Process attack input
          rem Use cached animation state - block attack input during
          rem attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneRightPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = PlayerState[temp1] & 2 PlayerStateBitGuarding
          if temp2 then InputDoneRightPortAttack
          rem Guarding - block attack input
          if !joy1fire then InputDoneRightPortAttack
          if (PlayerState[temp1] & PlayerStateBitFacing) then InputDoneRightPortAttack
          let temp4 = PlayerCharacter[temp1]
          gosub DispatchCharacterAttack bank10
InputDoneRightPortAttack
          return

HandlePauseInput
          rem
          rem Pause Button Handling With Debouncing
          rem Handles SELECT switch and Joy2b+ Button III with proper
          rem   debouncing
          rem Uses PauseButtonPrev for debouncing state
          let temp1 = 0
          rem Check SELECT switch (always available)
          if switchselect then temp1 = 1
          
          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for
          rem Player 2)
          if LeftPortJoy2bPlus then if !INPT1{7} then temp1 = 1
          if RightPortJoy2bPlus then if !INPT3{7} then temp1 = 1
Joy2bPauseDone
          rem Player 2 Button III
          
          rem Debounce: only toggle if button just pressed (was 0, now
          rem 1)
          if temp1 = 0 then DonePauseToggle
          if PauseButtonPrev then DonePauseToggle
          let GameState  = GameState ^ 1
DonePauseToggle
          rem Toggle pause (0<->1)
          
          
          let PauseButtonPrev  = temp1
          rem Update previous button state for next frame
          
          return

          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC
          rem   ROUTINES
          rem The original InputHandlePlayer1, HandlePlayer2Input,
          rem   HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into
          rem   HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

