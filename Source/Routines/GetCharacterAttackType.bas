          rem ChaosFight - Source/Routines/GetCharacterAttackType.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

GetCharacterAttackType
          rem Return attack type (0=mêlée, 1=ranged).
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterAttackTypes lookup)
          rem Output: temp2 = attack type (0=mêlée, 1=ranged)
          rem Mutates: temp2 (result register - attack type)
          rem Constraints: None (table lookup - attack type)
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterAttackTypes[temp1]
          return

