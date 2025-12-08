GetPlayerAnimationStateFunction
;;; Returns: Far (return otherbank)


;; GetPlayerAnimationStateFunction (duplicate)




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

                    ;; let temp2 = playerState[temp1] & 240         
          lda temp1
          asl
          tax
          ;; lda playerState,x (duplicate)
          sta temp2

          ;; Mask bits 4-7 (value 240 = %11110000)

                    ;; let temp2 = temp2 / 16

          ;; Shift right by 4 (divide by 16) to get animation sta


          ;; (0-15)
          jsr BS_return




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
          ;; Called Routines: IsPlayerAlive (bank13) - checks if player is

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

          ;; InputSkipPlayer4Input (all called via goto or gosub)

                    ;; if qtcontroller then goto InputHandleQuadtariPlayers
          ;; lda qtcontroller (duplicate)
          beq skip_514
          jmp InputHandleQuadtariPlayers
skip_514:



          ;; Even frame: Handle Players 1 & 2 - only if alive

                    ;; let currentPlayer = 0 : gosub IsPlayerAlive bank13
          ;; lda temp2 (duplicate)
          cmp # 0
          bne skip_299
          ;; jmp InputDonePlayer0Input (duplicate)
skip_299:


                    ;; if (playerState[0] & 8) then goto InputDonePlayer0Input

                    ;; let temp1 = 0
          ;; lda # 0 (duplicate)
          ;; sta temp1 : gosub InputHandleLeftPortPlayerFunction (duplicate)



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



                    ;; let currentPlayer = 1 : gosub IsPlayerAlive bank13
          ;; lda 1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ldx # 12
          ;; jmp BS_jsr (duplicate)
return_point:
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6107 (duplicate)
          ;; jmp InputDonePlayer1Input (duplicate)
skip_6107:


                    ;; if (playerState[1] & 8) then goto InputDonePlayer1Input
          ;; jmp InputHandlePlayer1 (duplicate)



          ;; jmp InputDonePlayer1Input (duplicate)



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

          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)

          ;; jsr InputHandleRightPortPlayerFunction (duplicate)

InputDonePlayer1Input

          ;; Player 1 uses Joy1
          ;; Returns: Far (return otherbank)

          ;; jsr BS_return (duplicate)

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
          ;; Called Routines: IsPlayerAlive (bank13) - checks if player is

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

          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; cmp # 0 (duplicate)
          ;; bne skip_9975 (duplicate)
          ;; jmp InputDonePlayer3Input (duplicate)
skip_9975:


                    ;; if playerCharacter[2] = NoCharacter then goto InputDonePlayer3Input

                    ;; let currentPlayer = 2 : gosub IsPlayerAlive bank13
          ;; lda 2 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_2411 (duplicate)
          ;; jmp InputDonePlayer3Input (duplicate)
skip_2411:


                    ;; if (playerState[2] & 8) then goto InputDonePlayer3Input

                    ;; let temp1 = 2
          ;; lda # 2 (duplicate)
          ;; sta temp1 : gosub InputHandleLeftPortPlayerFunction (duplicate)



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
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3451 (duplicate)
          ;; jmp InputDonePlayer4Input (duplicate)
skip_3451:


                    ;; if playerCharacter[3] = NoCharacter then goto InputDonePlayer4Input

                    ;; let currentPlayer = 3 : gosub IsPlayerAlive bank13
          ;; lda 3 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4413 (duplicate)
          ;; jmp InputDonePlayer4Input (duplicate)
skip_4413:


                    ;; if (playerState[3] & 8) then goto InputDonePlayer4Input

                    ;; let temp1 = 3
          ;; lda # 3 (duplicate)
          ;; sta temp1 : gosub InputHandleRightPortPlayerFunction (duplicate)



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
          ;; jsr BS_return (duplicate)



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

          ;; jsr BS_return (duplicate)

          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_423 (duplicate)
          ;; jmp HGI_CheckJoy0 (duplicate)
skip_423:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6625 (duplicate)
          ;; jmp HGI_CheckJoy0 (duplicate)
skip_6625:


          ;; lda joy1down (duplicate)
          ;; bne skip_1073 (duplicate)
          ;; jmp HGI_CheckGuardRelease (duplicate)
skip_1073:


          ;; jmp HGI_HandleDownPressed (duplicate)

.pend

HGI_CheckJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; lda joy0down (duplicate)
          ;; bne skip_6941 (duplicate)
          ;; jmp HGI_CheckGuardRelease (duplicate)
skip_6941:


.pend

HGI_HandleDownPressed .proc

          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)

                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; jsr BS_return (duplicate)

          ;; lda temp4 (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_4030 (duplicate)
          ;; jmp DragonOfStormsDown (duplicate)
skip_4030:


          ;; lda temp4 (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_6818 (duplicate)
          ;; jmp HarpyDown (duplicate)
skip_6818:


          ;; lda temp4 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_7443 (duplicate)
          ;; jmp FrootyDown (duplicate)
skip_7443:


          ;; lda temp4 (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_2206 (duplicate)
          ;; jmp DCD_HandleRoboTitoDown (duplicate)
skip_2206:


          ;; jmp StandardGuard (duplicate)

.pend

DCD_HandleRoboTitoDown .proc

          ;; Cross-bank call to RoboTitoDown in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          rts

          ;; jmp StandardGuard (duplicate)

.pend

HGI_CheckGuardRelease .proc

          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)

                    ;; let temp2 = playerState[temp1] & 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; Not guarding, nothing to do

          ;; jsr BS_return (duplicate)

          ;; Stop guard early and start cooldown

                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)

          ;; Start cooldown timer
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda GuardTimerMaxFrames (duplicate)
          ;; sta playerTimers_W,x (duplicate)

          ;; jsr BS_return (duplicate)



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

          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_5863 (duplicate)
          ;; jmp HUIEB_UseJoy0 (duplicate)
skip_5863:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_2993 (duplicate)
          ;; jmp HUIEB_UseJoy0 (duplicate)
skip_2993:


          ;; lda joy1up (duplicate)
          ;; bne skip_1791 (duplicate)
          ;; jmp HUIEB_CheckEnhanced (duplicate)
skip_1791:


          ;; jmp HUIEB_HandleUp (duplicate)

.pend

HUIEB_UseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; lda joy0up (duplicate)
          ;; bne skip_9467 (duplicate)
          ;; jmp HUIEB_CheckEnhanced (duplicate)
skip_9467:


.pend

HUIEB_HandleUp .proc

          ;; Check Shamone form switching first (Shamone <-> MethHound)
          ;; Returns: Far (return otherbank)

          ;; Switch Shamone -> MethHound

          ;; jsr BS_return (duplicate)

          ;; Switch MethHound -> Shamone

          ;; jsr BS_return (duplicate)

          ;; Robo Tito: Hold UP to ascend; auto-latch on ceiling contact

          ;; Check Bernie fall-through

                    ;; if playerCharacter[temp1] = CharacterRoboTito then goto HUIEB_RoboTitoAscend

          ;; Check Harpy flap

                    ;; if playerCharacter[temp1] = CharacterBernie then goto HUIEB_BernieFallThrough
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterBernie (duplicate)
          ;; bne skip_2293 (duplicate)
          ;; jmp HUIEB_BernieFallThrough (duplicate)
skip_2293:

          ;; For all other characters, UP is jump

                    ;; if playerCharacter[temp1] = CharacterHarpy then goto HUIEB_HarpyFlap
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_4862 (duplicate)
          ;; jmp HUIEB_HarpyFlap (duplicate)
skip_4862:
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jmp HUIEB_CheckEnhanced (duplicate)

HUIEB_RoboTitoAscend

          ;; Ascend toward ceiling
          ;; Returns: Far (return otherbank)

          ;; Save cached animation state (temp2) - will be restored after playfield read

          ;; lda temp2 (duplicate)
          ;; sta temp5 (duplicate)

                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6

                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; Compute playfield column

                    ;; let playerY[temp1] = playerY[temp1] - temp6

                    ;; let temp4 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; ;; let temp4 = temp4 - ScreenInsetX          lda temp4          sec          sbc ScreenInsetX          sta temp4
          ;; lda temp4 (duplicate)
          sec
          sbc ScreenInsetX
          ;; sta temp4 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp4 (duplicate)



            lsr temp4

            ;; lsr temp4 (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp # 32 (duplicate)
          bcc skip_6225
          ;; lda # 31 (duplicate)
          ;; sta temp4 (duplicate)
skip_6225:


          ;; Compute head row and check ceiling contact

                    ;; if temp4 & $80 then let temp4 = 0

                    ;; let temp3 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)


            ;; lsr temp3 (duplicate)

            ;; lsr temp3 (duplicate)

            ;; lsr temp3 (duplicate)

            ;; lsr temp3 (duplicate)


          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_7303 (duplicate)
          ;; jmp HUIEB_RoboTitoLatch (duplicate)
skip_7303:


          dec temp3

          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Restore cached animation sta


          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp5 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Clear latch if DOWN pressed (check appropriate joy port)

                    ;; if temp1 then goto HUIEB_RoboTitoLatch
          ;; lda temp1 (duplicate)
          ;; beq skip_8947 (duplicate)
          ;; jmp HUIEB_RoboTitoLatch (duplicate)
skip_8947:

          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1042 (duplicate)
          ;; jmp HUIEB_RoboTitoCheckJoy0 (duplicate)
skip_1042:


          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6975 (duplicate)
          ;; jmp HUIEB_RoboTitoCheckJoy0 (duplicate)
skip_6975:


                    ;; if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)          lda joy1down          beq skip_7336
skip_7336:
          ;; jmp skip_7336 (duplicate)
          ;; jmp HUIEB_RoboTitoDone (duplicate)

.pend

HUIEB_RoboTitoCheckJoy0 .proc

                    ;; if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)          lda joy0down          beq skip_9849
skip_9849:
          ;; jmp skip_9849 (duplicate)

HUIEB_RoboTitoDone
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

          ;; rts (duplicate)

.pend

HUIEB_RoboTitoLatch .proc

          ;; Restore cached animation sta

          ;; Returns: Far (return otherbank)

          ;; lda temp5 (duplicate)
          ;; sta temp2 (duplicate)

                    ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

HUIEB_BernieFallThrough .proc

          ;; Bernie UP input handled in BernieJump routine (fall through 1-row floors)
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to BernieJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BernieJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BernieJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

HUIEB_HarpyFlap .proc

          ;; Harpy UP input handled in HarpyJump routine (flap to fly)
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to HarpyJump in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HarpyJump-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HarpyJump-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

HUIEB_CheckEnhanced .proc

          ;; Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          ;; Returns: Far (return otherbank)

          ;; Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only

          ;; Note: For Bernie, UP is fall-through, so jump via enhanced buttons only

          ;; Note: For Harpy, UP is flap, so jump via enhanced buttons only

                    ;; if playerCharacter[temp1] = CharacterShamone then goto HUIEB_EnhancedCheck

                    ;; if playerCharacter[temp1] = CharacterMethHound then goto HUIEB_EnhancedCheck
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterMethHound (duplicate)
          ;; bne skip_2790 (duplicate)
          ;; jmp HUIEB_EnhancedCheck (duplicate)
skip_2790:

                    ;; if playerCharacter[temp1] = CharacterBernie then goto HUIEB_EnhancedCheck
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterBernie (duplicate)
          ;; bne skip_6652 (duplicate)
          ;; jmp HUIEB_EnhancedCheck (duplicate)
skip_6652:

          ;; Bernie and Harpy also use enhanced buttons for jump

                    ;; if playerCharacter[temp1] = CharacterHarpy then goto HUIEB_EnhancedCheck
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_5466 (duplicate)
          ;; jmp HUIEB_EnhancedCheck (duplicate)
skip_5466:
          ;; jmp HUIEB_StandardEnhancedCheck (duplicate)

.pend

HUIEB_EnhancedCheck .proc

          ;; Check Genesis/Joy2b+ Button C/II for alternative UP for any characters
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to CheckEnhancedJumpButton in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckEnhancedJumpButton-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckEnhancedJumpButton-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; For Shamone/Meth Hound, treat enhanced button as UP (toggle forms)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jmp HUIEB_ExecuteJump (duplicate)

.pend

HUIEB_StandardEnhancedCheck .proc

          ;; Check Genesis/Joy2b+ Button C/II
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to CheckEnhancedJumpButton in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckEnhancedJumpButton-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckEnhancedJumpButton-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

.pend

HUIEB_ExecuteJump .proc

          ;; Execute jump if pressed and not already jumping
          ;; Returns: Far (return otherbank)

          ;; Allow Zoe Ryen a single mid-air double-jump

                    ;; if playerCharacter[temp1] = CharacterZoeRyen then goto HUIEB_ZoeJumpCheck

          ;; Already jumping, cannot jump again
          ;; jsr BS_return (duplicate)

          ;; jmp HUIEB_JumpProceed (duplicate)

.pend

HUIEB_ZoeJumpCheck .proc

          ;; lda # 0 (duplicate)
          ;; sta temp6 (duplicate)

                    ;; if (playerState[temp1] & 4) then let temp6 = 1

          ;; Zoe already used double-jump

          ;; rts (duplicate)

.pend

HUIEB_JumpProceed .proc

          ;; Use cached animation state - block jump during attack animations (states 13-15)
          ;; Returns: Far (return otherbank)

          ;; Block jump during attack windup/execute/recovery
          ;; jsr BS_return (duplicate)

          ;; Dispatch character jump via dispatcher (same-bank call)

                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; jsr DispatchCharacterJump (duplicate)

HUIEB_JumpDone

          ;; Set Zoe Ryen double-jump flag if applicable
          ;; Returns: Far (return otherbank)

          ;; lda temp6 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_5085 (duplicate)
                    ;; let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
skip_5085:

          ;; jsr BS_return (duplicate)



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

          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6072 (duplicate)
          ;; jmp HSHM_UseJoy0 (duplicate)
skip_6072:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_4859 (duplicate)
          ;; jmp HSHM_UseJoy0 (duplicate)
skip_4859:


          ;; lda joy1left (duplicate)
          ;; bne skip_1838 (duplicate)
          ;; jmp HSHM_CheckRight (duplicate)
skip_1838:


          ;; jmp HSHM_HandleLeft (duplicate)

.pend

HSHM_UseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; lda joy0left (duplicate)
          ;; bne skip_3856 (duplicate)
          ;; jmp HSHM_CheckRight (duplicate)
skip_3856:


.pend

HSHM_HandleLeft .proc

          ;; Left movement: set negative velocity
          ;; Returns: Far (return otherbank)

                    ;; if playerCharacter[temp1] = CharacterFrooty then goto HSHM_LeftMomentum

                    ;; if playerCharacter[temp1] = CharacterDragonOfStorms then goto HSHM_LeftDirectSubpixel
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_7951 (duplicate)
          ;; jmp HSHM_LeftDirectSubpixel (duplicate)
skip_7951:

                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6

                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; let temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp2 (duplicate)


          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerVelocityX,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; jmp HSHM_AfterLeftSet (duplicate)

.pend

HSHM_LeftDirectSubpixel .proc

          ;; Dragon of Storms: direct velocity with subpixel accuracy
          ;; Returns: Far (return otherbank)

                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6

                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; let temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp2 (duplicate)


          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerVelocityX,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy

          ;; jmp HSHM_AfterLeftSet (duplicate)

.pend

HSHM_LeftMomentum .proc

                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6

                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

.pend

HSHM_AfterLeftSet .proc

          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)

                    ;; if (playerState[temp1] & 8) then goto HSHM_SPF_Yes1

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; ;; if temp2 < 5 then goto HSHM_SPF_No1          lda temp2          cmp 5          bcs .skip_1803          jmp
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          bcs skip_13
          goto_label:

          ;; jmp goto_label (duplicate)
skip_13:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_1041 (duplicate)
          ;; jmp goto_label (duplicate)
skip_1041:

          

          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_6084 (duplicate)
skip_6084:


.pend

HSHM_SPF_Yes1 .proc

          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jmp HSHM_SPF_Done1 (duplicate)

.pend

HSHM_SPF_No1 .proc

          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

HSHM_SPF_Done1

          ;; lda temp3 (duplicate)
          ;; bne skip_6641 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
skip_6641:


.pend

HSHM_CheckRight .proc

          ;; Determine which joy port to use for right movement
          ;; Returns: Far (return otherbank)
          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3331 (duplicate)
          ;; jmp HSHM_CheckRightJoy0 (duplicate)
skip_3331:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_9158 (duplicate)
          ;; jmp HSHM_CheckRightJoy0 (duplicate)
skip_9158:


          ;; jsr BS_return (duplicate)

          ;; jmp HSHM_HandleRight (duplicate)

.pend

HSHM_CheckRightJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; jsr BS_return (duplicate)

.pend

HSHM_HandleRight .proc

          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)

                    ;; if playerCharacter[temp1] = CharacterFrooty then goto HSHM_RightMomentum

                    ;; if playerCharacter[temp1] = CharacterDragonOfStorms then goto HSHM_RightDirectSubpixel
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_9323 (duplicate)
          ;; jmp HSHM_RightDirectSubpixel (duplicate)
skip_9323:

                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6

                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta playerVelocityX,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; jmp HSHM_AfterRightSet (duplicate)

.pend

HSHM_RightDirectSubpixel .proc

          ;; Dragon of Storms: direct velocity with subpixel accuracy
          ;; Returns: Far (return otherbank)

                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6

                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta playerVelocityX,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy

          ;; jmp HSHM_AfterRightSet (duplicate)

.pend

HSHM_RightMomentum .proc

                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6

                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

.pend

HSHM_AfterRightSet .proc

          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)

                    ;; if (playerState[temp1] & 8) then goto HSHM_SPF_Yes2

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; ;; if temp2 < 5 then goto HSHM_SPF_No2          lda temp2          cmp 5          bcs .skip_6914          jmp
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_8503 (duplicate)
          ;; jmp goto_label (duplicate)
skip_8503:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_655 (duplicate)
          ;; jmp goto_label (duplicate)
skip_655:

          

          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_4997 (duplicate)
skip_4997:


.pend

HSHM_SPF_Yes2 .proc

          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jmp HSHM_SPF_Done2 (duplicate)

.pend

HSHM_SPF_No2 .proc

          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

HSHM_SPF_Done2

          ;; lda temp3 (duplicate)
          ;; bne skip_1841 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] | 1
skip_1841:


          ;; rts (duplicate)



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

                    ;; let temp5 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp5 (duplicate)

          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          ;; Players 1,3 use joy1

                    ;; if temp1 & 2 = 0 then goto HFCM_UseJoy0

                    ;; if joy1left then goto HFCM_CheckLeftCollision
          ;; lda joy1left (duplicate)
          ;; beq skip_7089 (duplicate)
          ;; jmp HFCM_CheckLeftCollision (duplicate)
skip_7089:

          ;; jmp HFCM_CheckRightMovement (duplicate)

.pend

HFCM_UseJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

                    ;; if joy0left then goto HFCM_CheckLeftCollision
          ;; lda joy0left (duplicate)
          ;; beq skip_9079 (duplicate)
          ;; jmp HFCM_CheckLeftCollision (duplicate)
skip_9079:

          ;; jmp HFCM_CheckRightMovement (duplicate)

HFCM_CheckLeftCollision

          ;; Convert player position to playfield coordinates
          ;; Returns: Far (return otherbank)

                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)



            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)


          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_9735 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
skip_9735:


                    ;; if temp2 & $80 then let temp2 = 0



          ;; Check column to the left



                    ;; if temp2 <= 0 then goto HFCM_CheckRightMovement
          ;; lda temp2 (duplicate)
          ;; beq HFCM_CheckRightMovement (duplicate)
          bmi HFCM_CheckRightMovement
          ;; jmp skip_8359 (duplicate)
HFCM_CheckRightMovement:
skip_8359:

          ;; Already at left edge
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; checkColumn = column to the left

          ;; Save player index to global variable

          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)

          ;; Check player current row (check both top and bottom of sprite)

                    ;; let temp4 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)


            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)


          ;; pfRow = top row

          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)

          ;; Check if blocked in current row

          ;; Reset left-collision flag

          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
skip_955:
          ;; jmp skip_955 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

          ;; Blocked, cannot move left

          ;; lda temp5 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_2454 (duplicate)
          ;; jmp HFCM_CheckRightMovement (duplicate)
skip_2454:


          ;; Also check bottom row (feet)

          ;; lda temp4 (duplicate)
          clc
          adc # 16
          ;; sta temp2 (duplicate)


            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)


          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)

          ;; Do not check if beyond screen

          ;; if temp6 >= pfrows then goto HFCM_MoveLeftOK
          ;; lda temp6 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_5809 (duplicate)

          ;; jmp skip_5809 (duplicate)

          skip_5809:

          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
;; skip_955: (duplicate)
          ;; jmp skip_955 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp5 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_2454 (duplicate)
          ;; jmp HFCM_CheckRightMovement (duplicate)
;; skip_2454: (duplicate)


.pend

HFCM_MoveLeftOK .proc

          ;; Blocked at bottom too
          ;; Returns: Far (return otherbank)

          ;; lda temp5 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bne skip_2584 (duplicate)
          ;; jmp HFCM_LeftMomentumApply (duplicate)
skip_2584:


          ;; Default (should not hit): apply -1

          ;; lda temp5 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_1139 (duplicate)
          ;; jmp HFCM_LeftDirectApply (duplicate)
skip_1139:


                    ;; let playerVelocityX[temp1] = $ff
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; jmp HFCM_LeftApplyDone (duplicate)

.pend

HFCM_LeftMomentumApply .proc

                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] - CharacterMovementSpeed[temp5]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; jmp HFCM_LeftApplyDone (duplicate)

.pend

HFCM_LeftDirectApply .proc

                    ;; let playerX[temp1] = playerX[temp1] - CharacterMovementSpeed[temp5]

HFCM_LeftApplyDone

          ;; Preserve facing during hurt/recovery states (knockback, hitstun)
          ;; Returns: Far (return otherbank)

          ;; Inline ShouldPreserveFacing logic

                    ;; if (playerState[temp1] & 8) then goto SPF_InlineYes1
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; and # 8 (duplicate)
          ;; beq skip_5121 (duplicate)
          ;; jmp SPF_InlineYes1 (duplicate)
skip_5121:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; ;; if temp2 < 5 then goto SPF_InlineNo1          lda temp2          cmp 5          bcs .skip_6997          jmp
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_5111 (duplicate)
          ;; jmp goto_label (duplicate)
skip_5111:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_3707 (duplicate)
          ;; jmp goto_label (duplicate)
skip_3707:

          

          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_4099 (duplicate)
skip_4099:


.pend

SPF_InlineYes1 .proc

          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jmp SPF_InlineDone1 (duplicate)

.pend

SPF_InlineNo1 .proc

          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

SPF_InlineDone1

          ;; lda temp3 (duplicate)
          ;; bne skip_6641 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
;; skip_6641: (duplicate)


.pend

;; HFCM_CheckRightMovement .proc (duplicate)

          ;; Determine which joy port to use for right movement
          ;; Returns: Far (return otherbank)
          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_9636 (duplicate)
          ;; jmp HFCM_CheckRightJoy0 (duplicate)
skip_9636:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_2368 (duplicate)
          ;; jmp HFCM_CheckRightJoy0 (duplicate)
skip_2368:


          ;; jsr BS_return (duplicate)

          ;; jmp HFCM_DoRightMovement (duplicate)

.pend

HFCM_CheckRightJoy0 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; jsr BS_return (duplicate)

.pend

HFCM_DoRightMovement .proc

          ;; Convert player position to playfield coordinates
          ;; Returns: Far (return otherbank)

                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)



            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)


          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_9735 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
;; skip_9735: (duplicate)


                    ;; if temp2 & $80 then let temp2 = 0



          ;; Check column to the right
          ;; jsr BS_return (duplicate)

          ;; Already at right edge

          ;; lda temp2 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; checkColumn = column to the right

          ;; Save player index to global variable

          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)

          ;; Check player current row (check both top and bottom of sprite)

                    ;; let temp4 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)


            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)


          ;; pfRow = top row

          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)

          ;; Check if blocked in current row

          ;; Reset right-collision flag

          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
;; skip_955: (duplicate)
          ;; jmp skip_955 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

          ;; Blocked, cannot move right

          ;; jsr BS_return (duplicate)

          ;; Also check bottom row (feet)

          ;; lda temp4 (duplicate)
          ;; clc (duplicate)
          ;; adc # 16 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)


            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)


          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)

          ;; Do not check if beyond screen

          ;; if temp6 >= pfrows then goto HFCM_MoveRightOK
          ;; lda temp6 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_8465 (duplicate)

          ;; jmp skip_8465 (duplicate)

          skip_8465:

          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp1 then let temp5 = 1          lda temp1          beq skip_955
;; skip_955: (duplicate)
          ;; jmp skip_955 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

HFCM_MoveRightOK .proc

          ;; Blocked at bottom too
          ;; Returns: Far (return otherbank)

          ;; lda temp5 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bne skip_7212 (duplicate)
          ;; jmp HFCM_RightMomentumApply (duplicate)
skip_7212:


          ;; Default (should not hit): apply +1

          ;; lda temp5 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_8983 (duplicate)
          ;; jmp HFCM_RightDirectApply (duplicate)
skip_8983:


          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerVelocityX,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; jmp HFCM_RightApplyDone (duplicate)

.pend

HFCM_RightMomentumApply .proc

                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] + CharacterMovementSpeed[temp5]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; jmp HFCM_RightApplyDone (duplicate)

.pend

HFCM_RightDirectApply .proc

                    ;; let playerX[temp1] = playerX[temp1] + CharacterMovementSpeed[temp5]

HFCM_RightApplyDone

          ;; Preserve facing during hurt/recovery states while processing right movement
          ;; Returns: Far (return otherbank)

          ;; Inline ShouldPreserveFacing logic

                    ;; if (playerState[temp1] & 8) then goto SPF_InlineYes2
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; and # 8 (duplicate)
          ;; beq skip_422 (duplicate)
          ;; jmp SPF_InlineYes2 (duplicate)
skip_422:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; ;; if temp2 < 5 then goto SPF_InlineNo2          lda temp2          cmp 5          bcs .skip_5155          jmp
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_9488 (duplicate)
          ;; jmp goto_label (duplicate)
skip_9488:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_3353 (duplicate)
          ;; jmp goto_label (duplicate)
skip_3353:

          

          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_2500 (duplicate)
skip_2500:


.pend

SPF_InlineYes2 .proc

          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)

          ;; jmp SPF_InlineDone2 (duplicate)

.pend

SPF_InlineNo2 .proc

          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

SPF_InlineDone2

          ;; Vertical control for flying characters: UP/DOWN
          ;; Returns: Far (return otherbank)

          ;; lda temp3 (duplicate)
          ;; bne skip_1841 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] | 1
;; skip_1841: (duplicate)


                    ;; if temp1 & 2 = 0 then goto HFCM_VertJoy0
          ;; lda temp1 (duplicate)
          ;; and # 2 (duplicate)
          ;; bne skip_244 (duplicate)
          ;; jmp HFCM_VertJoy0 (duplicate)
skip_244:

                    ;; if joy1up then goto HFCM_VertUp
          ;; lda joy1up (duplicate)
          ;; beq skip_3244 (duplicate)
          ;; jmp HFCM_VertUp (duplicate)
skip_3244:

                    ;; if joy1down then goto HFCM_VertDown
          ;; lda joy1down (duplicate)
          ;; beq skip_9526 (duplicate)
          ;; jmp HFCM_VertDown (duplicate)
skip_9526:

          ;; jsr BS_return (duplicate)

.pend

HFCM_VertJoy0 .proc

                    ;; if joy0up then goto HFCM_VertUp
          ;; lda joy0up (duplicate)
          ;; beq skip_6096 (duplicate)
          ;; jmp HFCM_VertUp (duplicate)
skip_6096:

                    ;; if joy0down then goto HFCM_VertDown
          ;; lda joy0down (duplicate)
          ;; beq skip_3350 (duplicate)
          ;; jmp HFCM_VertDown (duplicate)
skip_3350:

          ;; rts (duplicate)

.pend

HFCM_VertUp .proc

          ;; rts (duplicate)

          ;; rts (duplicate)

          ;; rts (duplicate)

.pend

HFCM_VertDown .proc

          ;; rts (duplicate)

          ;; rts (duplicate)

          ;; rts (duplicate)



InputHandleLeftPortPlayerFunction


;; InputHandleLeftPortPlayerFunction (duplicate)




          ;;
          ;; LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)

          ;;
          ;; INPUT: temp1 = player index (0 or 2)

          ;; USES: joy0left, joy0right, joy0up, joy0down, joy0fire

          ;; Cache animation state at start (used for movement, jump,

          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)

          ;; and attack checks)

          ;; block movement during attack animations (states 13-15)

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Use goto to avoid branch out of range (target is 310+ bytes away)

          ;; Block movement during attack windup/execute/recovery

          ;; if temp2 >= 13 then goto DoneLeftPortMovement
          ;; lda temp2 (duplicate)
          ;; cmp 13 (duplicate)

          ;; bcc skip_243 (duplicate)

          ;; jmp skip_243 (duplicate)

          skip_243:



          ;; Process left/right movement (with playfield collision for

          ;; flying characters)

          ;; Frooty (8) and Dragon of Storms (2) need collision checks

          ;; for horizontal movement

                    ;; let temp5 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp5 (duplicate)

          ;; Use goto to avoid branch out of range (target is 298+ bytes away)

          ;; lda temp5 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bne skip_8078 (duplicate)
          ;; jmp IHLP_FlyingMovement (duplicate)
skip_8078:


          ;; Radish Goblin (12) uses bounce movement system

          ;; lda temp5 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_243 (duplicate)
          ;; jmp IHLP_FlyingMovement (duplicate)
;; skip_243: (duplicate)


          ;; lda temp5 (duplicate)
          ;; cmp CharacterRadishGoblin (duplicate)
          ;; bne skip_957 (duplicate)
          ;; jmp IHLP_RadishGoblinMovement (duplicate)
skip_957:




          ;; Standard horizontal movement (modifies velocity, not position)

          ;; jsr HandleStandardHorizontalMovement (duplicate)

DoneLeftPortMovement

.pend

IHLP_RadishGoblinMovement .proc

          ;; Cross-bank call to RadishGoblinHandleInput in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinHandleInput-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinHandleInput-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp DoneLeftPortMovement (duplicate)

.pend

IHLP_FlyingMovement .proc

          ;; Cross-bank call to HandleFlyingCharacterMovement in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HandleFlyingCharacterMovement-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HandleFlyingCharacterMovement-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


IHLP_DoneFlyingLeftRight



          ;; Process UP input and enhanced button (Button II)

          ;; temp2 already contains cached animation state from GetPlayerAnimationStateFunction

          ;; jsr HandleUpInputAndEnhancedButton (duplicate)



          ;; Process down/guard input (inlined for performance)

          ;; Frooty cannot guard

          ;; Players 0,2 use joy0; Players 1,3 use joy1

                    ;; if playerCharacter[temp1] = CharacterFrooty then goto HGI_Done1
          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6012 (duplicate)
          ;; jmp HGI_CheckJoy0_1 (duplicate)
skip_6012:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_1669 (duplicate)
          ;; jmp HGI_CheckJoy0_1 (duplicate)
skip_1669:


          ;; lda joy1down (duplicate)
          ;; bne skip_9580 (duplicate)
          ;; jmp HGI_CheckGuardRelease1 (duplicate)
skip_9580:


          ;; jmp HGI_HandleDownPressed1 (duplicate)

.pend

HGI_CheckJoy0_1 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; lda joy0down (duplicate)
          ;; bne skip_7206 (duplicate)
          ;; jmp HGI_CheckGuardRelease1 (duplicate)
skip_7206:


.pend

HGI_HandleDownPressed1 .proc

          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)

                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; if temp4 >= 32 then goto HGI_Done1
          ;; lda temp4 (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_8692 (duplicate)

          ;; jmp skip_8692 (duplicate)

          skip_8692:

          ;; lda temp4 (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_4030 (duplicate)
          ;; jmp DragonOfStormsDown (duplicate)
;; skip_4030: (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_6818 (duplicate)
          ;; jmp HarpyDown (duplicate)
;; skip_6818: (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_7443 (duplicate)
          ;; jmp FrootyDown (duplicate)
;; skip_7443: (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_7846 (duplicate)
          ;; jmp DCD_HandleRoboTitoDown1 (duplicate)
skip_7846:


          ;; lda temp4 (duplicate)
          ;; cmp CharacterRadishGoblin (duplicate)
          ;; bne skip_1660 (duplicate)
          ;; jmp HGI_HandleRadishGoblinDown1 (duplicate)
skip_1660:


          ;; jmp StandardGuard (duplicate)

.pend

HGI_HandleRadishGoblinDown1 .proc

          ;; Radish Goblin: drop momentum + normal guarding
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDown in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinHandleStickDown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinHandleStickDown-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp StandardGuard (duplicate)

.pend

DCD_HandleRoboTitoDown1 .proc

          ;; Cross-bank call to RoboTitoDown in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; lda temp2 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_4364 (duplicate)
          ;; jmp HGI_Done1 (duplicate)
skip_4364:


          ;; jmp StandardGuard (duplicate)

.pend

HGI_CheckGuardRelease1 .proc

          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)

                    ;; let temp2 = playerState[temp1] & 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; Not guarding, check for Radish Goblin short bounce

          ;; lda temp2 (duplicate)
          ;; bne skip_1931 (duplicate)
          ;; jmp HGI_CheckRadishGoblinRelease1 (duplicate)
skip_1931:


          ;; Stop guard early and start cooldown

                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)

          ;; Start cooldown timer
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda GuardTimerMaxFrames (duplicate)
          ;; sta playerTimers_W,x (duplicate)

.pend

HGI_CheckRadishGoblinRelease1 .proc

          ;; Check if Radish Goblin and apply short bounce on stick down release
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDownRelease in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinHandleStickDownRelease-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinHandleStickDownRelease-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


HGI_Done1



          ;; Process attack input

          ;; Map MethHound (31) to ShamoneAttack handler

          ;; Use cached animation state - block attack input during

          ;; attack

          ;; animations (states 13-15)

          ;; Block attack input during attack windup/execute/recovery

          ;; if temp2 >= 13 then goto InputDoneLeftPortAttack
          ;; lda temp2 (duplicate)
          ;; cmp 13 (duplicate)

          ;; bcc skip_7711 (duplicate)

          ;; jmp skip_7711 (duplicate)

          skip_7711:

          ;; Check if player is guarding - guard blocks attacks

                    ;; let temp2 = playerState[temp1] & 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; Guarding - block attack input

                    ;; if temp2 then goto InputDoneLeftPortAttack
          ;; lda temp2 (duplicate)
          ;; beq skip_5855 (duplicate)
          ;; jmp InputDoneLeftPortAttack (duplicate)
skip_5855:

          ;; lda joy0fire (duplicate)
          ;; bne skip_8700 (duplicate)
          ;; jmp InputDoneLeftPortAttack (duplicate)
skip_8700:


                    ;; if (playerState[temp1] & PlayerStateBitFacing) then goto InputDoneLeftPortAttack

                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; Cross-bank call to DispatchCharacterAttack in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DispatchCharacterAttack-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DispatchCharacterAttack-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


InputDoneLeftPortAttack





          ;; rts (duplicate)



InputHandleRightPortPlayerFunction


;; InputHandleRightPortPlayerFunction (duplicate)




          ;;
          ;; RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)

          ;;
          ;; INPUT: temp1 = player index (1 or 3)

          ;; USES: joy1left, joy1right, joy1up, joy1down, joy1fire

          ;; Cache animation state at start (used for movement, jump,

          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)

          ;; and attack checks)

          ;; block movement during attack animations (states 13-15)

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Use goto to avoid branch out of range (target is 327+ bytes away)

          ;; Block movement during attack windup/execute/recovery

          ;; if temp2 >= 13 then goto DoneRightPortMovement
          ;; lda temp2 (duplicate)
          ;; cmp 13 (duplicate)

          ;; bcc skip_9612 (duplicate)

          ;; jmp skip_9612 (duplicate)

          skip_9612:



          ;; Process left/right movement (with playfield collision for

          ;; flying characters)

          ;; Check if player is guarding - guard blocks movement

                    ;; let temp6 = playerState[temp1] & 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; Use goto to avoid branch out of range (target is 314+ bytes away)

          ;; Guarding - block movement

                    ;; if temp6 then goto DoneRightPortMovement
          ;; lda temp6 (duplicate)
          ;; beq skip_7029 (duplicate)
          ;; jmp DoneRightPortMovement (duplicate)
skip_7029:



          ;; Frooty and Dragon of Storms need collision checks

          ;; for horizontal movement

                    ;; let temp5 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp5 (duplicate)

          ;; Use goto to avoid branch out of range (target is 302+ bytes away)

          ;; lda temp5 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_7457 (duplicate)
          ;; jmp IHRP_FlyingMovement (duplicate)
skip_7457:


          ;; Radish Goblin (12) uses bounce movement system

          ;; lda temp5 (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_6901 (duplicate)
          ;; jmp IHRP_FlyingMovement (duplicate)
skip_6901:


          ;; lda temp5 (duplicate)
          ;; cmp CharacterRadishGoblin (duplicate)
          ;; bne skip_8331 (duplicate)
          ;; jmp IHRP_RadishGoblinMovement (duplicate)
skip_8331:




          ;; Standard horizontal movement (no collision check)

          ;; jsr HandleStandardHorizontalMovement (duplicate)

DoneRightPortMovement

.pend

IHRP_RadishGoblinMovement .proc

          ;; Cross-bank call to RadishGoblinHandleInput in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinHandleInput-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinHandleInput-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp DoneRightPortMovement (duplicate)

.pend

IHRP_FlyingMovement .proc

          ;; Cross-bank call to HandleFlyingCharacterMovement in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HandleFlyingCharacterMovement-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HandleFlyingCharacterMovement-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


IHRP_DoneFlyingLeftRight





          ;; Process UP input and enhanced button (Button II)

          ;; temp2 already contains cached animation state from GetPlayerAnimationStateFunction

          ;; Process down/guard input (inlined for performance)

          ;; jsr HandleUpInputAndEnhancedButton (duplicate)

          ;; Frooty cannot guard

          ;; Players 0,2 use joy0; Players 1,3 use joy1

                    ;; if playerCharacter[temp1] = CharacterFrooty then goto HGI_Done2
          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4636 (duplicate)
          ;; jmp HGI_CheckJoy0_2 (duplicate)
skip_4636:


          ;; Players 1,3 use joy1

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_8597 (duplicate)
          ;; jmp HGI_CheckJoy0_2 (duplicate)
skip_8597:


          ;; lda joy1down (duplicate)
          ;; bne skip_9573 (duplicate)
          ;; jmp HGI_CheckGuardRelease2 (duplicate)
skip_9573:


          ;; jmp HGI_HandleDownPressed2 (duplicate)

.pend

HGI_CheckJoy0_2 .proc

          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)

          ;; lda joy0down (duplicate)
          ;; bne skip_8408 (duplicate)
          ;; jmp HGI_CheckGuardRelease2 (duplicate)
skip_8408:


.pend

HGI_HandleDownPressed2 .proc

          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)

                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; if temp4 >= 32 then goto HGI_Done2
          ;; lda temp4 (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_7177 (duplicate)

          ;; jmp skip_7177 (duplicate)

          skip_7177:

          ;; lda temp4 (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_4030 (duplicate)
          ;; jmp DragonOfStormsDown (duplicate)
;; skip_4030: (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_6818 (duplicate)
          ;; jmp HarpyDown (duplicate)
;; skip_6818: (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_7443 (duplicate)
          ;; jmp FrootyDown (duplicate)
;; skip_7443: (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_399 (duplicate)
          ;; jmp DCD_HandleRoboTitoDown2 (duplicate)
skip_399:


          ;; lda temp4 (duplicate)
          ;; cmp CharacterRadishGoblin (duplicate)
          ;; bne skip_2539 (duplicate)
          ;; jmp HGI_HandleRadishGoblinDown2 (duplicate)
skip_2539:


          ;; jmp StandardGuard (duplicate)

.pend

HGI_HandleRadishGoblinDown2 .proc

          ;; Radish Goblin: drop momentum + normal guarding
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDown in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinHandleStickDown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinHandleStickDown-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp StandardGuard (duplicate)

.pend

DCD_HandleRoboTitoDown2 .proc

          ;; Cross-bank call to RoboTitoDown in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; lda temp2 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_8967 (duplicate)
          ;; jmp HGI_Done2 (duplicate)
skip_8967:


          ;; jmp StandardGuard (duplicate)

.pend

HGI_CheckGuardRelease2 .proc

          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)

                    ;; let temp2 = playerState[temp1] & 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; Not guarding, check for Radish Goblin short bounce

          ;; lda temp2 (duplicate)
          ;; bne skip_1080 (duplicate)
          ;; jmp HGI_CheckRadishGoblinRelease2 (duplicate)
skip_1080:


          ;; Stop guard early and start cooldown

                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)

          ;; Start cooldown timer
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda GuardTimerMaxFrames (duplicate)
          ;; sta playerTimers_W,x (duplicate)

.pend

HGI_CheckRadishGoblinRelease2 .proc

          ;; Check if Radish Goblin and apply short bounce on stick down release
          ;; Returns: Far (return otherbank)

          ;; Cross-bank call to RadishGoblinHandleStickDownRelease in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinHandleStickDownRelease-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinHandleStickDownRelease-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


HGI_Done2



          ;; Process attack input

          ;; Use cached animation state - block attack input during

          ;; attack

          ;; animations (states 13-15)

          ;; Block attack input during attack windup/execute/recovery

          ;; if temp2 >= 13 then goto InputDoneRightPortAttack
          ;; lda temp2 (duplicate)
          ;; cmp 13 (duplicate)

          ;; bcc skip_7237 (duplicate)

          ;; jmp skip_7237 (duplicate)

          skip_7237:

                    ;; let temp2 = playerState[temp1] & 2 PlayerStateBitGuarding         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; Guarding - block attack input

                    ;; if temp2 then goto InputDoneRightPortAttack
          ;; lda temp2 (duplicate)
          ;; beq skip_4608 (duplicate)
          ;; jmp InputDoneRightPortAttack (duplicate)
skip_4608:

          ;; lda joy1fire (duplicate)
          ;; bne skip_3584 (duplicate)
          ;; jmp InputDoneRightPortAttack (duplicate)
skip_3584:


                    ;; if (playerState[temp1] & PlayerStateBitFacing) then goto InputDoneRightPortAttack

                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; Cross-bank call to DispatchCharacterAttack in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DispatchCharacterAttack-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DispatchCharacterAttack-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


InputDoneRightPortAttack

          ;; rts (duplicate)



.pend

HandlePauseInput .proc

          ;;
          ;; Pause Button Handling With Debouncing

          ;; Handles SELECT switch and Joy2b+ Button III with proper

          ;; debouncing

          ;; Uses SystemFlagPauseButtonPrev bit in systemFlags for debouncing

          ;; Check SELECT switch (always available)

          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)

                    ;; if switchselect then let temp1 = 1          lda switchselect          beq skip_7014
skip_7014:
          ;; jmp skip_7014 (duplicate)



          ;; Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for

          ;; Player 2)

                    ;; if LeftPortJoy2bPlus then if !INPT1{7} then let temp1 = 1
          ;; lda LeftPortJoy2bPlus (duplicate)
          ;; beq skip_2135 (duplicate)
          bit INPT1
          ;; bmi skip_2135 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)
skip_2135:

                    ;; if RightPortJoy2bPlus then if !INPT3{7} then let temp1 = 1
          ;; lda RightPortJoy2bPlus (duplicate)
          ;; beq skip_2706 (duplicate)
          ;; bit INPT3 (duplicate)
          ;; bmi skip_2706 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)
skip_2706:

Joy2bPauseDone

          ;; Player 2 Button III



          ;; Debounce: only toggle if button just pressed (was 0, now

          ;; 1)
          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_7483 (duplicate)
          ;; jmp DonePauseToggle (duplicate)
skip_7483:


          ;; Toggle pause flag in systemFlags

                    ;; if systemFlags & SystemFlagPauseButtonPrev then goto DonePauseToggle
          ;; lda systemFlags (duplicate)
          ;; and SystemFlagPauseButtonPrev (duplicate)
          ;; beq skip_3278 (duplicate)
          ;; jmp DonePauseToggle (duplicate)
skip_3278:

                    ;; if systemFlags & SystemFlagGameStatePaused then let systemFlags = systemFlags & ClearSystemFlagGameStatePaused else systemFlags = systemFlags | SystemFlagGameStatePaused
          ;; lda systemFlags (duplicate)
          ;; and SystemFlagGameStatePaused (duplicate)
          ;; beq skip_179 (duplicate)
          ;; lda systemFlags (duplicate)
          ;; and ClearSystemFlagGameStatePaused (duplicate)
          ;; sta systemFlags (duplicate)
          ;; jmp end_179 (duplicate)
skip_179:
          ;; lda systemFlags (duplicate)
          ora SystemFlagGameStatePaused
          ;; sta systemFlags (duplicate)
end_179:

DonePauseToggle

          ;; Toggle pause (0<->1)





          ;; Update pause button previous state in systemFlags

          ;; Update previous button state for next frame

                    ;; if temp1 then let systemFlags = systemFlags | SystemFlagPauseButtonPrev else systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev
          ;; lda temp1 (duplicate)
          ;; beq skip_6637 (duplicate)
          ;; lda systemFlags (duplicate)
          ;; ora SystemFlagPauseButtonPrev (duplicate)
          ;; sta systemFlags (duplicate)
          ;; jmp end_9698 (duplicate)
skip_6637:
          ;; lda systemFlags (duplicate)
          ;; and ClearSystemFlagPauseButtonPrev (duplicate)
          ;; sta systemFlags (duplicate)
end_9698:



          ;; rts (duplicate)



.pend

