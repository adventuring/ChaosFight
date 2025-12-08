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
          ;; if joy0fire then AuthorPreludeComplete
          lda joy0fire
          beq skip_5569
          jmp AuthorPreludeComplete
skip_5569:
          

          ;; if joy1fire then AuthorPreludeComplete
          ;; lda joy1fire (duplicate)
          ;; beq skip_1114 (duplicate)
          ;; jmp AuthorPreludeComplete (duplicate)
skip_1114:
          

          ;; Check MegaDrive/Joy2b+ controllers if detected
          ;; Player 1: Genesis Button C (INPT0) or Joy2b+ Button C/II (INPT0) or Joy2b+ Button III (INPT1)
          ;; OR flags together and check for nonzero match
                    ;; let temp1 = controllerStatus & (SetLeftPortGenesis | SetLeftPortJoy2bPlus)
                    ;; if temp1 then if !INPT0{7} then AuthorPreludeComplete
          ;; lda temp1 (duplicate)
          ;; beq skip_4228 (duplicate)
          bit INPT0
          bmi skip_4228
          ;; jmp AuthorPreludeComplete (duplicate)
skip_4228:
          ;; lda controllerStatus (duplicate)
          and SetLeftPortJoy2bPlus
          sta temp1
                    ;; if temp1 then if !INPT1{7} then AuthorPreludeComplete          lda temp1          beq skip_933
skip_933:

          ;; Player 2: Genesis Button C (INPT2) or Joy2b+ Button C/II (INPT2) or Joy2b+ Button III (INPT3)
                    ;; let temp1 = controllerStatus & (SetRightPortGenesis | SetRightPortJoy2bPlus)
          ;; lda controllerStatus (duplicate)
          ;; and # 96 (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if temp1 then if !INPT2{7} then AuthorPreludeComplete
          ;; lda temp1 (duplicate)
          ;; beq skip_5977 (duplicate)
          ;; bit INPT2 (duplicate)
          ;; bmi skip_5977 (duplicate)
          ;; jmp AuthorPreludeComplete (duplicate)
skip_5977:
          ;; lda controllerStatus (duplicate)
          ;; and SetRightPortJoy2bPlus (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if temp1 then if !INPT3{7} then AuthorPreludeComplete          lda temp1          beq skip_5554
skip_5554:
          ;; jmp skip_5554 (duplicate)


          ;; Auto-advance after music completes + 0.5s
                    ;; if preambleTimer > 30 && musicPlaying = 0 then AuthorPreludeComplete
          ;; lda preambleTimer (duplicate)
          cmp # 31
          bcc skip_6974
          ;; lda musicPlaying (duplicate)
          bne skip_6974
          ;; jmp AuthorPreludeComplete (duplicate)
skip_6974:

          inc preambleTimer
          jsr BS_return

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
          ;; lda ModeTitle (duplicate)
          ;; sta gameMode (duplicate)
          ;; Cross-bank call to ChangeGameMode in bank 14
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 13
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; jsr BS_return (duplicate)
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

