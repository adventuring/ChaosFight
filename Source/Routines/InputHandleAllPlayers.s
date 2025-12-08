;;; ChaosFight - Source/Routines/InputHandleAllPlayers.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




InputHandleAllPlayers .proc




          ;; Main input handler for all players with Quadtari

          ;; multiplexing

          ;;
          ;; Input: qtcontroller (global) = multiplexing sta


          ;; (0=P1/P2, 1=P3/P4)

          ;; controllerStatus (global) = controller detection

          ;; sta


          ;; playerCharacter[] (global array) = character selections

          ;; playerState[] (global array) = player state flags

          ;;
          ;; Output: Input processed for active players, qtcontroller

          ;; toggled

          ;;
          ;; Mutates: temp1, temp2 (used for calculations),

          ;; currentPlayer (set to 0-3),

          ;; qtcontroller (toggled between 0 and 1)

          ;;
          ;; Called Routines: IsPlayerAlive (bank13) - checks if player is

          ;; alive (returns health in temp2),

          ;; InputHandleLeftPortPlayerFunction (bank8, same-bank),

          ;; InputHandleRightPortPlayerFunction (bank8, same-bank) -

          ;; handle input for left/right port players

          ;;
          ;; Constraints: Must be colocated with InputSkipPlayer0Input,

          ;; InputSkipPlayer1Input,

          ;; InputHandlePlayer1,

          ;; InputHandleQuadtariPlayers,

          ;; InputSkipPlayer3Input,

          ;; InputSkipPlayer4Input (all called via goto or gosub)

                    ;; if qtcontroller then goto InputHandleQuadtariPlayers
          lda qtcontroller
          beq skip_514
          jmp InputHandleQuadtariPlayers
skip_514:



          ;; Even frame: Handle Players 1 & 2 - only if alive

                    ;; let currentPlayer = 0 : gosub IsPlayerAlive bank13
          ;; lda temp2 (duplicate)
          cmp # 0
          bne skip_4896
          ;; TODO: InputDonePlayer0Input
skip_4896:


                    ;; if (playerState[0] & 8) then InputDonePlayer0Input

                    ;; let temp1 = 0
          ;; lda # 0 (duplicate)
          sta temp1 : gosub InputHandleLeftPortPlayerFunction



InputDonePlayer0Input

          ;; Skip Player 0 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with InputHandleAllPlayers



                    ;; let currentPlayer = 1 : gosub IsPlayerAlive bank13
          ;; lda 1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ldx # 12
          ;; jmp BS_jsr (duplicate)
return_point:
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1481 (duplicate)
          ;; TODO: InputDonePlayer1Input
skip_1481:


                    ;; if (playerState[1] & 8) then InputDonePlayer1Input
          ;; jmp InputHandlePlayer1 (duplicate)



          ;; jmp InputDonePlayer1Input (duplicate)



.pend

InputHandlePlayer1 .proc

          ;; Handle Player 1 input (right port)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 (set to 1), playerState[] (global array)

          ;;
          ;; Output: Player 1 input processed

          ;;
          ;; Mutates: temp1 (set to 1), player state (via

          ;; InputHandleRightPortPlayerFunction)

          ;;
          ;; Called Routines: InputHandleRightPortPlayerFunction - handles

          ;; right port player input

          ;; Constraints: Must be colocated with InputHandleAllPlayers, InputSkipPlayer1Input

          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)

          jsr InputHandleRightPortPlayerFunction

InputDonePlayer1Input

          ;; Player 1 uses Joy1
          ;; Returns: Far (return otherbank)

          ;; jsr BS_return (duplicate)

.pend

InputHandleQuadtariPlayers .proc

          ;; Skip Player 1 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with InputHandleAllPlayers

          ;; Odd frame: Handle Players 3 & 4 (if Quadtari detected and

          ;; alive)

          ;;
          ;; Input: controllerStatus (global), playerCharacter[] (global array),

          ;; playerState[] (global array)

          ;;
          ;; Output: Input processed for Players 3 & 4 if conditions

          ;; met, qtcontroller reset to 0

          ;;
          ;; Mutates: temp1, temp2 (used for calculations),

          ;; currentPlayer (set to 2-3),

          ;; qtcontroller (reset to 0)

          ;;
          ;; Called Routines: IsPlayerAlive (bank13) - checks if player is

          ;; alive (returns health in temp2),

          ;; InputHandleLeftPortPlayerFunction (bank8, same-bank),

          ;; InputHandleRightPortPlayerFunction (bank8, same-bank) -

          ;; handle input for left/right port players

          ;;
          ;; Constraints: Must be colocated with InputHandleAllPlayers,

          ;; InputSkipPlayer3Input,

          ;; InputSkipPlayer4Input

          ;; Odd frame: Handle Players 3 & 4 (if Quadtari detected and

          ;; alive)

          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; cmp # 0 (duplicate)
          ;; bne skip_2681 (duplicate)
skip_2681:


                    ;; if playerCharacter[2] = NoCharacter then InputDonePlayer3Input

                    ;; let currentPlayer = 2 : gosub IsPlayerAlive bank13
          ;; lda 2 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8643 (duplicate)
          ;; TODO: InputDonePlayer3Input
skip_8643:


                    ;; if (playerState[2] & 8) then InputDonePlayer3Input

                    ;; let temp1 = 2
          ;; lda # 2 (duplicate)
          ;; sta temp1 : gosub InputHandleLeftPortPlayerFunction (duplicate)



InputDonePlayer3Input

          ;; Skip Player 3 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with InputHandleQuadtariPlayers
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8739 (duplicate)
skip_8739:


                    ;; if playerCharacter[3] = NoCharacter then InputDonePlayer4Input

                    ;; let currentPlayer = 3 : gosub IsPlayerAlive bank13
          ;; lda 3 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(IsPlayerAlive-1) (duplicate)
          ;; pha (duplicate)
          ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_21 (duplicate)
          ;; TODO: InputDonePlayer4Input
skip_21:


                    ;; if (playerState[3] & 8) then InputDonePlayer4Input

                    ;; let temp1 = 3
          ;; lda # 3 (duplicate)
          ;; sta temp1 : gosub InputHandleRightPortPlayerFunction (duplicate)



InputDonePlayer4Input

          ;; Skip Player 4 input (label only, no execution)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: None (label only, no execution)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with

          ;; InputHandleQuadtariPlayers





          ;; Switch back to even frame

          qtcontroller = 0
          ;; jsr BS_return (duplicate)

.pend

