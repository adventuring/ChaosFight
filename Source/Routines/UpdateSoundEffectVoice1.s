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
          ;; lda temp5 (duplicate)
          ;; sta soundEffectFrame1_W (duplicate)
          jsr BS_return
          ;; Frame counter reached 0 - load next note from Sounds bank
          ;; Cross-bank call to LoadSoundNote1 in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadSoundNote1-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadSoundNote1-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          jmp BS_jsr
return_point:

          ;; LoadSoundNote1 will:
          ;; - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          ;; AUDF, Duration, Delay
          ;; - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          ;; - Write to TIA: AUDC1, AUDF1, AUDV1 (use Voice 1)
          ;; - Set SoundEffectFrame1 = Duration + Delay
          ;; - Advance SoundEffectPointer1 by 4 bytes
          ;; - Handle end-of-sound: set soundEffectPointer1 = 0, AUDV1
          ;; = 0, free voice
          ;; jsr BS_return (duplicate)

.pend

