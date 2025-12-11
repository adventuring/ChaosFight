
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
          lda # >(AfterStartMusicTitle-1)
          pha
          lda # <(AfterStartMusicTitle-1)
          pha
          lda # >(StartMusic-1)
          pha
          lda # <(StartMusic-1)
          pha
          ldx # 14
          jmp BS_jsr

AfterStartMusicTitle:

          ;; Set window values for Title screen (ChaosFight only)
          ;; OPTIMIZATION: Inlined to save call overhead (only used once)
          ;; Set titlescreenWindow1 = 0   ; AtariAge logo hidden
          ;; Set titlescreenWindow2 = 0  ; AtariAgeText hidden
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
          jmp BS_return

.pend

