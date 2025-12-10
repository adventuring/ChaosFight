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

                    let temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5

          ;; Save player index to global variable

          lda temp1
          sta currentPlayer

          ;; Determine which joy port to use based on player index

          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)

          ;; temp6 = 0 for players 0,2 (joy0), 2 for players 1,3 (joy1)

          ;; let temp6 = temp1 & 2
          lda temp1
          and # 2
          sta temp6

          lda temp1
          and # 2
          sta temp6


          ;; Check left movement

          lda temp6
          cmp # 0
          bne skip_1208
          ;; TODO: HFCM_CheckLeftJoy0
skip_1208:


          lda joy1left
          bne skip_7853
          jmp HFCM_CheckRight
skip_7853:


          jmp HFCM_DoLeft

.pend

HFCM_CheckLeftJoy0 .proc

          lda joy0left
          bne skip_712
          jmp HFCM_CheckRight
skip_712:


.pend

HFCM_DoLeft .proc
          ;; Tail call: Cross-bank call to HFCM_AttemptMoveLeft in Bank 6
          ;; HFCM_AttemptMoveLeft will return directly to InputHandleLeftPortPlayerFunction
          ;; (skipping HandleFlyingCharacterMovement's return)
          lda # >(HFCM_AttemptMoveLeft-1)
          pha
          lda # <(HFCM_AttemptMoveLeft-1)
          pha
          ldx # 5
          jmp BS_jsr
.pend

HFCM_CheckRight .proc

          ;; Check right movement
          ;; Returns: Far (return otherbank)

          lda temp6
          cmp # 0
          bne skip_8068
          ;; TODO: HFCM_CheckRightJoy0
skip_8068:


          lda joy1right
          bne skip_2833
          jmp HFCM_CheckVertical
skip_2833:


          jmp HFCM_DoRight

.pend

HFCM_CheckRightJoy0 .proc
          ;; Returns: Far (return otherbank)

          lda joy0right
          bne skip_3184
          jmp HFCM_CheckVertical
skip_3184:


.pend

HFCM_DoRight .proc
          ;; Tail call: Cross-bank call to HFCM_AttemptMoveRight in Bank 6
          ;; HFCM_AttemptMoveRight will return directly to InputHandleLeftPortPlayerFunction
          ;; (skipping HandleFlyingCharacterMovement's return)
          lda # >(HFCM_AttemptMoveRight-1)
          pha
          lda # <(HFCM_AttemptMoveRight-1)
          pha
          ldx # 5
          jmp BS_jsr
.pend

HFCM_CheckVertical .proc

          ;; Vertical control for flying characters: UP/DOWN
          ;; Returns: Far (return otherbank)

          lda currentPlayer
          sta temp1

                    let temp5 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp5

                    let characterMovementSpeed = CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed

          lda temp6
          cmp # 0
          bne skip_6783
          ;; TODO: HFCM_VertJoy0
skip_6783:


                    if joy1up then goto HFCM_VertUp
          lda joy1up
          beq skip_3244
          jmp HFCM_VertUp
skip_3244:

                    if joy1down then goto HFCM_VertDown
          lda joy1down
          beq skip_9526
          jmp HFCM_VertDown
skip_9526:

          jsr BS_return

.pend

HFCM_VertJoy0 .proc

                    if joy0up then goto HFCM_VertUp
          lda joy0up
          beq skip_6096
          jmp HFCM_VertUp
skip_6096:

                    if joy0down then goto HFCM_VertDown
          lda joy0down
          beq skip_3350
          jmp HFCM_VertDown
skip_3350:

          jsr BS_return

.pend

HFCM_VertUp .proc

          jsr BS_return

          jsr BS_return

          jsr BS_return

.pend

HFCM_VertDown .proc

          jsr BS_return

          jsr BS_return

          jsr BS_return



.pend

