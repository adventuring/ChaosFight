;;; ChaosFight - Source/Routines/TitleScreenMain.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


TitleScreenMain .proc
          ;; Title Screen - Per-frame Loop
          ;; Returns: Far (return otherbank)
          ;; Per-frame title screen display and input handling.
          ;; Called from MainLoop each frame (gameMode 2).
          ;; Dispatches to other modules for character parade and rendering.
          ;; Setup is handled by BeginTitleScreen (called from ChangeGameMode)
          ;; This function processes one frame and returns.
          ;; AVAILABLE VARIABLES (from Variables.bas):
          ;; titleParadeTimer - Frame counter for parade timing
          ;; titleParadeCharacter - Current parade character
          ;; (0-MaxCharacter)
          ;; titleParadeX - X position of parade character
          ;; titleParadeActive - Whether parade is currently running
          ;; QuadtariDetected - Whether 4-player mode is active
          ;; FLOW PER FRAME:
          ;; 1. Update random number generator (every frame)
          ;; 2. Handle input - any button press goes to character
          ;; select
          ;; 3. Update character parade
          ;; 4. Draw screen
          ;; 5. Return to MainLoop
          ;; Per-frame title screen display and input handling
          ;;
          ;; Input: joy0fire, joy1fire (hardware) = button sta

          ;; controllerStatus (global) = controller detection
          ;; sta

          ;; INPT0, INPT2 (hardware) = Quadtari controller
          ;; sta

          ;;
          ;; Output: Dispatches to TitleScreenComplete or returns
          ;;
          ;; Mutates: rand (global) - random number generator sta

          ;;
          ;; Called Routines: UpdateCharacterParade (bank14) - accesses
          ;; parade sta

          ;; DrawTitleScreen (bank9) - accesses title screen sta

          ;; titledrawscreen bank9 - accesses title screen graphics
          ;;
          ;; Constraints: Must be colocated with TitleSkipQuad,
          ;; TitleScreenComplete
          ;; Called from MainLoop each frame (gameMode 2)
          ;; Update random number generator (inlined to save 2 bytes on sta

          ;; CRITICAL: Inlined randomize routine (only called once, saves 2 bytes vs gosub)
          ;;
          ;; Inlined randomize routine to save stack space
          lda rand
          lsr
          .if  rand16_W
          ;; CRITICAL:

          ;; TODO: #1311 ; Must read from read port, perform operation in register, write to write port
          lda rand16_R
          rol
          sta rand16_W
          .fi

          bcc TitleScreenRandomizeNoEor

          eor #$B4

TitleScreenRandomizeNoEor:
          sta rand
          .if  rand16_W
          ;; CRITICAL:


rand16:


          eor rand16_R
fi:

          ;; Handle input - any button press goes to character select
          ;; Check standard controllers (Player 1 & 2)
          ;; Use skip-over pattern to avoid complex || operator issues
          if joy0fire then TitleScreenComplete
          lda joy0fire
          beq CheckJoy1Fire
          jmp TitleScreenComplete
CheckJoy1Fire:
          

          if joy1fire then TitleScreenComplete
          lda joy1fire
          beq CheckQuadtariControllers
          jmp TitleScreenComplete
CheckQuadtariControllers:
          

          ;; Check Quadtari controllers (Players 3 & 4 if active)
                    if 0 = (controllerStatus & SetQuadtariDetected) then TitleDoneQuad

                    if !INPT0{7} then TitleScreenComplete
          bit INPT0
          bmi CheckINPT2
          jmp TitleScreenComplete
CheckINPT2:

                    if !INPT2{7} then TitleScreenComplete
          bit INPT2
          bmi TitleDoneQuad
          jmp TitleScreenComplete
TitleDoneQuad:

TitleDoneQuad
          ;; Skip Quadtari controller check (not in 4-player mode)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with TitleScreenMain

          ;; Update character parade animation
          ;; Cross-bank call to UpdateCharacterParade in bank 14
          lda # >(AfterUpdateCharacterParade-1)
          pha
          lda # <(AfterUpdateCharacterParade-1)
          pha
          lda # >(UpdateCharacterParade-1)
          pha
          lda # <(UpdateCharacterParade-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterUpdateCharacterParade:


          ;; Draw title screen
          ;; CRITICAL: Do NOT call DrawTitleScreen here - MainLoopDrawScreen (MainLoop.bas line 139)
          ;; handles per-frame drawing. Calling it here would cause stack overflow (16-byte limit).
          ;; TitleScreenMain is always called via MainLoop, so MainLoopDrawScreen will handle drawing.
          jsr BS_return

TitleScreenComplete
          ;; Transition to character select
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from TitleScreenMain)
          ;;
          ;; Output: gameMode set to ModeCharacterSelect,
          ;; ChangeGameMode called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: ChangeGameMode (bank14) - accesses game
          ;; mode sta

          ;; Constraints: Must be colocated with TitleScreenMain
          lda ModeCharacterSelect
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
                    ldx # 13
          jmp BS_jsr
return_point:


          jsr BS_return

.pend (no matching .proc)

.endif
.endif

.pend
