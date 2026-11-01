InputHandleRightPortPlayerFunction .proc
    ;; RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
    ;; INPUT: temp1 = player index (1 or 3)
    ;; USES: joy1left, joy1right, joy1up, joy1down, joy1fire
    lda temp1
    sta currentPlayer
    ;; Cache animation state at start (used for movement, jump, and attack checks)
    lda temp1
    tax
    lda playerState,x
    sta temp2
    ;; Block movement during attack windup/execute/recovery
    lda temp2
    cmp # 13
    bcc IHRP_CheckGuardStatus
    jmp DoneRightPortMovement
IHRP_CheckGuardStatus:
    ;; Process left/right movement (with playfield collision for flying characters)
    lda temp1
    tax
    lda playerState,x
    sta temp6
    ;; Guarding - block movement
    lda temp6
    beq IHRP_CheckFlyingCharacter
    jmp DoneRightPortMovement
IHRP_CheckFlyingCharacter:
    lda temp1
    tax
    lda playerCharacter,x
    sta temp5
    lda temp5
    cmp # 8
    bne IHRP_CheckDragonOfStorms
    jmp IHRP_FlyingMovement
IHRP_CheckDragonOfStorms:
    lda temp5
    cmp # 2
    bne IHRP_ProcessStandardMovement
    jmp IHRP_FlyingMovement
IHRP_ProcessStandardMovement:
    ;; Standard horizontal movement (uses shared routine)
    lda temp1
    tax
    lda playerCharacter,x
    sta temp6
    lda temp6
    tax
    lda CharacterMovementSpeed,x
    sta temp6
    lda temp6
    tax
    lda CharacterMovementSpeed,x
    sta temp6
    lda temp1
    tax
    lda temp2
    clc
    adc temp6
    sta playerVelocityX,x
    lda temp1
    tax
    lda # 0
    sta playerVelocityXL,x
    .pend