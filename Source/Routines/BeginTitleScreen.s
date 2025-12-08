
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
          ;; lda # 0 (duplicate)
          ;; sta titleParadeActive (duplicate)

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Start Chaotica title music
          ;; lda MusicChaotica (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to StartMusic in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(StartMusic-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(StartMusic-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          jmp BS_jsr
return_point:


          ;; Set window values for Title screen (ChaosFight only)
          ;; OPTIMIZATION: Inlined to save call overhead (only used once)
                    ;; let titlescreenWindow1 = 0   ; AtariAge logo hidden
                    ;; let titlescreenWindow2 = 0  ; AtariAgeText hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow2 (duplicate)
                    ;; let titlescreenWindow3 = 42  ; ChaosFight visible
          ;; lda # 42 (duplicate)
          ;; sta titlescreenWindow3 (duplicate)
                    ;; let titlescreenWindow4 = 0  ; Interworldly hidden
          ;; lda # 0 (duplicate)
          ;; sta titlescreenWindow4 (duplicate)

          ;; Note: Bitmap data is loaded automatically by titlescreen
          ;; kernel via includes
          ;; BeginTitleScreen is called cross-bank from SetupTitle
          ;; (gosub BeginTitleScreen bank14 forces BS_jsr even though same bank)
          ;; so it must return with return otherbank to match
          jsr BS_return

.pend

