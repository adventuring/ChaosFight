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
          MusicVoice0PointerH = 0
          MusicVoice1PointerH = 0
          
          rem Lookup song pointer from Songs bank
          rem Note: SongPointerL/H tables are in Songs bank
          rem For now, assume Songs bank provides helper function
          gosub bankX LoadSongPointer
          rem LoadSongPointer will set SongPointerL and SongPointerH from temp1
          
          rem Set Voice 0 pointer to song start
          MusicVoice0PointerL = SongPointerL
          MusicVoice0PointerH = SongPointerH
          
          rem Calculate Voice 1 pointer offset (Voice 0 stream length calculated separately)
          rem For now, assume helper function calculates Voice 1 offset
          gosub bankX LoadSongVoice1Pointer
          rem LoadSongVoice1Pointer will set Voice 1 pointer based on Voice 0 + offset
          MusicVoice1PointerL = SongPointerL
          MusicVoice1PointerH = SongPointerH
          
          rem Initialize frame counters to trigger first note load
          MusicVoice0Frame = 1
          MusicVoice1Frame = 1
          
          rem Start first notes
          gosub UpdateMusic
          return

          rem =================================================================
          rem UpdateMusic - Update music playback each frame
          rem =================================================================
          rem Called every frame from MainLoop for gameMode 0-2, 7
          rem Updates both voices if active (high byte != 0)
          rem =================================================================
UpdateMusic
          rem Update Voice 0 if active
          if MusicVoice0PointerH != 0 then gosub UpdateMusicVoice0
          
          rem Update Voice 1 if active
          if MusicVoice1PointerH != 0 then gosub UpdateMusicVoice1
          return

          rem =================================================================
          rem UpdateMusicVoice0 - Update Voice 0 playback
          rem =================================================================
          rem Decrements frame counter, loads new note when counter reaches 0
          rem =================================================================
UpdateMusicVoice0
          rem Decrement frame counter
          MusicVoice0Frame = MusicVoice0Frame - 1
          if MusicVoice0Frame != 0 then return
          
          rem Frame counter reached 0 - load next note
          rem Switch to Songs bank to access data stream
          gosub bankX LoadMusicNote0
          rem LoadMusicNote0 will:
          rem   - Load 4-byte note from stream[pointer]: AUDCV, AUDF, Duration, Delay
          rem   - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          rem   - Write to TIA: AUDC0, AUDF0, AUDV0
          rem   - Set MusicVoice0Frame = Duration
          rem   - Advance MusicVoice0Pointer by 4 bytes
          rem   - Handle end-of-track: set MusicVoice0PointerH = 0, AUDV0 = 0
          return

          rem =================================================================
          rem UpdateMusicVoice1 - Update Voice 1 playback
          rem =================================================================
UpdateMusicVoice1
          rem Decrement frame counter
          MusicVoice1Frame = MusicVoice1Frame - 1
          if MusicVoice1Frame != 0 then return
          
          rem Frame counter reached 0 - load next note
          gosub bankX LoadMusicNote1
          rem LoadMusicNote1 does same as LoadMusicNote0 but for Voice 1
          return

          rem =================================================================
          rem StopMusic - Stop all music playback
          rem =================================================================
StopMusic
          rem Zero TIA volumes
          AUDV0 = 0
          AUDV1 = 0
          
          rem Clear voice pointers (high byte = 0 means inactive)
          MusicVoice0PointerH = 0
          MusicVoice1PointerH = 0
          
          rem Reset frame counters
          MusicVoice0Frame = 0
          MusicVoice1Frame = 0
          return
