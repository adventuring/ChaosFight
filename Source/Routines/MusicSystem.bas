          rem ChaosFight - Source/Routines/MusicSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem MUSIC SUBSYSTEM - Polyphony 2 Implementation
          rem
          rem Music system for publisher/author/title/winner screens
          rem   (gameMode 0-2, 7)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,
          rem   Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem High byte of pointer = 0 indicates voice inactive

          rem Startmusic - Initialize Music Playback
          rem
          rem Input: temp1 = song ID (0-255)
          rem Stops any current music and starts the specified song
StartMusic
          rem Initialize music playback (stops any current music and starts the specified song)
          rem Input: temp1 = song ID (0-255), songPointerL, songPointerH (global) = song pointers (via LoadSongPointer)
          rem Output: Music started, voice pointers set, frame counters initialized, first notes loaded
          rem Mutates: temp1 (used for song ID), AUDV0, AUDV1 (TIA registers) = sound volumes (set to 0), musicVoice0PointerL, musicVoice0PointerH, musicVoice1PointerL, musicVoice1PointerH (global) = voice pointers (set to song start), musicVoice0StartPointerL_W, musicVoice0StartPointerH_W, musicVoice1StartPointerL_W, musicVoice1StartPointerH_W (global SCRAM) = start pointers (stored for looping), currentSongID_W (global SCRAM) = current song ID (stored), musicVoice0Frame_W, musicVoice1Frame_W (global SCRAM) = frame counters (set to 1)
          rem Called Routines: LoadSongPointer (bank15 or bank16) - looks up song pointer, LoadSongVoice1Pointer (bank15 or bank16) - calculates Voice 1 pointer, UpdateMusic (tail call via goto) - starts first notes
          rem Constraints: Songs in Bank 15: OCascadia (1), Revontuli (2). All other songs (0, 3-28) in Bank 16. Routes to correct bank based on song ID
          dim SM_songID = temp1
          rem Stop any current music
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let musicVoice0PointerH = 0
          let musicVoice1PointerH = 0
          
          rem Lookup song pointer from appropriate bank (Bank15 or Bank16)
          rem Songs in Bank 15: OCascadia (1), Revontuli (2)
          rem Songs in Bank 16: All other songs (0, 3-28)
          rem Route to correct bank based on song ID
          if SM_songID = 1 then goto LoadSongFromBank15
          if SM_songID = 2 then goto LoadSongFromBank15
          rem Song in Bank 16
          gosub LoadSongPointer bank16
          gosub LoadSongVoice1Pointer bank16
          goto LoadSongPointersDone
LoadSongFromBank15
          rem Helper: Loads song pointers from Bank 15
          rem Input: temp1 = song ID, songPointerL, songPointerH (global) = song pointers (via LoadSongPointer)
          rem Output: Song pointers loaded from Bank 15
          rem Mutates: songPointerL, songPointerH (global) = song pointers (via LoadSongPointer and LoadSongVoice1Pointer)
          rem Called Routines: LoadSongPointer (bank15) - looks up song pointer, LoadSongVoice1Pointer (bank15) - calculates Voice 1 pointer
          rem Constraints: Internal helper for StartMusic, only called for songs 1-2
          rem Song in Bank 15
          gosub LoadSongPointer bank15
          gosub LoadSongVoice1Pointer bank15
LoadSongPointersDone
          rem Helper: Completes song pointer setup after loading
          rem Input: songPointerL, songPointerH (global) = song pointers
          rem Output: Voice pointers set, start pointers stored, frame counters initialized
          rem Mutates: musicVoice0PointerL, musicVoice0PointerH, musicVoice1PointerL, musicVoice1PointerH (global) = voice pointers, musicVoice0StartPointerL_W, musicVoice0StartPointerH_W, musicVoice1StartPointerL_W, musicVoice1StartPointerH_W (global SCRAM) = start pointers, currentSongID_W (global SCRAM) = current song ID, musicVoice0Frame_W, musicVoice1Frame_W (global SCRAM) = frame counters
          rem Called Routines: UpdateMusic (tail call via goto) - starts first notes
          rem Constraints: Internal helper for StartMusic, completes setup after pointer loading
          rem LoadSongPointer will set songPointerL and songPointerH
          rem   from temp1
          
          rem Set Voice 0 pointer to song start (Song_Voice0 stream)
          let musicVoice0PointerL = songPointerL
          let musicVoice0PointerH = songPointerH
          
          rem Store initial pointers for looping (Chaotica only)
          let musicVoice0StartPointerL_W = songPointerL
          let musicVoice0StartPointerH_W = songPointerH
          
          rem LoadSongVoice1Pointer already called above
          rem LoadSongVoice1Pointer will calculate and set Voice 1
          rem   pointer
          let musicVoice1PointerL = songPointerL
          let musicVoice1PointerH = songPointerH
          
          rem Store initial Voice 1 pointer for looping (Chaotica only)
          let musicVoice1StartPointerL_W = songPointerL
          let musicVoice1StartPointerH_W = songPointerH
          
          rem Store current song ID for looping check
          let currentSongID_W = SM_songID
          
          rem Initialize frame counters to trigger first note load
          let musicVoice0Frame_W = 1
          let musicVoice1Frame_W = 1
          
          rem Start first notes
          rem tail call
          goto UpdateMusic

          rem Updatemusic - Update Music Playback Each Frame
          rem
          rem Called every frame from MainLoop for gameMode 0-2, 7
          rem Updates both voices if active (high byte ≠ 0)
UpdateMusic
          rem Update music playback each frame (called every frame from MainLoop for gameMode 0-2, 7)
          rem Input: musicVoice0PointerH, musicVoice1PointerH (global) = voice pointers, musicVoice0Frame_R, musicVoice1Frame_R (global SCRAM) = frame counters, currentSongID_R (global SCRAM) = current song ID, musicVoice0StartPointerL_R, musicVoice0StartPointerH_R, musicVoice1StartPointerL_R, musicVoice1StartPointerH_R (global SCRAM) = start pointers
          rem Output: Both voices updated if active (high byte ≠ 0), Chaotica (song 26) loops when both voices end
          rem Mutates: All music voice state (via UpdateMusicVoice0 and UpdateMusicVoice1), musicVoice0PointerL, musicVoice0PointerH, musicVoice1PointerL, musicVoice1PointerH (global) = voice pointers (reset to start for Chaotica loop), musicVoice0Frame_W, musicVoice1Frame_W (global SCRAM) = frame counters (reset to 1 for Chaotica loop)
          rem Called Routines: UpdateMusicVoice0 - updates Voice 0 if active, UpdateMusicVoice1 - updates Voice 1 if active
          rem Constraints: Called every frame from MainLoop for gameMode 0-2, 7. Only Chaotica (song ID 26) loops - other songs stop when both voices end
          rem Update Voice 0 if active
          if musicVoice0PointerH then gosub UpdateMusicVoice0
          
          rem Update Voice 1 if active
          if musicVoice1PointerH then gosub UpdateMusicVoice1
          
          rem Check if both voices have ended (both pointerH = 0) and song is
          rem   Chaotica (26) for looping
          rem Only Chaotica loops - other songs stop when both voices end
          if musicVoice0PointerH then MusicUpdateDone
          rem Voice 0 still active, no reset needed
          if musicVoice1PointerH then MusicUpdateDone
          rem Voice 1 still active, no reset needed
          rem Both voices inactive - check if Chaotica (song ID 26)
          if currentSongID_R = 26 then IsChaotica
          goto MusicUpdateDone
          rem Not Chaotica - stop playback (no loop)
IsChaotica
          rem Helper: Resets Chaotica to song head when both voices end
          rem Input: musicVoice0StartPointerL_R, musicVoice0StartPointerH_R, musicVoice1StartPointerL_R, musicVoice1StartPointerH_R (global SCRAM) = start pointers
          rem Output: Voice pointers reset to start, frame counters reset, first notes reloaded
          rem Mutates: musicVoice0PointerL, musicVoice0PointerH, musicVoice1PointerL, musicVoice1PointerH (global) = voice pointers (reset to start), musicVoice0Frame_W, musicVoice1Frame_W (global SCRAM) = frame counters (reset to 1)
          rem Called Routines: UpdateMusic (tail call via goto) - reloads first notes
          rem Constraints: Internal helper for UpdateMusic, only called when both voices ended and song is Chaotica (26)
          rem Both voices ended and song is Chaotica - reset to song head
          rem Reset Voice 0 pointer to start
          let musicVoice0PointerL = musicVoice0StartPointerL_R
          let musicVoice0PointerH = musicVoice0StartPointerH_R
          rem Reset Voice 1 pointer to start
          let musicVoice1PointerL = musicVoice1StartPointerL_R
          let musicVoice1PointerH = musicVoice1StartPointerH_R
          rem Initialize frame counters to trigger first note load
          let musicVoice0Frame_W = 1
          let musicVoice1Frame_W = 1
          rem Tail call to reload first notes
          rem tail call
          goto UpdateMusic
MusicUpdateDone
          rem Helper: End of UpdateMusic (label only)
          rem Input: None (label only)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Internal label for UpdateMusic, marks end of update
          return

          rem Shared Music Voice Envelope Calculation
          rem
          rem Calculates envelope (attack/decay/sustain) for a music voice
          rem INPUT: temp1 = voice number (0 or 1)
          rem OUTPUT: Sets AUDV0 or AUDV1 based on voice
          rem Uses voice-specific variables based on temp1
CalculateMusicVoiceEnvelope
          rem Calculates envelope (attack/decay/sustain) for a music voice
          rem Input: temp1 = voice number (0 or 1), MusicVoice0TotalFrames, MusicVoice1TotalFrames (global) = total frames, musicVoice0Frame_R, musicVoice1Frame_R (global SCRAM) = frame counters, MusicVoice0TargetAUDV, MusicVoice1TargetAUDV (global) = target volumes, NoteAttackFrames, NoteDecayFrames (global constants) = envelope constants
          rem Output: Sets AUDV0 or AUDV1 based on voice and envelope phase
          rem Mutates: temp1-temp6 (used for calculations), AUDV0, AUDV1 (TIA registers) = sound volumes (set based on envelope)
          rem Called Routines: None
          rem Constraints: Uses voice-specific variables based on temp1. Attack phase: first NoteAttackFrames frames. Decay phase: last NoteDecayFrames frames. Sustain phase: uses target AUDV. Clamps AUDV to 0-15
          dim CMVE_voice = temp1
          dim CMVE_totalFrames = temp2
          dim CMVE_frameCounter = temp3
          dim CMVE_framesElapsed = temp4
          dim CMVE_targetAUDV = temp5
          dim CMVE_audv = temp6
          rem Get voice-specific variables
          if CMVE_voice = 0 then CMVE_GetVoice0Vars
          rem Voice 1
          let CMVE_totalFrames = MusicVoice1TotalFrames
          let CMVE_frameCounter = musicVoice1Frame_R
          let CMVE_targetAUDV = MusicVoice1TargetAUDV
          goto CMVE_CalcElapsed
CMVE_GetVoice0Vars
          rem Helper: Gets Voice 0 specific variables
          rem Input: MusicVoice0TotalFrames (global) = total frames, musicVoice0Frame_R (global SCRAM) = frame counter, MusicVoice0TargetAUDV (global) = target volume
          rem Output: Voice 0 variables loaded
          rem Mutates: CMVE_totalFrames, CMVE_frameCounter, CMVE_targetAUDV (local variables)
          rem Called Routines: None
          rem Constraints: Internal helper for CalculateMusicVoiceEnvelope, only called for voice 0
          rem Voice 0
          let CMVE_totalFrames = MusicVoice0TotalFrames
          let CMVE_frameCounter = musicVoice0Frame_R
          let CMVE_targetAUDV = MusicVoice0TargetAUDV
CMVE_CalcElapsed
          rem Helper: Calculates frames elapsed and determines envelope phase
          rem Input: CMVE_totalFrames, CMVE_frameCounter, CMVE_targetAUDV (local variables), NoteAttackFrames, NoteDecayFrames (global constants)
          rem Output: Envelope phase determined, appropriate phase handler called
          rem Mutates: CMVE_framesElapsed (local variable)
          rem Called Routines: CMVE_ApplyAttack - applies attack envelope, CMVE_ApplyDecay - applies decay envelope
          rem Constraints: Internal helper for CalculateMusicVoiceEnvelope
          rem Calculate frames elapsed = TotalFrames - FrameCounter
          let CMVE_framesElapsed = CMVE_totalFrames - CMVE_frameCounter
          rem Check if in attack phase (first NoteAttackFrames frames)
          if CMVE_framesElapsed < NoteAttackFrames then CMVE_ApplyAttack
          rem Check if in decay phase (last NoteDecayFrames frames)
          if CMVE_frameCounter <= NoteDecayFrames then CMVE_ApplyDecay
          rem Sustain phase - use target AUDV (already set)
          return
CMVE_ApplyAttack
          rem Helper: Applies attack envelope (ramps up volume)
          rem Input: CMVE_targetAUDV, CMVE_framesElapsed (local variables), CMVE_voice (local variable), NoteAttackFrames (global constant)
          rem Output: AUDV set based on attack phase
          rem Mutates: CMVE_audv (local variable), AUDV0, AUDV1 (TIA registers) = sound volumes
          rem Called Routines: CMVE_SetAUDV0 - sets AUDV0
          rem Constraints: Internal helper for CalculateMusicVoiceEnvelope, only called in attack phase. Formula: AUDV = Target - NoteAttackFrames + frames_elapsed
          rem Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          let CMVE_audv = CMVE_targetAUDV
          let CMVE_audv = CMVE_audv - NoteAttackFrames
          let CMVE_audv = CMVE_audv + CMVE_framesElapsed
          rem Check for wraparound: clamp to 0 if negative
          if CMVE_audv & $80 then let CMVE_audv = 0
          if CMVE_audv > 15 then let CMVE_audv = 15
          rem Set voice-specific AUDV
          if CMVE_voice = 0 then CMVE_SetAUDV0
          let AUDV1 = CMVE_audv
          return
CMVE_SetAUDV0
          rem Helper: Sets AUDV0 for Voice 0
          rem Input: CMVE_audv (local variable)
          rem Output: AUDV0 set
          rem Mutates: AUDV0 (TIA register) = sound volume
          rem Called Routines: None
          rem Constraints: Internal helper for CMVE_ApplyAttack and CMVE_ApplyDecay, only called for voice 0
          let AUDV0 = CMVE_audv
          return
CMVE_ApplyDecay
          rem Helper: Applies decay envelope (ramps down volume)
          rem Input: CMVE_targetAUDV, CMVE_frameCounter (local variables), CMVE_voice (local variable), NoteDecayFrames (global constant)
          rem Output: AUDV set based on decay phase
          rem Mutates: CMVE_audv (local variable), AUDV0, AUDV1 (TIA registers) = sound volumes
          rem Called Routines: CMVE_SetAUDV0 - sets AUDV0
          rem Constraints: Internal helper for CalculateMusicVoiceEnvelope, only called in decay phase. Formula: AUDV = Target - (NoteDecayFrames - FrameCounter + 1)
          rem Decay: AUDV = Target - (NoteDecayFrames - FrameCounter + 1)
          let CMVE_audv = CMVE_targetAUDV
          let CMVE_audv = CMVE_audv - NoteDecayFrames
          let CMVE_audv = CMVE_audv + CMVE_frameCounter
          let CMVE_audv = CMVE_audv - 1
          rem Check for wraparound: clamp to 0 if negative
          if CMVE_audv & $80 then let CMVE_audv = 0
          if CMVE_audv > 15 then let CMVE_audv = 15
          rem Set voice-specific AUDV
          if CMVE_voice = 0 then CMVE_SetAUDV0
          let AUDV1 = CMVE_audv
          return

          rem Updatemusicvoice0 - Update Voice 0 Playback
          rem
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
UpdateMusicVoice0
          rem Update Voice 0 playback (applies envelope, decrements frame counter, loads new note when counter reaches 0)
          rem Input: musicVoice0Frame_R (global SCRAM) = frame counter, musicVoice0PointerL, musicVoice0PointerH (global) = voice pointer, currentSongID_R (global SCRAM) = current song ID, MusicVoice0TotalFrames, MusicVoice0TargetAUDV (global) = envelope parameters, NoteAttackFrames, NoteDecayFrames (global constants) = envelope constants
          rem Output: Envelope applied, frame counter decremented, next note loaded when counter reaches 0
          rem Mutates: temp1 (used for voice number), MS_frameCount (global) = frame count calculation, musicVoice0Frame_W (global SCRAM) = frame counter (decremented), musicVoice0PointerL, musicVoice0PointerH (global) = voice pointer (advanced via LoadMusicNote0), AUDC0, AUDF0, AUDV0 (TIA registers) = sound registers (updated via LoadMusicNote0 and CalculateMusicVoiceEnvelope)
          rem Called Routines: CalculateMusicVoiceEnvelope - applies attack/decay/sustain envelope, LoadMusicNote0 (bank15 or bank16) - loads next 4-byte note, extracts AUDC/AUDV, writes to TIA, advances pointer, handles end-of-song
          rem Constraints: Uses Voice 0 (AUDC0, AUDF0, AUDV0). Songs 1-2 in Bank 15, all others in Bank 16. Routes to correct bank based on currentSongID_R
          rem Apply envelope using shared calculation
          let temp1 = 0
          gosub CalculateMusicVoiceEnvelope
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let MS_frameCount = musicVoice0Frame_R - 1
          let musicVoice0Frame_W = MS_frameCount
          if MS_frameCount then return
          rem Frame counter reached 0 - load next note from appropriate bank
          rem Check which bank this song is in (Bank 15: songs 1-2, Bank 16: others)
          if currentSongID_R = 1 then gosub LoadMusicNote0 bank15 : return
          if currentSongID_R = 2 then gosub LoadMusicNote0 bank15 : return
          rem Song in Bank 16
          gosub LoadMusicNote0 bank16
          return

          rem Updatemusicvoice1 - Update Voice 1 Playback
          rem
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
UpdateMusicVoice1
          rem Update Voice 1 playback (applies envelope, decrements frame counter, loads new note when counter reaches 0)
          rem Input: musicVoice1Frame_R (global SCRAM) = frame counter, musicVoice1PointerL, musicVoice1PointerH (global) = voice pointer, currentSongID_R (global SCRAM) = current song ID, MusicVoice1TotalFrames, MusicVoice1TargetAUDV (global) = envelope parameters, NoteAttackFrames, NoteDecayFrames (global constants) = envelope constants
          rem Output: Envelope applied, frame counter decremented, next note loaded when counter reaches 0
          rem Mutates: temp1 (used for voice number), MS_frameCount1 (global) = frame count calculation, musicVoice1Frame_W (global SCRAM) = frame counter (decremented), musicVoice1PointerL, musicVoice1PointerH (global) = voice pointer (advanced via LoadMusicNote1), AUDC1, AUDF1, AUDV1 (TIA registers) = sound registers (updated via LoadMusicNote1 and CalculateMusicVoiceEnvelope)
          rem Called Routines: CalculateMusicVoiceEnvelope - applies attack/decay/sustain envelope, LoadMusicNote1 (bank15 or bank16) - loads next 4-byte note, extracts AUDC/AUDV, writes to TIA, advances pointer, handles end-of-song
          rem Constraints: Uses Voice 1 (AUDC1, AUDF1, AUDV1). Songs 1-2 in Bank 15, all others in Bank 16. Routes to correct bank based on currentSongID_R
          rem Apply envelope using shared calculation
          let temp1 = 1
          gosub CalculateMusicVoiceEnvelope
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let MS_frameCount1 = musicVoice1Frame_R - 1
          let musicVoice1Frame_W = MS_frameCount1
          if MS_frameCount1 then return
          rem Frame counter reached 0 - load next note from appropriate bank
          rem Check which bank this song is in (Bank 15: songs 1-2, Bank 16: others)
          if currentSongID_R = 1 then gosub LoadMusicNote1 bank15 : return
          if currentSongID_R = 2 then gosub LoadMusicNote1 bank15 : return
          rem Song in Bank 16
          gosub LoadMusicNote1 bank16
          return

          rem Stopmusic - Stop All Music Playback
          rem
StopMusic
          rem Stop all music playback (zeroes TIA volumes, clears pointers, resets frame counters)
          rem Input: None
          rem Output: All music stopped, voices freed
          rem Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set to 0), musicVoice0PointerH, musicVoice1PointerH (global) = voice pointers (set to 0), musicVoice0Frame_W, musicVoice1Frame_W (global SCRAM) = frame counters (set to 0)
          rem Called Routines: None
          rem Constraints: None
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let musicVoice0PointerH = 0
          let musicVoice1PointerH = 0
          
          rem Reset frame counters
          let musicVoice0Frame_W = 0
          let musicVoice1Frame_W = 0
          return
