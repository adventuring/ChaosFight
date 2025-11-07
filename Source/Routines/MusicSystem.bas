StartMusic
          rem
          rem ChaosFight - Source/Routines/MusicSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem MUSIC SUBSYSTEM - Polyphony 2 Implementation
          rem Music system for publisher/author/title/winner screens
          rem   (gameMode 0-2, 7)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,
          rem
          rem   Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem High byte of pointer = 0 indicates voice inactive
          rem Startmusic - Initialize Music Playback
          rem Input: temp1 = song ID (0-255)
          rem Stops any current music and starts the specified song
          rem Initialize music playback (stops any current music and
          rem starts the specified song)
          rem Input: temp1 = song ID (0-255), songPointerL, songPointerH
          rem (global) = song pointers (via LoadSongPointer)
          rem Output: Music started, voice pointers set, frame counters
          rem initialized, first notes loaded
          rem Mutates: temp1 (used for song ID), AUDV0, AUDV1 (TIA
          rem registers) = sound volumes (set to 0),
          rem musicVoice0PointerL, musicVoice0PointerH,
          rem musicVoice1PointerL, musicVoice1PointerH (global) = voice
          rem pointers (set to song start), musicVoice0StartPointerL_W,
          rem musicVoice0StartPointerH_W, musicVoice1StartPointerL_W,
          rem musicVoice1StartPointerH_W (global SCRAM) = start pointers
          rem (stored for looping), currentSongID_W (global SCRAM) =
          rem current song ID (stored), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (set to
          rem 1)
          rem Called Routines: LoadSongPointer (bank15 or bank16) -
          rem looks up song pointer, LoadSongVoice1Pointer (bank15 or
          rem bank16) - calculates Voice 1 pointer, UpdateMusic (tail
          rem call via goto) - starts first notes
          rem Constraints: Songs in Bank 15: OCascadia (1), Revontuli
          rem (2). All other songs (0, 3-28) in Bank 16. Routes to
          rem correct bank based on song ID
          dim SM_songID = temp1
          rem Stop any current music
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let musicVoice0PointerH = 0
          let musicVoice1PointerH = 0
          
          rem Lookup song pointer from appropriate bank (Bank15 or
          rem Bank16)
          rem Songs in Bank 15: OCascadia (1), Revontuli (2)
          rem Songs in Bank 16: All other songs (0, 3-28)
          if SM_songID = 1 then goto LoadSongFromBank15 : rem Route to correct bank based on song ID
          if SM_songID = 2 then goto LoadSongFromBank15
          gosub LoadSongPointer bank16 : rem Song in Bank 16
          gosub LoadSongVoice1Pointer bank16
          goto LoadSongPointersDone
LoadSongFromBank15
          rem Helper: Loads song pointers from Bank 15
          rem Input: temp1 = song ID, songPointerL, songPointerH
          rem (global) = song pointers (via LoadSongPointer)
          rem Output: Song pointers loaded from Bank 15
          rem Mutates: songPointerL, songPointerH (global) = song
          rem pointers (via LoadSongPointer and LoadSongVoice1Pointer)
          rem Called Routines: LoadSongPointer (bank15) - looks up song
          rem pointer, LoadSongVoice1Pointer (bank15) - calculates Voice
          rem 1 pointer
          rem Constraints: Internal helper for StartMusic, only called
          rem for songs 1-2
          gosub LoadSongPointer bank15 : rem Song in Bank 15
          gosub LoadSongVoice1Pointer bank15
LoadSongPointersDone
          rem Helper: Completes song pointer setup after loading
          rem Input: songPointerL, songPointerH (global) = song pointers
          rem Output: Voice pointers set, start pointers stored, frame
          rem counters initialized
          rem Mutates: musicVoice0PointerL, musicVoice0PointerH,
          rem musicVoice1PointerL, musicVoice1PointerH (global) = voice
          rem pointers, musicVoice0StartPointerL_W,
          rem musicVoice0StartPointerH_W, musicVoice1StartPointerL_W,
          rem musicVoice1StartPointerH_W (global SCRAM) = start
          rem pointers, currentSongID_W (global SCRAM) = current song
          rem ID, musicVoice0Frame_W, musicVoice1Frame_W (global SCRAM)
          rem = frame counters
          rem Called Routines: UpdateMusic (tail call via goto) - starts
          rem first notes
          rem Constraints: Internal helper for StartMusic, completes
          rem setup after pointer loading
          rem LoadSongPointer will set songPointerL and songPointerH
          rem   from temp1
          
          let musicVoice0PointerL = songPointerL : rem Set Voice 0 pointer to song start (Song_Voice0 stream)
          let musicVoice0PointerH = songPointerH
          
          let musicVoice0StartPointerL_W = songPointerL : rem Store initial pointers for looping (Chaotica only)
          let musicVoice0StartPointerH_W = songPointerH
          
          rem LoadSongVoice1Pointer already called above
          rem LoadSongVoice1Pointer will calculate and set Voice 1
          let musicVoice1PointerL = songPointerL : rem   pointer
          let musicVoice1PointerH = songPointerH
          
          let musicVoice1StartPointerL_W = songPointerL : rem Store initial Voice 1 pointer for looping (Chaotica only)
          let musicVoice1StartPointerH_W = songPointerH
          
          let currentSongID_W = SM_songID : rem Store current song ID for looping check
          
          let musicVoice0Frame_W = 1 : rem Initialize frame counters to trigger first note load
          let musicVoice1Frame_W = 1
          
          rem Start first notes
          goto UpdateMusic : rem tail call

UpdateMusic
          rem
          rem Updatemusic - Update Music Playback Each Frame
          rem Called every frame from MainLoop for gameMode 0-2, 7
          rem Updates both voices if active (high byte ≠ 0)
          rem Update music playback each frame (called every frame from
          rem MainLoop for gameMode 0-2, 7)
          rem Input: musicVoice0PointerH, musicVoice1PointerH (global) =
          rem voice pointers, musicVoice0Frame_R, musicVoice1Frame_R
          rem (global SCRAM) = frame counters, currentSongID_R (global
          rem SCRAM) = current song ID, musicVoice0StartPointerL_R,
          rem musicVoice0StartPointerH_R, musicVoice1StartPointerL_R,
          rem musicVoice1StartPointerH_R (global SCRAM) = start pointers
          rem Output: Both voices updated if active (high byte ≠ 0),
          rem Chaotica (song 26) loops when both voices end
          rem Mutates: All music voice state (via UpdateMusicVoice0 and
          rem UpdateMusicVoice1), musicVoice0PointerL,
          rem musicVoice0PointerH, musicVoice1PointerL,
          rem musicVoice1PointerH (global) = voice pointers (reset to
          rem start for Chaotica loop), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (reset
          rem to 1 for Chaotica loop)
          rem Called Routines: UpdateMusicVoice0 - updates Voice 0 if
          rem active, UpdateMusicVoice1 - updates Voice 1 if active
          rem Constraints: Called every frame from MainLoop for gameMode
          rem 0-2, 7. Only Chaotica (song ID 26) loops - other songs
          rem stop when both voices end
          if musicVoice0PointerH then gosub UpdateMusicVoice0 : rem Update Voice 0 if active
          
          if musicVoice1PointerH then gosub UpdateMusicVoice1 : rem Update Voice 1 if active
          
          rem Check if both voices have ended (both pointerH = 0) and
          rem song is
          rem   Chaotica (26) for looping
          if musicVoice0PointerH then MusicUpdateDone : rem Only Chaotica loops - other songs stop when both voices end
          if musicVoice1PointerH then MusicUpdateDone : rem Voice 0 still active, no reset needed
          rem Voice 1 still active, no reset needed
          if currentSongID_R = 26 then IsChaotica : rem Both voices inactive - check if Chaotica (song ID 26)
          goto MusicUpdateDone
          rem Not Chaotica - stop playback (no loop)
IsChaotica
          rem Helper: Resets Chaotica to song head when both voices end
          rem Input: musicVoice0StartPointerL_R,
          rem musicVoice0StartPointerH_R, musicVoice1StartPointerL_R,
          rem musicVoice1StartPointerH_R (global SCRAM) = start pointers
          rem Output: Voice pointers reset to start, frame counters
          rem reset, first notes reloaded
          rem Mutates: musicVoice0PointerL, musicVoice0PointerH,
          rem musicVoice1PointerL, musicVoice1PointerH (global) = voice
          rem pointers (reset to start), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (reset
          rem to 1)
          rem Called Routines: UpdateMusic (tail call via goto) -
          rem reloads first notes
          rem Constraints: Internal helper for UpdateMusic, only called
          rem when both voices ended and song is Chaotica (26)
          rem Both voices ended and song is Chaotica - reset to song
          rem head
          let musicVoice0PointerL = musicVoice0StartPointerL_R : rem Reset Voice 0 pointer to start
          let musicVoice0PointerH = musicVoice0StartPointerH_R
          let musicVoice1PointerL = musicVoice1StartPointerL_R : rem Reset Voice 1 pointer to start
          let musicVoice1PointerH = musicVoice1StartPointerH_R
          let musicVoice0Frame_W = 1 : rem Initialize frame counters to trigger first note load
          let musicVoice1Frame_W = 1
          rem Tail call to reload first notes
          goto UpdateMusic : rem tail call
MusicUpdateDone
          return
          rem Helper: End of UpdateMusic (label only)
CalculateMusicVoiceEnvelope
          rem Input: None (label only)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Internal label for UpdateMusic, marks end of
          rem update
          rem
          rem Shared Music Voice Envelope Calculation
          rem Calculates envelope (attack/decay/sustain) for a music
          rem voice
          rem INPUT: temp1 = voice number (0 or 1)
          rem OUTPUT: Sets AUDV0 or AUDV1 based on voice
          rem Uses voice-specific variables based on temp1
          rem Calculates envelope (attack/decay/sustain) for a music
          rem voice
          rem Input: temp1 = voice number (0 or 1),
          rem MusicVoice0TotalFrames, MusicVoice1TotalFrames (global) =
          rem total frames, musicVoice0Frame_R, musicVoice1Frame_R
          rem (global SCRAM) = frame counters, MusicVoice0TargetAUDV,
          rem MusicVoice1TargetAUDV (global) = target volumes,
          rem NoteAttackFrames, NoteDecayFrames (global constants) =
          rem envelope constants
          rem Output: Sets AUDV0 or AUDV1 based on voice and envelope
          rem phase
          rem Mutates: temp1-temp6 (used for calculations), AUDV0, AUDV1
          rem (TIA registers) = sound volumes (set based on envelope)
          rem Called Routines: None
          rem Constraints: Uses voice-specific variables based on temp1.
          rem Attack phase: first NoteAttackFrames frames. Decay phase:
          rem last NoteDecayFrames frames. Sustain phase: uses target
          rem AUDV. Clamps AUDV to 0-15
          dim CMVE_voice = temp1
          dim CMVE_totalFrames = temp2
          dim CMVE_frameCounter = temp3
          dim CMVE_framesElapsed = temp4
          dim CMVE_targetAUDV = temp5
          dim CMVE_audv = temp6
          if CMVE_voice = 0 then CMVE_GetVoice0Vars : rem Get voice-specific variables
          let CMVE_totalFrames = MusicVoice1TotalFrames : rem Voice 1
          let CMVE_frameCounter = musicVoice1Frame_R
          let CMVE_targetAUDV = MusicVoice1TargetAUDV
          goto CMVE_CalcElapsed
CMVE_GetVoice0Vars
          rem Helper: Gets Voice 0 specific variables
          rem Input: MusicVoice0TotalFrames (global) = total frames,
          rem musicVoice0Frame_R (global SCRAM) = frame counter,
          rem MusicVoice0TargetAUDV (global) = target volume
          rem Output: Voice 0 variables loaded
          rem Mutates: CMVE_totalFrames, CMVE_frameCounter,
          rem CMVE_targetAUDV (local variables)
          rem Called Routines: None
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope, only called for voice 0
          let CMVE_totalFrames = MusicVoice0TotalFrames : rem Voice 0
          let CMVE_frameCounter = musicVoice0Frame_R
          let CMVE_targetAUDV = MusicVoice0TargetAUDV
CMVE_CalcElapsed
          rem Helper: Calculates frames elapsed and determines envelope
          rem phase
          rem Input: CMVE_totalFrames, CMVE_frameCounter,
          rem CMVE_targetAUDV (local variables), NoteAttackFrames,
          rem NoteDecayFrames (global constants)
          rem Output: Envelope phase determined, appropriate phase
          rem handler called
          rem Mutates: CMVE_framesElapsed (local variable)
          rem Called Routines: CMVE_ApplyAttack - applies attack
          rem envelope, CMVE_ApplyDecay - applies decay envelope
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope
          let CMVE_framesElapsed = CMVE_totalFrames - CMVE_frameCounter : rem Calculate frames elapsed = TotalFrames - FrameCounter
          if CMVE_framesElapsed < NoteAttackFrames then CMVE_ApplyAttack : rem Check if in attack phase (first NoteAttackFrames frames)
          if CMVE_frameCounter <= NoteDecayFrames then CMVE_ApplyDecay : rem Check if in decay phase (last NoteDecayFrames frames)
          rem Sustain phase - use target AUDV (already set)
          return
CMVE_ApplyAttack
          rem Helper: Applies attack envelope (ramps up volume)
          rem Input: CMVE_targetAUDV, CMVE_framesElapsed (local
          rem variables), CMVE_voice (local variable), NoteAttackFrames
          rem (global constant)
          rem Output: AUDV set based on attack phase
          rem Mutates: CMVE_audv (local variable), AUDV0, AUDV1 (TIA
          rem registers) = sound volumes
          rem Called Routines: CMVE_SetAUDV0 - sets AUDV0
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope, only called in attack phase.
          rem Formula: AUDV = Target - NoteAttackFrames + frames_elapsed
          rem Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          let CMVE_audv = CMVE_targetAUDV
          let CMVE_audv = CMVE_audv - NoteAttackFrames
          let CMVE_audv = CMVE_audv + CMVE_framesElapsed
          if CMVE_audv & $80 then let CMVE_audv = 0 : rem Check for wraparound: clamp to 0 if negative
          if CMVE_audv > 15 then let CMVE_audv = 15
          if CMVE_voice = 0 then CMVE_SetAUDV0 : rem Set voice-specific AUDV
          let AUDV1 = CMVE_audv
          return
CMVE_SetAUDV0
          rem Helper: Sets AUDV0 for Voice 0
          rem Input: CMVE_audv (local variable)
          rem Output: AUDV0 set
          rem Mutates: AUDV0 (TIA register) = sound volume
          rem Called Routines: None
          rem Constraints: Internal helper for CMVE_ApplyAttack and
          rem CMVE_ApplyDecay, only called for voice 0
          let AUDV0 = CMVE_audv
          return
CMVE_ApplyDecay
          rem Helper: Applies decay envelope (ramps down volume)
          rem Input: CMVE_targetAUDV, CMVE_frameCounter (local
          rem variables), CMVE_voice (local variable), NoteDecayFrames
          rem (global constant)
          rem Output: AUDV set based on decay phase
          rem Mutates: CMVE_audv (local variable), AUDV0, AUDV1 (TIA
          rem registers) = sound volumes
          rem Called Routines: CMVE_SetAUDV0 - sets AUDV0
          rem Constraints: Internal helper for
          rem CalculateMusicVoiceEnvelope, only called in decay phase.
          rem Formula: AUDV = Target - (NoteDecayFrames - FrameCounter +
          rem 1)
          rem Decay: AUDV = Target - (NoteDecayFrames - FrameCounter +
          rem 1)
          let CMVE_audv = CMVE_targetAUDV
          let CMVE_audv = CMVE_audv - NoteDecayFrames
          let CMVE_audv = CMVE_audv + CMVE_frameCounter
          let CMVE_audv = CMVE_audv - 1
          if CMVE_audv & $80 then let CMVE_audv = 0 : rem Check for wraparound: clamp to 0 if negative
          if CMVE_audv > 15 then let CMVE_audv = 15
          if CMVE_voice = 0 then CMVE_SetAUDV0 : rem Set voice-specific AUDV
          let AUDV1 = CMVE_audv
          return

UpdateMusicVoice0
          rem
          rem Updatemusicvoice0 - Update Voice 0 Playback
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
          rem Update Voice 0 playback (applies envelope, decrements
          rem frame counter, loads new note when counter reaches 0)
          rem Input: musicVoice0Frame_R (global SCRAM) = frame counter,
          rem musicVoice0PointerL, musicVoice0PointerH (global) = voice
          rem pointer, currentSongID_R (global SCRAM) = current song ID,
          rem MusicVoice0TotalFrames, MusicVoice0TargetAUDV (global) =
          rem envelope parameters, NoteAttackFrames, NoteDecayFrames
          rem (global constants) = envelope constants
          rem Output: Envelope applied, frame counter decremented, next
          rem note loaded when counter reaches 0
          rem Mutates: temp1 (used for voice number), MS_frameCount
          rem (global) = frame count calculation, musicVoice0Frame_W
          rem (global SCRAM) = frame counter (decremented),
          rem musicVoice0PointerL, musicVoice0PointerH (global) = voice
          rem pointer (advanced via LoadMusicNote0), AUDC0, AUDF0, AUDV0
          rem (TIA registers) = sound registers (updated via
          rem LoadMusicNote0 and CalculateMusicVoiceEnvelope)
          rem Called Routines: CalculateMusicVoiceEnvelope - applies
          rem attack/decay/sustain envelope, LoadMusicNote0 (bank15 or
          rem bank16) - loads next 4-byte note, extracts AUDC/AUDV,
          rem writes to TIA, advances pointer, handles end-of-song
          rem Constraints: Uses Voice 0 (AUDC0, AUDF0, AUDV0). Songs 1-2
          rem in Bank 15, all others in Bank 16. Routes to correct bank
          rem based on currentSongID_R
          let temp1 = 0 : rem Apply envelope using shared calculation
          gosub CalculateMusicVoiceEnvelope
          rem Decrement frame counter
          let MS_frameCount = musicVoice0Frame_R - 1 : rem Fix RMW: Read from _R, modify, write to _W
          let musicVoice0Frame_W = MS_frameCount
          if MS_frameCount then return
          rem Frame counter reached 0 - load next note from appropriate
          rem bank
          rem Check which bank this song is in (Bank 15: songs 1-2, Bank
          rem 16: others)
          if currentSongID_R = 1 then gosub LoadMusicNote0 bank15 : return
          if currentSongID_R = 2 then gosub LoadMusicNote0 bank15 : return
          gosub LoadMusicNote0 bank16 : rem Song in Bank 16
          return

UpdateMusicVoice1
          rem
          rem Updatemusicvoice1 - Update Voice 1 Playback
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
          rem Update Voice 1 playback (applies envelope, decrements
          rem frame counter, loads new note when counter reaches 0)
          rem Input: musicVoice1Frame_R (global SCRAM) = frame counter,
          rem musicVoice1PointerL, musicVoice1PointerH (global) = voice
          rem pointer, currentSongID_R (global SCRAM) = current song ID,
          rem MusicVoice1TotalFrames, MusicVoice1TargetAUDV (global) =
          rem envelope parameters, NoteAttackFrames, NoteDecayFrames
          rem (global constants) = envelope constants
          rem Output: Envelope applied, frame counter decremented, next
          rem note loaded when counter reaches 0
          rem Mutates: temp1 (used for voice number), MS_frameCount1
          rem (global) = frame count calculation, musicVoice1Frame_W
          rem (global SCRAM) = frame counter (decremented),
          rem musicVoice1PointerL, musicVoice1PointerH (global) = voice
          rem pointer (advanced via LoadMusicNote1), AUDC1, AUDF1, AUDV1
          rem (TIA registers) = sound registers (updated via
          rem LoadMusicNote1 and CalculateMusicVoiceEnvelope)
          rem Called Routines: CalculateMusicVoiceEnvelope - applies
          rem attack/decay/sustain envelope, LoadMusicNote1 (bank15 or
          rem bank16) - loads next 4-byte note, extracts AUDC/AUDV,
          rem writes to TIA, advances pointer, handles end-of-song
          rem Constraints: Uses Voice 1 (AUDC1, AUDF1, AUDV1). Songs 1-2
          rem in Bank 15, all others in Bank 16. Routes to correct bank
          rem based on currentSongID_R
          let temp1 = 1 : rem Apply envelope using shared calculation
          gosub CalculateMusicVoiceEnvelope
          rem Decrement frame counter
          let MS_frameCount1 = musicVoice1Frame_R - 1 : rem Fix RMW: Read from _R, modify, write to _W
          let musicVoice1Frame_W = MS_frameCount1
          if MS_frameCount1 then return
          rem Frame counter reached 0 - load next note from appropriate
          rem bank
          rem Check which bank this song is in (Bank 15: songs 1-2, Bank
          rem 16: others)
          if currentSongID_R = 1 then gosub LoadMusicNote1 bank15 : return
          if currentSongID_R = 2 then gosub LoadMusicNote1 bank15 : return
          gosub LoadMusicNote1 bank16 : rem Song in Bank 16
          return

StopMusic
          rem
          rem Stopmusic - Stop All Music Playback
          rem Stop all music playback (zeroes TIA volumes, clears
          rem pointers, resets frame counters)
          rem Input: None
          rem Output: All music stopped, voices freed
          rem Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set
          rem to 0), musicVoice0PointerH, musicVoice1PointerH (global) =
          rem voice pointers (set to 0), musicVoice0Frame_W,
          rem musicVoice1Frame_W (global SCRAM) = frame counters (set to
          rem 0)
          rem Called Routines: None
          rem Constraints: None
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let musicVoice0PointerH = 0
          let musicVoice1PointerH = 0
          
          let musicVoice0Frame_W = 0 : rem Reset frame counters
          let musicVoice1Frame_W = 0
          return
