;;; ChaosFight - Source/Routines/CheckAllPlayerEliminations.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CheckAllPlayerEliminations:
          ;; Player Elimination System
          ;; Returns: Far (return otherbank)
          ;; Handles player elimination when health reaches 0, game end
          ;; conditions,
          ;; and removal of eliminated players from active gameplay
          ;; systems.
          ;; ELIMINATION PROCESS:
          ;; 1. Detect when player health reaches 0
          ;; 2. Trigger elimination effects
          ;; 3. Remove player from active input/physics/collision
          ;; systems
          ;; 4. Hide player sprite and health bar
          ;; 5. Check for game end conditions (1 player remaining)
          ;; VARIABLES:
          ;;
          ;; playersRemaining - Count of active players
          ;; gameEndTimer - Countdown to game end screen
          ;; Check All Player Eliminations
          ;; Called each frame to check if any players should be
          ;; eliminated and trigger elimination effects.
          ;; Check all players for elimination and handle game end
          ;; condition
          ;;
          ;; Input: playerHealth[] (global array) = player health
          ;; values
          ;;
          ;; Output: Players eliminated if health reaches 0, game end
          ;; triggered if 1 or fewer players remain
          ;;
          ;; Mutates: currentPlayer (global loop variable),
          ;; eliminationCounter (global) = elimination order counter,
          ;; eliminationOrder[] (global array) = elimination order,
          ;; playersRemaining (global) = count of remaining players,
          ;; gameEndTimer (global) = game end countdown, systemFlags
          ;; (global) = system state flags, player sprite positions
          ;; (via TriggerEliminationEffects), missileActive (global) =
          ;; missile state (via DeactivatePlayerMissiles)
          ;;
          ;; Called Routines: CheckPlayerElimination (for each player),
          ;; CountRemainingPlayers, FindWinner (if game end),
          ;; TriggerEliminationEffects (via CheckPlayerElimination),
          ;; DeactivatePlayerMissiles (via TriggerEliminationEffects),
          ;; UpdatePlayers34ActiveFlag (via CheckPlayerElimination),
          ;; PlaySoundEffect (bank15, via TriggerEliminationEffects)
          ;;
          ;; Constraints: None
          ;; Issue #1254: Loop through currentPlayer = 0 to 3
          lda # 0
          sta currentPlayer
CAPE_Loop:
          ;; Cross-bank call to CheckPlayerElimination in bank 14
          lda # >(CAPE_CheckPlayerEliminationReturn-1)
          pha
          lda # <(CAPE_CheckPlayerEliminationReturn-1)
          pha
          lda # >(CheckPlayerElimination-1)
          pha
          lda # <(CheckPlayerElimination-1)
          pha
          ldx # 13
          jmp BS_jsr

CAPE_CheckPlayerEliminationReturn:
          ;; Issue #1254: Loop increment and check
          inc currentPlayer
          lda currentPlayer
          cmp # 4
          bcs CAPE_LoopDone
          jmp CAPE_Loop
CAPE_LoopDone:

          ;; Count remaining players and check game end (inline
          ;; CheckGameEndCondition)
          ;; Game ends when 1 or fewer players remain
          ;; Cross-bank call to CountRemainingPlayers in bank 13
          lda # >(AfterCountRemainingPlayers-1)
          pha
          lda # <(AfterCountRemainingPlayers-1)
          pha
          lda # >(CountRemainingPlayers-1)
          pha
          lda # <(CountRemainingPlayers-1)
          pha
          ldx # 13
          jmp BS_jsr

AfterCountRemainingPlayers:
          ;; Check if game should end (1 or fewer players remain)
          ;; CountRemainingPlayers sets playersRemaining_R
          lda playersRemaining_R
          cmp # 2
          bcs CheckGameEndContinue
          ;; 1 or fewer players remain - game ends, find winner
          jmp CheckGameEndFindWinner

CheckGameEndContinue:
          ;; More than 1 player remains - no game end yet
          jmp BS_return

CheckGameEndFindWinner:
          ;; Cross-bank call to FindWinner in bank 13
          lda # >(AfterFindWinner-1)
          pha
          lda # <(AfterFindWinner-1)
          pha
          lda # >(FindWinner-1)
          pha
          lda # <(FindWinner-1)
          pha
          ldx # 13
          jmp BS_jsr

AfterFindWinner:

          lda # 180
          sta gameEndTimer_W
          lda systemFlags
          ora # SystemFlagGameStateEnding
          sta systemFlags
          jmp BS_return

.pend

