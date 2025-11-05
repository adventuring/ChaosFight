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
          
          rem Lookup song pointer from Songs bank (Bank16)
          rem Note: songPointerL/H tables are in Songs bank
          gosub bank16 LoadSongPointer
          rem LoadSongPointer will set songPointerL and songPointerH
          rem   from temp1
          
          rem Set Voice 0 pointer to song start (Song_Voice0 stream)
          let musicVoice0PointerL = songPointerL
          let musicVoice0PointerH = songPointerH
          
          rem Store initial pointers for looping (Chaotica only)
          let musicVoice0StartPointerL_W = songPointerL
          let musicVoice0StartPointerH_W = songPointerH
          
          rem Calculate Voice 1 pointer offset (find end of Voice0
          rem   stream)
          rem Voice1 stream starts after Voice0 stream
          gosub bank16 LoadSongVoice1Pointer
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
          rem UpdateMusicVoice0 - Update Voice 0 playback
          rem ==========================================================
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
          rem ==========================================================
UpdateMusicVoice0
          rem Apply envelope to AUDV based on current frame position
          rem Calculate frames elapsed = TotalFrames - FrameCounter
          rem   (before decrement)
          temp1 = MusicVoice0TotalFrames
          temp2 = musicVoice0Frame_R
          temp3 = temp1 - temp2
          rem temp3 = frames elapsed (0-based, first frame is 0)
          
          rem Check if in attack phase (first NoteAttackFrames frames)
          if temp3 < NoteAttackFrames then goto ApplyAttack0
          
          rem Check if in decay phase (last NoteDecayFrames frames)
          if musicVoice0Frame_R <= NoteDecayFrames then goto ApplyDecay0
          
          rem Sustain phase - use target AUDV (already set)
          goto AfterEnvelope0
          
ApplyAttack0
          rem Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          rem First frame (elapsed=0): AUDV = Target - 4 + 0 = Target -
          rem   4
          rem Second frame (elapsed=1): AUDV = Target - 4 + 1 = Target -
          rem   3
          rem Third frame (elapsed=2): AUDV = Target - 4 + 2 = Target -
          rem   2
          rem Fourth frame (elapsed=3): AUDV = Target - 4 + 3 = Target -
          rem   1
          rem Fifth frame (elapsed=4): AUDV = Target - 4 + 4 = Target
          rem   (handled as sustain)
          temp4 = MusicVoice0TargetAUDV
          temp4 = temp4 - NoteAttackFrames
          temp4 = temp4 + temp3
          rem Check for wraparound: if subtraction resulted in negative, clamp to 0 (values ≥ 128 are negative in two's complement)
          if temp4 & $80 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV0 = temp4
          goto AfterEnvelope0
          
ApplyDecay0
          rem Decay: AUDV = Target - (NoteDecayFrames - FrameCounter +
          rem   1)
          rem When FrameCounter = 3: AUDV = Target - (3 - 3 + 1) =
          rem   Target - 1
          rem When FrameCounter = 2: AUDV = Target - (3 - 2 + 1) =
          rem   Target - 2
          rem When FrameCounter = 1: AUDV = Target - (3 - 1 + 1) =
          rem   Target - 3
          temp4 = MusicVoice0TargetAUDV
          temp4 = temp4 - NoteDecayFrames
          temp4 = temp4 + musicVoice0Frame_R
          temp4 = temp4 - 1
          rem Check for wraparound: if subtraction resulted in negative, clamp to 0 (values ≥ 128 are negative in two's complement)
          if temp4 & $80 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV0 = temp4
          
AfterEnvelope0
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let MS_frameCount = musicVoice0Frame_R - 1
          let musicVoice0Frame_W = MS_frameCount
          if MS_frameCount then return
          
          rem Frame counter reached 0 - load next note from Songs bank
          gosub bank16 LoadMusicNote0
          rem LoadMusicNote0 will:
          rem - Load 4-byte note from Song_Voice0[pointer]: AUDCV, AUDF,
          rem   Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Store target AUDV and total frames for envelope
          rem   - Write to TIA: AUDC0, AUDF0, AUDV0
          rem   - Set MusicVoice0Frame = Duration + Delay
          rem   - Advance MusicVoice0Pointer by 4 bytes
          rem - Handle end-of-track: set musicVoice0PointerH = 0, AUDV0
          rem   = 0
          return

          rem ==========================================================
          rem UpdateMusicVoice1 - Update Voice 1 playback
          rem ==========================================================
          rem Applies envelope (attack/decay), decrements frame counter,
          rem   loads new note when counter reaches 0
          rem ==========================================================
UpdateMusicVoice1
          rem Apply envelope to AUDV based on current frame position
          rem Calculate frames elapsed = TotalFrames - FrameCounter
          rem   (before decrement)
          temp1 = MusicVoice1TotalFrames
          temp2 = musicVoice1Frame_R
          temp3 = temp1 - temp2
          rem temp3 = frames elapsed (0-based, first frame is 0)
          
          rem Check if in attack phase (first NoteAttackFrames frames)
          if temp3 < NoteAttackFrames then goto ApplyAttack1
          
          rem Check if in decay phase (last NoteDecayFrames frames)
          if musicVoice1Frame_R <= NoteDecayFrames then goto ApplyDecay1
          
          rem Sustain phase - use target AUDV (already set)
          goto AfterEnvelope1
          
ApplyAttack1
          rem Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          rem First frame (elapsed=0): AUDV = Target - 4 + 0 = Target -
          rem   4
          rem Second frame (elapsed=1): AUDV = Target - 4 + 1 = Target -
          rem   3
          rem Third frame (elapsed=2): AUDV = Target - 4 + 2 = Target -
          rem   2
          rem Fourth frame (elapsed=3): AUDV = Target - 4 + 3 = Target -
          rem   1
          temp4 = MusicVoice1TargetAUDV
          temp4 = temp4 - NoteAttackFrames
          temp4 = temp4 + temp3
          rem Check for wraparound: if subtraction resulted in negative, clamp to 0 (values ≥ 128 are negative in two's complement)
          if temp4 & $80 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV1 = temp4
          goto AfterEnvelope1
          
ApplyDecay1
          rem Decay: AUDV = Target - (NoteDecayFrames - FrameCounter +
          rem   1)
          temp4 = MusicVoice1TargetAUDV
          temp4 = temp4 - NoteDecayFrames
          temp4 = temp4 + musicVoice1Frame_R
          temp4 = temp4 - 1
          rem Check for wraparound: if subtraction resulted in negative, clamp to 0 (values ≥ 128 are negative in two's complement)
          if temp4 & $80 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV1 = temp4
          
AfterEnvelope1
          rem Decrement frame counter
          rem Fix RMW: Read from _R, modify, write to _W
          let MS_frameCount1 = musicVoice1Frame_R - 1
          let musicVoice1Frame_W = MS_frameCount1
          if MS_frameCount1 then return
          
          rem Frame counter reached 0 - load next note from Songs bank
          gosub bank16 LoadMusicNote1
          rem LoadMusicNote1 does same as LoadMusicNote0 but for Voice 1
          rem   (Song_Voice1)
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
