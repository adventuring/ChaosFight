rem_label:

;;; ChaosFight - Source/Data/CharacterMissileTables.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
rem_label_2:

          ;; Character missile data tables for Bank 7.

          ;; Character weights (needed for missile calculations)
          ;; Issue #1194: Extended to 32 entries, entry 31 (Meth Hound) duplicates entry 15 (Shamone)
CharacterWeights:
          .byte 5, 53, 100, 48, 57, 100, 23, 57, 45, 66, 47, 57, 31, 60, 55, 35
          .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35
CharacterWeights_end:

          ;; Character weight divided by 12 (precomputed for Atari 2600 optimization)
          ;; Values are weight / 12, clamped to 0-8 range
          ;; Used for Ursulo knock-up velocity calculation (avoids expensive division)
          ;; Issue #1194: Extended to 32 entries matching CharacterWeights table
CharacterWeightDiv12:
          .byte 0, 4, 8, 4, 4, 8, 1, 4, 3, 5, 3, 4, 2, 5, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
CharacterWeightDiv12_end:

          ;; Missile widths per character
CharacterMissileWidths:
          .byte 0, 4, 2, 4, 4, 4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
CharacterMissileWidths_end:

          ;; Precomputed NUSIZ values per character (optimization)
          NUSIZ = (width-1)x16, clamped to 0 for width 0
          ;; Precomputed to avoid per-spawn arithmetic: width 0→0, 1→0, 2→16, 4→48
CharacterMissileNUSIZ:
          .byte 0, 48, 16, 48, 48, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
CharacterMissileNUSIZ_end:

          ;; Missile heights per character
CharacterMissileHeights:
          .byte 0, 4, 2, 1, 1, 4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
CharacterMissileHeights_end:

          ;; Missile maximum × travel
CharacterMissileMaxX:
          .byte 4, 8, 6, 6, 6, 6, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
CharacterMissileMaxX_end:

          ;; Missile maximum Y travel
CharacterMissileMaxY:
          .byte 4, 6, 6, 6, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
CharacterMissileMaxY_end:

          ;; Missile force
CharacterMissileForce:
          .byte 4, 6, 4, 6, 6, 6, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0
CharacterMissileForce_end:

          ;; Missile lifetime
CharacterMissileLifetime:
          .byte 8, 16, 12, 12, 12, 12, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0
CharacterMissileLifetime_end:

          ;; Missile emission heights
CharacterMissileEmissionHeights:
          .byte 8, 8, 8, 8, 8, 8, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0
CharacterMissileEmissionHeights_end:

          ;; Missile spawn offsets (facing right)
CharacterMissileSpawnOffsetRight:
          .byte 0, 17, 18, 18, 18, 17, 0, 8, 20, 0, 20, 0, 0, 6, 0, 0
CharacterMissileSpawnOffsetRight_end:

          ;; Missile spawn offsets (facing left, two’s complement)
CharacterMissileSpawnOffsetLeft:
          .byte 0, 251, 252, 250, 250, 251, 0, 8, 251, 0, 250, 0, 0, 6, 0, 0
CharacterMissileSpawnOffsetLeft_end:

          ;; Missile horizontal momentum
CharacterMissileMomentumX:
          .byte 5, 6, 4, 6, 0, 0, 5, 8, 6, 0, 0, 0, 0, 0, 0, 0
CharacterMissileMomentumX_end:

          ;; Missile vertical momentum
CharacterMissileMomentumY:
          .byte 0, 0, 4, 0, 0, 0, 4, 0, 5, 0, 0, 0, 0, 0, 0, 0
CharacterMissileMomentumY_end:

          ;; Missile behaviour flags
CharacterMissileFlags:
          .byte 0, MissileFlagCurlerFull, MissileFlagHitBackgroundAndGravity, MissileFlagHitBackground, 0, 0, 0, 0, MissileFlagHitBackgroundAndGravity, 0, 0, 0, 0, 0, 0, 0
CharacterMissileFlags_end:

          bit mask lookup table
BitMask:
          .byte 1, 2, 4, 8, 16, 32, 64, 128
BitMask_end:
