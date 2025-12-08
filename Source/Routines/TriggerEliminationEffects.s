;;; ChaosFight - Source/Routines/TriggerEliminationEffects.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

TriggerEliminationEffects
;;; Returns: Far (return otherbank)
;; TriggerEliminationEffects (duplicate)

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
          ;; lda temp5 (duplicate)
          ;; sta temp1 (duplicate)
          ;; PlaySoundEffect expects temp1 = sound ID
          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(TEE_return_point_1-1) (duplicate)
          pha
          ;; lda # <(TEE_return_point_1-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          jmp BS_jsr
TEE_return_point_1:

          ;; Set elimination visual effect timer
          ;; This could trigger screen flash, particle effects, etc.
          ;; lda # 30 (duplicate)
          ;; sta temp2 (duplicate)
          ;; 30 frames of elimination effect
          ;; lda currentPlayer (duplicate)
          asl
          tax
          ;; lda temp2 (duplicate)
          ;; sta eliminationEffectTimer_W,x (duplicate)
          ;; Hide player sprite immediately
          ;; Inline HideEliminatedPlayerSprite
          ;; Off-screen
          ;; lda currentPlayer (duplicate)
          cmp # 0
          bne skip_4443
          ;; lda # 200 (duplicate)
          ;; sta player0x (duplicate)
skip_4443:

          ;; lda currentPlayer (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_699 (duplicate)
          ;; lda # 200 (duplicate)
          ;; sta player1x (duplicate)
skip_699:

          ;; Player 3 uses player2 sprite (multisprite)
          ;; lda currentPlayer (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_4508 (duplicate)
          ;; lda # 200 (duplicate)
          ;; sta player2x (duplicate)
skip_4508:

          ;; Player 4 uses player3 sprite (multisprite)
          ;; lda currentPlayer (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_7810 (duplicate)
          ;; lda # 200 (duplicate)
          ;; sta player3x (duplicate)
skip_7810:

          ;; Stop any active missiles for this player - inlined
          ;; Clear missile active bit for this player (DeactivatePlayerMissiles)
          ;; lda currentPlayer (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_9458 (duplicate)
          ;; lda missileActive (duplicate)
          and #$FE
          ;; sta missileActive (duplicate)
skip_9458:

          ;; lda currentPlayer (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_498 (duplicate)
          ;; lda missileActive (duplicate)
          ;; and #$FD (duplicate)
          ;; sta missileActive (duplicate)
skip_498:

          ;; lda currentPlayer (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6929 (duplicate)
          ;; lda missileActive (duplicate)
          ;; and #$FB (duplicate)
          ;; sta missileActive (duplicate)
skip_6929:

          ;; lda currentPlayer (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_5725 (duplicate)
          ;; lda missileActive (duplicate)
          ;; and #$F7 (duplicate)
          ;; sta missileActive (duplicate)
skip_5725:

          jsr BS_return


