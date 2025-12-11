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
          and # ClearSystemFlagGameStatePaused
          sta systemFlags
          ;; Clear paused flag (0 = normal, not paused, not ending)
          ;; Initialize frame counter to 0 on warm sta

          lda # 0
          sta frame

          ;; Step 2: Reinitialize TIA color registers to safe defaults
          ;; Match ColdStart initialization for consistency
          ;; Background: black (COLUBK starts black, no need to set)
          ;; Playfield: white
          lda # $0E
          sta COLUPF
          ;; Player 0: bright blue
          lda # ColBlue(14)
          sta COLUP0
          ;; Player 1: bright red (multisprite kernel requires _COLUP1)
          lda # ColRed(14)
          sta _COLUP1

          ;; Step 3: Initialize audio channels (silent on reset)
          lda # 0
          sta AUDC0
          lda # 0
          sta AUDV0
          lda # 0
          sta AUDC1
          lda # 0
          sta AUDV1

          ;; Step 4: Clear sprite enable registers
          lda # 0
          sta ENAM0
          lda # 0
          sta ENAM1
          lda # 0
          sta ENABL

          ;; Step 5: Reset game mode to startup sequence
          lda # ModePublisherPrelude
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(AfterChangeGameModeReset-1)
          pha
          lda # <(AfterChangeGameModeReset-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
          ldx # 13
          jmp BS_jsr

AfterChangeGameModeReset:

          jmp BS_return

          ;; Reset complete - return to MainLoop which will dispatch to
          ;; new mode

HandleConsoleSwitches
          ;; Returns: Far (return otherbank)

HandleConsoleSwitches:

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
          bne CheckSelectPressed
CheckSelectPressed:

          ;; Re-detect controllers when Select is pressed
          ;; Cross-bank call to DetectPads in bank 13
          lda # >(AfterDetectPadsSelect-1)
          pha
          lda # <(AfterDetectPadsSelect-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterDetectPadsSelect:


          lda systemFlags
          and SystemFlagGameStatePaused
          cmp # 0
          bne SetPausedFlag
          ;; let systemFlags = systemFlags | SystemFlagGameStatePaused:goto Player1PauseDone
SetPausedFlag:

          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags

Player1PauseDone
          ;; Debounce - wait for button release (drawscreen called by
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;; MainLoop)
          jmp BS_return

DonePlayer1Pause
          lda # 1
          sta temp2
          ;; Check Player 2 buttons
          jsr CheckEnhancedPause

          lda temp1
          bne CheckSelectPressedP2
CheckSelectPressedP2:

          ;; Re-detect controllers when Select is pressed
          ;; Cross-bank call to DetectPads in bank 13
          lda # >(AfterDetectPadsSelectP2-1)
          pha
          lda # <(AfterDetectPadsSelectP2-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterDetectPadsSelectP2:


          lda systemFlags
          and SystemFlagGameStatePaused
          cmp # 0
          bne SetPausedFlagP2
          ;; let systemFlags = systemFlags | SystemFlagGameStatePaused : goto Player2PauseDone
SetPausedFlagP2:

          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags

Player2PauseDone
          ;; Debounce - wait for button release (drawscreen called by
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;; MainLoop)
          jmp BS_return

DonePlayer2Pause
          ;; Color/B&W switch - re-detect controllers when toggled
          ;; CRITICAL: Use bank13 even though same-bank to match return otherbank
          ;; Cross-bank call to CheckColorBWToggle in bank 13
          lda # >(AfterCheckColorBWToggle-1)
          pha
          lda # <(AfterCheckColorBWToggle-1)
          pha
          lda # >(CheckColorBWToggle-1)
          pha
          lda # <(CheckColorBWToggle-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterCheckColorBWToggle:


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
          jmp BS_return

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
          bne CheckPlayer2Pause
          jmp CheckPlayer1EnhancedPause
CheckPlayer2Pause:


          lda temp2
          cmp # 1
          bne CheckEnhancedPauseDone
          jmp CheckPlayer2EnhancedPause
CheckEnhancedPauseDone:

          rts

.pend

CheckPlayer1EnhancedPause .proc
          ;; Player 1: Check Genesis Button C (INPT0) or Joy2B+ Button III (INPT1)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from CheckEnhancedPause, so use return thisbank
          ;; if controllerStatus & SetLeftPortGenesis then if !INPT0{7} then let temp1 = 1
          lda controllerStatus
          and # SetLeftPortGenesis
          beq CheckJoy2bPlus
          bit INPT0
          bmi CheckJoy2bPlus
          lda # 1
          sta temp1
          jmp CheckPlayer1EnhancedPauseDone
CheckJoy2bPlus:
          ;; if controllerStatus & SetLeftPortJoy2bPlus then if !INPT1{7} then let temp1 = 1
          lda controllerStatus
          and # SetLeftPortJoy2bPlus
          beq CheckPlayer1EnhancedPauseDone
          bit INPT1
          bmi CheckPlayer1EnhancedPauseDone
          lda # 1
          sta temp1
CheckPlayer1EnhancedPauseDone:
          rts

.pend

CheckPlayer2EnhancedPause .proc
          ;; Player 2: Check Genesis Button C (INPT2) or Joy2B+ Button III (INPT3)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from CheckEnhancedPause, so use return thisbank
          lda INPT2
          and # 128
          cmp # 0
          bne CheckINPT3
          lda # 1
          sta temp1
CheckINPT3:

          lda INPT3
          and # 128
          cmp # 0
          bne CheckPlayer2EnhancedPauseDone
          lda # 1
          sta temp1
CheckPlayer2EnhancedPauseDone:

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
          ;; if switchbw then let temp6 = 1
          lda switchbw
          beq CheckSwitchChangedLabel
          lda # 1
          sta temp6
CheckSwitchChangedLabel:
          jmp CheckSwitchChangedLabel
CheckSwitchChanged:
          lda temp6
          cmp colorBWPrevious_R
          bne TriggerDetectPads
          ;; TODO: #1310 DoneSwitchChange
TriggerDetectPads:

          ;; Cross-bank call to DetectPads in bank 13
          lda # >(AfterDetectPadsColorBW-1)
          pha
          lda # <(AfterDetectPadsColorBW-1)
          pha
          lda # >(DetectPads-1)
          pha
          lda # <(DetectPads-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterDetectPadsColorBW:


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
          ;; if temp1 then ReloadArenaColorsNow
          lda temp1
          beq CheckColorBWToggleDone
          jmp ReloadArenaColorsNow
          jmp ReloadArenaColorsNow
CheckColorBWToggleDone:
          
          ;; Check7800PauseButton
          ;; (NTSC/PAL only, not SECAM)
          ;; CRITICAL: CheckColorBWToggle is called from HandleConsoleSwitches which is
          ;; called cross-bank, so this return must be return otherbank
          jmp BS_return

.pend

ReloadArenaColorsNow .proc
          ;; Reload arena colors with current switch sta

          ;; Returns: Far (return otherbank)
          ;; CheckColorBWToggle is called cross-bank, so must use return otherbank
          ;; Cross-bank call to ReloadArenaColors in bank 14
          lda # >(AfterReloadArenaColors-1)
          pha
          lda # <(AfterReloadArenaColors-1)
          pha
          lda # >(ReloadArenaColors-1)
          pha
          lda # <(ReloadArenaColors-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterReloadArenaColors:


          jmp BS_return

.pend

