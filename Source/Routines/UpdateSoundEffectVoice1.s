;;; ChaosFight - Source/Routines/UpdateSoundEffectVoice1.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateSoundEffectVoice1 .proc
          ;; Returns: Far (return otherbank)
          ;; Updatesoundeffectvoice1 - Update Voice 1 Sound Effect
          ;; Update Voice 1 sound effect playback (decrements frame
          ;; counter, loads next note when counter reaches 0)
          ;; Input: soundEffectFrame1_R (global SCRAM) = frame counter,
          ;; soundEffectPointer1 (global 16-bit) = sound pointer
          ;; Output: Frame counter decremented, next note loaded when
          ;; counter reaches 0, voice freed when sound ends
          ;; Mutates: temp5 = frame count
          ;; calculation, soundEffectFrame1_W (global SCRAM) = frame
          ;; counter (decremented), soundEffectPointer1 (global 16-bit) =
          ;; sound pointer (advanced by 4 bytes), AUDC1, AUDF1, AUDV1 (TIA registers)
          ;; = sound registers (updated via LoadSoundNote1)
          ;; Called Routines: LoadSoundNote1 (bank15) - loads next
          ;; 4-byte note from Sounds bank, extracts AUDC/AUDV, writes
          ;; to TIA, advances pointer, handles end-of-sound
          ;; Constraints: Uses Voice 1 (AUDC1, AUDF1, AUDV1).
          ;; LoadSoundNote1 handles end-of-sound by setting
          ;; soundEffectPointer1 = 0 and AUDV1 = 0
          ;; Decrement frame counter
          ;; Fix RMW: Read from _R, modify, write to _W
          lda soundEffectFrame1_R
          sec
          sbc # 1
          sta temp5
          lda temp5
          sta soundEffectFrame1_W
          jmp BS_return

          ;; Frame counter reached 0 - load next note from Sounds bank
          ;; Cross-bank call to LoadSoundNote1 in bank 14
          ;; Return address: ENCODED with caller bank 14 ($e0) for BS_return to decode
          lda # ((>(AfterLoadSoundNoteVoice1-1)) & $0f) | $e0  ;;; Encode bank 14 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLoadSoundNoteVoice1 hi (encoded)]
          lda # <(AfterLoadSoundNoteVoice1-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLoadSoundNoteVoice1 hi (encoded)] [SP+0: AfterLoadSoundNoteVoice1 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LoadSoundNote1-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLoadSoundNoteVoice1 hi (encoded)] [SP+1: AfterLoadSoundNoteVoice1 lo] [SP+0: LoadSoundNote1 hi (raw)]
          lda # <(LoadSoundNote1-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLoadSoundNoteVoice1 hi (encoded)] [SP+2: AfterLoadSoundNoteVoice1 lo] [SP+1: LoadSoundNote1 hi (raw)] [SP+0: LoadSoundNote1 lo]
          ldx # 14
          jmp BS_jsr

AfterLoadSoundNoteVoice1:

          ;; LoadSoundNote1 will:
          ;; - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          ;; AUDF, Duration, Delay
          ;; - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          ;; - Write to TIA: AUDC1, AUDF1, AUDV1 (use Voice 1)
          ;; - Set SoundEffectFrame1 = Duration + Delay
          ;; - Advance SoundEffectPointer1 by 4 bytes
          ;; - Handle end-of-sound: set soundEffectPointer1 = 0, AUDV1
          ;; = 0, free voice
          jmp BS_return

.pend

