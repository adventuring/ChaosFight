;;; ChaosFight - Source/Routines/LoadSoundNote1.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


LoadSoundNote1 .proc
          ;; Load next note from sound effect stream for Voice 1
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: soundEffectPointer1 (global 16-bit) points to current note in
          ;; Sound_Voice0 stream
          ;;
          ;; Output: Updates TIA registers, advances pointer, sets
          ;; SoundEffectFrame1
          ;;
          ;; Mutates: temp2-temp6 (used for calculations), AUDC1,
          ;; AUDF1, AUDV1 (TIA registers) = sound registers (updated),
          ;; soundEffectFrame1_W (global SCRAM) = frame counter (set to
          ;; Duration + Delay), soundEffectPointer1 (global 16-bit) =
          ;; sound pointer (advanced by 4 bytes)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Loads 4-byte note format: AUDCV (packed
          ;; AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          ;; bits) and AUDV (lower 4 bits) from AUDCV. End of sound
          ;; marked by Duration = 0 (sets soundEffectPointer1 = 0 and
          ;; AUDV1 = 0). Uses Voice 1 for sound effects
          ;; Load 4 bytes from stream[pointer]
          ldy # 0
          lda (soundEffectPointer1),y    ; Load AUDCV
          sta temp2
          iny
          lda (soundEffectPointer1),y    ; Load AUDF
          sta temp3
          iny
          lda (soundEffectPointer1),y    ; Load Duration
          sta temp4
          iny
          lda (soundEffectPointer1),y    ; Load Delay
          sta temp5

          ;; Check for end of sound (Duration = 0)
          jsr BS_return

          ;; Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          ;; AUDCV
          ;; let temp6 = temp2 & %11110000
          ;; let temp6 = temp6 / 16
          lda temp6
          lsr
          lsr
          lsr
          lsr
          sta temp6
          ;; let soundEffectID_W = temp2 & %00001111
          lda temp2
          and # 15
          sta soundEffectID_W

          ;; Write to TIA registers (use Voice 1 for sound effects)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = soundEffectID_R

          ;; Set frame counter = Duration + Delay
          ;; let soundEffectFrame1_W = temp4 + temp5
          lda temp4
          clc
          adc temp5
          sta soundEffectFrame1_W

          ;; Advance pointer by 4 bytes (16-bit addition)
          lda soundEffectPointer1
          clc
          adc # 4
          sta soundEffectPointer1

          jsr BS_return

.pend

