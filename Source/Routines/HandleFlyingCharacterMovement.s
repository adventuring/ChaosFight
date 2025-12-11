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

          ;; let temp5 = playerCharacter[temp1]         
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

          ;; Check left movement

          lda temp6
          cmp # 0
          bne HFCM_CheckLeftJoy1

          jmp HFCM_CheckLeftJoy0

HFCM_CheckLeftJoy1:

          lda SWCHA
          and # $08
          bne HFCM_CheckRight

HFCM_DoLeft:

.pend

HFCM_CheckLeftJoy0 .proc
          lda SWCHA
          and # $80
          bne HFCM_CheckRight

HFCM_DoLeft:


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
          bne HFCM_CheckRightJoy1
          ;; TODO: #1307 HFCM_CheckRightJoy0
HFCM_CheckRightJoy1:

          lda SWCHA
          and # $04
          bne HFCM_CheckVertical

HFCM_DoRight:

.pend

HFCM_CheckRightJoy0 .proc
          ;; Returns: Far (return otherbank)

          lda SWCHA
          and # $40
          bne HFCM_CheckVertical

HFCM_DoRight:


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

          ;; let temp5 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5

          ;; let characterMovementSpeed = CharacterMovementSpeed[temp5]
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
          bne HFCM_VertJoy1
          ;; TODO: #1307 HFCM_VertJoy0
HFCM_VertJoy1:


          ;; if joy1up then goto HFCM_VertUp
          lda SWCHA
          and # $01
          bne CheckJoy1Down
          jmp HFCM_VertUp
CheckJoy1Down:

          ;; if joy1down then goto HFCM_VertDown
          lda SWCHA
          and # $02
          bne HandleFlyingCharacterMovementDone
          jmp HFCM_VertDown
HandleFlyingCharacterMovementDone:

          rts

.pend

HFCM_VertJoy0 .proc

          ;; if joy0up then goto HFCM_VertUp
          lda joy0up
          beq CheckJoy0Down
          jmp HFCM_VertUp
CheckJoy0Down:

          ;; if joy0down then goto HFCM_VertDown
          lda joy0down
          beq HandleFlyingCharacterMovementDone
          jmp HFCM_VertDown
HandleFlyingCharacterMovementDone:

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



.pend

