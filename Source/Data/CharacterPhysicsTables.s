rem_label_1_L1:

;;; ChaosFight - Source/Data/CharacterPhysicsTables.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
rem_label_2_1_L5:

          ;; Character physics tables shared between banks.

          ;; Safe fall velocity thresholds (120 ÷ weight)
SafeFallVelocityThresholds:
          .byte 24, 2, 1, 2, 2, 1, 5, 2, 2, 1, 2, 2, 3, 2, 1, 3
SafeFallVelocityThresholds_end:

          ;; Weight divided by 20 (damage multiplier helper)
WeightDividedBy20:
          .byte 0, 2, 5, 2, 2, 5, 1, 2, 2, 3, 2, 2, 1, 3, 4, 1
WeightDividedBy20_end:

          ;; Square lookup table (v² ÷ 4 for velocities 0-24)
SquareTable
asm_1:

SquareTable
asm_end_1:
SquareTable:
          .byte 0, 1, 2, 4, 6, 9, 12, 16, 20, 25, 30, 36, 42, 49, 56, 64, 72, 81, 90, 100, 110, 121, 132, 144
SquareTable_end:
