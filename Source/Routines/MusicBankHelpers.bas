          rem
          rem ChaosFight - Source/Routines/MusicBankHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem SONGS BANK HELPER FUNCTIONS (bank 1)
          rem These functions access song data tables and streams in
          rem   Bank 1 (primary symbols use “1” suffix; SongPointers1.bas
          rem   provides legacy aliases for the historical “16” labels)
          
LoadSongPointer
          rem Lookup 16-bit song pointer for Bank 1 songs.
          rem Input: temp1 = song ID (4-28), SongPointers1L[]/SongPointers1H[]
          rem Output: songPointer updated (points to Song_Voice0 stream)
          rem Mutates: temp1-temp2, songPointer
          rem Constraints: Songs 0-3 live in Bank 15; returns songPointer = 0 if out of range
          if temp1 > 28 then goto LSP_InvalidSong
          rem Check if songs handled by other banks (0-3)
          if temp1 < 4 then goto LSP_InvalidSong
          rem Calculate compact index: songID - 4 (song 4 → 0)
          let temp2 = temp1 - 4
LSP_Lookup
          rem Helper: Lookup pointer from tables and combine into 16-bit value
          rem
          rem Input: temp2 (local variable) = table index,
          rem SongPointers1L[], SongPointers1H[] (global data tables)
          rem = song pointer tables (residing in Bank 1)
          rem
          rem Output: songPointer set from tables
          rem
          rem Mutates: songPointer (global 16-bit) = song pointer (set from tables)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for LoadSongPointer
          let songPointer = SongPointers1H[temp2]
          let songPointer = songPointer * 256
          let songPointer = songPointer + SongPointers1L[temp2]
          return

LSP_InvalidSong
          let songPointer = 0
          return
          
LoadSongVoice1Pointer
          rem Lookup Voice 1 song pointer from tables (Bank 1 songs)
          rem
          rem Input: temp1 = song ID (Bank 1 songs: 4-28),
          rem SongPointers1SecondL[], SongPointers1SecondH[] (global
          rem data tables) = Voice 1 song pointer tables (Bank 1)
          rem
          rem Output: songPointer = pointer to Song_Voice1 stream
          rem
          rem Mutates: temp1-temp2 (used for calculations), songPointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only songs 4-28 are in Bank 1. Songs 0-3
          rem are in Bank 15. Index mapping: song 4 → index 0, songs
          rem 5-28 → indices 1-24. Returns songPointer = 0 if song not
          rem in this bank
          rem Bounds check: Only songs 4-28 are in Bank 1
          if temp1 > 28 then goto LSV1P_InvalidSong
          rem Check if songs handled by other banks (0-3)
          if temp1 < 4 then goto LSV1P_InvalidSong
          rem Calculate compact index: songID - 4 (song 4 → 0)
          let temp2 = temp1 - 4
LSV1P_Lookup
          rem Helper: Lookup Voice 1 pointer from tables
          rem
          rem Input: temp2 (local variable) = table index,
          rem SongPointers1SecondL[], SongPointers1SecondH[] (global
          rem data tables) = Voice 1 song pointer tables
          rem
          rem Output: songPointer set from Voice 1 tables
          rem
          rem Mutates: songPointer (global 16-bit) = song pointer (set from Voice 1 tables)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for LoadSongVoice1Pointer
          let songPointer = SongPointers1SecondH[temp2]
          let songPointer = songPointer * 256
          let songPointer = songPointer + SongPointers1SecondL[temp2]
          return

LSV1P_InvalidSong
          let songPointer = 0
          return
          
LoadMusicNote0
          rem Load next note from Voice 0 stream (assembly pointer access).
          rem Input: musicVoice0Pointer (global 16-bit) = current Song_Voice0 pointer
          rem Output: Updates AUDC0/AUDF0/AUDV0, stores envelope parameters, advances pointer
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC0,
          rem AUDF0, AUDV0 (TIA registers) = sound registers (updated),
          rem MusicVoice0TargetAUDV, MusicVoice0TotalFrames (global) =
          rem envelope parameters (stored), musicVoice0Frame_W (global
          rem SCRAM) = frame counter (set to Duration + Delay),
          rem musicVoice0Pointer (global 16-bit) = voice pointer (advanced by 4 bytes)
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
            lda (musicVoice0Pointer),y  ; Load AUDCV
            sta temp2
            iny
            lda (musicVoice0Pointer),y  ; Load AUDF
            sta temp3
            iny
            lda (musicVoice0Pointer),y  ; Load Duration
            sta temp4
            iny
            lda (musicVoice0Pointer),y  ; Load Delay
            sta temp5
end
          
          rem Check for end of track (Duration = 0)
          if temp4 = 0 then LoadMusicNote0EndOfTrack
          
          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from
          let temp6 = temp2 & %11110000
          rem   AUDCV
          let temp6 = temp6 / 16
          let MusicVoice0TargetAUDV_W = temp2 & %00001111
          
          rem Store target AUDV and total frames for envelope
          let MusicVoice0TotalFrames_W = temp4 + temp5
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice0)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = MusicVoice0TargetAUDV_R
          
          let musicVoice0Frame_W = temp4 + temp5
          rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes (16-bit addition)
          let musicVoice0Pointer = musicVoice0Pointer + 4
          
          return
          
LoadMusicNote0EndOfTrack
          rem Helper: Handle end of track for Voice 0
          rem
          rem Input: None
          rem
          rem Output: Voice 0 marked as inactive, volume zeroed
          rem
          rem Mutates: musicVoice0Pointer (global 16-bit) = voice pointer (set
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
          let musicVoice0Pointer = 0
          rem   only)
          AUDV0 = 0
          return
          
LoadMusicNote1
          rem Load next note from Voice 1 stream using assembly for pointer access
          rem
          rem Input: musicVoice1Pointer (global 16-bit) =
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
          rem musicVoice1Pointer (global 16-bit) = voice pointer (advanced by 4 bytes)
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
            lda (musicVoice1Pointer),y  ; Load AUDCV
            sta temp2
            iny
            lda (musicVoice1Pointer),y  ; Load AUDF
            sta temp3
            iny
            lda (musicVoice1Pointer),y  ; Load Duration
            sta temp4
            iny
            lda (musicVoice1Pointer),y  ; Load Delay
            sta temp5
end
          
          rem Check for end of track (Duration = 0)
          if temp4 = 0 then LoadMusicNote1EndOfTrack
          
          let temp6 = temp2 & %11110000
          rem Extract AUDC and AUDV
          let temp6 = temp6 / 16
          let MusicVoice1TargetAUDV_W = temp2 & %00001111
          
          rem Store target AUDV and total frames for envelope
          let MusicVoice1TotalFrames_W = temp4 + temp5
          
          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice1)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = MusicVoice1TargetAUDV_R
          
          let musicVoice1Frame_W = temp4 + temp5
          rem Set frame counter = Duration + Delay
          
          rem Advance pointer by 4 bytes
          let musicVoice1Pointer = musicVoice1Pointer + 4
          
          return
          
LoadMusicNote1EndOfTrack
          rem Helper: Handle end of track for Voice 1
          rem
          rem Input: None
          rem
          rem Output: Voice 1 marked as inactive, volume zeroed
          rem
          rem Mutates: musicVoice1Pointer (global 16-bit) = voice pointer (set
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
          let musicVoice1Pointer = 0
          rem   only)
          AUDV1 = 0
          return
