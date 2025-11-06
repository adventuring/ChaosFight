          rem ChaosFight - Source/Routines/PlayerElimination.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem PLAYER ELIMINATION SYSTEM
          rem ==========================================================
          rem Handles player elimination when health reaches 0, game end
          rem   conditions,
          rem and removal of eliminated players from active gameplay
          rem   systems.

          rem ELIMINATION PROCESS:
          rem   1. Detect when player health reaches 0
          rem   2. Set elimination flag and play elimination effects
          rem 3. Remove player from active input/physics/collision
          rem   systems
          rem   4. Hide player sprite and health bar
          rem   5. Check for game end conditions (1 player remaining)

          rem VARIABLES:
          rem   playersEliminated - Bit flags for eliminated players
          rem   playersRemaining - Count of active players
          rem   gameEndTimer - Countdown to game end screen
          rem ==========================================================

          rem ==========================================================
          rem CHECK ALL PLAYER ELIMINATIONS
          rem ==========================================================
          rem Called each frame to check if any players should be
          rem   eliminated.
          rem Sets elimination flags and triggers elimination effects.
CheckAllPlayerEliminations
          rem Check all players for elimination and handle game end condition
          rem Input: playerHealth[] (global array) = player health values, playersEliminated_R (global SCRAM) = elimination flags
          rem Output: Players eliminated if health reaches 0, game end triggered if 1 or fewer players remain
          rem Mutates: currentPlayer (global loop variable), playersEliminated_W (global SCRAM) = elimination flags, eliminationCounter (global) = elimination order counter, eliminationOrder[] (global array) = elimination order, playersRemaining (global) = count of remaining players, gameEndTimer (global) = game end countdown, systemFlags (global) = system state flags, player sprite positions (via TriggerEliminationEffects), missileActive (global) = missile state (via DeactivatePlayerMissiles)
          rem Called Routines: CheckPlayerElimination (for each player), CountRemainingPlayers, FindWinner (if game end), TriggerEliminationEffects (via CheckPlayerElimination), DeactivatePlayerMissiles (via TriggerEliminationEffects), UpdatePlayers34ActiveFlag (via CheckPlayerElimination), PlaySoundEffect (bank15, via TriggerEliminationEffects)
          rem Constraints: None
          rem Check each player for elimination using FOR loop
          for currentPlayer = 0 to 3
              gosub CheckPlayerElimination
          next
          
          rem Count remaining players and check game end (inline
          rem   CheckGameEndCondition)
          gosub CountRemainingPlayers
          rem Game ends when 1 or fewer players remain
          if playersRemaining <= 1 then gosub FindWinner : let gameEndTimer = 180 : let systemFlags = systemFlags | SystemFlagGameStateEnding : return
          

          rem ==========================================================
          rem CHECK SINGLE PLAYER ELIMINATION
          rem ==========================================================
          rem Check if specified player should be eliminated.
          rem INPUT: currentPlayer = player index (0-3) (global variable)
          rem
          rem MUTATES:
          rem   temp2 = CPE_isEliminated / CPE_health (reused, internal)
          rem   temp6 = CPE_bitMask (internal)
          rem WARNING: temp2 and temp6 are mutated during execution. Do not
          rem   use these temp variables after calling this subroutine.
          rem
          rem EFFECTS:
          rem   Sets playersEliminated bit flags
CheckPlayerElimination
          rem Check if specified player should be eliminated (health = 0)
          rem Input: currentPlayer (global) = player index (0-3), playerHealth[] (global array) = player health values, playersEliminated_R (global SCRAM) = elimination flags, BitMask[] (global data table) = bit masks for players
          rem Output: Player eliminated if health = 0, elimination effects triggered
          rem Mutates: temp2 (used for isEliminated/health check), temp6 (used for bit mask), playersEliminated_W (global SCRAM) = elimination flags, eliminationCounter (global) = elimination order counter, eliminationOrder[] (global array) = elimination order, controllerStatus (global) = controller state (via UpdatePlayers34ActiveFlag), player sprite positions (via TriggerEliminationEffects), missileActive (global) = missile state (via DeactivatePlayerMissiles), eliminationEffectTimer[] (global array) = effect timers (via TriggerEliminationEffects)
          rem Called Routines: UpdatePlayers34ActiveFlag (if player 2 or 3 eliminated), TriggerEliminationEffects (tail call), DeactivatePlayerMissiles (via TriggerEliminationEffects), PlaySoundEffect (bank15, via TriggerEliminationEffects)
          rem Constraints: WARNING - temp2 and temp6 are mutated during execution. Do not use these temp variables after calling this subroutine.
          dim CPE_bitMask = temp6
          dim CPE_isEliminated = temp2
          dim CPE_health = temp2
          rem Skip if already eliminated
          let CPE_bitMask = BitMask[currentPlayer]
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          let CPE_isEliminated = CPE_bitMask & playersEliminated_R
          if CPE_isEliminated then return 
          rem Already eliminated
          
          rem Check if health has reached 0
          let CPE_health = playerHealth[currentPlayer]
          
          if CPE_health then return 
          rem Still alive
          
          rem Player health reached 0 - eliminate them
          rem Fix RMW: Read from _R, modify, write to _W
          let CPE_eliminatedFlags = playersEliminated_R | CPE_bitMask
          let playersEliminated_W = CPE_eliminatedFlags
          
          rem Update Players34Active flag if Player 3 or 4 was
          rem   eliminated
          rem Only clear flag if both players 3 and 4 are eliminated or
          rem   not selected
          rem Use skip-over pattern to avoid complex || operator
          if currentPlayer = 2 then gosub UpdatePlayers34ActiveFlag : goto UpdatePlayers34Done
          if currentPlayer = 3 then gosub UpdatePlayers34ActiveFlag
UpdatePlayers34Done
          
          rem Record elimination order
          let eliminationCounter = eliminationCounter + 1
          let eliminationOrder[currentPlayer] = eliminationCounter
          
          rem Trigger elimination effects
          rem tail call
          goto TriggerEliminationEffects
          

          rem ==========================================================
          rem TRIGGER ELIMINATION EFFECTS
          rem ==========================================================
          rem Visual and audio effects when player is eliminated.
          rem INPUT: currentPlayer = eliminated player index (0-3) (global variable)
TriggerEliminationEffects
          rem Visual and audio effects when player is eliminated
          rem Input: currentPlayer (global) = eliminated player index (0-3), SoundPlayerEliminated (global constant) = elimination sound ID
          rem Output: Elimination sound played, visual effect timer set, sprite hidden, missiles deactivated
          rem Mutates: temp2 (used for effect timer), temp5 (used for sound ID), player0x, player1x, player2x, player3x (TIA registers) = sprite positions moved off-screen, eliminationEffectTimer[] (global array) = effect timers, missileActive (global) = missile state (via DeactivatePlayerMissiles)
          rem Called Routines: PlaySoundEffect (bank15) - plays elimination sound, DeactivatePlayerMissiles (tail call) - removes player missiles
          rem Constraints: None
          dim TEE_soundId = temp5
          dim TEE_effectTimer = temp2
          rem Play elimination sound effect
          let TEE_soundId = SoundPlayerEliminated
          let PSE_soundID = TEE_soundId
          rem PlaySoundEffect expects temp1 (PSE_soundID alias)
          gosub PlaySoundEffect bank15
          
          rem Set elimination visual effect timer
          rem This could trigger screen flash, particle effects, etc.
          let TEE_effectTimer = 30 
          rem 30 frames of elimination effect
          let eliminationEffectTimer[currentPlayer] = TEE_effectTimer
          
          rem Hide player sprite immediately
          rem Inline HideEliminatedPlayerSprite
          if currentPlayer = 0 then player0x = 200 
          rem Off-screen
          if currentPlayer = 1 then player1x = 200
          if currentPlayer = 2 then player2x = 200 
          rem Player 3 uses player2 sprite (multisprite)
          if currentPlayer = 3 then player3x = 200 
          rem Player 4 uses player3 sprite (multisprite)
          
          rem Stop any active missiles for this player
          rem tail call
          goto DeactivatePlayerMissiles
          

          rem ==========================================================
          rem HIDE ELIMINATED PLAYER SPRITE
          rem ==========================================================
          rem Move eliminated player sprite off-screen.
          rem INPUT: currentPlayer = player index (0-3) (global variable)
          rem Player 4 uses player3 sprite (multisprite)
          rem   TriggerEliminationEffects
          rem NOTE: This function is now inlined in
          
          return

          rem ==========================================================
          rem DEACTIVATE PLAYER MISSILES
          rem ==========================================================
          rem Remove any active missiles belonging to eliminated player.
          rem INPUT: currentPlayer = player index (0-3) (global variable)
DeactivatePlayerMissiles
          rem Remove any active missiles belonging to eliminated player
          rem Input: currentPlayer (global) = player index (0-3), missileActive (global) = missile active flags
          rem Output: Missile active flag cleared for specified player
          rem Mutates: temp6 (used for bit mask calculation), missileActive (global) = missile active flags
          rem Called Routines: None
          rem Constraints: None
          dim DPM_bitMask = temp6
          dim DPM_invertedMask = temp6
          rem Clear missile active bit for this player
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if currentPlayer = 0 then let DPM_bitMask = 1
          if currentPlayer = 1 then let DPM_bitMask = 2
          if currentPlayer = 2 then let DPM_bitMask = 4
          if currentPlayer = 3 then let DPM_bitMask = 8
          let DPM_invertedMask = 255 - DPM_bitMask 
          rem Invert bits for AND mask
          let missileActive = missileActive & DPM_invertedMask
          
          return

          rem ==========================================================
          rem COUNT REMAINING PLAYERS
          rem ==========================================================
          rem Count how many players are still alive.
          rem OUTPUT: temp1 = number of remaining players
CountRemainingPlayers
          rem Count how many players are still alive (not eliminated)
          rem Input: playersEliminated_R (global SCRAM) = elimination flags, PlayerEliminatedPlayer0-3 (global constants) = elimination bit masks
          rem Output: playersRemaining (global) = number of remaining players, temp1 = count (return value)
          rem Mutates: temp1 (used for count), playersRemaining (global) = count of remaining players
          rem Called Routines: None
          rem Constraints: None
          dim CRP_count = temp1
          let CRP_count = 0 
          rem Counter
          
          rem Check each player
          if !(PlayerEliminatedPlayer0 & playersEliminated_R) then let CRP_count = 1 + CRP_count
          rem Player 1
          if !(PlayerEliminatedPlayer1 & playersEliminated_R) then let CRP_count = 1 + CRP_count
          rem Player 2
          if !(PlayerEliminatedPlayer2 & playersEliminated_R) then let CRP_count = 1 + CRP_count
          rem Player 3  
          if !(PlayerEliminatedPlayer3 & playersEliminated_R) then let CRP_count = 1 + CRP_count
          rem Player 4
          
          let playersRemaining = CRP_count
          return

          rem ==========================================================
          rem CHECK GAME END CONDITION
          rem ==========================================================
          rem Check if game should end (1 or 0 players remaining).
          rem ==========================================================
          rem IS PLAYER ELIMINATED
          rem ==========================================================
          rem Check if specified player is eliminated.
          rem INPUT: currentPlayer = player index (0-3) (global variable)
          rem OUTPUT: temp2 = 1 if eliminated, 0 if alive
IsPlayerEliminated
          rem Check if specified player is eliminated
          rem Input: currentPlayer (global) = player index (0-3), playersEliminated_R (global SCRAM) = elimination flags, PlayerEliminatedPlayer0-3 (global constants) = elimination bit masks
          rem Output: temp2 = 1 if eliminated, 0 if alive
          rem Mutates: temp2 (return value), temp6 (used for bit mask)
          rem Called Routines: None
          rem Constraints: None
          dim IPE_bitMask = temp6
          dim IPE_isEliminated = temp2
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if currentPlayer = 0 then let IPE_bitMask = PlayerEliminatedPlayer0
          if currentPlayer = 1 then let IPE_bitMask = PlayerEliminatedPlayer1
          if currentPlayer = 2 then let IPE_bitMask = PlayerEliminatedPlayer2
          if currentPlayer = 3 then let IPE_bitMask = PlayerEliminatedPlayer3
          let IPE_isEliminated = IPE_bitMask & playersEliminated_R
          if IPE_isEliminated then let IPE_isEliminated = 1 : goto IsEliminatedDone
          let IPE_isEliminated = 0
IsEliminatedDone
          let temp2 = IPE_isEliminated
          return

          rem ==========================================================
          rem IS PLAYER ALIVE  
          rem ==========================================================
          rem Check if specified player is alive (not eliminated AND
          rem   health > 0).
          rem INPUT: currentPlayer = player index (0-3) (global variable)
          rem OUTPUT: temp2 = 1 if alive, 0 if eliminated/dead
IsPlayerAlive
          rem Check if specified player is alive (not eliminated AND health > 0)
          rem Input: currentPlayer (global) = player index (0-3), playerHealth[] (global array) = player health values, playersEliminated_R (global SCRAM) = elimination flags
          rem Output: temp2 = 1 if alive, 0 if eliminated/dead
          rem Mutates: temp2 (return value, reused for isEliminated and isAlive), temp3 (used for health check)
          rem Called Routines: IsPlayerEliminated - checks elimination flag
          rem Constraints: None
          dim IPA_isEliminated = temp2
          dim IPA_health = temp3
          dim IPA_isAlive = temp2
          rem Check elimination flag first
          gosub IsPlayerEliminated
          let IPA_isEliminated = temp2
          if IPA_isEliminated then return 
          rem Already eliminated
          
          rem Check health
          let IPA_health = playerHealth[currentPlayer]
          
          let IPA_isAlive = 0 
          rem Default: not alive
          if IPA_health > 0 then let IPA_isAlive = 1 
          rem Alive if health > 0
          let temp2 = IPA_isAlive
          return

          rem ==========================================================
          rem FIND WINNER
          rem ==========================================================
          rem Identify the winning player (last one standing).
FindWinner
          rem Identify the winning player (last one standing)
          rem Input: currentPlayer (global loop variable), playersEliminated_R (global SCRAM) = elimination flags, eliminationOrder[] (global array) = elimination order
          rem Output: winnerPlayerIndex (global) = winning player index (0-3) or 255 if all eliminated
          rem Mutates: temp2 (used for isEliminated check), currentPlayer (global loop variable), winnerPlayerIndex (global) = winner index
          rem Called Routines: IsPlayerEliminated - checks each player elimination status, FindLastEliminated (tail call) - if no winner found
          rem Constraints: None
          dim FW_isEliminated = temp2
          rem Find the player who is not eliminated
          let winnerPlayerIndex = 255 
          rem Invalid initially
          
          rem Check each player using FOR loop
          for currentPlayer = 0 to 3
              gosub IsPlayerEliminated
              let FW_isEliminated = temp2
              if !FW_isEliminated then let winnerPlayerIndex = currentPlayer
          next
          
          rem If no winner found (all eliminated), pick last eliminated
          rem tail call
          if winnerPlayerIndex = 255 then goto FindLastEliminated

          rem ==========================================================
          rem FIND LAST ELIMINATED
          rem ==========================================================
          rem Find player who was eliminated most recently (highest
          rem   elimination order).
FindLastEliminated
          rem Find player who was eliminated most recently (highest elimination order)
          rem Input: currentPlayer (global loop variable), eliminationOrder[] (global array) = elimination order
          rem Output: winnerPlayerIndex (global) = player with highest elimination order (last eliminated)
          rem Mutates: temp4 (used for order comparison), currentPlayer (global loop variable), winnerPlayerIndex (global) = winner index
          rem Called Routines: None
          rem Constraints: None
          dim FLE_highestOrder = temp4
          dim FLE_currentOrder = temp4
          let FLE_highestOrder = 0    
          rem Highest elimination order found
          let winnerPlayerIndex = 0 
          rem Default winner
          
          rem Check each player elimination order using FOR loop
          for currentPlayer = 0 to 3
              let FLE_currentOrder = eliminationOrder[currentPlayer]
              if FLE_currentOrder > FLE_highestOrder then let FLE_highestOrder = FLE_currentOrder : let winnerPlayerIndex = currentPlayer
          next
          
          rem ==========================================================
          rem UPDATE PLAYERS 3/4 ACTIVE FLAG
          rem ==========================================================
          rem Updates the Players34Active flag based on whether players
          rem   3 or 4
          rem are selected and not eliminated. Used for missile
          rem   multiplexing.
UpdatePlayers34ActiveFlag
          rem Updates the Players34Active flag based on whether players 3 or 4 are selected and not eliminated
          rem Input: selectedChar3_R, selectedChar4_R (global SCRAM) = player 3/4 character selections, playersEliminated_R (global SCRAM) = elimination flags, PlayerEliminatedPlayer2, PlayerEliminatedPlayer3 (global constants) = elimination bit masks, controllerStatus (global) = controller state
          rem Output: controllerStatus (global) = controller state with Players34Active flag updated
          rem Mutates: controllerStatus (global) = controller state flags
          rem Called Routines: None
          rem Constraints: Used for missile multiplexing - flag indicates if players 3/4 need missile updates
          rem Clear flag first
          let controllerStatus = controllerStatus & ClearPlayers34Active
          
          rem Check if Player 3 is active (selected and not eliminated)
          if 255 = selectedChar3_R then CheckPlayer4ActiveFlag
          if PlayerEliminatedPlayer2 & playersEliminated_R then CheckPlayer4ActiveFlag
          rem Player 3 is active
          let controllerStatus = controllerStatus | SetPlayers34Active
          
CheckPlayer4ActiveFlag
          rem Check if Player 4 is active (selected and not eliminated)
          if 255 = selectedChar4_R then UpdatePlayers34ActiveDone
          if PlayerEliminatedPlayer3 & playersEliminated_R then UpdatePlayers34ActiveDone
          rem Player 4 is active
          let controllerStatus = controllerStatus | SetPlayers34Active
          
UpdatePlayers34ActiveDone
          return
