          rem ChaosFight - Source/Routines/PlayerElimination.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER ELIMINATION SYSTEM
          rem =================================================================
          rem Handles player elimination when health reaches 0, game end conditions,
          rem and removal of eliminated players from active gameplay systems.

          rem ELIMINATION PROCESS:
          rem   1. Detect when player health reaches 0
          rem   2. Set elimination flag and play elimination effects
          rem   3. Remove player from active input/physics/collision systems
          rem   4. Hide player sprite and health bar
          rem   5. Check for game end conditions (1 player remaining)

          rem VARIABLES:
          rem   playersEliminated - Bit flags for eliminated players
          rem   playersRemaining - Count of active players
          rem   gameEndTimer - Countdown to game end screen
          rem =================================================================

          rem =================================================================
          rem CHECK ALL PLAYER ELIMINATIONS
          rem =================================================================
          rem Called each frame to check if any players should be eliminated.
          rem Sets elimination flags and triggers elimination effects.
CheckAllPlayerEliminations
          rem Check each player for elimination
          currentPlayer = 0 : gosub CheckPlayerElimination
          currentPlayer = 1 : gosub CheckPlayerElimination  
          currentPlayer = 2 : gosub CheckPlayerElimination
          currentPlayer = 3 : gosub CheckPlayerElimination
          
          rem Count remaining players and check game end
          gosub CountRemainingPlayers
          gosub CheckGameEndCondition
          
          return

          rem =================================================================
          rem CHECK SINGLE PLAYER ELIMINATION
          rem =================================================================
          rem Check if specified player should be eliminated.
          rem INPUT: currentPlayer = player index (0-3)
CheckPlayerElimination
          rem Skip if already eliminated
          temp6 = BitMask[currentPlayer]
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          temp2 = playersEliminated & temp6
          if temp2 then return 
          rem Already eliminated
          
          rem Check if health has reached 0
          temp2 = playerHealth[currentPlayer]
          
          if temp2 > 0 then return 
          rem Still alive
          
          rem Player health reached 0 - eliminate them
          let playersEliminated = playersEliminated | temp6
          
          rem Update Players34Active flag if Player 3 or 4 was eliminated
          rem Only clear flag if both players 3 and 4 are eliminated or not selected
          rem Use skip-over pattern to avoid complex || operator
          if currentPlayer = 2 then gosub UpdatePlayers34ActiveFlag : goto UpdatePlayers34Done
          if currentPlayer = 3 then gosub UpdatePlayers34ActiveFlag
UpdatePlayers34Done
          
          rem Record elimination order
          let eliminationCounter = eliminationCounter + 1
          let eliminationOrder[currentPlayer] = eliminationCounter
          
          rem Trigger elimination effects
          gosub TriggerEliminationEffects
          
          return

          rem =================================================================
          rem TRIGGER ELIMINATION EFFECTS
          rem =================================================================
          rem Visual and audio effects when player is eliminated.
          rem INPUT: currentPlayer = eliminated player index (0-3)
TriggerEliminationEffects
          rem Play elimination sound effect
          temp5 = SoundElimination
          gosub bank15 PlaySoundEffect
          
          rem Set elimination visual effect timer
          rem This could trigger screen flash, particle effects, etc.
          temp2 = 30 
          rem 30 frames of elimination effect
          let eliminationEffectTimer[currentPlayer] = temp2
          
          rem Hide player sprite immediately
          gosub HideEliminatedPlayerSprite
          
          rem Stop any active missiles for this player
          gosub DeactivatePlayerMissiles
          
          return

          rem =================================================================
          rem HIDE ELIMINATED PLAYER SPRITE
          rem =================================================================
          rem Move eliminated player sprite off-screen.
          rem INPUT: currentPlayer = player index (0-3)
HideEliminatedPlayerSprite
          if currentPlayer = 0 then player0x = 200 
          rem Off-screen
          if currentPlayer = 1 then player1x = 200
          if currentPlayer = 2 then player2x = 200 
          rem Player 3 uses player2 sprite (multisprite)
          if currentPlayer = 3 then player3x = 200 
          rem Player 4 uses player3 sprite (multisprite)
          
          return

          rem =================================================================
          rem DEACTIVATE PLAYER MISSILES
          rem =================================================================
          rem Remove any active missiles belonging to eliminated player.
          rem INPUT: currentPlayer = player index (0-3)
DeactivatePlayerMissiles
          rem Clear missile active bit for this player
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if currentPlayer = 0 then temp6 = 1
          if currentPlayer = 1 then temp6 = 2
          if currentPlayer = 2 then temp6 = 4
          if currentPlayer = 3 then temp6 = 8
          temp6 = 255 - temp6 
          rem Invert bits for AND mask
          let missileActive = missileActive & temp6
          
          return

          rem =================================================================
          rem COUNT REMAINING PLAYERS
          rem =================================================================
          rem Count how many players are still alive.
          rem OUTPUT: temp1 = number of remaining players
CountRemainingPlayers
          temp1 = 0 
          rem Counter
          
          rem Check each player
          if !(playersEliminated & 1) then temp1 = temp1 + 1 
          rem Player 1
          if !(playersEliminated & 2) then temp1 = temp1 + 1 
          rem Player 2
          if !(playersEliminated & 4) then temp1 = temp1 + 1 
          rem Player 3  
          if !(playersEliminated & 8) then temp1 = temp1 + 1 
          rem Player 4
          
          let playersRemaining = temp1
          return

          rem =================================================================
          rem CHECK GAME END CONDITION
          rem =================================================================
          rem Check if game should end (1 or 0 players remaining).
CheckGameEndCondition
          rem Game ends when 1 or fewer players remain
if playersRemaining <= 1 then 
          rem Find winner (last remaining player)
          gosub FindWinner
          rem Start game end countdown  
          let gameEndTimer = 180 
          rem 3 seconds at 60 FPS
          let gameState = 2     
          rem Game ending state
          
          
          return

          rem =================================================================  
          rem IS PLAYER ELIMINATED
          rem =================================================================
          rem Check if specified player is eliminated.
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if eliminated, 0 if alive
IsPlayerEliminated
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if currentPlayer = 0 then temp6 = 1
          if currentPlayer = 1 then temp6 = 2
          if currentPlayer = 2 then temp6 = 4
          if currentPlayer = 3 then temp6 = 8
          temp2 = playersEliminated & temp6
          if temp2 then temp2 = 1 : goto IsEliminatedDone
          temp2 = 0
IsEliminatedDone
          return

          rem =================================================================
          rem IS PLAYER ALIVE  
          rem =================================================================
          rem Check if specified player is alive (not eliminated AND health > 0).
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if alive, 0 if eliminated/dead
IsPlayerAlive
          rem Check elimination flag first
          gosub IsPlayerEliminated
          if temp2 then return 
          rem Already eliminated
          
          rem Check health
          temp3 = playerHealth[currentPlayer]
          
          temp2 = 0 
          rem Default: not alive
          if temp3 > 0 then temp2 = 1 
          rem Alive if health > 0
          return

          rem =================================================================
          rem FIND WINNER
          rem =================================================================
          rem Identify the winning player (last one standing).
FindWinner
          rem Find the player who is not eliminated
          let winnerPlayerIndex = 255 
          rem Invalid initially
          
          currentPlayer = 0 : gosub IsPlayerEliminated
          if !temp2 then winnerPlayerIndex = 0
          currentPlayer = 1 : gosub IsPlayerEliminated  
          if !temp2 then winnerPlayerIndex = 1
          currentPlayer = 2 : gosub IsPlayerEliminated
          if !temp2 then winnerPlayerIndex = 2
          currentPlayer = 3 : gosub IsPlayerEliminated
          if !temp2 then winnerPlayerIndex = 3
          
          rem If no winner found (all eliminated), pick last eliminated
if winnerPlayerIndex = 255 then 
          gosub FindLastEliminated
          
          
          return

          rem =================================================================
          rem FIND LAST ELIMINATED
          rem =================================================================
          rem Find player who was eliminated most recently (highest elimination order).
FindLastEliminated
          temp4 = 0    
          rem Highest elimination order found
          let winnerPlayerIndex = 0 
          rem Default winner
          
          rem Check each player elimination order
if eliminationOrder[0] > temp4 then 
          temp4 = eliminationOrder[0]
          let winnerPlayerIndex = 0
          
if eliminationOrder[1] > temp4 then 
          temp4 = eliminationOrder[1] 
          let winnerPlayerIndex = 1
          
if eliminationOrder[2] > temp4 then 
          temp4 = eliminationOrder[2]
          let winnerPlayerIndex = 2
          
if eliminationOrder[3] > temp4 then 
          temp4 = eliminationOrder[3]
          let winnerPlayerIndex = 3
          
          rem =================================================================
          rem UPDATE PLAYERS 3/4 ACTIVE FLAG
          rem =================================================================
          rem Updates the Players34Active flag based on whether players 3 or 4
          rem are selected and not eliminated. Used for missile multiplexing.
UpdatePlayers34ActiveFlag
          rem Clear flag first
          let controllerStatus = controllerStatus & ClearPlayers34Active
          
          rem Check if Player 3 is active (selected and not eliminated)
          if selectedChar3 = 255 then goto CheckPlayer4ActiveFlag
          if playersEliminated & 4 then goto CheckPlayer4ActiveFlag
          rem Player 3 is active
          let controllerStatus = controllerStatus | SetPlayers34Active
          
CheckPlayer4ActiveFlag
          rem Check if Player 4 is active (selected and not eliminated)
          if selectedChar4 = 255 then goto UpdatePlayers34ActiveDone
          if playersEliminated & 8 then goto UpdatePlayers34ActiveDone
          rem Player 4 is active
          let controllerStatus = controllerStatus | SetPlayers34Active
          
UpdatePlayers34ActiveDone
          return
