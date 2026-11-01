;;; ChaosFight - Source/Routines/PublisherPrelude.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Publisher Prelude Screen - Per-frame Loop
;;; Per-frame publisher prelude display and input handling.
;;; Called from MainLoop each frame (gameMode 0).
          ;; Setup handled by BeginPublisherPrelude.
          ;; FLOW PER FRAME (overscan only - minimal work):
          ;; 1. Handle input - any button press skips to author prelude
          ;; 2. Check auto-advance timer (music completion + 0.5s)
          ;; 3. Increment timer
          ;; 4. Return to MainLoop (music and drawing handled by MainLoop)
          ;; BITMAP: 48×42 pixels (48×84 scanlines double-height)
          ;; Uses titlescreen kernel minikernel; bitmap data: Source/Generated/Art.AtariAge.s
          ;;
          ;; Input: joy0fire, joy1fire (hardware) = button state
          ;;        controllerStatus (global) = controller detection state
          ;;        INPT0-3 (hardware) = MegaDrive/Joy2b+ controller button state
          ;;        preambleTimer (global) = frame counter
          ;;        musicPlaying (global) = music playback state
          ;;
          ;; Output: Dispatches to PublisherPreludeComplete or returns
          ;;
          ;; Mutates: preambleTimer (incremented)
          ;;
          ;; Called Routines: None (music handled by MainLoop, window values set in BeginPublisherPrelude)
          ;;
          ;; Constraints: Must be colocated with PublisherPreludeComplete


PublisherPreludeMain .proc
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call (cross-bank call from MainLoop)
          ;; Check for button press on any controller to skip
          ;; Advance only on a *fresh* press (MainLoop sets newFirePress on
          ;; the frame either fire button goes down), so that a single press
          ;; cannot race through several screens while it is held.
          lda fireEdgeState
          bmi PublisherPreludeComplete

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
          ;; Player 1: Genesis Button C (INPT0) or Joy2b+ Button C/II (INPT0)
          lda temp1
          beq CheckPlayer1Joy2bPlusButton3

          lda INPT0
          bpl PublisherPreludeComplete  ; Button pressed (bit 7 = 0)

CheckPlayer1Joy2bPlusButton3:

          ;; Check Joy2b+ Button III (INPT1) for Player 1
          lda controllerStatus
          and # SetLeftPortJoy2bPlus
          beq CheckPlayer2Enhanced

          lda INPT1
          bpl PublisherPreludeComplete  ; Button pressed (bit 7 = 0)

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

          lda INPT2
          bpl PublisherPreludeComplete  ; Button pressed (bit 7 = 0)

CheckPlayer2Joy2bPlusButton3:

          ;; Check Joy2b+ Button III (INPT3) for Player 2
          lda controllerStatus
          and # SetRightPortJoy2bPlus
          beq CheckAutoAdvance

          lda INPT3
          bpl PublisherPreludeComplete  ; Button pressed (bit 7 = 0)

CheckAutoAdvance:

          ;; Skip on fresh fire press
          lda fireEdgeState
          bmi PublisherPreludeComplete

          ;; Auto-advance after music completes + 0.5s
          ;; If preambleTimer > 30 && musicPlaying = 0, then jmp PublisherPreludeComplete
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          lda preambleTimer
          cmp # 31
          bcc IncrementTimer
          lda musicPlaying
          bne IncrementTimer
          jmp PublisherPreludeComplete
IncrementTimer:
          ;; PublisherPreludeComplete

          inc preambleTimer

          ;; Music and drawing handled by MainLoop (PlayMusic and DrawTitleScreen)
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call
          jmp BS_return

PublisherPreludeComplete
          ;; Transition to Author Prelude mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from PublisherPreludeMain)
          ;;
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call (same as PublisherPreludeMain entry)
          ;;
          ;; Output: gameMode set to ModeAuthorPrelude, BeginAuthorPrelude called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: BeginAuthorPrelude (bank14) - sets up author prelude
          ;; Constraints: Must be colocated with PublisherPreludeMain
          ;; OPTIMIZATION: Call BeginAuthorPrelude directly to save 4 bytes (skip ChangeGameMode)
          lda #ModeAuthorPrelude
          sta gameMode
          ;; Cross-bank call to BeginAuthorPrelude in bank 13
          ;; BS_jsr expects: [SP+0: return lo] [SP+1: return hi] [SP+2: target lo] [SP+3: target hi]
          ;; After RTS pops target (SP+2/SP+3 after increment): [SP+0: return lo] [SP+1: return hi]
          ;; Push return FIRST (earliest), target LAST (most recent for RTS to pop)
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterBeginAuthorPrelude-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi (return hi)] [SP+0: AfterBeginAuthorPrelude hi (encoded)]
          lda # <(AfterBeginAuthorPrelude-1)
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterBeginAuthorPrelude hi]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(BeginAuthorPrelude-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: BeginAuthorPrelude hi] [SP+0: AfterBeginAuthorPrelude lo]
          lda # <(BeginAuthorPrelude-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: BeginAuthorPrelude hi] [SP+1: BeginAuthorPrelude lo] [SP+0: AfterBeginAuthorPrelude lo]
          ldx # 13
          jmp BS_jsr
AfterBeginAuthorPrelude:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from BeginAuthorPrelude call, left original 4 bytes)


          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
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

