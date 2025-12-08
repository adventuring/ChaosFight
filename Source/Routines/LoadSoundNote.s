;;; ChaosFight - Source/Routines/LoadSoundNote.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


LoadSoundNote .proc

          ;; Load next sound-effect note (assembly pointer access, Voice 0).
          ;; Returns: Far (return otherbank)
          ;; Input: soundEffectPointer (global 16-bit) = current note pointer
          ;; Output: Updates AUDC0/AUDF0/AUDV0, advances pointer, sets SoundEffectFrame
          ;;
          ;; Mutates: temp2-temp6 (used for calculations), AUDC0,
          ;; AUDF0, AUDV0 (TIA registers) = sound registers (updated),
          ;; soundEffectFrame_W (global SCRAM) = frame counter (set to
          ;; Duration + Delay), soundEffectPointer (global 16-bit) =
          ;; sound pointer (advanced by 4 bytes)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Loads 4-byte note format: AUDCV (packed
          ;; AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          ;; bits) and AUDV (lower 4 bits) from AUDCV. End of sound
          ;; marked by Duration = 0 (sets soundEffectPointer = 0 and
          ;; AUDV0 = 0). Uses Voice 0 for sound effects
          ;; TODO: ; Load 4 bytes from stream[pointer]
          ;; TODO: ldy #0
            lda (soundEffectPointer),y  ; Load AUDCV
            sta temp2
            iny
            ;; lda (soundEffectPointer),y  ; Load AUDF (duplicate)
            ;; sta temp3 (duplicate)
            ;; iny (duplicate)
            ;; lda (soundEffectPointer),y  ; Load Duration (duplicate)
            ;; sta temp4 (duplicate)
            ;; iny (duplicate)
            ;; lda (soundEffectPointer),y  ; Load Delay (duplicate)
            ;; sta temp5 (duplicate)

          ;; Check for end of sound (Duration = 0)
          jsr BS_return

          ;; Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          ;; AUDCV
                    ;; let temp6 = temp2 & %11110000
                    ;; let temp6 = temp6 / 16
          ;; lda temp6 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)
                    ;; let soundEffectID_W = temp2 & %00001111
          ;; lda temp2 (duplicate)
          and # 15
          ;; sta soundEffectID_W (duplicate)

          ;; Write to TIA registers (use Voice 0 for sound effects)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = soundEffectID_R

          ;; Set frame counter = Duration + Delay
                    ;; let soundEffectFrame_W = temp4 + temp5
          ;; lda temp4 (duplicate)
          clc
          adc temp5
          ;; sta soundEffectFrame_W (duplicate)

          ;; Advance pointer by 4 bytes (16-bit addition)
          ;; lda soundEffectPointer (duplicate)
          ;; clc (duplicate)
          ;; adc # 4 (duplicate)
          ;; sta soundEffectPointer (duplicate)

          ;; jsr BS_return (duplicate)


.pend

