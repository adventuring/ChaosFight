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
          if temp2 = 0 then goto InputDonePlayer0Input
          if (playerState[0] & 8) then goto InputDonePlayer0Input
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
          if temp2 = 0 then goto InputDonePlayer1Input
          if (playerState[1] & 8) then goto InputDonePlayer1Input
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
          if (controllerStatus & SetQuadtariDetected) = 0 then goto InputDonePlayer3Input
          if playerCharacter[2] = NoCharacter then goto InputDonePlayer3Input
          let currentPlayer = 2 : gosub IsPlayerAlive bank13
          if temp2 = 0 then goto InputDonePlayer3Input
          if (playerState[2] & 8) then goto InputDonePlayer3Input
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
          if (controllerStatus & SetQuadtariDetected) = 0 then goto InputDonePlayer4Input
          if playerCharacter[3] = NoCharacter then goto InputDonePlayer4Input
          let currentPlayer = 3 : gosub IsPlayerAlive bank13
          if temp2 = 0 then goto InputDonePlayer4Input
          if (playerState[3] & 8) then goto InputDonePlayer4Input
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
          rem Frooty cannot guard
          if playerCharacter[temp1] = CharacterFrooty then return
          rem Players 0,2 use joy0; Players 1,3 use joy1
          if temp1 = 0 then goto HGI_CheckJoy0
          if temp1 = 2 then goto HGI_CheckJoy0
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
          if temp4 = CharacterDragonOfStorms then goto DragonOfStormsDown
          if temp4 = CharacterHarpy then goto HarpyDown
          if temp4 = CharacterFrooty then goto FrootyDown
          if temp4 = CharacterRoboTito then goto DCD_HandleRoboTitoDown
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

HandleUpInputAndEnhancedButton
          rem Unified handler for UP input and enhanced button (Button II) handling
          rem
          rem INPUT: temp1 = player index (0-3), temp2 = cached animation state
          rem Uses: joy0up/joy0down for players 0,2; joy1up/joy1down for players 1,3
          rem        CheckEnhancedJumpButton for enhanced button state
          rem
          rem OUTPUT: temp3 = jump pressed flag (1=yes, 0=no)
          rem         Character-specific behaviors executed (form switch, fall-through, etc.)
          rem         Jump executed if conditions met
          rem
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 = 0 then goto HUIEB_UseJoy0
          if temp1 = 2 then goto HUIEB_UseJoy0
          rem Players 1,3 use joy1
          if !joy1up then goto HUIEB_CheckEnhanced
          goto HUIEB_HandleUp
HUIEB_UseJoy0
          rem Players 0,2 use joy0
          if !joy0up then goto HUIEB_CheckEnhanced
HUIEB_HandleUp
          rem Check Shamone form switching first (Shamone <-> MethHound)
          if playerCharacter[temp1] = CharacterShamone then let playerCharacter[temp1] = CharacterMethHound : let temp3 = 0 : return
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = CharacterMethHound then let playerCharacter[temp1] = CharacterShamone : let temp3 = 0 : return
          rem Switch MethHound -> Shamone
          rem Robo Tito: Hold UP to ascend; auto-latch on ceiling contact
          if playerCharacter[temp1] = CharacterRoboTito then goto HUIEB_RoboTitoAscend
          rem Check Bernie fall-through
          if playerCharacter[temp1] = CharacterBernie then goto HUIEB_BernieFallThrough
          rem Check Harpy flap
          if playerCharacter[temp1] = CharacterHarpy then goto HUIEB_HarpyFlap
          rem For all other characters, UP is jump
          let temp3 = 1
          goto HUIEB_CheckEnhanced
HUIEB_RoboTitoAscend
          rem Ascend toward ceiling
          rem Save cached animation state (temp2) - will be restored after playfield read
          let temp5 = temp2
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerY[temp1] = playerY[temp1] - temp6
          rem Compute playfield column
          let temp4 = playerX[temp1]
          let temp4 = temp4 - ScreenInsetX
          asm
            lsr temp4
            lsr temp4
end
          if temp4 > 31 then temp4 = 31
          if temp4 & $80 then temp4 = 0
          rem Compute head row and check ceiling contact
          let temp3 = playerY[temp1]
          asm
            lsr temp3
            lsr temp3
            lsr temp3
            lsr temp3
end
          if temp3 = 0 then goto HUIEB_RoboTitoLatch
          let temp3 = temp3 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          let temp1 = currentPlayer
          rem Restore cached animation state
          let temp2 = temp5
          if temp1 then goto HUIEB_RoboTitoLatch
          rem Clear latch if DOWN pressed (check appropriate joy port)
          if temp1 = 0 then goto HUIEB_RoboTitoCheckJoy0
          if temp1 = 2 then goto HUIEB_RoboTitoCheckJoy0
          if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          goto HUIEB_RoboTitoDone
HUIEB_RoboTitoCheckJoy0
          if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
HUIEB_RoboTitoDone
          let temp3 = 0
          return
HUIEB_RoboTitoLatch
          rem Restore cached animation state
          let temp2 = temp5
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          let temp3 = 0
          return
HUIEB_BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall through 1-row floors)
          gosub BernieJump bank10
          let temp3 = 0
          return
HUIEB_HarpyFlap
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          gosub HarpyJump bank10
          let temp3 = 0
          return
HUIEB_CheckEnhanced
          rem Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons only
          if playerCharacter[temp1] = CharacterShamone then goto HUIEB_EnhancedCheck
          if playerCharacter[temp1] = CharacterMethHound then goto HUIEB_EnhancedCheck
          if playerCharacter[temp1] = CharacterBernie then goto HUIEB_EnhancedCheck
          if playerCharacter[temp1] = CharacterHarpy then goto HUIEB_EnhancedCheck
          rem Bernie and Harpy also use enhanced buttons for jump
          goto HUIEB_StandardEnhancedCheck
HUIEB_EnhancedCheck
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II for alternative UP for any characters
          rem For Shamone/Meth Hound, treat enhanced button as UP (toggle forms)
          if playerCharacter[temp1] = CharacterShamone then if temp3 then let playerCharacter[temp1] = CharacterMethHound : return
          if playerCharacter[temp1] = CharacterMethHound then if temp3 then let playerCharacter[temp1] = CharacterShamone : return
          if temp3 = 0 then return
          goto HUIEB_ExecuteJump
HUIEB_StandardEnhancedCheck
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II
          if temp3 = 0 then return
HUIEB_ExecuteJump
          rem Execute jump if pressed and not already jumping
          rem Allow Zoe Ryen a single mid-air double-jump
          if playerCharacter[temp1] = CharacterZoeRyen then goto HUIEB_ZoeJumpCheck
          if (playerState[temp1] & 4) then return
          rem Already jumping, cannot jump again
          goto HUIEB_JumpProceed
HUIEB_ZoeJumpCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then return
          rem Zoe already used double-jump
HUIEB_JumpProceed
          rem Use cached animation state - block jump during attack animations (states 13-15)
          if temp2 >= 13 then return
          rem Block jump during attack windup/execute/recovery
          let temp4 = playerCharacter[temp1]
          rem Dispatch character jump (inlined for performance)
          if temp4 >= 32 then goto HUIEB_JumpDone
          if temp4 >= 16 && temp4 <= 30 then goto StandardJump
          if temp4 = CharacterMethHound then goto ShamoneJump
          on temp4 goto BernieJump StandardJump DragonOfStormsJump ZoeRyenJump FatTonyJump StandardJump HarpyJump KnightGuyJump FrootyJump StandardJump NinjishGuyJump PorkChopJump RadishGoblinJump RoboTitoJump UrsuloJump ShamoneJump
HUIEB_JumpDone
          rem Set Zoe Ryen double-jump flag if applicable
          if playerCharacter[temp1] = CharacterZoeRyen then if temp6 = 1 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
          return

HandleStandardHorizontalMovement
          rem Unified handler for standard horizontal movement
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0left/joy0right for players 0,2; joy1left/joy1right for players 1,3
          rem
          rem OUTPUT: playerVelocityX[temp1] and playerVelocityXL[temp1] updated,
          rem playerState[temp1] facing bit updated
          rem
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 = 0 then goto HSHM_UseJoy0
          if temp1 = 2 then goto HSHM_UseJoy0
          rem Players 1,3 use joy1
          if !joy1left then goto HSHM_CheckRight
          goto HSHM_HandleLeft
HSHM_UseJoy0
          rem Players 0,2 use joy0
          if !joy0left then goto HSHM_CheckRight
HSHM_HandleLeft
          rem Left movement: set negative velocity
          if playerCharacter[temp1] = CharacterFrooty then goto HSHM_LeftMomentum
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let temp2 = 0
          let temp2 = temp2 - temp6
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          goto HSHM_AfterLeftSet
HSHM_LeftMomentum
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
HSHM_AfterLeftSet
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto HSHM_SPF_Yes1
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto HSHM_SPF_No1
          if temp2 > 9 then goto HSHM_SPF_No1
HSHM_SPF_Yes1
          let temp3 = 1
          goto HSHM_SPF_Done1
HSHM_SPF_No1
          let temp3 = 0
HSHM_SPF_Done1
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
HSHM_CheckRight
          rem Determine which joy port to use for right movement
          if temp1 = 0 then goto HSHM_CheckRightJoy0
          if temp1 = 2 then goto HSHM_CheckRightJoy0
          rem Players 1,3 use joy1
          if !joy1right then return
          goto HSHM_HandleRight
HSHM_CheckRightJoy0
          rem Players 0,2 use joy0
          if !joy0right then return
HSHM_HandleRight
          rem Right movement: set positive velocity
          if playerCharacter[temp1] = CharacterFrooty then goto HSHM_RightMomentum
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = temp6
          let playerVelocityXL[temp1] = 0
          goto HSHM_AfterRightSet
HSHM_RightMomentum
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
HSHM_AfterRightSet
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto HSHM_SPF_Yes2
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto HSHM_SPF_No2
          if temp2 > 9 then goto HSHM_SPF_No2
HSHM_SPF_Yes2
          let temp3 = 1
          goto HSHM_SPF_Done2
HSHM_SPF_No2
          let temp3 = 0
HSHM_SPF_Done2
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
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
          if temp1 & 2 = 0 then goto HFCM_UseJoy0
          rem Players 1,3 use joy1
          if joy1left then goto HFCM_CheckLeftCollision
          goto HFCM_CheckRightMovement
HFCM_UseJoy0
          rem Players 0,2 use joy0
          if joy0left then goto HFCM_CheckLeftCollision
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
          if temp1 = 0 then goto HFCM_CheckRightJoy0
          if temp1 = 2 then goto HFCM_CheckRightJoy0
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
          if temp1 & 2 = 0 then goto HFCM_VertJoy0
          if joy1up then goto HFCM_VertUp
          if joy1down then goto HFCM_VertDown
          return
HFCM_VertJoy0
          if joy0up then goto HFCM_VertUp
          if joy0down then goto HFCM_VertDown
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

          rem Standard horizontal movement (modifies velocity, not position)
          gosub HandleStandardHorizontalMovement
DoneLeftPortMovement
IHLP_FlyingMovement
          gosub HandleFlyingCharacterMovement bank12
IHLP_DoneFlyingLeftRight

          rem Process UP input and enhanced button (Button II)
          rem temp2 already contains cached animation state from GetPlayerAnimationStateFunction
          gosub HandleUpInputAndEnhancedButton

          rem Process down/guard input (inlined for performance)
          rem Frooty cannot guard
          if playerCharacter[temp1] = CharacterFrooty then goto HGI_Done1
          rem Players 0,2 use joy0; Players 1,3 use joy1
          if temp1 = 0 then goto HGI_CheckJoy0_1
          if temp1 = 2 then goto HGI_CheckJoy0_1
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
          if temp4 = CharacterDragonOfStorms then goto DragonOfStormsDown
          if temp4 = CharacterHarpy then goto HarpyDown
          if temp4 = CharacterFrooty then goto FrootyDown
          if temp4 = CharacterRoboTito then goto DCD_HandleRoboTitoDown1
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
          if temp2 >= 13 then goto InputDoneLeftPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = playerState[temp1] & 2
          rem Check if player is guarding - guard blocks attacks
          if temp2 then goto InputDoneLeftPortAttack
          rem Guarding - block attack input
          if !joy0fire then goto InputDoneLeftPortAttack
          if (playerState[temp1] & PlayerStateBitFacing) then goto InputDoneLeftPortAttack
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

          rem Frooty and Dragon of Storms need collision checks
          let temp5 = playerCharacter[temp1]
          rem   for horizontal movement
          rem Use goto to avoid branch out of range (target is 302+ bytes away)
          if temp5 = CharacterFrooty then goto IHRP_FlyingMovement
          if temp5 = CharacterDragonOfStorms then goto IHRP_FlyingMovement

          rem Standard horizontal movement (no collision check)
          gosub HandleStandardHorizontalMovement
DoneRightPortMovement
IHRP_FlyingMovement
          gosub HandleFlyingCharacterMovement bank12
IHRP_DoneFlyingLeftRight


          rem Process UP input and enhanced button (Button II)
          rem temp2 already contains cached animation state from GetPlayerAnimationStateFunction
          gosub HandleUpInputAndEnhancedButton
          rem Process down/guard input (inlined for performance)
          rem Frooty cannot guard
          if playerCharacter[temp1] = CharacterFrooty then goto HGI_Done2
          rem Players 0,2 use joy0; Players 1,3 use joy1
          if temp1 = 0 then goto HGI_CheckJoy0_2
          if temp1 = 2 then goto HGI_CheckJoy0_2
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
          if temp4 = CharacterDragonOfStorms then goto DragonOfStormsDown
          if temp4 = CharacterHarpy then goto HarpyDown
          if temp4 = CharacterFrooty then goto FrootyDown
          if temp4 = CharacterRoboTito then goto DCD_HandleRoboTitoDown2
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
          if temp2 >= 13 then goto InputDoneRightPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = playerState[temp1] & 2 PlayerStateBitGuarding
          if temp2 then goto InputDoneRightPortAttack
          rem Guarding - block attack input
          if !joy1fire then goto InputDoneRightPortAttack
          if (playerState[temp1] & PlayerStateBitFacing) then goto InputDoneRightPortAttack
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterAttack bank7
InputDoneRightPortAttack
          return

HandlePauseInput
          rem
          rem Pause Button Handling With Debouncing
          rem Handles SELECT switch and Joy2b+ Button III with proper
          rem   debouncing
          rem Uses SystemFlagPauseButtonPrev bit in systemFlags for debouncing
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
          if temp1 = 0 then goto DonePauseToggle
          if systemFlags & SystemFlagPauseButtonPrev then goto DonePauseToggle
          rem Toggle pause flag in systemFlags
          if systemFlags & SystemFlagGameStatePaused then systemFlags = systemFlags & ClearSystemFlagGameStatePaused else systemFlags = systemFlags | SystemFlagGameStatePaused
DonePauseToggle
          rem Toggle pause (0<->1)


          rem Update pause button previous state in systemFlags
          if temp1 then systemFlags = systemFlags | SystemFlagPauseButtonPrev else systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev
          rem Update previous button state for next frame

          return

          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC
          rem   ROUTINES
          rem The original InputHandlePlayer1, HandlePlayer2Input,
          rem   HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into
          rem   HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

