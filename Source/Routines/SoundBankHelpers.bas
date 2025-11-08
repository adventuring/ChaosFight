          rem
          rem ChaosFight - Source/Routines/SoundBankHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Sounds Bank Helper Functions
          rem These functions access sound data tables and streams in
          rem   Bank 15
          
LoadSoundPointer
          rem Lookup sound pointer from tables
          rem
          rem Input: temp1 = sound ID (0-9)
          rem
          rem Output: SoundPointerL, SoundPointerH = pointer to
          rem   Sound_Voice0 stream
          rem Lookup sound pointer from tables (Bank 15 sounds: 0-9)
          rem
          rem Input: temp1 = sound ID (0-9), SoundPointersL[],
          rem SoundPointersH[] (global data tables) = sound pointer
          rem tables
          rem
          rem Output: SoundPointerL, soundPointerH_W = pointer to
          rem Sound_Voice0 stream
          rem
          rem Mutates: temp1 (used for sound ID), SoundPointerL,
          rem soundPointerH_W (global SCRAM) = sound pointer (set from
          rem tables)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only 10 sounds (0-9) available. Returns
          rem soundPointerH_W = 0 if sound ID out of bounds
          if temp1 > 9 then let soundPointerH_W = 0 : return : rem Bounds check: only 10 sounds (0-9)
          let SoundPointerL = SoundPointersL[temp1] : rem Use array access to lookup pointer
          let soundPointerH_W = SoundPointersH[temp1]
          return
          
LoadSoundNote
          rem Load next note from sound effect stream using assembly for
          rem   pointer access
          rem
          rem Input: SoundEffectPointerL/H points to current note in
          rem   Sound_Voice0 stream
          rem
          rem Output: Updates TIA registers, advances pointer, sets
          rem   SoundEffectFrame
          rem Load next note from sound effect stream using assembly for
          rem pointer access (Voice 0)
          rem
          rem Input: SoundEffectPointerL, soundEffectPointerH_R (global
          rem SCRAM) = pointer to current note in Sound_Voice0 stream
          rem
          rem Output: TIA registers updated (AUDC0, AUDF0, AUDV0),
          rem pointer advanced by 4 bytes, SoundEffectFrame set
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC0,
          rem AUDF0, AUDV0 (TIA registers) = sound registers (updated),
          rem soundEffectFrame_W (global SCRAM) = frame counter (set to
          rem Duration + Delay), SoundEffectPointerL,
          rem soundEffectPointerH_W (global SCRAM) = sound pointer
          rem (advanced by 4 bytes)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Loads 4-byte note format: AUDCV (packed
          rem AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          rem bits) and AUDV (lower 4 bits) from AUDCV. End of sound
          rem marked by Duration = 0 (sets soundEffectPointerH_W = 0 and
          rem AUDV0 = 0). Uses Voice 0 for sound effects
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (SoundEffectPointerL),y  ; Load AUDCV
            sta temp2
            iny
            lda (SoundEffectPointerL),y  ; Load AUDF
            sta temp3
            iny
            lda (SoundEffectPointerL),y  ; Load Duration
            sta temp4
            iny
            lda (SoundEffectPointerL),y  ; Load Delay
            sta temp5
end
          
          rem Check for end of sound (Duration = 0)
          if temp4 = 0 then let soundEffectPointerH_W = 0 : AUDV0 = 0 : return
          
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
          rem Reuse temp2 (temp2 no longer needed) for pointer
          rem   calculation
          let temp2 = SoundEffectPointerL : rem Fix RMW: Read from _R, modify, write to _W
          let SoundEffectPointerL = temp2 + 4
          if SoundEffectPointerL < temp2 then let soundEffectPointerH_W = soundEffectPointerH_R + 1
          
          return
          
LoadSoundNote1
          rem Load next note from sound effect stream for Voice 1
          rem
          rem Input: soundEffectPointer1L/H points to current note in
          rem   Sound_Voice0 stream
          rem
          rem Output: Updates TIA registers, advances pointer, sets
          rem   SoundEffectFrame1
          rem Load next note from sound effect stream using assembly for
          rem pointer access (Voice 1)
          rem
          rem Input: soundEffectPointer1L, soundEffectPointer1H (global
          rem SCRAM) = pointer to current note in Sound_Voice0 stream
          rem
          rem Output: TIA registers updated (AUDC1, AUDF1, AUDV1),
          rem pointer advanced by 4 bytes, SoundEffectFrame1 set
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC1,
          rem AUDF1, AUDV1 (TIA registers) = sound registers (updated),
          rem soundEffectFrame1_W (global SCRAM) = frame counter (set to
          rem Duration + Delay), soundEffectPointer1L,
          rem soundEffectPointer1H (global SCRAM) = sound pointer
          rem (advanced by 4 bytes)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Loads 4-byte note format: AUDCV (packed
          rem AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          rem bits) and AUDV (lower 4 bits) from AUDCV. End of sound
          rem marked by Duration = 0 (sets soundEffectPointer1H = 0 and
          rem AUDV1 = 0). Uses Voice 1 for sound effects
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (soundEffectPointer1L),y  ; Load AUDCV
            sta temp2
            iny
            lda (soundEffectPointer1L),y  ; Load AUDF
            sta temp3
            iny
            lda (soundEffectPointer1L),y  ; Load Duration
            sta temp4
            iny
            lda (soundEffectPointer1L),y  ; Load Delay
            sta temp5
end
          
          rem Check for end of sound (Duration = 0)
          if temp4 = 0 then let soundEffectPointer1H = 0 : AUDV1 = 0 : return
          
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
          rem Reuse temp2 (temp2 no longer needed) for pointer
          let temp2 = soundEffectPointer1L : rem   calculation
          let soundEffectPointer1L = temp2 + 4
          if soundEffectPointer1L < temp2 then let soundEffectPointer1H = soundEffectPointer1H + 1
          
          return
