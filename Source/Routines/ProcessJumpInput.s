;;; ChaosFight - Source/Routines/ProcessJumpInput.bas
          ;; Forward declaration for cross-bank call
          ;; CheckEnhancedJumpButton is defined in CharacterAttacksDispatch.s (Bank 9)
          ;; Cross-bank call: CheckEnhancedJumpButton is defined in CharacterAttacksDispatch.s (Bank 9)
          ;; The BS_jsr mechanism handles cross-bank symbol resolution at link time

;;; Copyright © 2025 Bruce-Robert Pocock.


ProcessJumpInput .proc
          ;;
          ;; Returns: Near (return thisbank) - changed from Far to save stack depth
          ;; Shared Jump Input Handler
          ;; Handles jump input from enhanced buttons (Genesis Button C, Joy2B+ Button II)
          ;; UP = Button C = Button II (no exceptions)
          ;;
          ;; INPUT: temp1 = player index (0-3), temp2 = cached animation sta

          ;;
          ;; OUTPUT: Jump or character-specific behavior executed if conditions met
          ;;
          ;; Mutates: temp3, temp4, temp6, playerCharacter[], playerState[],
          ;; playerY[], characterStateFlags_W[]
          ;;
          ;; Called Routines: CheckEnhancedJumpButton (bank10),
          ;; ProcessUpAction (thisbank) - executes character-specific behavior
          ;;
          ;; Constraints: Must be colocated with ProcessUpAction in same bank

          ;; Inlined CheckEnhancedJumpButton to save 4 bytes stack depth (FIXME #1236)
          ;; Check enhanced button first (sets temp3 = 1 if pressed, 0 otherwise)
          ;; Check Genesis/Joy2b+ Button C/II
          ;; Initialize to no jump
          lda # 0
          sta temp3

          ;; Only players 0-1 can have enhanced controllers
          ;; Players 2-3 (Quadtari players) cannot have enhanced controllers
          lda currentPlayer
          cmp # 0
          beq PJI_CheckPlayer0Enhanced
          cmp # 1
          beq PJI_CheckPlayer1Enhanced
          jmp ProcessJumpInputReturn
PJI_CheckPlayer0Enhanced:
          ;; Player 0: Check Genesis controller first
          lda controllerStatus
          and # SetLeftPortGenesis
          beq PJI_CheckPlayer0Joy2bPlus
          bit INPT0
          bmi PJI_CheckPlayer0Joy2bPlus
          lda # 1
          sta temp3
          jmp ProcessJumpInputContinue
PJI_CheckPlayer0Joy2bPlus:
          ;; Player 0: Check Joy2b+ controller (fallback)
          lda controllerStatus
          and # SetLeftPortJoy2bPlus
          beq ProcessJumpInputReturn
          bit INPT0
          bmi ProcessJumpInputReturn
          lda # 1
          sta temp3
          jmp ProcessJumpInputContinue
PJI_CheckPlayer1Enhanced:
          ;; Player 1: Check Genesis controller first
          lda controllerStatus
          and # SetRightPortGenesis
          beq PJI_CheckPlayer1Joy2bPlus
          bit INPT2
          bmi PJI_CheckPlayer1Joy2bPlus
          lda # 1
          sta temp3
          jmp ProcessJumpInputContinue
PJI_CheckPlayer1Joy2bPlus:
          ;; Player 1: Check Joy2b+ controller (fallback)
          lda controllerStatus
          and # SetRightPortJoy2bPlus
          beq ProcessJumpInputReturn
          bit INPT2
          bmi ProcessJumpInputReturn
          lda # 1
          sta temp3
          jmp ProcessJumpInputContinue
ProcessJumpInputReturn:
          ;; If enhanced button not pressed, return (no action)
          rts
ProcessJumpInputContinue:

          ;; Execute character-specific UP action (UP = Button C = Button II)
          jsr ProcessUpAction

          rts

.pend

