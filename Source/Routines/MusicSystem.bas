          rem ChaosFight - Source/Routines/MusicSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem MUSIC SUBSYSTEM - Polyphony 2 Implementation
          rem ==========================================================
          rem Music system for publisher/author/title/winner screens
          rem   (gameMode 0-2, 7)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,
          rem   Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem High byte of pointer = 0 indicates voice inactive
          rem ==========================================================

          rem ==========================================================
          rem StartMusic - Initialize music playback
          rem ==========================================================
          rem Input: temp1 = song ID (0-255)
          rem Stops any current music and starts the specified song
          rem ==========================================================
StartMusic
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
          gosub bank16 LoadSongPointer
          gosub bank16 LoadSongVoice1Pointer
          goto LoadSongPointersDone
LoadSongFromBank15
          rem Song in Bank 15
          gosub bank15 LoadSongPointer
          gosub bank15 LoadSongVoice1Pointer
LoadSongPointersDone
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

          rem ==========================================================
          rem UpdateMusic - Update music playback each frame
          rem ==========================================================
          rem Called every frame from MainLoop for gameMode 0-2, 7
          rem Updates both voices if active (high byte ≠ 0)
          rem ==========================================================
UpdateMusic
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
          return

          rem ==========================================================
          rem SHARED MUSIC VOICE ENVELOPE CALCULATION
          rem ==========================================================
          rem Calculates envelope (attack/decay/sustain) for a music voice
          rem INPUT: temp1 = voice number (0 or 1)
          rem OUTPUT: Sets AUDV0 or AUDV1 based on voice
          rem Uses voice-specific variables based on temp1
CalculateMusicVoiceEnvelope
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
          rem Voice 0
          let CMVE_totalFrames = MusicVoice0TotalFrames
          let CMVE_frameCounter = musicVoice0Frame_R
          let CMVE_targetAUDV = MusicVoice0TargetAUDV
CMVE_CalcElapsed
          rem Calculate frames elapsed = TotalFrames - FrameCounter
          let CMVE_framesElapsed = CMVE_totalFrames - CMVE_frameCounter
          rem Check if in attack phase (first NoteAttackFrames frames)
          if CMVE_framesElapsed < NoteAttackFrames then CMVE_ApplyAttack
          rem Check if in decay phase (last NoteDecayFrames frames)
          if CMVE_frameCounter <= NoteDecayFrames then CMVE_ApplyDecay
          rem Sustain phase - use target AUDV (already set)
          return
CMVE_ApplyAttack
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
          let AUDV0 = CMVE_audv
          return
CMVE_ApplyDecay
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

          rem ==========================================================
          rem UpdateMusicVoice0 - Update Voice 0 playback
          rem ==========================================================
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
          rem ==========================================================
UpdateMusicVoice0
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
          if currentSongID_R = 1 then gosub bank15 LoadMusicNote0 : return
          if currentSongID_R = 2 then gosub bank15 LoadMusicNote0 : return
          rem Song in Bank 16
          gosub bank16 LoadMusicNote0
          return

          rem ==========================================================
          rem UpdateMusicVoice1 - Update Voice 1 playback
          rem ==========================================================
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
          rem ==========================================================
UpdateMusicVoice1
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
          if currentSongID_R = 1 then gosub bank15 LoadMusicNote1 : return
          if currentSongID_R = 2 then gosub bank15 LoadMusicNote1 : return
          rem Song in Bank 16
          gosub bank16 LoadMusicNote1
          return

          rem ==========================================================
          rem StopMusic - Stop all music playback
          rem ==========================================================
StopMusic
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

          rem ==========================================================
          rem StopMusic - Stop all music playback
          rem ==========================================================
StopMusic
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
