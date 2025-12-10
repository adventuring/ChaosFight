;;; ChaosFight - Source/Routines/UpdateSoundEffect.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateSoundEffect .proc
          ;; UpdateSoundEffect - Update sound effect playback each
          ;; Returns: Far (return otherbank)
          ;; frame
          ;; Called every frame from MainLoop for gameMode 6
          ;; Updates both voices if active (high byte ≠ 0)
          ;; Update sound effect playback each frame (called every
          ;; frame from MainLoop for gameMode 6)
          ;;
          ;; Input: soundEffectPointer, soundEffectPointer1 (global 16-bit)
          ;; = sound effect pointers, soundEffectFrame_R,
          ;; soundEffectFrame1_R (global SCRAM) = frame counters
          ;;
          ;; Output: Both voices updated if active (high byte ≠ 0)
          ;;
          ;; Mutates: All sound effect state (via
          ;; UpdateSoundEffectVoice0 and UpdateSoundEffectVoice1)
          ;;
          ;; Called Routines: UpdateSoundEffectVoice0 - updates Voice 0
          ;; if active, UpdateSoundEffectVoice1 - updates Voice 1 if
          ;; active
          ;;
          ;; Constraints: Called every frame from MainLoop for gameMode
          ;; 6. Only updates voices if active (high byte ≠ 0)
          ;; Update Voice 0
          ;; Cross-bank call to UpdateSoundEffectVoice0 in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdateSoundEffectVoice0-1)
          pha
          lda # <(UpdateSoundEffectVoice0-1)
          pha
          ldx # 14
          jmp BS_jsr

return_point:

          ;; Update Voice 1
          ;; Cross-bank call to UpdateSoundEffectVoice1 in bank 15
          lda # >(return_point2-1)
          pha
          lda # <(return_point2-1)
          pha
          lda # >(UpdateSoundEffectVoice1-1)
          pha
          lda # <(UpdateSoundEffectVoice1-1)
          pha
          ldx # 14
          jmp BS_jsr

return_point2:

          jsr BS_return

.pend

