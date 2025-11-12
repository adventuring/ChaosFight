          rem
          rem ChaosFight - Source/Data/CharacterDataTables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Character data tables for Bank 12.


          rem Character heights (in pixels)
          data CharacterHeights
            10, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
end

          data CharacterAttackTypes
            MeleeAttack, RangedAttack, RangedAttack, RangedAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
            RangedAttack, MeleeAttack, MeleeAttack, MeleeAttack
            MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
end

          rem Area-of-effect offsets
          data CharacterAOEOffsets
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
end

          rem Per-character movement speeds (pixels/frame or momentum units)
          rem Index 0-15: Bernie, Curler, Dragon, Zoe, FatTony, Megax, Harpy, Knight,
          rem                Frooty, Nefertem, Ninjish, PorkChop, Radish, RoboTito, Ursulo, Shamone
          data CharacterMovementSpeed
            1, 1, 2, 2, 1, 1, 2, 1,
            2, 1, 2, 1, 2, 1, 1, 2
end
