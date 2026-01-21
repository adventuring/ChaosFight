;;; ChaosFight - Source/Routines/CheckPlayerElimination.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CheckPlayerElimination:
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Single Player Elimination
          ;;
          ;; Check if specified player should be eliminated.
          ;;
          ;; INPUT: currentPlayer = player index (0-3) (global
          ;; variable)
          ;;
          ;; MUTATES:
          ;; temp2 = temp2 ÷ temp2 (reused, internal)
          ;; temp6 = temp6 (internal)
          ;; WARNING: temp2 and temp6 are mutated during execution. Do
          ;; not
          ;; use these temp variables after calling this subroutine.
          ;;
          ;; EFFECTS:
          ;; Triggers elimination effects
          ;; Check if specified player should be eliminated (health =
          ;; 0) and trigger elimination effects
          ;;
          ;; Input: currentPlayer (global) = player index (0-3),
          ;; playerHealth[] (global array) = player health values
          ;;
          ;; Output: Player eliminated if health = 0, elimination
          ;; effects triggered
          ;;
          ;; Mutates: temp2 (used for health check), eliminationCounter (global) =
          ;; elimination order counter, eliminationOrder[] (global
          ;; array) = elimination order, controllerStatus (global) =
          ;; controller state (via UpdatePlayers34ActiveFlag), player
          ;; sprite positions (via TriggerEliminationEffects),
          ;; missileActive (global) = missile state (via
          ;; DeactivatePlayerMissiles), eliminationEffectTimer[]
          ;; (global array) = effect timers (via
          ;; TriggerEliminationEffects)
          ;;
          ;; Called Routines: UpdatePlayers34ActiveFlag (bank14, if player 2 or
          ;; 3 eliminated), TriggerEliminationEffects (bank13, tail call),
          ;; DeactivatePlayerMissiles (via TriggerEliminationEffects),
          ;; PlaySoundEffect (bank15, via TriggerEliminationEffects)
          ;;
          ;; Constraints: WARNING - temp2 is mutated during
          ;; execution. Do not use these temp variables after calling
          ;; this subroutine.
          ;; Check if health has reached 0
          ;; Set temp2 = playerHealth[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          sta temp2
          ;; Check if health has reached 0
          beq PlayerEliminated
          ;; Still alive
          jmp BS_return

PlayerEliminated:
          ;; Player health reached 0 - trigger elimination effects

          ;; Update Players34Active flag if Player 3 or 4 was
          ;; eliminated
          ;; Only clear flag if both players 3 and 4 are eliminated or
          ;; not selected
          ;; Use skip-over pattern to avoid complex || operator
          ;; Cross-bank call to UpdatePlayers34ActiveFlag in bank 13
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterUpdatePlayers34ActiveFlag-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdatePlayers34ActiveFlag hi (encoded)]
          lda # <(AfterUpdatePlayers34ActiveFlag-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdatePlayers34ActiveFlag hi (encoded)] [SP+0: AfterUpdatePlayers34ActiveFlag lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdatePlayers34ActiveFlag-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdatePlayers34ActiveFlag hi (encoded)] [SP+1: AfterUpdatePlayers34ActiveFlag lo] [SP+0: UpdatePlayers34ActiveFlag hi (raw)]
          lda # <(UpdatePlayers34ActiveFlag-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdatePlayers34ActiveFlag hi (encoded)] [SP+2: AfterUpdatePlayers34ActiveFlag lo] [SP+1: UpdatePlayers34ActiveFlag hi (raw)] [SP+0: UpdatePlayers34ActiveFlag lo]
          ldx # 13
          jmp BS_jsr

AfterUpdatePlayers34ActiveFlag:

UpdatePlayers34Done:
          ;; Returns: Far (return otherbank)

          ;; Record elimination order
          ;; Returns: Far (return otherbank)
          lda eliminationCounter_R
          clc
          adc # 1
          sta temp2
          lda temp2
          sta eliminationCounter_W
          lda currentPlayer
          asl
          tax
          lda temp2
          sta eliminationOrder_W,x

          ;; Trigger elimination effects
          ;; tail call
          jmp TriggerEliminationEffects


