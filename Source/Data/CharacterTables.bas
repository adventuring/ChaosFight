          rem
          rem ChaosFight - Source/Data/Common/CharacterTables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Character data tables used across multiple banks.
          rem Included from Source/Common/CharacterDefinitions.bas prior to any bank code.

          rem Character weights
          data CharacterWeights
            5, 53, 100, 48, 57, 100, 23, 57, 45, 66, 47, 57, 31, 60, 55, 35
end

          rem Safe fall velocity thresholds (120 / weight)
          data SafeFallVelocityThresholds
            24, 2, 1, 2, 2, 1, 5, 2, 2, 1, 2, 2, 3, 2, 1, 3
end

          rem Weight divided by 20 (damage multiplier helper)
          data WeightDividedBy20
            0, 2, 5, 2, 2, 5, 1, 2, 2, 3, 2, 2, 1, 3, 4, 1
end

          rem Square lookup table (v^2 / 4 for velocities 0-24)
          data SquareTable
            0, 1, 2, 4, 6, 9, 12, 16, 20, 25, 30, 36, 42, 49, 56, 64, 72, 81, 90, 100, 110, 121, 132, 144
end

          rem Character heights (in pixels)
          data CharacterHeights
            10, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
end

          rem Missile widths per character
          data CharacterMissileWidths
             0, 4, 2, 4, 4, 4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile heights per character
          data CharacterMissileHeights
             0, 4, 2, 1, 1, 4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile maximum X travel
          data CharacterMissileMaxX
             4, 8, 6, 6, 6, 6, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile maximum Y travel
          data CharacterMissileMaxY
             4, 6, 6, 6, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile force per character
          data CharacterMissileForce
             3, 5, 4, 4, 4, 0, 0, 0, 4, 0, 0, 0, 0, 0, 4, 0
end

          rem Missile lifetime in frames
          data CharacterMissileLifetime
             4, 255, 255, 255, 255, 4, 5, 6, 255, 5, 4, 4, 3, 5, 5, 4
end

          rem Player bitmask lookup (1,2,4,8)
          data BitMask
             1, 2, 4, 8
end

          rem Character attack type bitfield (packed)
          data CharacterAttackTypes
              %00011110, %00000101, %00000000, %00000000
end

          rem Missile emission heights per character
          data CharacterMissileEmissionHeights
             3, 14, 4, 4, 3, 4, 4, 4, 3, 3, 3, 3, 3, 3, 4, 3
end

          rem Missile spawn offsets (facing right)
          data CharacterMissileSpawnOffsetRight
             0, 17, 18, 18, 18, 17, 0, 8, 20, 0, 20, 0, 0, 6, 0, 0
end

          rem Missile spawn offsets (facing left, two’s complement)
          data CharacterMissileSpawnOffsetLeft
             0, 251, 252, 250, 250, 251, 0, 8, 251, 0, 250, 0, 0, 6, 0, 0
end

          rem Missile horizontal momentum
          data CharacterMissileMomentumX
             5, 6, 4, 6, 0, 0, 5, 8, 6, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile vertical momentum
          data CharacterMissileMomentumY
             0, 0, -4, 0, 0, 0, 4, 0, -5, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile behaviour flags
          data CharacterMissileFlags
            0, MissileFlagCurlerFull, MissileFlagHitBackgroundAndGravity, MissileFlagHitBackground, 0, 0, 0, 0, MissileFlagHitBackgroundAndGravity, 0, 0, 0, 0, 0, 0, 0
end

          rem Area-of-effect offsets
          data CharacterAOEOffsets
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
end

