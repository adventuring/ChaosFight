          rem ChaosFight - Source/Routines/CheckAllPlayerEliminations.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckAllPlayerEliminations
          asm
CheckAllPlayerEliminations
end
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
          gosub CheckPlayerElimination bank12
          next

          rem Count remaining players and check game end (inline
          rem   CheckGameEndCondition)
          gosub CountRemainingPlayers bank12
          rem Game ends when 1 or fewer players remain
          if playersRemaining_R > 0 then return
          rem If players still remain, no game end yet

          gosub FindWinner bank12
          let gameEndTimer_W = 180
          let systemFlags = systemFlags | SystemFlagGameStateEnding
          return

