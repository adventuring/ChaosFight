          rem ChaosFight - Source/Routines/CharacterMissileData.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem Character Missile Data Lookup Routines
          rem Provides O(1) lookups for character missile and weight properties.
          rem
          rem All character data is defined in CharacterMissileTables.bas and
          rem accessed through these optimized lookup routines.

GetCharacterWeightValue
          asm
GetCharacterWeightValue
end
          rem Return the character’s weight.
          rem Input: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = character weight
          rem Mutates: temp2 (return value)
          rem Constraints: None
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterWeights[temp1]
          return thisbank
GetCharacterMissileHeight
          asm
GetCharacterMissileHeight
end
          rem Return missile height slot (0 = none, 1-2 = height).
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileHeights lookup)
          rem Output: temp2 = missile height slot
          rem Mutates: temp2 (result register - missile height slot)
          rem Constraints: None (table lookup - missile height)
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterMissileHeights[temp1]
          return thisbank
GetCharacterMissileMaxX
          asm
GetCharacterMissileMaxX
end
          rem Return missile maximum X range.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMaxX lookup)
          rem Output: temp2 = missile max X range
          rem Mutates: temp2 (result register - missile max X)
          rem Constraints: None (table lookup - missile max X)
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterMissileMaxX[temp1]
          return thisbank
GetCharacterMissileMaxY
          asm
GetCharacterMissileMaxY
end
          rem Return missile maximum Y range.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMaxY lookup)
          rem Output: temp2 = missile max Y range
          rem Mutates: temp2 (result register - missile max Y)
          rem Constraints: None (table lookup - missile max Y)
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterMissileMaxY[temp1]
          return thisbank
GetMissileWidth
          asm
GetMissileWidth
end
          rem Return missile width (stub - use CharacterMissileWidths[] directly)
          rem Input: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = missile width
          rem Mutates: temp2 (return value)
          rem Constraints: None (table lookup - missile width)
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterMissileWidths[temp1]
          return thisbank
GetMissileHeight
          asm
GetMissileHeight
end
          rem Return missile height (stub - use CharacterMissileHeights[] directly)
          rem Input: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = missile height
          rem Mutates: temp2 (return value)
          rem Constraints: None (table lookup - missile height)
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterMissileHeights[temp1]
          return thisbank
GetMissileFlags
          asm
GetMissileFlags
end
          rem Return missile flags (stub - use CharacterMissileFlags[] directly)
          rem Input: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = missile flags
          rem Mutates: temp2 (return value)
          rem Constraints: None (table lookup - missile flags)
          rem Use direct array access for O(1) lookup
          let temp2 = CharacterMissileFlags[temp1]
          return thisbank
GetMissileMomentumX
          asm
GetMissileMomentumX
end
          rem Return missile horizontal momentum from CharacterMissileMomentumX[temp1].
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMomentumY lookup)
          rem Output: temp2 = missile momentum X
          rem Mutates: temp2 (return value - missile momentum X)
          rem Constraints: None (table lookup - missile momentum X)
          let temp2 = CharacterMissileMomentumX[temp1]
          return thisbank
GetMissileMomentumY
          asm
GetMissileMomentumY
end
          rem Return missile vertical momentum from CharacterMissileMomentumY[temp1].
          rem Parameters: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = missile momentum Y
          rem Mutates: temp2 (return value - missile momentum Y)
          rem Constraints: None (table lookup - missile momentum Y)
          let temp2 = CharacterMissileMomentumY[temp1]
          return thisbank