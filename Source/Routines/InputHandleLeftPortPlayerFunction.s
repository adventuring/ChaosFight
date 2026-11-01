InputHandleLeftPortPlayerFunction .proc
    ;;
    ;; LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 0 & 3)
    ;; INPUT: temp1 = player index (0 or 2)
    ;; USES: joy0left, joy0right, joy0up, joy0down, joy0fire
    ;; Cache animation state at start (used for movement, jump, and attack checks)
    lda temp1
    sta currentPlayer
    ;; block movement during attack animations (states 13-15)
    lda temp2
    cmp # 13
    bcc CheckGuardStatus
    jmp DoneLeftPortMovement
CheckGuardStatus:
    ;; Process left/right movement (with playfield collision for
    ;; flying characters)
    lda temp1
    tax
    lda playerState,x
    sta temp5
    lda temp5
    cmp # 8
    bne CheckDragonOfStorms
    jmp IHLP_FlyingMovement
CheckDragonOfStorms:
    lda temp5
    cmp # 2
    bne IHLPF_ProcessStandardMovementLabel
    jmp IHLP_FlyingMovement
IHLPF_ProcessStandardMovementLabel:
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
    sec
    sbc temp6
    sta temp2
    lda temp1
    tax
    lda playerState,x
    and # 8
    beq HandleStandardHorizontalMovementShouldPreserveFacingNo1
    jmp HandleStandardHorizontalMovementShouldPreserveFacingYes1
    .pend