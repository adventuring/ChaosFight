;;; ChaosFight - Source/Routines/TriggerEliminationEffects.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

TriggerEliminationEffects
;;; Returns: Far (return otherbank)
TriggerEliminationEffects

          ;; Returns: Far (return otherbank)
          ;; Trigger elimination audio/visual effects for currentPlayer.
          ;; Input: currentPlayer (0-3), SoundPlayerEliminated
          ;; Output: Plays sound, configures effect timer, hides sprite, deactivates missiles
          ;; Mutates: temp2, temp5, eliminationTimer[], playerState[], playerX/Y[]
          ;; sound ID), player0x, player1x, player2x, player3x (TIA
          ;; registers) = sprite positions moved off-screen,
          ;; eliminationEffectTimer[] (global array) = effect timers,
          ;; missileActive (global) = missile state (via
          ;; DeactivatePlayerMissiles)
          ;; Called Routines: PlaySoundEffect (bank15) - plays
          ;; elimination sound, DeactivatePlayerMissiles (tail call) -
          ;; removes player missiles
          ;; Constraints: None
          ;; Play elimination sound effect
          lda SoundPlayerEliminated
          sta temp5
          lda temp5
          sta temp1
          ;; PlaySoundEffect expects temp1 = sound ID
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(TEE_return_point_1-1)
          pha
          lda # <(TEE_return_point_1-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
TEE_return_point_1:

          ;; Set elimination visual effect timer
          ;; This could trigger particle effects, etc.
          lda # 30
          sta temp2
          ;; 30 frames of elimination effect
          lda currentPlayer
          asl
          tax
          lda temp2
          sta eliminationEffectTimer_W,x
          ;; Hide player sprite immediately
          ;; Inline HideEliminatedPlayerSprite
          ;; Off-screen
          lda currentPlayer
          cmp # 0
          bne CheckPlayer1Hide
          lda # 200
          sta player0x
CheckPlayer1Hide:

          lda currentPlayer
          cmp # 1
          bne CheckPlayer2Hide
          lda # 200
          sta player1x
CheckPlayer2Hide:

          ;; Player 3 uses player2 sprite (multisprite)
          lda currentPlayer
          cmp # 2
          bne CheckPlayer3Hide
          lda # 200
          sta player2x
CheckPlayer3Hide:

          ;; Player 4 uses player3 sprite (multisprite)
          lda currentPlayer
          cmp # 3
          bne DeactivateMissiles
          lda # 200
          sta player3x
DeactivateMissiles:

          ;; Stop any active missiles for this player - inlined
          ;; Clear missile active bit for this player (DeactivatePlayerMissiles)
          lda currentPlayer
          cmp # 0
          bne ClearMissileBit1
          lda missileActive
          and #$FE
          sta missileActive
          jmp TriggerEliminationEffectsDone
ClearMissileBit1:

          lda currentPlayer
          cmp # 1
          bne ClearMissileBit2
          lda missileActive
          and #$FD
          sta missileActive
          jmp TriggerEliminationEffectsDone
ClearMissileBit2:

          lda currentPlayer
          cmp # 2
          bne ClearMissileBit3
          lda missileActive
          and #$FB
          sta missileActive
          jmp TriggerEliminationEffectsDone
ClearMissileBit3:

          lda currentPlayer
          cmp # 3
          bne TriggerEliminationEffectsDone
          lda missileActive
          and #$F7
          sta missileActive
TriggerEliminationEffectsDone:

          jsr BS_return


