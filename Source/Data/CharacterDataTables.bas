          rem
          rem ChaosFight - Source/Data/CharacterDataTables.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem Character data tables for Bank 7.


          rem Character heights (in pixels)
          data CharacterHeights
            10, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
end

          rem Global label for cross-bank access to CharacterHeights data table
          asm
CharacterHeights = CharacterHeights
end

          rem Issue #1194: Extended to 32 entries, entry 31 (Meth Hound) duplicates entry 15 (Shamone)
          data CharacterAttackTypes
            MeleeAttack, RangedAttack, RangedAttack, RangedAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
            RangedAttack, MeleeAttack, MeleeAttack, MeleeAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
end

          rem Global label for cross-bank access to CharacterAttackTypes data table
          asm
CharacterAttackTypes = CharacterAttackTypes
end

          rem Area-of-effect offsets
          data CharacterAOEOffsets
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
end

          rem Per-character movement speeds (pixels/frame or momentum units)
          rem Index 0-15: Bernie, Curler, Dragon, Zoe, FatTony, Megax, Harpy, Knight,
          rem                Frooty, Nefertem, Ninjish, PorkChop, Radish, RoboTito, Ursulo, Shamone
          rem Issue #1194: Extended to 32 entries, entry 31 (Meth Hound) duplicates entry 15 (Shamone)
          data CharacterMovementSpeed
            1, 1, 2, 2, 1, 1, 2, 1,
            2, 1, 2, 1, 2, 1, 1, 2
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
end
