;;; ChaosFight - Source/Routines/PlaySoundEffect.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


PlaySoundEffect .proc
          ;; SOUND EFFECT SUBSYSTEM - Polyphony 2 Implementation
          ;; Returns: Far (return otherbank)
          ;; Sound effects for gameplay (gameMode 6)
          ;; Uses interleaved 4-byte streams: AUDCV, AUDF, Duration,
          ;; Delay
          ;; AUDCV = (AUDC << 4) | AUDV (packed into single byte)
          ;;
          ;; High byte of pointer = 0 indicates sound inactive
          ;; Supports 2 simultaneous sound effects (one per voice)
          ;; Music takes priority (no sounds if music active)
          ;; Playsoundeffect - Start Sound Effect Playback
          ;;
          ;; Input: temp1 = sound ID (0-255)
          ;; Plays sound effect if voice is free, else forgets it (no
          ;; queuing)
          ;; Start sound effect playback (plays sound if voice is free,
          ;; else forgets it)
          ;;
          ;; Input: temp1 = sound ID (0-255), musicVoice0Pointer,
          ;; musicVoice1Pointer (global 16-bit) = music voice pointers,
          ;; soundEffectPointer, soundEffectPointer1 (global 16-bit) =
          ;; sound effect pointers
          ;;
          ;; Output: Sound effect started on available voice (Voice 0
          ;; preferred, Voice 1 fallback)
          ;;
          ;; Mutates: temp1 (used for sound ID), soundEffectPointer (global 16-bit)
          ;; = sound pointer (via LoadSoundPointer), soundEffectPointer,
          ;; soundEffectFrame_W (global SCRAM) = Voice 0 sound state (if Voice 0 used),
          ;; soundEffectPointer1,
          ;; soundEffectFrame1_W (global SCRAM) = Voice 1 sound sta

          ;; (if Voice 1 used)
          ;;
          ;; Called Routines: LoadSoundPointer (bank15) - looks up
          ;; sound pointer from Sounds bank, UpdateSoundEffectVoice0
          ;; (tail call via goto) - starts Voice 0 playback,
          ;; UpdateSoundEffectVoice1 (tail call via goto) - sta

          ;; Voice 1 playback
          ;;
          ;; Constraints: Music takes priority (no sounds if music
          ;; active). No queuing - sound forgotten if both voices busy.
          ;; Voice 0 tried first, Voice 1 as fallback
          ;; Check if music is active (music takes priority)
          jmp BS_return

          ;; Lookup sound pointer from Sounds bank (Bank15)
          ;; Cross-bank call to LoadSoundPointer in bank 15
          lda # >(AfterLoadSoundPointer-1)
          pha
          lda # <(AfterLoadSoundPointer-1)
          pha
          lda # >(LoadSoundPointer-1)
          pha
          lda # <(LoadSoundPointer-1)
          pha
          ldx # 14
          jmp BS_jsr

AfterLoadSoundPointer:

          ;; Try Voice 0 first
          ;; if soundEffectPointer then TryVoice1
          lda soundEffectPointer
          beq UseVoice0

          jmp TryVoice1

UseVoice0:

          ;; Voice 0 is free - LoadSoundPointer already set soundEffectPointer
          lda # 1
          sta soundEffectFrame_W
          ;; tail call
          jmp UpdateSoundEffectVoice0

.pend

TryVoice1 .proc
          ;; Helper: Tries Voice 1 if Voice 0 is busy
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: soundEffectPointer (global 16-bit) = sound pointer (set by LoadSoundPointer),
          ;; soundEffectPointer1 (global 16-bit) = Voice 1 pointer
          ;;
          ;; Output: Sound effect started on Voice 1 if free
          ;;
          ;; Mutates: soundEffectPointer1,
          ;; soundEffectFrame1_W (global SCRAM) = Voice 1 sound sta

          ;;
          ;; Called Routines: UpdateSoundEffectVoice1 (tail call via
          ;; goto) - starts Voice 1 playback
          ;;
          ;; Constraints: Internal helper for PlaySoundEffect, only
          ;; called when Voice 0 is busy
          ;; Try Voice 1
          jmp BS_return

          ;; Copy soundEffectPointer to soundEffectPointer1
          lda soundEffectPointer
          sta soundEffectPointer1
          ;; Voice 1 is free - use it
          lda soundEffectPointerH
          sta soundEffectPointer1H
          lda # 1
          sta soundEffectFrame1_W
          ;; tail call
          jmp UpdateSoundEffectVoice1


.pend

