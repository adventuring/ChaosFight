          rem ChaosFight - Source/Routines/SoundBankHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Sounds Bank Helper Functions
          rem
          rem These functions access sound data tables and streams in
          rem   Bank 15
          
          #include "Source/Data/SoundPointers.bas"
          
          rem Lookup sound pointer from tables
          rem Input: temp1 = sound ID (0-9)
          rem Output: SoundPointerL, SoundPointerH = pointer to
          rem   Sound_Voice0 stream
LoadSoundPointer
          rem Lookup sound pointer from tables (Bank 15 sounds: 0-9)
          rem Input: temp1 = sound ID (0-9), SoundPointersL[], SoundPointersH[] (global data tables) = sound pointer tables
          rem Output: SoundPointerL, soundPointerH_W = pointer to Sound_Voice0 stream
          rem Mutates: temp1 (used for sound ID), SoundPointerL, soundPointerH_W (global SCRAM) = sound pointer (set from tables)
          rem Called Routines: None
          rem Constraints: Only 10 sounds (0-9) available. Returns soundPointerH_W = 0 if sound ID out of bounds
          dim LSP_soundID = temp1
          rem Bounds check: only 10 sounds (0-9)
          if LSP_soundID > 9 then let soundPointerH_W = 0 : return
          rem Use array access to lookup pointer
          let SoundPointerL = SoundPointersL[LSP_soundID]
          let soundPointerH_W = SoundPointersH[LSP_soundID]
          return
          
          rem Load next note from sound effect stream using assembly for
          rem   pointer access
          rem Input: SoundEffectPointerL/H points to current note in
          rem   Sound_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets
          rem   SoundEffectFrame
LoadSoundNote
          rem Load next note from sound effect stream using assembly for pointer access (Voice 0)
          rem Input: SoundEffectPointerL, soundEffectPointerH_R (global SCRAM) = pointer to current note in Sound_Voice0 stream
          rem Output: TIA registers updated (AUDC0, AUDF0, AUDV0), pointer advanced by 4 bytes, SoundEffectFrame set
          rem Mutates: temp2-temp7 (used for calculations), AUDC0, AUDF0, AUDV0 (TIA registers) = sound registers (updated), soundEffectFrame_W (global SCRAM) = frame counter (set to Duration + Delay), SoundEffectPointerL, soundEffectPointerH_W (global SCRAM) = sound pointer (advanced by 4 bytes)
          rem Called Routines: None
          rem Constraints: Loads 4-byte note format: AUDCV (packed AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV. End of sound marked by Duration = 0 (sets soundEffectPointerH_W = 0 and AUDV0 = 0). Uses Voice 0 for sound effects
          dim LSN_audcv = temp2
          dim LSN_audf = temp3
          dim LSN_duration = temp4
          dim LSN_delay = temp5
          dim LSN_audc = temp6
          dim LSN_audv = temp7
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (SoundEffectPointerL),y  ; Load AUDCV
            sta LSN_audcv
            iny
            lda (SoundEffectPointerL),y  ; Load AUDF
            sta LSN_audf
            iny
            lda (SoundEffectPointerL),y  ; Load Duration
            sta LSN_duration
            iny
            lda (SoundEffectPointerL),y  ; Load Delay
            sta LSN_delay
end
          
          rem Check for end of sound (Duration = 0)
          if LSN_duration = 0 then let soundEffectPointerH_W = 0 : AUDV0 = 0 : return
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          rem   AUDCV
          let LSN_audc = LSN_audcv & %11110000
          let LSN_audc = LSN_audc / 16
          let LSN_audv = LSN_audcv & %00001111
          
          rem Write to TIA registers (use Voice 0 for sound effects)
          AUDC0 = LSN_audc
          AUDF0 = LSN_audf
          AUDV0 = LSN_audv
          
          rem Set frame counter = Duration + Delay
          let soundEffectFrame_W = LSN_duration + LSN_delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (LSN_audcv no longer needed) for pointer
          rem   calculation
          rem Fix RMW: Read from _R, modify, write to _W
          let temp2 = SoundEffectPointerL
          let SoundEffectPointerL = temp2 + 4
          if SoundEffectPointerL < temp2 then let soundEffectPointerH_W = soundEffectPointerH_R + 1
          
          return
          
          rem Load next note from sound effect stream for Voice 1
          rem Input: soundEffectPointer1L/H points to current note in
          rem   Sound_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets
          rem   SoundEffectFrame1
LoadSoundNote1
          rem Load next note from sound effect stream using assembly for pointer access (Voice 1)
          rem Input: soundEffectPointer1L, soundEffectPointer1H (global SCRAM) = pointer to current note in Sound_Voice0 stream
          rem Output: TIA registers updated (AUDC1, AUDF1, AUDV1), pointer advanced by 4 bytes, SoundEffectFrame1 set
          rem Mutates: temp2-temp7 (used for calculations), AUDC1, AUDF1, AUDV1 (TIA registers) = sound registers (updated), soundEffectFrame1_W (global SCRAM) = frame counter (set to Duration + Delay), soundEffectPointer1L, soundEffectPointer1H (global SCRAM) = sound pointer (advanced by 4 bytes)
          rem Called Routines: None
          rem Constraints: Loads 4-byte note format: AUDCV (packed AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV. End of sound marked by Duration = 0 (sets soundEffectPointer1H = 0 and AUDV1 = 0). Uses Voice 1 for sound effects
          dim LSN1_audcv = temp2
          dim LSN1_audf = temp3
          dim LSN1_duration = temp4
          dim LSN1_delay = temp5
          dim LSN1_audc = temp6
          dim LSN1_audv = temp7
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (soundEffectPointer1L),y  ; Load AUDCV
            sta LSN1_audcv
            iny
            lda (soundEffectPointer1L),y  ; Load AUDF
            sta LSN1_audf
            iny
            lda (soundEffectPointer1L),y  ; Load Duration
            sta LSN1_duration
            iny
            lda (soundEffectPointer1L),y  ; Load Delay
            sta LSN1_delay
end
          
          rem Check for end of sound (Duration = 0)
          if LSN1_duration = 0 then let soundEffectPointer1H = 0 : AUDV1 = 0 : return
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          rem   AUDCV
          let LSN1_audc = LSN1_audcv & %11110000
          let LSN1_audc = LSN1_audc / 16
          let LSN1_audv = LSN1_audcv & %00001111
          
          rem Write to TIA registers (use Voice 1 for sound effects)
          AUDC1 = LSN1_audc
          AUDF1 = LSN1_audf
          AUDV1 = LSN1_audv
          
          rem Set frame counter = Duration + Delay
          let soundEffectFrame1_W = LSN1_duration + LSN1_delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (LSN1_audcv no longer needed) for pointer
          rem   calculation
          let temp2 = soundEffectPointer1L
          let soundEffectPointer1L = temp2 + 4
          if soundEffectPointer1L < temp2 then let soundEffectPointer1H = soundEffectPointer1H + 1
          
          return
