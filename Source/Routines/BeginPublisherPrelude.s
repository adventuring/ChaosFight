
BeginPublisherPrelude .proc
          ;;
          ;; ChaosFight - Source/Routines/BeginPublisherPrelude.bas
          ;; Copyright © 2025 Bruce-Robert Pocock.
          ;; Begin Publisher Prelude - Setup Routine
          ;;
          ;; Initializes state for Publisher Prelude screen (gameMode
          ;; 0).
          ;; Called from ChangeGameMode when transitioning to Publisher
          ;; Prelude.
          ;;
          ;; Sets up:
          ;; - Timer initialization
          ;; - Background color
          ;; - Music playback sta

          ;; - Window values for Publisher screen bitmaps
          ;; Bitmap data is loaded automatically by titlescreen kernel
          ;; via includes.
          ;; No explicit loading needed - titlescreen kernel handles
          ;; bitmap display.
          ;; Initializes state for Publisher Prelude screen (gameMode
          ;; 0)
          ;;
          ;; Input: None (called from ChangeGameMode)
          ;;
          ;; Output: preambleTimer initialized, COLUBK set, music
          ;; sta

          ;;
          ;; Mutates: preambleTimer (set to 0), COLUBK (TIA register),
          ;; temp1 (passed to StartMusic)
          ;;
          ;; Called Routines: StartMusic (bank15) - starts AtariToday
          ;; music
          ;;
          ;; Constraints: Called from ChangeGameMode when transitioning
          ;; to ModePublisherPrelude
          ;; Initialize prelude timer
          lda # 0
          sta preambleTimer

          ;; Disable character parade (only active on title screen, not preludes)
          lda # 0
          sta titleParadeActive

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Start AtariToday music
          lda # MusicAtariToday
          sta temp1
          ;; Cross-bank call to StartMusic in bank 15
          lda # >(AfterStartMusicPublisher-1)
          pha
          lda # <(AfterStartMusicPublisher-1)
          pha
          lda # >(StartMusic-1)
          pha
          lda # <(StartMusic-1)
          pha
          ldx # 14
          jmp BS_jsr

AfterStartMusicPublisher:

          ;; Set window values for Publisher screen (AtariAge logo + AtariAge text)
          ;; Window values are set once during setup, not every frame
          ;; OPTIMIZATION: Inlined to save call overhead (only used once)
          ;; let titlescreenWindow1 = 42  ; AtariAge logo visible
          ;; let titlescreenWindow2 = 42  ; AtariAgeText visible
          lda # 42
          sta titlescreenWindow2
          ;; let titlescreenWindow3 = 0  ; ChaosFight hidden
          lda # 0
          sta titlescreenWindow3
          ;; let titlescreenWindow4 = 0  ; BRP hidden
          lda # 0
          sta titlescreenWindow4
          jsr BS_return

.pend

