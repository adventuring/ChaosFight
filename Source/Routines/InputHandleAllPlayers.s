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
          beq HandlePlayers12
          jmp InputHandleQuadtariPlayers
HandlePlayers12:



          ;; Even frame: Handle Players 1 & 2 - only if alive

          ;; let currentPlayer = 0 : gosub IsPlayerAlive bank13
          lda temp2
          cmp # 0
          bne CheckPlayer0State
          jmp InputDonePlayer0Input
CheckPlayer0State:


                    if (playerState[0] & 8) then InputDonePlayer0Input

          ;; let temp1 = 0
          lda # 0
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
          lda 1
          sta currentPlayer
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(IsPlayerAlive-1)
          pha
          lda # <(IsPlayerAlive-1)
          pha
          ldx # 12
          jmp BS_jsr
return_point:
          lda temp2
          cmp # 0
          bne CheckPlayer1State
          ;; TODO: #1310 InputDonePlayer1Input
CheckPlayer1State:


                    if (playerState[1] & 8) then InputDonePlayer1Input
          jmp InputHandlePlayer1



          jmp InputDonePlayer1Input



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

          lda # 1
          sta temp1

          jsr InputHandleRightPortPlayerFunction

InputDonePlayer1Input

          ;; Player 1 uses Joy1
          ;; Returns: Far (return otherbank)

          jsr BS_return

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

          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer3Character

          jmp InputDonePlayer3InputDone

CheckPlayer3Character:


                    if playerCharacter[2] = NoCharacter then InputDonePlayer3Input

          ;; let currentPlayer = 2 : gosub IsPlayerAlive bank13
          lda 2
          sta currentPlayer
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(IsPlayerAlive-1)
          pha
          lda # <(IsPlayerAlive-1)
          pha
          ldx # 12
          jmp BS_jsr
return_point:
          lda temp2
          cmp # 0
          bne CheckPlayer3State
          jmp InputDonePlayer3Input
CheckPlayer3State:


                    if (playerState[2] & 8) then InputDonePlayer3Input

          ;; let temp1 = 2
          lda # 2
          sta temp1 : gosub InputHandleLeftPortPlayerFunction



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
          lda controllerStatus
          and SetQuadtariDetected
          cmp # 0
          bne CheckPlayer4Character
          jmp InputDonePlayer4Input
CheckPlayer4Character:


                    if playerCharacter[3] = NoCharacter then InputDonePlayer4Input

          ;; let currentPlayer = 3 : gosub IsPlayerAlive bank13
          lda 3
          sta currentPlayer
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(IsPlayerAlive-1)
          pha
          lda # <(IsPlayerAlive-1)
          pha
          ldx # 12
          jmp BS_jsr
return_point:
          lda temp2
          cmp # 0
          bne CheckPlayer4State
          jmp InputDonePlayer4Input
CheckPlayer4State:


                    if (playerState[3] & 8) then InputDonePlayer4Input

          ;; let temp1 = 3
          lda # 3
          sta temp1 : gosub InputHandleRightPortPlayerFunction



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
          jsr BS_return

.pend

