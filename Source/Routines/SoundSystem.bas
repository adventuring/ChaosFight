          rem ChaosFight - Source/Routines/SoundSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

PlaySoundEffect
          rem SOUND EFFECT SUBSYSTEM - Polyphony 2 Implementation
          rem Sound effects for gameplay (gameMode 6)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,
          rem Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem
          rem High byte of pointer = 0 indicates sound inactive
          rem Supports 2 simultaneous sound effects (one per voice)
          rem Music takes priority (no sounds if music active)
          rem Playsoundeffect - Start Sound Effect Playback
          rem
          rem Input: temp1 = sound ID (0-255)
          rem Plays sound effect if voice is free, else forgets it (no
          rem   queuing)
          rem Start sound effect playback (plays sound if voice is free,
          rem else forgets it)
          rem
          rem Input: temp1 = sound ID (0-255), musicVoice0Pointer,
          rem musicVoice1Pointer (global 16-bit) = music voice pointers,
          rem soundEffectPointer, soundEffectPointer1 (global 16-bit) =
          rem sound effect pointers
          rem
          rem Output: Sound effect started on available voice (Voice 0
          rem preferred, Voice 1 fallback)
          rem
          rem Mutates: temp1 (used for sound ID), soundPointer (global 16-bit)
          rem = sound pointer (via LoadSoundPointer), soundEffectPointer,
          rem soundEffectFrame_W (global SCRAM) = Voice 0 sound state (if Voice 0 used),
          rem soundEffectPointer1,
          rem soundEffectFrame1_W (global SCRAM) = Voice 1 sound state
          rem (if Voice 1 used)
          rem
          rem Called Routines: LoadSoundPointer (bank15) - looks up
          rem sound pointer from Sounds bank, UpdateSoundEffectVoice0
          rem (tail call via goto) - starts Voice 0 playback,
          rem UpdateSoundEffectVoice1 (tail call via goto) - starts
          rem Voice 1 playback
          rem
          rem Constraints: Music takes priority (no sounds if music
          rem active). No queuing - sound forgotten if both voices busy.
          rem Voice 0 tried first, Voice 1 as fallback
          rem Check if music is active (music takes priority)
          if musicVoice0Pointer then return
          if musicVoice1Pointer then return
          
          gosub LoadSoundPointer bank15 : 
          rem Lookup sound pointer from Sounds bank (Bank15)
          
          rem Try Voice 0 first
          
          if soundEffectPointer then TryVoice1
          
          let soundEffectPointer = soundPointer : 
          rem Voice 0 is free - use it
          let soundEffectFrame_W = 1
          goto UpdateSoundEffectVoice0 : 
          rem tail call
          
TryVoice1
          rem Helper: Tries Voice 1 if Voice 0 is busy
          rem
          rem Input: soundPointer (global 16-bit) = sound pointer,
          rem soundEffectPointer1 (global 16-bit) = Voice 1 pointer
          rem
          rem Output: Sound effect started on Voice 1 if free
          rem
          rem Mutates: soundEffectPointer1,
          rem soundEffectFrame1_W (global SCRAM) = Voice 1 sound state
          rem
          rem Called Routines: UpdateSoundEffectVoice1 (tail call via
          rem goto) - starts Voice 1 playback
          rem
          rem Constraints: Internal helper for PlaySoundEffect, only
          rem called when Voice 0 is busy
          rem Try Voice 1
          if soundEffectPointer1 then return
          
          let soundEffectPointer1 = soundPointer : 
          rem Voice 1 is free - use it
          let soundEffectFrame1_W = 1
          goto UpdateSoundEffectVoice1 : 
          rem tail call

UpdateSoundEffect
          rem UpdateSoundEffect - Update sound effect playback each
          rem   frame
          rem Called every frame from MainLoop for gameMode 6
          rem Updates both voices if active (high byte != 0)
          rem Update sound effect playback each frame (called every
          rem frame from MainLoop for gameMode 6)
          rem
          rem Input: soundEffectPointer, soundEffectPointer1 (global 16-bit)
          rem = sound effect pointers, soundEffectFrame_R,
          rem soundEffectFrame1_R (global SCRAM) = frame counters
          rem
          rem Output: Both voices updated if active (high byte != 0)
          rem
          rem Mutates: All sound effect state (via
          rem UpdateSoundEffectVoice0 and UpdateSoundEffectVoice1)
          rem
          rem Called Routines: UpdateSoundEffectVoice0 - updates Voice 0
          rem if active, UpdateSoundEffectVoice1 - updates Voice 1 if
          rem active
          rem
          rem Constraints: Called every frame from MainLoop for gameMode
          rem 6. Only updates voices if active (high byte != 0)
          rem Update Voice 0
          if soundEffectPointer then gosub UpdateSoundEffectVoice0
          
          rem Update Voice 1
          
          if soundEffectPointer1 then gosub UpdateSoundEffectVoice1
          return
          
          
UpdateSoundEffectVoice0
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
          rem Mutates: SS_frameCount (global) = frame count calculation,
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
          let SS_frameCount = soundEffectFrame_R - 1 : 
          rem Fix RMW: Read from _R, modify, write to _W
          let soundEffectFrame_W = SS_frameCount
          if SS_frameCount then return
          
          gosub LoadSoundNote bank15 : 
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
          rem Mutates: SS_frameCount1 (global) = frame count
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
          let SS_frameCount1 = soundEffectFrame1_R - 1 : 
          rem Fix RMW: Read from _R, modify, write to _W
          let soundEffectFrame1_W = SS_frameCount1
          if SS_frameCount1 then return
          
          gosub LoadSoundNote1 bank15 : 
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

StopSoundEffects
          rem
          rem Stopsoundeffects - Stop All Sound Effects
          rem Stop all sound effects (zeroes TIA volumes, clears
          rem pointers, resets frame counters)
          rem
          rem Input: None
          rem
          rem Output: All sound effects stopped, voices freed
          rem
          rem Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set
          rem to 0), soundEffectPointer, soundEffectPointer1 (global 16-bit)
          rem = sound pointers (set to 0), soundEffectFrame_W,
          rem soundEffectFrame1_W (global SCRAM) = frame counters (set
          rem to 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear sound pointers (high byte = 0 means inactive)
          let soundEffectPointer = 0
          let soundEffectPointer1 = 0
          
          let soundEffectFrame_W = 0 : 
          rem Reset frame counters
          let soundEffectFrame1_W = 0
          return
