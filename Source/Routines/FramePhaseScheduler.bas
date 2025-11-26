          rem ChaosFight - Source/Routines/FramePhaseScheduler.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateFramePhase
          rem Frame Budgeting System
          rem Manages expensive operations across multiple frames to
          rem ensure game logic never exceeds the overscan period.
          rem Updates framePhase (0-3) once per frame to schedule multi-frame operations.
          rem
          rem Input: frame (global) = global frame counter
          rem
          rem Output: framePhase set to frame & 3 (cycles 0, 1, 2, 3, 0, 1, 2, 3...)
          rem
          rem Mutates: framePhase (set to frame & 3)
          rem
          rem Called Routines: None
          rem Constraints: Called once per frame at the start of game loop
          rem Cycle 0, 1, 2, 3, 0, 1, 2, 3...
          let framePhase = frame & 3
          return thisbank


