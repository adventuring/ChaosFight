
BeginTitleScreen .proc
          ;; ChaosFight - Source/Routines/BeginTitleScreen.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Setup routine for Title Screen. Sets initial state only.

          ;; Setup routine for Title Screen - sets initial state only
          ;;
          ;; Input: None (called from ChangeGameMode)
          ;;
          ;; Output: titleParadeTimer initialized, titleParadeActive
          ;; initialized, COLUBK set,
          ;; music started, window values set
          ;;
          ;; Mutates: titleParadeTimer (set to 0), titleParadeActive
          ;; (set to 0),
          ;; COLUBK (TIA register), temp1 (passed to
          ;; StartMusic)
          ;;
          ;; Called Routines: StartMusic (bank15) - starts title music
          ;;
          ;; Constraints: Called from ChangeGameMode when transitioning
          ;; to ModeTitle
          ;; Initialize Title Screen mode
          ;; Note: pfres is defined globally in AssemblyConfig.s

          ;; Initialize title parade sta

          lda # 0
          sta titleParadeTimer
          lda # 0
          sta titleParadeActive

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Start Chaotica title music
          lda # MusicChaotica
          sta temp1
          ;; Cross-bank call to StartMusic in bank 15
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call (cross-bank call from ChangeGameMode)
          ;; Cross-bank call to StartMusic in bank 14
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterStartMusicTitle-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterStartMusicTitle hi (encoded)]
          lda # <(AfterStartMusicTitle-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterStartMusicTitle hi (encoded)] [SP+0: AfterStartMusicTitle lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterStartMusicTitle hi (encoded)] [SP+1: AfterStartMusicTitle lo] [SP+0: StartMusic hi (raw)]
          lda # <(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterStartMusicTitle hi (encoded)] [SP+2: AfterStartMusicTitle lo] [SP+1: StartMusic hi (raw)] [SP+0: StartMusic lo]
          ldx # 14
          jmp BS_jsr

AfterStartMusicTitle:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from StartMusic call, left original 4 bytes)

          ;; Set window values for Title screen (ChaosFight only)
          ;; OPTIMIZATION: Inlined to save call overhead (only used once)
          ;; Set titlescreenWindow1 = 0   ; AtariAge logo hidden
          ;; Set titlescreenWindow2 = 0  ; AtariAgeText hidden
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          lda # 0
          sta titlescreenWindow1
          lda # 0
          sta titlescreenWindow2
          ;; Set titlescreenWindow3 = 42  ; ChaosFight visible
          lda # 42
          sta titlescreenWindow3
          ;; Set titlescreenWindow4 = 0  ; Interworldly hidden
          lda # 0
          sta titlescreenWindow4

          ;; Note: Bitmap data is loaded automatically by titlescreen
          ;; kernel via includes
          ;; BeginTitleScreen is called cross-bank from SetupTitle
          ;; (cross-bank call to BeginTitleScreen bank14 forces BS_jsr even though same bank)
          ;; so it must return with return otherbank to match
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend

