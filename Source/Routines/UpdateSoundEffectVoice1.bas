          rem ChaosFight - Source/Routines/UpdateSoundEffectVoice1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateSoundEffectVoice1
          rem
          rem Updatesoundeffectvoice1 - Update Voice 1 Sound Effect
          rem Update Voice 1 sound effect playback (decrements frame
          rem counter, loads next note when counter reaches 0)
          rem
          rem Input: soundEffectFrame1_R (global SCRAM) = frame counter,
          rem soundEffectPointer1 (global 16-bit) = sound pointer
          rem
          rem Output: Frame counter decremented, next note loaded when
          rem counter reaches 0, voice freed when sound ends
          rem
          rem Mutates: temp5 = frame count
          rem calculation, soundEffectFrame1_W (global SCRAM) = frame
          rem counter (decremented), soundEffectPointer1 (global 16-bit) =
          rem sound pointer (advanced by 4 bytes), AUDC1, AUDF1, AUDV1 (TIA registers)
          rem = sound registers (updated via LoadSoundNote1)
          rem
          rem Called Routines: LoadSoundNote1 (bank15) - loads next
          rem 4-byte note from Sounds bank, extracts AUDC/AUDV, writes
          rem to TIA, advances pointer, handles end-of-sound
          rem
          rem Constraints: Uses Voice 1 (AUDC1, AUDF1, AUDV1).
          rem LoadSoundNote1 handles end-of-sound by setting
          rem soundEffectPointer1 = 0 and AUDV1 = 0
          rem Decrement frame counter
          let temp5 = soundEffectFrame1_R - 1
          rem Fix RMW: Read from _R, modify, write to _W
          let soundEffectFrame1_W = temp5
          if temp5 then return

          gosub LoadSoundNote1 bank15
          rem Frame counter reached 0 - load next note from Sounds bank
          rem LoadSoundNote1 will:
          rem - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          rem   AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Write to TIA: AUDC1, AUDF1, AUDV1 (use Voice 1)
          rem   - Set SoundEffectFrame1 = Duration + Delay
          rem   - Advance SoundEffectPointer1 by 4 bytes
          rem - Handle end-of-sound: set soundEffectPointer1 = 0, AUDV1
          rem   = 0, free voice
          return

