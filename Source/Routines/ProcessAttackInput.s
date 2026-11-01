; ChaosFight - Source/Routines/ProcessAttackInput.s
;; Copyright © 2025 Bruce-Robert Pocock.

ProcessAttackInput .proc
    ;; Shared Attack Input Handler
    ;; Handles attack input (fire button) for both ports.
    ;; Attack/fire = bit 7 ($80) of each consolidated playerXInput byte.
    ;;
    ;; INPUT:  temp1 = player index (0-3)
    ;; Mutates: temp1, temp2, temp4, playerCharacter[]
    ;; Called Routines: DispatchCharacterAttack (bank 9)
    ;; Constraints: Far-called; ends with jmp BS_return

    ;; Map temp1 -> consolidated input read port
    lda temp1
    tax

    ;; Read consolidated input byte for this player
    lda player1Input_R,x   ; player1Input_R..player4Input_R are consecutive ($FB..$FE)
    bmi ProcessAttack_FirePressed
    jmp ProcessAttack_Return

ProcessAttack_FirePressed:
    ;; Check if player is guarding - guard blocks attacks
    lda temp1
    tax
    lda playerState,x
    sta temp2
    and # 2
    bne ProcessAttack_Return         ; guarding -> block attack

    ;; Set temp4 = playerCharacter[temp1]
    lda temp1
    tax
    lda playerCharacter,x
    sta temp4

    ;; Cross-bank call to DispatchCharacterAttack in bank 9
    lda # ((>(AfterDispatchCharacterAttack-1)) & $0f) | $90   ; Encode bank 9
    pha
    lda # <(AfterDispatchCharacterAttack-1)
    pha
    lda # >(DispatchCharacterAttack-1)
    pha
    lda # <(DispatchCharacterAttack-1)
    pha
    ldx # 9
    jmp BS_jsr
AfterDispatchCharacterAttack:
    jmp BS_return

ProcessAttack_Return:
    jmp BS_return
    .pend
