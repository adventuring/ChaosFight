GetPlayerAnimationStateFunction:
          ;; Returns: Far (return otherbank)




          ;;
          ;; ChaosFight - Source/Routines/PlayerInput.bas

          ;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Player Input Handling

          ;; All input handling for the four players, with

          ;; character-specific

          ;; control logic dispatched to character-specific

          ;; subroutines.

          ;; QUADTARI MULTIPLEXING:

          ;; Even frames (qtcontroller=0): joy0=Player1, joy1=Player2

          ;; Odd frames (qtcontroller=1): joy0=Player3, joy1=Player4

          ;; AVAILABLE VARIABLES (from Variables.bas):

          ;; playerX[0-3] - X positions

          ;; playerY[0-3] - Y positions

          ;; playerState[0-3] - State flags (attacking, guarding,

          ;; jumping, etc.)

          ;; playerCharacter[0-3] - Character type indices (0-MaxCharacter)

          ;; playerVelocityX[0-3] - Horizontal velocity (8.8

          ;; fixed-point)

          ;; playerVelocityXL[0-3] - Horizontal velocity fractional

          ;; part

          ;; controllerStatus - Packed controller detection sta


          ;; qtcontroller - Multiplexing state (0=P1/P2, 1=P3/P4)

          ;; STATE FLAGS (in playerState):

          ;; bit 0: Facing (1 = right, 0 = left)

          ;; bit 1: Guarding

          ;; bit 2: Jumping

          ;; bit 3: Recovery (disabled during hitstun)

          ;; Bits 4-7: Animation sta


          ;; CHARACTER INDICES (0-MaxCharacter):

          ;; 0=Bernie, 1=Curler, 2=Dragon of Storms, 3=ZoeRyen,

          ;; 4=FatTony, 5=Megax,

          ;;
          ;; 6=Harpy, 7=KnightGuy, 8=Frooty, 9=Nefertem, 10=NinjishGuy,

          ;; 11=PorkChop, 12=RadishGoblin, 13=RoboTito, 14=Ursulo,

          ;; 15=Shamone

          ;; Animation State Helper

          ;; Input: temp1 = player index (0-3), playerState[]

          ;; Output: temp2 = animation state (bits 4-7 of playerState)

          ;; Set temp2 = playerState[temp1] & 240         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Mask bits 4-7 (value 240 = %11110000)

          ;; Set temp2 = temp2 / 16
          ;; Shift right by 4 (divide by 16) to get animation sta


          ;; (0-15)
          jmp BS_return




InputHandleAllPlayers .proc




          ;; Main input handler for all players

          ;; Main input handler for all players with Quadtari

          ;; multiplexing

          ;;
          ;; Input: qtcontroller (global) = multiplexing sta


          ;; (0=P1/P2, 1=P3/P4)

          ;; controllerStatus (global) = controller detection

          ;; sta


          ;; playerCharacter[] (global array) = character selections

          ;; playerState[] (global array) = player state flags

          ;;
          ;; Output: Input processed for active players, qtcontroller

          ;; toggled

          ;;
          ;; Mutates: temp1, temp2 (used for calculations),

          ;; currentPlayer (set to 0-3),

          ;; qtcontroller (toggled between 0 and 1)

          ;;
          ;; Called Routines: (IsPlayerAlive inlined) - checks if player is

          ;; alive (returns health in temp2),

          ;; InputHandleLeftPortPlayerFunction (bank8, same-bank),

          ;; InputHandleRightPortPlayerFunction (bank8, same-bank) -

          ;; handle input for left/right port players

          ;;
          ;; Constraints: Must be colocated with InputSkipPlayer0Input,

          ;; InputSkipPlayer1Input,

          ;; InputHandlePlayer1,

          ;; InputHandleQuadtariPlayers,

          ;; InputSkipPlayer3Input,

          ;; InputSkipPlayer4Input (all called via jmp or gosub)

          ;; If qtcontroller, then jmp InputHandleQuadtariPlayers
          lda qtcontroller
          beq HandlePlayers12
          jmp InputHandleQuadtariPlayers
HandlePlayers12:



          ;; Even frame: Handle Players 1 & 2 - only if alive

          ;; Inlined IsPlayerAlive check for player 0
          lda # 0
          asl
          tax
          lda playerHealth,x
          sta temp2
          lda temp2
          cmp # 0
          bne CheckPlayer0State
          jmp InputDonePlayer0Input
CheckPlayer0State:

          ;; If (playerState[0] & 8), then jmp InputDonePlayer0Input
          lda # 0
          asl
          tax
          lda playerState,x
          and # 8
          beq InputDonePlayer0InputSkip
          jmp InputDonePlayer0Input
InputDonePlayer0InputSkip:
          ;; Set temp1 = 0
          lda # 0
          sta temp1 : cross-bank call to InputHandleLeftPortPlayerFunction



InputDonePlayer0Input

          ;; Skip Player 0 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with InputHandleAllPlayers



          ;; Inlined IsPlayerAlive check for player 1
          lda # 1
          asl
          tax
          lda playerHealth,x
          sta temp2
          lda temp2
          cmp # 0
          bne CheckPlayer1State
          jmp InputDonePlayer1Input
CheckPlayer1State:
          ;; If (playerState[1] & 8), then jmp InputDonePlayer1Input
          lda # 1
          asl
          tax
          lda playerState,x
          and # 8
          beq InputDonePlayer1InputSkip
          jmp InputDonePlayer1Input
InputDonePlayer1InputSkip:
          jmp InputHandlePlayer1



          jmp InputDonePlayer1Input



.pend

InputHandlePlayer1 .proc

          ;; Handle Player 1 input (right port)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 (set to 1), playerState[] (global array)

          ;;
          ;; Output: Player 1 input processed

          ;;
          ;; Mutates: temp1 (set to 1), player state (via

          ;; InputHandleRightPortPlayerFunction)

          ;;
          ;; Called Routines: InputHandleRightPortPlayerFunction - handles

          ;; right port player input

          ;; Constraints: Must be colocated with InputHandleAllPlayers, InputSkipPlayer1Input

          lda # 1
          sta temp1

          jsr InputHandleRightPortPlayerFunction

InputDonePlayer1Input

          ;; Player 1 uses Joy1
          ;; Returns: Far (return otherbank)

          jmp BS_return

.pend

InputHandleQuadtariPlayers .proc

          ;; Skip Player 1 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with InputHandleAllPlayers

          ;; Odd frame: Handle Players 3 & 4 (if Quadtari detected and

          ;; alive)

          ;;
          ;; Input: controllerStatus (global), playerCharacter[] (global array),

          ;; playerState[] (global array)

          ;;
          ;; Output: Input processed for Players 3 & 4 if conditions

          ;; met, qtcontroller reset to 0

          ;;
          ;; Mutates: temp1, temp2 (used for calculations),

          ;; currentPlayer (set to 2-3),

          ;; qtcontroller (reset to 0)

          ;;
          ;; Called Routines: (IsPlayerAlive inlined) - checks if player is

          ;; alive (returns health in temp2),

          ;; InputHandleLeftPortPlayerFunction (bank8, same-bank),

          ;; InputHandleRightPortPlayerFunction (bank8, same-bank) -

          ;; handle input for left/right port players

          ;;
          ;; Constraints: Must be colocated with InputHandleAllPlayers,

          ;; InputSkipPlayer3Input,

          ;; InputSkipPlayer4Input

          ;; Odd frame: Handle Players 3 & 4 (if Quadtari detected and

          ;; alive)

          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer3Character

          jmp InputDonePlayer3Input

CheckPlayer3Character:


          ;; If playerCharacter[2] = NoCharacter, then jmp InputDonePlayer3Input

          ;; Inlined IsPlayerAlive check for player 2
          lda # 2
          asl
          tax
          lda playerHealth,x
          sta temp2
          lda temp2
          cmp # 0
          bne CheckPlayer3State
          jmp InputDonePlayer3Input
CheckPlayer3State:
          ;; If (playerState[2] & 8), then jmp InputDonePlayer3Input
          lda # 2
          asl
          tax
          lda playerState,x
          and # 8
          beq InputDonePlayer3InputSkip
          jmp InputDonePlayer3Input
InputDonePlayer3InputSkip:
          ;; Set temp1 = 2
          lda # 2
          sta temp1 : cross-bank call to InputHandleLeftPortPlayerFunction



InputDonePlayer3Input

          ;; Skip Player 3 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with InputHandleQuadtariPlayers
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer4Character

          jmp InputDonePlayer4Input

CheckPlayer4Character:


          ;; If playerCharacter[3] = NoCharacter, then jmp InputDonePlayer4Input

          ;; Inlined IsPlayerAlive check for player 3
          lda # 3
          asl
          tax
          lda playerHealth,x
          sta temp2
          lda temp2
          cmp # 0
          bne CheckPlayer4State
          jmp InputDonePlayer4Input
CheckPlayer4State:


                    if (playerState[3] & 8) then jmp InputDonePlayer4Input

          ;; Set temp1 = 3
          lda # 3
          sta temp1 : cross-bank call to InputHandleRightPortPlayerFunction



InputDonePlayer4Input

          ;; Skip Player 4 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with

          ;; InputHandleQuadtariPlayers





          ;; Switch back to even frame

          qtcontroller = 0
          jmp BS_return



.pend

HandleGuardInput .proc




          ;;
          ;; Shared Guard Input Handling

          ;; Handles down/guard input for both ports

          ;;
          ;; INPUT: temp1 = player index (0-3)

          ;; Uses: joy0down for players 0,2; joy1down for players 1,3

          ;; Determine which joy port to use based on player index

          ;; Frooty cannot guard

          ;; Players 0,2 use joy0; Players 1,3 use joy1

          jmp BS_return

          lda temp1
          cmp # 0
          bne CheckPlayer2Joy
          jmp HandleGuardInputCheckJoy0
CheckPlayer2Joy:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne CheckJoy1
          jmp HandleGuardInputCheckJoy0
CheckJoy1:


          lda joy1down
          bne HandleGuardInputHandleDownPressedJoy1
          jmp HandleGuardInputCheckGuardRelease
HandleGuardInputHandleDownPressedJoy1:


          jmp HandleGuardInputHandleDownPressed

.pend

HandleGuardInputCheckJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          lda joy0down
          bne HandleGuardInputHandleDownPressedJoy0
          jmp HandleGuardInputCheckGuardRelease
HandleGuardInputHandleDownPressedJoy0:


.pend

HandleGuardInputHandleDownPressed .proc

          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)

          ;; Set temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          jmp BS_return

          lda temp4
          cmp CharacterDragonOfStorms
          bne CheckHarpy
          jmp DragonOfStormsDown
CheckHarpy:


          lda temp4
          cmp CharacterHarpy
          bne CheckFrooty
          jmp HarpyDown
CheckFrooty:


          lda temp4
          cmp CharacterFrooty
          bne CheckRoboTito
          jmp FrootyDown
CheckRoboTito:


          lda temp4
          cmp CharacterRoboTito
          bne UseStandardGuard
          jmp DCD_HandleRoboTitoDown
UseStandardGuard:


          jmp StandardGuard

.pend

DCD_HandleRoboTitoDown .proc

          ;; Cross-bank call to RoboTitoDown in bank 13
          lda # >(AfterRoboTitoDownInput-1)
          pha
          lda # <(AfterRoboTitoDownInput-1)
          pha
          lda # >(RoboTitoDown-1)
          pha
          lda # <(RoboTitoDown-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterRoboTitoDownInput:


          rts

          jmp StandardGuard

.pend

HandleGuardInputCheckGuardRelease .proc

          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)

          ;; Set temp2 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Not guarding, nothing to do

          jmp BS_return

          ;; Stop guard early and start cooldown
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitGuarding)
          sta playerState,x

          ;; Start cooldown timer
          lda temp1
          asl
          tax
          lda GuardTimerMaxFrames
          sta playerTimers_W,x

          jmp BS_return



HandleUpInputAndEnhancedButton

          ;; Unified handler for UP input and enhanced button (Button II) handling
          ;; Returns: Far (return thisbank)

          ;;
          ;; INPUT: temp1 = player index (0-3), temp2 = cached animation sta


          ;; Uses: joy0up/joy0down for players 0,2; joy1up/joy1down for players 1,3

          ;; CheckEnhancedJumpButton for enhanced button sta


          ;;
          ;; OUTPUT: temp3 = jump pressed flag (1=yes, 0=no)

          ;; Character-specific behaviors executed (form switch, fall-through, etc.)

          ;; Jump executed if conditions met

          ;;
          ;; Determine which joy port to use based on player index

          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          lda temp1
          cmp # 0
          bne CheckPlayer2JoyPort
          jmp HandleUpInputEnhancedButtonUseJoy0
CheckPlayer2JoyPort:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne CheckJoy1Up
          jmp HandleUpInputEnhancedButtonUseJoy0
CheckJoy1Up:


          lda joy1up
          bne HandleUpInputEnhancedButtonHandleUpJoy1
          jmp HandleUpInputEnhancedButtonCheckEnhanced
HandleUpInputEnhancedButtonHandleUpJoy1:


          jmp HandleUpInputEnhancedButtonHandleUp

.pend

HandleUpInputEnhancedButtonUseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          lda joy0up
          bne HandleUpInputEnhancedButtonHandleUpJoy0
          jmp HandleUpInputEnhancedButtonCheckEnhanced
HandleUpInputEnhancedButtonHandleUpJoy0:


.pend

HandleUpInputEnhancedButtonHandleUp .proc

          ;; Check Shamone form switching first (Shamone <-> MethHound)
          ;; Returns: Far (return otherbank)

          ;; Switch Shamone -> MethHound

          jmp BS_return

          ;; Switch MethHound -> Shamone

          jmp BS_return

          ;; Robo Tito: Hold UP to ascend; auto-latch on ceiling contact

          ;; Check Bernie fall-through

          ;; If playerCharacter[temp1] = CharacterRoboTito then jmp HandleUpInputEnhancedButtonRoboTitoAscend

          ;; Check Harpy flap

          ;; if playerCharacter[temp1] = CharacterBernie, then jmp HandleUpInputEnhancedButtonBernieFallThrough
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterBernie
          bne CheckHarpyFlap
          jmp HandleUpInputEnhancedButtonBernieFallThrough
CheckHarpyFlap:

          ;; For all other characters, UP is jump

          ;; If playerCharacter[temp1] = CharacterHarpy, then jmp HandleUpInputEnhancedButtonHarpyFlap
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterHarpy
          bne HandleUpInputEnhancedButtonStandardJump
          jmp HandleUpInputEnhancedButtonHarpyFlap
HandleUpInputEnhancedButtonStandardJump:
          lda # 1
          sta temp3

          jmp HandleUpInputEnhancedButtonCheckEnhanced

HandleUpInputEnhancedButtonRoboTitoAscend

          ;; Ascend toward ceiling
          ;; Returns: Far (return otherbank)

          ;; Save cached animation state (temp2) - will be restored after playfield read

          lda temp2
          sta temp5

                    ;; Set temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6

          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

          ;; Compute playfield column
          ;; Set playerY[temp1] = playerY[temp1] - temp6
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc temp6
          sta playerY,x

          ;; Set temp4 = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp4

          ;; Set temp4 = temp4 - ScreenInsetX          lda temp4          sec          sbc ScreenInsetX          sta temp4
          lda temp4
          sec
          sbc ScreenInsetX
          sta temp4

          lda temp4
          sec
          sbc ScreenInsetX
          sta temp4



            lsr temp4

            lsr temp4


          lda temp4
          cmp # 32
          bcc ColumnInRange
          lda # 31
          sta temp4
ColumnInRange:


          ;; Compute head row and check ceiling contact

                    if temp4 & $80 then let temp4 = 0

          ;; Set temp3 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3


            lsr temp3

            lsr temp3

            lsr temp3

            lsr temp3


          lda temp3
          cmp # 0
          bne CheckCeilingPixel
          jmp HandleUpInputEnhancedButtonRoboTitoLatch
CheckCeilingPixel:


          dec temp3

          lda temp1
          sta currentPlayer

          lda temp4
          sta temp1

          lda temp3
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadRestoreAnimation-1)
          pha
          lda # <(AfterPlayfieldReadRestoreAnimation-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadRestoreAnimation:


          ;; Restore cached animation sta


          lda currentPlayer
          sta temp1

          lda temp5
          sta temp2

          ;; Clear latch if DOWN pressed (check appropriate joy port)

          ;; If temp1, then jmp HandleUpInputEnhancedButtonRoboTitoLatch
          lda temp1
          beq HandleUpInputEnhancedButtonRoboTitoLatch
          jmp HandleUpInputEnhancedButtonRoboTitoLatch
HandleUpInputEnhancedButtonRoboTitoLatch:

          lda temp1
          cmp # 0
          bne CheckPlayer2JoyPortRoboTito
          jmp HandleUpInputEnhancedButtonRoboTitoCheckJoy0
CheckPlayer2JoyPortRoboTito:


          lda temp1
          cmp # 2
          bne CheckJoy1Down
          jmp HandleUpInputEnhancedButtonRoboTitoCheckJoy0
CheckJoy1Down:


                    if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)          lda joy1down          beq HandleUpInputEnhancedButtonRoboTitoDoneJoy1
HandleUpInputEnhancedButtonRoboTitoDoneJoy1:
          jmp HandleUpInputEnhancedButtonRoboTitoDoneJoy1
          jmp HandleUpInputEnhancedButtonRoboTitoDoneJoy1

.pend

HandleUpInputEnhancedButtonRoboTitoCheckJoy0 .proc

                    if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)          lda joy0down          beq HandleUpInputEnhancedButtonRoboTitoDoneJoy0
HandleUpInputEnhancedButtonRoboTitoDoneJoy0:
          jmp HandleUpInputEnhancedButtonRoboTitoDoneJoy0

HandleUpInputEnhancedButtonRoboTitoDoneJoy0Label:
          lda # 0
          sta temp3

          rts

.pend

HandleUpInputEnhancedButtonRoboTitoLatch .proc

          ;; Restore cached animation sta

          ;; Returns: Far (return otherbank)

          lda temp5
          sta temp2

          ;; Set characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          ora # 1
          sta characterStateFlags_W,x
          lda # 0
          sta temp3

          jmp BS_return

.pend

HandleUpInputEnhancedButtonBernieFallThrough .proc

          ;; Bernie UP input handled in BernieJump routine (fall through 1-row floors)
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to BernieJump in bank 12
          lda # >(AfterBernieJumpInput-1)
          pha
          lda # <(AfterBernieJumpInput-1)
          pha
          lda # >(BernieJump-1)
          pha
          lda # <(BernieJump-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterBernieJumpInput:


          lda # 0
          sta temp3

          jmp BS_return

.pend

HandleUpInputEnhancedButtonHarpyFlap .proc

          ;; Harpy UP input handled in HarpyJump routine (flap to fly)
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to HarpyJump in bank 12
          lda # >(AfterHarpyJumpInput-1)
          pha
          lda # <(AfterHarpyJumpInput-1)
          pha
          lda # >(HarpyJump-1)
          pha
          lda # <(HarpyJump-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterHarpyJumpInput:


          lda # 0
          sta temp3

          jmp BS_return

.pend

HandleUpInputEnhancedButtonCheckEnhanced .proc

          ;; Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          ;; Returns: Far (return otherbank)

          ;; Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only

          ;; Note: For Bernie, UP is fall-through, so jump via enhanced buttons only

          ;; Note: For Harpy, UP is flap, so jump via enhanced buttons only

          ;; If playerCharacter[temp1] = CharacterShamone then jmp HandleUpInputEnhancedButtonEnhancedCheck

          ;; if playerCharacter[temp1] = CharacterMethHound, then jmp HandleUpInputEnhancedButtonEnhancedCheck
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterMethHound
          bne CheckBernie
          jmp HandleUpInputEnhancedButtonEnhancedCheck
CheckBernie:

          ;; If playerCharacter[temp1] = CharacterBernie, then jmp HandleUpInputEnhancedButtonEnhancedCheck
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterBernie
          bne CheckHarpyEnhanced
          jmp HandleUpInputEnhancedButtonEnhancedCheck
CheckHarpyEnhanced:

          ;; Bernie and Harpy also use enhanced buttons for jump

          ;; If playerCharacter[temp1] = CharacterHarpy, then jmp HandleUpInputEnhancedButtonEnhancedCheck
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterHarpy
          bne HandleUpInputEnhancedButtonStandardEnhancedCheck
          jmp HandleUpInputEnhancedButtonEnhancedCheck
HandleUpInputEnhancedButtonStandardEnhancedCheck:
          jmp HandleUpInputEnhancedButtonStandardEnhancedCheck

.pend

HandleUpInputEnhancedButtonEnhancedCheck .proc

          ;; Check Genesis/Joy2b+ Button C/II for alternative UP for any characters
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to CheckEnhancedJumpButton in bank 10
          lda # >(AfterCheckEnhancedJumpButtonEnhanced-1)
          pha
          lda # <(AfterCheckEnhancedJumpButtonEnhanced-1)
          pha
          lda # >(CheckEnhancedJumpButton-1)
          pha
          lda # <(CheckEnhancedJumpButton-1)
          pha
                    ldx # 9
          jmp BS_jsr
AfterCheckEnhancedJumpButtonEnhanced:


          ;; For Shamone/Meth Hound, treat enhanced button as UP (toggle forms)

          jmp BS_return

          jmp BS_return

          jmp BS_return

          jmp HandleUpInputEnhancedButtonExecuteJump

.pend

HandleUpInputEnhancedButtonStandardEnhancedCheck .proc

          ;; Check Genesis/Joy2b+ Button C/II
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to CheckEnhancedJumpButton in bank 10
          lda # >(AfterCheckEnhancedJumpButtonCheck-1)
          pha
          lda # <(AfterCheckEnhancedJumpButtonCheck-1)
          pha
          lda # >(CheckEnhancedJumpButton-1)
          pha
          lda # <(CheckEnhancedJumpButton-1)
          pha
                    ldx # 9
          jmp BS_jsr
AfterCheckEnhancedJumpButtonCheck:


          jmp BS_return

.pend

HandleUpInputEnhancedButtonExecuteJump .proc

          ;; Execute jump if pressed and not already jumping
          ;; Returns: Far (return otherbank)

          ;; Allow Zoe Ryen a single mid-air double-jump

          ;; If playerCharacter[temp1] = CharacterZoeRyen, then jmp HandleUpInputEnhancedButtonZoeJumpCheck

          ;; Already jumping, cannot jump again
          jmp BS_return

          jmp HandleUpInputEnhancedButtonJumpProceed

.pend

HandleUpInputEnhancedButtonZoeJumpCheck .proc

          lda # 0
          sta temp6

                    if (playerState[temp1] & 4), set temp6 = 1

          ;; Zoe already used double-jump

          rts

.pend

HandleUpInputEnhancedButtonJumpProceed .proc

          ;; Use cached animation state - block jump during attack animations (states 13-15)
          ;; Returns: Far (return otherbank)

          ;; Block jump during attack windup/execute/recovery
          jmp BS_return

          ;; Dispatch character jump via dispatcher (same-bank call)

          ;; Set temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          jsr DispatchCharacterJump

HandleUpInputEnhancedButtonJumpDoneLabel:

          ;; Set Zoe Ryen double-jump flag if applicable
          ;; Returns: Far (return otherbank)
          lda temp6
          cmp # 1
          bne HandleUpInputEnhancedButtonJumpDoneCheck
          ;; Set characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          ora # 8
          sta characterStateFlags_W,x
HandleUpInputEnhancedButtonJumpDoneCheck:

          jmp BS_return



HandleStandardHorizontalMovement

          ;; Unified handler for standard horizontal movement
          ;; Returns: Far (return thisbank)

          ;;
          ;; INPUT: temp1 = player index (0-3)

          ;; Uses: joy0left/joy0right for players 0,2; joy1left/joy1right for players 1,3

          ;;
          ;; OUTPUT: playerVelocityX[temp1] and playerVelocityXL[temp1] updated,

          ;; playerState[temp1] facing bit updated

          ;;
          ;; Determine which joy port to use based on player index

          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          lda temp1
          cmp # 0
          bne CheckPlayer2JoyPortHSHM
          jmp HSHM_UseJoy0
CheckPlayer2JoyPortHSHM:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne CheckJoy1Left
          jmp HSHM_UseJoy0
CheckJoy1Left:


          lda joy1left
          bne HSHM_HandleLeft
          jmp HSHM_CheckRight
HSHM_HandleLeft:


          jmp HSHM_HandleLeft

.pend

HSHM_UseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          lda joy0left
          bne HSHM_HandleLeftJoy0
          jmp HSHM_CheckRight
HSHM_HandleLeftJoy0:


.pend

HSHM_HandleLeft .proc

          ;; Left movement: set negative velocity
          ;; Returns: Far (return otherbank)

          ;; If playerCharacter[temp1] = CharacterFrooty then jmp HSHM_LeftMomentum

          ;; if playerCharacter[temp1] = CharacterDragonOfStorms, then jmp HSHM_LeftDirectSubpixel
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterDragonOfStorms
          bne HSHM_LeftStandard
          jmp HSHM_LeftDirectSubpixel
HSHM_LeftStandard:

                    ;; Set temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6

          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

          lda # 0
          sta temp2

          ;; Set temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
          lda temp2
          sec
          sbc temp6
          sta temp2

          lda temp2
          sec
          sbc temp6
          sta temp2


          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityX,x

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          jmp HSHM_AfterLeftSet

.pend

HSHM_LeftDirectSubpixel .proc

          ;; Dragon of Storms: direct velocity with subpixel accuracy
          ;; Returns: Far (return otherbank)

                    ;; Set temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6

          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

          lda # 0
          sta temp2

          ;; Set temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
          lda temp2
          sec
          sbc temp6
          sta temp2

          lda temp2
          sec
          sbc temp6
          sta temp2


          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityX,x

          lda temp1
          asl
          tax
          lda 1
          sta playerVelocityXL,x

          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy

          jmp HSHM_AfterLeftSet

.pend

HSHM_LeftMomentum .proc

                    ;; Set temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6

          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

                    let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

.pend

HSHM_AfterLeftSet .proc

          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
          ;; If (playerState[temp1] & 8), then jmp HSHM_SPF_Yes1
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq HSHM_SPF_No1
          jmp HSHM_SPF_Yes1
HSHM_SPF_No1:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateAfterLeftSet-1)
          pha
          lda # <(AfterGetPlayerAnimationStateAfterLeftSet-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateAfterLeftSet:


          ;; If temp2 < 5, then jmp HSHM_SPF_No1          lda temp2          cmp 5          bcs .skip_1803          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10
          goto_label:

          jmp HSHM_SPF_No1
CheckAnimationState10:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10Label
          jmp HSHM_SPF_No1
CheckAnimationState10Label:

          

          lda temp2
          cmp # 10
          bcc HSHM_SPF_No1
          jmp HSHM_SPF_Yes1
HSHM_SPF_No1:


.pend

HSHM_SPF_Yes1 .proc

          lda # 1
          sta temp3

          jmp HSHM_SPF_Done1

.pend

HSHM_SPF_No1 .proc

          lda # 0
          sta temp3

HSHM_SPF_Done1

          lda temp3
          bne HSHM_AfterLeftSetDone
                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
HSHM_AfterLeftSetDone:


.pend

HSHM_CheckRight .proc

          ;; Determine which joy port to use for right movement
          ;; Returns: Far (return otherbank)
          lda temp1
          cmp # 0
          bne CheckPlayer2JoyPortRight
          jmp HSHM_CheckRightJoy0
CheckPlayer2JoyPortRight:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne HSHM_HandleRight
          jmp HSHM_CheckRightJoy0
HSHM_HandleRight:


          jmp BS_return

          jmp HSHM_HandleRight

.pend

HSHM_CheckRightJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          jmp BS_return

.pend

HSHM_HandleRight .proc

          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)

          ;; If playerCharacter[temp1] = CharacterFrooty then jmp HSHM_RightMomentum

          ;; if playerCharacter[temp1] = CharacterDragonOfStorms, then jmp HSHM_RightDirectSubpixel
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterDragonOfStorms
          bne HSHM_RightStandard
          jmp HSHM_RightDirectSubpixel
HSHM_RightStandard:

                    ;; Set temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6

          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

          lda temp1
          asl
          tax
          lda temp6
          sta playerVelocityX,x

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          jmp HSHM_AfterRightSet

.pend

HSHM_RightDirectSubpixel .proc

          ;; Dragon of Storms: direct velocity with subpixel accuracy
          ;; Returns: Far (return otherbank)

                    ;; Set temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6

          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

          lda temp1
          asl
          tax
          lda temp6
          sta playerVelocityX,x

          lda temp1
          asl
          tax
          lda 1
          sta playerVelocityXL,x

          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy

          jmp HSHM_AfterRightSet

.pend

HSHM_RightMomentum .proc

                    ;; Set temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6

          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          clc
          adc temp6
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

.pend

HSHM_AfterRightSet .proc

          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)

                    if (playerState[temp1] & 8) then jmp HSHM_SPF_Yes2

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateAfterRightSet-1)
          pha
          lda # <(AfterGetPlayerAnimationStateAfterRightSet-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateAfterRightSet:


          ;; If temp2 < 5, then jmp HSHM_SPF_No2          lda temp2          cmp 5          bcs .skip_6914          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right
          jmp HSHM_SPF_No2
CheckAnimationState10Right:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightLabel
          jmp HSHM_SPF_No2
CheckAnimationState10RightLabel:

          

          lda temp2
          cmp # 10
          bcc HSHM_SPF_No2
          jmp HSHM_SPF_Yes2
HSHM_SPF_No2:


.pend

HSHM_SPF_Yes2 .proc

          lda # 1
          sta temp3

          jmp HSHM_SPF_Done2

.pend

HSHM_SPF_No2 .proc

          lda # 0
          sta temp3

HSHM_SPF_Done2

          lda temp3
          bne HSHM_AfterRightSetDone
                    let playerState[temp1] = playerState[temp1] | 1
HSHM_AfterRightSetDone:


          rts



.pend

HandleFlyingCharacterMovement .proc




          ;;
          ;; Shared Flying Character Movement

          ;; Handles horizontal movement with collision for flying

          ;; characters (Frooty, Dragon of Storms)

          ;;
          ;; INPUT: temp1 = player index (0-3)

          ;; Uses: joy0left/joy0right for players 0,2;

          ;; joy1left/joy1right

          ;; for players 1,3

          ;; Determine which joy port to use based on player index

          ;; Set temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5

          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          ;; Players 1,3 use joy1

          ;; If temp1 & 2 = 0 then jmp HFCM_UseJoy0

          ;; if joy1left, then jmp HFCM_CheckLeftCollision
          lda joy1left
          beq HFCM_CheckRightMovement
          jmp HFCM_CheckLeftCollision
HFCM_CheckRightMovement:

          jmp HFCM_CheckRightMovement

.pend

HFCM_UseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; If joy0left, then jmp HFCM_CheckLeftCollision
          lda joy0left
          beq HFCM_CheckRightMovementJoy0
          jmp HFCM_CheckLeftCollision
HFCM_CheckRightMovementJoy0:

          jmp HFCM_CheckRightMovementJoy0

HFCM_CheckLeftCollision

          ;; Convert player position to playfield coordinates
          ;; Returns: Far (return otherbank)

          ;; Set temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; Set temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2



            lsr temp2

            lsr temp2


          lda temp2
          cmp # 32
          bcc ColumnInRangeLeft
          lda # 31
          sta temp2
ColumnInRangeLeft:
          ;; If temp2 & $80, set temp2 = 0
          lda temp2
          and # $80
          beq CheckTemp2RangeLeft
          lda # 0
          sta temp2
CheckTemp2RangeLeft:

          ;; Check column to the left



          ;; If temp2 <= 0, then jmp HFCM_CheckRightMovement
          lda temp2
          beq HFCM_CheckRightMovementColumn
          bmi HFCM_CheckRightMovementColumn
          jmp CheckColumnLeft
HFCM_CheckRightMovementColumn:
CheckColumnLeft:

          ;; Already at left edge
          lda temp2
          sec
          sbc # 1
          sta temp3

          ;; checkColumn = column to the left

          ;; Save player index to global variable

          lda temp1
          sta currentPlayer

          ;; Check player current row (check both top and bottom of sprite)

          ;; Set temp4 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp4

          lda temp4
          sta temp2


            lsr temp2

            lsr temp2

            lsr temp2

            lsr temp2


          ;; pfRow = top row

          lda temp2
          sta temp6

          ;; Check if blocked in current row

          ;; Reset left-collision flag

          lda # 0
          sta temp5

          lda temp3
          sta temp1

          lda temp6
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveLeftCurrentRow-1)
          pha
          lda # <(AfterPlayfieldReadMoveLeftCurrentRow-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveLeftCurrentRow:
          ;; If temp1, set temp5 = 1
          lda temp1
          beq CheckBottomRowMoveLeft
          lda # 1
          sta temp5
CheckBottomRowMoveLeft:
          lda currentPlayer
          sta temp1

          ;; Blocked, cannot move left

          lda temp5
          cmp # 1
          bne HFCM_MoveLeftOK
          jmp HFCM_CheckRightMovement
HFCM_MoveLeftOK:


          ;; Also check bottom row (feet)

          lda temp4
          clc
          adc # 16
          sta temp2


            lsr temp2

            lsr temp2

            lsr temp2

            lsr temp2


          lda temp2
          sta temp6

          ;; Do not check if beyond screen

          ;; If temp6 >= pfrows, then jmp HFCM_MoveLeftOK
          lda temp6
          cmp pfrows

          bcc CheckBottomRowLeft

          jmp HFCM_MoveLeftOK

          CheckBottomRowLeft:

          lda temp3
          sta temp1

          lda temp6
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveLeftBottomRow-1)
          pha
          lda # <(AfterPlayfieldReadMoveLeftBottomRow-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveLeftBottomRow:
          ;; If temp1, set temp5 = 1
          lda temp1
          beq CheckBottomRowMoveLeftBottom
          lda # 1
          sta temp5
CheckBottomRowMoveLeftBottom:
          lda currentPlayer
          sta temp1

          lda temp5
          cmp # 1
          bne HFCM_MoveLeftOKLabel
          jmp HFCM_CheckRightMovementJoy0
HFCM_MoveLeftOKLabel:


.pend

HFCM_MoveLeftOK .proc

          ;; Blocked at bottom too
          ;; Returns: Far (return otherbank)

          lda temp5
          cmp # 8
          bne CheckDragonOfStormsLeft
          jmp HFCM_LeftMomentumApply
CheckDragonOfStormsLeft:


          ;; Default (should not hit): apply -1

          lda temp5
          cmp # 2
          bne HFCM_LeftStandard
          jmp HFCM_LeftDirectApply
HFCM_LeftStandard:
          ;; Set playerVelocityX[temp1] = $ff
          lda temp1
          asl
          tax
          lda # $ff
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

          jmp HFCM_LeftApplyDone

.pend

HFCM_LeftMomentumApply .proc

                    let playerVelocityX[temp1] = playerVelocityX[temp1] - CharacterMovementSpeed[temp5]
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          jmp HFCM_LeftApplyDone

.pend

HFCM_LeftDirectApply .proc
          ;; Set playerX[temp1] = playerX[temp1] - CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc temp6
          sta playerX,x

HFCM_LeftApplyDone:

          ;; Preserve facing during hurt/recovery states (knockback, hitstun)
          ;; Returns: Far (return otherbank)

          ;; Inline ShouldPreserveFacing logic
          ;; If (playerState[temp1] & 8), then jmp SPF_InlineYes1
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq SPF_InlineNo1
          jmp SPF_InlineYes1
SPF_InlineNo1:
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq GetAnimationState
          jmp SPF_InlineYes1
GetAnimationState:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateInline1-1)
          pha
          lda # <(AfterGetPlayerAnimationStateInline1-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateInline1:


          ;; If temp2 < 5, then jmp SPF_InlineNo1          lda temp2          cmp 5          bcs .skip_6997          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Left
          jmp SPF_InlineNo1
CheckAnimationState10Left:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10LeftLabel
          jmp SPF_InlineNo1
CheckAnimationState10LeftLabel:

          

          lda temp2
          cmp # 10
          bcc SPF_InlineNo1
          jmp SPF_InlineYes1
SPF_InlineNo1:


.pend

SPF_InlineYes1 .proc

          lda # 1
          sta temp3

          jmp SPF_InlineDone1

.pend

SPF_InlineNo1 .proc

          lda # 0
          sta temp3

SPF_InlineDone1

          lda temp3
          bne HSHM_AfterLeftSetDoneHFCM
                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
HSHM_AfterLeftSetDoneHFCM:


.pend

HFCM_CheckRightMovement .proc

          ;; Determine which joy port to use for right movement
          ;; Returns: Far (return otherbank)
          lda temp1
          cmp # 0
          bne CheckPlayer2JoyPortRightMovement
          jmp HFCM_CheckRightJoy0
CheckPlayer2JoyPortRightMovement:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne HFCM_DoRightMovement
          jmp HFCM_CheckRightJoy0
HFCM_DoRightMovement:


          jmp BS_return

          jmp HFCM_DoRightMovement

.pend

HFCM_CheckRightJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          jmp BS_return

.pend

HFCM_DoRightMovement .proc

          ;; Convert player position to playfield coordinates
          ;; Returns: Far (return otherbank)

          ;; Set temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; Set temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2



            lsr temp2

            lsr temp2


          lda temp2
          cmp # 32
          bcc ColumnInRangeLeft
          lda # 31
          sta temp2
ColumnInRangeLeft:


                    if temp2 & $80 then let temp2 = 0



          ;; Check column to the right
          jmp BS_return

          ;; Already at right edge

          lda temp2
          clc
          adc # 1
          sta temp3

          ;; checkColumn = column to the right

          ;; Save player index to global variable

          lda temp1
          sta currentPlayer

          ;; Check player current row (check both top and bottom of sprite)

          ;; Set temp4 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp4

          lda temp4
          sta temp2


            lsr temp2

            lsr temp2

            lsr temp2

            lsr temp2


          ;; pfRow = top row

          lda temp2
          sta temp6

          ;; Check if blocked in current row

          ;; Reset right-collision flag

          lda # 0
          sta temp5

          lda temp3
          sta temp1

          lda temp6
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveRightCurrentRow-1)
          pha
          lda # <(AfterPlayfieldReadMoveRightCurrentRow-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveRightCurrentRow:


                    if temp1 then let temp5 = 1          lda temp1          beq CheckBottomRow
CheckBottomRow:
          jmp CheckBottomRow
          lda currentPlayer
          sta temp1

          ;; Blocked, cannot move right

          jmp BS_return

          ;; Also check bottom row (feet)

          lda temp4
          clc
          adc # 16
          sta temp4

          lda temp4
          sta temp2


            lsr temp2

            lsr temp2

            lsr temp2

            lsr temp2


          lda temp2
          sta temp6

          ;; Do not check if beyond screen

          ;; If temp6 >= pfrows, then jmp HFCM_MoveRightOK
          lda temp6
          cmp pfrows

          bcc CheckBottomRowRight

          jmp HFCM_MoveRightOK

          CheckBottomRowRight:

          lda temp3
          sta temp1

          lda temp6
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveRightBottomRow-1)
          pha
          lda # <(AfterPlayfieldReadMoveRightBottomRow-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveRightBottomRow:


                    if temp1 then let temp5 = 1          lda temp1          beq CheckBottomRowMoveRightBottom
CheckBottomRowMoveRightBottom:
          jmp CheckBottomRowMoveRightBottom
          lda currentPlayer
          sta temp1

          jmp BS_return

.pend

HFCM_MoveRightOK .proc

          ;; Blocked at bottom too
          ;; Returns: Far (return otherbank)

          lda temp5
          cmp # 8
          bne CheckDragonOfStormsRight
          jmp HFCM_RightMomentumApply
CheckDragonOfStormsRight:


          ;; Default (should not hit): apply +1

          lda temp5
          cmp # 2
          bne HFCM_RightStandard
          jmp HFCM_RightDirectApply
HFCM_RightStandard:
          lda temp1
          asl
          tax
          lda # 1
          sta playerVelocityX,x

          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

          jmp HFCM_RightApplyDone

.pend

HFCM_RightMomentumApply .proc

                    let playerVelocityX[temp1] = playerVelocityX[temp1] + CharacterMovementSpeed[temp5]
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          jmp HFCM_RightApplyDone

.pend

HFCM_RightDirectApply .proc

                    let playerX[temp1] = playerX[temp1] + CharacterMovementSpeed[temp5]

HFCM_RightApplyDone

          ;; Preserve facing during hurt/recovery states while processing right movement
          ;; Returns: Far (return otherbank)

          ;; Inline ShouldPreserveFacing logic
          ;; If (playerState[temp1] & 8), then jmp SPF_InlineYes2
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq SPF_InlineNo2
          jmp SPF_InlineYes2
SPF_InlineNo2:
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq GetAnimationStateRight
          jmp SPF_InlineYes2
GetAnimationStateRight:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateInline2-1)
          pha
          lda # <(AfterGetPlayerAnimationStateInline2-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateInline2:


          ;; If temp2 < 5, then jmp SPF_InlineNo2          lda temp2          cmp 5          bcs .skip_5155          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightSPF
          jmp SPF_InlineNo2
CheckAnimationState10RightSPF:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightLabelSPF
          jmp SPF_InlineNo2
CheckAnimationState10RightLabelSPF:

          

          lda temp2
          cmp # 10
          bcc SPF_InlineNo2
          jmp SPF_InlineYes2
SPF_InlineNo2:


.pend

SPF_InlineYes2 .proc

          lda # 1
          sta temp3

          jmp SPF_InlineDone2

.pend

SPF_InlineNo2 .proc

          lda # 0
          sta temp3

SPF_InlineDone2

          ;; Vertical control for flying characters: UP/DOWN
          ;; Returns: Far (return otherbank)

          lda temp3
          bne HSHM_AfterRightSetDone
                    let playerState[temp1] = playerState[temp1] | 1
HSHM_AfterRightSetDone:


          ;; If temp1 & 2 = 0, then jmp HFCM_VertJoy0
          lda temp1
          and # 2
          bne CheckJoy1UpHSHM
          jmp HFCM_VertJoy0
CheckJoy1UpHSHM:

          ;; If joy1up, then jmp HFCM_VertUp
          lda joy1up
          beq CheckJoy1DownHSHM
          jmp HFCM_VertUp
CheckJoy1DownHSHM:

          ;; If joy1down, then jmp HFCM_VertDown
          lda joy1down
          beq HandleFlyingCharacterMovementDoneJoy1
          jmp HFCM_VertDown
HandleFlyingCharacterMovementDoneJoy1:

          jmp BS_return

.pend

HFCM_VertJoy0 .proc

          ;; If joy0up, then jmp HFCM_VertUp
          lda joy0up
          beq CheckJoy0Down
          jmp HFCM_VertUp
CheckJoy0Down:

          ;; If joy0down, then jmp HFCM_VertDown
          lda joy0down
          beq HandleFlyingCharacterMovementDoneJoy0
          jmp HFCM_VertDown
HandleFlyingCharacterMovementDoneJoy0:

          rts

.pend

HFCM_VertUp .proc

          rts

          rts

          rts

.pend

HFCM_VertDown .proc

          rts

          rts

          rts



InputHandleLeftPortPlayerFunction


InputHandleLeftPortPlayerFunction




          ;;
          ;; LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)

          ;;
          ;; INPUT: temp1 = player index (0 or 2)

          ;; USES: joy0left, joy0right, joy0up, joy0down, joy0fire

          ;; Cache animation state at start (used for movement, jump,

          lda temp1
          sta currentPlayer

          and attack checks)

          ;; block movement during attack animations (states 13-15)

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateLeftPort-1)
          pha
          lda # <(AfterGetPlayerAnimationStateLeftPort-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateLeftPort:


          ;; Use jmp to avoid branch out of range (target is 310+ bytes away)

          ;; Block movement during attack windup/execute/recovery

          ;; If temp2 >= 13, then jmp DoneLeftPortMovement
          lda temp2
          cmp 13

          bcc CheckFlyingCharacter

          jmp DoneLeftPortMovement

          CheckFlyingCharacter:



          ;; Process left/right movement (with playfield collision for

          ;; flying characters)

          ;; Frooty (8) and Dragon of Storms (2) need collision checks

          ;; for horizontal movement

          ;; Set temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5

          ;; Use jmp to avoid branch out of range (target is 298+ bytes away)

          lda temp5
          cmp # 8
          bne CheckDragonOfStorms
          jmp IHLP_FlyingMovement
CheckDragonOfStorms:


          ;; Radish Goblin (12) uses bounce movement system

          lda temp5
          cmp # 2
          bne CheckRadishGoblin
          jmp IHLP_FlyingMovement
CheckRadishGoblin:


          lda temp5
          cmp CharacterRadishGoblin
          bne HandleStandardHorizontalMovementLabel
          jmp IHLP_RadishGoblinMovement
HandleStandardHorizontalMovementLabel:




          ;; Standard horizontal movement (modifies velocity, not position)

          jsr HandleStandardHorizontalMovement

DoneLeftPortMovement

.pend

IHLP_RadishGoblinMovement .proc

          ;; Cross-bank call to RadishGoblinHandleInput in bank 12
          lda # >(AfterRadishGoblinHandleInputLeftPort-1)
          pha
          lda # <(AfterRadishGoblinHandleInputLeftPort-1)
          pha
          lda # >(RadishGoblinHandleInput-1)
          pha
          lda # <(RadishGoblinHandleInput-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleInputLeftPort:


          jmp DoneLeftPortMovement

.pend

IHLP_FlyingMovement .proc

          ;; Cross-bank call to HandleFlyingCharacterMovement in bank 12
          lda # >(AfterHandleFlyingCharacterMovementLeftPort-1)
          pha
          lda # <(AfterHandleFlyingCharacterMovementLeftPort-1)
          pha
          lda # >(HandleFlyingCharacterMovement-1)
          pha
          lda # <(HandleFlyingCharacterMovement-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterHandleFlyingCharacterMovementLeftPort:


IHLP_DoneFlyingLeftRight



          ;; Process UP input and enhanced button (Button II)

          ;; temp2 already contains cached animation state from GetPlayerAnimationStateFunction

          jsr HandleUpInputAndEnhancedButton



          ;; Process down/guard input (inlined for performance)

          ;; Frooty cannot guard

          ;; Players 0,2 use joy0; Players 1,3 use joy1

          ;; If playerCharacter[temp1] = CharacterFrooty, then jmp HandleGuardInputDoneLeftPort
          lda temp1
          cmp # 0
          bne CheckPlayer2JoyPort1
          jmp HandleGuardInputCheckJoy0LeftPort
CheckPlayer2JoyPort1:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne CheckJoy1Down1
          jmp HandleGuardInputCheckJoy0LeftPort
CheckJoy1Down1:


          lda joy1down
          bne HandleGuardInputHandleDownPressedLeftPort
          jmp HandleGuardInputCheckGuardReleaseLeftPort
HandleGuardInputHandleDownPressedLeftPort:


          jmp HandleGuardInputHandleDownPressedLeftPort

.pend

HandleGuardInputCheckJoy0LeftPort .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          lda joy0down
          bne HandleGuardInputHandleDownPressedLeftPortJoy0
          jmp HandleGuardInputCheckGuardReleaseLeftPort
HandleGuardInputHandleDownPressedLeftPortJoy0:


.pend

HandleGuardInputHandleDownPressedLeftPort .proc

          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)

          ;; Set temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; If temp4 >= 32, then jmp HandleGuardInputDoneLeftPort
          lda temp4
          cmp 32

          bcc CheckDragonOfStormsDown1

          jmp HandleGuardInputDoneLeftPort

          CheckDragonOfStormsDown1:

          lda temp4
          cmp CharacterDragonOfStorms
          bne CheckHarpyDown1
          jmp DragonOfStormsDown
CheckHarpyDown1:


          lda temp4
          cmp CharacterHarpy
          bne CheckFrootyDown1
          jmp HarpyDown
CheckFrootyDown1:


          lda temp4
          cmp CharacterFrooty
          bne CheckRoboTitoDown1
          jmp FrootyDown
CheckRoboTitoDown1:


          lda temp4
          cmp CharacterRoboTito
          bne CheckRadishGoblinDown1
          jmp DCD_HandleRoboTitoDown1
CheckRadishGoblinDown1:


          lda temp4
          cmp CharacterRadishGoblin
          bne UseStandardGuard1
          jmp HGI_HandleRadishGoblinDown1
UseStandardGuard1:


          jmp StandardGuard

.pend

HGI_HandleRadishGoblinDown1 .proc

          ;; Radish Goblin: drop momentum + normal guarding
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDown in bank 12
          lda # >(AfterRadishGoblinHandleStickDownLeftPort-1)
          pha
          lda # <(AfterRadishGoblinHandleStickDownLeftPort-1)
          pha
          lda # >(RadishGoblinHandleStickDown-1)
          pha
          lda # <(RadishGoblinHandleStickDown-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleStickDownLeftPort:


          jmp StandardGuard

.pend

DispatchCharacterDownHandleRoboTitoDownLeftPort .proc

          ;; Cross-bank call to RoboTitoDown in bank 13
          lda # >(AfterRoboTitoDownInput1-1)
          pha
          lda # <(AfterRoboTitoDownInput1-1)
          pha
          lda # >(RoboTitoDown-1)
          pha
          lda # <(RoboTitoDown-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterRoboTitoDownInput1:


          lda temp2
          cmp # 1
          bne UseStandardGuard1Label
          jmp HGI_Done1
UseStandardGuard1Label:


          jmp StandardGuard

.pend

HandleGuardInputCheckGuardReleaseLeftPort .proc

          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)

          ;; Set temp2 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Not guarding, check for Radish Goblin short bounce

          lda temp2
          bne StopGuardEarly1
          jmp HandleGuardInputCheckRadishGoblinReleaseLeftPort
StopGuardEarly1:


          ;; Stop guard early and start cooldown
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitGuarding)
          sta playerState,x

          ;; Start cooldown timer
          lda temp1
          asl
          tax
          lda GuardTimerMaxFrames
          sta playerTimers_W,x

.pend

HGI_CheckRadishGoblinRelease1 .proc

          ;; Check if Radish Goblin and apply short bounce on stick down release
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDownRelease in bank 12
          lda # >(AfterRadishGoblinHandleStickDownReleaseLeftPort-1)
          pha
          lda # <(AfterRadishGoblinHandleStickDownReleaseLeftPort-1)
          pha
          lda # >(RadishGoblinHandleStickDownRelease-1)
          pha
          lda # <(RadishGoblinHandleStickDownRelease-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleStickDownReleaseLeftPort:


HandleGuardInputDoneLeftPort



          ;; Process attack input

          ;; Map MethHound (31) to ShamoneAttack handler

          ;; Use cached animation state - block attack input during

          ;; attack

          ;; animations (states 13-15)

          ;; Block attack input during attack windup/execute/recovery

          ;; If temp2 >= 13, then jmp InputDoneLeftPortAttack
          lda temp2
          cmp 13

          bcc CheckGuardStatus1

          jmp InputDoneLeftPortAttack

          CheckGuardStatus1:

          ;; Check if player is guarding - guard blocks attacks

          ;; Set temp2 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Guarding - block attack input

          ;; If temp2, then jmp InputDoneLeftPortAttack
          lda temp2
          beq CheckJoy0Fire
          jmp InputDoneLeftPortAttack
CheckJoy0Fire:

          lda joy0fire
          bne DispatchAttack
          jmp InputDoneLeftPortAttack
DispatchAttack:


                    if (playerState[temp1] & PlayerStateBitFacing) then jmp InputDoneLeftPortAttack

          ;; Set temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; Cross-bank call to DispatchCharacterAttack in bank 10
          lda # >(AfterDispatchCharacterAttackLeftPort-1)
          pha
          lda # <(AfterDispatchCharacterAttackLeftPort-1)
          pha
          lda # >(DispatchCharacterAttack-1)
          pha
          lda # <(DispatchCharacterAttack-1)
          pha
                    ldx # 9
          jmp BS_jsr
AfterDispatchCharacterAttackLeftPort:


InputDoneLeftPortAttack





          rts



InputHandleRightPortPlayerFunction


InputHandleRightPortPlayerFunction




          ;;
          ;; RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)

          ;;
          ;; INPUT: temp1 = player index (1 or 3)

          ;; USES: joy1left, joy1right, joy1up, joy1down, joy1fire

          ;; Cache animation state at start (used for movement, jump,

          lda temp1
          sta currentPlayer

          and attack checks)

          ;; block movement during attack animations (states 13-15)

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateRightPort-1)
          pha
          lda # <(AfterGetPlayerAnimationStateRightPort-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateRightPort:


          ;; Use jmp to avoid branch out of range (target is 327+ bytes away)

          ;; Block movement during attack windup/execute/recovery

          ;; If temp2 >= 13, then jmp DoneRightPortMovement
          lda temp2
          cmp 13

          bcc CheckGuardStatus2

          jmp DoneRightPortMovement

          CheckGuardStatus2:



          ;; Process left/right movement (with playfield collision for

          ;; flying characters)

          ;; Check if player is guarding - guard blocks movement

          ;; Set temp6 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6

          ;; Use jmp to avoid branch out of range (target is 314+ bytes away)

          ;; Guarding - block movement

          ;; If temp6, then jmp DoneRightPortMovement
          lda temp6
          beq CheckFlyingCharacter2
          jmp DoneRightPortMovement
CheckFlyingCharacter2:



          ;; Frooty and Dragon of Storms need collision checks

          ;; for horizontal movement

          ;; Set temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5

          ;; Use jmp to avoid branch out of range (target is 302+ bytes away)

          lda temp5
          cmp CharacterFrooty
          bne CheckDragonOfStorms2
          jmp IHRP_FlyingMovement
CheckDragonOfStorms2:


          ;; Radish Goblin (12) uses bounce movement system

          lda temp5
          cmp CharacterDragonOfStorms
          bne CheckRadishGoblin2
          jmp IHRP_FlyingMovement
CheckRadishGoblin2:


          lda temp5
          cmp CharacterRadishGoblin
          bne HandleStandardHorizontalMovement2
          jmp IHRP_RadishGoblinMovement
HandleStandardHorizontalMovement2:




          ;; Standard horizontal movement (no collision check)

          jsr HandleStandardHorizontalMovement

DoneRightPortMovement

.pend

IHRP_RadishGoblinMovement .proc

          ;; Cross-bank call to RadishGoblinHandleInput in bank 12
          lda # >(AfterRadishGoblinHandleInputRightPort-1)
          pha
          lda # <(AfterRadishGoblinHandleInputRightPort-1)
          pha
          lda # >(RadishGoblinHandleInput-1)
          pha
          lda # <(RadishGoblinHandleInput-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleInputRightPort:


          jmp DoneRightPortMovement

.pend

IHRP_FlyingMovement .proc

          ;; Cross-bank call to HandleFlyingCharacterMovement in bank 12
          lda # >(AfterHandleFlyingCharacterMovementRightPort-1)
          pha
          lda # <(AfterHandleFlyingCharacterMovementRightPort-1)
          pha
          lda # >(HandleFlyingCharacterMovement-1)
          pha
          lda # <(HandleFlyingCharacterMovement-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterHandleFlyingCharacterMovementRightPort:


IHRP_DoneFlyingLeftRight





          ;; Process UP input and enhanced button (Button II)

          ;; temp2 already contains cached animation state from GetPlayerAnimationStateFunction

          ;; Process down/guard input (inlined for performance)

          jsr HandleUpInputAndEnhancedButton

          ;; Frooty cannot guard

          ;; Players 0,2 use joy0; Players 1,3 use joy1

          ;; If playerCharacter[temp1] = CharacterFrooty, then jmp HGI_Done2
          lda temp1
          cmp # 0
          bne CheckPlayer2JoyPort2
          jmp HGI_CheckJoy0_2
CheckPlayer2JoyPort2:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne CheckJoy1Down2
          jmp HGI_CheckJoy0_2
CheckJoy1Down2:


          lda joy1down
          bne HGI_HandleDownPressed2
          jmp HGI_CheckGuardRelease2
HGI_HandleDownPressed2:


          jmp HGI_HandleDownPressed2

.pend

HGI_CheckJoy0_2 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          lda joy0down
          bne HandleGuardInputHandleDownPressedRightPortJoy0
          jmp HandleGuardInputCheckGuardReleaseRightPort
HandleGuardInputHandleDownPressedRightPortJoy0:


.pend

HandleGuardInputHandleDownPressedRightPort .proc

          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)

          ;; Set temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; If temp4 >= 32, then jmp HGI_Done2
          lda temp4
          cmp 32

          bcc CheckDragonOfStormsDown2

          jmp HGI_Done2

          CheckDragonOfStormsDown2:

          lda temp4
          cmp CharacterDragonOfStorms
          bne CheckHarpyDown2
          jmp DragonOfStormsDown
CheckHarpyDown2:


          lda temp4
          cmp CharacterHarpy
          bne CheckFrootyDown2
          jmp HarpyDown
CheckFrootyDown2:


          lda temp4
          cmp CharacterFrooty
          bne CheckRoboTitoDown2
          jmp FrootyDown
CheckRoboTitoDown2:


          lda temp4
          cmp CharacterRoboTito
          bne CheckRadishGoblinDown2
          jmp DCD_HandleRoboTitoDown2
CheckRadishGoblinDown2:


          lda temp4
          cmp CharacterRadishGoblin
          bne UseStandardGuard2
          jmp HGI_HandleRadishGoblinDown2
UseStandardGuard2:


          jmp StandardGuard

.pend

HGI_HandleRadishGoblinDown2 .proc

          ;; Radish Goblin: drop momentum + normal guarding
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDown in bank 12
          lda # >(AfterRadishGoblinHandleStickDownRightPort-1)
          pha
          lda # <(AfterRadishGoblinHandleStickDownRightPort-1)
          pha
          lda # >(RadishGoblinHandleStickDown-1)
          pha
          lda # <(RadishGoblinHandleStickDown-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleStickDownRightPort:


          jmp StandardGuard

.pend

DCD_HandleRoboTitoDown2 .proc

          ;; Cross-bank call to RoboTitoDown in bank 13
          lda # >(AfterRoboTitoDownInput2-1)
          pha
          lda # <(AfterRoboTitoDownInput2-1)
          pha
          lda # >(RoboTitoDown-1)
          pha
          lda # <(RoboTitoDown-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterRoboTitoDownInput2:


          lda temp2
          cmp # 1
          bne UseStandardGuard2Label
          jmp HandleGuardInputDoneRightPort
UseStandardGuard2Label:


          jmp StandardGuard

.pend

HandleGuardInputCheckGuardReleaseRightPort .proc

          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)

          ;; Set temp2 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Not guarding, check for Radish Goblin short bounce

          lda temp2
          bne StopGuardEarly2
          jmp HandleGuardInputCheckRadishGoblinReleaseRightPort
StopGuardEarly2:


          ;; Stop guard early and start cooldown
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitGuarding)
          sta playerState,x

          ;; Start cooldown timer
          lda temp1
          asl
          tax
          lda GuardTimerMaxFrames
          sta playerTimers_W,x

.pend

HandleGuardInputCheckRadishGoblinReleaseRightPort .proc

          ;; Check if Radish Goblin and apply short bounce on stick down release
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDownRelease in bank 12
          lda # >(AfterRadishGoblinHandleStickDownReleaseRightPort-1)
          pha
          lda # <(AfterRadishGoblinHandleStickDownReleaseRightPort-1)
          pha
          lda # >(RadishGoblinHandleStickDownRelease-1)
          pha
          lda # <(RadishGoblinHandleStickDownRelease-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleStickDownReleaseRightPort:


HandleGuardInputDoneRightPort



          ;; Process attack input

          ;; Use cached animation state - block attack input during

          ;; attack

          ;; animations (states 13-15)

          ;; Block attack input during attack windup/execute/recovery

          ;; If temp2 >= 13, then jmp InputDoneRightPortAttack
          lda temp2
          cmp 13

          bcc CheckGuardStatus3

          jmp InputDoneRightPortAttack

          CheckGuardStatus3:

          ;; Set temp2 = playerState[temp1] & 2 PlayerStateBitGuarding         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2

          ;; Guarding - block attack input

          ;; If temp2, then jmp InputDoneRightPortAttack
          lda temp2
          beq CheckJoy1Fire
          jmp InputDoneRightPortAttack
CheckJoy1Fire:

          lda joy1fire
          bne DispatchAttack2
          jmp InputDoneRightPortAttack
DispatchAttack2:
          ;; If (playerState[temp1] & PlayerStateBitFacing), then jmp InputDoneRightPortAttack
          lda temp1
          asl
          tax
          lda playerState,x
          and # PlayerStateBitFacing
          beq InputDoneRightPortAttackSkip
          jmp InputDoneRightPortAttack
InputDoneRightPortAttackSkip:

          ;; Set temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; Cross-bank call to DispatchCharacterAttack in bank 10
          lda # >(AfterDispatchCharacterAttackRightPort-1)
          pha
          lda # <(AfterDispatchCharacterAttackRightPort-1)
          pha
          lda # >(DispatchCharacterAttack-1)
          pha
          lda # <(DispatchCharacterAttack-1)
          pha
                    ldx # 9
          jmp BS_jsr
AfterDispatchCharacterAttackRightPort:


InputDoneRightPortAttack

          rts



.pend

HandlePauseInput .proc

          ;;
          ;; Pause Button Handling With Debouncing

          ;; Handles SELECT switch and Joy2b+ Button III with proper

          ;; debouncing

          ;; Uses SystemFlagPauseButtonPrev bit in systemFlags for debouncing

          ;; Check SELECT switch (always available)

          lda # 0
          sta temp1

          ;; If switchselect, set temp1 = 1
          lda switchselect
          beq CheckJoy2bPlus
          lda # 1
          sta temp1
CheckJoy2bPlus:



          ;; Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for

          ;; Player 2)
          ;; If LeftPortJoy2bPlus and !INPT1{7}, set temp1 = 1
          lda LeftPortJoy2bPlus
          beq CheckRightPortJoy2bPlus
          bit INPT1
          bmi CheckRightPortJoy2bPlus
          lda # 1
          sta temp1
CheckRightPortJoy2bPlus:
          ;; If RightPortJoy2bPlus and !INPT3{7}, set temp1 = 1
          lda RightPortJoy2bPlus
          beq Joy2bPauseDone
          bit INPT3
          bmi Joy2bPauseDone
          lda # 1
          sta temp1
Joy2bPauseDone:

          ;; Player 2 Button III



          ;; Debounce: only toggle if button just pressed (was 0, now

          ;; 1)
          lda temp1
          cmp # 0
          bne CheckPauseButtonPrev
          jmp DonePauseToggle
CheckPauseButtonPrev:


          ;; Toggle pause flag in systemFlags

          ;; If systemFlags & SystemFlagPauseButtonPrev, then jmp DonePauseToggle
          lda systemFlags
          and # SystemFlagPauseButtonPrev
          beq TogglePauseFlag
          jmp DonePauseToggle
TogglePauseFlag:

                    if systemFlags & SystemFlagGameStatePaused then let systemFlags = systemFlags & ClearSystemFlagGameStatePaused else systemFlags = systemFlags | SystemFlagGameStatePaused
          lda systemFlags
          and # SystemFlagGameStatePaused
          beq SetPausedFlag
          lda systemFlags
          and # ClearSystemFlagGameStatePaused
          sta systemFlags
          jmp end_179
SetPausedFlag:
          lda systemFlags
          ora # SystemFlagGameStatePaused
          sta systemFlags
end_179:

DonePauseToggle

          ;; Toggle pause (0<->1)





          ;; Update pause button previous state in systemFlags

          ;; Update previous button state for next frame

                    if temp1 then let systemFlags = systemFlags | SystemFlagPauseButtonPrev else systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev
          lda temp1
          beq ClearPauseButtonPrev
          lda systemFlags
          ora # SystemFlagPauseButtonPrev
          sta systemFlags
          jmp end_9698
ClearPauseButtonPrev:
          lda systemFlags
          and ClearSystemFlagPauseButtonPrev
          sta systemFlags
end_9698:



          rts



.pend

