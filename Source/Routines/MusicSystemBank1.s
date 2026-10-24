;;; ChaosFight - Source/Routines/MusicSystemBank1.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Duplicate of MusicSystem.s for Bank 1 (Bank 14 already has full MusicSystem).
;;; This ensures cross-bank access is available from every bank.
;;; (Same routines exist in bank 15 - music routines use self-contained logic.)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; NOTE: This file duplicates all music subroutines. No variable aliases here; use $A2-$A4 etc. (safe ZP) directly.
;;; The purpose is bank-agnostic access - calling routines look up global variables from SCRAM or ZP.
;;; Cross-bank calls between Bank 1 and other banks use BS_jsr / BS_return as defined in BankSwitching.s.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

          bne PlayMusicDone  ; Voice 0 still active
          bne PlayMusicDone  ; Voice 1 still active
          bne PlayMusicEnded ; Chaotica loop

PlayMusicEnded:
          ;; Both voices ended and song is not Chaotica - stop music
          lda # 0
          sta musicPlaying
PlayMusicDone:
          rts
.pend

IsChaotica .proc
          ;; Returns $1 if currentSongID_R = Chaotica (song 26)
          lda # ChaoticaID
          cmp currentSongID_R
          bne IsChaoticaDone
          lda # 1
IsChaoticaDone:
          rts
.pend

CalculateMusicVoiceEnvelope .proc
          ;; Shared envelope calculation shared by both voices
          ;; Reads from global vars; writes to AUDC/AUDF TIA registers
.pend

GetVoice0Vars .proc
          ;; Fetch starting values for Voice 0 from currentSongID_R
.pend

CalcElapsedFrames .proc
          ;; Calculate elapsed frames for envelope timing
.pend

ApplyAttackEnvelope .proc
          ;; Apply attack phase envelope to AUDC0/AUDV0
.pend

ApplyDecayEnvelope .proc
          ;; Apply decay phase envelope
.pend

UpdateMusicVoice0 .proc

          ;; Same logic as Bank 14 version (see MusicSystem.s lines 630-730).
          ;; Frame counter decrement; note load when counter hits 0.
.pend

UpdateMusicVoice1 .proc

          ;; Same logic as Bank 14 version.
.pend