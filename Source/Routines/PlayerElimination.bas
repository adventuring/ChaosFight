CheckAllPlayerEliminations
          rem
          rem ChaosFight - Source/Routines/PlayerElimination.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Player Elimination System
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
          rem
          rem   playersEliminated - Bit flags for eliminated players
          rem   playersRemaining - Count of active players
          rem   gameEndTimer - Countdown to game end screen
          rem Check All Player Eliminations
          rem Called each frame to check if any players should be
          rem   eliminated.
          rem Sets elimination flags and triggers elimination effects.
          rem Check all players for elimination and handle game end
          rem condition
          rem Input: playerHealth[] (global array) = player health
          rem values, playersEliminated_R (global SCRAM) = elimination
          rem flags
          rem Output: Players eliminated if health reaches 0, game end
          rem triggered if 1 or fewer players remain
          rem Mutates: currentPlayer (global loop variable),
          rem playersEliminated_W (global SCRAM) = elimination flags,
          rem eliminationCounter (global) = elimination order counter,
          rem eliminationOrder[] (global array) = elimination order,
          rem playersRemaining (global) = count of remaining players,
          rem gameEndTimer (global) = game end countdown, systemFlags
          rem (global) = system state flags, player sprite positions
          rem (via TriggerEliminationEffects), missileActive (global) =
          rem missile state (via DeactivatePlayerMissiles)
          rem Called Routines: CheckPlayerElimination (for each player),
          rem CountRemainingPlayers, FindWinner (if game end),
          rem TriggerEliminationEffects (via CheckPlayerElimination),
          rem DeactivatePlayerMissiles (via TriggerEliminationEffects),
          rem UpdatePlayers34ActiveFlag (via CheckPlayerElimination),
          rem PlaySoundEffect (bank15, via TriggerEliminationEffects)
          rem Constraints: None
          for currentPlayer = 0 to 3 : rem Check each player for elimination using FOR loop
              gosub CheckPlayerElimination
          next
          
          rem Count remaining players and check game end (inline
          gosub CountRemainingPlayers : rem   CheckGameEndCondition)
          rem Game ends when 1 or fewer players remain
          if playersRemaining <= 1 then gosub FindWinner : let gameEndTimer = 180 : let systemFlags = systemFlags | SystemFlagGameStateEnding : return
          

CheckPlayerElimination
          rem
          rem Check Single Player Elimination
          rem
          rem Check if specified player should be eliminated.
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem
          rem MUTATES:
          rem   temp2 = CPE_isEliminated / CPE_health (reused, internal)
          rem   temp6 = CPE_bitMask (internal)
          rem WARNING: temp2 and temp6 are mutated during execution. Do
          rem not
          rem   use these temp variables after calling this subroutine.
          rem EFFECTS:
          rem   Sets playersEliminated bit flags
          rem Check if specified player should be eliminated (health =
          rem 0)
          rem Input: currentPlayer (global) = player index (0-3),
          rem playerHealth[] (global array) = player health values,
          rem playersEliminated_R (global SCRAM) = elimination flags,
          rem BitMask[] (global data table) = bit masks for players
          rem Output: Player eliminated if health = 0, elimination
          rem effects triggered
          rem Mutates: temp2 (used for isEliminated/health check), temp6
          rem (used for bit mask), playersEliminated_W (global SCRAM) =
          rem elimination flags, eliminationCounter (global) =
          rem elimination order counter, eliminationOrder[] (global
          rem array) = elimination order, controllerStatus (global) =
          rem controller state (via UpdatePlayers34ActiveFlag), player
          rem sprite positions (via TriggerEliminationEffects),
          rem missileActive (global) = missile state (via
          rem DeactivatePlayerMissiles), eliminationEffectTimer[]
          rem (global array) = effect timers (via
          rem TriggerEliminationEffects)
          rem Called Routines: UpdatePlayers34ActiveFlag (if player 2 or
          rem 3 eliminated), TriggerEliminationEffects (tail call),
          rem DeactivatePlayerMissiles (via TriggerEliminationEffects),
          rem PlaySoundEffect (bank15, via TriggerEliminationEffects)
          rem Constraints: WARNING - temp2 and temp6 are mutated during
          rem execution. Do not use these temp variables after calling
          rem this subroutine.
          dim CPE_bitMask = temp6
          dim CPE_isEliminated = temp2
          dim CPE_health = temp2
          let CPE_bitMask = BitMask[currentPlayer] : rem Skip if already eliminated
          let CPE_isEliminated = CPE_bitMask & playersEliminated_R : rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if CPE_isEliminated then return 
          rem Already eliminated
          
          let CPE_health = playerHealth[currentPlayer] : rem Check if health has reached 0
          
          if CPE_health then return 
          rem Still alive
          
          rem Player health reached 0 - eliminate them
          let CPE_eliminatedFlags = playersEliminated_R | CPE_bitMask : rem Fix RMW: Read from _R, modify, write to _W
          let playersEliminated_W = CPE_eliminatedFlags
          
          rem Update Players34Active flag if Player 3 or 4 was
          rem   eliminated
          rem Only clear flag if both players 3 and 4 are eliminated or
          rem   not selected
          rem Use skip-over pattern to avoid complex || operator
          if currentPlayer = 2 then gosub UpdatePlayers34ActiveFlag : goto UpdatePlayers34Done
          if currentPlayer = 3 then gosub UpdatePlayers34ActiveFlag
UpdatePlayers34Done
          
          let eliminationCounter = eliminationCounter + 1 : rem Record elimination order
          let eliminationOrder[currentPlayer] = eliminationCounter
          
          rem Trigger elimination effects
          goto TriggerEliminationEffects : rem tail call
          

TriggerEliminationEffects
          rem
          rem Trigger Elimination Effects
          rem Visual and audio effects when player is eliminated.
          rem INPUT: currentPlayer = eliminated player index (0-3)
          rem (global variable)
          rem Visual and audio effects when player is eliminated
          rem Input: currentPlayer (global) = eliminated player index
          rem (0-3), SoundPlayerEliminated (global constant) =
          rem elimination sound ID
          rem Output: Elimination sound played, visual effect timer set,
          rem sprite hidden, missiles deactivated
          rem Mutates: temp2 (used for effect timer), temp5 (used for
          rem sound ID), player0x, player1x, player2x, player3x (TIA
          rem registers) = sprite positions moved off-screen,
          rem eliminationEffectTimer[] (global array) = effect timers,
          rem missileActive (global) = missile state (via
          rem DeactivatePlayerMissiles)
          rem Called Routines: PlaySoundEffect (bank15) - plays
          rem elimination sound, DeactivatePlayerMissiles (tail call) -
          rem removes player missiles
          dim TEE_soundId = temp5 : rem Constraints: None
          dim TEE_effectTimer = temp2
          let TEE_soundId = SoundPlayerEliminated : rem Play elimination sound effect
          let PSE_soundID = TEE_soundId
          gosub PlaySoundEffect bank15 : rem PlaySoundEffect expects temp1 (PSE_soundID alias)
          
          rem Set elimination visual effect timer
          let TEE_effectTimer = 30 : rem This could trigger screen flash, particle effects, etc.
          let eliminationEffectTimer[currentPlayer] = TEE_effectTimer : rem 30 frames of elimination effect
          
          rem Hide player sprite immediately
          if currentPlayer = 0 then player0x = 200 : rem Inline HideEliminatedPlayerSprite
          if currentPlayer = 1 then player1x = 200 : rem Off-screen
          if currentPlayer = 2 then player2x = 200 
          if currentPlayer = 3 then player3x = 200 : rem Player 3 uses player2 sprite (multisprite)
          rem Player 4 uses player3 sprite (multisprite)
          
          rem Stop any active missiles for this player
          goto DeactivatePlayerMissiles : rem tail call
          

          return
          rem
          rem Hide Eliminated Player Sprite
          rem Move eliminated player sprite off-screen.
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem Player 4 uses player3 sprite (multisprite)
          rem   TriggerEliminationEffects
DeactivatePlayerMissiles
          rem NOTE: This function is now inlined in
          rem
          rem Deactivate Player Missiles
          rem Remove any active missiles belonging to eliminated player.
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem Remove any active missiles belonging to eliminated player
          rem Input: currentPlayer (global) = player index (0-3),
          rem missileActive (global) = missile active flags
          rem Output: Missile active flag cleared for specified player
          rem Mutates: temp6 (used for bit mask calculation),
          rem missileActive (global) = missile active flags
          rem Called Routines: None
          dim DPM_bitMask = temp6 : rem Constraints: None
          dim DPM_invertedMask = temp6
          rem Clear missile active bit for this player
          if currentPlayer = 0 then let DPM_bitMask = 1 : rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if currentPlayer = 1 then let DPM_bitMask = 2
          if currentPlayer = 2 then let DPM_bitMask = 4
          if currentPlayer = 3 then let DPM_bitMask = 8
          let DPM_invertedMask = 255 - DPM_bitMask 
          let missileActive = missileActive & DPM_invertedMask : rem Invert bits for AND mask
          
          return

CountRemainingPlayers
          rem
          rem Count Remaining Players
          rem Count how many players are still alive.
          rem OUTPUT: temp1 = number of remaining players
          rem Count how many players are still alive (not eliminated)
          rem Input: playersEliminated_R (global SCRAM) = elimination
          rem flags, PlayerEliminatedPlayer0-3 (global constants) =
          rem elimination bit masks
          rem Output: playersRemaining (global) = number of remaining
          rem players, temp1 = count (return value)
          rem Mutates: temp1 (used for count), playersRemaining (global)
          rem = count of remaining players
          rem Called Routines: None
          dim CRP_count = temp1 : rem Constraints: None
          let CRP_count = 0 
          rem Counter
          
          if !(PlayerEliminatedPlayer0 & playersEliminated_R) then let CRP_count = 1 + CRP_count : rem Check each player
          if !(PlayerEliminatedPlayer1 & playersEliminated_R) then let CRP_count = 1 + CRP_count : rem Player 1
          if !(PlayerEliminatedPlayer2 & playersEliminated_R) then let CRP_count = 1 + CRP_count : rem Player 2
          if !(PlayerEliminatedPlayer3 & playersEliminated_R) then let CRP_count = 1 + CRP_count : rem Player 3
          rem Player 4
          
          let playersRemaining = CRP_count
          return

IsPlayerEliminated
          rem
          rem Check Game End Condition
          rem
          rem Check if game should end (1 or 0 players remaining).
          rem Is Player Eliminated
          rem Check if specified player is eliminated.
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem OUTPUT: temp2 = 1 if eliminated, 0 if alive
          rem Check if specified player is eliminated
          rem Input: currentPlayer (global) = player index (0-3),
          rem playersEliminated_R (global SCRAM) = elimination flags,
          rem PlayerEliminatedPlayer0-3 (global constants) = elimination
          rem bit masks
          rem Output: temp2 = 1 if eliminated, 0 if alive
          rem Mutates: temp2 (return value), temp6 (used for bit mask)
          rem Called Routines: None
          dim IPE_bitMask = temp6 : rem Constraints: None
          dim IPE_isEliminated = temp2
          if currentPlayer = 0 then let IPE_bitMask = PlayerEliminatedPlayer0 : rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if currentPlayer = 1 then let IPE_bitMask = PlayerEliminatedPlayer1
          if currentPlayer = 2 then let IPE_bitMask = PlayerEliminatedPlayer2
          if currentPlayer = 3 then let IPE_bitMask = PlayerEliminatedPlayer3
          let IPE_isEliminated = IPE_bitMask & playersEliminated_R
          if IPE_isEliminated then let IPE_isEliminated = 1 : goto IsEliminatedDone
          let IPE_isEliminated = 0
IsEliminatedDone
          let temp2 = IPE_isEliminated
          return

IsPlayerAlive
          rem
          rem Is Player Alive
          rem Check if specified player is alive (not eliminated AND
          rem   health > 0).
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem OUTPUT: temp2 = 1 if alive, 0 if eliminated/dead
          rem Check if specified player is alive (not eliminated AND
          rem health > 0)
          rem Input: currentPlayer (global) = player index (0-3),
          rem playerHealth[] (global array) = player health values,
          rem playersEliminated_R (global SCRAM) = elimination flags
          rem Output: temp2 = 1 if alive, 0 if eliminated/dead
          rem Mutates: temp2 (return value, reused for isEliminated and
          rem isAlive), temp3 (used for health check)
          rem Called Routines: IsPlayerEliminated - checks elimination
          rem flag
          dim IPA_isEliminated = temp2 : rem Constraints: None
          dim IPA_health = temp3
          dim IPA_isAlive = temp2
          gosub IsPlayerEliminated : rem Check elimination flag first
          let IPA_isEliminated = temp2
          if IPA_isEliminated then return 
          rem Already eliminated
          
          let IPA_health = playerHealth[currentPlayer] : rem Check health
          
          let IPA_isAlive = 0 
          if IPA_health > 0 then let IPA_isAlive = 1 : rem Default: not alive
          let temp2 = IPA_isAlive : rem Alive if health > 0
          return

          rem
          rem Find Winner
          rem Identify the winning player (last one standing).
FindWinner
          rem Identify the winning player (last one standing)
          rem Input: currentPlayer (global loop variable),
          rem playersEliminated_R (global SCRAM) = elimination flags,
          rem eliminationOrder[] (global array) = elimination order
          rem Output: winnerPlayerIndex (global) = winning player index
          rem (0-3) or 255 if all eliminated
          rem Mutates: temp2 (used for isEliminated check),
          rem currentPlayer (global loop variable), winnerPlayerIndex
          rem (global) = winner index
          rem Called Routines: IsPlayerEliminated - checks each player
          rem elimination status, FindLastEliminated (tail call) - if no
          rem winner found
          dim FW_isEliminated = temp2 : rem Constraints: None
          let winnerPlayerIndex = 255 : rem Find the player who is not eliminated
          rem Invalid initially
          
          for currentPlayer = 0 to 3 : rem Check each player using FOR loop
              gosub IsPlayerEliminated
              let FW_isEliminated = temp2
              if !FW_isEliminated then let winnerPlayerIndex = currentPlayer
          next
          
          rem If no winner found (all eliminated), pick last eliminated
          if winnerPlayerIndex = 255 then goto FindLastEliminated : rem tail call

          rem
          rem Find Last Eliminated
          rem Find player who was eliminated most recently (highest
          rem   elimination order).
FindLastEliminated
          rem Find player who was eliminated most recently (highest
          rem elimination order)
          rem Input: currentPlayer (global loop variable),
          rem eliminationOrder[] (global array) = elimination order
          rem Output: winnerPlayerIndex (global) = player with highest
          rem elimination order (last eliminated)
          rem Mutates: temp4 (used for order comparison), currentPlayer
          rem (global loop variable), winnerPlayerIndex (global) =
          rem winner index
          rem Called Routines: None
          dim FLE_highestOrder = temp4 : rem Constraints: None
          dim FLE_currentOrder = temp4
          let FLE_highestOrder = 0    
          let winnerPlayerIndex = 0 : rem Highest elimination order found
          rem Default winner
          
          for currentPlayer = 0 to 3 : rem Check each player elimination order using FOR loop
              let FLE_currentOrder = eliminationOrder[currentPlayer]
              if FLE_currentOrder > FLE_highestOrder then let FLE_highestOrder = FLE_currentOrder : let winnerPlayerIndex = currentPlayer
          next
          
          rem
          rem UPDATE PLAYERS 3/4 ACTIVE FLAG
          rem Updates the Players34Active flag based on whether players
          rem   3 or 4
          rem are selected and not eliminated. Used for missile
          rem   multiplexing.
UpdatePlayers34ActiveFlag
          rem Updates the Players34Active flag based on whether players
          rem 3 or 4 are selected and not eliminated
          rem Input: selectedChar3_R, selectedChar4_R (global SCRAM) =
          rem player 3/4 character selections, playersEliminated_R
          rem (global SCRAM) = elimination flags,
          rem PlayerEliminatedPlayer2, PlayerEliminatedPlayer3 (global
          rem constants) = elimination bit masks, controllerStatus
          rem (global) = controller state
          rem Output: controllerStatus (global) = controller state with
          rem Players34Active flag updated
          rem Mutates: controllerStatus (global) = controller state
          rem flags
          rem Called Routines: None
          rem Constraints: Used for missile multiplexing - flag
          rem indicates if players 3/4 need missile updates
          let controllerStatus = controllerStatus & ClearPlayers34Active : rem Clear flag first
          
          if 255 = selectedChar3_R then CheckPlayer4ActiveFlag : rem Check if Player 3 is active (selected and not eliminated)
          if PlayerEliminatedPlayer2 & playersEliminated_R then CheckPlayer4ActiveFlag
          let controllerStatus = controllerStatus | SetPlayers34Active : rem Player 3 is active
          
CheckPlayer4ActiveFlag
          if 255 = selectedChar4_R then UpdatePlayers34ActiveDone : rem Check if Player 4 is active (selected and not eliminated)
          if PlayerEliminatedPlayer3 & playersEliminated_R then UpdatePlayers34ActiveDone
          let controllerStatus = controllerStatus | SetPlayers34Active : rem Player 4 is active
          
UpdatePlayers34ActiveDone
          return
