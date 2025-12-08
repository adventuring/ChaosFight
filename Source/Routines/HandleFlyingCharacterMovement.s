;;; ChaosFight - Source/Routines/HandleFlyingCharacterMovement.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




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

                    ;; let temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          sta temp5

          ;; Save player index to global variable

          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)

          ;; Determine which joy port to use based on player index

          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          ;; temp6 = 0 for players 0,2 (joy0), 2 for players 1,3 (joy1)

          ;; ;; let temp6 = temp1 & 2
          ;; lda temp1 (duplicate)
          and # 2
          ;; sta temp6 (duplicate)

          ;; lda temp1 (duplicate)
          ;; and # 2 (duplicate)
          ;; sta temp6 (duplicate)


          ;; Check left movement

          ;; lda temp6 (duplicate)
          cmp # 0
          bne skip_1208
          ;; TODO: HFCM_CheckLeftJoy0
skip_1208:


          ;; lda joy1left (duplicate)
          ;; bne skip_7853 (duplicate)
          jmp HFCM_CheckRight
skip_7853:


          ;; jmp HFCM_DoLeft (duplicate)

.pend

HFCM_CheckLeftJoy0 .proc

          ;; lda joy0left (duplicate)
          ;; bne skip_712 (duplicate)
          ;; jmp HFCM_CheckRight (duplicate)
skip_712:


.pend

HFCM_DoLeft .proc

          ;; Tail call: goto instead of gosub to save 2 bytes on sta

          ;; HFCM_AttemptMoveLeft will return directly to InputHandleLeftPortPlayerFunction
          ;; jmp HFCM_AttemptMoveLeft (duplicate)

.pend

HFCM_CheckRight .proc

          ;; Check right movement
          ;; Returns: Far (return otherbank)

          ;; lda temp6 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8068 (duplicate)
          ;; TODO: HFCM_CheckRightJoy0
skip_8068:


          ;; lda joy1right (duplicate)
          ;; bne skip_2833 (duplicate)
          ;; jmp HFCM_CheckVertical (duplicate)
skip_2833:


          ;; jmp HFCM_DoRight (duplicate)

.pend

HFCM_CheckRightJoy0 .proc
          ;; Returns: Far (return otherbank)

          ;; lda joy0right (duplicate)
          ;; bne skip_3184 (duplicate)
          ;; jmp HFCM_CheckVertical (duplicate)
skip_3184:


.pend

HFCM_DoRight .proc

          ;; Tail call: goto instead of gosub to save 2 bytes on sta

          ;; HFCM_AttemptMoveRight will return directly to InputHandleLeftPortPlayerFunction
          ;; jmp HFCM_AttemptMoveRight (duplicate)

.pend

HFCM_CheckVertical .proc

          ;; Vertical control for flying characters: UP/DOWN
          ;; Returns: Far (return otherbank)

          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

                    ;; let temp5 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp5

                    ;; let characterMovementSpeed = CharacterMovementSpeed[temp5]
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta characterMovementSpeed (duplicate)
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta characterMovementSpeed (duplicate)

          ;; lda temp6 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6783 (duplicate)
          ;; TODO: HFCM_VertJoy0
skip_6783:


                    ;; if joy1up then goto HFCM_VertUp
          ;; lda joy1up (duplicate)
          beq skip_3244
          ;; jmp HFCM_VertUp (duplicate)
skip_3244:

                    ;; if joy1down then goto HFCM_VertDown
          ;; lda joy1down (duplicate)
          ;; beq skip_9526 (duplicate)
          ;; jmp HFCM_VertDown (duplicate)
skip_9526:

          jsr BS_return

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

          ;; jsr BS_return (duplicate)

.pend

HFCM_VertUp .proc

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

.pend

HFCM_VertDown .proc

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)



.pend

