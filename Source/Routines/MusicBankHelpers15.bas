          rem
          rem ChaosFight - Source/Routines/MusicBankHelpers15.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Songs Bank Helper Functions (bank 15)
          rem These functions access song data tables and streams in
          rem   Bank 15
          rem Duplicate of MusicBankHelpers.bas but for Bank 15 songs
          
LoadSongPointer
          rem Lookup song pointer from tables (Bank 15 songs: 1-2 only)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 1-2 only),
          rem        SongPointersL15[], SongPointersH15[] = pointer tables
          rem
          rem Output: SongPointerL, SongPointerH = pointer to Song_Voice0 stream
          rem
          rem Mutates: temp1-temp2, SongPointerL, SongPointerH
          rem
          rem Constraints: Only songs 1-2 live in Bank 15. Index mapping:
          rem song 1 → index 0, song 2 → index 1. Returns SongPointerH = 0 if song not in this bank.
          rem Bounds check: only songs 1-2 reside in Bank 15
          if temp1 < 1 then goto LSP15_InvalidSong
          if temp1 > 2 then goto LSP15_InvalidSong
          rem Calculate compact index: songID - 1 (song 1→0, song 2→1)
          let temp2 = temp1 - 1
          let SongPointerL = SongPointersL15[temp2] : rem Use array access to lookup pointer
          let SongPointerH = SongPointersH15[temp2]
          return

LSP15_InvalidSong
          let SongPointerH = 0
          return
          
LoadSongVoice1Pointer
          rem Lookup Voice 1 song pointer from tables (Bank 15 songs)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 1-2 only)
          rem
          rem Output: SongPointerL, SongPointerH = pointer to
          rem   Song_Voice1 stream
          rem Index mapping: song 1 → index 0, song 2 → index 1
          rem Lookup Voice 1 song pointer from tables (Bank 15 songs:
          rem 1-2 only)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 1-2 only),
          rem SongPointersSecondL15[], SongPointersSecondH15[] (global
          rem data tables) = Voice 1 song pointer tables
          rem
          rem Output: SongPointerL, SongPointerH = pointer to
          rem Song_Voice1 stream
          rem
          rem Mutates: temp1-temp2 (used for calculations),
          rem SongPointerL, SongPointerH (global) = song pointer (set
          rem from Voice 1 tables)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only songs 1-2 are in Bank 15. Index mapping:
          rem song 1 → index 0, song 2 → index 1. Returns SongPointerH =
          rem 0 if song not in this bank
          dim LSV1P_songID = temp1
          rem Bounds check: Only songs 1-2 are in Bank 15
          if LSV1P_songID < 1 then let SongPointerH = 0 : return
          if LSV1P_songID > 2 then let SongPointerH = 0 : return
          dim LSV1P_index = temp2 : rem Calculate compact index: songID - 1 (song 1→0, song 2→1)
          let LSV1P_index = LSV1P_songID - 1
          let SongPointerL = SongPointersSecondL15[LSV1P_index] : rem Use array access to lookup Voice 1 pointer directly
          let SongPointerH = SongPointersSecondH15[LSV1P_index]
          return
          
LoadMusicNote0
          rem Load next note from Voice 0 stream using assembly for
          rem   pointer access
          rem
          rem Input: musicVoice0PointerL/H points to current note in
          rem   Song_Voice0 stream
          rem
          rem Output: Updates TIA registers, advances pointer, sets
          rem   MusicVoice0Frame
          rem Load next note from Voice 0 stream using assembly for
          rem pointer access (Bank 15)
          rem
          rem Input: musicVoice0PointerL, musicVoice0PointerH (global) =
          rem pointer to current note in Song_Voice0 stream
          rem
          rem Output: TIA registers updated (AUDC0, AUDF0, AUDV0),
          rem pointer advanced by 4 bytes, MusicVoice0Frame set,
          rem envelope parameters stored
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC0,
          rem AUDF0, AUDV0 (TIA registers) = sound registers (updated),
          rem MusicVoice0TargetAUDV, MusicVoice0TotalFrames (global) =
          rem envelope parameters (stored), musicVoice0Frame_W (global
          rem SCRAM) = frame counter (set to Duration + Delay),
          rem musicVoice0PointerL, musicVoice0PointerH (global) = voice
          rem pointer (advanced by 4 bytes)
          rem
          rem Called Routines: LoadMusicNote0EndOfTrack - handles end of
          rem track
          rem
          rem Constraints: Loads 4-byte note format: AUDCV (packed
          rem AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          rem bits) and AUDV (lower 4 bits) from AUDCV. End of track
          rem marked by Duration = 0. Chaotica loop handled in
          rem UpdateMusic when both voices end
          dim LMN0_audcv = temp2
          dim LMN0_audf = temp3
          dim LMN0_duration = temp4
          dim LMN0_delay = temp5
          dim LMN0_audc = temp6
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
          let LMN0_audc = LMN0_audcv & %11110000 : rem   AUDCV
          let LMN0_audc = LMN0_audc / 16
          let MusicVoice0TargetAUDV = LMN0_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope
          let MusicVoice0TotalFrames = LMN0_duration + LMN0_delay
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice0)
          AUDC0 = LMN0_audc
          AUDF0 = LMN0_audf
          AUDV0 = MusicVoice0TargetAUDV
          
          let musicVoice0Frame_W = LMN0_duration + LMN0_delay : rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (LMN0_audcv no longer needed) for pointer
          let temp2 = musicVoice0PointerL : rem   calculation
          let musicVoice0PointerL = temp2 + 4
          if musicVoice0PointerL < temp2 then let musicVoice0PointerH = musicVoice0PointerH + 1
          
          return
          
LoadMusicNote0EndOfTrack
          rem Helper: Handle end of track for Voice 0 (Bank 15)
          rem
          rem Input: None
          rem
          rem Output: Voice 0 marked as inactive, volume zeroed
          rem
          rem Mutates: musicVoice0PointerH (global) = voice pointer (set
          rem to 0), AUDV0 (TIA register) = sound volume (set to 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for LoadMusicNote0, only
          rem called when Duration = 0. Chaotica loop handled in
          rem UpdateMusic when both voices end
          rem End of track reached - mark voice as inactive (pointerH =
          rem 0)
          rem   (Chaotica
          rem Loop will be handled in UpdateMusic when both voices end
          let musicVoice0PointerH = 0 : rem   only)
          AUDV0 = 0
          return
          
LoadMusicNote1
          rem Load next note from Voice 1 stream
          rem Load next note from Voice 1 stream using assembly for
          rem pointer access (Bank 15)
          rem
          rem Input: musicVoice1PointerL, musicVoice1PointerH (global) =
          rem pointer to current note in Song_Voice1 stream
          rem
          rem Output: TIA registers updated (AUDC1, AUDF1, AUDV1),
          rem pointer advanced by 4 bytes, MusicVoice1Frame set,
          rem envelope parameters stored
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC1,
          rem AUDF1, AUDV1 (TIA registers) = sound registers (updated),
          rem MusicVoice1TargetAUDV, MusicVoice1TotalFrames (global) =
          rem envelope parameters (stored), musicVoice1Frame_W (global
          rem SCRAM) = frame counter (set to Duration + Delay),
          rem musicVoice1PointerL, musicVoice1PointerH (global) = voice
          rem pointer (advanced by 4 bytes)
          rem
          rem Called Routines: LoadMusicNote1EndOfTrack - handles end of
          rem track
          rem
          rem Constraints: Loads 4-byte note format: AUDCV (packed
          rem AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4
          rem bits) and AUDV (lower 4 bits) from AUDCV. End of track
          rem marked by Duration = 0. Chaotica loop handled in
          rem UpdateMusic when both voices end
          dim LMN1_audcv = temp2
          dim LMN1_audf = temp3
          dim LMN1_duration = temp4
          dim LMN1_delay = temp5
          dim LMN1_audc = temp6
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
          
          let LMN1_audc = LMN1_audcv & %11110000 : rem Extract AUDC and AUDV
          let LMN1_audc = LMN1_audc / 16
          let MusicVoice1TargetAUDV = LMN1_audcv & %00001111
          
          rem Store target AUDV and total frames for envelope
          let MusicVoice1TotalFrames = LMN1_duration + LMN1_delay
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice1)
          AUDC1 = LMN1_audc
          AUDF1 = LMN1_audf
          AUDV1 = MusicVoice1TargetAUDV
          
          let musicVoice1Frame_W = LMN1_duration + LMN1_delay : rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes
          rem Reuse temp2 (LMN1_audcv no longer needed) for pointer
          let temp2 = musicVoice1PointerL : rem   calculation
          let musicVoice1PointerL = temp2 + 4
          if musicVoice1PointerL < temp2 then let musicVoice1PointerH = musicVoice1PointerH + 1
          
          return
          
LoadMusicNote1EndOfTrack
          rem Helper: Handle end of track for Voice 1 (Bank 15)
          rem
          rem Input: None
          rem
          rem Output: Voice 1 marked as inactive, volume zeroed
          rem
          rem Mutates: musicVoice1PointerH (global) = voice pointer (set
          rem to 0), AUDV1 (TIA register) = sound volume (set to 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for LoadMusicNote1, only
          rem called when Duration = 0. Chaotica loop handled in
          rem UpdateMusic when both voices end
          rem End of track reached - mark voice as inactive (pointerH =
          rem 0)
          rem   (Chaotica
          rem Loop will be handled in UpdateMusic when both voices end
          let musicVoice1PointerH = 0 : rem   only)
          AUDV1 = 0
          return

