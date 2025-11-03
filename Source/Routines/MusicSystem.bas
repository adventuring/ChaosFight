          rem ChaosFight - Source/Routines/MusicSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem MUSIC SUBSYSTEM - Polyphony 2 Implementation
          rem =================================================================
          rem Music system for publisher/author/title/winner screens (gameMode 0-2, 7)
          rem Uses interleaved 4-byte streams: AUDCV, AUDF, Duration, Delay
          rem AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          rem High byte of pointer = 0 indicates voice inactive
          rem =================================================================

          rem =================================================================
          rem StartMusic - Initialize music playback
          rem =================================================================
          rem Input: temp1 = song ID (0-255)
          rem Stops any current music and starts the specified song
          rem =================================================================
StartMusic
          rem Stop any current music
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let MusicVoice0PointerH = 0
          let MusicVoice1PointerH = 0
          
          rem Lookup song pointer from Songs bank (Bank16)
          rem Note: SongPointerL/H tables are in Songs bank
          gosub bank16 LoadSongPointer
          rem LoadSongPointer will set SongPointerL and SongPointerH from temp1
          
          rem Set Voice 0 pointer to song start (Song_Voice0 stream)
          let MusicVoice0PointerL = SongPointerL
          let MusicVoice0PointerH = SongPointerH
          
          rem Calculate Voice 1 pointer offset (find end of Voice0 stream)
          rem Voice1 stream starts after Voice0 stream
          gosub bank16 LoadSongVoice1Pointer
          rem LoadSongVoice1Pointer will calculate and set Voice 1 pointer
          let MusicVoice1PointerL = SongPointerL
          let MusicVoice1PointerH = SongPointerH
          
          rem Initialize frame counters to trigger first note load
          let MusicVoice0Frame = 1
          let MusicVoice1Frame = 1
          
          rem Start first notes
          rem tail call
          goto UpdateMusic

          rem =================================================================
          rem UpdateMusic - Update music playback each frame
          rem =================================================================
          rem Called every frame from MainLoop for gameMode 0-2, 7
          rem Updates both voices if active (high byte ≠ 0)
          rem =================================================================
UpdateMusic
          rem Update Voice 0 if active
          if MusicVoice0PointerH then gosub UpdateMusicVoice0
          
          rem Update Voice 1 if active
          if MusicVoice1PointerH then gosub UpdateMusicVoice1
          return

          rem =================================================================
          rem UpdateMusicVoice0 - Update Voice 0 playback
          rem =================================================================
          rem Applies envelope (attack/decay), decrements frame counter, loads new note when counter reaches 0
          rem =================================================================
UpdateMusicVoice0
          rem Apply envelope to AUDV based on current frame position
          rem Calculate frames elapsed = TotalFrames - FrameCounter (before decrement)
          temp1 = MusicVoice0TotalFrames
          temp2 = MusicVoice0Frame
          temp3 = temp1 - temp2
          rem temp3 = frames elapsed (0-based, first frame is 0)
          
          rem Check if in attack phase (first NoteAttackFrames frames)
          if temp3 < NoteAttackFrames then goto ApplyAttack0
          
          rem Check if in decay phase (last NoteDecayFrames frames)
          if MusicVoice0Frame <= NoteDecayFrames then goto ApplyDecay0
          
          rem Sustain phase - use target AUDV (already set)
          goto AfterEnvelope0
          
ApplyAttack0
          rem Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          rem First frame (elapsed=0): AUDV = Target - 4 + 0 = Target - 4
          rem Second frame (elapsed=1): AUDV = Target - 4 + 1 = Target - 3
          rem Third frame (elapsed=2): AUDV = Target - 4 + 2 = Target - 2
          rem Fourth frame (elapsed=3): AUDV = Target - 4 + 3 = Target - 1
          rem Fifth frame (elapsed=4): AUDV = Target - 4 + 4 = Target (handled as sustain)
          temp4 = MusicVoice0TargetAUDV
          temp4 = temp4 - NoteAttackFrames
          temp4 = temp4 + temp3
          if temp4 < 0 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV0 = temp4
          goto AfterEnvelope0
          
ApplyDecay0
          rem Decay: AUDV = Target - (NoteDecayFrames - FrameCounter + 1)
          rem When FrameCounter = 3: AUDV = Target - (3 - 3 + 1) = Target - 1
          rem When FrameCounter = 2: AUDV = Target - (3 - 2 + 1) = Target - 2
          rem When FrameCounter = 1: AUDV = Target - (3 - 1 + 1) = Target - 3
          temp4 = MusicVoice0TargetAUDV
          temp4 = temp4 - NoteDecayFrames
          temp4 = temp4 + MusicVoice0Frame
          temp4 = temp4 - 1
          if temp4 < 0 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV0 = temp4
          
AfterEnvelope0
          rem Decrement frame counter
          let MusicVoice0Frame = MusicVoice0Frame - 1
          if MusicVoice0Frame then return
          
          rem Frame counter reached 0 - load next note from Songs bank
          gosub bank16 LoadMusicNote0
          rem LoadMusicNote0 will:
          rem   - Load 4-byte note from Song_Voice0[pointer]: AUDCV, AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Store target AUDV and total frames for envelope
          rem   - Write to TIA: AUDC0, AUDF0, AUDV0
          rem   - Set MusicVoice0Frame = Duration + Delay
          rem   - Advance MusicVoice0Pointer by 4 bytes
          rem   - Handle end-of-track: set MusicVoice0PointerH = 0, AUDV0 = 0
          return

          rem =================================================================
          rem UpdateMusicVoice1 - Update Voice 1 playback
          rem =================================================================
          rem Applies envelope (attack/decay), decrements frame counter, loads new note when counter reaches 0
          rem =================================================================
UpdateMusicVoice1
          rem Apply envelope to AUDV based on current frame position
          rem Calculate frames elapsed = TotalFrames - FrameCounter (before decrement)
          temp1 = MusicVoice1TotalFrames
          temp2 = MusicVoice1Frame
          temp3 = temp1 - temp2
          rem temp3 = frames elapsed (0-based, first frame is 0)
          
          rem Check if in attack phase (first NoteAttackFrames frames)
          if temp3 < NoteAttackFrames then goto ApplyAttack1
          
          rem Check if in decay phase (last NoteDecayFrames frames)
          if MusicVoice1Frame <= NoteDecayFrames then goto ApplyDecay1
          
          rem Sustain phase - use target AUDV (already set)
          goto AfterEnvelope1
          
ApplyAttack1
          rem Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          rem First frame (elapsed=0): AUDV = Target - 4 + 0 = Target - 4
          rem Second frame (elapsed=1): AUDV = Target - 4 + 1 = Target - 3
          rem Third frame (elapsed=2): AUDV = Target - 4 + 2 = Target - 2
          rem Fourth frame (elapsed=3): AUDV = Target - 4 + 3 = Target - 1
          temp4 = MusicVoice1TargetAUDV
          temp4 = temp4 - NoteAttackFrames
          temp4 = temp4 + temp3
          if temp4 < 0 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV1 = temp4
          goto AfterEnvelope1
          
ApplyDecay1
          rem Decay: AUDV = Target - (NoteDecayFrames - FrameCounter + 1)
          temp4 = MusicVoice1TargetAUDV
          temp4 = temp4 - NoteDecayFrames
          temp4 = temp4 + MusicVoice1Frame
          temp4 = temp4 - 1
          if temp4 < 0 then temp4 = 0
          if temp4 > 15 then temp4 = 15
          AUDV1 = temp4
          
AfterEnvelope1
          rem Decrement frame counter
          let MusicVoice1Frame = MusicVoice1Frame - 1
          if MusicVoice1Frame then return
          
          rem Frame counter reached 0 - load next note from Songs bank
          gosub bank16 LoadMusicNote1
          rem LoadMusicNote1 does same as LoadMusicNote0 but for Voice 1 (Song_Voice1)
          return

          rem =================================================================
          rem StopMusic - Stop all music playback
          rem =================================================================
StopMusic
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          let MusicVoice0PointerH = 0
          let MusicVoice1PointerH = 0
          
          rem Reset frame counters
          let MusicVoice0Frame = 0
          let MusicVoice1Frame = 0
          return
