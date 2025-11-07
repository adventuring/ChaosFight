GetCharacterWeight
          rem
          rem ChaosFight - Source/Routines/CharacterData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character Data Lookup Routines
          rem Provides O(1) character property lookups using direct
          rem   array access.
          rem
          rem All character data is defined in CharacterDefinitions.bas
          rem   and
          rem accessed through these optimized lookup routines.
          rem Get Character Weight
          rem Fast lookup of character weight using direct array access.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = character weight
          rem Fast lookup of character weight using direct array access
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterWeights[] (global data table) = character weights
          rem
          rem Output: temp2 = character weight
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2  = CharacterWeights[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterAttackType
          rem
          rem Get Character Attack Type
          rem Fast lookup of character attack type (0=melee, 1=ranged).
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = attack type (0=melee, 1=ranged)
          rem Fast lookup of character attack type (0=melee, 1=ranged)
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterAttackTypes[] (global data table) = character
          rem attack types
          rem
          rem Output: temp2 = attack type (0=melee, 1=ranged)
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2  = CharacterAttackTypes[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterMissileHeight
          rem
          rem Get Character Missile Height
          rem Fast lookup of character missile height for ranged
          rem   attacks.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile height (0=no missile, 1-2=height)
          rem Fast lookup of character missile height for ranged attacks
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileHeights[] (global data table) = character
          rem missile heights
          rem
          rem Output: temp2 = missile height (0=no missile, 1-2=height)
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2  = CharacterMissileHeights[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterMissileMaxX
          rem
          rem Get Character Missile Max X
          rem Fast lookup of character missile maximum X range.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile max X range
          rem Fast lookup of character missile maximum X range
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileMaxX[] (global data table) = character
          rem missile max X ranges
          rem
          rem Output: temp2 = missile max X range
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2  = CharacterMissileMaxX[temp1] : rem Use direct array access for O(1) lookup
          return

GetCharacterMissileMaxY
          rem
          rem Get Character Missile Max Y
          rem Fast lookup of character missile maximum Y range.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile max Y range
          rem Fast lookup of character missile maximum Y range
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileMaxY[] (global data table) = character
          rem missile max Y ranges
          rem
          rem Output: temp2 = missile max Y range
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2  = CharacterMissileMaxY[temp1] : rem Use direct array access for O(1) lookup
          return

IsCharacterRanged
          rem
          rem Is Character Ranged
          rem Quick check if character uses ranged attacks.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = 1 if ranged, 0 if melee
          rem Quick check if character uses ranged attacks
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterAttackTypes[] (global data table) = character
          rem attack types
          rem
          rem Output: temp2 = 1 if ranged, 0 if melee
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          let temp2  = CharacterAttackTypes[temp1] : rem Constraints: None
          return

IsCharacterMelee
          rem
          rem Is Character Melee
          rem Quick check if character uses melee attacks.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = 1 if melee, 0 if ranged
          rem Quick check if character uses melee attacks
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterAttackTypes[] (global data table) = character
          rem attack types
          rem
          rem Output: temp2 = 1 if melee, 0 if ranged
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          let temp2  = CharacterAttackTypes[temp1] : rem Constraints: None
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
          
          if temp3 <= 15 then temp2  = 12 : goto GetCharacterDamageEnd : rem Calculate damage based on weight class
          if temp3 <= 25 then temp2  = 18 : goto GetCharacterDamageEnd
          let temp2  = 22
GetCharacterDamageEnd
          rem Heavy characters
          return          
GetMissileWidth
          rem
          rem Get Missile Width
          rem Fast lookup of character missile width.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile width
          rem Fast lookup of character missile width
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileWidths[] (global data table) = character
          rem missile widths
          rem
          rem Output: temp2 = missile width
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          let temp2  = CharacterMissileWidths[temp1] : rem Constraints: None
          return
          
GetMissileHeight
          rem
          rem Get Missile Height
          rem Fast lookup of character missile height.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile height
          rem Fast lookup of character missile height
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileHeights[] (global data table) = character
          rem missile heights
          rem
          rem Output: temp2 = missile height
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          let temp2  = CharacterMissileHeights[temp1] : rem Constraints: None
          return
          
GetMissileFlags
          rem
          rem Get Missile Flags
          rem Fast lookup of character missile flags.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile flags
          rem Fast lookup of character missile flags
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileFlags[] (global data table) = character
          rem missile flags
          rem
          rem Output: temp2 = missile flags
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          let temp2  = CharacterMissileFlags[temp1] : rem Constraints: None
          return
          
GetMissileMomentumX
          rem
          rem Get Missile Momentum X
          rem Fast lookup of character missile horizontal momentum.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile momentum X
          rem Fast lookup of character missile horizontal momentum
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileMomentumX[] (global data table) =
          rem character missile horizontal momentum
          rem
          rem Output: temp2 = missile momentum X
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          let temp2  = CharacterMissileMomentumX[temp1] : rem Constraints: None
          return
          
GetMissileMomentumY
          rem
          rem Get Missile Momentum Y
          rem Fast lookup of character missile vertical momentum.
          rem
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem
          rem OUTPUT: temp2 = missile momentum Y
          rem Fast lookup of character missile vertical momentum
          rem
          rem Input: temp1 = character index (0-MaxCharacter),
          rem CharacterMissileMomentumY[] (global data table) =
          rem character missile vertical momentum
          rem
          rem Output: temp2 = missile momentum Y
          rem
          rem Mutates: temp2 (return value)
          rem
          rem Called Routines: None
          let temp2  = CharacterMissileMomentumY[temp1] : rem Constraints: None
          return
