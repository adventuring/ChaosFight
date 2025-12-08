;;; ChaosFight - Source/Routines/PublisherPrelude.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Publisher Prelude Screen - Per-frame Loop
;;; Per-frame publisher prelude display and input handling.
;;; Called from MainLoop each frame (gameMode 0).
          ;; Setup is handled by BeginPublisherPrelude in
          ;; ChangeGameMode.bas.
          ;; This function processes one frame and returns.
          ;; FLOW PER FRAME (OVerscan only - minimal work):
          ;; 1. Handle input - any button press skips to author prelude
          ;; 2. Check auto-advance timer (music completion + 0.5s)
          ;; 3. Increment timer
          ;; 4. Return to MainLoop (music and drawing handled by MainLoop)
          ;; BITMAP CONFIGURATION:
          ;; - Size: 48×42 pixels (displayed as 48×84 scanlines in
          ;; double-height mode)
          ;; - Uses titlescreen kernel minikernel for display
          ;; - Color-per-line support (84 color values, 42 × 2 for
          ;; double-height)
          ;; - Bitmap data stored in ROM:
          ;; Source/Generated/Art.AtariAge.s
          ;; AVAILABLE VARIABLES:
          ;; preambleTimer - Frame counter for timing
          ;; musicPlaying - Music state flag
          ;; QuadtariDetected - For checking all controllers
          ;; Per-frame publisher prelude display and input handling
          ;;
          ;; Input: joy0fire, joy1fire (hardware) = button sta

          ;; controllerStatus (global) = controller detection
          ;; sta

          ;; INPT0-3 (hardware) = MegaDrive/Joy2b+ controller
          ;; button sta

          ;; preambleTimer (global) = frame counter
          ;; musicPlaying (global) = music playback sta

          ;;
          ;; Output: Dispatches to PublisherPreludeComplete or returns
          ;;
          ;; Mutates: preambleTimer (incremented)
          ;;
          ;; Called Routines: None (music handled by MainLoop, window values set in BeginPublisherPrelude)
          ;;
          ;; Constraints: Must be colocated with
          ;; PublisherPreludeComplete
          ;; Called from MainLoop each frame (gameMode 0)
          ;; Bitmap data is loaded automatically by titlescreen kernel
          ;; via includes
          ;; No explicit loading needed - titlescreen kernel handles
          ;; bitmap display


PublisherPreludeMain .proc
          ;; Check for button press on any controller to skip
                    ;; if joy0fire then goto PublisherPreludeComplete
          lda joy0fire
          beq skip_7935
          jmp PublisherPreludeComplete
skip_7935:

                    ;; if joy1fire then goto PublisherPreludeComplete
          ;; lda joy1fire (duplicate)
          ;; beq skip_5538 (duplicate)
          ;; jmp PublisherPreludeComplete (duplicate)
skip_5538:

          ;; Check MegaDrive/Joy2b+ controllers if detected
          ;; Player 1: Genesis Button C (INPT0) or Joy2b+ Button C/II (INPT0) or Joy2b+ Button III (INPT1)
          ;; OR flags together and check for nonzero match
                    ;; let temp1 = controllerStatus & (SetLeftPortGenesis | SetLeftPortJoy2bPlus)
                    ;; if temp1 then if !INPT0{7} then goto PublisherPreludeComplete
          ;; lda temp1 (duplicate)
          ;; beq skip_4033 (duplicate)
          bit INPT0
          bmi skip_4033
          ;; jmp PublisherPreludeComplete (duplicate)
skip_4033:

;; lda temp1 (duplicate)

;; beq skip_7601 (duplicate)

skip_7601:
          ;; jmp skip_7601 (duplicate)

          ;; lda controllerStatus (duplicate)
          and SetLeftPortJoy2bPlus
          sta temp1
                    ;; if temp1 then if !INPT1{7} then goto PublisherPreludeComplete          lda temp1          beq skip_4785
skip_4785:
          ;; jmp skip_4785 (duplicate)

          ;; Player 2: Genesis Button C (INPT2) or Joy2b+ Button C/II (INPT2) or Joy2b+ Button III (INPT3)
                    ;; let temp1 = controllerStatus & (SetRightPortGenesis | SetRightPortJoy2bPlus)
          ;; lda controllerStatus (duplicate)
          ;; and # 96 (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if temp1 then if !INPT2{7} then goto PublisherPreludeComplete
          ;; lda temp1 (duplicate)
          ;; beq skip_5689 (duplicate)
          ;; bit INPT2 (duplicate)
          ;; bmi skip_5689 (duplicate)
          ;; jmp PublisherPreludeComplete (duplicate)
skip_5689:

;; lda temp1 (duplicate)

;; beq skip_5903 (duplicate)

skip_5903:
          ;; jmp skip_5903 (duplicate)

          ;; lda controllerStatus (duplicate)
          ;; and SetRightPortJoy2bPlus (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if temp1 then if !INPT3{7} then goto PublisherPreludeComplete          lda temp1          beq skip_8894
skip_8894:
          ;; jmp skip_8894 (duplicate)

          ;; Auto-advance after music completes + 0.5s
          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
                    ;; if preambleTimer > 30 && musicPlaying = 0 then goto
          ;; lda preambleTimer (duplicate)
          cmp # 31
          bcc skip_5880
          ;; lda musicPlaying (duplicate)
          bne skip_5880
          goto_label:

          ;; jmp goto_label_label (duplicate)
skip_5880:
          ;; PublisherPreludeComplete

          inc preambleTimer

          ;; Music and drawing handled by MainLoop (PlayMusic and DrawTitleScreen)
          jsr BS_return

PublisherPreludeComplete
          ;; Transition to Author Prelude mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from PublisherPreludeMain)
          ;;
          ;; Output: gameMode set to ModeAuthorPrelude, BeginAuthorPrelude called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: BeginAuthorPrelude (bank14) - sets up author prelude
          ;; Constraints: Must be colocated with PublisherPreludeMain
          ;; OPTIMIZATION: Call BeginAuthorPrelude directly to save 4 bytes (skip ChangeGameMode)
          ;; lda ModeAuthorPrelude (duplicate)
          ;; sta gameMode (duplicate)
          ;; Cross-bank call to BeginAuthorPrelude in bank 14
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BeginAuthorPrelude-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BeginAuthorPrelude-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 13
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; jsr BS_return (duplicate)
          ;;
          ;; Bitmap Loading
          ;; Bitmap data is loaded automatically by titlescreen kernel
          ;; via includes.
          ;; Generated from Source/Art/AtariAge.xcf → AtariAge.png
          ;; SkylineTool creates: Source/Generated/Art.AtariAge.s
          ;; - BitmapAtariAge: 6 columns × 42 bytes (inverted-y)
          ;; - BitmapAtariAgeColors: 84 color values (double-height)
          ;; The titlescreen kernel handles bitmap display
          ;; automatically - no explicit loading needed.

.pend

