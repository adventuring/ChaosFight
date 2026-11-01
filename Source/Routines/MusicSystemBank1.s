;;; ChaosFight - Source/Routines/MusicSystemBank1.s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Duplicate of MusicSystem.s for Bank 1 (Bank 14 already has full MusicSystem).
;;; This ensures cross-bank access is available from every bank.
;;; (Same routines exist in bank 15 - music routines use self-contained logic.)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; NOTE: This file duplicates all music subroutines. No variable aliases here; use $A2-$A4 etc. (safe ZP) directly.
;;; The purpose is bank-agnostic access - calling routines look up global variables from SCRAM or ZP.
;;; Cross-bank calls between Bank 1 and other banks use BS_jsr / BS_return as defined in BankSwitching.s.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Variables accessed (all safe - not in $F0-$FF stack zone):
;;;   musicPlaying      = $A2  (SCRAM)
;;;   titleParadeTimer  = $A3  (SCRAM)
;;;   playerCharacter   = $A4  (SCRAM)
;;;   songPointer       = $D4  (SCRAM)
;;;   musicVoice0Pointer = $D6  (SCRAM)
;;;   musicVoice1Pointer = $D8  (SCRAM)
;;; These are set at runtime via BS_jsr calls; both banks can read them safely.

StartMusic .proc
          ;; MUSIC SUBSYSTEM for Bank 1 (duplicate of Bank14 version).
          ;; All global vars are read at runtime ($A2-$D8 range), no local aliases needed.

          ;; Set musicPlaying = 1 to indicate music is active
          lda # 1
          sta musicPlaying

          jmp BS_return
.pend

PlayMusic .proc
          ;; PlayMusic - Called every frame from MainLoop (or Vblank handler).
          ;; Same code as Bank 14 version; uses runtime global vars only.

          jsr UpdateMusicVoice0
          jsr UpdateMusicVoice1

          ;; Check if Voice 0 still active (high byte of pointer != 0)
          lda musicVoice0Pointer + 1
          bne PlayMusicDone

          ;; Check if Voice 1 still active (high byte of pointer != 0)
          lda musicVoice1Pointer + 1
          bne PlayMusicEnded

          ;; Both voices ended - check if Chaotica (song ID 26) for looping
          lda currentSongID_R
          cmp # 26
          bne PlayMusicEnded

          jmp IsChaotica

PlayMusicEnded:
          ;; Both voices ended and song is not Chaotica - stop music
          lda # 0
          sta musicPlaying

PlayMusicDone:
          jmp BS_return
.pend

IsChaotica .proc
          ;; Both voices ended and song is Chaotica - reset to song start
          ;; Returns: Far (return thisbank)
          lda currentSongID_R
          cmp # 26
          bne IsChaoticaDone
          lda # 1
IsChaoticaDone:
          rts
.pend
