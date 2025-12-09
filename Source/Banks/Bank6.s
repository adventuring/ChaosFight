;;; ChaosFight - Source/Banks/Bank6.s
;;;Copyright © 2025 Interworldly Adventuring, LLC.

;;;GENERAL CODE BANK (shared memory budget - 8 banks total)
;;;Missile system (tables, physics, collision) + combat system

          ;; Set file offset for Bank 6 at the top of the file
          .offs (6 * $1000) - $f000  ; Adjust file offset for Bank 6
          * = $F000
          .rept 256
          .byte $ff
          .endrept  ;; Scram shadow (256 bytes of $FF)
          * = $F100

CharacterMissileTablesStart:
.include "Source/Data/CharacterMissileTables.s"
CharacterMissileTablesEnd:
            .warn format("// Bank 6: %d bytes = CharacterMissileTables", [CharacterMissileTablesEnd - CharacterMissileTablesStart])
CharacterMissileDataStart:
.include "Source/Routines/CharacterMissileData.s"
CharacterMissileDataEnd:
            .warn format("// Bank 6: %d bytes = CharacterMissileData", [CharacterMissileDataEnd - CharacterMissileDataStart])
CharacterDataTablesStart:
.include "Source/Data/CharacterDataTables.s"
CharacterDataTablesEnd:
            .warn format("// Bank 6: %d bytes = CharacterDataTables", [CharacterDataTablesEnd - CharacterDataTablesStart])
Bank6DataEnds:

BudgetedMissileCollisionsStart:
.include "Source/Routines/BudgetedMissileCollisionCheck.s"
MissileSystemStart:
.include "Source/Routines/MissileSystem.s"
MissileSystemEnd:
            .warn format("// Bank 6: %d bytes = MissileSystem", [MissileSystemEnd - MissileSystemStart])
MissileCharacterHandlersStart:
.include "Source/Routines/MissileCharacterHandlers.s"
MissileCharacterHandlersEnd:
            .warn format("// Bank 6: %d bytes = MissileCharacterHandlers", [MissileCharacterHandlersEnd - MissileCharacterHandlersStart])
CombatStart:
.include "Source/Routines/Combat.s"
PerformGenericAttackStart:
.include "Source/Routines/PerformGenericAttack.s"
PerformGenericAttackEnd:
            .warn format("// Bank 6: %d bytes = PerformGenericAttack", [PerformGenericAttackEnd - PerformGenericAttackStart])
FlyingMovementHelpersStart:
.include "Source/Routines/FlyingMovementHelpers.s"
FlyingMovementHelpersEnd:
            .warn format("// Bank 6: %d bytes = FlyingMovementHelpers", [FlyingMovementHelpersEnd - FlyingMovementHelpersStart])
Bank6CodeEnds:

          ;; Include BankSwitching.s in Bank 6
          ;; Wrap in .block to create namespace Bank6BS (avoids duplicate definitions)
Bank6BS: .block
          current_bank = 6
                    ;; Set file offset and CPU address for bankswitch code
          ;; File offset: (6 * $1000) + ($FFE0 - bscode_length - $F000) = $6FC8
          ;; CPU address: $FFE0 - bscode_length = $FFC8
          ;; Use .org to set file offset, then * = to set CPU address
          ;; Code appears at $ECA but should be at $FC8, difference is $FE
          ;; So adjust .org by $FE
          * = $FFE0 - bscode_length
          
          
          .include "Source/Common/BankSwitching.s"
          .bend
