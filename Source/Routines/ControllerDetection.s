;;; ControllerDetection.bas - Console and controller detection

          ;; Include ConsoleDetection.s to get ConsoleDetHW
          .include "ConsoleDetection.s"

CtrlDetConsole:
          ;; Console detection (7800 vs 2600) - calls ConsoleDetHW
          ;; Returns: Far (return otherbank)
          jsr ConsoleDetHW

          ;;
          ;; Fall through to controller detection

DetectPads .proc
          ;; Re-detect controllers (monotonic upgrade only)
          ;; Returns: Far (return otherbank)
          ;; Public entry point used by console handling and character select flows
          ;; Input: controllerStatus (global) = existing capabilities, INPT0-5 = paddle port sta

          ;; Output: controllerStatus updated with any newly detected capabilities
          ;; Constraints: Upgrades only – never clears previously detected hardware
          lda controllerStatus
          sta temp1
          lda # 0
          sta temp2

          ;; Clear system flags for NTSC/PAL (not SECAM)
          .if TVStandard != SECAM
          lda systemFlags
          and # ClearSystemFlagColorBWOverride
          sta systemFlags
          lda systemFlags
          and # ClearSystemFlagPauseButtonPrev
          sta systemFlags
          .fi
          ;; Check for QuadTari on either port (proper detection with timing)
          ;; For QuadTari detection: after grounding paddle ports (VBLANK bit 6 = 1),
          ;; QuadTari switches the second player's fire button to INPT1/INPT3.
          ;; Without QuadTari, these ports float high (idle).
          ;; We need to wait for VBLANK to ground capacitors, then check.
          ;;
          ;; First: wait one frame for capacitors to discharge after grounding
          ;; Set VBLANK bit 6 = 1 (ground paddle ports)
          lda # $40
          ora VBLANK
          sta VBLANK

          ;; Wait for timer to expire (INTIM reaches 0)
          lda INTIM
          bne *-3                    ; Wait for timer to expire (end of frame)

          ;; Left port: INPT1 high (no fire pressed) = QuadTari present
          lda INPT1
          bmi CDP_QuadtariFound

          ;; If INPT1 low, not QuadTari on left port
          jmp CDP_CheckGenesis

CheckRightPortQuadTari:
          ;; Right port: INPT3 high (no fire pressed) = QuadTari present
          lda INPT3
          bmi CDP_QuadtariFound

          ;; If INPT3 low, not QuadTari on right port
          jmp CDP_CheckGenesis

          ;; No QuadTari - check for Genesis controllers

.pend

CDP_QuadtariFound:
          ;; Returns: Far (return otherbank)
          lda temp2
          ora # SetQuadtariDetected
          sta temp2
          jmp CDP_MergeStatus

CDP_CheckRightSide .proc
          ;; Right port: INPT3 high (no fire pressed) = QuadTari present
          lda INPT3
          bmi CDP_QuadtariFound

          jmp CDP_CheckGenesis

.pend

CDP_CheckGenesis .proc
          ;; Check for Genesis controller (only if Quadtari not already
          ;; Returns: Far (return otherbank)
          ;; detected)
          ;; If Quadtari was previously detected, skip all other
          ;; detection
          ;; If temp1 & SetQuadtariDetected, then jmp CDP_MergeStatus
          lda temp1
          and # SetQuadtariDetected
          bne CDP_CheckGenesisDone

          ;; Genesis controllers pull INPT0 and INPT1 HIGH when idle
          ;; Method: Ground paddle ports via VBLANK, wait a frame,
          ;; check levels
          ;; Set VBLANK to ground paddle capacitors (bit 6 = 1)
          lda # $40
          ora VBLANK
          sta VBLANK

          ;; Wait one frame for capacitors to discharge
          ;; This gives us time for the capacitors to drain through joystick ports
          lda INTIM
          bne *-3                    ; Wait for timer to expire (end of frame)

          ;; Check left side (INPT0, INPT1) for Genesis controller
          ;; Genesis controllers will pull these HIGH when idle
          ;; If both HIGH → Genesis present; if either LOW → not Genesis
          lda INPT0
          bmi CheckGenesisRightSide    ; If LOW, not Genesis on left
          lda INPT1
          bmi CheckGenesisRightSide    ; If LOW, not Genesis on left

          ;; Both HIGH → Left side Genesis detected
          lda temp2
          ora # SetLeftPortGenesis
          ora # SetLeftPortJoy2bPlus
          sta temp2

CheckGenesisRightSide:
          ;; Check right side (INPT2, INPT3) for Genesis controller
          lda INPT2
          bpl CDP_CheckGenesisDone       ; If LOW, not Genesis on right
          lda INPT3
          bpl CDP_CheckGenesisDone       ; If LOW, not Genesis on right

          ;; Both HIGH → Right side Genesis detected
          lda temp2
          ora # SetRightPortGenesis
          ora # SetRightPortJoy2bPlus
          sta temp2

CDP_CheckGenesisDone:
          jmp CDP_MergeStatus

.pend

CDP_MergeStatus .proc
          ;; Merge detected capabilities into controllerStatus
          ;; Returns: Far (return otherbank)
          lda controllerStatus
          ora temp2
          sta controllerStatus
          jmp BS_return

.pend