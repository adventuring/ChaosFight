          rem ChaosFight - Source/Routines/CheckPlayerElimination.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckPlayerElimination
          asm
CheckPlayerElimination
end
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
          if currentPlayer = 2 then gosub UpdatePlayers34ActiveFlag bank12 : goto UpdatePlayers34Done
          if currentPlayer = 3 then gosub UpdatePlayers34ActiveFlag bank12
UpdatePlayers34Done
          asm
UpdatePlayers34Done
end

          let temp2 = eliminationCounter_R + 1
          rem Record elimination order
          let eliminationCounter_W = temp2
          let eliminationOrder_W[currentPlayer] = temp2

          rem Trigger elimination effects
          goto TriggerEliminationEffects bank12
          rem tail call

