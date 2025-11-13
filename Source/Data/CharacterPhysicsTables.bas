          rem
          rem ChaosFight - Source/Data/CharacterPhysicsTables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Character physics tables shared between banks.

          rem Safe fall velocity thresholds (120 / weight)
          data SafeFallVelocityThresholds
            24, 2, 1, 2, 2, 1, 5, 2, 2, 1, 2, 2, 3, 2, 1, 3
end

          rem Weight divided by 20 (damage multiplier helper)
          data WeightDividedBy20
            0, 2, 5, 2, 2, 5, 1, 2, 2, 3, 2, 2, 1, 3, 4, 1
end

          rem Square lookup table (v^2 / 4 for velocities 0-24)
SquareTable
          asm
SquareTable
end
          data SquareTable
            0, 1, 2, 4, 6, 9, 12, 16, 20, 25, 30, 36, 42, 49, 56, 64, 72, 81, 90, 100, 110, 121, 132, 144
end
