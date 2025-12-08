;;; ControllerDetection.bas - Console and controller detection

          ;; Include ConsoleDetection.s to get ConsoleDetHW
          .include "ConsoleDetection.s"

CtrlDetConsole
;;; Console detection (7800 vs 2600) - calls ConsoleDetHW
;;; Returns: Far (return otherbank)
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
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)

          ;; TODO: #ifndef TV_SECAM
          ;; lda systemFlags (duplicate)
          and ClearSystemFlagColorBWOverride
          ;; sta systemFlags (duplicate)
          ;; lda systemFlags (duplicate)
          ;; and ClearSystemFlagPauseButtonPrev (duplicate)
          ;; sta systemFlags (duplicate)

          ;; TODO: #.fi
          ;; Check for Quadtari
                    ;; if INPT0{7} then CDP_CheckRightSide

                    ;; if !INPT1{7} then CDP_CheckRightSide
          bit INPT1
          bmi skip_7772
          jmp CDP_CheckRightSide
skip_7772:
          ;; jmp CDP_QuadtariFound (duplicate)

.pend

CDP_CheckRightSide .proc
                    ;; if INPT2{7} then goto CDP_CheckGenesis

          ;; fall through to CDP_QuadtariFound
                    ;; if !INPT3{7} then goto CDP_CheckGenesis
          ;; bit INPT3 (duplicate)
          ;; bmi skip_725 (duplicate)
          ;; jmp CDP_CheckGenesis (duplicate)
skip_725:

CDP_QuadtariFound
          ;; Returns: Far (return otherbank)
          ;; lda temp2 (duplicate)
          ora SetQuadtariDetected
          ;; sta temp2 (duplicate)
          ;; jmp CDP_MergeStatus (duplicate)

.pend

CDP_CheckGenesis .proc
          ;; Check for Genesis controller (only if Quadtari not already
          ;; Returns: Far (return otherbank)
          ;; detected)
          ;; If Quadtari was previously detected, skip all other
          ;; detection
                    ;; if temp1 & SetQuadtariDetected then goto CDP_MergeStatus

          ;; Genesis controllers pull INPT0 and INPT1 HIGH when idle
          ;; Method: Ground paddle ports via VBLANK, wait a frame,
          ;; check levels
          ;; Detect Genesis/MegaDrive controllers using correct method
          ;; TODO: Implement Genesis detection logic

.pend

CDP_MergeStatus .proc
          ;; Merge detected capabilities into controllerStatus
          ;; Returns: Far (return otherbank)
          ;; lda controllerStatus (duplicate)
          ;; ora temp2 (duplicate)
          ;; sta controllerStatus (duplicate)
          ;; jsr BS_return (duplicate)

.pend

