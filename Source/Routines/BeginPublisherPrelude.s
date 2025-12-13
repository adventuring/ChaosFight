
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
          ;; STACK PICTURE: [] (empty, BeginPublisherPrelude called cross-bank)
          lda # >(AfterStartMusicPublisher-1)
          pha
          ;; STACK PICTURE: [SP+0: AfterStartMusicPublisher hi]
          lda # <(AfterStartMusicPublisher-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterStartMusicPublisher hi] [SP+0: AfterStartMusicPublisher lo]
          lda # >(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterStartMusicPublisher hi] [SP+1: AfterStartMusicPublisher lo] [SP+0: StartMusic hi]
          lda # <(StartMusic-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterStartMusicPublisher hi] [SP+2: AfterStartMusicPublisher lo] [SP+1: StartMusic hi] [SP+0: StartMusic lo]
          ldx # 14
          jmp BS_jsr

AfterStartMusicPublisher:
          ;; STACK PICTURE: [] (empty, BS_return consumed 4 bytes)

          ;; Set window values for Publisher screen (AtariAge logo + AtariAge text)
          ;; Window values are set once during setup, not every frame
          ;; OPTIMIZATION: Inlined to save call overhead (only used once)
          ;; Set titlescreenWindow1 = 42  ; AtariAge logo visible
          ;; Set titlescreenWindow2 = 42  ; AtariAgeText visible
          ;; STACK PICTURE: [] (empty)
          lda # 42
          sta titlescreenWindow1
          lda # 42
          sta titlescreenWindow2
          ;; Set titlescreenWindow3 = 0  ; ChaosFight hidden
          lda # 0
          sta titlescreenWindow3
          ;; Set titlescreenWindow4 = 0  ; BRP hidden
          lda # 0
          sta titlescreenWindow4
          ;; STACK PICTURE: [] (empty, BS_return expects 4 bytes from cross-bank caller)
          jmp BS_return

.pend

