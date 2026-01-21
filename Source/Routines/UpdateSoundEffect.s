;;; ChaosFight - Source/Routines/UpdateSoundEffect.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateSoundEffect .proc
          ;; UpdateSoundEffect - Update sound effect playback each
          ;; Returns: Far (return otherbank)
          ;; frame
          ;; Called every frame from MainLoop for gameMode 6
          ;; Updates both voices if active (high byte ≠ 0)
          ;; Update sound effect playback each frame (called every
          ;; frame from MainLoop for gameMode 6)
          ;;
          ;; Input: soundEffectPointer, soundEffectPointer1 (global 16-bit)
          ;; = sound effect pointers, soundEffectFrame_R,
          ;; soundEffectFrame1_R (global SCRAM) = frame counters
          ;;
          ;; Output: Both voices updated if active (high byte ≠ 0)
          ;;
          ;; Mutates: All sound effect state (via
          ;; UpdateSoundEffectVoice0 and UpdateSoundEffectVoice1)
          ;;
          ;; Called Routines: UpdateSoundEffectVoice0 - updates Voice 0
          ;; if active, UpdateSoundEffectVoice1 - updates Voice 1 if
          ;; active
          ;;
          ;; Constraints: Called every frame from MainLoop for gameMode
          ;; 6. Only updates voices if active (high byte ≠ 0)
          ;; Update Voice 0
          ;; Cross-bank call to UpdateSoundEffectVoice0 in bank 14
          ;; Return address: ENCODED with caller bank 14 ($e0) for BS_return to decode
          lda # ((>(AfterUpdateSoundEffectVoice0-1)) & $0f) | $e0  ;;; Encode bank 14 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdateSoundEffectVoice0 hi (encoded)]
          lda # <(AfterUpdateSoundEffectVoice0-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdateSoundEffectVoice0 hi (encoded)] [SP+0: AfterUpdateSoundEffectVoice0 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdateSoundEffectVoice0-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdateSoundEffectVoice0 hi (encoded)] [SP+1: AfterUpdateSoundEffectVoice0 lo] [SP+0: UpdateSoundEffectVoice0 hi (raw)]
          lda # <(UpdateSoundEffectVoice0-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdateSoundEffectVoice0 hi (encoded)] [SP+2: AfterUpdateSoundEffectVoice0 lo] [SP+1: UpdateSoundEffectVoice0 hi (raw)] [SP+0: UpdateSoundEffectVoice0 lo]
          ldx # 14
          jmp BS_jsr

AfterUpdateSoundEffectVoice0:

          ;; Update Voice 1
          ;; Cross-bank call to UpdateSoundEffectVoice1 in bank 14
          ;; Return address: ENCODED with caller bank 14 ($e0) for BS_return to decode
          lda # ((>(AfterUpdateSoundEffectVoice1-1)) & $0f) | $e0  ;;; Encode bank 14 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdateSoundEffectVoice1 hi (encoded)]
          lda # <(AfterUpdateSoundEffectVoice1-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdateSoundEffectVoice1 hi (encoded)] [SP+0: AfterUpdateSoundEffectVoice1 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdateSoundEffectVoice1-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdateSoundEffectVoice1 hi (encoded)] [SP+1: AfterUpdateSoundEffectVoice1 lo] [SP+0: UpdateSoundEffectVoice1 hi (raw)]
          lda # <(UpdateSoundEffectVoice1-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdateSoundEffectVoice1 hi (encoded)] [SP+2: AfterUpdateSoundEffectVoice1 lo] [SP+1: UpdateSoundEffectVoice1 hi (raw)] [SP+0: UpdateSoundEffectVoice1 lo]
          ldx # 14
          jmp BS_jsr

AfterUpdateSoundEffectVoice1:

          jmp BS_return

.pend

