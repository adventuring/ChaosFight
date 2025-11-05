          rem ChaosFight - Source/Routines/MusicBankHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem SONGS BANK HELPER FUNCTIONS
          rem ==========================================================
          rem These functions access song data tables and streams in
          rem   Bank 16
          rem ==========================================================
          
          #include "Source/Data/SongPointers.bas"
          
          rem Lookup song pointer from tables
          rem Input: temp1 = song ID (0-28)
          rem Output: SongPointerL, SongPointerH = pointer to
          rem   Song_Voice0 stream
LoadSongPointer
          dim LSP_songID = temp1
          rem Bounds check: 29 songs (0-28)
          if LSP_songID > 28 then let SongPointerH = 0 : return
          rem Use array access to lookup pointer
          let SongPointerL = SongPointersL[LSP_songID]
          let SongPointerH = SongPointersH[LSP_songID]
          return
          
          rem Lookup Voice 1 song pointer from tables
          rem Input: temp1 = song ID (0-28)
          rem Output: SongPointerL, SongPointerH = pointer to
          rem   Song_Voice1 stream
LoadSongVoice1Pointer
          dim LSV1P_songID = temp1
          rem Bounds check: 29 songs (0-28)
          if LSV1P_songID > 28 then let SongPointerH = 0 : return
          rem Use array access to lookup Voice 1 pointer directly
          let SongPointerL = SongPointersSecondL[LSV1P_songID]
          let SongPointerH = SongPointersSecondH[LSV1P_songID]
          return
          
          rem Load next note from Voice 0 stream using assembly for
          rem   pointer access
          rem Input: MusicVoice0PointerL/H points to current note in
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
          let MusicVoice0Frame_W = LMN0_duration + LMN0_delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (LMN0_audcv no longer needed) for pointer
          rem   calculation
          let temp2 = MusicVoice0PointerL
          let MusicVoice0PointerL = temp2 + 4
          if MusicVoice0PointerL < temp2 then let MusicVoice0PointerH = MusicVoice0PointerH + 1
          
          return
          
LoadMusicNote0EndOfTrack
          rem End of track reached - mark voice as inactive (pointerH = 0)
          rem Loop will be handled in UpdateMusic when both voices end (Chaotica
          rem   only)
          let MusicVoice0PointerH = 0
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
          let MusicVoice1Frame_W = LMN1_duration + LMN1_delay
          
          rem Advance pointer by 4 bytes
          rem Reuse temp2 (LMN1_audcv no longer needed) for pointer
          rem   calculation
          let temp2 = MusicVoice1PointerL
          let MusicVoice1PointerL = temp2 + 4
          if MusicVoice1PointerL < temp2 then let MusicVoice1PointerH = MusicVoice1PointerH + 1
          
          return
          
LoadMusicNote1EndOfTrack
          rem End of track reached - mark voice as inactive (pointerH = 0)
          rem Loop will be handled in UpdateMusic when both voices end (Chaotica
          rem   only)
          let MusicVoice1PointerH = 0
          AUDV1 = 0
          return
