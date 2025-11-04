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
          
          rem Voice 1 stream pointer lookup tables (populated with symbol addresses)
          rem Format: data SongPointersSecondL, SongPointersSecondH tables (5 entries: indices 0-4)
          data SongPointersSecondL
          <Song_AtariToday_Voice1, <Song_Interworldly_Voice1, <Song_Title_Voice1, <Song_GameOver_Voice1, <Song_Victory_Voice1
          end
          data SongPointersSecondH
          >Song_AtariToday_Voice1, >Song_Interworldly_Voice1, >Song_Title_Voice1, >Song_GameOver_Voice1, >Song_Victory_Voice1
          end
          
          rem Lookup song pointer from tables
          rem Input: temp1 = song ID (0-4)
          rem Output: SongPointerL, SongPointerH = pointer to Song_Voice0 stream
LoadSongPointer
          dim LSP_songID = temp1
          rem Bounds check: only 5 songs (0-4)
          if LSP_songID > 4 then let SongPointerH = 0 : return
          rem Use array access to lookup pointer
          let SongPointerL = SongPointersL[LSP_songID]
          let SongPointerH = SongPointersH[LSP_songID]
          return
          
          rem Lookup Voice 1 song pointer from tables
          rem Input: temp1 = song ID (0-4)
          rem Output: SongPointerL, SongPointerH = pointer to Song_Voice1 stream
LoadSongVoice1Pointer
          dim LSV1P_songID = temp1
          rem Bounds check: only 5 songs (0-4)
          if LSV1P_songID > 4 then let SongPointerH = 0 : return
          rem Use array access to lookup Voice 1 pointer directly
          let SongPointerL = SongPointersSecondL[LSV1P_songID]
          let SongPointerH = SongPointersSecondH[LSV1P_songID]
          return
          
          rem Load next note from Voice 0 stream using assembly for pointer access
          rem Input: MusicVoice0PointerL/H points to current note in Song_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets MusicVoice0Frame
LoadMusicNote0
          dim LMN0_audcv = temp2
          dim LMN0_audf = temp3
          dim LMN0_duration = temp4
          dim LMN0_delay = temp5
          dim LMN0_audc = temp6
          dim LMN0_audv = temp7
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
          if LMN0_duration = 0 then let MusicVoice0PointerH = 0 : AUDV0 = 0 : return
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
          LMN0_audc = LMN0_audcv & %11110000
          LMN0_audc = LMN0_audc / 16
          LMN0_audv = LMN0_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice0TargetAUDV = LMN0_audv
          let MusicVoice0TotalFrames = LMN0_duration + LMN0_delay
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice0)
          AUDC0 = LMN0_audc
          AUDF0 = LMN0_audf
          AUDV0 = LMN0_audv
          
          rem Set frame counter = Duration + Delay
          let MusicVoice0Frame = LMN0_duration + LMN0_delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          dim LMN0_pointerL_old = temp2
          let LMN0_pointerL_old = MusicVoice0PointerL
          let MusicVoice0PointerL = LMN0_pointerL_old + 4
          if MusicVoice0PointerL < LMN0_pointerL_old then let MusicVoice0PointerH = MusicVoice0PointerH + 1
          
          return
          
          rem Load next note from Voice 1 stream
LoadMusicNote1
          dim LMN1_audcv = temp2
          dim LMN1_audf = temp3
          dim LMN1_duration = temp4
          dim LMN1_delay = temp5
          dim LMN1_audc = temp6
          dim LMN1_audv = temp7
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
          if LMN1_duration = 0 then let MusicVoice1PointerH = 0 : AUDV1 = 0 : return
          
          rem Extract AUDC and AUDV
          LMN1_audc = LMN1_audcv & %11110000
          LMN1_audc = LMN1_audc / 16
          LMN1_audv = LMN1_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope calculation
          let MusicVoice1TargetAUDV = LMN1_audv
          let MusicVoice1TotalFrames = LMN1_duration + LMN1_delay
          
          rem Write to TIA registers (will be adjusted by envelope in UpdateMusicVoice1)
          AUDC1 = LMN1_audc
          AUDF1 = LMN1_audf
          AUDV1 = LMN1_audv
          
          rem Set frame counter = Duration + Delay
          let MusicVoice1Frame = LMN1_duration + LMN1_delay
          
          rem Advance pointer by 4 bytes
          dim LMN1_pointerL_old = temp2
          let LMN1_pointerL_old = MusicVoice1PointerL
          let MusicVoice1PointerL = LMN1_pointerL_old + 4
          if MusicVoice1PointerL < LMN1_pointerL_old then let MusicVoice1PointerH = MusicVoice1PointerH + 1
          
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