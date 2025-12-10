;;; ConsoleHandling.bas - Console switch handling


WarmStart .proc



          ;; Warm Start / Reset Handler
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from MainLoop on RESET)
          ;;
          ;; Output: gameMode set to ModePublisherPrelude,
          ;; ChangeGameMode called, TIA registers initialized
          ;;
          ;; Mutates: systemFlags (paused flag cleared), frame (reset
          ;; to 0), gameMode (set to ModePublisherPrelude),
          ;; COLUBK, COLUPF, COLUP0, _COLUP1 (TIA color
          ;; registers),
          ;; AUDC0, AUDV0, AUDC1, AUDV1 (TIA audio registers),
          ;; ENAM0, ENAM1, ENABL (sprite enable registers)
          ;;
          ;; Called Routines: ChangeGameMode (bank14) - accesses game
          ;; mode sta

          ;;
          ;; Constraints: Entry point for warm start/reset (called from
          ;; MainLoop)
          ;; Step 1: Clear critical game state variables
          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags
          ;; Clear paused flag (0 = normal, not paused, not ending)
          ;; Initialize frame counter to 0 on warm sta

          lda # 0
          sta frame

          ;; Step 2: Reinitialize TIA color registers to safe defaults
          ;; Match ColdStart initialization for consistency
          ;; Background: black (COLUBK starts black, no need to set)
          ;; Playfield: white
          COLUPF = $0E(14)
          ;; Player 0: bright blue
          COLUP0 = ColBlue(14)
          ;; Player 1: bright red (multisprite kernel requires _COLUP1)
          _COLUP1 = ColRed(14)

          ;; Step 3: Initialize audio channels (silent on reset)
          AUDC0 = 0
          AUDV0 = 0
          AUDC1 = 0
          AUDV1 = 0

          ;; Step 4: Clear sprite enable registers
          ENAM0 = 0
          ENAM1 = 0
          ENABL = 0

          ;; Step 5: Reset game mode to startup sequence
          lda ModePublisherPrelude
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
          ;; Reset complete - return to MainLoop which will dispatch to
          ;; new mode

HandleConsoleSwitches
          ;; Returns: Far (return otherbank)

HandleConsoleSwitches



          ;; Main console switch handler
          ;; Returns: Far (return otherbank)
          ;;
          ;; Game Select switch or Joy2B+ Button III - toggle pause
          ;; mode
          lda # 0
          sta temp2
          ;; Check Player 1 buttons
          jsr CheckEnhancedPause

          lda temp1
          bne skip_2900
skip_2900:

          ;; Re-detect controllers when Select is pressed
          ;; Cross-bank call to DetectPads in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          lda systemFlags
          and SystemFlagGameStatePaused
          cmp # 0
          bne skip_1411
          ;; let systemFlags = systemFlags | SystemFlagGameStatePaused:goto Player1PauseDone
skip_1411:

          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags

Player1PauseDone
          ;; Debounce - wait for button release (drawscreen called by
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;; MainLoop)
          jsr BS_return

DonePlayer1Pause
          lda # 1
          sta temp2
          ;; Check Player 2 buttons
          jsr CheckEnhancedPause

          lda temp1
          bne skip_4884
skip_4884:

          ;; Re-detect controllers when Select is pressed
          ;; Cross-bank call to DetectPads in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          lda systemFlags
          and SystemFlagGameStatePaused
          cmp # 0
          bne skip_3376
          ;; let systemFlags = systemFlags | SystemFlagGameStatePaused : goto Player2PauseDone
skip_3376:

          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags

Player2PauseDone
          ;; Debounce - wait for button release (drawscreen called by
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;; MainLoop)
          jsr BS_return

DonePlayer2Pause
          ;; Color/B&W switch - re-detect controllers when toggled
          ;; CRITICAL: Use bank13 even though same-bank to match return otherbank
          ;; Cross-bank call to CheckColorBWToggle in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckColorBWToggle-1)
          pha
          lda # <(CheckColorBWToggle-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          ;; 7800 Pause button - toggle Color/B&W mode (not in SECAM)
          .if TVStandard != SECAM
          ;; tail call
          jmp Check7800Pause
          .fi

.pend

Check7800Pause .proc
          ;; 7800 pause button handler (uses same pin as Color/B&W switch)
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;;
          ;; Note: 7800 pause button behavior is handled by CheckColorBWToggle
          ;; which detects switchbw changes and toggles colorBWOverride.
          ;; This function is a placeholder for future 7800-specific pause handling.
          ;;
          ;; Constraints: NTSC/PAL only (not SECAM)
          jsr BS_return

.pend

CheckEnhancedPause .proc



          ;; Check if pause buttons are pressed (console Game Select switch or enhanced controller buttons)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from HandlePauseButton, so use return thisbank
          ;; Game Select switch (always) + Joy2B+ Button III (INPT1/INPT3) or Genesis Button C (INPT0/INPT2)
          ;;
          ;; Input: temp2 = player index (0=Player 1, 1=Player 2)
          ;; controllerStatus (global) = controller capabilities
          ;; switchselect (hardware) = Game Select switch
          ;; INPT0-3 (hardware) = paddle port sta

          ;;
          ;; Output: temp1 = 1 if any pause button pressed, 0 otherwise
          ;;
          ;; Mutates: temp1
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;; Default to no pause button pressed
          lda # 0
          sta temp1

          ;; Always check Game Select switch first (works with any controller)
          rts

          Then check enhanced pause buttons for the specified player
          ;; Joy2B+ Button III uses different registers than Button II/C
          lda temp2
          cmp # 0
          bne skip_9581
          jmp CEP_CheckPlayer1
skip_9581:


          lda temp2
          cmp # 1
          bne skip_8204
          jmp CEP_CheckPlayer2
skip_8204:

          rts

.pend

CEP_CheckPlayer1 .proc
          ;; Player 1: Check Genesis Button C (INPT0) or Joy2B+ Button III (INPT1)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from CheckEnhancedPause, so use return thisbank
                    if controllerStatus & SetLeftPortGenesis then if !INPT0{7} then let temp1 = 1
                    if controllerStatus & SetLeftPortJoy2bPlus then if !INPT1{7} then let temp1 = 1
          lda controllerStatus
          and SetLeftPortJoy2bPlus
          beq skip_4516
          bit INPT1
          bmi skip_4516
          lda # 1
          sta temp1
skip_4516:
          rts

.pend

CEP_CheckPlayer2 .proc
          ;; Player 2: Check Genesis Button C (INPT2) or Joy2B+ Button III (INPT3)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from CheckEnhancedPause, so use return thisbank
          lda INPT2
          and # 128
          cmp # 0
          bne skip_6018
          lda # 1
          sta temp1
skip_6018:

          lda INPT3
          and # 128
          cmp # 0
          bne skip_4127
          lda # 1
          sta temp1
skip_4127:

          rts
          ;;
          ;; Color/B&W switch change detection (triggers controller re-detect)

.pend

CheckColorBWToggle .proc

          ;; Check switch state and trigger DetectPads when it flips
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;;
          ;; Input: switchbw (hardware) = Color/B&W switch sta

          ;; colorBWPrevious_R (global SCRAM) = previous
          ;; Color/B&W switch sta

          ;;
          ;; Output: colorBWPrevious_W updated, DetectPads
          ;; called if switch changed
          ;;
          ;; Mutates: temp1 (switch changed flag), temp6 (used for
          ;; switchbw read),
          ;; colorBWPrevious_W (updated if switch changed)
          ;;
          ;; Called Routines: DetectPads (bank13) - accesses
          ;; controller detection sta

          ;; Constraints: Must be colocated with DoneSwitchChange (called via goto)
          ;; Optimized: Check Color/B&W switch state change directly
          lda # 0
          sta temp6
          if switchbw then let temp6 = 1
          lda switchbw
          beq skip_1649
          jmp skip_1649
skip_1649:
          lda temp6
          cmp colorBWPrevious_R
          bne skip_7622
          ;; TODO: DoneSwitchChange
skip_7622:

          ;; Cross-bank call to DetectPads in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          lda temp6
          sta colorBWPrevious_W

DoneSwitchChange
          ;; Color/B&W switch change check complete (label only, no
          ;; Returns: Near (return thisbank)
          ;; execution)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with CheckColorBWToggle
          ;; Check if colorBWOverride changed (7800 pause button)
          ;; Note: colorBWOverride does not have a previous value
          ;; stored,
          ;; so we check it every frame (NTSC/PAL only, not SECAM).
          ;; This is acceptable since it is only toggled by button
          ;; press,
          ;; not continuously. If needed, we could add a previous
          ;; value
          ;; variable.
          ;; Reload arena colors if switch or override changed
          ;; Note: colorBWOverride check handled in
          if temp1 then ReloadArenaColorsNow
          lda temp1
          beq skip_9286
          jmp ReloadArenaColorsNow
skip_9286:
          
          ;; Check7800PauseButton
          ;; (NTSC/PAL only, not SECAM)
          ;; CRITICAL: CheckColorBWToggle is called from HandleConsoleSwitches which is
          ;; called cross-bank, so this return must be return otherbank
          jsr BS_return

.pend

ReloadArenaColorsNow .proc
          ;; Reload arena colors with current switch sta

          ;; Returns: Far (return otherbank)
          ;; CheckColorBWToggle is called cross-bank, so must use return otherbank
          ;; Cross-bank call to ReloadArenaColors in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ReloadArenaColors-1)
          pha
          lda # <(ReloadArenaColors-1)
          pha
                    ldx # 13
          jmp BS_jsr
return_point:


          jsr BS_return

.pend

