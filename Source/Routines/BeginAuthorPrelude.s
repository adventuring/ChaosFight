
BeginAuthorPrelude .proc
          ;; ChaosFight - Source/Routines/BeginAuthorPrelude.bas
          ;; Setup routine for Author Prelude. Sets initial sta

          ;; only.
          ;; Setup routine for Author Prelude - sets initial state only
          ;;
          ;; Input: None (called from ChangeGameMode)
          ;;
          ;; Output: preambleTimer initialized, COLUBK set, music
          ;; started, window values set
          ;;
          ;; Mutates: preambleTimer (set to 0), COLUBK (TIA register),
          ;; temp1 (passed to StartMusic)
          ;;
          ;; Called Routines: StartMusic (bank15) - starts Interworldly
          ;; music
          ;;
          ;; Constraints: Called from ChangeGameMode when transitioning
          ;; to ModeAuthorPrelude
          ;; Initialize Author Prelude mode
          ;; Note: pfres is defined globally in AssemblyConfig.s

          ;; Initialize timer
          lda # 0
          sta preambleTimer

          ;; Disable character parade (only active on title screen, not preludes)
          lda # 0
          sta titleParadeActive

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Start Interworldly music
          lda # MusicInterworldly
          sta temp1
          ;; Cross-bank call to StartMusic in bank 15
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call (cross-bank call from ChangeGameMode)
          lda # >(AfterStartMusicAuthorPrelude-1)
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterStartMusicAuthorPrelude hi]
          lda # <(AfterStartMusicAuthorPrelude-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterStartMusicAuthorPrelude hi] [SP+0: AfterStartMusicAuthorPrelude lo]
          lda # >(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterStartMusicAuthorPrelude hi] [SP+1: AfterStartMusicAuthorPrelude lo] [SP+0: StartMusic hi]
          lda # <(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterStartMusicAuthorPrelude hi] [SP+2: AfterStartMusicAuthorPrelude lo] [SP+1: StartMusic hi] [SP+0: StartMusic lo]
          ldx # 14
          jmp BS_jsr

AfterStartMusicAuthorPrelude:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from StartMusic call, left original 4 bytes)


          ;; Set window values for Author screen (Interworldly only)
          ;; OPTIMIZATION: Inlined to save call overhead (only used once)
          ;; Set titlescreenWindow1 = 0   ; AtariAge logo hidden
          ;; Set titlescreenWindow2 = 0  ; AtariAgeText hidden
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          lda # 0
          sta titlescreenWindow1
          lda # 0
          sta titlescreenWindow2
          ;; Set titlescreenWindow3 = 0  ; ChaosFight hidden
          lda # 0
          sta titlescreenWindow3
          ;; Set titlescreenWindow4 = 42  ; BRP visible
          lda # 42
          sta titlescreenWindow4

          ;; Note: Bitmap data is loaded automatically by titlescreen
          ;; kernel via includes
          ;; BeginAuthorPrelude is called cross-bank from SetupAuthorPrelude
          ;; (cross-bank call to BeginAuthorPrelude bank14 forces BS_jsr even though same bank)
          ;; so it must return with return otherbank to match
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend

