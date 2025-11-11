          rem ChaosFight - Source/Routines/MusicSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Local music-system scratch aliases (temp registers for frame countdowns)
          dim MS_frameCount = temp4
          dim MS_frameCount1 = temp5

StartMusic
          rem MUSIC SUBSYSTEM - Polyphony 2 Implementation
          rem Music system for publisher/author/title/winner screens
          rem   (gameMode 0-2, 7)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,
          rem
          rem   Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem High byte of pointer = 0 indicates voice inactive
          rem Startmusic - Initialize Music Playback
          rem
          rem Input: temp1 = song ID (0-255)
          rem Stops any current music and starts the specified song
          rem Initialize music playback (stops any current music and
          rem starts the specified song)
          rem
          rem Input: temp1 = song ID (0-255)
          rem
          rem Output: Music started, voice pointers set, frame counters
          rem initialized, first notes loaded
          rem
          rem Mutates: temp1 (used for song ID), AUDV0, AUDV1 (TIA
          rem registers) = sound volumes (set to 0),
          rem musicVoice0Pointer, musicVoice1Pointer (global 16-bit words)
          rem = voice pointers (set to song start), musicVoice0StartPointer_W,
          rem musicVoice1StartPointer_W (global SCRAM 16-bit) = start pointers
          rem (stored for looping), currentSongID_W (global SCRAM) =
          rem current song ID (stored), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (set to
          rem 1)
          rem
          rem Called Routines: LoadSongPointer (bank15 or bank1) -
          rem looks up song pointer, LoadSongVoice1PointerBank15 or
          rem LoadSongVoice1PointerBank1 - calculates Voice 1 pointer, UpdateMusic (tail
          rem call via goto) - starts first notes
          rem
          rem Constraints: Songs in Bank 15: Bernie (0), OCascadia (1),
          rem Revontuli (2), EXO (3), Grizzards (Bank15MaxSongID). All other songs (Bank1MinSongID-28) in Bank 1.
          rem Routes to correct bank based on song ID
          rem Stop any current music
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let musicVoice0Pointer = 0
          let musicVoice1Pointer = 0
          
          rem Lookup song pointer from appropriate bank (Bank15 or
          rem Bank1)
          rem Songs in Bank 15: IDs 0-Bank15MaxSongID
          rem Songs in Bank 1: All other songs (Bank1MinSongID-28)
          rem Route to correct bank based on song ID
          if temp1 < Bank1MinSongID then goto LoadSongFromBank15
          gosub LoadSongPointer bank1
          rem Song in Bank 1
          gosub LoadSongVoice1PointerBank1
          goto LoadSongPointersDone
LoadSongFromBank15
          rem Helper: Loads song pointers from Bank 15
          rem
          rem Input: temp1 = song ID
          rem
          rem Output: Song pointers loaded from Bank 15
          rem
          rem Mutates: songPointer (global 16-bit) via LoadSongPointer and
          rem LoadSongVoice1PointerBank15
          rem
          rem Called Routines: LoadSongPointer (bank15) - looks up song
          rem pointer, LoadSongVoice1PointerBank15 (bank15) - calculates Voice
          rem 1 pointer
          rem
          rem Constraints: Internal helper for StartMusic, only called
          rem for songs 0-Bank15MaxSongID
          gosub LoadSongPointer bank15
          rem Song in Bank 15
          gosub LoadSongVoice1PointerBank15 bank15
LoadSongPointersDone
          rem Helper: Completes song pointer setup after loading
          rem
          rem Input: songPointer (global 16-bit) = song pointers
          rem
          rem Output: Voice pointers set, start pointers stored, frame
          rem counters initialized
          rem
          rem Mutates: musicVoice0Pointer, musicVoice1Pointer (global 16-bit
          rem words) = voice pointers, musicVoice0StartPointer_W,
          rem musicVoice1StartPointer_W (global SCRAM 16-bit) = start
          rem pointers, currentSongID_W (global SCRAM) = current song
          rem ID, musicVoice0Frame_W, musicVoice1Frame_W (global SCRAM)
          rem = frame counters
          rem
          rem Called Routines: UpdateMusic (tail call via goto) - starts
          rem first notes
          rem
          rem Constraints: Internal helper for StartMusic, completes
          rem setup after pointer loading
          rem LoadSongPointer populated songPointer (16-bit)
          let musicVoice0Pointer = songPointer
          rem Set Voice 0 pointer to song start (Song_Voice0 stream)
          let musicVoice0StartPointer_W = songPointer
          rem Store initial pointers for looping (Chaotica only)
          
          rem LoadSongVoice1PointerBank1/15 already called above
          rem Voice 1 loader reused songPointer (16-bit) for Voice 1
          let musicVoice1Pointer = songPointer
          let musicVoice1StartPointer_W = songPointer
          rem Store initial Voice 1 pointer for looping (Chaotica only)
          
          let currentSongID_W = temp1
          rem Store current song ID for looping check
          
          let musicVoice0Frame_W = 1
          rem Initialize frame counters to trigger first note load
          let musicVoice1Frame_W = 1
          
          rem Start first notes
          goto UpdateMusic
          rem tail call

UpdateMusic
          rem
          rem Updatemusic - Update Music Playback Each Frame
          rem Called every frame from MainLoop for gameMode 0-2, 7
          rem Updates both voices if active (high byte ≠ 0)
          rem Update music playback each frame (called every frame from
          rem MainLoop for gameMode 0-2, 7)
          rem
          rem Input: musicVoice0Pointer, musicVoice1Pointer (global 16-bit)
          rem voice pointers, musicVoice0Frame_R, musicVoice1Frame_R
          rem (global SCRAM) = frame counters, currentSongID_R (global
          rem SCRAM) = current song ID, musicVoice0StartPointer_R,
          rem musicVoice1StartPointer_R (global SCRAM 16-bit) = start pointers
          rem
          rem Output: Both voices updated if active (high byte ≠ 0),
          rem Chaotica (song 26) loops when both voices end
          rem
          rem Mutates: All music voice state (via UpdateMusicVoice0 and
          rem UpdateMusicVoice1), musicVoice0Pointer, musicVoice1Pointer
          rem (global 16-bit) = voice pointers (reset to start for Chaotica
          rem loop), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (reset
          rem to 1 for Chaotica loop)
          rem
          rem Called Routines: UpdateMusicVoice0 - updates Voice 0 if
          rem active, UpdateMusicVoice1 - updates Voice 1 if active
          rem
          rem Constraints: Called every frame from MainLoop for gameMode
          rem 0-2, 7. Only Chaotica (song ID 26) loops - other songs
          rem stop when both voices end
          rem Update Voice 0 if active
          if musicVoice0Pointer then gosub UpdateMusicVoice0
          
          rem Update Voice 1 if active
          
          if musicVoice1Pointer then gosub UpdateMusicVoice1
          
          rem Check if both voices have ended (both pointerH = 0) and
          rem song is
          rem   Chaotica (26) for looping
          rem Only Chaotica loops - other songs stop when both voices end
          if musicVoice0Pointer then MusicUpdateDone
          rem Voice 0 still active, no reset needed
          if musicVoice1Pointer then MusicUpdateDone
          rem Voice 1 still active, no reset needed
          rem Both voices inactive - check if Chaotica (song ID 26)
          if currentSongID_R = 26 then IsChaotica
          goto MusicUpdateDone
IsChaotica
          rem Not Chaotica - stop playback (no loop)
          rem Helper: Resets Chaotica to song head when both voices end
          rem
          rem Input: musicVoice0StartPointer_R,
          rem musicVoice1StartPointer_R (global SCRAM 16-bit) = start pointers
          rem
          rem Output: Voice pointers reset to start, frame counters
          rem reset, first notes reloaded
          rem
          rem Mutates: musicVoice0Pointer, musicVoice1Pointer (global 16-bit) =
          rem pointers (reset to start), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (reset
          rem to 1)
          rem
          rem Called Routines: UpdateMusic (tail call via goto) -
          rem reloads first notes
          rem
          rem Constraints: Internal helper for UpdateMusic, only called
          rem when both voices ended and song is Chaotica (26)
          rem Both voices ended and song is Chaotica - reset to song
          rem head
          let musicVoice0Pointer = musicVoice0StartPointer_R
          rem Reset Voice 0 pointer to start
          let musicVoice1Pointer = musicVoice1StartPointer_R
          rem Reset Voice 1 pointer to start
          let musicVoice0Frame_W = 1
          rem Initialize frame counters to trigger first note load
          let musicVoice1Frame_W = 1
          rem Tail call to reload first notes
          goto UpdateMusic
          rem tail call
MusicUpdateDone
          return
CalculateMusicVoiceEnvelope
          rem Helper: End of UpdateMusic (label only)
          rem
          rem Input: None (label only)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal label for UpdateMusic, marks end of
          rem update
          rem
          rem Shared Music Voice Envelope Calculation
          rem Input: temp1 = voice number (0 or 1)
          rem        MusicVoiceXTotalFrames, musicVoiceXFrame_R, MusicVoiceXTargetAUDV,
          rem        NoteAttackFrames, NoteDecayFrames (indexed by voice)
          rem Output: AUDV0 or AUDV1 set per envelope phase
          rem Mutates: temp1-temp6, AUDV0, AUDV1
          rem Constraints: Voice-specific data selected via temp1. Attack phase = first NoteAttackFrames frames,
          rem last NoteDecayFrames frames. Sustain phase: uses target
          rem AUDV. Clamps AUDV to 0-15
          rem Get voice-specific variables
          if temp1 = 0 then CMVE_GetVoice0Vars
          let temp2 = MusicVoice1TotalFrames_R
          rem Voice 1
          let temp3 = musicVoice1Frame_R
          let temp5 = MusicVoice1TargetAUDV_R
          goto CMVE_CalcElapsed
CMVE_GetVoice0Vars
          rem Helper: Gets Voice 0 specific variables
          rem
          rem Input: MusicVoice0TotalFrames (global) = total frames,
          rem musicVoice0Frame_R (global SCRAM) = frame counter,
          rem MusicVoice0TargetAUDV (global) = target volume
          rem
          rem Output: Voice 0 variables loaded
          rem
          rem Mutates: temp2, temp3,
          rem temp5 (local variables)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope, only called for voice 0
          let temp2 = MusicVoice0TotalFrames_R
          rem Voice 0
          let temp3 = musicVoice0Frame_R
          let temp5 = MusicVoice0TargetAUDV_R
CMVE_CalcElapsed
          rem Helper: Calculates frames elapsed and determines envelope
          rem phase
          rem
          rem Input: temp2, temp3,
          rem temp5 (local variables), NoteAttackFrames,
          rem NoteDecayFrames (global constants)
          rem
          rem Output: Envelope phase determined, appropriate phase
          rem handler called
          rem
          rem Mutates: temp4 (local variable)
          rem
          rem Called Routines: CMVE_ApplyAttack - applies attack
          rem envelope, CMVE_ApplyDecay - applies decay envelope
          rem
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope
          let temp4 = temp2 - temp3
          rem Calculate frames elapsed = TotalFrames - FrameCounter
          rem Check if in attack phase (first NoteAttackFrames frames)
          if temp4 < NoteAttackFrames then CMVE_ApplyAttack
          rem Check if in decay phase (last NoteDecayFrames frames)
          if temp3 <= NoteDecayFrames then CMVE_ApplyDecay
          rem Sustain phase - use target AUDV (already set)
          return
CMVE_ApplyAttack
          rem Helper: Applies attack envelope (ramps up volume)
          rem
          rem Input: temp5, temp4 (local
          rem variables), temp1 (local variable), NoteAttackFrames
          rem (global constant)
          rem
          rem Output: AUDV set based on attack phase
          rem
          rem Mutates: temp6 (local variable), AUDV0, AUDV1 (TIA
          rem registers) = sound volumes
          rem
          rem Called Routines: CMVE_SetAUDV0 - sets AUDV0
          rem
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope, only called in attack phase.
          rem Formula: AUDV = Target - NoteAttackFrames + frames_elapsed
          rem Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          let temp6 = temp5
          let temp6 = temp6 - NoteAttackFrames
          let temp6 = temp6 + temp4
          rem Check for wraparound: clamp to 0 if negative
          if temp6 & $80 then temp6 = 0
          if temp6 > 15 then temp6 = 15
          rem Set voice-specific AUDV
          if temp1 = 0 then CMVE_SetAUDV0
          let AUDV1 = temp6
          return
CMVE_SetAUDV0
          rem Helper: Sets AUDV0 for Voice 0
          rem
          rem Input: temp6 (local variable)
          rem
          rem Output: AUDV0 set
          rem
          rem Mutates: AUDV0 (TIA register) = sound volume
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for CMVE_ApplyAttack and
          rem CMVE_ApplyDecay, only called for voice 0
          let AUDV0 = temp6
          return
CMVE_ApplyDecay
          rem Helper: Applies decay envelope (ramps down volume)
          rem
          rem Input: temp5, temp3 (local
          rem variables), temp1 (local variable), NoteDecayFrames
          rem (global constant)
          rem
          rem Output: AUDV set based on decay phase
          rem
          rem Mutates: temp6 (local variable), AUDV0, AUDV1 (TIA
          rem registers) = sound volumes
          rem
          rem Called Routines: CMVE_SetAUDV0 - sets AUDV0
          rem
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope, only called in decay phase.
          rem Formula: AUDV = Target - (NoteDecayFrames - FrameCounter + 1)
          let temp6 = temp5
          let temp6 = temp6 - NoteDecayFrames
          let temp6 = temp6 + temp3
          let temp6 = temp6 - 1
          rem Check for wraparound: clamp to 0 if negative
          if temp6 & $80 then temp6 = 0
          if temp6 > 15 then temp6 = 15
          rem Set voice-specific AUDV
          if temp1 = 0 then CMVE_SetAUDV0
          let AUDV1 = temp6
          return

UpdateMusicVoice0
          rem
          rem Update Voice 0 playback (envelope, frame counter, note stepping).
          rem Input: musicVoice0Frame_R, musicVoice0Pointer (16-bit), currentSongID_R,
          rem        MusicVoice0TotalFrames/TargetAUDV, NoteAttackFrames, NoteDecayFrames
          rem Output: Envelope applied, frame counter decremented, next note loaded when counter hits 0
          rem Mutates: temp1, MS_frameCount, musicVoice0Frame_W, musicVoice0Pointer
          rem pointer (advanced via LoadMusicNote0), AUDC0, AUDF0, AUDV0
          rem (TIA registers) = sound registers (updated via
          rem LoadMusicNote0 and CalculateMusicVoiceEnvelope)
          rem
          rem Called Routines: CalculateMusicVoiceEnvelope - applies
          rem attack/decay/sustain envelope, LoadMusicNote0 (bank15 or
          rem bank1) - loads next 4-byte note, extracts AUDC/AUDV,
          rem writes to TIA, advances pointer, handles end-of-song
          rem
          rem Constraints: Uses Voice 0 (AUDC0, AUDF0, AUDV0). Songs 0-Bank15MaxSongID
          rem in Bank 15, all others in Bank 1. Routes to correct bank
          rem based on currentSongID_R
          let temp1 = 0
          rem Apply envelope using shared calculation
          gosub CalculateMusicVoiceEnvelope
          rem Decrement frame counter
          let MS_frameCount = musicVoice0Frame_R - 1
          rem Fix RMW: Read from _R, modify, write to _W
          let musicVoice0Frame_W = MS_frameCount
          if MS_frameCount then return
          rem Frame counter reached 0 - load next note from appropriate
          rem bank
          rem Check which bank this song is in (Bank 15: songs 0-Bank15MaxSongID, Bank
          rem 1: others)
          if currentSongID_R < Bank1MinSongID then gosub LoadMusicNote0 bank15 : return
          gosub LoadMusicNote0 bank1
          rem Song in Bank 1
          return

UpdateMusicVoice1
          rem
          rem Updatemusicvoice1 - Update Voice 1 Playback
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
          rem Update Voice 1 playback (applies envelope, decrements
          rem frame counter, loads new note when counter reaches 0)
          rem
          rem Input: musicVoice1Frame_R (global SCRAM) = frame counter,
          rem musicVoice1Pointer (global 16-bit) = voice pointer,
          rem currentSongID_R (global SCRAM) = current song ID,
          rem MusicVoice1TotalFrames, MusicVoice1TargetAUDV (global) =
          rem envelope parameters, NoteAttackFrames, NoteDecayFrames
          rem (global constants) = envelope constants
          rem
          rem Output: Envelope applied, frame counter decremented, next
          rem note loaded when counter reaches 0
          rem
          rem Mutates: temp1 (used for voice number), MS_frameCount1
          rem (global) = frame count calculation, musicVoice1Frame_W
          rem (global SCRAM) = frame counter (decremented),
          rem musicVoice1Pointer (global 16-bit) = voice
          rem pointer (advanced via LoadMusicNote1), AUDC1, AUDF1, AUDV1
          rem (TIA registers) = sound registers (updated via
          rem LoadMusicNote1 and CalculateMusicVoiceEnvelope)
          rem
          rem Called Routines: CalculateMusicVoiceEnvelope - applies
          rem attack/decay/sustain envelope, LoadMusicNote1 (bank15 or
          rem bank1) - loads next 4-byte note, extracts AUDC/AUDV,
          rem writes to TIA, advances pointer, handles end-of-song
          rem
          rem Constraints: Uses Voice 1 (AUDC1, AUDF1, AUDV1). Songs 0-Bank15MaxSongID
          rem in Bank 15, all others in Bank 1. Routes to correct bank
          rem based on currentSongID_R
          let temp1 = 1
          rem Apply envelope using shared calculation
          gosub CalculateMusicVoiceEnvelope
          rem Decrement frame counter
          let MS_frameCount1 = musicVoice1Frame_R - 1
          rem Fix RMW: Read from _R, modify, write to _W
          let musicVoice1Frame_W = MS_frameCount1
          if MS_frameCount1 then return
          rem Frame counter reached 0 - load next note from appropriate
          rem bank
          rem Check which bank this song is in (Bank 15: songs 0-Bank15MaxSongID, Bank
          rem 1: others)
          if currentSongID_R < Bank1MinSongID then gosub LoadMusicNote1 bank15 : return
          gosub LoadMusicNote1 bank1
          rem Song in Bank 1
          return

StopMusic
          rem
          rem Stopmusic - Stop All Music Playback
          rem Stop all music playback (zeroes TIA volumes, clears
          rem pointers, resets frame counters)
          rem
          rem Input: None
          rem
          rem Output: All music stopped, voices freed
          rem
          rem Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set
          rem to 0), musicVoice0Pointer, musicVoice1Pointer (global 16-bit)
          rem = voice pointers (set to 0), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (set to
          rem 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let musicVoice0Pointer = 0
          let musicVoice1Pointer = 0
          
          let musicVoice0Frame_W = 0
          rem Reset frame counters
          let musicVoice1Frame_W = 0
          return
