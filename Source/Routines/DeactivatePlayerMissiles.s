;;; ChaosFight - Source/Routines/DeactivatePlayerMissiles.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


DeactivatePlayerMissiles:
.proc
          ;;
          ;; Deactivate Player Missiles
          ;; Input: currentPlayer (0-3), missileActive flags
          ;; Output: Clears this player’s missile bit
          ;; Mutates: missileActive
          ;; Clear missile active bit for this player
          ;; let missileActive = missileActive & PlayerANDMask[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda PlayerANDMask,x
          and missileActive
          sta missileActive
          rts

          ;; and masks to clear player missile bits (inverted BitMask values)

PlayerANDMask:
          .byte 7


.pend

