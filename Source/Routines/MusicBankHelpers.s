          ;;
;;; ChaosFight - Source/Routines/MusicBankHelpers.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



          ;; SONGS BANK HELPER FUNCTIONS (bank 1)

          ;; These functions access song data tables and streams in

          ;; Bank 1 (primary symbols use “1” suffix; SongPointers1.bas

          ;; provides legacy aliases for the historical “16” labels)



LoadSongPointer
          ;; Returns: Far (return otherbank)


          ;; Lookup 16-bit song pointer for Bank 1 songs.
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = song ID (Bank0MinSongID-28), SongPointers1L[]/SongPointers1H[]

          ;; Output: songPointer updated (points to Song_Voice0 stream)

          ;; Mutates: temp1-temp2, songPointer

          ;; Constraints: Songs 0-Bank14MaxSongID live in Bank 15; returns songPointer = 0 if out of range

          lda temp1
          cmp # 29
          bcc skip_6352
skip_6352:


          ;; Check if songs handled by other banks (0-Bank14MaxSongID)

          ;; if temp1 < Bank0MinSongID then goto LSP_InvalidSong
          lda temp1
          cmp Bank0MinSongID
          bcs skip_4480
          jmp LSP_InvalidSong
skip_4480:
          

          ;; Calculate compact index: songID - Bank0MinSongID (song Bank0MinSongID → 0)

          ;; let temp2 = temp1 - Bank0MinSongID          lda temp1          sec          sbc Bank0MinSongID          sta temp2
          lda temp1
          sec
          sbc Bank0MinSongID
          sta temp2

          lda temp1
          sec
          sbc Bank0MinSongID
          sta temp2


          ;; Lookup pointer from tables and combine into 16-bit value

          ;; Fix: Assign directly to high/low bytes instead of broken × 256 multiplication

          ;; let var40 = SongPointers1H[temp2]
          lda temp2
          asl
          tax
          lda SongPointers1H,x
          sta songPointer+1

          ;; let songPointer = SongPointers1L[temp2]
          lda temp2
          asl
          tax
          lda SongPointers1L,x
          sta songPointer
          lda temp2
          asl
          tax
          lda SongPointers1L,x
          sta songPointer

          jsr BS_return



LSP_InvalidSong
          ;; Returns: Far (return otherbank)

          lda # 0
          sta songPointer

          jsr BS_return



LoadSongVoice1PointerBank1
          ;; Returns: Far (return otherbank)




          ;; Lookup Voice 1 song pointer from tables (Bank 1 songs)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 = song ID (Bank 1 songs: Bank0MinSongID-28),

          ;; SongPointers1SecondL[], SongPointers1SecondH[] (global

          ;; data tables) = Voice 1 song pointer tables (Bank 1)

          ;;
          ;; Output: songPointer = pointer to Song_Voice1 stream

          ;;
          ;; Mutates: temp1-temp2 (used for calculations), songPointer

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Only songs Bank0MinSongID-28 are in Bank 1. Songs 0-Bank14MaxSongID

          ;; are in Bank 15. Index mapping: song Bank0MinSongID → index 0, songs

          ;; (Bank0MinSongID+1)-28 → indices 1-23. Returns songPointer = 0 if song not

          ;; in this bank

          ;; Bounds check: Only songs Bank0MinSongID-28 are in Bank 1

          lda temp1
          cmp # 29
          bcc skip_6043
skip_6043:


          ;; Check if songs handled by other banks (0-Bank14MaxSongID)

          ;; if temp1 < Bank0MinSongID then goto LSV1P_InvalidSong
          lda temp1
          cmp Bank0MinSongID
          bcs skip_9878
          jmp LSV1P_InvalidSong
skip_9878:
          

          ;; Calculate compact index: songID - Bank0MinSongID (song Bank0MinSongID → 0)

          ;; let temp2 = temp1 - Bank0MinSongID          lda temp1          sec          sbc Bank0MinSongID          sta temp2
          lda temp1
          sec
          sbc Bank0MinSongID
          sta temp2

          lda temp1
          sec
          sbc Bank0MinSongID
          sta temp2


          ;; Lookup Voice 1 pointer from tables

          ;; Fix: Assign directly to high/low bytes instead of broken × 256 multiplication

          ;; let var40 = SongPointers1SecondH[temp2]
          lda temp2
          asl
          tax
          lda SongPointers1SecondH,x
          sta songPointer+1

          ;; let songPointer = SongPointers1SecondL[temp2]
          lda temp2
          asl
          tax
          lda SongPointers1SecondL,x
          sta songPointer
          lda temp2
          asl
          tax
          lda SongPointers1SecondL,x
          sta songPointer

          jsr BS_return



LSV1P_InvalidSong
          ;; Returns: Far (return otherbank)

          lda # 0
          sta songPointer

          jsr BS_return




LoadMusicNote0 .proc


          ;; Load next note from Voice 0 stream (assembly pointer access).
          ;; Returns: Far (return otherbank)

          ;; Input: musicVoice0Pointer (global 16-bit) = current Song_Voice0 pointer

          ;; Output: Updates AUDC0/AUDF0/AUDV0, stores envelope parameters, advances pointer

          ;;
          ;; Mutates: temp2-temp6 (used for calculations), AUDC0,

          ;; AUDF0, AUDV0 (TIA registers) = sound registers (updated),

          ;; musicVoice0TargetAUDV, musicVoice0TotalFrames (global) =

          ;; envelope parameters (stored), musicVoice0Frame_W (global

          ;; SCRAM) = frame counter (set to Duration + Delay),

          ;; musicVoice0Pointer (global 16-bit) = voice pointer (advanced by 4 bytes)

          ;;
          ;; Called Routines: LoadMusicNote0EndOfTrack - handles end of

          ;; track

          ;;
          ;; Constraints: Loads 4-byte note format: AUDCV (packed

          ;; AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4

          ;; bits) and AUDV (lower 4 bits) from AUDCV. End of track

          ;; marked by Duration = 0. Chaotica loop handled in

          ;; PlayMusic when both voices end


          ;; TODO: ; Load 4 bytes from stream[pointer]

          ;; TODO: ldy #0

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




          ;; Check for end of track (Duration = 0)

          jsr BS_return



          ;; Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV

          ;; let temp6 = temp2 & %11110000

          ;; let temp6 = temp6 / 16
          lda temp6
          lsr
          lsr
          lsr
          lsr
          sta temp6

          ;; let musicVoice0TargetAUDV_W = temp2 & %00001111
          lda temp2
          and # 15
          sta musicVoice0TargetAUDV_W



          ;; Store target AUDV and total frames for envelope

          ;; let musicVoice0TotalFrames_W = temp4 + temp5
          lda temp4
          clc
          adc temp5
          sta musicVoice0TotalFrames_W



          ;; Write to TIA registers (will be adjusted by envelope in

          ;; UpdateMusicVoice0)

          AUDC0 = temp6

          AUDF0 = temp3

          AUDV0 = musicVoice0TargetAUDV_R



          ;; let musicVoice0Frame_W = temp4 + temp5
          lda temp4
          clc
          adc temp5
          sta musicVoice0Frame_W

          ;; Set frame counter = Duration + Delay



          ;; Advance pointer by 4 bytes (16-bit addition)
          lda musicVoice0Pointer
          clc
          adc # 4
          sta musicVoice0Pointer



          jsr BS_return



.pend

LoadMusicNote1 .proc


          ;; Load next note from Voice 1 stream using assembly for pointer access
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: musicVoice1Pointer (global 16-bit) =

          ;; pointer to current note in Song_Voice1 stream

          ;;
          ;; Output: TIA registers updated (AUDC1, AUDF1, AUDV1),

          ;; pointer advanced by 4 bytes, musicVoice1Frame set,

          ;; envelope parameters stored

          ;;
          ;; Mutates: temp2-temp6 (used for calculations), AUDC1,

          ;; AUDF1, AUDV1 (TIA registers) = sound registers (updated),

          ;; musicVoice1TargetAUDV, musicVoice1TotalFrames (global) =

          ;; envelope parameters (stored), musicVoice1Frame_W (global

          ;; SCRAM) = frame counter (set to Duration + Delay),

          ;; musicVoice1Pointer (global 16-bit) = voice pointer (advanced by 4 bytes)

          ;;
          ;; Called Routines: LoadMusicNote1EndOfTrack - handles end of

          ;; track

          ;;
          ;; Constraints: Loads 4-byte note format: AUDCV (packed

          ;; AUDC/AUDV), AUDF, Duration, Delay. Extracts AUDC (upper 4

          ;; bits) and AUDV (lower 4 bits) from AUDCV. End of track

          ;; marked by Duration = 0. Chaotica loop handled in

          ;; PlayMusic when both voices end


          ;; TODO: ; Load 4 bytes from stream[pointer]

          ;; TODO: ldy #0

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




          ;; Check for end of track (Duration = 0)

          jsr BS_return



          ;; Extract AUDC and AUDV

          ;; let temp6 = temp2 & %11110000

          ;; let temp6 = temp6 / 16
          lda temp6
          lsr
          lsr
          lsr
          lsr
          sta temp6

          ;; let musicVoice1TargetAUDV_W = temp2 & %00001111
          lda temp2
          and # 15
          sta musicVoice1TargetAUDV_W



          ;; Store target AUDV and total frames for envelope

          ;; let musicVoice1TotalFrames_W = temp4 + temp5
          lda temp4
          clc
          adc temp5
          sta musicVoice1TotalFrames_W



          ;; Write to TIA registers (will be adjusted by envelope in

          ;; UpdateMusicVoice1)

          AUDC1 = temp6

          AUDF1 = temp3

          AUDV1 = musicVoice1TargetAUDV_R



          ;; let musicVoice1Frame_W = temp4 + temp5
          lda temp4
          clc
          adc temp5
          sta musicVoice1Frame_W

          ;; Set frame counter = Duration + Delay



          ;; Advance pointer by 4 bytes
          lda musicVoice1Pointer
          clc
          adc # 4
          sta musicVoice1Pointer



          jsr BS_return

.pend

