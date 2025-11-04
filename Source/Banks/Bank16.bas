          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          bank 16
          
          rem Music system - dedicated 3.5kiB bank for compiled samples
          #include "Source/Routines/MusicSystem.bas"
          
          rem =================================================================
          rem SONGS BANK HELPER FUNCTIONS
          rem =================================================================
          rem These functions access song data tables and streams in this bank
          rem =================================================================
          
          rem Song pointer lookup tables (populated with symbol addresses)
          rem Format: data SongPointersL, SongPointersH tables (5 entries: indices 0-4)
          rem Songs: 0=AtariToday, 1=Interworldly, 2=Title, 3=GameOver, 4=Victory
          data SongPointersL
          <Song_AtariToday_Voice0, <Song_Interworldly_Voice0, <Song_Title_Voice0, <Song_GameOver_Voice0, <Song_Victory_Voice0
          end
          data SongPointersH
          >Song_AtariToday_Voice0, >Song_Interworldly_Voice0, >Song_Title_Voice0, >Song_GameOver_Voice0, >Song_Victory_Voice0
          end
          
          rem Voice 1 stream offset table (bytes from Voice0 start to Voice1 start)
          rem Calculated as low byte of (Voice1 - Voice0) address difference
          rem Format: data SongVoice1Offsets (5 entries: indices 0-4)
          data SongVoice1Offsets
          <Song_AtariToday_Voice1 - <Song_AtariToday_Voice0, <Song_Interworldly_Voice1 - <Song_Interworldly_Voice0, <Song_Title_Voice1 - <Song_Title_Voice0, <Song_GameOver_Voice1 - <Song_GameOver_Voice0, <Song_Victory_Voice1 - <Song_Victory_Voice0
          end
          
          rem Lookup song pointer from tables
          rem Input: temp1 = song ID (0-4)
          rem Output: SongPointerL, SongPointerH = pointer to Song_Voice0 stream
LoadSongPointer
          rem Bounds check: only 5 songs (0-4)
          if temp1 > 4 then let SongPointerH = 0 : return
          rem Use array access to lookup pointer
          let SongPointerL = SongPointersL[temp1]
          let SongPointerH = SongPointersH[temp1]
          return
          
          rem Load next note from Voice 0 stream using assembly for pointer access
          rem Input: MusicVoice0PointerL/H points to current note in Song_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets MusicVoice0Frame
LoadMusicNote0
          asm
          ; Load 4 bytes from stream[pointer]
          ldy #0
          lda (MusicVoice0PointerL),y  ; Load AUDCV
          sta temp2
          iny
          lda (MusicVoice0PointerL),y  ; Load AUDF
          sta temp3
          iny
          lda (MusicVoice0PointerL),y  ; Load Duration
          sta temp4
          iny
          lda (MusicVoice0PointerL),y  ; Load Delay
          sta temp5
          end
          
          rem Check for end of track (Duration = 0)
          if temp4 = 0 then let MusicVoice0PointerH = 0 : AUDV0 = 0 : return
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
          temp6 = temp2 & %11110000
          temp6 = temp6 / 16
          temp7 = temp2 & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice0TargetAUDV = temp7
          let MusicVoice0TotalFrames = temp4 + temp5
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice0)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = temp7
          
          rem Set frame counter = Duration + Delay
          let MusicVoice0Frame = temp4 + temp5
          
          rem Advance pointer by 4 bytes (16-bit addition)
          let temp2 = MusicVoice0PointerL
          let MusicVoice0PointerL = temp2 + 4
          if MusicVoice0PointerL < temp2 then let MusicVoice0PointerH = MusicVoice0PointerH + 1
          
          return
          
          rem Load next note from Voice 1 stream
LoadMusicNote1
          asm
          ; Load 4 bytes from stream[pointer]
          ldy #0
          lda (MusicVoice1PointerL),y  ; Load AUDCV
          sta temp2
          iny
          lda (MusicVoice1PointerL),y  ; Load AUDF
          sta temp3
          iny
          lda (MusicVoice1PointerL),y  ; Load Duration
          sta temp4
          iny
          lda (MusicVoice1PointerL),y  ; Load Delay
          sta temp5
          end
          
          rem Check for end of track (Duration = 0)
          if temp4 = 0 then let MusicVoice1PointerH = 0 : AUDV1 = 0 : return
          
          rem Extract AUDC and AUDV
          temp6 = temp2 & %11110000
          temp6 = temp6 / 16
          temp7 = temp2 & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice1TargetAUDV = temp7
          let MusicVoice1TotalFrames = temp4 + temp5
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice1)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = temp7
          
          rem Set frame counter = Duration + Delay
          let MusicVoice1Frame = temp4 + temp5
          
          rem Advance pointer by 4 bytes
          temp2 = MusicVoice1PointerL
          let MusicVoice1PointerL = temp2 + 4
          if MusicVoice1PointerL < temp2 then let MusicVoice1PointerH = MusicVoice1PointerH + 1
          
          return
          
          rem =================================================================
          rem SONG DATA (Generated by SkylineTool)
          rem =================================================================
          rem Note: Pointer tables must be updated with actual addresses after compilation
          rem Songs are indexed: 0=AtariToday, 1=Interworldly, 2=Title, 3=GameOver, 4=Victory
          
          rem Song 0: AtariToday (Publisher preamble)
          #ifdef TV_NTSC
          #include "Source/Generated/Song.AtariToday.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Song.AtariToday.PAL.bas"
          #endif
          
          rem Song 1: Interworldly (Author preamble)
          #ifdef TV_NTSC
          #include "Source/Generated/Song.Interworldly.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Song.Interworldly.PAL.bas"
          #endif
          
          rem Song 2: Title (Title screen)
          #ifdef TV_NTSC
          #include "Source/Generated/Song.Title.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Song.Title.PAL.bas"
          #endif
          
          rem Song 3: GameOver (Defeat screen)
          #ifdef TV_NTSC
          #include "Source/Generated/Song.GameOver.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Song.GameOver.PAL.bas"
          #endif
          
          rem Song 4: Victory (Win screen)
          #ifdef TV_NTSC
          #include "Source/Generated/Song.Victory.NTSC.bas"
          #else
          rem PAL or SECAM: Use PAL version for both
          #include "Source/Generated/Song.Victory.PAL.bas"
          #endif