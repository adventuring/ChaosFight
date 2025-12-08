          ;;
;;; ChaosFight - Source/Routines/MusicBankHelpers15.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Songs Bank Helper Functions (bank 15)
          ;; These functions access song data tables and streams in
          ;; Bank 15
          ;; Duplicate of MusicBankHelpers.bas but for Bank 15 songs

LoadSongPointerBank15
;; LoadSongPointerBank15 (duplicate)
          ;; Lookup song pointer from tables (Bank 15 songs: 0-Bank14MaxSongID)
          ;;
          ;; Input: temp1 = song ID (Bank 15 songs: 0-Bank14MaxSongID),
          ;; SongPointers2L[], SongPointers2H[] = pointer tables
          ;;
          ;; Output: songPointer = pointer to Song_Voice0 stream
          ;;
          ;; Mutates: temp1-temp2, songPointer
          ;;
          ;; Constraints: Only songs 0-Bank14MaxSongID live in Bank 15. Index mapping:
          ;; song ID maps directly (index = songID). Returns songPointer = 0 if song not in this bank.
          ;; Bounds check: only songs 0-Bank14MaxSongID reside in Bank 15
          ;; ;; if temp1 < 0 then goto LSP15_InvalidSong          lda temp1          cmp 0          bcs .skip_6825          jmp
          lda temp1
          cmp # 0
          bcs skip_8245
          MBH15_goto_label:

          jmp goto_label
skip_8245:

          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bcs skip_8387 (duplicate)
          ;; jmp goto_label (duplicate)
skip_8387:

          
          ;; ;; if temp1 > Bank14MaxSongID then goto LSP15_InvalidSong
          ;; lda temp1 (duplicate)
          sec
          sbc Bank14MaxSongID
          bcc skip_6412
          beq skip_6412
          ;; jmp LSP15_InvalidSong (duplicate)
skip_6412:

          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc Bank14MaxSongID (duplicate)
          ;; bcc skip_5367 (duplicate)
          ;; beq skip_5367 (duplicate)
          ;; jmp LSP15_InvalidSong (duplicate)
skip_5367:


          ;; Calculate compact index: index = songID
          ;; lda temp1 (duplicate)
          sta temp2
          ;; Fix: Assign directly to high/low bytes instead of broken × 256 multiplication
                    ;; let var40 = SongPointers2H[temp2]          lda temp2          asl          tax          lda SongPointers2H,x          sta var40
                    ;; let songPointer = SongPointers2L[temp2]
          ;; lda temp2 (duplicate)
          asl
          tax
          ;; lda SongPointers2L,x (duplicate)
          ;; sta songPointer (duplicate)
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SongPointers2L,x (duplicate)
          ;; sta songPointer (duplicate)
          ;; LoadSongPointerBank15 is called from StartMusic which is called cross-bank
          ;; Therefore it must always use return thisbank, even when called same-bank
          rts
LSP15_InvalidSong
          ;; lda # 0 (duplicate)
          ;; sta songPointer (duplicate)
          ;; LoadSongPointerBank15 is called from StartMusic which is called cross-bank
          ;; Therefore it must always use return thisbank, even when called same-bank
          ;; rts (duplicate)
LoadSongVoice1PointerBank15
;; LoadSongVoice1PointerBank15 (duplicate)

          ;; Lookup Voice 1 song pointer from tables (Bank 15 songs)
          ;;
          ;; Input: temp1 = song ID (Bank 15 songs: 0-Bank14MaxSongID),
          ;; SongPointers2SecondL[], SongPointers2SecondH[] (global
          ;; data tables) = Voice 1 song pointer tables
          ;;
          ;; Output: songPointer = pointer to Song_Voice1 stream
          ;;
          ;; Mutates: temp1-temp2 (used for calculations), songPointer
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Only songs 0-Bank14MaxSongID are in Bank 15. Index mapping:
          ;; song ID maps directly (index = songID). Returns songPointer = 0 if song not in this bank
          ;; Bounds check: Only songs 0-Bank14MaxSongID are in Bank 15
          ;; rts (duplicate)
          ;; rts (duplicate)
          ;; Calculate compact index: index = songID
          ;; lda temp1 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Fix: Assign directly to high/low bytes instead of broken × 256 multiplication
                    ;; let var40 = SongPointers2SecondH[temp2]          lda temp2          asl          tax          lda SongPointers2SecondH,x          sta var40
                    ;; let songPointer = SongPointers2SecondL[temp2]
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SongPointers2SecondL,x (duplicate)
          ;; sta songPointer (duplicate)
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SongPointers2SecondL,x (duplicate)
          ;; sta songPointer (duplicate)
          ;; LoadSongVoice1PointerBank15 is called from StartMusic which is called cross-bank
          ;; Therefore it must always use return thisbank, even when called same-bank
          ;; rts (duplicate)
LoadMusicNote0Bank15
;; LoadMusicNote0Bank15 (duplicate)

          ;; Load next note from Voice 0 stream (Bank 15, assembly pointer access).
          ;; Input: musicVoice0Pointer (global 16-bit) = current Song_Voice0 pointer
          ;; Output: Updates AUDC0_1/AUDF0_1/AUDV0_1, stores envelope parameters, advances pointer
          ;;
          ;; Mutates: temp2-temp6 (used for calculations), AUDC0_1,
          ;; AUDF0_1, AUDV0_1 (TIA registers) = sound registers (updated),
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
            ;; lda (musicVoice0Pointer),y  ; Load AUDCV (duplicate)
            ;; sta temp2 (duplicate)
            iny
            ;; lda (musicVoice0Pointer),y  ; Load AUDF (duplicate)
            ;; sta temp3 (duplicate)
            ;; iny (duplicate)
            ;; lda (musicVoice0Pointer),y  ; Load Duration (duplicate)
            ;; sta temp4 (duplicate)
            ;; iny (duplicate)
            ;; lda (musicVoice0Pointer),y  ; Load Delay (duplicate)
            ;; sta temp5 (duplicate)

          ;; Check for end of track (Duration = 0)
          ;; rts (duplicate)

          ;; Extract AUDC (upper 4 bits) and AUDV (lower 4 bits) from AUDCV
                    ;; let temp6 = temp2 & %11110000
                    ;; let temp6 = temp6 / 16
          ;; lda temp6 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)
                    ;; let musicVoice0TargetAUDV_W = temp2 & %00001111
          ;; lda temp2 (duplicate)
          and # 15
          ;; sta musicVoice0TargetAUDV_W (duplicate)

          ;; Store target AUDV and total frames for envelope
                    ;; let musicVoice0TotalFrames_W = temp4 + temp5
          ;; lda temp4 (duplicate)
          clc
          adc temp5
          ;; sta musicVoice0TotalFrames_W (duplicate)

          ;; Write to TIA registers (will be adjusted by envelope in
          ;; UpdateMusicVoice0)
          AUDC0_1:= temp6
          AUDF0_1:= temp3
          AUDV0_1:= musicVoice0TargetAUDV_R

                    ;; let musicVoice0Frame_W = temp4 + temp5
          ;; lda temp4 (duplicate)
          ;; clc (duplicate)
          ;; adc temp5 (duplicate)
          ;; sta musicVoice0Frame_W (duplicate)
          ;; Set frame counter = Duration + Delay

          ;; Advance pointer by 4 bytes (16-bit addition)
          ;; lda musicVoice0Pointer (duplicate)
          ;; clc (duplicate)
          ;; adc # 4 (duplicate)
          ;; sta musicVoice0Pointer (duplicate)

          ;; LoadMusicNote0Bank15 is called from UpdateMusicVoice0 which is reached via cross-bank call
          ;; (PlayMusic is called cross-bank from MainLoop). Therefore it must always use return thisbank.
          ;; rts (duplicate)
LoadMusicNote1Bank15
;; LoadMusicNote1Bank15 (duplicate)

          ;; Load next note from Voice 1 stream using assembly for pointer access (Bank 15)
          ;;
          ;; Input: musicVoice1Pointer (global 16-bit) =
          ;; pointer to current note in Song_Voice1 stream
          ;;
          ;; Output: TIA registers updated (AUDC1_1, AUDF1_1, AUDV1_1),
          ;; pointer advanced by 4 bytes, musicVoice1Frame set,
          ;; envelope parameters stored
          ;;
          ;; Mutates: temp2-temp6 (used for calculations), AUDC1_1,
          ;; AUDF1_1, AUDV1_1 (TIA registers) = sound registers (updated),
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
            ;; lda (musicVoice1Pointer),y  ; Load AUDCV (duplicate)
            ;; sta temp2 (duplicate)
            ;; iny (duplicate)
            ;; lda (musicVoice1Pointer),y  ; Load AUDF (duplicate)
            ;; sta temp3 (duplicate)
            ;; iny (duplicate)
            ;; lda (musicVoice1Pointer),y  ; Load Duration (duplicate)
            ;; sta temp4 (duplicate)
            ;; iny (duplicate)
            ;; lda (musicVoice1Pointer),y  ; Load Delay (duplicate)
            ;; sta temp5 (duplicate)

          ;; Check for end of track (Duration = 0)
          ;; rts (duplicate)

                    ;; let temp6 = temp2 & %11110000
          ;; Extract AUDC and AUDV
                    ;; let temp6 = temp6 / 16
          ;; lda temp6 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)
                    ;; let musicVoice1TargetAUDV_W = temp2 & %00001111
          ;; lda temp2 (duplicate)
          ;; and # 15 (duplicate)
          ;; sta musicVoice1TargetAUDV_W (duplicate)

          ;; Store target AUDV and total frames for envelope
                    ;; let musicVoice1TotalFrames_W = temp4 + temp5
          ;; lda temp4 (duplicate)
          ;; clc (duplicate)
          ;; adc temp5 (duplicate)
          ;; sta musicVoice1TotalFrames_W (duplicate)

          ;; Write to TIA registers (will be adjusted by envelope in
          ;; UpdateMusicVoice1)
          AUDC1_1:= temp6
          AUDF1_1:= temp3
          AUDV1_1:= musicVoice1TargetAUDV_R

                    ;; let musicVoice1Frame_W = temp4 + temp5
          ;; lda temp4 (duplicate)
          ;; clc (duplicate)
          ;; adc temp5 (duplicate)
          ;; sta musicVoice1Frame_W (duplicate)
          ;; Set frame counter = Duration + Delay

          ;; Advance pointer by 4 bytes
          ;; lda musicVoice1Pointer (duplicate)
          ;; clc (duplicate)
          ;; adc # 4 (duplicate)
          ;; sta musicVoice1Pointer (duplicate)

          ;; LoadMusicNote1Bank15 is called from UpdateMusicVoice1 which is reached via cross-bank call
          ;; (PlayMusic is called cross-bank from MainLoop). Therefore it must always use return thisbank.
          ;; rts (duplicate)


