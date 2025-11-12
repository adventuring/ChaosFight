          rem ChaosFight - Source/Routines/CharacterData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character Data Lookup Routines
          rem Provides O(1) lookups for character properties.
          rem
          rem All character data is defined in CharacterDataTables.bas and
          rem accessed through these optimized lookup routines.

GetCharacterAttackType
          rem Return attack type (0=melee, 1=ranged).
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterAttackTypes lookup)
          rem Output: temp2 = attack type (0=melee, 1=ranged)
          rem Mutates: temp2 (result register - attack type)
          rem Constraints: None (table lookup - attack type)
          let temp2 = CharacterAttackTypes[temp1]
          rem Use direct array access for O(1) lookup
          return

IsCharacterRanged
          rem Return 1 if character is ranged, else 0.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterAttackTypes lookup)
          rem Output: temp2 = 1 if ranged, 0 if melee
          rem Mutates: temp2 (return value - ranged flag)
          rem Constraints: None (direct lookup - ranged flag)
          let temp2 = CharacterAttackTypes[temp1]
          return

IsCharacterMelee
          rem Return 1 if character is melee, else 0.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileWidths lookup)
          rem Output: temp2 = 1 if melee, 0 if ranged
          rem Mutates: temp2 (return value - melee flag)
          rem Constraints: None (direct lookup - melee flag)
          let temp2 = CharacterAttackTypes[temp1]
          let temp2 = temp2 ^ 1
          rem XOR to flip 0<->1
          return
