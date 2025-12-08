;;; ChaosFight - Source/Routines/UpdateSoundEffectVoice0.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateSoundEffectVoice0 .proc

          ;; Returns: Far (return otherbank)
          ;; Updatesoundeffectvoice0 - Update Voice 0 Sound Effect
          ;; Update Voice 0 sound effect playback (decrements frame
          ;; counter, loads next note when counter reaches 0)
          ;; Input: soundEffectFrame_R (global SCRAM) = frame counter,
          ;; soundEffectPointer (global 16-bit) = sound pointer
          ;; Output: Frame counter decremented, next note loaded when
          ;; counter reaches 0, voice freed when sound ends
          ;; Mutates: temp4 = frame count calculation,
          ;; soundEffectFrame_W (global SCRAM) = frame counter
          ;; (decremented), soundEffectPointer (global 16-bit) = sound pointer (advanced by 4 bytes),
          ;; AUDC0, AUDF0, AUDV0 (TIA registers) = sound registers
          ;; (updated via LoadSoundNote)
          ;; Called Routines: LoadSoundNote (bank15) - loads next
          ;; 4-byte note from Sounds bank, extracts AUDC/AUDV, writes
          ;; to TIA, advances pointer, handles end-of-sound
          ;; Constraints: Uses Voice 0 (AUDC0, AUDF0, AUDV0).
          ;; LoadSoundNote handles end-of-sound by setting
          ;; soundEffectPointer = 0 and AUDV0 = 0
          ;; Decrement frame counter
          ;; Fix RMW: Read from _R, modify, write to _W
          lda soundEffectFrame_R
          sec
          sbc # 1
          sta temp4
          ;; lda temp4 (duplicate)
          ;; sta soundEffectFrame_W (duplicate)
          jsr BS_return
          ;; Frame counter reached 0 - load next note from Sounds bank
          ;; Cross-bank call to LoadSoundNote in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadSoundNote-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadSoundNote-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          jmp BS_jsr
return_point:

          ;; LoadSoundNote will:
          ;; - Load 4-byte note from Sound_Voice0[pointer]: AUDCV,
          ;; AUDF, Duration, Delay
          ;; - Extract AUDC (upper 4 bits) and AUDV (lower 4 bits)
          ;; - Write to TIA: AUDC0, AUDF0, AUDV0 (use Voice 0)
          ;; - Set SoundEffectFrame = Duration + Delay
          ;; - Advance SoundEffectPointer by 4 bytes
          ;; - Handle end-of-sound: set soundEffectPointer = 0, AUDV0
          ;; = 0, free voice
          ;; jsr BS_return (duplicate)

.pend

