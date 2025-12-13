;;; ChaosFight - Source/Routines/HandleFlyingCharacterMovement.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




HandleFlyingCharacterMovement .proc
          ;; Returns: Near (return thisbank) - changed from Far to save stack depth (FIXME #1241)
          ;;
          ;; Input: temp1 = player index, temp2 = (document other inputs)
          ;;
          ;; Output: (document return values and state changes)
          ;;
          ;; Mutates: temp1-temp6 (as used), player position/velocity arrays
          ;;
          ;; Called Routines: (document subroutines called)
          ;;
          ;; Constraints: (document colocation/bank requirements)

          ;;
          ;; Shared Flying Character Movement

          ;; Handles horizontal movement with collision for flying

          ;; characters (Frooty, Dragon of Storms)

          ;;
          ;; INPUT: temp1 = player index (0-3)

          ;; Uses: joy0left/joy0right for players 0,2;

          ;; joy1left/joy1right

          ;; for players 1,3

          ;; Set temp5 = playerCharacter[temp1]
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

          ;; Set temp6 = temp1 & 2
          lda temp1
          and # 2
          sta temp6

          ;; Check left movement

          lda temp6
          cmp # 0
          bne HandleFlyingCharacterMovementCheckLeftJoy1

          jmp HandleFlyingCharacterMovementCheckLeftJoy0

HandleFlyingCharacterMovementCheckLeftJoy1:

          lda SWCHA
          bit # SWCHA_P1Left
          bne HandleFlyingCharacterMovementCheckRight

          jmp HandleFlyingCharacterMovementDoLeft

.pend

HandleFlyingCharacterMovementCheckLeftJoy0 .proc
          lda # SWCHA_P0Left
          bit SWCHA
          bne HandleFlyingCharacterMovementCheckRight

          jmp HandleFlyingCharacterMovementDoLeft


.pend

HandleFlyingCharacterMovementDoLeft .proc
          ;; Tail call: Cross-bank call to HandleFlyingCharacterMovementAttemptMoveLeft in Bank 6
          ;; HandleFlyingCharacterMovementAttemptMoveLeft will return directly to InputHandleLeftPortPlayerFunction
          ;; (skipping HandleFlyingCharacterMovement's return)
          lda # >(HandleFlyingCharacterMovementAttemptMoveLeft-1)
          pha
          lda # <(HandleFlyingCharacterMovementAttemptMoveLeft-1)
          pha
          ldx # 5
          jmp BS_jsr
.pend

HandleFlyingCharacterMovementCheckRight .proc

          ;; Check right movement
          ;; Returns: Far (return otherbank)

          lda temp6
          cmp # 0
          bne HandleFlyingCharacterMovementCheckRightJoy1
          jsr HandleFlyingCharacterMovementCheckRightJoy0
          jmp HandleFlyingCharacterMovementCheckVertical
HandleFlyingCharacterMovementCheckRightJoy1:

          lda # SWCHA_P1Right
          bit SWCHA
          bne HandleFlyingCharacterMovementCheckVertical

          jmp HandleFlyingCharacterMovementDoRight

.pend

HandleFlyingCharacterMovementCheckRightJoy0 .proc
          ;; Returns: Far (return otherbank)

          lda # SWCHA_P0Right
          bit SWCHA
          bne HandleFlyingCharacterMovementCheckVertical

          jmp HandleFlyingCharacterMovementDoRight


.pend

HandleFlyingCharacterMovementDoRight .proc
          ;; Tail call: Cross-bank call to HandleFlyingCharacterMovementAttemptMoveRight in Bank 6
          ;; HandleFlyingCharacterMovementAttemptMoveRight will return directly to InputHandleLeftPortPlayerFunction
          ;; (skipping HandleFlyingCharacterMovement's return)
          lda # >(HandleFlyingCharacterMovementAttemptMoveRight-1)
          pha
          lda # <(HandleFlyingCharacterMovementAttemptMoveRight-1)
          pha
          ldx # 5
          jmp BS_jsr
.pend

HandleFlyingCharacterMovementCheckVertical .proc

          ;; Vertical control for flying characters: UP/DOWN
          ;; Returns: Far (return otherbank)

          lda currentPlayer
          sta temp1

          ;; Set temp5 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5

          ;; Set characterMovementSpeed = CharacterMovementSpeed[temp5]
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
          bne HandleFlyingCharacterMovementVerticalJoy1
          jsr HandleFlyingCharacterMovementVerticalJoy0
          jmp HandleFlyingCharacterMovementCheckVerticalEnd
HandleFlyingCharacterMovementVerticalJoy1:


          ;; if joy1up then jmp HandleFlyingCharacterMovementVerticalUp
          lda SWCHA
          bit # SWCHA_P1Up
          bne CheckJoy1Down
          jmp HandleFlyingCharacterMovementVerticalUp
CheckJoy1Down:

          ;; if joy1down then jmp HandleFlyingCharacterMovementVerticalDown
          lda SWCHA
          bit # SWCHA_P1Down
          bne HandleFlyingCharacterMovementDoneJoy1
          jmp HandleFlyingCharacterMovementVerticalDown
HandleFlyingCharacterMovementDoneJoy1:

          rts

.pend

HandleFlyingCharacterMovementVerticalJoy0 .proc
          ;; Returns: Near (called from same bank)
          ;; if joy0up then jmp HandleFlyingCharacterMovementVerticalUp
          lda # SWCHA_P0Up
          bit SWCHA
          bne CheckJoy0Down
          jmp HandleFlyingCharacterMovementVerticalUp
CheckJoy0Down:

          ;; if joy0down then jmp HandleFlyingCharacterMovementVerticalDown
          lda # SWCHA_P0Down
          bit SWCHA
          bne HandleFlyingCharacterMovementDoneJoy0
          jmp HandleFlyingCharacterMovementVerticalDown
HandleFlyingCharacterMovementDoneJoy0:

          rts

.pend

HandleFlyingCharacterMovementCheckVerticalEnd:
          rts

HandleFlyingCharacterMovementVerticalUp .proc

          rts

          rts

          rts

.pend

HandleFlyingCharacterMovementVerticalDown .proc

          rts

          rts

          rts



.pend

