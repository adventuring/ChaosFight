GetPlayerAnimationStateFunction
          asm
GetPlayerAnimationStateFunction

end
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
          rem   playerX[0-3] - X positions
          rem   playerY[0-3] - Y positions
          rem playerState[0-3] - State flags (attacking, guarding,
          rem   jumping, etc.)
          rem playerCharacter[0-3] - Character type indices (0-MaxCharacter)
          rem playerVelocityX[0-3] - Horizontal velocity (8.8
          rem   fixed-point)
          rem playerVelocityXL[0-3] - Horizontal velocity fractional
          rem   part
          rem   controllerStatus - Packed controller detection status
          rem   qtcontroller - Multiplexing state (0=P1/P2, 1=P3/P4)
          rem STATE FLAGS (in playerState):
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

InputHandleAllPlayers
          asm
InputHandleAllPlayers

end
          rem Main input handler for all players
          rem Main input handler for all players with Quadtari
          rem multiplexing
          rem
          rem Input: qtcontroller (global) = multiplexing state
          rem (0=P1/P2, 1=P3/P4)
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        playerCharacter[] (global array) = character selections
          rem        playerState[] (global array) = player state flags
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
          rem   InputHandleLeftPortPlayerFunction, InputHandleRightPortPlayerFunction -
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
          let currentPlayer = 0 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer0Input
          if (playerState[0] & 8) then InputDonePlayer0Input
          let temp1 = 0 : gosub InputHandleLeftPortPlayerFunction

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

          let currentPlayer = 1 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer1Input
          if (playerState[1] & 8) then InputDonePlayer1Input
          goto InputHandlePlayer1

          goto InputDonePlayer1Input

InputHandlePlayer1
          rem Handle Player 1 input (right port)
          rem
          rem Input: temp1 (set to 1), playerState[] (global array)
          rem
          rem Output: Player 1 input processed
          rem
          rem Mutates: temp1 (set to 1), player state (via
          rem InputHandleRightPortPlayerFunction)
          rem
          rem Called Routines: InputHandleRightPortPlayerFunction - handles
          rem right port player input
          rem Constraints: Must be colocated with InputHandleAllPlayers, InputSkipPlayer1Input
          let temp1 = 1
          gosub InputHandleRightPortPlayerFunction
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
          rem Input: controllerStatus (global), playerCharacter[] (global array),
          rem        playerState[] (global array)
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
          rem   InputHandleLeftPortPlayerFunction, InputHandleRightPortPlayerFunction -
          rem   handle input for left/right port players
          rem
          rem Constraints: Must be colocated with InputHandleAllPlayers,
          rem InputSkipPlayer3Input,
          rem InputSkipPlayer4Input
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and
          rem alive)
          if (controllerStatus & SetQuadtariDetected) = 0 then InputDonePlayer3Input
          if playerCharacter[2] = NoCharacter then InputDonePlayer3Input
          let currentPlayer = 2 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer3Input
          if (playerState[2] & 8) then InputDonePlayer3Input
          let temp1 = 2 : gosub InputHandleLeftPortPlayerFunction

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
          if (controllerStatus & SetQuadtariDetected) = 0 then InputDonePlayer4Input
          if playerCharacter[3] = NoCharacter then InputDonePlayer4Input
          let currentPlayer = 3 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer4Input
          if (playerState[3] & 8) then InputDonePlayer4Input
          let temp1 = 3 : gosub InputHandleRightPortPlayerFunction

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

HandleGuardInput
          asm
HandleGuardInput

end
          rem
          rem Shared Guard Input Handling
          rem Handles down/guard input for both ports
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0down for players 0,2; joy1down for players 1,3
          rem Determine which joy port to use based on player index
          rem Frooty (8) cannot guard
          if playerCharacter[temp1] = 8 then return
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
          let temp4 = playerCharacter[temp1]
          rem DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          if temp4 >= 32 then return
          if temp4 = 2 then goto DragonOfStormsDown
          if temp4 = 6 then goto HarpyDown
          if temp4 = 8 then goto FrootyDown
          if temp4 = 13 then goto DCD_HandleRoboTitoDown
          goto StandardGuard
DCD_HandleRoboTitoDown
          gosub RoboTitoDown
          if temp2 = 1 then return
          goto StandardGuard
HGI_CheckGuardRelease
          let temp2 = playerState[temp1] & 2
          rem DOWN released - check for early guard release
          if !temp2 then return
          rem Not guarding, nothing to do
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          rem Stop guard early and start cooldown
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
          return

HandleFlyingCharacterMovement
          asm
HandleFlyingCharacterMovement

end
          rem
          rem Shared Flying Character Movement
          rem Handles horizontal movement with collision for flying
          rem   characters (Frooty, Dragon of Storms)
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0left/joy0right for players 0,2;
          rem joy1left/joy1right
          rem for players 1,3
          let temp5 = playerCharacter[temp1]
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 & 2 = 0 then HFCM_UseJoy0
          rem Players 1,3 use joy1
          if joy1left then HFCM_CheckLeftCollision
          goto HFCM_CheckRightMovement
HFCM_UseJoy0
          rem Players 0,2 use joy0
          if joy0left then HFCM_CheckLeftCollision
          goto HFCM_CheckRightMovement
HFCM_CheckLeftCollision
          rem Convert player position to playfield coordinates
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0

          rem Check column to the left

          if temp2 <= 0 then goto HFCM_CheckRightMovement
          let temp3 = temp2 - 1
          rem Already at left edge
          rem checkColumn = column to the left
          let currentPlayer = temp1
          rem Save player index to global variable
          let temp4 = playerY[temp1]
          rem Check player current row (check both top and bottom of sprite)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          rem pfRow = top row  
          rem Check if blocked in current row
          let temp5 = 0
          rem Reset left-collision flag
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then goto HFCM_CheckRightMovement
          rem Blocked, cannot move left
          let temp2 = temp4 + 16
          rem Also check bottom row (feet)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          if temp6 >= pfrows then goto HFCM_MoveLeftOK
          rem Do not check if beyond screen
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then goto HFCM_CheckRightMovement
HFCM_MoveLeftOK
          rem Blocked at bottom too
          if temp5 = 8 then goto HFCM_LeftMomentumApply
          if temp5 = 2 then goto HFCM_LeftDirectApply
          rem Default (should not hit): apply -1
          let playerVelocityX[temp1] = $ff
          let playerVelocityXL[temp1] = 0
          goto HFCM_LeftApplyDone
HFCM_LeftMomentumApply
          let playerVelocityX[temp1] = playerVelocityX[temp1] - CharacterMovementSpeed[temp5]
          let playerVelocityXL[temp1] = 0
          goto HFCM_LeftApplyDone
HFCM_LeftDirectApply
          let playerX[temp1] = playerX[temp1] - CharacterMovementSpeed[temp5]
HFCM_LeftApplyDone
          rem Preserve facing during hurt/recovery states (knockback, hitstun)
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes1
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo1
          if temp2 > 9 then goto SPF_InlineNo1
SPF_InlineYes1
          let temp3 = 1
          goto SPF_InlineDone1
SPF_InlineNo1
          let temp3 = 0
SPF_InlineDone1
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
HFCM_CheckRightMovement
          rem Determine which joy port to use for right movement
          if temp1 = 0 then HFCM_CheckRightJoy0
          if temp1 = 2 then HFCM_CheckRightJoy0
          rem Players 1,3 use joy1
          if !joy1right then return
          goto HFCM_DoRightMovement
HFCM_CheckRightJoy0
          rem Players 0,2 use joy0
          if !joy0right then return
HFCM_DoRightMovement
          rem Convert player position to playfield coordinates
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0

          rem Check column to the right

          if temp2 >= 31 then return
          let temp3 = temp2 + 1
          rem Already at right edge
          rem checkColumn = column to the right
          let currentPlayer = temp1
          rem Save player index to global variable
          let temp4 = playerY[temp1]
          rem Check player current row (check both top and bottom of sprite)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          rem pfRow = top row
          rem Check if blocked in current row
          let temp5 = 0
          rem Reset right-collision flag
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then return
          rem Blocked, cannot move right
          let temp4 = temp4 + 16
          rem Also check bottom row (feet)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          if temp6 >= pfrows then goto HFCM_MoveRightOK
          rem Do not check if beyond screen
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then return
HFCM_MoveRightOK
          rem Blocked at bottom too
          if temp5 = 8 then goto HFCM_RightMomentumApply
          if temp5 = 2 then goto HFCM_RightDirectApply
          rem Default (should not hit): apply +1
          let playerVelocityX[temp1] = 1
          let playerVelocityXL[temp1] = 0
          goto HFCM_RightApplyDone
HFCM_RightMomentumApply
          let playerVelocityX[temp1] = playerVelocityX[temp1] + CharacterMovementSpeed[temp5]
          let playerVelocityXL[temp1] = 0
          goto HFCM_RightApplyDone
HFCM_RightDirectApply
          let playerX[temp1] = playerX[temp1] + CharacterMovementSpeed[temp5]
HFCM_RightApplyDone
          rem Preserve facing during hurt/recovery states while processing right movement
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes2
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo2
          if temp2 > 9 then goto SPF_InlineNo2
SPF_InlineYes2
          let temp3 = 1
          goto SPF_InlineDone2
SPF_InlineNo2
          let temp3 = 0
SPF_InlineDone2
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          rem Vertical control for flying characters: UP/DOWN
          if temp1 & 2 = 0 then HFCM_VertJoy0
          if joy1up then HFCM_VertUp
          if joy1down then HFCM_VertDown
          return
HFCM_VertJoy0
          if joy0up then HFCM_VertUp
          if joy0down then HFCM_VertDown
          return
HFCM_VertUp
          if temp5 = 8 then let playerVelocityY[temp1] = playerVelocityY[temp1] - CharacterMovementSpeed[temp5] : return
          if temp5 = 2 then let playerY[temp1] = playerY[temp1] - CharacterMovementSpeed[temp5] : return
          return
HFCM_VertDown
          if temp5 = 8 then let playerVelocityY[temp1] = playerVelocityY[temp1] + CharacterMovementSpeed[temp5] : return
          if temp5 = 2 then let playerY[temp1] = playerY[temp1] + CharacterMovementSpeed[temp5] : return
          return

InputHandleLeftPortPlayerFunction
          asm
InputHandleLeftPortPlayerFunction

end
          rem
          rem LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)
          rem
          rem INPUT: temp1 = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
          let currentPlayer = temp1
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationStateFunction
          rem   block movement during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 310+ bytes away)
          if temp2 >= 13 then goto DoneLeftPortMovement
          rem Block movement during attack windup/execute/recovery

          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = playerCharacter[temp1]
          rem   for horizontal movement
          rem Use goto to avoid branch out of range (target is 298+ bytes away)
          if temp5 = 8 then goto IHLP_FlyingMovement
          if temp5 = 2 then goto IHLP_FlyingMovement

          rem Standard horizontal movement (modifies velocity, not
          rem position)
          rem Left movement: set negative velocity (255 in 8-bit twos
          rem complement = -1)
          if !joy0left then goto IHLP_DoneLeftMovement
          if playerCharacter[temp1] = 8 then goto IHLP_LeftMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let temp2 = 0
          let temp2 = temp2 - temp6
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          goto IHLP_AfterLeftSet0
IHLP_LeftMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
IHLP_AfterLeftSet0
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes3
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo3
          if temp2 > 9 then goto SPF_InlineNo3
SPF_InlineYes3
          let temp3 = 1
          goto SPF_InlineDone3
SPF_InlineNo3
          let temp3 = 0
SPF_InlineDone3
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
IHLP_DoneLeftMovement
          rem Right movement: set positive velocity
          if !joy0right then goto IHLP_DoneFlyingLeftRight
          if playerCharacter[temp1] = 8 then goto IHLP_RightMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = temp6
          let playerVelocityXL[temp1] = 0
          goto IHLP_AfterRightSet0
IHLP_RightMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
IHLP_AfterRightSet0
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes4
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo4
          if temp2 > 9 then goto SPF_InlineNo4
SPF_InlineYes4
          let temp3 = 1
          goto SPF_InlineDone4
SPF_InlineNo4
          let temp3 = 0
SPF_InlineDone4
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          rem Right movement complete
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
          if playerCharacter[temp1] = 15 then let playerCharacter[temp1] = 31 : goto DoneJumpInput
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = 31 then let playerCharacter[temp1] = 15 : goto DoneJumpInput
          rem Switch MethHound -> Shamone

          rem Robo Tito (13): Hold UP to ascend; auto-latch on ceiling contact
          if playerCharacter[temp1] = 13 then RoboTitoAscendLeft

          rem Check Bernie fall-through (Character 0)

          if playerCharacter[temp1] = 0 then BernieFallThrough

          rem Check Harpy flap (Character 6)

          if playerCharacter[temp1] = 6 then HarpyFlap

          goto NormalJumpInput
          rem For all other characters, UP is jump

BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump bank13
          rem   through 1-row floors)
          goto DoneJumpInput

HarpyFlap
          gosub HarpyJump bank13
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInput

RoboTitoAscendLeft
          rem Ascend toward ceiling
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerY[temp1] = playerY[temp1] - temp6
          rem Compute playfield column
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          let temp4 = temp2
          rem Save playfield column (temp2 will be overwritten)
          rem Compute head row and check ceiling contact
          let temp2 = playerY[temp1]
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          if temp2 = 0 then goto RoboTitoLatchLeft
          let temp3 = temp2 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          if temp1 then RoboTitoLatchLeft
          let temp1 = currentPlayer
          rem Clear latch if DOWN pressed
          if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          goto DoneJumpInput
RoboTitoLatchLeft
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
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
          if playerCharacter[temp1] = 15 then goto ShamoneJumpCheckEnhanced
          if playerCharacter[temp1] = 31 then goto ShamoneJumpCheckEnhanced
          if playerCharacter[temp1] = 0 then goto ShamoneJumpCheckEnhanced
          if playerCharacter[temp1] = 6 then goto ShamoneJumpCheckEnhanced
          rem Bernie and Harpy also use enhanced buttons for jump

          goto SkipEnhancedJumpCheck
ShamoneJumpCheckEnhanced
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II for alternative UP for any characters

          rem Execute jump if pressed and not already jumping
          rem For Shamone/Meth Hound, treat enhanced button as UP (toggle forms)
          if playerCharacter[temp1] = 15 then if temp3 then let playerCharacter[temp1] = 31 : goto InputDoneLeftPortJump
          if playerCharacter[temp1] = 31 then if temp3 then let playerCharacter[temp1] = 15 : goto InputDoneLeftPortJump
          rem Use goto to avoid branch out of range (target is 244+ bytes away)
          if temp3 = 0 then goto InputDoneLeftPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto LeftZoeEnhancedCheck
          rem Use goto to avoid branch out of range (target is 224+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneLeftPortJump
          goto LeftEnhancedJumpProceed
LeftZoeEnhancedCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 189+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneLeftPortJump
LeftEnhancedJumpProceed
          rem Use cached animation state - block jump during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 183+ bytes away)
          if temp2 >= 13 then goto InputDoneLeftPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          rem Dispatch character jump (inlined for performance)
          if temp4 >= 32 then goto InputDoneLeftPortJump
          if temp4 >= 16 && temp4 <= 30 then goto StandardJump
          if temp4 = 31 then goto ShamoneJump
          on temp4 goto BernieJump StandardJump DragonOfStormsJump ZoeRyenJump FatTonyJump StandardJump HarpyJump KnightGuyJump FrootyJump StandardJump NinjishGuyJump PorkChopJump RadishGoblinJump RoboTitoJump UrsuloJump ShamoneJump
          goto InputDoneLeftPortJump

SkipEnhancedJumpCheck
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II

          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          rem Use goto to avoid branch out of range (target is 244+ bytes away)
          if temp3 = 0 then goto InputDoneLeftPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto LeftZoeStdJumpCheck
          rem Use goto to avoid branch out of range (target is 224+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneLeftPortJump
          goto LeftStdJumpProceed
LeftZoeStdJumpCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 189+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneLeftPortJump
LeftStdJumpProceed
          rem Use cached animation state - block jump during attack
          rem animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 183+ bytes away)
          if temp2 >= 13 then goto InputDoneLeftPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          rem Dispatch character jump (inlined for performance)
          if temp4 >= 32 then goto InputDoneLeftPortJump2
          if temp4 >= 16 && temp4 <= 30 then goto StandardJump
          if temp4 = 31 then goto ShamoneJump
          on temp4 goto BernieJump StandardJump DragonOfStormsJump ZoeRyenJump FatTonyJump StandardJump HarpyJump KnightGuyJump FrootyJump StandardJump NinjishGuyJump PorkChopJump RadishGoblinJump RoboTitoJump UrsuloJump ShamoneJump
          goto InputDoneLeftPortJump2
InputDoneLeftPortJump2
          if playerCharacter[temp1] = 3 then if temp6 = 1 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
InputDoneLeftPortJump

          rem Process down/guard input (inlined for performance)
          rem Frooty (8) cannot guard
          if playerCharacter[temp1] = 8 then goto HGI_Done1
          rem Players 0,2 use joy0; Players 1,3 use joy1
          if temp1 = 0 then HGI_CheckJoy0_1
          if temp1 = 2 then HGI_CheckJoy0_1
          rem Players 1,3 use joy1
          if !joy1down then goto HGI_CheckGuardRelease1
          goto HGI_HandleDownPressed1
HGI_CheckJoy0_1
          rem Players 0,2 use joy0
          if !joy0down then goto HGI_CheckGuardRelease1
HGI_HandleDownPressed1
          let temp4 = playerCharacter[temp1]
          rem DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          if temp4 >= 32 then goto HGI_Done1
          if temp4 = 2 then goto DragonOfStormsDown
          if temp4 = 6 then goto HarpyDown
          if temp4 = 8 then goto FrootyDown
          if temp4 = 13 then goto DCD_HandleRoboTitoDown1
          goto StandardGuard
DCD_HandleRoboTitoDown1
          gosub RoboTitoDown
          if temp2 = 1 then goto HGI_Done1
          goto StandardGuard
HGI_CheckGuardRelease1
          let temp2 = playerState[temp1] & 2
          rem DOWN released - check for early guard release
          if !temp2 then goto HGI_Done1
          rem Not guarding, nothing to do
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          rem Stop guard early and start cooldown
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
HGI_Done1

          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          rem Use cached animation state - block attack input during
          rem attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneLeftPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = playerState[temp1] & 2
          rem Check if player is guarding - guard blocks attacks
          if temp2 then InputDoneLeftPortAttack
          rem Guarding - block attack input
          if !joy0fire then InputDoneLeftPortAttack
          if (playerState[temp1] & PlayerStateBitFacing) then InputDoneLeftPortAttack
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterAttack bank7
InputDoneLeftPortAttack


          return

InputHandleRightPortPlayerFunction
          asm
InputHandleRightPortPlayerFunction

end
          rem
          rem RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
          rem
          rem INPUT: temp1 = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
          let currentPlayer = temp1
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationStateFunction
          rem   block movement during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 327+ bytes away)
          if temp2 >= 13 then goto DoneRightPortMovement
          rem Block movement during attack windup/execute/recovery

          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          let temp6 = playerState[temp1] & 2
          rem Check if player is guarding - guard blocks movement
          rem Use goto to avoid branch out of range (target is 314+ bytes away)
          if temp6 then goto DoneRightPortMovement
          rem Guarding - block movement

          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = playerCharacter[temp1]
          rem   for horizontal movement
          rem Use goto to avoid branch out of range (target is 302+ bytes away)
          if temp5 = 8 then goto IHRP_FlyingMovement
          if temp5 = 2 then goto IHRP_FlyingMovement

          rem Standard horizontal movement (no collision check)

          if !joy1left then goto IHRP_DoneLeftMovement
          if playerCharacter[temp1] = 8 then goto IHRP_LeftMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let temp2 = 0
          let temp2 = temp2 - temp6
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          goto IHRP_AfterLeftSet1
IHRP_LeftMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
IHRP_AfterLeftSet1
          rem Preserve facing during hurt/recovery states while processing right movement
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes5
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo5
          if temp2 > 9 then goto SPF_InlineNo5
SPF_InlineYes5
          let temp3 = 1
          goto SPF_InlineDone5
SPF_InlineNo5
          let temp3 = 0
SPF_InlineDone5
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
IHRP_DoneLeftMovement

          if !joy1right then goto IHRP_DoneFlyingLeftRight
          if playerCharacter[temp1] = 8 then goto IHRP_RightMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = temp6
          rem Apply rightward velocity impulse
          let playerVelocityXL[temp1] = 0
          goto IHRP_AfterRightSet1
IHRP_RightMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
IHRP_AfterRightSet1
          rem Preserve facing during hurt/recovery states (knockback, hitstun)
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes6
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo6
          if temp2 > 9 then goto SPF_InlineNo6
SPF_InlineYes6
          let temp3 = 1
          goto SPF_InlineDone6
SPF_InlineNo6
          let temp3 = 0
SPF_InlineDone6
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          rem Right movement complete (right port)

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
          if playerCharacter[temp1] = 15 then let playerCharacter[temp1] = 31 : goto DoneJumpInputRight
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = 31 then let playerCharacter[temp1] = 15 : goto DoneJumpInputRight
          rem Switch MethHound -> Shamone

          rem Robo Tito (13): Hold UP to ascend; auto-latch on ceiling contact
          if playerCharacter[temp1] = 13 then RoboTitoAscendRight

          rem Check Bernie fall-through (Character 0)

          if playerCharacter[temp1] = 0 then BernieFallThroughRight

          rem Check Harpy flap (Character 6)

          if playerCharacter[temp1] = 6 then HarpyFlapRight

          goto NormalJumpInputRight
          rem For all other characters, UP is jump

BernieFallThroughRight
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump bank13
          rem   through 1-row floors)
          goto DoneJumpInputRight

HarpyFlapRight
          gosub HarpyJump bank13
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInputRight

RoboTitoAscendRight
          rem Ascend toward ceiling (right port)
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerY[temp1] = playerY[temp1] - temp6
          rem Compute playfield column
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          let temp4 = temp2
          rem Save playfield column (temp2 will be overwritten)
          rem Compute head row and check ceiling contact
          let temp2 = playerY[temp1]
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          if temp2 = 0 then goto RoboTitoLatchRight
          let temp3 = temp2 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          if temp1 then RoboTitoLatchRight
          let temp1 = currentPlayer
          rem Clear latch if DOWN pressed
          if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          goto DoneJumpInputRight
RoboTitoLatchRight
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
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
          if playerCharacter[temp1] = 15 then goto ShamoneJumpCheckEnhancedRight
          if playerCharacter[temp1] = 31 then goto ShamoneJumpCheckEnhancedRight
          if playerCharacter[temp1] = 0 then goto ShamoneJumpCheckEnhancedRight
          if playerCharacter[temp1] = 6 then goto ShamoneJumpCheckEnhancedRight
          rem Bernie and Harpy also use enhanced buttons for jump

          goto SkipEnhancedJumpCheckRight
ShamoneJumpCheckEnhancedRight
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II for JUMP for any character, identical to UP

          rem Execute jump if pressed and not already jumping
          rem For Shamone/Meth Hound, treat enhanced button as UP (toggle forms)
          if playerCharacter[temp1] = 15 then if temp3 then let playerCharacter[temp1] = 31 : goto InputDoneRightPortJump
          if playerCharacter[temp1] = 31 then if temp3 then let playerCharacter[temp1] = 15 : goto InputDoneRightPortJump
          rem Use goto to avoid branch out of range (target is 218+ bytes away)
          if temp3 = 0 then goto InputDoneRightPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto RightZoeEnhancedCheck
          rem Use goto to avoid branch out of range (target is 198+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneRightPortJump
          goto RightEnhancedJumpProceed
RightZoeEnhancedCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 163+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneRightPortJump
RightEnhancedJumpProceed
          rem Use cached animation state - block jump during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 157+ bytes away)
          if temp2 >= 13 then goto InputDoneRightPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          rem Dispatch character jump (inlined for performance)
          if temp4 >= 32 then goto InputDoneRightPortJump
          if temp4 >= 16 && temp4 <= 30 then goto StandardJump
          if temp4 = 31 then goto ShamoneJump
          on temp4 goto BernieJump StandardJump DragonOfStormsJump ZoeRyenJump FatTonyJump StandardJump HarpyJump KnightGuyJump FrootyJump StandardJump NinjishGuyJump PorkChopJump RadishGoblinJump RoboTitoJump UrsuloJump ShamoneJump
          goto InputDoneRightPortJump

SkipEnhancedJumpCheckRight
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II
          rem temp3 already set by CheckEnhancedJumpButton

          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          rem Shamone)
          rem Use goto to avoid branch out of range (target is 218+ bytes away)
          if temp3 = 0 then goto InputDoneRightPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto RightZoeStdJumpCheck
          rem Use goto to avoid branch out of range (target is 198+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneRightPortJump
          goto RightStdJumpProceed
RightZoeStdJumpCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 163+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneRightPortJump
RightStdJumpProceed
          rem Use cached animation state - block jump during attack
          rem animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 157+ bytes away)
          if temp2 >= 13 then goto InputDoneRightPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          rem Dispatch character jump (inlined for performance)
          if temp4 >= 32 then goto InputDoneRightPortJump
          if temp4 >= 16 && temp4 <= 30 then goto StandardJump
          if temp4 = 31 then goto ShamoneJump
          on temp4 goto BernieJump StandardJump DragonOfStormsJump ZoeRyenJump FatTonyJump StandardJump HarpyJump KnightGuyJump FrootyJump StandardJump NinjishGuyJump PorkChopJump RadishGoblinJump RoboTitoJump UrsuloJump ShamoneJump
InputDoneRightPortJump
          rem Process down/guard input (inlined for performance)
          rem Frooty (8) cannot guard
          if playerCharacter[temp1] = 8 then goto HGI_Done2
          rem Players 0,2 use joy0; Players 1,3 use joy1
          if temp1 = 0 then HGI_CheckJoy0_2
          if temp1 = 2 then HGI_CheckJoy0_2
          rem Players 1,3 use joy1
          if !joy1down then goto HGI_CheckGuardRelease2
          goto HGI_HandleDownPressed2
HGI_CheckJoy0_2
          rem Players 0,2 use joy0
          if !joy0down then goto HGI_CheckGuardRelease2
HGI_HandleDownPressed2
          let temp4 = playerCharacter[temp1]
          rem DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          if temp4 >= 32 then goto HGI_Done2
          if temp4 = 2 then goto DragonOfStormsDown
          if temp4 = 6 then goto HarpyDown
          if temp4 = 8 then goto FrootyDown
          if temp4 = 13 then goto DCD_HandleRoboTitoDown2
          goto StandardGuard
DCD_HandleRoboTitoDown2
          gosub RoboTitoDown
          if temp2 = 1 then goto HGI_Done2
          goto StandardGuard
HGI_CheckGuardRelease2
          let temp2 = playerState[temp1] & 2
          rem DOWN released - check for early guard release
          if !temp2 then goto HGI_Done2
          rem Not guarding, nothing to do
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          rem Stop guard early and start cooldown
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
HGI_Done2

          rem Process attack input
          rem Use cached animation state - block attack input during
          rem attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneRightPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = playerState[temp1] & 2 PlayerStateBitGuarding
          if temp2 then InputDoneRightPortAttack
          rem Guarding - block attack input
          if !joy1fire then InputDoneRightPortAttack
          if (playerState[temp1] & PlayerStateBitFacing) then InputDoneRightPortAttack
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterAttack bank7
InputDoneRightPortAttack
          return

HandlePauseInput
          rem
          rem Pause Button Handling With Debouncing
          rem Handles SELECT switch and Joy2b+ Button III with proper
          rem   debouncing
          rem Uses pauseButtonPrev for debouncing state
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
          if pauseButtonPrev then DonePauseToggle
          let gameState = gameState ^ 1
DonePauseToggle
          rem Toggle pause (0<->1)


          let pauseButtonPrev  = temp1
          rem Update previous button state for next frame

          return

          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC
          rem   ROUTINES
          rem The original InputHandlePlayer1, HandlePlayer2Input,
          rem   HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into
          rem   HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

