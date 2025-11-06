          rem ChaosFight - Source/Routines/SoundSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem SOUND EFFECT SUBSYSTEM - Polyphony 2 Implementation
          rem ==========================================================
          rem Sound effects for gameplay (gameMode 6)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,
          rem   Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem High byte of pointer = 0 indicates sound inactive
          rem Supports 2 simultaneous sound effects (one per voice)
          rem Music takes priority (no sounds if music active)
          rem ==========================================================

          rem ==========================================================
          rem PlaySoundEffect - Start sound effect playback
          rem ==========================================================
          rem Input: temp1 = sound ID (0-255)
          rem Plays sound effect if voice is free, else forgets it (no
          rem   queuing)
          rem ==========================================================
PlaySoundEffect
          rem Start sound effect playback (plays sound if voice is free, else forgets it)
          rem Input: temp1 = sound ID (0-255), musicVoice0PointerH, musicVoice1PointerH (global) = music voice pointers, soundEffectPointerH_R, soundEffectPointer1H (global SCRAM) = sound effect pointers
          rem Output: Sound effect started on available voice (Voice 0 preferred, Voice 1 fallback)
          rem Mutates: temp1 (used for sound ID), soundPointerL, soundPointerH_R (global) = sound pointer (via LoadSoundPointer), SoundEffectPointerL, soundEffectPointerH_W, soundEffectFrame_W (global SCRAM) = Voice 0 sound state (if Voice 0 used), soundEffectPointer1L, soundEffectPointer1H, soundEffectFrame1_W (global SCRAM) = Voice 1 sound state (if Voice 1 used)
          rem Called Routines: LoadSoundPointer (bank15) - looks up sound pointer from Sounds bank, UpdateSoundEffectVoice0 (tail call via goto) - starts Voice 0 playback, UpdateSoundEffectVoice1 (tail call via goto) - starts Voice 1 playback
          rem Constraints: Music takes priority (no sounds if music active). No queuing - sound forgotten if both voices busy. Voice 0 tried first, Voice 1 as fallback
          dim PSE_soundID = temp1
          rem Check if music is active (music takes priority)
          if musicVoice0PointerH then return
          if musicVoice1PointerH then return
          
          rem Lookup sound pointer from Sounds bank (Bank15)
          gosub LoadSoundPointer bank15
          
          rem Try Voice 0 first
          if soundEffectPointerH_R then TryVoice1
          
          rem Voice 0 is free - use it
          let SoundEffectPointerL = soundPointerL
          let soundEffectPointerH_W = soundPointerH_R
          let soundEffectFrame_W = 1
          rem tail call
          goto UpdateSoundEffectVoice0
          
TryVoice1
          rem Helper: Tries Voice 1 if Voice 0 is busy
          rem Input: soundPointerL, soundPointerH_R (global) = sound pointer, soundEffectPointer1H (global SCRAM) = Voice 1 pointer
          rem Output: Sound effect started on Voice 1 if free
          rem Mutates: soundEffectPointer1L, soundEffectPointer1H, soundEffectFrame1_W (global SCRAM) = Voice 1 sound state
          rem Called Routines: UpdateSoundEffectVoice1 (tail call via goto) - starts Voice 1 playback
          rem Constraints: Internal helper for PlaySoundEffect, only called when Voice 0 is busy
          rem Try Voice 1
          if soundEffectPointer1H then return
          
          rem Voice 1 is free - use it
          let soundEffectPointer1L = soundPointerL
          let soundEffectPointer1H = soundPointerH_R
          let soundEffectFrame1_W = 1
          rem tail call
          goto UpdateSoundEffectVoice1

          rem ==========================================================
          rem UpdateSoundEffect - Update sound effect playback each
          rem   frame
          rem ==========================================================
          rem Called every frame from MainLoop for gameMode 6
          rem Updates both voices if active (high byte != 0)
          rem ==========================================================
UpdateSoundEffect
          rem Update sound effect playback each frame (called every frame from MainLoop for gameMode 6)
          rem Input: soundEffectPointerH_R, soundEffectPointer1H (global SCRAM) = sound effect pointers, soundEffectFrame_R, soundEffectFrame1_R (global SCRAM) = frame counters
          rem Output: Both voices updated if active (high byte != 0)
          rem Mutates: All sound effect state (via UpdateSoundEffectVoice0 and UpdateSoundEffectVoice1)
          rem Called Routines: UpdateSoundEffectVoice0 - updates Voice 0 if active, UpdateSoundEffectVoice1 - updates Voice 1 if active
          rem Constraints: Called every frame from MainLoop for gameMode 6. Only updates voices if active (high byte != 0)
          rem Update Voice 0
          if soundEffectPointerH_R then gosub UpdateSoundEffectVoice0
          
          rem Update Voice 1
          if soundEffectPointer1H then gosub UpdateSoundEffectVoice1
          return
          
          
          rem ==========================================================
          rem UpdateSoundEffectVoice0 - Update Voice 0 sound effect
          rem ==========================================================
UpdateSoundEffectVoice0
          rem Update Voice 0 sound effect playback (decrements frame counter, loads next note when counter reaches 0)
          rem Input: soundEffectFrame_R (global SCRAM) = frame counter, SoundEffectPointerL, soundEffectPointerH_R (global SCRAM) = sound pointer
          rem Output: Frame counter decremented, next note loaded when counter reaches 0, voice freed when sound ends
          rem Mutates: SS_frameCount (global) = frame count calculation, soundEffectFrame_W (global SCRAM) = frame counter (decremented), SoundEffectPointerL, soundEffectPointerH_W (global SCRAM) = sound pointer (advanced by 4 bytes), AUDC0, AUDF0, AUDV0 (TIA registers) = sound registers (updated via LoadSoundNote)
          rem Called Routines: LoadSoundNote (bank15) - loads next 4-byte note from Sounds bank, extracts AUDC/AUDV, writes to TIA, advances pointer, handles end-of-sound
          rem Constraints: Uses Voice 0 (AUDC0, AUDF0, AUDV0). LoadSoundNote handles end-of-sound by setting SoundEffectPointerH = 0 and AUDV0 = 0
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let SS_frameCount = soundEffectFrame_R - 1
          let soundEffectFrame_W = SS_frameCount
          if SS_frameCount then return
          
          rem Frame counter reached 0 - load next note from Sounds bank
          gosub LoadSoundNote bank15
          rem LoadSoundNote will:
          rem - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          rem   AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Write to TIA: AUDC0, AUDF0, AUDV0 (use Voice 0)
          rem   - Set SoundEffectFrame = Duration + Delay
          rem   - Advance SoundEffectPointer by 4 bytes
          rem - Handle end-of-sound: set SoundEffectPointerH = 0, AUDV0
          rem   = 0, free voice
          return
          
          rem ==========================================================
          rem UpdateSoundEffectVoice1 - Update Voice 1 sound effect
          rem ==========================================================
UpdateSoundEffectVoice1
          rem Update Voice 1 sound effect playback (decrements frame counter, loads next note when counter reaches 0)
          rem Input: soundEffectFrame1_R (global SCRAM) = frame counter, soundEffectPointer1L, soundEffectPointer1H (global SCRAM) = sound pointer
          rem Output: Frame counter decremented, next note loaded when counter reaches 0, voice freed when sound ends
          rem Mutates: SS_frameCount1 (global) = frame count calculation, soundEffectFrame1_W (global SCRAM) = frame counter (decremented), soundEffectPointer1L, soundEffectPointer1H (global SCRAM) = sound pointer (advanced by 4 bytes), AUDC1, AUDF1, AUDV1 (TIA registers) = sound registers (updated via LoadSoundNote1)
          rem Called Routines: LoadSoundNote1 (bank15) - loads next 4-byte note from Sounds bank, extracts AUDC/AUDV, writes to TIA, advances pointer, handles end-of-sound
          rem Constraints: Uses Voice 1 (AUDC1, AUDF1, AUDV1). LoadSoundNote1 handles end-of-sound by setting soundEffectPointer1H = 0 and AUDV1 = 0
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let SS_frameCount1 = soundEffectFrame1_R - 1
          let soundEffectFrame1_W = SS_frameCount1
          if SS_frameCount1 then return
          
          rem Frame counter reached 0 - load next note from Sounds bank
          gosub LoadSoundNote1 bank15
          rem LoadSoundNote1 will:
          rem - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          rem   AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Write to TIA: AUDC1, AUDF1, AUDV1 (use Voice 1)
          rem   - Set SoundEffectFrame1 = Duration + Delay
          rem   - Advance SoundEffectPointer1 by 4 bytes
          rem - Handle end-of-sound: set soundEffectPointer1H = 0, AUDV1
          rem   = 0, free voice
          return

          rem ==========================================================
          rem StopSoundEffects - Stop all sound effects
          rem ==========================================================
StopSoundEffects
          rem Stop all sound effects (zeroes TIA volumes, clears pointers, resets frame counters)
          rem Input: None
          rem Output: All sound effects stopped, voices freed
          rem Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set to 0), soundEffectPointerH_W, soundEffectPointer1H (global SCRAM) = sound pointers (set to 0), soundEffectFrame_W, soundEffectFrame1_W (global SCRAM) = frame counters (set to 0)
          rem Called Routines: None
          rem Constraints: None
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear sound pointers (high byte = 0 means inactive)
          let soundEffectPointerH_W = 0
          let soundEffectPointer1H = 0
          
          rem Reset frame counters
          let soundEffectFrame_W = 0
          let soundEffectFrame1_W = 0
          return
