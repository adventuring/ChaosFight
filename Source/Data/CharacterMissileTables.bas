          rem
          rem ChaosFight - Source/Data/CharacterMissileTables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Character missile data tables for Bank 7.

          rem Character weights (needed for missile calculations)
          data CharacterWeights
            5, 53, 100, 48, 57, 100, 23, 57, 45, 66, 47, 57, 31, 60, 55, 35
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

          rem Missile force
          data CharacterMissileForce
            4, 6, 4, 6, 6, 6, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile lifetime
          data CharacterMissileLifetime
            8, 16, 12, 12, 12, 12, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0
end

          rem Missile emission heights
          data CharacterMissileEmissionHeights
            8, 8, 8, 8, 8, 8, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0
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

          rem Bit mask lookup table
          data BitMask
            1, 2, 4, 8, 16, 32, 64, 128
end
