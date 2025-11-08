          rem ChaosFight - Source/Routines/CharacterData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character Data Lookup Routines
          rem Provides O(1) lookups for character properties.
          rem
          rem All character data is defined in CharacterDefinitions.bas and
          rem accessed through these optimized lookup routines.

GetCharacterWeight
          rem Return the character’s weight.
          rem Input: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = character weight
          rem Mutates: temp2 (return value)
          rem Constraints: None
          let temp2  = CharacterWeights[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterAttackType
          rem Return attack type (0=melee, 1=ranged).
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterAttackTypes lookup)
          rem Output: temp2 = attack type (0=melee, 1=ranged)
          rem Mutates: temp2 (result register - attack type)
          rem Constraints: None (table lookup - attack type)
          let temp2  = CharacterAttackTypes[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterMissileHeight
          rem Return missile height slot (0 = none, 1-2 = height).
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileHeights lookup)
          rem Output: temp2 = missile height slot
          rem Mutates: temp2 (result register - missile height slot)
          rem Constraints: None (table lookup - missile height)
          let temp2  = CharacterMissileHeights[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterMissileMaxX
          rem Return missile maximum X range.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMaxX lookup)
          rem Output: temp2 = missile max X range
          rem Mutates: temp2 (result register - missile max X)
          rem Constraints: None (table lookup - missile max X)
          let temp2  = CharacterMissileMaxX[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterMissileMaxY
          rem Return missile maximum Y range.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMaxY lookup)
          rem Output: temp2 = missile max Y range
          rem Mutates: temp2 (result register - missile max Y)
          rem Constraints: None (table lookup - missile max Y)
          let temp2  = CharacterMissileMaxY[temp1] : rem Use direct array access for O(1) lookup
          return

IsCharacterRanged
          rem Return 1 if character is ranged, else 0.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterAttackTypes lookup)
          rem Output: temp2 = 1 if ranged, 0 if melee
          rem Mutates: temp2 (return value - ranged flag)
          rem Constraints: None (direct lookup - ranged flag)
          let temp2  = CharacterAttackTypes[temp1]
          return

IsCharacterMelee
          rem Return 1 if character is melee, else 0.
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileWidths lookup)
          rem Output: temp2 = 1 if melee, 0 if ranged
          rem Mutates: temp2 (return value - melee flag)
          rem Constraints: None (direct lookup - melee flag)
          let temp2  = CharacterAttackTypes[temp1]
          let temp2  = temp2 ^ 1
          rem XOR to flip 0<->1
          return

GetCharacterDamage
          rem
          rem Get Character Damage
          rem Get base damage value for character attacks.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = base damage value
          rem Get base damage value for character attacks based on
          rem weight class
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterWeights[] (global data table) = character weights
          rem
          rem Output: temp2 = base damage value (12=light, 18=medium,
          rem 22=heavy)
          rem
          rem Mutates: temp2 (return value), temp3 (used for weight
          rem lookup)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Base damage varies by character type and weight
          rem Light characters: 10-15 damage
          rem Medium characters: 15-20 damage  
          rem Heavy characters: 20-25 damage
          
          let temp3  = CharacterWeights[temp1]
          rem Get weight
          
          rem Calculate damage based on weight class
          
          if temp3 <= 15 then temp2  = 12 : goto GetCharacterDamageEnd
          if temp3 <= 25 then temp2  = 18 : goto GetCharacterDamageEnd
          let temp2  = 22
GetCharacterDamageEnd
          rem Heavy characters
          return          
GetMissileWidth
          rem Return missile width from CharacterMissileWidths[temp1].
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileHeights lookup)
          rem Output: temp2 = missile width
          rem Mutates: temp2 (return value - missile width)
          rem Constraints: None (table lookup - missile width)
          let temp2  = CharacterMissileWidths[temp1]
          return
          
GetMissileHeight
          rem Return missile height from CharacterMissileHeights[temp1].
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileFlags lookup)
          rem Output: temp2 = missile height
          rem Mutates: temp2 (return value - missile height)
          rem Constraints: None (table lookup - missile height)
          let temp2  = CharacterMissileHeights[temp1]
          return
          
GetMissileFlags
          rem Return missile flags from CharacterMissileFlags[temp1].
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMomentumX lookup)
          rem Output: temp2 = missile flags
          rem Mutates: temp2 (return value - missile flags)
          rem Constraints: None (table lookup - missile flags)
          let temp2  = CharacterMissileFlags[temp1]
          return
          
GetMissileMomentumX
          rem Return missile horizontal momentum from CharacterMissileMomentumX[temp1].
          rem Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMomentumY lookup)
          rem Output: temp2 = missile momentum X
          rem Mutates: temp2 (return value - missile momentum X)
          rem Constraints: None (table lookup - missile momentum X)
          let temp2  = CharacterMissileMomentumX[temp1]
          return
          
GetMissileMomentumY
          rem Return missile vertical momentum from CharacterMissileMomentumY[temp1].
          rem Parameters: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = missile momentum Y
          rem Mutates: temp2 (return value - missile momentum Y)
          rem Constraints: None (table lookup - missile momentum Y)
          let temp2  = CharacterMissileMomentumY[temp1]
          return
