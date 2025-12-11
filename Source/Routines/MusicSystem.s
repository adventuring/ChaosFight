;;; ChaosFight - Source/Routines/MusicSystem.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



          ;; Local music-system scratch variables (using built-in temp4/temp5)




StartMusic .proc
          ;; MUSIC SUBSYSTEM - Polyphony 2 Implementation
          ;; Returns: Far (return otherbank)

          ;; Music system for publisher/author/title/winner screens

          ;; (gameMode 0-2, 7)

          ;; Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,

          ;;
          ;; Delay

          ;; AUDCV = (AUDC << 4) | AUDV (packed into single byte)

          ;; High byte of pointer = 0 indicates voice inactive

          ;; Startmusic - Initialize Music Playback

          ;;
          ;; Input: temp1 = song ID (0-255)

          ;; Stops any current music and starts the specified song

          ;; Initialize music playback (stops any current music and

          ;; starts the specified song)

          ;;
          ;; Input: temp1 = song ID (0-255)

          ;;
          ;; Output: Music started, voice pointers set, frame counters

          ;; initialized, first notes loaded

          ;;
          ;; Mutates: temp1 (used for song ID), AUDV0, AUDV1 (TIA

          ;; registers) = sound volumes (set to 0),

          ;; musicVoice0Pointer, musicVoice1Pointer (global 16-bit words)

          ;; = voice pointers (set to song start), musicVoice0StartPointer_W,

          ;; musicVoice1StartPointer_W (global SCRAM 16-bit) = start pointers

          ;; (stored for looping), currentSongID_W (global SCRAM) =

          ;; current song ID (stored), musicVoice0Frame_W,

          ;; musicVoice1Frame_W (global SCRAM) = frame counters (set to

          ;; 1)

          ;;
          ;; Called Routines: LoadSongPointer (bank15 or bank1) -

          ;; looks up song pointer, LoadSongVoice1PointerBank15 or

          ;; LoadSongVoice1PointerBank1 - calculates Voice 1 pointer, PlayMusic (tail

          ;; call via goto) - starts first notes

          ;;
          ;; Constraints: Songs in Bank 15: Bernie (0), OCascadia (1),

          ;; Revontuli (2), EXO (3), Grizzards (Bank14MaxSongID). All other songs (Bank0MinSongID-28) in Bank 1.

          ;; Routes to correct bank based on song ID

          ;; Stop any current music

          AUDV0 = 0

          AUDV1 = 0



          ;; Clear voice pointers (high byte = 0 means inactive)

          lda # 0
          sta musicVoice0Pointer

          lda # 0
          sta musicVoice1Pointer



          ;; Lookup song pointer from appropriate bank (Bank15 or

          ;; Bank1)

          ;; Songs in Bank 15: IDs 0-Bank14MaxSongID

          ;; Songs in Bank 1: All other songs (Bank0MinSongID-28)

          ;; Route to correct bank based on song ID

          ;; if temp1 < Bank0MinSongID then goto LoadSongFromBank15
          lda temp1
          cmp Bank0MinSongID
          bcs LoadSongFromBank1
          jmp LoadSongFromBank15
LoadSongFromBank1:

          

          ;; Song in Bank 1

          ;; Cross-bank call to LoadSongPointer in bank 1
          lda # >(AfterLoadSongPointer-1)
          pha
          lda # <(AfterLoadSongPointer-1)
          pha
          lda # >(LoadSongPointer-1)
          pha
          lda # <(LoadSongPointer-1)
          pha
                    ldx # 0
          jmp BS_jsr
AfterLoadSongPointer:


          ;; Cross-bank call to LoadSongVoice1PointerBank1 in bank 1
          lda # >(AfterLoadSongVoice1Pointer-1)
          pha
          lda # <(AfterLoadSongVoice1Pointer-1)
          pha
          lda # >(LoadSongVoice1PointerBank1-1)
          pha
          lda # <(LoadSongVoice1PointerBank1-1)
          pha
                    ldx # 0
          jmp BS_jsr
AfterLoadSongVoice1Pointer:


          jmp LoadSongPointersDone

LoadSongFromBank15

          ;; Song in Bank 15
          ;; Returns: Far (return otherbank)

          jsr LoadSongPointerBank15

          jsr LoadSongVoice1PointerBank15

LoadSongPointersDone

          ;; LoadSongPointer populated songPointer (16-bit)
          ;; Returns: Far (return otherbank)

          ;; Set Voice 0 pointer to song start (Song_Voice0 stream)

          ;; Store initial pointers for looping (Chaotica only)

          lda songPointer
          sta musicVoice0Pointer

          lda songPointer
          sta musicVoice0StartPointer_W



          ;; LoadSongVoice1PointerBank1/15 already called above

          ;; Voice 1 loader reused songPointer (16-bit) for Voice 1

          ;; Store initial Voice 1 pointer for looping (Chaotica only)

          lda songPointer
          sta musicVoice1Pointer

          lda songPointer
          sta musicVoice1StartPointer_W



          ;; Store current song ID for looping check

          lda temp1
          sta currentSongID_W



          ;; Initialize frame counters to trigger first note load

          lda # 1
          sta musicVoice0Frame_W

          lda # 1
          sta musicVoice1Frame_W



          ;; StartMusic is called via gosub from other banks, so must return otherbank

          ;; PlayMusic will be called every frame from MainLoop

          jmp BS_return



.pend

PlayMusic .proc


          ;;
          ;; Returns: Far (return otherbank)

          ;; PlayMusic - Play Music Each Frame

          ;; Called every frame from MainLoop for gameMode 0-2, 7

          ;; Updates both voices if active (high byte ≠ 0)

          ;; Update music playback each frame (called every frame from

          ;; MainLoop for gameMode 0-2, 7)

          ;;
          ;; Input: musicVoice0Pointer, musicVoice1Pointer (global 16-bit)

          ;; voice pointers, musicVoice0Frame_R, musicVoice1Frame_R

          ;; (global SCRAM) = frame counters, currentSongID_R (global

          ;; SCRAM) = current song ID, musicVoice0StartPointer_R,

          ;; musicVoice1StartPointer_R (global SCRAM 16-bit) = start pointers

          ;;
          ;; Output: Both voices updated if active (high byte ≠ 0),

          ;; Chaotica (song 26) loops when both voices end

          ;;
          ;; Mutates: All music voice state (via UpdateMusicVoice0 and

          ;; UpdateMusicVoice1), musicVoice0Pointer, musicVoice1Pointer

          ;; (global 16-bit) = voice pointers (reset to start for Chaotica

          ;; loop), musicVoice0Frame_W,

          ;; musicVoice1Frame_W (global SCRAM) = frame counters (reset

          ;; to 1 for Chaotica loop)

          ;;
          ;; Called Routines: UpdateMusicVoice0 - updates Voice 0 if

          ;; active, UpdateMusicVoice1 - updates Voice 1 if active

          ;;
          ;; Constraints: Called every frame from MainLoop for gameMode

          ;; 0-2, 7. Only Chaotica (song ID 26) loops - other songs

          ;; stop when both voices end

          ;; Update Voice 0 if active

          jsr UpdateMusicVoice0



          ;; Update Voice 1 if active



          jsr UpdateMusicVoice1



          ;; Check if both voices have ended (both pointerH = 0) and

          ;; song is Chaotica (26) for looping

          ;; Only Chaotica loops - other songs stop when both voices end

          ;; Voice 0 still active, no reset needed

          jmp BS_return

          ;; Voice 1 still active, no reset needed

          jmp BS_return

          ;; Both voices inactive - check if Chaotica (song ID 26)

          lda currentSongID_R
          cmp # 26
          bne PlayMusicDone
          jmp IsChaotica
PlayMusicDone:


          jmp BS_return

.pend

IsChaotica .proc

          ;; Both voices ended and song is Chaotica - reset to song head
          ;; Returns: Far (return otherbank)

          lda musicVoice0StartPointer_R
          sta musicVoice0Pointer

          lda musicVoice1StartPointer_R
          sta musicVoice1Pointer

          lda # 1
          sta musicVoice0Frame_W

          lda # 1
          sta musicVoice1Frame_W

          ;; tail call

          jmp PlayMusic

.pend

CalculateMusicVoiceEnvelope .proc




          ;; Helper: End of PlayMusic (label only)
          ;; Returns: Near (return thisbank) - called same-bank

          ;;
          ;; Input: None (label only)

          ;;
          ;; Output: None (label only)

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Internal label for PlayMusic, marks end of

          ;; update

          ;;
          ;; Shared Music Voice Envelope Calculation

          ;; Input: temp1 = voice number (0 or 1)

          ;; MusicVoiceXTotalFrames, musicVoiceXFrame_R, MusicVoiceXTargetAUDV,

          ;; NoteAttackFrames, NoteDecayFrames (indexed by voice)

          ;; Output: AUDV0 or AUDV1 set per envelope phase

          ;; Mutates: temp1-temp6, AUDV0, AUDV1

          ;; Constraints: Voice-specific data selected via temp1. Attack phase = first NoteAttackFrames frames,

          ;; last NoteDecayFrames frames. Sustain phase: uses target

          ;; AUDV. Clamps AUDV to 0-15

          ;; Get voice-specific variables

          lda temp1
          cmp # 0
          bne GetVoice1Vars
          jmp GetVoice0Vars
GetVoice1Vars:


          ;; Voice 1

          lda musicVoice1TotalFrames_R
          sta temp2

          lda musicVoice1Frame_R
          sta temp3

          lda musicVoice1TargetAUDV_R
          sta temp5

          jmp CalcElapsedFrames

.pend

GetVoice0Vars .proc

          ;; Voice 0
          ;; Returns: Far (return thisbank)

          lda musicVoice0TotalFrames_R
          sta temp2

          lda musicVoice0Frame_R
          sta temp3

          lda musicVoice0TargetAUDV_R
          sta temp5

          jmp CalcElapsedFrames

.pend

CalcElapsedFrames .proc

          ;; Calculate frames elapsed = TotalFrames - FrameCounter
          ;; Returns: Far (return thisbank)

          ;; let temp4 = temp2 - temp3          lda temp2          sec          sbc temp3          sta temp4
          lda temp2
          sec
          sbc temp3
          sta temp4

          lda temp2
          sec
          sbc temp3
          sta temp4


          ;; Check if in attack phase (first NoteAttackFrames frames)
          ;; if temp4 < NoteAttackFrames then ApplyAttackEnvelope
          lda temp4
          cmp # NoteAttackFrames
          bcs CheckDecayPhase
          jmp ApplyAttackEnvelope
CheckDecayPhase:

          ;; Check if in decay phase (last NoteDecayFrames frames)
          ;; if temp3 <= NoteDecayFrames then ApplyDecayEnvelope
          lda temp3
          sec
          sbc NoteDecayFrames
          bcc ApplyDecayEnvelope
          beq ApplyDecayEnvelope
          jmp ApplySustainEnvelope
ApplyDecayEnvelope:
ApplySustainEnvelope:

          ;; Sustain phase - use target AUDV (already set)

          rts

.pend

ApplyAttackEnvelope .proc

          ;; Helper: Applies attack envelope (ramps up volume)
          ;; Returns: Far (return thisbank)

          ;;
          ;; Input: temp5, temp4 (local

          ;; variables), temp1 (local variable), NoteAttackFrames

          ;; (global consta


          ;;
          ;; Output: AUDV set based on attack phase

          ;;
          ;; Mutates: temp6 (local variable), AUDV0, AUDV1 (TIA

          ;; registers) = sound volumes

          ;;
          ;; Called Routines: CMVE_SetAUDV0 - sets AUDV0

          ;;
          ;; Constraints: Internal helper for

          ;; CalculateMusicVoiceEnvelope, only called in attack phase.

          ;; Formula: AUDV = Target - NoteAttackFrames + frames_elapsed

          ;; Attack: AUDV = Target - NoteAttackFrames + frames_elapsed
          lda temp5
          sta temp6

          ;; let temp6 = temp6 - NoteAttackFrames          lda temp6          sec          sbc NoteAttackFrames          sta temp6
          lda temp6
          sec
          sbc NoteAttackFrames
          sta temp6

          lda temp6
          sec
          sbc NoteAttackFrames
          sta temp6


          ;; Check for wraparound: clamp to 0 if negative

          ;; let temp6 = temp6 + temp4

                    if temp6 & $80 then let temp6 = 0
          lda temp6
          and #$80
          beq ClampAUDV
          lda # 0
          sta temp6
ClampAUDV:

          ;; Set voice-specific AUDV
          lda temp6
          cmp # 16
          bcc SetAUDV
          lda # 15
          sta temp6
SetAUDV:


          rts

.pend

ApplyDecayEnvelope .proc

          ;; Helper: Applies decay envelope (ramps down volume)
          ;; Returns: Near (return thisbank) - called same-bank

          ;;
          ;; Input: temp5, temp3 (local

          ;; variables), temp1 (local variable), NoteDecayFrames

          ;; (global consta


          ;;
          ;; Output: AUDV set based on decay phase

          ;;
          ;; Mutates: temp6 (local variable), AUDV0, AUDV1 (TIA

          ;; registers) = sound volumes

          ;;
          ;; Called Routines: CMVE_SetAUDV0 - sets AUDV0

          ;;
          ;; Constraints: Internal helper for

          ;; CalculateMusicVoiceEnvelope, only called in decay phase.

          ;; Formula: AUDV = Target - (NoteDecayFrames - FrameCounter + 1)

          lda temp5
          sta temp6

          ;; let temp6 = temp6 - NoteDecayFrames          lda temp6          sec          sbc NoteDecayFrames          sta temp6
          lda temp6
          sec
          sbc NoteDecayFrames
          sta temp6

          lda temp6
          sec
          sbc NoteDecayFrames
          sta temp6


          ;; let temp6 = temp6 + temp3

          ;; Check for wraparound: clamp to 0 if negative

          dec temp6

                    if temp6 & $80 then let temp6 = 0
          lda temp6
          and #$80
          beq ClampAUDV
          lda # 0
          sta temp6
ClampAUDV:

          ;; Set voice-specific AUDV
          lda temp6
          cmp # 16
          bcc SetAUDV
          lda # 15
          sta temp6
SetAUDV:


          rts

.pend

UpdateMusicVoice0 .proc




          ;;
          ;; Returns: Far (return otherbank)

          ;; Update Voice 0 playback (envelope, frame counter, note stepping).

          ;; Input: musicVoice0Frame_R, musicVoice0Pointer (16-bit), currentSongID_R,

          ;; musicVoice0TotalFrames/TargetAUDV, NoteAttackFrames, NoteDecayFrames

          ;; Output: Envelope applied, frame counter decremented, next note loaded when counter hits 0

          ;; Mutates: temp1, temp4, musicVoice0Frame_W, musicVoice0Pointer

          ;; pointer (advanced via LoadMusicNote0), AUDC0, AUDF0, AUDV0

          ;; (TIA registers) = sound registers (updated via

          ;; LoadMusicNote0 and CalculateMusicVoiceEnvelope)

          ;;
          ;; Called Routines: CalculateMusicVoiceEnvelope - applies

          ;; attack/decay/sustain envelope, LoadMusicNote0 (bank15 or

          ;; bank1) - loads next 4-byte note, extracts AUDC/AUDV,

          ;; writes to TIA, advances pointer, handles end-of-song

          ;;
          ;; Constraints: Uses Voice 0 (AUDC0, AUDF0, AUDV0). Songs 0-Bank14MaxSongID

          ;; in Bank 15, all others in Bank 1. Routes to correct bank

          ;; based on currentSongID_R

          ;; Apply envelope using shared calculation

          lda # 0
          sta temp1

          ;; Decrement frame counter

          jsr CalculateMusicVoiceEnvelope

          ;; Fix RMW: Read from _R, modify, write to _W

          lda musicVoice0Frame_R
          sec
          sbc # 1
          sta temp4

          lda temp4
          sta musicVoice0Frame_W

          ;; Frame counter reached 0 - load next note from appropriate

          rts

          ;; bank

          ;; Check which bank this song is in (Bank 15: songs 0-Bank14MaxSongID, Bank

          ;; 1: others)

          ;; Song in Bank 15

          jsr LoadMusicNote0Bank15

          ;; Song in Bank 1

          ;; Cross-bank call to LoadMusicNote0 in bank 1
          lda # >(AfterLoadMusicNote0Bank1-1)
          pha
          lda # <(AfterLoadMusicNote0Bank1-1)
          pha
          lda # >(LoadMusicNote0-1)
          pha
          lda # <(LoadMusicNote0-1)
          pha
                    ldx # 0
          jmp BS_jsr
AfterLoadMusicNote0Bank1:


          rts

.pend

UpdateMusicVoice1 .proc




          ;;
          ;; Returns: Far (return otherbank)

          ;; Updatemusicvoice1 - Update Voice 1 Playback

          ;; Applies envelope (attack/decay), decrements frame counter,

          ;; loads new note when counter reaches 0

          ;; Update Voice 1 playback (applies envelope, decrements

          ;; frame counter, loads new note when counter reaches 0)

          ;;
          ;; Input: musicVoice1Frame_R (global SCRAM) = frame counter,

          ;; musicVoice1Pointer (global 16-bit) = voice pointer,

          ;; currentSongID_R (global SCRAM) = current song ID,

          ;; musicVoice1TotalFrames, musicVoice1TargetAUDV (global) =

          ;; envelope parameters, NoteAttackFrames, NoteDecayFrames

          ;; (global constants) = envelope consta


          ;;
          ;; Output: Envelope applied, frame counter decremented, next

          ;; note loaded when counter reaches 0

          ;;
          ;; Mutates: temp1 (used for voice number), temp5

          ;; (global) = frame count calculation, musicVoice1Frame_W

          ;; (global SCRAM) = frame counter (decremented),

          ;; musicVoice1Pointer (global 16-bit) = voice

          ;; pointer (advanced via LoadMusicNote1), AUDC1, AUDF1, AUDV1

          ;; (TIA registers) = sound registers (updated via

          ;; LoadMusicNote1 and CalculateMusicVoiceEnvelope)

          ;;
          ;; Called Routines: CalculateMusicVoiceEnvelope - applies

          ;; attack/decay/sustain envelope, LoadMusicNote1 (bank15 or

          ;; bank1) - loads next 4-byte note, extracts AUDC/AUDV,

          ;; writes to TIA, advances pointer, handles end-of-song

          ;;
          ;; Constraints: Uses Voice 1 (AUDC1, AUDF1, AUDV1). Songs 0-Bank14MaxSongID

          ;; in Bank 15, all others in Bank 1. Routes to correct bank

          ;; based on currentSongID_R

          ;; Apply envelope using shared calculation

          lda # 1
          sta temp1

          ;; Decrement frame counter

          jsr CalculateMusicVoiceEnvelope

          ;; Fix RMW: Read from _R, modify, write to _W

          lda musicVoice1Frame_R
          sec
          sbc # 1
          sta temp5

          lda temp5
          sta musicVoice1Frame_W

          ;; Frame counter reached 0 - load next note from appropriate

          rts

          ;; bank

          ;; Check which bank this song is in (Bank 15: songs 0-Bank14MaxSongID, Bank

          ;; 1: others)

          ;; Song in Bank 15

          jsr LoadMusicNote1Bank15

          ;; Song in Bank 1

          ;; Cross-bank call to LoadMusicNote1 in bank 1
          lda # >(AfterLoadMusicNote1Bank1-1)
          pha
          lda # <(AfterLoadMusicNote1Bank1-1)
          pha
          lda # >(LoadMusicNote1-1)
          pha
          lda # <(LoadMusicNote1-1)
          pha
                    ldx # 0
          jmp BS_jsr
AfterLoadMusicNote1Bank1:


          rts

.pend

;; StopMusic .proc (no matching .pend)

          ;;
          ;; Returns: Far (return otherbank)

          ;; Stopmusic - Stop All Music Playback

          ;; Stop all music playback (zeroes TIA volumes, clears

          ;; pointers, resets frame counters)

          ;;
          ;; Input: None

          ;;
          ;; Output: All music stopped, voices freed

          ;;
          ;; Mutates: AUDV0, AUDV1 (TIA registers) = sound volumes (set

          ;; to 0), musicVoice0Pointer, musicVoice1Pointer (global 16-bit)

          ;; = voice pointers (set to 0), musicVoice0Frame_W,

          ;; musicVoice1Frame_W (global SCRAM) = frame counters (set to

          ;; 0)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: None

          ;; Zero TIA volumes
          lda # 0
          sta AUDV0
          lda # 0
          sta AUDV1



          ;; Clear voice pointers (high byte = 0 means inactive)

          lda # 0
          sta musicVoice0Pointer

          lda # 0
          sta musicVoice1Pointer



          ;; Reset frame counters

          lda # 0
          sta musicVoice0Frame_W

          lda # 0
          sta musicVoice1Frame_W

          jmp BS_return

