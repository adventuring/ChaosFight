          rem
          rem ChaosFight - Source/Routines/MusicBankHelpers15.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Songs Bank Helper Functions (bank 15)
          rem These functions access song data tables and streams in
          rem   Bank 15
          rem Duplicate of MusicBankHelpers.bas but for Bank 15 songs

LoadSongPointerBank15
          asm
LoadSongPointerBank15
end
          rem Lookup song pointer from tables (Bank 15 songs: 0-Bank15MaxSongID)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 0-Bank15MaxSongID),
          rem        SongPointers2L[], SongPointers2H[] = pointer tables
          rem
          rem Output: songPointer = pointer to Song_Voice0 stream
          rem
          rem Mutates: temp1-temp2, songPointer
          rem
          rem Constraints: Only songs 0-Bank15MaxSongID live in Bank 15. Index mapping:
          rem song ID maps directly (index = songID). Returns songPointer = 0 if song not in this bank.
          rem Bounds check: only songs 0-Bank15MaxSongID reside in Bank 15
          if temp1 < 0 then goto LSP15_InvalidSong
          if temp1 > Bank15MaxSongID then goto LSP15_InvalidSong
          rem Calculate compact index: index = songID
          let temp2 = temp1
          rem Fix: Assign directly to high/low bytes instead of broken * 256 multiplication
          let var40 = SongPointers2H[temp2]
          let songPointer = SongPointers2L[temp2]
          rem LoadSongPointerBank15 is called from StartMusic which is called cross-bank
          rem Therefore it must always use return otherbank, even when called same-bank
          return otherbank
LSP15_InvalidSong
          let songPointer = 0
          rem LoadSongPointerBank15 is called from StartMusic which is called cross-bank
          rem Therefore it must always use return otherbank, even when called same-bank
          return otherbank
LoadSongVoice1PointerBank15
          asm
LoadSongVoice1PointerBank15

end
          rem Lookup Voice 1 song pointer from tables (Bank 15 songs)
          rem
          rem Input: temp1 = song ID (Bank 15 songs: 0-Bank15MaxSongID),
          rem SongPointers2SecondL[], SongPointers2SecondH[] (global
          rem data tables) = Voice 1 song pointer tables
          rem
          rem Output: songPointer = pointer to Song_Voice1 stream
          rem
          rem Mutates: temp1-temp2 (used for calculations), songPointer
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only songs 0-Bank15MaxSongID are in Bank 15. Index mapping:
          rem song ID maps directly (index = songID). Returns songPointer = 0 if song not in this bank
          rem Bounds check: Only songs 0-Bank15MaxSongID are in Bank 15
          if temp1 < 0 then let songPointer = 0 : return otherbank
          if temp1 > Bank15MaxSongID then let songPointer = 0 : return otherbank
          rem Calculate compact index: index = songID
          let temp2 = temp1
          rem Fix: Assign directly to high/low bytes instead of broken * 256 multiplication
          let var40 = SongPointers2SecondH[temp2]
          let songPointer = SongPointers2SecondL[temp2]
          rem LoadSongVoice1PointerBank15 is called from StartMusic which is called cross-bank
          rem Therefore it must always use return otherbank, even when called same-bank
          return otherbank
LoadMusicNote0Bank15
          asm
LoadMusicNote0Bank15

end
          rem Load next note from Voice 0 stream (Bank 15, assembly pointer access).
          rem Input: musicVoice0Pointer (global 16-bit) = current Song_Voice0 pointer
          rem Output: Updates AUDC0/AUDF0/AUDV0, stores envelope parameters, advances pointer
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC0,
          rem AUDF0, AUDV0 (TIA registers) = sound registers (updated),
          rem musicVoice0TargetAUDV, musicVoice0TotalFrames (global) =
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
          rem PlayMusic when both voices end
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
          if temp4 = 0 then let musicVoice0Pointer = 0 : AUDV0 = 0 : return otherbank

          rem Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
          let temp6 = temp2 & %11110000
          let temp6 = temp6 / 16
          let musicVoice0TargetAUDV_W = temp2 & %00001111

          rem Store target AUDV and total frames for envelope
          let musicVoice0TotalFrames_W = temp4 + temp5

          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice0)
          AUDC0 = temp6
          AUDF0 = temp3
          AUDV0 = musicVoice0TargetAUDV_R

          let musicVoice0Frame_W = temp4 + temp5
          rem Set frame counter = Duration + Delay

          rem Advance pointer by 4 bytes (16-bit addition)
          let musicVoice0Pointer = musicVoice0Pointer + 4

          rem LoadMusicNote0Bank15 is called from UpdateMusicVoice0 which is reached via cross-bank call
          rem (PlayMusic is called cross-bank from MainLoop). Therefore it must always use return otherbank.
          return otherbank
LoadMusicNote1Bank15
          asm
LoadMusicNote1Bank15

end
          rem Load next note from Voice 1 stream using assembly for pointer access (Bank 15)
          rem
          rem Input: musicVoice1Pointer (global 16-bit) =
          rem pointer to current note in Song_Voice1 stream
          rem
          rem Output: TIA registers updated (AUDC1, AUDF1, AUDV1),
          rem pointer advanced by 4 bytes, musicVoice1Frame set,
          rem envelope parameters stored
          rem
          rem Mutates: temp2-temp6 (used for calculations), AUDC1,
          rem AUDF1, AUDV1 (TIA registers) = sound registers (updated),
          rem musicVoice1TargetAUDV, musicVoice1TotalFrames (global) =
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
          rem PlayMusic when both voices end
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
          if temp4 = 0 then let musicVoice1Pointer = 0 : AUDV1 = 0 : return otherbank

          let temp6 = temp2 & %11110000
          rem Extract AUDC and AUDV
          let temp6 = temp6 / 16
          let musicVoice1TargetAUDV_W = temp2 & %00001111

          rem Store target AUDV and total frames for envelope
          let musicVoice1TotalFrames_W = temp4 + temp5

          rem Write to TIA registers (will be adjusted by envelope in
          rem   UpdateMusicVoice1)
          AUDC1 = temp6
          AUDF1 = temp3
          AUDV1 = musicVoice1TargetAUDV_R

          let musicVoice1Frame_W = temp4 + temp5
          rem Set frame counter = Duration + Delay

          rem Advance pointer by 4 bytes
          let musicVoice1Pointer = musicVoice1Pointer + 4

          rem LoadMusicNote1Bank15 is called from UpdateMusicVoice1 which is reached via cross-bank call
          rem (PlayMusic is called cross-bank from MainLoop). Therefore it must always use return otherbank.
          return otherbank
