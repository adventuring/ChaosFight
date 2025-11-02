          rem ChaosFight - Source/Routines/SoundSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem SOUND EFFECT SUBSYSTEM - Polyphony 1 Implementation
          rem =================================================================
          rem Sound effects for gameplay (gameMode 6)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration, Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem High byte of pointer = 0 indicates sound inactive
          rem Sound effects only play if music is not active
          rem =================================================================

          rem =================================================================
          rem PlaySoundEffect - Start sound effect playback
          rem =================================================================
          rem Input: temp1 = sound ID (0-255)
          rem Plays sound effect if voice is free, else forgets it (no queuing)
          rem =================================================================
PlaySoundEffect
          rem Check if already playing (forget if busy)
          if SoundEffectPointerH != 0 then return
          
          rem Check if music is active (music takes priority)
          if MusicVoice0PointerH != 0 then return
          if MusicVoice1PointerH != 0 then return
          
          rem Lookup sound pointer from Sounds bank (Bank15)
          rem Note: SoundPointerL/H tables are in Sounds bank
          gosub bank15 LoadSoundPointer
          rem LoadSoundPointer will set SoundPointerL and SoundPointerH from temp1
          
          rem Set sound effect pointer
          SoundEffectPointerL = SoundPointerL
          SoundEffectPointerH = SoundPointerH
          
          rem Initialize frame counter to trigger first note load
          SoundEffectFrame = 1
          
          rem Start first note
          gosub UpdateSoundEffect
          return

          rem =================================================================
          rem UpdateSoundEffect - Update sound effect playback each frame
          rem =================================================================
          rem Called every frame from MainLoop for gameMode 6
          rem Updates sound if active (high byte != 0)
          rem =================================================================
UpdateSoundEffect
          rem Check if sound active
          if SoundEffectPointerH = 0 then return
          
          rem Decrement frame counter
          SoundEffectFrame = SoundEffectFrame - 1
          if SoundEffectFrame != 0 then return
          
          rem Frame counter reached 0 - load next note from Sounds bank
          gosub bank15 LoadSoundNote
          rem LoadSoundNote will:
          rem   - Load 4-byte note from Sound_Voice0[pointer]: AUDCV, AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Write to TIA: AUDC0, AUDF0, AUDV0 (use Voice 0)
          rem   - Set SoundEffectFrame = Duration + Delay
          rem   - Advance SoundEffectPointer by 4 bytes
          rem   - Handle end-of-sound: set SoundEffectPointerH = 0, AUDV0 = 0, free voice
          return

          rem =================================================================
          rem StopSoundEffects - Stop all sound effects
          rem =================================================================
StopSoundEffects
          rem Zero TIA volume
          AUDV0 = 0
          
          rem Clear sound pointer (high byte = 0 means inactive)
          SoundEffectPointerH = 0
          
          rem Reset frame counter
          SoundEffectFrame = 0
          return

          rem =================================================================
          rem Compatibility stub (legacy function name)
          rem =================================================================
SoundSubsystem
          rem Legacy function - redirects to UpdateSoundEffect
          gosub UpdateSoundEffect
          return
