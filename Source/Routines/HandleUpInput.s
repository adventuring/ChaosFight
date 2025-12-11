;;; ChaosFight - Source/Routines/HandleUpInput.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


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

          ;; Determine which joy port to use based on player index
          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          ;; if temp1 & 2 = 0 then jmp HUI_UseJoy0
          rts

          jmp HUI_ProcessUp

.pend

HUI_UseJoy0 .proc
          ;; Players 0,2 use joy0
          rts

.pend

HUI_ProcessUp .proc
          ;; Execute character-specific UP action
          ;; Tail call: jmp instead of cross-bank call to since ProcessUpAction returns to our caller
          jmp ProcessUpAction

.pend

