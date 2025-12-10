rem_label_1:

;;; ChaosFight - Source/Data/CharacterDataTables.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
rem_label_2_1:

          ;; Character data tables for Bank 7.


          ;; Character heights (in pixels)
CharacterHeights:
          .byte 10, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
CharacterHeights_end:

          ;; Global label for cross-bank access to CharacterHeights data table
          ;; CharacterHeights is already defined above

          ;; Issue #1194: Extended to 32 entries, entry 31 (Meth Hound) duplicates entry 15 (Shamone)
CharacterAttackTypes:
          .byte MeleeAttack, RangedAttack, RangedAttack, RangedAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, RangedAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack, MeleeAttack
CharacterAttackTypes_end:

          ;; Global label for cross-bank access to CharacterAttackTypes data table
asm:

          ;; CharacterAttackTypes = CharacterAttackTypes (duplicate - already defined above)
asm_end:

          ;; Area-of-effect offsets
CharacterAOEOffsets:
          .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
CharacterAOEOffsets_end:

          ;; Per-character movement speeds (pixels/frame or momentum units)
          ;; Index 0-15: Bernie, Curler, Dragon, Zoe, FatTony, Megax, Harpy, Knight,
          ;; Frooty, Nefertem, Ninjish, PorkChop, Radish, RoboTito, Ursulo, Shamone
          ;; Issue #1194: Extended to 32 entries, entry 31 (Meth Hound) duplicates entry 15 (Shamone)
CharacterMovementSpeed:
          .byte 1, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
CharacterMovementSpeed_end:
