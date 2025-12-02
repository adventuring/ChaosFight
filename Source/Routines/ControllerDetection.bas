          rem ControllerDetection.bas - Console and controller detection

CtrlDetConsole
          rem Console detection (7800 vs 2600) - calls ConsoleDetHW
          rem Returns: Far (return otherbank)
          gosub ConsoleDetHW

          rem
          rem Fall through to controller detection

DetectPads
          rem Returns: Far (return otherbank)
          asm

DetectPads

end
          rem Re-detect controllers (monotonic upgrade only)
          rem Returns: Far (return otherbank)
          rem Public entry point used by console handling and character select flows
          rem Input: controllerStatus (global) = existing capabilities, INPT0-5 = paddle port states
          rem Output: controllerStatus updated with any newly detected capabilities
          rem Constraints: Upgrades only – never clears previously detected hardware
          let temp1 = controllerStatus
          let temp2 = 0

#ifndef TV_SECAM
          let systemFlags = systemFlags & ClearSystemFlagColorBWOverride
          let systemFlags = systemFlags & ClearSystemFlagPauseButtonPrev

#endif
          rem Check for Quadtari
          if INPT0{7} then CDP_CheckRightSide

          if !INPT1{7} then CDP_CheckRightSide

          goto CDP_QuadtariFound

CDP_CheckRightSide
          if INPT2{7} then goto CDP_CheckGenesis

          rem fall through to CDP_QuadtariFound
          if !INPT3{7} then goto CDP_CheckGenesis

CDP_QuadtariFound
          rem Returns: Far (return otherbank)
          let temp2 = temp2 | SetQuadtariDetected
          goto CDP_MergeStatus

CDP_CheckGenesis
          rem Check for Genesis controller (only if Quadtari not already
          rem Returns: Far (return otherbank)
          rem   detected)
          rem If Quadtari was previously detected, skip all other
          rem detection
          if temp1 & SetQuadtariDetected then CDP_MergeStatus

          rem Genesis controllers pull INPT0 and INPT1 HIGH when idle
          rem Method: Ground paddle ports via VBLANK, wait a frame,
          rem   check levels
          rem Detect Genesis/MegaDrive controllers using correct method
