          rem ChaosFight - Source/Routines/PlaySoundEffect.bas
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

          gosub LoadSoundPointer bank15
          rem Lookup sound pointer from Sounds bank (Bank15)

          rem Try Voice 0 first

          if soundEffectPointer then TryVoice1

          let soundEffectPointer = soundPointer
          rem Voice 0 is free - use it
          let soundEffectFrame_W = 1
          goto UpdateSoundEffectVoice0 bank15
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

          let soundEffectPointer1 = soundPointer
          rem Voice 1 is free - use it
          let soundEffectFrame1_W = 1
          goto UpdateSoundEffectVoice1 bank15
          rem tail call

