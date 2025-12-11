;;; ChaosFight - Source/Routines/AuthorPrelude.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Displays the Interworldly author logo/artwork with music.
;;; Author Prelude Screen
;;; Displays the Interworldly author logo/artwork with music.
          ;; This is the second screen shown at cold sta

          ;; FLOW:
          ;; 1. Display 48×42 bitmap from Source/Art/Interworldly.xcf
          ;; (via titlescreen kernel)
          ;; 2. Play Interworldly music
          ;; 3. Wait for music completion + 0.5s OR button press
          ;; 4. Transition to title screen
          ;; BITMAP CONFIGURATION:
          ;; - Size: 48×42 pixels (displayed as 48×84 scanlines in
          ;; double-height mode)
          ;; - Uses titlescreen kernel minikernel for display
          ;; - Color-per-line support (84 color values, 42 × 2 for
          ;; double-height)
          ;; - Bitmap data stored in ROM:
          ;; Source/Generated/Art.Interworldly.s
          ;; AVAILABLE VARIABLES:
          ;; preambleTimer - Frame counter for timing
          ;; musicPlaying - Music state flag
          ;; QuadtariDetected - For checking all controllers
          ;; Per-frame author prelude display and input handling
          ;;
          ;; Input: joy0fire, joy1fire (hardware) = button sta

          ;; controllerStatus (global) = controller detection
          ;; sta

          ;; INPT0-3 (hardware) = MegaDrive/Joy2b+ controller
          ;; button sta

          ;; preambleTimer (global) = frame counter
          ;; musicPlaying (global) = music playback sta

          ;;
          ;; Output: Dispatches to AuthorPreludeComplete or returns
          ;;
          ;; Mutates: preambleTimer (incremented)
          ;;
          ;; Called Routines: PlayMusic (bank1) - plays music
          ;; state variables
          ;;
          ;; Constraints: Must be colocated with AuthorPreludeComplete
          ;; Called from MainLoop each frame (gameMode 1)
          ;; Bitmap data is loaded automatically by titlescreen kernel
          ;; via includes
          ;; No explicit loading needed - titlescreen kernel handles
          ;; bitmap display

AuthorPrelude .proc
          ;; Check for button press on any controller to skip
          ;; Returns: Far (return otherbank)
          ;; Use skip-over pattern to avoid complex || operator issues
          if joy0fire then AuthorPreludeComplete
          lda joy0fire
          beq CheckJoy1Fire

          jmp AuthorPreludeComplete

CheckJoy1Fire:

          if joy1fire then AuthorPreludeComplete
          lda joy1fire
          beq CheckEnhancedControllers

          jmp AuthorPreludeComplete

CheckEnhancedControllers:

          ;; Check MegaDrive/Joy2b+ controllers if detected
          ;; Player 1: Genesis Button C (INPT0) or Joy2b+ Button C/II (INPT0) or Joy2b+ Button III (INPT1)
          ;; OR flags together and check for nonzero match
          ;; let temp1 = controllerStatus & (SetLeftPortGenesis | SetLeftPortJoy2bPlus)
          if temp1 then if !INPT0{7} then AuthorPreludeComplete
          lda temp1
          beq CheckRightPortControllers
          bit INPT0
          bmi CheckRightPortControllers
          jmp AuthorPreludeComplete
CheckRightPortControllers:
          lda controllerStatus
          and SetLeftPortJoy2bPlus
          sta temp1
                    if temp1 then if !INPT1{7} then AuthorPreludeComplete          lda temp1          beq CheckRightPortControllersLabel
CheckRightPortControllersLabel:

          ;; Player 2: Genesis Button C (INPT2) or Joy2b+ Button C/II (INPT2) or Joy2b+ Button III (INPT3)
          ;; let temp1 = controllerStatus & (SetRightPortGenesis | SetRightPortJoy2bPlus)
          lda controllerStatus
          and # 96
          sta temp1
                    if temp1 then if !INPT2{7} then AuthorPreludeComplete
          lda temp1
          beq CheckAutoAdvance
          bit INPT2
          bmi CheckAutoAdvance
          jmp AuthorPreludeComplete
CheckAutoAdvance:
          lda controllerStatus
          and SetRightPortJoy2bPlus
          sta temp1
                    if temp1 then if !INPT3{7} then AuthorPreludeComplete          lda temp1          beq CheckAutoAdvanceLabel
CheckAutoAdvanceLabel:
          jmp CheckAutoAdvanceLabel


          ;; Auto-advance after music completes + 0.5s
                    if preambleTimer > 30 && musicPlaying = 0 then AuthorPreludeComplete
          lda preambleTimer
          cmp # 31
          bcc IncrementTimer
          lda musicPlaying
          bne IncrementTimer
          jmp AuthorPreludeComplete
IncrementTimer:

          inc preambleTimer
          jmp BS_return

AuthorPreludeComplete
          ;; Transition to Title Screen mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from AuthorPrelude)
          ;;
          ;; Output: gameMode set to ModeTitle, ChangeGameMode called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: ChangeGameMode (bank14) - accesses game
          ;; mode sta

          ;; Constraints: Must be colocated with AuthorPrelude
          lda ModeTitle
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(AfterChangeGameModeAuthorPrelude-1)
          pha
          lda # <(AfterChangeGameModeAuthorPrelude-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterChangeGameModeAuthorPrelude:


          jmp BS_return
          ;;
          ;; Bitmap Loading
          ;; Bitmap data is loaded automatically by titlescreen kernel
          ;; via includes.
          ;; Generated from Source/Art/Interworldly.xcf →
          ;; Interworldly.png
          ;; SkylineTool creates: Source/Generated/Art.Interworldly.s
          ;; - BitmapInterworldly: 6 columns × 42 bytes (inverted-y)
          ;; - BitmapInterworldlyColors: 84 color values
          ;; (double-height)
          ;; The titlescreen kernel handles bitmap display
          ;; automatically - no explicit loading needed.

.pend

