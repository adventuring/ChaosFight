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
          dim PSE_soundID = temp1
          rem Check if music is active (music takes priority)
          if MusicVoice0PointerH then return
          if MusicVoice1PointerH then return
          
          rem Lookup sound pointer from Sounds bank (Bank15)
          gosub bank15 LoadSoundPointer
          
          rem Try Voice 0 first
          if SoundEffectPointerH then TryVoice1
          
          rem Voice 0 is free - use it
          let SoundEffectPointerL = SoundPointerL
          let SoundEffectPointerH = SoundPointerH
          let SoundEffectFrame_W = 1
          rem tail call
          goto UpdateSoundEffectVoice0
          
TryVoice1
          rem Try Voice 1
          if SoundEffectPointer1H then return
          
          rem Voice 1 is free - use it
          let SoundEffectPointer1L = SoundPointerL
          let SoundEffectPointer1H = SoundPointerH
          let SoundEffectFrame1_W = 1
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
          rem Update Voice 0
          if SoundEffectPointerH then gosub UpdateSoundEffectVoice0
          
          rem Update Voice 1
          if SoundEffectPointer1H then rem tail call : goto UpdateSoundEffectVoice1
          return
          
          
          rem ==========================================================
          rem UpdateSoundEffectVoice0 - Update Voice 0 sound effect
          rem ==========================================================
UpdateSoundEffectVoice0
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let SS_frameCount = SoundEffectFrame_R - 1
          let SoundEffectFrame_W = SS_frameCount
          if SS_frameCount then return
          
          rem Frame counter reached 0 - load next note from Sounds bank
          gosub bank15 LoadSoundNote
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
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let SS_frameCount1 = SoundEffectFrame1_R - 1
          let SoundEffectFrame1_W = SS_frameCount1
          if SS_frameCount1 then return
          
          rem Frame counter reached 0 - load next note from Sounds bank
          gosub bank15 LoadSoundNote1
          rem LoadSoundNote1 will:
          rem - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          rem   AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Write to TIA: AUDC1, AUDF1, AUDV1 (use Voice 1)
          rem   - Set SoundEffectFrame1 = Duration + Delay
          rem   - Advance SoundEffectPointer1 by 4 bytes
          rem - Handle end-of-sound: set SoundEffectPointer1H = 0, AUDV1
          rem   = 0, free voice
          return

          rem ==========================================================
          rem StopSoundEffects - Stop all sound effects
          rem ==========================================================
StopSoundEffects
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear sound pointers (high byte = 0 means inactive)
          let SoundEffectPointerH = 0
          let SoundEffectPointer1H = 0
          
          rem Reset frame counters
          let SoundEffectFrame_W = 0
          let SoundEffectFrame1_W = 0
          return

          rem ==========================================================
          rem Compatibility stub (legacy function name)
          rem ==========================================================
SoundSubsystem
          rem Legacy function - redirects to UpdateSoundEffect
          rem tail call
          goto UpdateSoundEffect
