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
          ;; Cross-bank call to InputHandleLeftPortPlayerFunction
          lda # 0
          sta temp1



InputDonePlayer0Input:

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
          ;; Cross-bank call to InputHandleLeftPortPlayerFunction
          lda # 2
          sta temp1



InputDonePlayer3Input:

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
          bne CheckPlayer4State
          jmp InputDonePlayer4Input
CheckPlayer4State:

          ;; If (playerState[3] & 8), then jmp InputDonePlayer4Input
          lda # 3
          asl
          tax
          lda playerState,x
          and # 8
          beq InputDonePlayer4InputSkipSecond
          jmp InputDonePlayer4Input
InputDonePlayer4InputSkipSecond:
          ;; Set temp1 = 3
          ;; Cross-bank call to InputHandleRightPortPlayerFunction
          lda # 3
          sta temp1



InputDonePlayer4Input:

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

          ;; Cross-bank call to RoboTitoDown in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterRoboTitoDownInput-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRoboTitoDownInput hi (encoded)]
          lda # <(AfterRoboTitoDownInput-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRoboTitoDownInput hi (encoded)] [SP+0: AfterRoboTitoDownInput lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRoboTitoDownInput hi (encoded)] [SP+1: AfterRoboTitoDownInput lo] [SP+0: RoboTitoDown hi (raw)]
          lda # <(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRoboTitoDownInput hi (encoded)] [SP+2: AfterRoboTitoDownInput lo] [SP+1: RoboTitoDown hi (raw)] [SP+0: RoboTitoDown lo]
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



HandleUpInputAndEnhancedButton:

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

HandleUpInputEnhancedButtonRoboTitoAscend:

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

          ;; Set temp4 = temp4 - ScreenInsetX          lda temp4          sec          sbc # ScreenInsetX          sta temp4
          lda temp4
          sec
          sbc # ScreenInsetX
          sta temp4

          lda temp4
          sec
          sbc # ScreenInsetX
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
          ;; If temp4 & $80, set temp4 = 0
          lda temp4
          and # $80
          beq CheckTemp4RangeSecond
          lda # 0
          sta temp4
CheckTemp4RangeSecond:

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

          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterPlayfieldReadRestoreAnimation-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadRestoreAnimation hi (encoded)]
          lda # <(AfterPlayfieldReadRestoreAnimation-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadRestoreAnimation hi (encoded)] [SP+0: AfterPlayfieldReadRestoreAnimation lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadRestoreAnimation hi (encoded)] [SP+1: AfterPlayfieldReadRestoreAnimation lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadRestoreAnimation hi (encoded)] [SP+2: AfterPlayfieldReadRestoreAnimation lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
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
          bne CheckPlayer2JoyPortRoboTito
          jmp HandleUpInputEnhancedButtonRoboTitoCheckJoy0
CheckPlayer2JoyPortRoboTito:


          lda temp1
          cmp # 2
          bne CheckJoy1Down
          jmp HandleUpInputEnhancedButtonRoboTitoCheckJoy0
CheckJoy1Down:

          ;; If joy1down, set characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          lda joy1down
          beq HandleUpInputEnhancedButtonRoboTitoDoneJoy1
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          and # (255 - 1)
          sta characterStateFlags_W,x
HandleUpInputEnhancedButtonRoboTitoDoneJoy1:
          jmp BS_return

.pend

HandleUpInputEnhancedButtonRoboTitoCheckJoy0 .proc

          ;; If joy0down, set characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          lda joy0down
          beq HandleUpInputEnhancedButtonRoboTitoDoneJoy0
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          and # (255 - 1)
          sta characterStateFlags_W,x
HandleUpInputEnhancedButtonRoboTitoDoneJoy0:
          jmp BS_return

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

          ;; Cross-bank call to BernieJump in bank 11
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterBernieJumpInput-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterBernieJumpInput hi (encoded)]
          lda # <(AfterBernieJumpInput-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterBernieJumpInput hi (encoded)] [SP+0: AfterBernieJumpInput lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(BernieJump-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterBernieJumpInput hi (encoded)] [SP+1: AfterBernieJumpInput lo] [SP+0: BernieJump hi (raw)]
          lda # <(BernieJump-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterBernieJumpInput hi (encoded)] [SP+2: AfterBernieJumpInput lo] [SP+1: BernieJump hi (raw)] [SP+0: BernieJump lo]
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

          ;; Cross-bank call to HarpyJump in bank 11
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterHarpyJumpInput-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterHarpyJumpInput hi (encoded)]
          lda # <(AfterHarpyJumpInput-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterHarpyJumpInput hi (encoded)] [SP+0: AfterHarpyJumpInput lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(HarpyJump-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterHarpyJumpInput hi (encoded)] [SP+1: AfterHarpyJumpInput lo] [SP+0: HarpyJump hi (raw)]
          lda # <(HarpyJump-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterHarpyJumpInput hi (encoded)] [SP+2: AfterHarpyJumpInput lo] [SP+1: HarpyJump hi (raw)] [SP+0: HarpyJump lo]
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

          ;; Cross-bank call to CheckEnhancedJumpButton in bank 9
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterCheckEnhancedJumpButtonEnhanced-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckEnhancedJumpButtonEnhanced hi (encoded)]
          lda # <(AfterCheckEnhancedJumpButtonEnhanced-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckEnhancedJumpButtonEnhanced hi (encoded)] [SP+0: AfterCheckEnhancedJumpButtonEnhanced lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckEnhancedJumpButton-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckEnhancedJumpButtonEnhanced hi (encoded)] [SP+1: AfterCheckEnhancedJumpButtonEnhanced lo] [SP+0: CheckEnhancedJumpButton hi (raw)]
          lda # <(CheckEnhancedJumpButton-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckEnhancedJumpButtonEnhanced hi (encoded)] [SP+2: AfterCheckEnhancedJumpButtonEnhanced lo] [SP+1: CheckEnhancedJumpButton hi (raw)] [SP+0: CheckEnhancedJumpButton lo]
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

          ;; Cross-bank call to CheckEnhancedJumpButton in bank 9
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterCheckEnhancedJumpButtonCheck-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckEnhancedJumpButtonCheck hi (encoded)]
          lda # <(AfterCheckEnhancedJumpButtonCheck-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckEnhancedJumpButtonCheck hi (encoded)] [SP+0: AfterCheckEnhancedJumpButtonCheck lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckEnhancedJumpButton-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckEnhancedJumpButtonCheck hi (encoded)] [SP+1: AfterCheckEnhancedJumpButtonCheck lo] [SP+0: CheckEnhancedJumpButton hi (raw)]
          lda # <(CheckEnhancedJumpButton-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckEnhancedJumpButtonCheck hi (encoded)] [SP+2: AfterCheckEnhancedJumpButtonCheck lo] [SP+1: CheckEnhancedJumpButton hi (raw)] [SP+0: CheckEnhancedJumpButton lo]
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



HandleStandardHorizontalMovement:

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
          bne CheckPlayer2JoyPortHSHM
          jmp HandleStandardHorizontalMovementUseJoy0
CheckPlayer2JoyPortHSHM:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne CheckJoy1Left
          jmp HandleStandardHorizontalMovementUseJoy0
CheckJoy1Left:


          lda joy1left
          bne HandleStandardHorizontalMovementHandleLeft
          jmp HandleStandardHorizontalMovementCheckRight
HandleStandardHorizontalMovementHandleLeft:


          jmp HandleStandardHorizontalMovementHandleLeft

.pend

HandleStandardHorizontalMovementUseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          lda joy0left
          bne HandleStandardHorizontalMovementHandleLeftJoy0
          jmp HandleStandardHorizontalMovementCheckRight
HandleStandardHorizontalMovementHandleLeftJoy0:


.pend

HandleStandardHorizontalMovementHandleLeft .proc

          ;; Left movement: set negative velocity
          ;; Returns: Far (return otherbank)

          ;; If playerCharacter[temp1] = CharacterFrooty then jmp HandleStandardHorizontalMovementLeftMomentum

          ;; if playerCharacter[temp1] = CharacterDragonOfStorms, then jmp HandleStandardHorizontalMovementLeftDirectSubpixel
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterDragonOfStorms
          bne HandleStandardHorizontalMovementLeftStandard
          jmp HandleStandardHorizontalMovementLeftDirectSubpixel
HandleStandardHorizontalMovementLeftStandard:

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
          lda # 0
          sta playerVelocityXL,x

          jmp HandleStandardHorizontalMovementAfterLeftSet

.pend

HandleStandardHorizontalMovementLeftDirectSubpixel .proc

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
          lda # 1
          sta playerVelocityXL,x

          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy

          jmp HandleStandardHorizontalMovementAfterLeftSet

.pend

HandleStandardHorizontalMovementLeftMomentum .proc

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

          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc temp6
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

.pend

HandleStandardHorizontalMovementAfterLeftSet .proc

          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
          ;; If (playerState[temp1] & 8), then jmp HandleStandardHorizontalMovementShouldPreserveFacingYes1
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq HandleStandardHorizontalMovementShouldPreserveFacingNo1
          jmp HandleStandardHorizontalMovementShouldPreserveFacingYes1
HandleStandardHorizontalMovementShouldPreserveFacingNo1:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterGetPlayerAnimationStateAfterLeftSet-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerAnimationStateAfterLeftSet hi (encoded)]
          lda # <(AfterGetPlayerAnimationStateAfterLeftSet-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerAnimationStateAfterLeftSet hi (encoded)] [SP+0: AfterGetPlayerAnimationStateAfterLeftSet lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerAnimationStateAfterLeftSet hi (encoded)] [SP+1: AfterGetPlayerAnimationStateAfterLeftSet lo] [SP+0: GetPlayerAnimationStateFunction hi (raw)]
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerAnimationStateAfterLeftSet hi (encoded)] [SP+2: AfterGetPlayerAnimationStateAfterLeftSet lo] [SP+1: GetPlayerAnimationStateFunction hi (raw)] [SP+0: GetPlayerAnimationStateFunction lo]
          ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateAfterLeftSet:


          ;; If temp2 < 5, then jmp HandleStandardHorizontalMovementShouldPreserveFacingNo1          lda temp2          cmp 5          bcs .skip_1803          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10
          goto_label:

          jmp HandleStandardHorizontalMovementShouldPreserveFacingNo1
CheckAnimationState10:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10Label
          jmp HandleStandardHorizontalMovementShouldPreserveFacingNo1
CheckAnimationState10Label:

          

          lda temp2
          cmp # 10
          bcc HandleStandardHorizontalMovementShouldPreserveFacingNo1
          jmp HandleStandardHorizontalMovementShouldPreserveFacingYes1
HandleStandardHorizontalMovementShouldPreserveFacingNo1:


.pend

HandleStandardHorizontalMovementShouldPreserveFacingYes1 .proc

          lda # 1
          sta temp3

          jmp HandleStandardHorizontalMovementShouldPreserveFacingDone1

.pend

HandleStandardHorizontalMovementShouldPreserveFacingNo1 .proc

          lda # 0
          sta temp3

HandleStandardHorizontalMovementShouldPreserveFacingDone1:

          lda temp3
          bne HandleStandardHorizontalMovementAfterLeftSetDone
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitFacing)
          sta playerState,x
HandleStandardHorizontalMovementAfterLeftSetDone:


.pend

HandleStandardHorizontalMovementCheckRight .proc

          ;; Determine which joy port to use for right movement
          ;; Returns: Far (return otherbank)
          lda temp1
          bne CheckPlayer2JoyPortRight
          jmp HandleStandardHorizontalMovementCheckRightJoy0
CheckPlayer2JoyPortRight:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne HandleStandardHorizontalMovementHandleRight
          jmp HandleStandardHorizontalMovementCheckRightJoy0
HandleStandardHorizontalMovementHandleRight:


          jmp BS_return

          jmp HandleStandardHorizontalMovementHandleRight

.pend

HandleStandardHorizontalMovementCheckRightJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          jmp BS_return

.pend

HandleStandardHorizontalMovementHandleRight .proc

          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)

          ;; If playerCharacter[temp1] = CharacterFrooty then jmp HandleStandardHorizontalMovementRightMomentum

          ;; if playerCharacter[temp1] = CharacterDragonOfStorms, then jmp HandleStandardHorizontalMovementRightDirectSubpixel
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterDragonOfStorms
          bne HandleStandardHorizontalMovementRightStandard
          jmp HandleStandardHorizontalMovementRightDirectSubpixel
HandleStandardHorizontalMovementRightStandard:

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
          lda # 0
          sta playerVelocityXL,x

          jmp HSHM_AfterRightSet

.pend

HandleStandardHorizontalMovementRightDirectSubpixel .proc

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
          lda # 1
          sta playerVelocityXL,x

          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy

          jmp HandleStandardHorizontalMovementAfterRightSet

.pend

HandleStandardHorizontalMovementRightMomentum .proc

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

HandleStandardHorizontalMovementAfterRightSet .proc

          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
          ;; If (playerState[temp1] & 8), then jmp HandleStandardHorizontalMovementShouldPreserveFacingYes2
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq HandleStandardHorizontalMovementShouldPreserveFacingNo2
          jmp HandleStandardHorizontalMovementShouldPreserveFacingYes2
HandleStandardHorizontalMovementShouldPreserveFacingNo2:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterGetPlayerAnimationStateAfterRightSet-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerAnimationStateAfterRightSet hi (encoded)]
          lda # <(AfterGetPlayerAnimationStateAfterRightSet-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerAnimationStateAfterRightSet hi (encoded)] [SP+0: AfterGetPlayerAnimationStateAfterRightSet lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerAnimationStateAfterRightSet hi (encoded)] [SP+1: AfterGetPlayerAnimationStateAfterRightSet lo] [SP+0: GetPlayerAnimationStateFunction hi (raw)]
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerAnimationStateAfterRightSet hi (encoded)] [SP+2: AfterGetPlayerAnimationStateAfterRightSet lo] [SP+1: GetPlayerAnimationStateFunction hi (raw)] [SP+0: GetPlayerAnimationStateFunction lo]
          ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateAfterRightSet:


          ;; If temp2 < 5, then jmp HandleStandardHorizontalMovementShouldPreserveFacingNo2          lda temp2          cmp 5          bcs .skip_6914          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right
          jmp HandleStandardHorizontalMovementShouldPreserveFacingNo2
CheckAnimationState10Right:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightLabel
          jmp HandleStandardHorizontalMovementShouldPreserveFacingNo2
CheckAnimationState10RightLabel:

          

          lda temp2
          cmp # 10
          bcc HandleStandardHorizontalMovementShouldPreserveFacingNo2
          jmp HandleStandardHorizontalMovementShouldPreserveFacingYes2
HandleStandardHorizontalMovementShouldPreserveFacingNo2:


.pend

HandleStandardHorizontalMovementShouldPreserveFacingYes2 .proc

          lda # 1
          sta temp3

          jmp HandleStandardHorizontalMovementShouldPreserveFacingDone2

.pend

HandleStandardHorizontalMovementShouldPreserveFacingNo2 .proc

          lda # 0
          sta temp3

HandleStandardHorizontalMovementShouldPreserveFacingDone2:

          lda temp3
          bne HandleStandardHorizontalMovementAfterRightSetDoneFirst
          ;; Set playerState[temp1] = playerState[temp1] | 1
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 1
          sta playerState,x
HandleStandardHorizontalMovementAfterRightSetDoneFirst:

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

          ;; If temp1 & 2 = 0 then jmp HandleFlyingCharacterMovementUseJoy0

          ;; if joy1left, then jmp HandleFlyingCharacterMovementCheckLeftCollision
          lda joy1left
          beq HandleFlyingCharacterMovementCheckRightMovement
          jmp HandleFlyingCharacterMovementCheckLeftCollision
HandleFlyingCharacterMovementCheckRightMovement:

          jmp HandleFlyingCharacterMovementCheckRightMovement

.pend

HandleFlyingCharacterMovementUseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; If joy0left, then jmp HandleFlyingCharacterMovementCheckLeftCollision
          lda joy0left
          beq HandleFlyingCharacterMovementCheckRightMovementJoy0
          jmp HandleFlyingCharacterMovementCheckLeftCollision
HandleFlyingCharacterMovementCheckRightMovementJoy0:

          jmp HandleFlyingCharacterMovementCheckRightMovementJoy0

HandleFlyingCharacterMovementCheckLeftCollision:

          ;; Convert player position to playfield coordinates
          ;; Returns: Far (return otherbank)

          ;; Set temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; Set temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc # ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc # ScreenInsetX
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



          ;; If temp2 <= 0, then jmp HandleFlyingCharacterMovementCheckRightMovement
          lda temp2
          beq HandleFlyingCharacterMovementCheckRightMovementColumn
          bmi HandleFlyingCharacterMovementCheckRightMovementColumn
          jmp CheckColumnLeft
HandleFlyingCharacterMovementCheckRightMovementColumn:
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

          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveLeftCurrentRow-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveLeftCurrentRow hi (encoded)]
          lda # <(AfterPlayfieldReadMoveLeftCurrentRow-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveLeftCurrentRow hi (encoded)] [SP+0: AfterPlayfieldReadMoveLeftCurrentRow lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveLeftCurrentRow hi (encoded)] [SP+1: AfterPlayfieldReadMoveLeftCurrentRow lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveLeftCurrentRow hi (encoded)] [SP+2: AfterPlayfieldReadMoveLeftCurrentRow lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
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
          bne HandleFlyingCharacterMovementMoveLeftOK
          jmp HandleFlyingCharacterMovementCheckRightMovement
HandleFlyingCharacterMovementMoveLeftOK:


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

          ;; If temp6 >= pfrows, then jmp HandleFlyingCharacterMovementMoveLeftOK
          lda temp6
          cmp pfrows

          bcc CheckBottomRowLeft

          jmp HandleFlyingCharacterMovementMoveLeftOK

          CheckBottomRowLeft:

          lda temp3
          sta temp1

          lda temp6
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveLeftBottomRow-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveLeftBottomRow hi (encoded)]
          lda # <(AfterPlayfieldReadMoveLeftBottomRow-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveLeftBottomRow hi (encoded)] [SP+0: AfterPlayfieldReadMoveLeftBottomRow lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveLeftBottomRow hi (encoded)] [SP+1: AfterPlayfieldReadMoveLeftBottomRow lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveLeftBottomRow hi (encoded)] [SP+2: AfterPlayfieldReadMoveLeftBottomRow lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
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
          bne HandleFlyingCharacterMovementMoveLeftOKLabel
          jmp HandleFlyingCharacterMovementCheckRightMovementJoy0
HandleFlyingCharacterMovementMoveLeftOKLabel:


.pend

HandleFlyingCharacterMovementMoveLeftOK .proc

          ;; Blocked at bottom too
          ;; Returns: Far (return otherbank)

          lda temp5
          cmp # 8
          bne CheckDragonOfStormsLeft
          jmp HandleFlyingCharacterMovementLeftMomentumApply
CheckDragonOfStormsLeft:


          ;; Default (should not hit): apply -1

          lda temp5
          cmp # 2
          bne HandleFlyingCharacterMovementLeftStandard
          jmp HandleFlyingCharacterMovementLeftDirectApply
HandleFlyingCharacterMovementLeftStandard:
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

          jmp HandleFlyingCharacterMovementLeftApplyDone

.pend

HandleFlyingCharacterMovementLeftMomentumApply .proc

          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] - CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc temp6
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

          jmp HandleFlyingCharacterMovementLeftApplyDone

.pend

HandleFlyingCharacterMovementLeftDirectApply .proc
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

HandleFlyingCharacterMovementLeftApplyDone:

          ;; Preserve facing during hurt/recovery states (knockback, hitstun)
          ;; Returns: Far (return otherbank)

          ;; Inline ShouldPreserveFacing logic
          ;; If (playerState[temp1] & 8), then jmp ShouldPreserveFacingInlineYes1
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq ShouldPreserveFacingInlineNo1
          jmp ShouldPreserveFacingInlineYes1
ShouldPreserveFacingInlineNo1:
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq GetAnimationState
          jmp ShouldPreserveFacingInlineYes1
GetAnimationState:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterGetPlayerAnimationStateInline1-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerAnimationStateInline1 hi (encoded)]
          lda # <(AfterGetPlayerAnimationStateInline1-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerAnimationStateInline1 hi (encoded)] [SP+0: AfterGetPlayerAnimationStateInline1 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerAnimationStateInline1 hi (encoded)] [SP+1: AfterGetPlayerAnimationStateInline1 lo] [SP+0: GetPlayerAnimationStateFunction hi (raw)]
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerAnimationStateInline1 hi (encoded)] [SP+2: AfterGetPlayerAnimationStateInline1 lo] [SP+1: GetPlayerAnimationStateFunction hi (raw)] [SP+0: GetPlayerAnimationStateFunction lo]
          ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateInline1:


          ;; If temp2 < 5, then jmp ShouldPreserveFacingInlineNo1          lda temp2          cmp 5          bcs .skip_6997          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Left
          jmp ShouldPreserveFacingInlineNo1
CheckAnimationState10Left:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10LeftLabel
          jmp ShouldPreserveFacingInlineNo1
CheckAnimationState10LeftLabel:

          

          lda temp2
          cmp # 10
          bcc ShouldPreserveFacingInlineNo1
          jmp ShouldPreserveFacingInlineYes1
ShouldPreserveFacingInlineNo1:


.pend

ShouldPreserveFacingInlineYes1 .proc

          lda # 1
          sta temp3

          jmp ShouldPreserveFacingInlineDone1

.pend

ShouldPreserveFacingInlineNo1 .proc

          lda # 0
          sta temp3

ShouldPreserveFacingInlineDone1:

          lda temp3
          bne HandleStandardHorizontalMovementAfterLeftSetDoneHandleFlyingCharacterMovement
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitFacing)
          sta playerState,x
HandleStandardHorizontalMovementAfterLeftSetDoneHandleFlyingCharacterMovement:


.pend

HandleFlyingCharacterMovementCheckRightMovement .proc

          ;; Determine which joy port to use for right movement
          ;; Returns: Far (return otherbank)
          lda temp1
          bne CheckPlayer2JoyPortRightMovement
          jmp HandleFlyingCharacterMovementCheckRightJoy0
CheckPlayer2JoyPortRightMovement:


          ;; Players 1,3 use joy1

          lda temp1
          cmp # 2
          bne HandleFlyingCharacterMovementDoRightMovement
          jmp HandleFlyingCharacterMovementCheckRightJoy0
HandleFlyingCharacterMovementDoRightMovement:


          jmp BS_return

          jmp HandleFlyingCharacterMovementDoRightMovement

.pend

HandleFlyingCharacterMovementCheckRightJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)
          lda SWCHA
          bit BitMask + SWCHA_BitP0Right
          bne HandleFlyingCharacterMovementCheckRightJoy0Done

          jmp HandleFlyingCharacterMovementDoRightMovement
HandleFlyingCharacterMovementCheckRightJoy0Done:
          jmp BS_return

.pend

HandleFlyingCharacterMovementDoRightMovement .proc

          ;; Convert player position to playfield coordinates
          ;; Returns: Far (return otherbank)

          ;; Set temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; Set temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc # ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2



            lsr temp2

            lsr temp2


          lda temp2
          cmp # 32
          bcc ColumnInRangeLeftSecond
          lda # 31
          sta temp2
ColumnInRangeLeftSecond:

          ;; If temp2 & $80, set temp2 = 0
          lda temp2
          and # $80
          beq CheckTemp2RangeLeftThird
          lda # 0
          sta temp2
CheckTemp2RangeLeftThird:



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

          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveRightCurrentRow-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveRightCurrentRow hi (encoded)]
          lda # <(AfterPlayfieldReadMoveRightCurrentRow-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveRightCurrentRow hi (encoded)] [SP+0: AfterPlayfieldReadMoveRightCurrentRow lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveRightCurrentRow hi (encoded)] [SP+1: AfterPlayfieldReadMoveRightCurrentRow lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveRightCurrentRow hi (encoded)] [SP+2: AfterPlayfieldReadMoveRightCurrentRow lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
          ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveRightCurrentRow:


          ;; If temp1, set temp5 = 1
          lda temp1
          beq CheckBottomRow
          lda # 1
          sta temp5
CheckBottomRow:
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

          ;; If temp6 >= pfrows, then jmp HandleFlyingCharacterMovementMoveRightOK
          lda temp6
          cmp pfrows

          bcc CheckBottomRowRight

          jmp HandleFlyingCharacterMovementMoveRightOK

          CheckBottomRowRight:

          lda temp3
          sta temp1

          lda temp6
          sta temp2

          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveRightBottomRow-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveRightBottomRow hi (encoded)]
          lda # <(AfterPlayfieldReadMoveRightBottomRow-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveRightBottomRow hi (encoded)] [SP+0: AfterPlayfieldReadMoveRightBottomRow lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveRightBottomRow hi (encoded)] [SP+1: AfterPlayfieldReadMoveRightBottomRow lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveRightBottomRow hi (encoded)] [SP+2: AfterPlayfieldReadMoveRightBottomRow lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
          ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveRightBottomRow:

          ;; If temp1, set temp5 = 1
          lda temp1
          beq CheckBottomRowMoveRightBottom
          lda # 1
          sta temp5
CheckBottomRowMoveRightBottom:
          lda currentPlayer
          sta temp1

          jmp BS_return

.pend

HandleFlyingCharacterMovementMoveRightOK .proc

          ;; Blocked at bottom too
          ;; Returns: Far (return otherbank)

          lda temp5
          cmp # 8
          bne CheckDragonOfStormsRight
          jmp HandleFlyingCharacterMovementRightMomentumApply
CheckDragonOfStormsRight:


          ;; Default (should not hit): apply +1

          lda temp5
          cmp # 2
          bne HandleFlyingCharacterMovementRightStandard
          jmp HandleFlyingCharacterMovementRightDirectApply
HandleFlyingCharacterMovementRightStandard:
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

          jmp HandleFlyingCharacterMovementRightApplyDone

.pend

HandleFlyingCharacterMovementRightMomentumApply .proc

          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] + CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
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

          jmp HandleFlyingCharacterMovementRightApplyDone

.pend

HandleFlyingCharacterMovementRightDirectApply .proc

          ;; Set playerX[temp1] = playerX[temp1] + CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp1
          asl
          tax
          lda playerX,x
          clc
          adc temp6
          sta playerX,x

HandleFlyingCharacterMovementRightApplyDone:

          ;; Preserve facing during hurt/recovery states while processing right movement
          ;; Returns: Far (return otherbank)

          ;; Inline ShouldPreserveFacing logic
          ;; If (playerState[temp1] & 8), then jmp ShouldPreserveFacingInlineYes2
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq ShouldPreserveFacingInlineNo2
          jmp ShouldPreserveFacingInlineYes2
ShouldPreserveFacingInlineNo2:
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq GetAnimationStateRight
          jmp ShouldPreserveFacingInlineYes2
GetAnimationStateRight:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterGetPlayerAnimationStateInline2-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerAnimationStateInline2 hi (encoded)]
          lda # <(AfterGetPlayerAnimationStateInline2-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerAnimationStateInline2 hi (encoded)] [SP+0: AfterGetPlayerAnimationStateInline2 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerAnimationStateInline2 hi (encoded)] [SP+1: AfterGetPlayerAnimationStateInline2 lo] [SP+0: GetPlayerAnimationStateFunction hi (raw)]
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerAnimationStateInline2 hi (encoded)] [SP+2: AfterGetPlayerAnimationStateInline2 lo] [SP+1: GetPlayerAnimationStateFunction hi (raw)] [SP+0: GetPlayerAnimationStateFunction lo]
          ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateInline2:


          ;; If temp2 < 5, then jmp ShouldPreserveFacingInlineNo2          lda temp2          cmp 5          bcs .skip_5155          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightSPF
          jmp ShouldPreserveFacingInlineNo2
CheckAnimationState10RightSPF:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightLabelSPF
          jmp ShouldPreserveFacingInlineNo2
CheckAnimationState10RightLabelSPF:

          

          lda temp2
          cmp # 10
          bcc ShouldPreserveFacingInlineNo2
          jmp ShouldPreserveFacingInlineYes2
ShouldPreserveFacingInlineNo2:


.pend

ShouldPreserveFacingInlineYes2 .proc

          lda # 1
          sta temp3

          jmp ShouldPreserveFacingInlineDone2

.pend

ShouldPreserveFacingInlineNo2 .proc

          lda # 0
          sta temp3

ShouldPreserveFacingInlineDone2:

          ;; Vertical control for flying characters: UP/DOWN
          ;; Returns: Far (return otherbank)

          lda temp3
          bne HandleStandardHorizontalMovementAfterRightSetDoneSecond
          ;; Set playerState[temp1] = playerState[temp1] | 1
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 1
          sta playerState,x
HandleStandardHorizontalMovementAfterRightSetDoneSecond:


          ;; If temp1 & 2 = 0, then jmp HandleFlyingCharacterMovementVerticalJoy0
          lda temp1
          and # 2
          bne CheckJoy1UpHSHM
          jmp HandleFlyingCharacterMovementVerticalJoy0
CheckJoy1UpHSHM:

          ;; If joy1up, then jmp HandleFlyingCharacterMovementVerticalUp
          lda joy1up
          beq CheckJoy1DownHSHM
          jmp HandleFlyingCharacterMovementVerticalUp
CheckJoy1DownHSHM:

          ;; If joy1down, then jmp HandleFlyingCharacterMovementVerticalDown
          lda joy1down
          beq HandleFlyingCharacterMovementDoneJoy1
          jmp HandleFlyingCharacterMovementVerticalDown
HandleFlyingCharacterMovementDoneJoy1:

          jmp BS_return

.pend

HandleFlyingCharacterMovementVerticalJoy0 .proc

          ;; If joy0up, then jmp HandleFlyingCharacterMovementVerticalUp
          lda joy0up
          beq CheckJoy0Down
          jmp HandleFlyingCharacterMovementVerticalUp
CheckJoy0Down:

          ;; If joy0down, then jmp HandleFlyingCharacterMovementVerticalDown
          lda joy0down
          beq HandleFlyingCharacterMovementDoneJoy0
          jmp HandleFlyingCharacterMovementVerticalDown
HandleFlyingCharacterMovementDoneJoy0:

          rts

.pend

HandleFlyingCharacterMovementVerticalUp .proc

          rts

.pend

HandleFlyingCharacterMovementVerticalDown .proc

          rts

.pend

InputHandleLeftPortPlayerFunction:




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

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterGetPlayerAnimationStateLeftPort-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerAnimationStateLeftPort hi (encoded)]
          lda # <(AfterGetPlayerAnimationStateLeftPort-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerAnimationStateLeftPort hi (encoded)] [SP+0: AfterGetPlayerAnimationStateLeftPort lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerAnimationStateLeftPort hi (encoded)] [SP+1: AfterGetPlayerAnimationStateLeftPort lo] [SP+0: GetPlayerAnimationStateFunction hi (raw)]
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerAnimationStateLeftPort hi (encoded)] [SP+2: AfterGetPlayerAnimationStateLeftPort lo] [SP+1: GetPlayerAnimationStateFunction hi (raw)] [SP+0: GetPlayerAnimationStateFunction lo]
          ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateLeftPort:


          ;; Use jmp to avoid branch out of range (target is 310+ bytes away)

          ;; Block movement during attack windup/execute/recovery

          ;; If temp2 >= 13, then jmp DoneLeftPortMovement
          lda temp2
          cmp # 13

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

DoneLeftPortMovement:

.pend

IHLP_RadishGoblinMovement .proc

          ;; Cross-bank call to RadishGoblinHandleInput in bank 11
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterRadishGoblinHandleInputLeftPort-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRadishGoblinHandleInputLeftPort hi (encoded)]
          lda # <(AfterRadishGoblinHandleInputLeftPort-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRadishGoblinHandleInputLeftPort hi (encoded)] [SP+0: AfterRadishGoblinHandleInputLeftPort lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RadishGoblinHandleInput-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRadishGoblinHandleInputLeftPort hi (encoded)] [SP+1: AfterRadishGoblinHandleInputLeftPort lo] [SP+0: RadishGoblinHandleInput hi (raw)]
          lda # <(RadishGoblinHandleInput-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRadishGoblinHandleInputLeftPort hi (encoded)] [SP+2: AfterRadishGoblinHandleInputLeftPort lo] [SP+1: RadishGoblinHandleInput hi (raw)] [SP+0: RadishGoblinHandleInput lo]
          ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleInputLeftPort:


          jmp DoneLeftPortMovement

.pend

IHLP_FlyingMovement .proc

          ;; Cross-bank call to HandleFlyingCharacterMovement in bank 11
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterHandleFlyingCharacterMovementLeftPort-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterHandleFlyingCharacterMovementLeftPort hi (encoded)]
          lda # <(AfterHandleFlyingCharacterMovementLeftPort-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterHandleFlyingCharacterMovementLeftPort hi (encoded)] [SP+0: AfterHandleFlyingCharacterMovementLeftPort lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(HandleFlyingCharacterMovement-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterHandleFlyingCharacterMovementLeftPort hi (encoded)] [SP+1: AfterHandleFlyingCharacterMovementLeftPort lo] [SP+0: HandleFlyingCharacterMovement hi (raw)]
          lda # <(HandleFlyingCharacterMovement-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterHandleFlyingCharacterMovementLeftPort hi (encoded)] [SP+2: AfterHandleFlyingCharacterMovementLeftPort lo] [SP+1: HandleFlyingCharacterMovement hi (raw)] [SP+0: HandleFlyingCharacterMovement lo]
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
          cmp # 32

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

          ;; Cross-bank call to RoboTitoDown in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterRoboTitoDownInput1-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRoboTitoDownInput1 hi (encoded)]
          lda # <(AfterRoboTitoDownInput1-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRoboTitoDownInput1 hi (encoded)] [SP+0: AfterRoboTitoDownInput1 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRoboTitoDownInput1 hi (encoded)] [SP+1: AfterRoboTitoDownInput1 lo] [SP+0: RoboTitoDown hi (raw)]
          lda # <(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRoboTitoDownInput1 hi (encoded)] [SP+2: AfterRoboTitoDownInput1 lo] [SP+1: RoboTitoDown hi (raw)] [SP+0: RoboTitoDown lo]
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


HandleGuardInputDoneLeftPort:



          ;; Process attack input

          ;; Map MethHound (31) to ShamoneAttack handler

          ;; Use cached animation state - block attack input during

          ;; attack

          ;; animations (states 13-15)

          ;; Block attack input during attack windup/execute/recovery

          ;; If temp2 >= 13, then jmp InputDoneLeftPortAttack
          lda temp2
          cmp # 13

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

          ;; If (playerState[temp1] & PlayerStateBitFacing), then jmp InputDoneLeftPortAttack
          lda temp1
          asl
          tax
          lda playerState,x
          and # PlayerStateBitFacing
          beq InputDoneLeftPortAttackSkipSecond
          jmp InputDoneLeftPortAttack
InputDoneLeftPortAttackSkipSecond:

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


InputDoneLeftPortAttack:





          rts

.pend

InputHandleRightPortPlayerFunction:




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
          cmp # 13

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

DoneRightPortMovement:

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
          cmp # 32

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

          ;; Cross-bank call to RadishGoblinHandleStickDown in bank 11
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterRadishGoblinHandleStickDownRightPort-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRadishGoblinHandleStickDownRightPort hi (encoded)]
          lda # <(AfterRadishGoblinHandleStickDownRightPort-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRadishGoblinHandleStickDownRightPort hi (encoded)] [SP+0: AfterRadishGoblinHandleStickDownRightPort lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RadishGoblinHandleStickDown-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRadishGoblinHandleStickDownRightPort hi (encoded)] [SP+1: AfterRadishGoblinHandleStickDownRightPort lo] [SP+0: RadishGoblinHandleStickDown hi (raw)]
          lda # <(RadishGoblinHandleStickDown-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRadishGoblinHandleStickDownRightPort hi (encoded)] [SP+2: AfterRadishGoblinHandleStickDownRightPort lo] [SP+1: RadishGoblinHandleStickDown hi (raw)] [SP+0: RadishGoblinHandleStickDown lo]
          ldx # 11
          jmp BS_jsr
AfterRadishGoblinHandleStickDownRightPort:


          jmp StandardGuard

.pend

DCD_HandleRoboTitoDown2 .proc

          ;; Cross-bank call to RoboTitoDown in bank 12
          ;; Return address: ENCODED with caller bank 12 ($c0) for BS_return to decode
          lda # ((>(AfterRoboTitoDownInput2-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRoboTitoDownInput2 hi (encoded)]
          lda # <(AfterRoboTitoDownInput2-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRoboTitoDownInput2 hi (encoded)] [SP+0: AfterRoboTitoDownInput2 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRoboTitoDownInput2 hi (encoded)] [SP+1: AfterRoboTitoDownInput2 lo] [SP+0: RoboTitoDown hi (raw)]
          lda # <(RoboTitoDown-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRoboTitoDownInput2 hi (encoded)] [SP+2: AfterRoboTitoDownInput2 lo] [SP+1: RoboTitoDown hi (raw)] [SP+0: RoboTitoDown lo]
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


HandleGuardInputDoneRightPort:



          ;; Process attack input

          ;; Use cached animation state - block attack input during

          ;; attack

          ;; animations (states 13-15)

          ;; Block attack input during attack windup/execute/recovery

          ;; If temp2 >= 13, then jmp InputDoneRightPortAttack
          lda temp2
          cmp # 13

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


InputDoneRightPortAttack:

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

          ;; If systemFlags & SystemFlagGameStatePaused, then set systemFlags = systemFlags & ClearSystemFlagGameStatePaused, else set systemFlags = systemFlags | SystemFlagGameStatePaused
          lda systemFlags
          and # SystemFlagGameStatePaused
          beq SetPausedFlag
          lda systemFlags
          and # ClearSystemFlagGameStatePaused
          sta systemFlags
          jmp PauseToggleDone
SetPausedFlag:
          lda systemFlags
          ora # SystemFlagGameStatePaused
          sta systemFlags
PauseToggleDone:

DonePauseToggle:

          ;; Toggle pause (0<->1)





          ;; Update pause button previous state in systemFlags

          ;; Update previous button state for next frame
          ;; If temp1, then set systemFlags = systemFlags | SystemFlagPauseButtonPrev, else set systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev
          lda temp1
          beq ClearPauseButtonPrev
          lda systemFlags
          ora # SystemFlagPauseButtonPrev
          sta systemFlags
          jmp PauseButtonPrevUpdateDone
ClearPauseButtonPrev:
          lda systemFlags
          and ClearSystemFlagPauseButtonPrev
          sta systemFlags
PauseButtonPrevUpdateDone:



          rts



.pend

