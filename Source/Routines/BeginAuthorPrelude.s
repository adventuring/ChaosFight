
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
          lda # >(AfterStartMusicAuthorPrelude-1)
          pha
          lda # <(AfterStartMusicAuthorPrelude-1)
          pha
          lda # >(StartMusic-1)
          pha
          lda # <(StartMusic-1)
          pha
          ldx # 14
          jmp BS_jsr

AfterStartMusicAuthorPrelude:


          ;; Set window values for Author screen (Interworldly only)
          ;; OPTIMIZATION: Inlined to save call overhead (only used once)
          ;; Set titlescreenWindow1 = 0   ; AtariAge logo hidden
          ;; Set titlescreenWindow2 = 0  ; AtariAgeText hidden
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
          jmp BS_return

.pend

