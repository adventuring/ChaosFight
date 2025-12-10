;;; ChaosFight - Source/Routines/StopSoundEffects.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


StopSoundEffects .proc
          ;;
          ;; Stopsoundeffects - Stop All Sound Effects
          ;; Stop all sound effects (zeroes TIA volumes, clears
          ;; pointers, resets frame counters)
          ;;
          ;; Input: None
          ;;
          ;; Output: All sound effects stopped, voices freed
          ;;
          ;; Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set
          ;; to 0), soundEffectPointer, soundEffectPointer1 (global 16-bit)
          ;; = sound pointers (set to 0), soundEffectFrame_W,
          ;; soundEffectFrame1_W (global SCRAM) = frame counters (set
          ;; to 0)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;; Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0

          ;; Clear sound pointers (high byte = 0 means inactive)
          lda # 0
          sta soundEffectPointer
          lda # 0
          sta soundEffectPointer1

          ;; Reset frame counters
          lda # 0
          sta soundEffectFrame_W
          lda # 0
          sta soundEffectFrame1_W
          rts

.pend

