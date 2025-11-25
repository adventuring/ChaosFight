          rem ChaosFight - Source/Routines/LoadSoundNote1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

LoadSoundNote1
          asm
LoadSoundNote1
end
          rem Load next note from sound effect stream for Voice 1
          rem
          rem Input: soundEffectPointer1 (global 16-bit) points to current note in
          rem   Sound_Voice0 stream
          rem
          rem Output: Updates TIA registers, advances pointer, sets
          rem   SoundEffectFrame1
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC1,
          rem AUDF1, AUDV1 (TIA registers) = sound registers (updated),
          rem soundEffectFrame1_W (global SCRAM) = frame counter (set to
          rem Duration + Delay), soundEffectPointer1 (global 16-bit) =
          rem sound pointer (advanced by 4 bytes)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Loads 4-byte note format: AUDCV (packed
          rem AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          rem bits) and AUDV (lower 4 bits) from AUDCV. End of sound
          rem marked by Duration = 0 (sets soundEffectPointer1 = 0 and
          rem AUDV1 = 0). Uses Voice 1 for sound effects
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (soundEffectPointer1),y  ; Load AUDCV
            sta temp2
            iny
            lda (soundEffectPointer1),y  ; Load AUDF
            sta temp3
            iny
            lda (soundEffectPointer1),y  ; Load Duration
            sta temp4
            iny
            lda (soundEffectPointer1),y  ; Load Delay
            sta temp5
end

          rem Check for end of sound (Duration = 0)
          if temp4 = 0 then let soundEffectPointer1 = 0 : AUDV1 = 0 : return otherbank

          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          let temp6 = temp2 & %11110000
          rem   AUDCV
          let temp6 = temp6 / 16
          let soundEffectID_W = temp2 & %00001111

          rem Write to TIA registers (use Voice 1 for sound effects)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = soundEffectID_R

          let soundEffectFrame1_W = temp4 + temp5
          rem Set frame counter = Duration + Delay

          rem Advance pointer by 4 bytes (16-bit addition)
          let soundEffectPointer1 = soundEffectPointer1 + 4

          return otherbank

