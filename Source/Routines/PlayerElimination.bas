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
          dim TEE_soundId = temp5
          dim TEE_effectTimer = temp2
          rem Play elimination sound effect
          let TEE_soundId = SoundElimination
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
