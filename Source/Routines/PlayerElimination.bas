          rem ChaosFight - Source/Routines/PlayerElimination.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER ELIMINATION SYSTEM
          rem =================================================================
          rem Handles player elimination when health reaches 0, game end conditions,
          rem and removal of eliminated players from active gameplay systems.
          rem
          rem ELIMINATION PROCESS:
          rem   1. Detect when player health reaches 0
          rem   2. Set elimination flag and play elimination effects
          rem   3. Remove player from active input/physics/collision systems
          rem   4. Hide player sprite and health bar
          rem   5. Check for game end conditions (1 player remaining)
          rem
          rem VARIABLES:
          rem   PlayersEliminated - Bit flags for eliminated players
          rem   PlayersRemaining - Count of active players
          rem   GameEndTimer - Countdown to game end screen
          rem =================================================================

          rem =================================================================
          rem CHECK ALL PLAYER ELIMINATIONS
          rem =================================================================
          rem Called each frame to check if any players should be eliminated.
          rem Sets elimination flags and triggers elimination effects.
CheckAllPlayerEliminations
          rem Check each player for elimination
          temp1 = 0 : gosub CheckPlayerElimination
          temp1 = 1 : gosub CheckPlayerElimination  
          temp1 = 2 : gosub CheckPlayerElimination
          temp1 = 3 : gosub CheckPlayerElimination
          
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
          rem Skip if already eliminated
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4  
          if temp1 = 3 then temp6 = 8
          temp2 = PlayersEliminated & temp6
          if temp2 then return  : rem Already eliminated
          
          rem Check if health has reached 0
          if temp1 = 0 then temp2 = PlayerHealth[0]
          if temp1 = 1 then temp2 = PlayerHealth[1] 
          if temp1 = 2 then temp2 = PlayerHealth[2]
          if temp1 = 3 then temp2 = PlayerHealth[3]
          
          if temp2 > 0 then return  : rem Still alive
          
          rem Player health reached 0 - eliminate them
          PlayersEliminated = PlayersEliminated | temp6
          
          rem Trigger elimination effects
          gosub TriggerEliminationEffects
          
          return

          rem =================================================================
          rem TRIGGER ELIMINATION EFFECTS
          rem =================================================================
          rem Visual and audio effects when player is eliminated.
          rem INPUT: temp1 = eliminated player index (0-3)
TriggerEliminationEffects
          rem Play elimination sound effect
          temp5 = SoundElimination
          gosub PlaySoundEffect
          
          rem Set elimination visual effect timer
          rem This could trigger screen flash, particle effects, etc.
          temp2 = 30  : rem 30 frames of elimination effect
          if temp1 = 0 then EliminationEffectTimer[0] = temp2
          if temp1 = 1 then EliminationEffectTimer[1] = temp2
          if temp1 = 2 then EliminationEffectTimer[2] = temp2
          if temp1 = 3 then EliminationEffectTimer[3] = temp2
          
          rem Hide player sprite immediately
          gosub HideEliminatedPlayerSprite
          
          rem Stop any active missiles for this player
          gosub DeactivatePlayerMissiles
          
          return

          rem =================================================================
          rem HIDE ELIMINATED PLAYER SPRITE
          rem =================================================================
          rem Move eliminated player sprite off-screen.
          rem INPUT: temp1 = player index (0-3)
HideEliminatedPlayerSprite
          if temp1 = 0 then player0x = 200  : rem Off-screen
          if temp1 = 1 then player1x = 200
          if temp1 = 2 then missile1x = 200  : rem Player 3 uses missile1
          if temp1 = 3 then ballx = 200      : rem Player 4 uses ball
          
          return

          rem =================================================================
          rem DEACTIVATE PLAYER MISSILES
          rem =================================================================
          rem Remove any active missiles belonging to eliminated player.
          rem INPUT: temp1 = player index (0-3)
DeactivatePlayerMissiles
          rem Clear missile active bit for this player
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp6 = 255 - temp6  : rem Invert bits for AND mask
          MissileActive = MissileActive & temp6
          
          return

          rem =================================================================
          rem COUNT REMAINING PLAYERS
          rem =================================================================
          rem Count how many players are still alive.
          rem OUTPUT: temp1 = number of remaining players
CountRemainingPlayers
          temp1 = 0  : rem Counter
          
          rem Check each player
          if !(PlayersEliminated & 1) then temp1 = temp1 + 1  : rem Player 1
          if !(PlayersEliminated & 2) then temp1 = temp1 + 1  : rem Player 2
          if !(PlayersEliminated & 4) then temp1 = temp1 + 1  : rem Player 3  
          if !(PlayersEliminated & 8) then temp1 = temp1 + 1  : rem Player 4
          
          PlayersRemaining = temp1
          return

          rem =================================================================
          rem CHECK GAME END CONDITION
          rem =================================================================
          rem Check if game should end (1 or 0 players remaining).
CheckGameEndCondition
          rem Game ends when 1 or fewer players remain
          if PlayersRemaining <= 1 then
                    rem Start game end countdown
                    GameEndTimer = 180  : rem 3 seconds at 60 FPS
                    GameState = 2      : rem Game ending state
          endif
          
          return

          rem =================================================================  
          rem IS PLAYER ELIMINATED
          rem =================================================================
          rem Check if specified player is eliminated.
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if eliminated, 0 if alive
IsPlayerEliminated
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp2 = PlayersEliminated & temp6
          if temp2 then temp2 = 1 else temp2 = 0
          return

          rem =================================================================
          rem IS PLAYER ALIVE  
          rem =================================================================
          rem Check if specified player is alive (not eliminated AND health > 0).
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if alive, 0 if eliminated/dead
IsPlayerAlive
          rem Check elimination flag first
          gosub IsPlayerEliminated
          if temp2 then return  : rem Already eliminated
          
          rem Check health
          if temp1 = 0 then temp3 = PlayerHealth[0]
          if temp1 = 1 then temp3 = PlayerHealth[1]
          if temp1 = 2 then temp3 = PlayerHealth[2] 
          if temp1 = 3 then temp3 = PlayerHealth[3]
          
          if temp3 > 0 then temp2 = 1 else temp2 = 0
          return
