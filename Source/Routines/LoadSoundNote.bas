          rem ChaosFight - Source/Routines/LoadSoundNote.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

LoadSoundNote
          rem Load next sound-effect note (assembly pointer access, Voice 0).
          rem Input: soundEffectPointer (global 16-bit) = current note pointer
          rem Output: Updates AUDC0/AUDF0/AUDV0, advances pointer, sets SoundEffectFrame
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC0,
          rem AUDF0, AUDV0 (TIA registers) = sound registers (updated),
          rem soundEffectFrame_W (global SCRAM) = frame counter (set to
          rem Duration + Delay), soundEffectPointer (global 16-bit) =
          rem sound pointer (advanced by 4 bytes)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Loads 4-byte note format: AUDCV (packed
          rem AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          rem bits) and AUDV (lower 4 bits) from AUDCV. End of sound
          rem marked by Duration = 0 (sets soundEffectPointer = 0 and
          rem AUDV0 = 0). Uses Voice 0 for sound effects
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (soundEffectPointer),y  ; Load AUDCV
            sta temp2
            iny
            lda (soundEffectPointer),y  ; Load AUDF
            sta temp3
            iny
            lda (soundEffectPointer),y  ; Load Duration
            sta temp4
            iny
            lda (soundEffectPointer),y  ; Load Delay
            sta temp5
end

          rem Check for end of sound (Duration = 0)
          if temp4 = 0 then let soundEffectPointer = 0 : AUDV0 = 0 : return

          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          let temp6 = temp2 & %11110000
          rem   AUDCV
          let temp6 = temp6 / 16
          let soundEffectID_W = temp2 & %00001111

          rem Write to TIA registers (use Voice 0 for sound effects)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = soundEffectID_R

          let soundEffectFrame_W = temp4 + temp5
          rem Set frame counter = Duration + Delay

          rem Advance pointer by 4 bytes (16-bit addition)
          let soundEffectPointer = soundEffectPointer + 4

          return

