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
          ;; Check for Quadtari
          if INPT0{7} then CDP_CheckRightSide

          if !INPT1{7} then CDP_CheckRightSide
          bit INPT1
          bmi CheckLeftSideQuadtari

          jmp CDP_CheckRightSide

CheckLeftSideQuadtari:

          jmp CDP_QuadtariFound

.pend

CDP_CheckRightSide .proc
          ;; if INPT2{7} then jmp CDP_CheckGenesis

          ;; fall through to CDP_QuadtariFound
          if !INPT3{7} then jmp CDP_CheckGenesis
          bit INPT3
          bmi CheckRightSideQuadtari

          jmp CDP_CheckGenesis

CheckRightSideQuadtari:

CDP_QuadtariFound:
          ;; Returns: Far (return otherbank)
          lda temp2
          ora # SetQuadtariDetected
          sta temp2
          jmp CDP_MergeStatus

.pend

CDP_CheckGenesis .proc
          ;; Check for Genesis controller (only if Quadtari not already
          ;; Returns: Far (return otherbank)
          ;; detected)
          ;; If Quadtari was previously detected, skip all other
          ;; detection
          ;; if temp1 & SetQuadtariDetected then jmp CDP_MergeStatus

          ;; Genesis controllers pull INPT0 and INPT1 HIGH when idle
          ;; Method: Ground paddle ports via VBLANK, wait a frame,
          ;; check levels
          ;; Detect Genesis/MegaDrive controllers using correct method
          ;; TODO: #1251 Implement Genesis detection logic

.pend

CDP_MergeStatus .proc
          ;; Merge detected capabilities into controllerStatus
          ;; Returns: Far (return otherbank)
          lda controllerStatus
          ora temp2
          sta controllerStatus
          jmp BS_return

.pend

