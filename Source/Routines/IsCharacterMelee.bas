          rem ChaosFight - Source/Routines/IsCharacterMelee.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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

