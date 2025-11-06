          rem ChaosFight - Source/Routines/MusicBankHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem SONGS BANK HELPER FUNCTIONS (BANK 16)
          rem ==========================================================
          rem These functions access song data tables and streams in
          rem   Bank 16
          rem ==========================================================
          
          #include "Source/Data/SongPointers16.bas"
          
          rem Lookup song pointer from tables (Bank 16 songs)
          rem Input: temp1 = song ID (Bank 16 songs: 0, 3-28)
          rem Output: SongPointerL, SongPointerH = pointer to
          rem   Song_Voice0 stream
          rem Index mapping: song 0 → index 0, songs 3-28 → indices 1-26
LoadSongPointer
          dim LSP_songID = temp1
          rem Bounds check: Only songs 0, 3-28 are in Bank 16
          if LSP_songID > 28 then let SongPointerH = 0 : return
          rem Check if song 1 or 2 (not in this bank)
          if LSP_songID = 1 then let SongPointerH = 0 : return
          if LSP_songID = 2 then let SongPointerH = 0 : return
          rem Calculate compact index: if songID = 0 then index = 0,
          rem   else index = songID - 2
          dim LSP_index = temp2
          if LSP_songID = 0 then LSP_IndexZero
          let LSP_index = LSP_songID - 2
          goto LSP_Lookup
LSP_IndexZero
          let LSP_index = 0
LSP_Lookup
          rem Use array access to lookup pointer
          let SongPointerL = SongPointersL16[LSP_index]
          let SongPointerH = SongPointersH16[LSP_index]
          return
          
          rem Lookup Voice 1 song pointer from tables (Bank 16 songs)
          rem Input: temp1 = song ID (Bank 16 songs: 0, 3-28)
          rem Output: SongPointerL, SongPointerH = pointer to
          rem   Song_Voice1 stream
          rem Index mapping: song 0 → index 0, songs 3-28 → indices 1-26
LoadSongVoice1Pointer
          dim LSV1P_songID = temp1
          rem Bounds check: Only songs 0, 3-28 are in Bank 16
          if LSV1P_songID > 28 then let SongPointerH = 0 : return
          rem Check if song 1 or 2 (not in this bank)
          if LSV1P_songID = 1 then let SongPointerH = 0 : return
          if LSV1P_songID = 2 then let SongPointerH = 0 : return
          rem Calculate compact index: if songID = 0 then index = 0,
          rem   else index = songID - 2
          dim LSV1P_index = temp2
          if LSV1P_songID = 0 then LSV1P_IndexZero
          let LSV1P_index = LSV1P_songID - 2
          goto LSV1P_Lookup
LSV1P_IndexZero
          let LSV1P_index = 0
LSV1P_Lookup
          rem Use array access to lookup Voice 1 pointer directly
          let SongPointerL = SongPointersSecondL16[LSV1P_index]
          let SongPointerH = SongPointersSecondH16[LSV1P_index]
          return
          
          rem Load next note from Voice 0 stream using assembly for
          rem   pointer access
          rem Input: musicVoice0PointerL/H points to current note in
          rem   Song_Voice0 stream
          rem Output: Updates TIA registers, advances pointer, sets
          rem   MusicVoice0Frame
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
            lda (musicVoice0PointerL),y  ; Load AUDCV
            sta LMN0_audcv
            iny
            lda (musicVoice0PointerL),y  ; Load AUDF
            sta LMN0_audf
            iny
            lda (musicVoice0PointerL),y  ; Load Duration
            sta LMN0_duration
            iny
            lda (musicVoice0PointerL),y  ; Load Delay
            sta LMN0_delay
end
          
          rem Check for end of track (Duration = 0)
          if LMN0_duration = 0 then LoadMusicNote0EndOfTrack
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          rem   AUDCV
          let LMN0_audc = LMN0_audcv & %11110000
          let LMN0_audc = LMN0_audc / 16
          let LMN0_audv = LMN0_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope
          rem   calculation
          let MusicVoice0TargetAUDV = LMN0_audv
          let MusicVoice0TotalFrames = LMN0_duration + LMN0_delay
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice0)
          AUDC0 = LMN0_audc
          AUDF0 = LMN0_audf
          AUDV0 = LMN0_audv
          
          rem Set frame counter = Duration + Delay
          let musicVoice0Frame_W = LMN0_duration + LMN0_delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (LMN0_audcv no longer needed) for pointer
          rem   calculation
          let temp2 = musicVoice0PointerL
          let musicVoice0PointerL = temp2 + 4
          if musicVoice0PointerL < temp2 then let musicVoice0PointerH = musicVoice0PointerH + 1
          
          return
          
LoadMusicNote0EndOfTrack
          rem End of track reached - mark voice as inactive (pointerH = 0)
          rem   (Chaotica
          rem Loop will be handled in UpdateMusic when both voices end
          rem   only)
          let musicVoice0PointerH = 0
          AUDV0 = 0
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
            lda (musicVoice1PointerL),y  ; Load AUDCV
            sta LMN1_audcv
            iny
            lda (musicVoice1PointerL),y  ; Load AUDF
            sta LMN1_audf
            iny
            lda (musicVoice1PointerL),y  ; Load Duration
            sta LMN1_duration
            iny
            lda (musicVoice1PointerL),y  ; Load Delay
            sta LMN1_delay
end
          
          rem Check for end of track (Duration = 0)
          if LMN1_duration = 0 then LoadMusicNote1EndOfTrack
          
          rem Extract AUDC and AUDV
          let LMN1_audc = LMN1_audcv & %11110000
          let LMN1_audc = LMN1_audc / 16
          let LMN1_audv = LMN1_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope
          rem   calculation
          let MusicVoice1TargetAUDV = LMN1_audv
          let MusicVoice1TotalFrames = LMN1_duration + LMN1_delay
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice1)
          AUDC1 = LMN1_audc
          AUDF1 = LMN1_audf
          AUDV1 = LMN1_audv
          
          rem Set frame counter = Duration + Delay
          let musicVoice1Frame_W = LMN1_duration + LMN1_delay
          
          rem Advance pointer by 4 bytes
          rem Reuse temp2 (LMN1_audcv no longer needed) for pointer
          rem   calculation
          let temp2 = musicVoice1PointerL
          let musicVoice1PointerL = temp2 + 4
          if musicVoice1PointerL < temp2 then let musicVoice1PointerH = musicVoice1PointerH + 1
          
          return
          
LoadMusicNote1EndOfTrack
          rem End of track reached - mark voice as inactive (pointerH = 0)
          rem   (Chaotica
          rem Loop will be handled in UpdateMusic when both voices end
          rem   only)
          let musicVoice1PointerH = 0
          AUDV1 = 0
          return

          rem   UpdateMusicVoice1)
          AUDC1 = LMN1_audc
          AUDF1 = LMN1_audf
          AUDV1 = LMN1_audv
          
          rem Set frame counter = Duration + Delay
          let musicVoice1Frame_W = LMN1_duration + LMN1_delay
          
          rem Advance pointer by 4 bytes
          rem Reuse temp2 (LMN1_audcv no longer needed) for pointer
          rem   calculation
          let temp2 = musicVoice1PointerL
          let musicVoice1PointerL = temp2 + 4
          if musicVoice1PointerL < temp2 then let musicVoice1PointerH = musicVoice1PointerH + 1
          
          return
          
LoadMusicNote1EndOfTrack
          rem End of track reached - mark voice as inactive (pointerH = 0)
          rem   (Chaotica
          rem Loop will be handled in UpdateMusic when both voices end
          rem   only)
          let musicVoice1PointerH = 0
          AUDV1 = 0
          return
