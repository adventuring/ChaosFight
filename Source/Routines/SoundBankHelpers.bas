          rem ChaosFight - Source/Routines/SoundBankHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Sounds Bank Helper Functions
          rem These functions access sound data tables and streams in
          rem   Bank 15
          
LoadSoundPointer
          rem Lookup sound pointer from tables (Bank 15 sounds: 0-9)
          rem
          rem Input: temp1 = sound ID (0-9), SoundPointersL[],
          rem SoundPointersH[] (global data tables) = sound pointer
          rem tables
          rem
          rem Output: soundPointer = pointer to Sound_Voice0 stream
          rem
          rem Mutates: temp1 (used for sound ID), soundPointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only 10 sounds (0-9) available. Returns
          rem soundPointer = 0 if sound ID out of bounds
          rem Bounds check: only 10 sounds (0-9)
          if temp1 > 9 then goto LoadSoundPointerOutOfRange
          let soundPointer = SoundPointersH[temp1]
          let soundPointer = soundPointer * 256
          let soundPointer = soundPointer + SoundPointersL[temp1]
          goto LoadSoundPointerReturn
LoadSoundPointerOutOfRange
          let soundPointer = 0 : rem Out of range - mark sound pointer inactive
LoadSoundPointerReturn
          return
          
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
          let temp6 = temp2 & %11110000 : rem   AUDCV
          let temp6 = temp6 / 16
          let soundEffectID_W = temp2 & %00001111
          
          rem Write to TIA registers (use Voice 0 for sound effects)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = soundEffectID_R
          
          let soundEffectFrame_W = temp4 + temp5 : rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          let soundEffectPointer = soundEffectPointer + 4
          
          return
          
LoadSoundNote1
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
          if temp4 = 0 then let soundEffectPointer1 = 0 : AUDV1 = 0 : return
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          let temp6 = temp2 & %11110000 : rem   AUDCV
          let temp6 = temp6 / 16
          let soundEffectID_W = temp2 & %00001111
          
          rem Write to TIA registers (use Voice 1 for sound effects)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = soundEffectID_R
          
          let soundEffectFrame1_W = temp4 + temp5 : rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          let soundEffectPointer1 = soundEffectPointer1 + 4
          
          return
