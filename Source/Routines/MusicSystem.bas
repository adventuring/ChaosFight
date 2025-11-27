          rem ChaosFight - Source/Routines/MusicSystem.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Local music-system scratch variables (using built-in temp4/temp5)

StartMusic
          asm
StartMusic
end
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
          rem LoadSongVoice1PointerBank1 - calculates Voice 1 pointer, PlayMusic (tail
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
          rem Song in Bank 1
          gosub LoadSongPointer bank1
          gosub LoadSongVoice1PointerBank1 bank1
          goto LoadSongPointersDone
LoadSongFromBank15
          rem Song in Bank 15
          gosub LoadSongPointerBank15
          gosub LoadSongVoice1PointerBank15
LoadSongPointersDone
          rem LoadSongPointer populated songPointer (16-bit)
          rem Set Voice 0 pointer to song start (Song_Voice0 stream)
          rem Store initial pointers for looping (Chaotica only)
          let musicVoice0Pointer = songPointer
          let musicVoice0StartPointer_W = songPointer

          rem LoadSongVoice1PointerBank1/15 already called above
          rem Voice 1 loader reused songPointer (16-bit) for Voice 1
          rem Store initial Voice 1 pointer for looping (Chaotica only)
          let musicVoice1Pointer = songPointer
          let musicVoice1StartPointer_W = songPointer

          rem Store current song ID for looping check
          let currentSongID_W = temp1

          rem Initialize frame counters to trigger first note load
          let musicVoice0Frame_W = 1
          let musicVoice1Frame_W = 1

          rem StartMusic is called via gosub from other banks, so must return
          rem PlayMusic will be called every frame from MainLoop
          return otherbank

PlayMusic
          asm
PlayMusic
end
          rem
          rem PlayMusic - Play Music Each Frame
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
          rem song is Chaotica (26) for looping
          rem Only Chaotica loops - other songs stop when both voices end
          rem Voice 0 still active, no reset needed
          if musicVoice0Pointer then return otherbank
          rem Voice 1 still active, no reset needed
          if musicVoice1Pointer then return otherbank
          rem Both voices inactive - check if Chaotica (song ID 26)
          if currentSongID_R = 26 then goto IsChaotica
          return otherbank
IsChaotica
          rem Both voices ended and song is Chaotica - reset to song head
          let musicVoice0Pointer = musicVoice0StartPointer_R
          let musicVoice1Pointer = musicVoice1StartPointer_R
          let musicVoice0Frame_W = 1
          let musicVoice1Frame_W = 1
          rem tail call
          goto PlayMusic bank15
CalculateMusicVoiceEnvelope
          asm
CalculateMusicVoiceEnvelope

end
          rem Helper: End of PlayMusic (label only)
          rem
          rem Input: None (label only)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal label for PlayMusic, marks end of
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
          rem Voice 1
          let temp2 = musicVoice1TotalFrames_R
          let temp3 = musicVoice1Frame_R
          let temp5 = musicVoice1TargetAUDV_R
          goto CMVE_CalcElapsed
CMVE_GetVoice0Vars
          rem Voice 0
          let temp2 = musicVoice0TotalFrames_R
          let temp3 = musicVoice0Frame_R
          let temp5 = musicVoice0TargetAUDV_R
CMVE_CalcElapsed
          rem Calculate frames elapsed = TotalFrames - FrameCounter
          let temp4 = temp2 - temp3
          rem Check if in attack phase (first NoteAttackFrames frames)
          if temp4 < NoteAttackFrames then CMVE_ApplyAttack
          rem Check if in decay phase (last NoteDecayFrames frames)
          if temp3 <= NoteDecayFrames then CMVE_ApplyDecay
          rem Sustain phase - use target AUDV (already set)
          return otherbank
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
          rem Check for wraparound: clamp to 0 if negative
          let temp6 = temp6 + temp4
          if temp6 & $80 then temp6 = 0
          rem Set voice-specific AUDV
          if temp6 > 15 then temp6 = 15
          if temp1 = 0 then let AUDV0 = temp6 : return otherbank
          let AUDV1 = temp6
          return otherbank
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
          rem Check for wraparound: clamp to 0 if negative
          let temp6 = temp6 - 1
          if temp6 & $80 then temp6 = 0
          rem Set voice-specific AUDV
          if temp6 > 15 then temp6 = 15
          if temp1 = 0 then let AUDV0 = temp6 : return otherbank
          let AUDV1 = temp6
          return otherbank
UpdateMusicVoice0
          asm
UpdateMusicVoice0

end
          rem
          rem Update Voice 0 playback (envelope, frame counter, note stepping).
          rem Input: musicVoice0Frame_R, musicVoice0Pointer (16-bit), currentSongID_R,
          rem        musicVoice0TotalFrames/TargetAUDV, NoteAttackFrames, NoteDecayFrames
          rem Output: Envelope applied, frame counter decremented, next note loaded when counter hits 0
          rem Mutates: temp1, temp4, musicVoice0Frame_W, musicVoice0Pointer
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
          rem Apply envelope using shared calculation
          let temp1 = 0
          rem Decrement frame counter
          gosub CalculateMusicVoiceEnvelope
          rem Fix RMW: Read from _R, modify, write to _W
          let temp4 = musicVoice0Frame_R - 1
          let musicVoice0Frame_W = temp4
          rem Frame counter reached 0 - load next note from appropriate
          if temp4 then return otherbank
          rem bank
          rem Check which bank this song is in (Bank 15: songs 0-Bank15MaxSongID, Bank
          rem 1: others)
          rem Song in Bank 15
          if currentSongID_R < Bank1MinSongID then gosub LoadMusicNote0Bank15 : return otherbank
          rem Song in Bank 1
          gosub LoadMusicNote0 bank1
          return otherbank
UpdateMusicVoice1
          asm
UpdateMusicVoice1

end
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
          rem musicVoice1TotalFrames, musicVoice1TargetAUDV (global) =
          rem envelope parameters, NoteAttackFrames, NoteDecayFrames
          rem (global constants) = envelope constants
          rem
          rem Output: Envelope applied, frame counter decremented, next
          rem note loaded when counter reaches 0
          rem
          rem Mutates: temp1 (used for voice number), temp5
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
          rem Apply envelope using shared calculation
          let temp1 = 1
          rem Decrement frame counter
          gosub CalculateMusicVoiceEnvelope
          rem Fix RMW: Read from _R, modify, write to _W
          let temp5 = musicVoice1Frame_R - 1
          let musicVoice1Frame_W = temp5
          rem Frame counter reached 0 - load next note from appropriate
          if temp5 then return otherbank
          rem bank
          rem Check which bank this song is in (Bank 15: songs 0-Bank15MaxSongID, Bank
          rem 1: others)
          rem Song in Bank 15
          if currentSongID_R < Bank1MinSongID then gosub LoadMusicNote1Bank15 : return otherbank
          rem Song in Bank 1
          gosub LoadMusicNote1 bank1
          return otherbank
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

          rem Reset frame counters
          let musicVoice0Frame_W = 0
          let musicVoice1Frame_W = 0
          return otherbank