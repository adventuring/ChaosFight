; ChaosFight - Source/Routines/HandleUpInput.s
;; Copyright © 2025 Bruce-Robert Pocock.

;; NOTE: UP ($01 D-pad) and Button-2 ($20) are both jump sources in the
;; consolidated byte and MUST share the same code path (jump dispatch).
;; Do not maintain separate HandleUp / HandleButton2 jump routines.

HandleUpInput .proc
    ;;
    ;; Shared UP Input Handler
    ;; Handles UP input from joystick direction
    ;; UP = Button C = Button II (no exceptions)
    ;;
    ;; INPUT: temp1 = player index (0-3)
    ;; temp2 = cached animation state (for attack blocking)
    ;; Uses: joy0up/joy0down for players 0,2; joy1up/joy1down for players 1,3
    ;;
    ;; OUTPUT: temp3 = jump flag (1 if UP used for jump, 0 if special ability)
    ;; Character state may be modified (form switching, RoboTito latch)
    ;;
    ;; Mutates: temp2, temp3, temp4, temp6, playerCharacter[],
    ;; playerY[], characterStateFlags_W[]
    ;;
    ;; Called Routines: ProcessUpAction (thisbank) - executes character-specific behavior
    ;;
    ;; Constraints: Must be colocated with ProcessUpAction in same bank

    ; Determine which joy port to use based on player index
    ; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
    lda temp1
    bne CheckPlayer2JoyPort
    jmp HUI_UseJoy0
CheckPlayer2JoyPort:
    ;; Players 1,3 use joy1
    lda temp1
    cmp # 2
    bne CheckJoy1Up
    jmp HUI_UseJoy0
CheckJoy1Up:
    lda joy1up
    bne HandleUpInputHandleUpJoy1
    jmp HUI_CheckEnhanced
HandleUpInputHandleUpJoy1:
    jmp HUI_ProcessUp

    .pend

HUI_UseJoy0 .proc
    ; Players 0,2 use joy0
    lda joy0up
    bne HUI_HandleUpJoy0
    jmp HUI_CheckEnhanced
HUI_HandleUpJoy0:
    jmp HUI_ProcessUp
    .pend

HUI_CheckEnhanced .proc
    ; Enhanced button (Button II / C) check
    jmp HUI_ProcessUp
    .pend

HUI_ProcessUp .proc
    ; Execute character-specific UP action
    jmp ProcessUpAction
    .pend