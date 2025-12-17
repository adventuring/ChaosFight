;;; ChaosFight - Source/Routines/HandleFlyingCharacterMovement.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




HandleFlyingCharacterMovement .proc
          ;; Returns: Far (return otherbank)
          ;; Called from Bank 7, so must use Far return convention (jmp BS_return)
          ;; However, this routine is currently only called via tail call (jmp), so it never actually returns
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
          bne HandleFlyingCharacterMovementCheckLeftJoy1

          jmp HandleFlyingCharacterMovementCheckLeftJoy0

HandleFlyingCharacterMovementCheckLeftJoy1:

          lda SWCHA
          bit BitMask + SWCHA_BitP1Left
          bne HandleFlyingCharacterMovementCheckRight

          jmp HandleFlyingCharacterMovementDoLeft

.pend

HandleFlyingCharacterMovementCheckLeftJoy0 .proc
          lda SWCHA
          bit BitMask + SWCHA_BitP0Left
          bne HandleFlyingCharacterMovementCheckRight

          jmp HandleFlyingCharacterMovementDoLeft


.pend

HandleFlyingCharacterMovementDoLeft .proc
          ;; Tail call: Cross-bank call to HandleFlyingCharacterMovementAttemptMoveLeft in Bank 5
          ;; HandleFlyingCharacterMovementAttemptMoveLeft will return directly to InputHandleLeftPortPlayerFunction's caller
          ;; Preserve the return address from HandleFlyingCharacterMovement's caller (InputHandleLeftPortPlayerFunction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(HandleFlyingCharacterMovementAttemptMoveLeft-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: HandleFlyingCharacterMovementAttemptMoveLeft hi (raw)]
          lda # <(HandleFlyingCharacterMovementAttemptMoveLeft-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: HandleFlyingCharacterMovementAttemptMoveLeft hi (raw)] [SP+0: HandleFlyingCharacterMovementAttemptMoveLeft lo]
          ldx # 5
          jmp BS_jsr
.pend

HandleFlyingCharacterMovementCheckRight .proc

          ;; Check right movement
          ;; Returns: Far (return otherbank)

          lda temp6
          bne HandleFlyingCharacterMovementCheckRightJoy1
          jsr HandleFlyingCharacterMovementCheckRightJoy0
          jmp HandleFlyingCharacterMovementCheckVertical
HandleFlyingCharacterMovementCheckRightJoy1:

          lda SWCHA
          bit BitMask + SWCHA_BitP1Right
          bne HandleFlyingCharacterMovementCheckVertical

          jmp HandleFlyingCharacterMovementDoRight

.pend

HandleFlyingCharacterMovementCheckRightJoy0 .proc
          ;; Returns: Far (return otherbank)

          lda SWCHA
          bit BitMask + SWCHA_BitP0Right
          bne HandleFlyingCharacterMovementCheckVertical

          jmp HandleFlyingCharacterMovementDoRight


.pend

HandleFlyingCharacterMovementDoRight .proc
          ;; Tail call: Cross-bank call to HandleFlyingCharacterMovementAttemptMoveRight in Bank 5
          ;; HandleFlyingCharacterMovementAttemptMoveRight will return directly to InputHandleLeftPortPlayerFunction's caller
          ;; Preserve the return address from HandleFlyingCharacterMovement's caller (InputHandleLeftPortPlayerFunction in Bank 7)
          ;; and re-encode it for BS_jsr
          pla
          sta temp6  ;;; Save low byte
          pla
          sta temp7  ;;; Save high byte (raw address in Bank 7)
          ;; Encode return address with caller bank 7 ($70) for BS_return to decode
          lda temp7
          and # $0f  ;;; Get low nybble
          ora # $70  ;;; Encode bank 7 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: return hi (encoded with bank 7)]
          lda temp6
          pha
          ;; STACK PICTURE: [SP+1: return hi (encoded)] [SP+0: return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(HandleFlyingCharacterMovementAttemptMoveRight-1)
          pha
          ;; STACK PICTURE: [SP+2: return hi (encoded)] [SP+1: return lo] [SP+0: HandleFlyingCharacterMovementAttemptMoveRight hi (raw)]
          lda # <(HandleFlyingCharacterMovementAttemptMoveRight-1)
          pha
          ;; STACK PICTURE: [SP+3: return hi (encoded)] [SP+2: return lo] [SP+1: HandleFlyingCharacterMovementAttemptMoveRight hi (raw)] [SP+0: HandleFlyingCharacterMovementAttemptMoveRight lo]
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
          bne HandleFlyingCharacterMovementVerticalJoy1
          jsr HandleFlyingCharacterMovementVerticalJoy0
          jmp HandleFlyingCharacterMovementCheckVerticalEnd
HandleFlyingCharacterMovementVerticalJoy1:


          ;; if joy1up then jmp HandleFlyingCharacterMovementVerticalUp
          lda SWCHA
          bit BitMask + SWCHA_BitP1Up
          bne CheckJoy1Down
          jmp HandleFlyingCharacterMovementVerticalUp
CheckJoy1Down:

          ;; if joy1down then jmp HandleFlyingCharacterMovementVerticalDown
          lda SWCHA
          bit BitMask + SWCHA_BitP1Down
          bne HandleFlyingCharacterMovementDoneJoy1
          jmp HandleFlyingCharacterMovementVerticalDown
HandleFlyingCharacterMovementDoneJoy1:

          jmp BS_return

.pend

HandleFlyingCharacterMovementVerticalJoy0 .proc
          ;; Returns: Near (called from same bank)
          ;; if joy0up then jmp HandleFlyingCharacterMovementVerticalUp
          lda SWCHA
          bit BitMask + SWCHA_BitP0Up
          bne CheckJoy0Down
          jmp HandleFlyingCharacterMovementVerticalUp
CheckJoy0Down:

          ;; if joy0down then jmp HandleFlyingCharacterMovementVerticalDown
          lda SWCHA
          bit BitMask + SWCHA_BitP0Down
          bne HandleFlyingCharacterMovementDoneJoy0
          jmp HandleFlyingCharacterMovementVerticalDown
HandleFlyingCharacterMovementDoneJoy0:

          jmp BS_return

.pend

HandleFlyingCharacterMovementCheckVerticalEnd:
          ;; This label is jumped to from HandleFlyingCharacterMovementCheckVertical
          ;; which is called from HandleFlyingCharacterMovement (all in Bank 11)
          ;; Since HandleFlyingCharacterMovement is only tail-called from Bank 7,
          ;; and never returns, this should theoretically use Far return.
          ;; However, since it's only reached via jmp (not jsr), it never returns either.
          ;; Using BS_return to maintain protocol: any routine that could return to
          ;; a cross-bank caller must use Far return.
          jmp BS_return

HandleFlyingCharacterMovementVerticalUp .proc
          ;; Called from HandleFlyingCharacterMovementCheckVertical (same bank)
          ;; So Near return is correct
          rts

.pend

HandleFlyingCharacterMovementVerticalDown .proc
          ;; Called from HandleFlyingCharacterMovementCheckVertical (same bank)
          ;; So Near return is correct
          rts

.pend

