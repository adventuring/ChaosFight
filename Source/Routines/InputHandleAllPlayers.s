; ChaosFight - Source/Routines/InputHandleAllPlayers.s
;; Copyright © 2025 Bruce-Robert Pocock.

InputHandleAllPlayers .proc
    ;; Main input handler for all players with Quadtari multiplexing
    lda qtcontroller
    beq HandlePlayers12
    jmp InputHandleQuadtariPlayers
HandlePlayers12:

    ;; Even frame: Handle Players 1 & 2
    ;; Player 0 (left port) - inlined alive check
    lda # 0
    tax
    lda playerHealth,x
    sta temp2
    lda temp2
    bne CheckPlayer0State
    jmp InputDonePlayer0Input
CheckPlayer0State:
    lda # 0
    tax
    lda playerState,x
    and # 8
    beq InputDonePlayer0InputSkip
    jmp InputDonePlayer0Input
InputDonePlayer0InputSkip:
    lda # 0
    sta temp1
    jsr InputHandleLeftPortPlayerFunction
InputDonePlayer0Input:

    ;; Player 1 (right port)
    lda # 1
    tax
    lda playerHealth,x
    sta temp2
    lda temp2
    bne CheckPlayer1State
    jmp InputDonePlayer1Input
CheckPlayer1State:
    lda # 1
    tax
    lda playerState,x
    and # 8
    beq InputDonePlayer1InputSkip
    jmp InputHandlePlayer1
InputDonePlayer1InputSkip:
    jmp InputHandlePlayer1
InputDonePlayer1Input:

    ;; Odd frame: Handle Players 3 & 4
    lda controllerStatus
    and # SetQuadtariDetected
    bne CheckPlayer3Character
    jmp InputDonePlayer3Input
CheckPlayer3Character:
    lda # 2
    tax
    lda playerCharacter,x
    cmp # NoCharacter
    beq InputDonePlayer3Input
    lda # 2
    tax
    lda playerHealth,x
    sta temp2
    lda temp2
    bne CheckPlayer3State
    jmp InputDonePlayer3Input
CheckPlayer3State:
    lda # 2
    tax
    lda playerState,x
    and # 8
    beq InputDonePlayer3InputSkip
    jmp InputHandlePlayer3
InputDonePlayer3InputSkip:
    lda # 2
    sta temp1
    jsr InputHandleLeftPortPlayerFunction
InputDonePlayer3Input:

    lda controllerStatus
    and # SetQuadtariDetected
    bne CheckPlayer4Character
    jmp InputDonePlayer4Input
CheckPlayer4Character:
    lda # 3
    tax
    lda playerCharacter,x
    cmp # NoCharacter
    beq InputDonePlayer4Input
    lda # 3
    tax
    lda playerHealth,x
    sta temp2
    lda temp2
    bne CheckPlayer4State
    jmp InputDonePlayer4Input
CheckPlayer4State:
    lda # 3
    tax
    lda playerState,x
    and # 8
    beq InputDonePlayer4InputSkip
    jmp InputHandlePlayer4
InputDonePlayer4InputSkip:
    lda # 3
    sta temp1
    jsr InputHandleRightPortPlayerFunction
InputDonePlayer4Input:

    qtcontroller = 0
    jmp BS_return
    .pend
