          rem ChaosFight - Source/Routines/InputHandleAllPlayers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

InputHandleAllPlayers
          asm
InputHandleAllPlayers

end
          rem Main input handler for all players with Quadtari
          rem multiplexing
          rem
          rem Input: qtcontroller (global) = multiplexing state
          rem (0=P1/P2, 1=P3/P4)
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        playerCharacter[] (global array) = character selections
          rem        playerState[] (global array) = player state flags
          rem
          rem Output: Input processed for active players, qtcontroller
          rem toggled
          rem
          rem Mutates: temp1, temp2 (used for calculations),
          rem currentPlayer (set to 0-3),
          rem         qtcontroller (toggled between 0 and 1)
          rem
          rem Called Routines: IsPlayerAlive (bank13) - checks if player is
          rem alive (returns health in temp2),
          rem   InputHandleLeftPortPlayerFunction (bank8, same-bank),
          rem   InputHandleRightPortPlayerFunction (bank8, same-bank) -
          rem   handle input for left/right port players
          rem
          rem Constraints: Must be colocated with InputSkipPlayer0Input,
          rem InputSkipPlayer1Input,
          rem              InputHandlePlayer1,
          rem              InputHandleQuadtariPlayers,
          rem              InputSkipPlayer3Input,
          rem InputSkipPlayer4Input (all called via goto or gosub)
          if qtcontroller then goto InputHandleQuadtariPlayers

          rem Even frame: Handle Players 1 & 2 - only if alive
          let currentPlayer = 0 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer0Input
          if (playerState[0] & 8) then InputDonePlayer0Input
          let temp1 = 0 : gosub InputHandleLeftPortPlayerFunction

InputDonePlayer0Input
          rem Skip Player 0 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with InputHandleAllPlayers

          let currentPlayer = 1 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer1Input
          if (playerState[1] & 8) then InputDonePlayer1Input
          goto InputHandlePlayer1

          goto InputDonePlayer1Input

InputHandlePlayer1
          rem Handle Player 1 input (right port)
          rem
          rem Input: temp1 (set to 1), playerState[] (global array)
          rem
          rem Output: Player 1 input processed
          rem
          rem Mutates: temp1 (set to 1), player state (via
          rem InputHandleRightPortPlayerFunction)
          rem
          rem Called Routines: InputHandleRightPortPlayerFunction - handles
          rem right port player input
          rem Constraints: Must be colocated with InputHandleAllPlayers, InputSkipPlayer1Input
          let temp1 = 1
          gosub InputHandleRightPortPlayerFunction
InputDonePlayer1Input
          rem Player 1 uses Joy1
          return otherbank
InputHandleQuadtariPlayers
          rem Skip Player 1 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with InputHandleAllPlayers
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and
          rem alive)
          rem
          rem Input: controllerStatus (global), playerCharacter[] (global array),
          rem        playerState[] (global array)
          rem
          rem Output: Input processed for Players 3 & 4 if conditions
          rem met, qtcontroller reset to 0
          rem
          rem Mutates: temp1, temp2 (used for calculations),
          rem currentPlayer (set to 2-3),
          rem         qtcontroller (reset to 0)
          rem
          rem Called Routines: IsPlayerAlive (bank13) - checks if player is
          rem alive (returns health in temp2),
          rem   InputHandleLeftPortPlayerFunction (bank8, same-bank),
          rem   InputHandleRightPortPlayerFunction (bank8, same-bank) -
          rem   handle input for left/right port players
          rem
          rem Constraints: Must be colocated with InputHandleAllPlayers,
          rem InputSkipPlayer3Input,
          rem InputSkipPlayer4Input
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and
          rem alive)
          if (controllerStatus & SetQuadtariDetected) = 0 then InputDonePlayer3Input
          if playerCharacter[2] = NoCharacter then InputDonePlayer3Input
          let currentPlayer = 2 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer3Input
          if (playerState[2] & 8) then InputDonePlayer3Input
          let temp1 = 2 : gosub InputHandleLeftPortPlayerFunction

InputDonePlayer3Input
          rem Skip Player 3 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with InputHandleQuadtariPlayers
          if (controllerStatus & SetQuadtariDetected) = 0 then InputDonePlayer4Input
          if playerCharacter[3] = NoCharacter then InputDonePlayer4Input
          let currentPlayer = 3 : gosub IsPlayerAlive bank13
          if temp2 = 0 then InputDonePlayer4Input
          if (playerState[3] & 8) then InputDonePlayer4Input
          let temp1 = 3 : gosub InputHandleRightPortPlayerFunction

InputDonePlayer4Input
          rem Skip Player 4 input (label only, no execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem InputHandleQuadtariPlayers


          rem Switch back to even frame
          qtcontroller = 0
          return otherbank

