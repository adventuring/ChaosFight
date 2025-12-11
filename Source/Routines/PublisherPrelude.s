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
          ;; if joy0fire then jmp PublisherPreludeComplete
          bit INPT0
          bmi CheckJoy1Fire

          jmp PublisherPreludeComplete

CheckJoy1Fire:

          ;; if joy1fire then jmp PublisherPreludeComplete
          bit INPT1
          bmi CheckEnhancedControllers

          jmp PublisherPreludeComplete

CheckEnhancedControllers:

          ;; Check MegaDrive/Joy2b+ controllers if detected
          ;; Player 1: Genesis Button C (INPT0) or Joy2b+ Button C/II (INPT0) or Joy2b+ Button III (INPT1)
          ;; OR flags together and check for nonzero match
          ;; Set temp1 = controllerStatus & (SetLeftPortGenesis | SetLeftPortJoy2bPlus)
          lda controllerStatus
          and # SetLeftPortGenesis
          sta temp1
          lda controllerStatus
          and # SetLeftPortJoy2bPlus
          ora temp1
          sta temp1
          ;; if temp1 then if !INPT0{7} then jmp PublisherPreludeComplete
          lda temp1
          beq CheckPlayer1Joy2bPlusButton3

          bit INPT0
          bmi CheckPlayer1Joy2bPlusButton3

          jmp PublisherPreludeComplete

CheckPlayer1Joy2bPlusButton3:

          ;; Check Joy2b+ Button III (INPT1) for Player 1
          lda controllerStatus
          and # SetLeftPortJoy2bPlus
          beq CheckPlayer2Enhanced

          bit INPT1
          bmi CheckPlayer2Enhanced

          jmp PublisherPreludeComplete

CheckPlayer2Enhanced:

          ;; Player 2: Genesis Button C (INPT2) or Joy2b+ Button C/II (INPT2) or Joy2b+ Button III (INPT3)
          ;; Set temp1 = controllerStatus & (SetRightPortGenesis | SetRightPortJoy2bPlus)
          lda controllerStatus
          and # SetRightPortGenesis
          sta temp1
          lda controllerStatus
          and # SetRightPortJoy2bPlus
          ora temp1
          sta temp1
          ;; if temp1 then if !INPT2{7} then jmp PublisherPreludeComplete
          lda temp1
          beq CheckPlayer2Joy2bPlusButton3

          bit INPT2
          bmi CheckPlayer2Joy2bPlusButton3

          jmp PublisherPreludeComplete

CheckPlayer2Joy2bPlusButton3:

          ;; Check Joy2b+ Button III (INPT3) for Player 2
          lda controllerStatus
          and # SetRightPortJoy2bPlus
          beq CheckAutoAdvance

          bit INPT3
          bmi CheckAutoAdvance

          jmp PublisherPreludeComplete

CheckAutoAdvance:

          ;; Auto-advance after music completes + 0.5s
          ;; Long branch - use goto (generates JMP) instead of if-then (generates branch)
          ;; If preambleTimer > 30 && musicPlaying = 0, then jmp lda preambleTimer
          cmp # 31
          bcc IncrementTimer
          lda musicPlaying
          bne IncrementTimer
          goto_label:

          jmp PublisherPreludeComplete
IncrementTimer:
          ;; PublisherPreludeComplete

          inc preambleTimer

          ;; Music and drawing handled by MainLoop (PlayMusic and DrawTitleScreen)
          jmp BS_return

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
          lda ModeAuthorPrelude
          sta gameMode
          ;; Cross-bank call to BeginAuthorPrelude in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(BeginAuthorPrelude-1)
          pha
          lda # <(BeginAuthorPrelude-1)
          pha
          ldx # 13
          jmp BS_jsr
AfterBeginAuthorPrelude:


          jmp BS_return
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

