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
          ;; CRITICAL: Must read from read port, perform operation in register, write to write port
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
          lda rand16_R
          rol
          sta rand16_W
          .fi

          ;; Handle input - any button press goes to character select
          ;; Check standard controllers (Player 1 & 2)
          ;; Use skip-over pattern to avoid complex || operator issues
          ;; If joy0fire, then TitleScreenComplete
          lda joy0fire
          beq CheckJoy1Fire
          jmp TitleScreenComplete
CheckJoy1Fire:
          

          ;; If joy1fire, then TitleScreenComplete
          lda joy1fire
          beq CheckQuadtariControllers
          jmp TitleScreenComplete
CheckQuadtariControllers:
          

          ;; Check Quadtari controllers (Players 3 & 4 if active)
          ;; If controllerStatus & SetQuadtariDetected is 0, skip Quadtari check
          lda controllerStatus
          and # SetQuadtariDetected
          beq TitleDoneQuad

          ;; If !INPT0{7}, then TitleScreenComplete
          bit INPT0
          bmi CheckINPT2
          jmp TitleScreenComplete
CheckINPT2:

          ;; If !INPT2{7}, then TitleScreenComplete
          bit INPT2
          bmi TitleDoneQuad
          jmp TitleScreenComplete
TitleDoneQuad:
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
          ;; Cross-bank call to UpdateCharacterParade in bank 13
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call (cross-bank call from MainLoop)
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterUpdateCharacterParade-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterUpdateCharacterParade hi (encoded)]
          lda # <(AfterUpdateCharacterParade-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterUpdateCharacterParade hi (encoded)] [SP+0: AfterUpdateCharacterParade lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdateCharacterParade-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterUpdateCharacterParade hi (encoded)] [SP+1: AfterUpdateCharacterParade lo] [SP+0: UpdateCharacterParade hi (raw)]
          lda # <(UpdateCharacterParade-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterUpdateCharacterParade hi (encoded)] [SP+2: AfterUpdateCharacterParade lo] [SP+1: UpdateCharacterParade hi (raw)] [SP+0: UpdateCharacterParade lo]
          ldx # 13
          jmp BS_jsr
AfterUpdateCharacterParade:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from UpdateCharacterParade call, left original 4 bytes)


          ;; Draw title screen
          ;; CRITICAL: Do NOT call DrawTitleScreen here - MainLoopDrawScreen (MainLoop.bas line 139)
          ;; handles per-frame drawing. Calling it here would cause stack overflow (16-byte limit).
          ;; TitleScreenMain is always called via MainLoop, so MainLoopDrawScreen will handle drawing.
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend

TitleScreenComplete .proc
          ;; Transition to character select
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from TitleScreenMain)
          ;;
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from BS_jsr call (same as TitleScreenMain entry)
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
          ;; Cross-bank call to ChangeGameMode in bank 13
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Return address: ENCODED with caller bank 13 ($d0) for BS_return to decode
          lda # ((>(AfterChangeGameModeTitle-1)) & $0f) | $d0  ;;; Encode bank 13 in high nybble
          pha
          ;; STACK PICTURE: [SP+4: caller ret hi] [SP+3: caller ret lo] [SP+2: encoded ret hi] [SP+1: encoded ret lo] [SP+0: AfterChangeGameModeTitle hi (encoded)]
          lda # <(AfterChangeGameModeTitle-1)
          pha
          ;; STACK PICTURE: [SP+5: caller ret hi] [SP+4: caller ret lo] [SP+3: encoded ret hi] [SP+2: encoded ret lo] [SP+1: AfterChangeGameModeTitle hi (encoded)] [SP+0: AfterChangeGameModeTitle lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+6: caller ret hi] [SP+5: caller ret lo] [SP+4: encoded ret hi] [SP+3: encoded ret lo] [SP+2: AfterChangeGameModeTitle hi (encoded)] [SP+1: AfterChangeGameModeTitle lo] [SP+0: ChangeGameMode hi (raw)]
          lda # <(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+7: caller ret hi] [SP+6: caller ret lo] [SP+5: encoded ret hi] [SP+4: encoded ret lo] [SP+3: AfterChangeGameModeTitle hi (encoded)] [SP+2: AfterChangeGameModeTitle lo] [SP+1: ChangeGameMode hi (raw)] [SP+0: ChangeGameMode lo]
          ldx # 13
          jmp BS_jsr
AfterChangeGameModeTitle:
          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; (BS_return consumed 4 bytes from ChangeGameMode call, left original 4 bytes)


          ;; STACK PICTURE: [SP+3: caller ret hi] [SP+2: caller ret lo] [SP+1: encoded ret hi] [SP+0: encoded ret lo]
          ;; Expected: 4 bytes on stack from original BS_jsr call
          jmp BS_return

.pend
