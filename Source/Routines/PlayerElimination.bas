          rem ChaosFight - Source/Routines/PlayerElimination.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckAllPlayerEliminations
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
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values, playersEliminated_R (global SCRAM) = elimination
          rem flags
          rem
          rem Output: Players eliminated if health reaches 0, game end
          rem triggered if 1 or fewer players remain
          rem
          rem Mutates: currentPlayer (global loop variable),
          rem playersEliminated_W (global SCRAM) = elimination flags,
          rem eliminationCounter (global) = elimination order counter,
          rem eliminationOrder[] (global array) = elimination order,
          rem playersRemaining (global) = count of remaining players,
          rem gameEndTimer (global) = game end countdown, systemFlags
          rem (global) = system state flags, player sprite positions
          rem (via TriggerEliminationEffects), missileActive (global) =
          rem missile state (via DeactivatePlayerMissiles)
          rem
          rem Called Routines: CheckPlayerElimination (for each player),
          rem CountRemainingPlayers, FindWinner (if game end),
          rem TriggerEliminationEffects (via CheckPlayerElimination),
          rem DeactivatePlayerMissiles (via TriggerEliminationEffects),
          rem UpdatePlayers34ActiveFlag (via CheckPlayerElimination),
          rem PlaySoundEffect (bank15, via TriggerEliminationEffects)
          rem
          rem Constraints: None
          for currentPlayer = 0 to 3
          rem Check each player for elimination using FOR loop
              gosub CheckPlayerElimination
          next
          
          rem Count remaining players and check game end (inline
          gosub CountRemainingPlayers
          rem   CheckGameEndCondition)
          rem Game ends when 1 or fewer players remain
          if playersRemaining_R <= 1 then gosub FindWinner : let gameEndTimer_W = 180 : let systemFlags = systemFlags | SystemFlagGameStateEnding : return
          

CheckPlayerElimination
          rem
          rem Check Single Player Elimination
          rem
          rem Check if specified player should be eliminated.
          rem
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem
          rem MUTATES:
          rem   temp2 = temp2 / temp2 (reused, internal)
          rem   temp6 = temp6 (internal)
          rem WARNING: temp2 and temp6 are mutated during execution. Do
          rem not
          rem   use these temp variables after calling this subroutine.
          rem
          rem EFFECTS:
          rem   Sets playersEliminated bit flags
          rem Check if specified player should be eliminated (health =
          rem 0)
          rem
          rem Input: currentPlayer (global) = player index (0-3),
          rem playerHealth[] (global array) = player health values,
          rem playersEliminated_R (global SCRAM) = elimination flags,
          rem BitMask[] (global data table) = bit masks for players
          rem
          rem Output: Player eliminated if health = 0, elimination
          rem effects triggered
          rem
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
          rem
          rem Called Routines: UpdatePlayers34ActiveFlag (if player 2 or
          rem 3 eliminated), TriggerEliminationEffects (tail call),
          rem DeactivatePlayerMissiles (via TriggerEliminationEffects),
          rem PlaySoundEffect (bank15, via TriggerEliminationEffects)
          rem
          rem Constraints: WARNING - temp2 and temp6 are mutated during
          rem execution. Do not use these temp variables after calling
          rem this subroutine.
          let temp6 = BitMask[currentPlayer]
          rem Skip if already eliminated
          let temp2 = temp6 & playersEliminated_R
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp2 then return 
          rem Already eliminated
          
          let temp2 = playerHealth[currentPlayer]
          rem Check if health has reached 0
          
          if temp2 then return 
          rem Still alive
          
          rem Player health reached 0 - eliminate them
          let CPE_eliminatedFlags = playersEliminated_R | temp6
          rem Fix RMW: Read from _R, modify, write to _W
          let playersEliminated_W = CPE_eliminatedFlags
          
          rem Update Players34Active flag if Player 3 or 4 was
          rem   eliminated
          rem Only clear flag if both players 3 and 4 are eliminated or
          rem   not selected
          rem Use skip-over pattern to avoid complex || operator
          if currentPlayer = 2 then gosub UpdatePlayers34ActiveFlag : goto UpdatePlayers34Done
          if currentPlayer = 3 then gosub UpdatePlayers34ActiveFlag
UpdatePlayers34Done
          
          let temp2 = eliminationCounter_R + 1
          rem Record elimination order
          let eliminationCounter_W = temp2
          let eliminationOrder_W[currentPlayer] = temp2
          
          rem Trigger elimination effects
          goto TriggerEliminationEffects
          rem tail call
          

TriggerEliminationEffects
          rem
          rem Trigger elimination audio/visual effects for currentPlayer.
          rem Input: currentPlayer (0-3), SoundPlayerEliminated
          rem Output: Plays sound, configures effect timer, hides sprite, deactivates missiles
          rem Mutates: temp2, temp5, eliminationTimer[], playerState[], playerX/Y[]
          rem sound ID), player0x, player1x, player2x, player3x (TIA
          rem registers) = sprite positions moved off-screen,
          rem eliminationEffectTimer[] (global array) = effect timers,
          rem missileActive (global) = missile state (via
          rem DeactivatePlayerMissiles)
          rem
          rem Called Routines: PlaySoundEffect (bank15) - plays
          rem elimination sound, DeactivatePlayerMissiles (tail call) -
          rem removes player missiles
          rem Constraints: None
          let temp5 = SoundPlayerEliminated
          rem Play elimination sound effect
          let PSE_soundID = temp5
          gosub PlaySoundEffect bank15
          rem PlaySoundEffect expects temp1 (PSE_soundID alias)
          
          rem Set elimination visual effect timer
          let temp2 = 30
          rem This could trigger screen flash, particle effects, etc.
          let eliminationEffectTimer_W[currentPlayer] = temp2
          rem 30 frames of elimination effect
          
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
          goto DeactivatePlayerMissiles
          rem tail call
          

          return

DeactivatePlayerMissiles
          rem
          rem Hide Eliminated Player Sprite
          rem Move eliminated player sprite off-screen.
          rem
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem Player 4 uses player3 sprite (multisprite)
          rem   TriggerEliminationEffects
          rem NOTE: This function is now inlined in
          rem
          rem Deactivate Player Missiles
          rem Input: currentPlayer (0-3), missileActive flags
          rem Output: Clears this player’s missile bit
          rem Mutates: missileActive
          rem Clear missile active bit for this player
          let missileActive = missileActive & PlayerANDMask[currentPlayer]
          return

CountRemainingPlayers
          rem
          rem Count Remaining Players
          rem Input: playersEliminated_R (SCRAM flags), PlayerEliminatedPlayer0-3 masks
          rem Output: playersRemaining (global) and temp1 updated with alive player count
          rem Mutates: temp1, playersRemaining
          let temp1 = 0 
          rem Counter
          
          rem Check each player
          
          if !(PlayerEliminatedPlayer0 & playersEliminated_R) then let temp1 = 1 + temp1
          if !(PlayerEliminatedPlayer1 & playersEliminated_R) then let temp1 = 1 + temp1
          if !(PlayerEliminatedPlayer2 & playersEliminated_R) then let temp1 = 1 + temp1
          if !(PlayerEliminatedPlayer3 & playersEliminated_R) then let temp1 = 1 + temp1
          
          let playersRemaining_W = temp1
          return

IsPlayerEliminated
          rem
          rem Is Player Eliminated
          rem Input: currentPlayer (0-3), playersEliminated_R, PlayerEliminatedPlayer0-3 masks
          rem Output: temp2 = 1 if eliminated, 0 if alive
          rem Mutates: temp2, temp6
          let temp6 = BitMask[currentPlayer]
          let temp2 = temp6 & playersEliminated_R
          if temp2 then let temp2 = 1 : goto IsEliminatedDone
          let temp2 = 0
IsEliminatedDone
          return

IsPlayerAlive
          rem
          rem Is Player Alive
          rem Check if specified player is alive (not eliminated AND
          rem   health > 0).
          rem
          rem Input: currentPlayer (0-3), playerHealth[], playersEliminated_R
          rem Output: temp2 = 1 if alive, 0 if eliminated/dead
          rem Mutates: temp2, temp3
          rem Calls: IsPlayerEliminated
          gosub IsPlayerEliminated
          rem Check elimination flag first
          if temp2 then return 
          rem Already eliminated
          
          let temp3 = playerHealth[currentPlayer]
          rem Check health
          
          let temp2 = 0 
          rem Default: not alive
          if temp3 > 0 then let temp2 = 1
          rem Alive if health > 0
          return

FindWinner
          rem
          rem Find Winner
          rem Identify the last standing player.
          rem Input: currentPlayer (loop), playersEliminated_R, eliminationOrder[]
          rem Output: winnerPlayerIndex (0-3, 255 if all eliminated)
          rem Mutates: temp2, currentPlayer, winnerPlayerIndex
          rem Calls: IsPlayerEliminated, FindLastEliminated (if needed)
          let winnerPlayerIndex_W = 255
          rem Find the player who is not eliminated
          rem Invalid initially
          
          for currentPlayer = 0 to 3
          rem Check each player using FOR loop
              gosub IsPlayerEliminated
              if !temp2 then let winnerPlayerIndex_W = currentPlayer
          next
          
          rem If no winner found (all eliminated), pick last eliminated
          rem tail call
          if winnerPlayerIndex_R = 255 then goto FindLastEliminated

FindLastEliminated
          rem
          rem Find player eliminated most recently (highest elimination order).
          rem Input: currentPlayer loop variable, eliminationOrder[]
          rem Output: winnerPlayerIndex updated to last eliminated player
          rem Mutates: temp4, currentPlayer, winnerPlayerIndex
          let temp4 = 0    
          let winnerPlayerIndex_W = 0
          rem Highest elimination order found
          rem Default winner
          
          for currentPlayer = 0 to 3
          rem Check each player elimination order using FOR loop
              let temp4 = eliminationOrder_R[currentPlayer]
              if temp4 > temp4 then let winnerPlayerIndex_W = currentPlayer
          next
          
UpdatePlayers34ActiveFlag
          rem Update Players34Active flag when players 3/4 are present.
          rem Input: playerCharacter[] (global array), playersEliminated_R,
          rem        PlayerEliminatedPlayer2/3 masks, controllerStatus
          rem Output: controllerStatus updated with Players34Active flag
          let controllerStatus = controllerStatus & ClearPlayers34Active
          rem Clear flag first
          
          rem Check if Player 3 is active (selected and not eliminated)
          
          if playerCharacter[2] = NoCharacter then CheckPlayer4ActiveFlag
          if PlayerEliminatedPlayer2 & playersEliminated_R then CheckPlayer4ActiveFlag
          let controllerStatus = controllerStatus | SetPlayers34Active
          rem Player 3 is active
          
CheckPlayer4ActiveFlag
          rem Check if Player 4 is active (selected and not eliminated)
          if playerCharacter[3] = NoCharacter then UpdatePlayers34ActiveDone
          if PlayerEliminatedPlayer3 & playersEliminated_R then UpdatePlayers34ActiveDone
          let controllerStatus = controllerStatus | SetPlayers34Active
          rem Player 4 is active
          
UpdatePlayers34ActiveDone
          return

          rem AND masks to clear player missile bits (inverted BitMask values)
          data PlayerANDMask
          $FE, $FD, $FB, $F7
          end
