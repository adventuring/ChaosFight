          rem
          rem ChaosFight - Source/Routines/MusicBankHelpers15.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Songs Bank Helper Functions (bank 15)
          rem These functions access song data tables and streams in
          rem   Bank 15
          rem Duplicate of MusicBankHelpers.bas but for Bank 15 songs
          
LoadSongPointer
          rem Lookup song pointer from tables (Bank 15 songs: 0-3)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 0-3),
          rem        SongPointers2L[], SongPointers2H[] = pointer tables
          rem
          rem Output: SongPointerL, SongPointerH = pointer to Song_Voice0 stream
          rem
          rem Mutates: temp1-temp2, SongPointerL, SongPointerH
          rem
          rem Constraints: Only songs 0-3 live in Bank 15. Index mapping:
          rem song ID maps directly (index = songID). Returns SongPointerH = 0 if song not in this bank.
          rem Bounds check: only songs 0-3 reside in Bank 15
          if temp1 < 0 then goto LSP15_InvalidSong
          if temp1 > 3 then goto LSP15_InvalidSong
          rem Calculate compact index: index = songID
          let temp2 = temp1
          let SongPointerL = SongPointers2L[temp2] : rem Use array access to lookup pointer
          let SongPointerH = SongPointers2H[temp2]
          return

LSP15_InvalidSong
          let SongPointerH = 0
          return
          
LoadSongVoice1Pointer
          rem Lookup Voice 1 song pointer from tables (Bank 15 songs)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 0-3)
          rem
          rem Output: SongPointerL, SongPointerH = pointer to
          rem   Song_Voice1 stream
          rem Index mapping: song ID maps directly (index = songID)
          rem Lookup Voice 1 song pointer from tables (Bank 15 songs:
          rem 0-3)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 0-3),
          rem SongPointers2SecondL[], SongPointers2SecondH[] (global
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
          rem Constraints: Only songs 0-3 are in Bank 15. Index mapping:
          rem song ID maps directly (index = songID). Returns SongPointerH =
          rem 0 if song not in this bank
          rem Bounds check: Only songs 0-3 are in Bank 15
          if temp1 < 0 then let SongPointerH = 0 : return
          if temp1 > 3 then let SongPointerH = 0 : return
          rem Calculate compact index: index = songID
          let temp2 = temp1
          let SongPointerL = SongPointers2SecondL[temp2] : rem Use array access to lookup Voice 1 pointer directly
          let SongPointerH = SongPointers2SecondH[temp2]
          return
          
LoadMusicNote0
          rem Load next note from Voice 0 stream (Bank 15, assembly pointer access).
          rem Input: musicVoice0PointerL/H (global) = current Song_Voice0 pointer
          rem Output: Updates AUDC0/AUDF0/AUDV0, stores envelope parameters, advances pointer
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
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (musicVoice0PointerL),y  ; Load AUDCV
            sta temp2
            iny
            lda (musicVoice0PointerL),y  ; Load AUDF
            sta temp3
            iny
            lda (musicVoice0PointerL),y  ; Load Duration
            sta temp4
            iny
            lda (musicVoice0PointerL),y  ; Load Delay
            sta temp5
end
          
          rem Check for end of track (Duration = 0)
          if temp4 = 0 then LoadMusicNote0EndOfTrack
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          let temp6 = temp2 & %11110000 : rem   AUDCV
          let temp6 = temp6 / 16
          let MusicVoice0TargetAUDV_W = temp2 & %00001111
          
          rem Store target AUDV and total frames for envelope
          let MusicVoice0TotalFrames_W = temp4 + temp5
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice0)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = MusicVoice0TargetAUDV_R
          
          let musicVoice0Frame_W = temp4 + temp5 : rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          rem Reuse temp2 (temp2 no longer needed) for pointer
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
          asm
            ; Load 4 bytes from stream[pointer]
            ldy #0
            lda (musicVoice1PointerL),y  ; Load AUDCV
            sta temp2
            iny
            lda (musicVoice1PointerL),y  ; Load AUDF
            sta temp3
            iny
            lda (musicVoice1PointerL),y  ; Load Duration
            sta temp4
            iny
            lda (musicVoice1PointerL),y  ; Load Delay
            sta temp5
end
          
          rem Check for end of track (Duration = 0)
          if temp4 = 0 then LoadMusicNote1EndOfTrack
          
          let temp6 = temp2 & %11110000 : rem Extract AUDC and AUDV
          let temp6 = temp6 / 16
          let MusicVoice1TargetAUDV_W = temp2 & %00001111
          
          rem Store target AUDV and total frames for envelope
          let MusicVoice1TotalFrames_W = temp4 + temp5
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice1)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = MusicVoice1TargetAUDV_R
          
          let musicVoice1Frame_W = temp4 + temp5 : rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes
          rem Reuse temp2 (temp2 no longer needed) for pointer
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

