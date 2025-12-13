;;; ConsoleHandling.bas - Console switch handling


WarmStart .proc
          ;; Warm Start / Reset Handler
          ;; Returns: Far (return otherbank) - jumps to BeginPublisherPrelude
          ;;
          ;; Input: None (called from cold start procedure in Reset handler)
          ;;
          ;; Output: All memory cleared, TIA registers initialized, PIA RIOT ports initialized,
          ;; controller detection performed, jumps to BeginPublisherPrelude
          ;;
          ;; Mutates: All RAM ($81-$FF), SCRAM (w000-w127 via $F000-$F07F), TIA registers, PIA RIOT ports,
          ;; controllerStatus (via DetectPads)
          ;;
          ;; Called Routines: DetectPads (bank13) - controller detection,
          ;; BeginPublisherPrelude (bank14) - publisher prelude entry
          ;;
          ;; Constraints: Entry point for warm start (called from cold start procedure)
          ;; Must clear memory before any stack operations
          
          ;; Step 1: Clear all memory from $81 to $FF (zero-page RAM) and SCRAM w000-w127 together
          ;; SCRAM write ports are at $F000-$F07F (w000-w127)
          ;; SCRAM read ports are at $F080-$F0FF (r000-r127)
          ;; Must write to write ports, not read ports
          ;; Iterate from $7F down to $01, writing to both $80,x (ZPRAM $FF-$81) and $F000,x (SCRAM $F07F-$F001)
          ;; Then iterate from $7F down to $00 for SCRAM only (clearing $F07F-$F000)
          ;; Never write to $80 (console7800Detected at $80 must be preserved)
          lda # 0
          ldx # $7F                        ;;; Start at $7F, iterate down to $01
WarmStartClearMemory:
          ;; Clear zero-page RAM at $80,x (which is $FF down to $81 when X = $7F down to $01)
          ;; X never reaches 0 in this loop, so we never write to $80+0=$80
          sta $80,x                        ;;; Clear zero-page RAM ($80+$7F=$FF down to $80+$01=$81)
          ;; Clear SCRAM at $F000,x
          sta $F000,x                      ;;; Clear SCRAM write ports ($F000+$7F=$F07F down to $F000+$01=$F001)
          dex                              ;;; Decrement X
          bne WarmStartClearMemory         ;;; Continue until X wraps from $01 to $00 (bne fails when X becomes $00)
          ;; X is now $00, clear remaining SCRAM from $7F down to $00 (never write to $80)
          ldx # $7F                        ;;; Start at $7F, iterate down to $00
WarmStartClearSCRAM:
          sta $F000,x                      ;;; Clear SCRAM write ports ($F000+$7F=$F07F down to $F000+$00=$F000)
          dex                              ;;; Decrement X
          bpl WarmStartClearSCRAM          ;;; Continue until X wraps from $00 to $FF (bpl fails when X becomes $FF)
          ;; X is now $FF (wrapped), loop complete
          
          ;; Step 3: Clear TIA registers
          ;; Clear all TIA registers to safe defaults
          lda # 0
          sta VSYNC                        ;;; Vertical sync
          sta VBLANK                       ;;; Vertical blank
          sta WSYNC                        ;;; Wait for sync
          sta RSYNC                        ;;; Reset sync
          sta NUSIZ0                       ;;; Number/size player 0
          sta NUSIZ1                       ;;; Number/size player 1
          sta COLUP0                       ;;; Color/luminance player 0
          sta COLUP1                       ;;; Color/luminance player 1
          sta COLUPF                       ;;; Color/luminance playfield
          sta COLUBK                       ;;; Color/luminance background
          sta CTRLPF                       ;;; Control playfield
          sta REFP0                        ;;; Reflect player 0
          sta REFP1                        ;;; Reflect player 1
          sta PF0                          ;;; Playfield register 0
          sta PF1                          ;;; Playfield register 1
          sta PF2                          ;;; Playfield register 2
          sta RESP0                        ;;; Reset player 0
          sta RESP1                        ;;; Reset player 1
          sta RESM0                        ;;; Reset missile 0
          sta RESM1                        ;;; Reset missile 1
          sta RESBL                        ;;; Reset ball
          sta AUDC0                        ;;; Audio control 0
          sta AUDC1                        ;;; Audio control 1
          sta AUDF0                        ;;; Audio frequency 0
          sta AUDF1                        ;;; Audio frequency 1
          sta AUDV0                        ;;; Audio volume 0
          sta AUDV1                        ;;; Audio volume 1
          sta GRP0                         ;;; Graphics player 0
          sta GRP1                         ;;; Graphics player 1
          sta ENAM0                        ;;; Enable missile 0
          sta ENAM1                        ;;; Enable missile 1
          sta ENABL                        ;;; Enable ball
          sta HMP0                         ;;; Horizontal motion player 0
          sta HMP1                         ;;; Horizontal motion player 1
          sta HMM0                         ;;; Horizontal motion missile 0
          sta HMM1                         ;;; Horizontal motion missile 1
          sta HMBL                         ;;; Horizontal motion ball
          sta VDELP0                       ;;; Vertical delay player 0
          sta VDELP1                       ;;; Vertical delay player 1
          sta VDELBL                       ;;; Vertical delay ball
          sta HMOVE                        ;;; Apply horizontal motion
          sta HMCLR                        ;;; Clear horizontal motion
          
          ;; Step 4: Initialize PIA RIOT I/O ports
          ;; RIOT (6532) I/O ports: SWCHA ($0280) and SWCHB ($0282) are read-only
          ;; Timer registers can be initialized:
          ;; TIM1T ($0294) - set 1 clock interval
          ;; TIM8T ($0295) - set 8 clock intervals  
          ;; TIM64T ($0296) - set 64 clock intervals
          ;; T1024T ($0297) - set 1024 clock intervals
          ;; Initialize timer to a known state (1 clock interval - will expire immediately)
          lda # 0
          sta TIM1T                        ;;; Set timer to 1 clock interval
          
          ;; Step 5: Perform input controller detection for Quadtari, Joy2b+, or MegaDrive controllers
          ;; DetectPads is in Bank 12 (same bank as WarmStart), but it uses jmp BS_return
          ;; so we must use BS_jsr even though it's same-bank (inefficient but correct)
          ;; STACK PICTURE: [] (empty, WarmStart entry)
          lda # ((>(AfterDetectPadsWarmStart-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterDetectPadsWarmStart hi (encoded)]
          lda # <(AfterDetectPadsWarmStart-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterDetectPadsWarmStart hi] [SP+0: AfterDetectPadsWarmStart lo]
          lda # ((>(DetectPads-1)) & $0f) | $c0  ;;; Encode bank 12 in high nybble
          pha
          ;; STACK PICTURE: [SP+2: AfterDetectPadsWarmStart hi] [SP+1: AfterDetectPadsWarmStart lo] [SP+0: DetectPads hi (encoded)]
          lda # <(DetectPads-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterDetectPadsWarmStart hi] [SP+2: AfterDetectPadsWarmStart lo] [SP+1: DetectPads hi] [SP+0: DetectPads lo]
          ldx # 12                         ;;; Bank 12 = $ffe0 + 12, 0-based = 12
          jmp BS_jsr

AfterDetectPadsWarmStart:
          ;; STACK PICTURE: [] (empty, BS_return consumed 4 bytes)

          ;; Step 6: Go to publisher prelude
          ;; Set game mode to Publisher Prelude
          lda # ModePublisherPrelude
          sta gameMode
          
          ;; Cross-bank call to BeginPublisherPrelude in bank 13
          ;; STACK PICTURE: [] (empty, after previous BS_return)
          lda # >(AfterBeginPublisherPreludeWarmStart-1)
          pha
          ;; STACK PICTURE: [SP+0: AfterBeginPublisherPreludeWarmStart hi]
          lda # <(AfterBeginPublisherPreludeWarmStart-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterBeginPublisherPreludeWarmStart hi] [SP+0: AfterBeginPublisherPreludeWarmStart lo]
          lda # >(BeginPublisherPrelude-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterBeginPublisherPreludeWarmStart hi] [SP+1: AfterBeginPublisherPreludeWarmStart lo] [SP+0: BeginPublisherPrelude hi]
          lda # <(BeginPublisherPrelude-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterBeginPublisherPreludeWarmStart hi] [SP+2: AfterBeginPublisherPreludeWarmStart lo] [SP+1: BeginPublisherPrelude hi] [SP+0: BeginPublisherPrelude lo]
          ldx # 13                         ;;; Bank 13 = $ffe0 + 13, 0-based = 13
          jmp BS_jsr

AfterBeginPublisherPreludeWarmStart:
          ;; STACK PICTURE: [] (empty, BS_return consumed 4 bytes)

          ;; Jump to MainLoop in bank 15 without pushing to stack
          ;; CRITICAL: MainLoop is in Bank 15, WarmStart is in Bank 12
          ;; MainLoop is an infinite loop - it NEVER returns, so we must NOT push bytes to stack
          ;; Switch banks directly using nop $ffe0, x then jump
          ;; STACK PICTURE: [] (empty - no bytes pushed)
          ldx # 14                         ;;; Bank 15 = $ffe0 + 14, 0-based = 14
          nop $ffe0, x                     ;;; Switch to bank 15
          jmp MainLoop                     ;;; Jump directly to MainLoop (no stack push)

.pend

HandleConsoleSwitches .proc

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
          bne SetPausedFlag
          ;; Set systemFlags = systemFlags | SystemFlagGameStatePausedjmp Player1PauseDone
SetPausedFlag:

          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags

Player1PauseDone:
          ;; Debounce - wait for button release (drawscreen called by
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;; MainLoop)
          jmp BS_return

DonePlayer1Pause:
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
          bne SetPausedFlagP2
          ;; Set systemFlags = systemFlags | SystemFlagGameStatePaused, then jump to Player2PauseDone
SetPausedFlagP2:

          lda systemFlags
          and ClearSystemFlagGameStatePaused
          sta systemFlags

Player2PauseDone:
          ;; Debounce - wait for button release (drawscreen called by
          ;; Returns: Far (return otherbank)
          ;; HandleConsoleSwitches is called cross-bank, so must use return otherbank
          ;; MainLoop)
          jmp BS_return

DonePlayer2Pause:
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
          ;; STACK PICTURE: [SP+1: caller ret hi] [SP+0: caller ret lo] (from jsr CheckEnhancedPause)
          ;; RTS will pop 2 bytes and return to caller
          rts

          Then check enhanced pause buttons for the specified player
          ;; Joy2B+ Button III uses different registers than Button II/C
          lda temp2
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
          ;; If controllerStatus & SetLeftPortGenesis then if !INPT0{7}, set temp1 = 1
          lda controllerStatus
          and # SetLeftPortGenesis
          beq CheckJoy2bPlus
          bit INPT0
          bmi CheckJoy2bPlus
          lda # 1
          sta temp1
          jmp CheckPlayer1EnhancedPauseDone
CheckJoy2bPlus:
          ;; If controllerStatus & SetLeftPortJoy2bPlus and !INPT1{7}, set temp1 = 1
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
          bne CheckINPT3
          lda # 1
          sta temp1
CheckINPT3:

          lda INPT3
          and # 128
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

          ;; Constraints: Must be colocated with DoneSwitchChange (called via jmp)
          ;; Optimized: Check Color/B&W switch state change directly
          lda # 0
          sta temp6
          ;; If switchbw, set temp6 = 1
          lda switchbw
          beq CheckSwitchChanged
          lda # 1
          sta temp6
CheckSwitchChanged:
          lda temp6
          cmp colorBWPrevious_R
          bne TriggerDetectPads
          jmp DoneSwitchChange
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

DoneSwitchChange:
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
          ;; If temp1 is non-zero, reload arena colors now
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

