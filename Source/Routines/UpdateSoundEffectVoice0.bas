          rem ChaosFight - Source/Routines/UpdateSoundEffectVoice0.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateSoundEffectVoice0
          asm
UpdateSoundEffectVoice0

end
          rem
          rem Updatesoundeffectvoice0 - Update Voice 0 Sound Effect
          rem Update Voice 0 sound effect playback (decrements frame
          rem counter, loads next note when counter reaches 0)
          rem
          rem Input: soundEffectFrame_R (global SCRAM) = frame counter,
          rem soundEffectPointer (global 16-bit) = sound pointer
          rem
          rem Output: Frame counter decremented, next note loaded when
          rem counter reaches 0, voice freed when sound ends
          rem
          rem Mutates: temp4 = frame count calculation,
          rem soundEffectFrame_W (global SCRAM) = frame counter
          rem (decremented), soundEffectPointer (global 16-bit) = sound pointer (advanced by 4 bytes),
          rem AUDC0, AUDF0, AUDV0 (TIA registers) = sound registers
          rem (updated via LoadSoundNote)
          rem
          rem Called Routines: LoadSoundNote (bank15) - loads next
          rem 4-byte note from Sounds bank, extracts AUDC/AUDV, writes
          rem to TIA, advances pointer, handles end-of-sound
          rem
          rem Constraints: Uses Voice 0 (AUDC0, AUDF0, AUDV0).
          rem LoadSoundNote handles end-of-sound by setting
          rem soundEffectPointer = 0 and AUDV0 = 0
          rem Decrement frame counter
          let temp4 = soundEffectFrame_R - 1
          rem Fix RMW: Read from _R, modify, write to _W
          let soundEffectFrame_W = temp4
          if temp4 then return

          gosub LoadSoundNote bank15
          rem Frame counter reached 0 - load next note from Sounds bank
          rem LoadSoundNote will:
          rem - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          rem   AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Write to TIA: AUDC0, AUDF0, AUDV0 (use Voice 0)
          rem   - Set SoundEffectFrame = Duration + Delay
          rem   - Advance SoundEffectPointer by 4 bytes
          rem - Handle end-of-sound: set soundEffectPointer = 0, AUDV0
          rem   = 0, free voice
          return

