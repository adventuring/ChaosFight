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
          dim CAPE_playerIndex = temp1
          rem Check each player for elimination
          let CAPE_playerIndex = 0
          let temp1 = CAPE_playerIndex
          gosub CheckPlayerElimination
          let CAPE_playerIndex = 1
          let temp1 = CAPE_playerIndex
          gosub CheckPlayerElimination  
          let CAPE_playerIndex = 2
          let temp1 = CAPE_playerIndex
          gosub CheckPlayerElimination
          let CAPE_playerIndex = 3
          let temp1 = CAPE_playerIndex
          gosub CheckPlayerElimination
          
          rem Count remaining players and check game end
          gosub CountRemainingPlayers
          gosub CheckGameEndCondition
          
          return

          rem =================================================================
          rem CHECK SINGLE PLAYER ELIMINATION
          rem =================================================================
          rem Check if specified player should be eliminated.
          rem INPUT: temp1 = player index (0-3)
CheckPlayerElimination
          dim CPE_playerIndex = temp1
          dim CPE_bitMask = temp6
          dim CPE_isEliminated = temp2
          dim CPE_health = temp2
          rem Skip if already eliminated
          let CPE_bitMask = BitMask[CPE_playerIndex]
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          let CPE_isEliminated = playersEliminated & CPE_bitMask
          if CPE_isEliminated then return 
          rem Already eliminated
          
          rem Check if health has reached 0
          let CPE_health = playerHealth[CPE_playerIndex]
          
          if CPE_health > 0 then return 
          rem Still alive
          
          rem Player health reached 0 - eliminate them
          let playersEliminated = playersEliminated | CPE_bitMask
          
          rem Update Players34Active flag if Player 3 or 4 was eliminated
          rem Only clear flag if both players 3 and 4 are eliminated or not selected
          rem Use skip-over pattern to avoid complex || operator
          if CPE_playerIndex = 2 then gosub UpdatePlayers34ActiveFlag : goto UpdatePlayers34Done
          if CPE_playerIndex = 3 then gosub UpdatePlayers34ActiveFlag
UpdatePlayers34Done
          
          rem Record elimination order
          let eliminationCounter = eliminationCounter + 1
          eliminationOrder[CPE_playerIndex] = eliminationCounter
          
          rem Trigger elimination effects
          gosub TriggerEliminationEffects
          
          return

          rem =================================================================
          rem TRIGGER ELIMINATION EFFECTS
          rem =================================================================
          rem Visual and audio effects when player is eliminated.
          rem INPUT: temp1 = eliminated player index (0-3)
TriggerEliminationEffects
          dim TEE_playerIndex = temp1
          dim TEE_soundId = temp5
          dim TEE_effectTimer = temp2
          rem Play elimination sound effect
          let TEE_soundId = SoundElimination
          let temp5 = TEE_soundId
          gosub bank15 PlaySoundEffect
          
          rem Set elimination visual effect timer
          rem This could trigger screen flash, particle effects, etc.
          let TEE_effectTimer = 30 
          rem 30 frames of elimination effect
          let eliminationEffectTimer[TEE_playerIndex] = TEE_effectTimer
          
          rem Hide player sprite immediately
          let temp1 = TEE_playerIndex
          gosub HideEliminatedPlayerSprite
          
          rem Stop any active missiles for this player
          let temp1 = TEE_playerIndex
          gosub DeactivatePlayerMissiles
          
          return

          rem =================================================================
          rem HIDE ELIMINATED PLAYER SPRITE
          rem =================================================================
          rem Move eliminated player sprite off-screen.
          rem INPUT: temp1 = player index (0-3)
HideEliminatedPlayerSprite
          dim HEPS_playerIndex = temp1
          if HEPS_playerIndex = 0 then player0x = 200 
          rem Off-screen
          if HEPS_playerIndex = 1 then player1x = 200
          if HEPS_playerIndex = 2 then player2x = 200 
          rem Player 3 uses player2 sprite (multisprite)
          if HEPS_playerIndex = 3 then player3x = 200 
          rem Player 4 uses player3 sprite (multisprite)
          
          return

          rem =================================================================
          rem DEACTIVATE PLAYER MISSILES
          rem =================================================================
          rem Remove any active missiles belonging to eliminated player.
          rem INPUT: temp1 = player index (0-3)
DeactivatePlayerMissiles
          dim DPM_playerIndex = temp1
          dim DPM_bitMask = temp6
          dim DPM_invertedMask = temp6
          rem Clear missile active bit for this player
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if DPM_playerIndex = 0 then let DPM_bitMask = 1
          if DPM_playerIndex = 1 then let DPM_bitMask = 2
          if DPM_playerIndex = 2 then let DPM_bitMask = 4
          if DPM_playerIndex = 3 then let DPM_bitMask = 8
          let DPM_invertedMask = 255 - DPM_bitMask 
          rem Invert bits for AND mask
          let missileActive = missileActive & DPM_invertedMask
          
          return

          rem =================================================================
          rem COUNT REMAINING PLAYERS
          rem =================================================================
          rem Count how many players are still alive.
          rem OUTPUT: temp1 = number of remaining players
CountRemainingPlayers
          dim CRP_count = temp1
          let CRP_count = 0 
          rem Counter
          
          rem Check each player
          if !(playersEliminated & 1) then let CRP_count = CRP_count + 1 
          rem Player 1
          if !(playersEliminated & 2) then let CRP_count = CRP_count + 1 
          rem Player 2
          if !(playersEliminated & 4) then let CRP_count = CRP_count + 1 
          rem Player 3  
          if !(playersEliminated & 8) then let CRP_count = CRP_count + 1 
          rem Player 4
          
          let playersRemaining = CRP_count
          return

          rem =================================================================
          rem CHECK GAME END CONDITION
          rem =================================================================
          rem Check if game should end (1 or 0 players remaining).
CheckGameEndCondition
          rem Game ends when 1 or fewer players remain
          if playersRemaining <= 1 then gosub FindWinner : gameEndTimer = 180 : gameState = 2 : return

          rem =================================================================  
          rem IS PLAYER ELIMINATED
          rem =================================================================
          rem Check if specified player is eliminated.
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if eliminated, 0 if alive
IsPlayerEliminated
          dim IPE_playerIndex = temp1
          dim IPE_bitMask = temp6
          dim IPE_isEliminated = temp2
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if IPE_playerIndex = 0 then let IPE_bitMask = 1
          if IPE_playerIndex = 1 then let IPE_bitMask = 2
          if IPE_playerIndex = 2 then let IPE_bitMask = 4
          if IPE_playerIndex = 3 then let IPE_bitMask = 8
          let IPE_isEliminated = playersEliminated & IPE_bitMask
          if IPE_isEliminated then let IPE_isEliminated = 1 : goto IsEliminatedDone
          let IPE_isEliminated = 0
IsEliminatedDone
          let temp2 = IPE_isEliminated
          return

          rem =================================================================
          rem IS PLAYER ALIVE  
          rem =================================================================
          rem Check if specified player is alive (not eliminated AND health > 0).
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if alive, 0 if eliminated/dead
IsPlayerAlive
          dim IPA_playerIndex = temp1
          dim IPA_isEliminated = temp2
          dim IPA_health = temp3
          dim IPA_isAlive = temp2
          rem Check elimination flag first
          let temp1 = IPA_playerIndex
          gosub IsPlayerEliminated
          let IPA_isEliminated = temp2
          if IPA_isEliminated then return 
          rem Already eliminated
          
          rem Check health
          let IPA_health = playerHealth[IPA_playerIndex]
          
          let IPA_isAlive = 0 
          rem Default: not alive
          if IPA_health > 0 then let IPA_isAlive = 1 
          rem Alive if health > 0
          let temp2 = IPA_isAlive
          return

          rem =================================================================
          rem FIND WINNER
          rem =================================================================
          rem Identify the winning player (last one standing).
FindWinner
          dim FW_playerIndex = temp1
          dim FW_isEliminated = temp2
          rem Find the player who is not eliminated
          let winnerPlayerIndex = 255 
          rem Invalid initially
          
          let FW_playerIndex = 0
          let temp1 = FW_playerIndex
          gosub IsPlayerEliminated
          let FW_isEliminated = temp2
          if !FW_isEliminated then let winnerPlayerIndex = 0
          let FW_playerIndex = 1
          let temp1 = FW_playerIndex
          gosub IsPlayerEliminated  
          let FW_isEliminated = temp2
          if !FW_isEliminated then let winnerPlayerIndex = 1
          let FW_playerIndex = 2
          let temp1 = FW_playerIndex
          gosub IsPlayerEliminated
          let FW_isEliminated = temp2
          if !FW_isEliminated then let winnerPlayerIndex = 2
          let FW_playerIndex = 3
          let temp1 = FW_playerIndex
          gosub IsPlayerEliminated
          let FW_isEliminated = temp2
          if !FW_isEliminated then let winnerPlayerIndex = 3
          
          rem If no winner found (all eliminated), pick last eliminated
          rem tail call
          if winnerPlayerIndex = 255 then goto FindLastEliminated

          rem =================================================================
          rem FIND LAST ELIMINATED
          rem =================================================================
          rem Find player who was eliminated most recently (highest elimination order).
FindLastEliminated
          dim FLE_highestOrder = temp4
          dim FLE_currentOrder = temp4
          let FLE_highestOrder = 0    
          rem Highest elimination order found
          let winnerPlayerIndex = 0 
          rem Default winner
          
          rem Check each player elimination order
          let FLE_currentOrder = eliminationOrder[0]
          if FLE_currentOrder > FLE_highestOrder then let FLE_highestOrder = FLE_currentOrder : let winnerPlayerIndex = 0
          let FLE_currentOrder = eliminationOrder[1]
          if FLE_currentOrder > FLE_highestOrder then let FLE_highestOrder = FLE_currentOrder : let winnerPlayerIndex = 1
          let FLE_currentOrder = eliminationOrder[2]
          if FLE_currentOrder > FLE_highestOrder then let FLE_highestOrder = FLE_currentOrder : let winnerPlayerIndex = 2
          let FLE_currentOrder = eliminationOrder[3]
          if FLE_currentOrder > FLE_highestOrder then let FLE_highestOrder = FLE_currentOrder : let winnerPlayerIndex = 3
          
          rem =================================================================
          rem UPDATE PLAYERS 3/4 ACTIVE FLAG
          rem =================================================================
          rem Updates the Players34Active flag based on whether players 3 or 4
          rem are selected and not eliminated. Used for missile multiplexing.
UpdatePlayers34ActiveFlag
          rem Clear flag first
          let controllerStatus = controllerStatus & ClearPlayers34Active
          
          rem Check if Player 3 is active (selected and not eliminated)
          if selectedChar3 = 255 then CheckPlayer4ActiveFlag
          if playersEliminated & 4 then CheckPlayer4ActiveFlag
          rem Player 3 is active
          let controllerStatus = controllerStatus | SetPlayers34Active
          
CheckPlayer4ActiveFlag
          rem Check if Player 4 is active (selected and not eliminated)
          if selectedChar4 = 255 then UpdatePlayers34ActiveDone
          if playersEliminated & 8 then UpdatePlayers34ActiveDone
          rem Player 4 is active
          let controllerStatus = controllerStatus | SetPlayers34Active
          
UpdatePlayers34ActiveDone
          return
