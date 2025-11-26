          rem ChaosFight - Source/Routines/IsCharacterRanged.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

IsCharacterRanged
          rem Return 1 if character is ranged, else 0.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterAttackTypes lookup)
          rem Output: temp2 = 1 if ranged, 0 if mêlée
          rem Mutates: temp2 (return value - ranged flag)
          rem Constraints: None (direct lookup - ranged flag)
          let temp2 = CharacterAttackTypes[temp1]
          return thisbank
