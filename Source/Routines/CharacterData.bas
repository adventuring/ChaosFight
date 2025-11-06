          rem ChaosFight - Source/Routines/CharacterData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Character Data Lookup Routines
          rem
          rem Provides O(1) character property lookups using direct
          rem   array access.
          rem All character data is defined in CharacterDefinitions.bas
          rem   and
          rem accessed through these optimized lookup routines.
          rem ==========================================================

          rem Get Character Weight
          rem
          rem Fast lookup of character weight using direct array access.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = character weight
GetCharacterWeight
          rem Fast lookup of character weight using direct array access
          rem Input: temp1 = character index (0-MaxCharacter), CharacterWeights[] (global data table) = character weights
          rem Output: temp2 = character weight
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterWeights[temp1]
          return

          rem Get Character Attack Type
          rem
          rem Fast lookup of character attack type (0=melee, 1=ranged).
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = attack type (0=melee, 1=ranged)
GetCharacterAttackType
          rem Fast lookup of character attack type (0=melee, 1=ranged)
          rem Input: temp1 = character index (0-MaxCharacter), CharacterAttackTypes[] (global data table) = character attack types
          rem Output: temp2 = attack type (0=melee, 1=ranged)
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterAttackTypes[temp1]
          return

          rem Get Character Missile Height
          rem
          rem Fast lookup of character missile height for ranged
          rem   attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile height (0=no missile, 1-2=height)
GetCharacterMissileHeight
          rem Fast lookup of character missile height for ranged attacks
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileHeights[] (global data table) = character missile heights
          rem Output: temp2 = missile height (0=no missile, 1-2=height)
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterMissileHeights[temp1]
          return

          rem Get Character Missile Max X
          rem
          rem Fast lookup of character missile maximum X range.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile max X range
GetCharacterMissileMaxX
          rem Fast lookup of character missile maximum X range
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileMaxX[] (global data table) = character missile max X ranges
          rem Output: temp2 = missile max X range
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterMissileMaxX[temp1]
          return

          rem Get Character Missile Max Y
          rem
          rem Fast lookup of character missile maximum Y range.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile max Y range
GetCharacterMissileMaxY
          rem Fast lookup of character missile maximum Y range
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileMaxY[] (global data table) = character missile max Y ranges
          rem Output: temp2 = missile max Y range
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterMissileMaxY[temp1]
          return

          rem Is Character Ranged
          rem
          rem Quick check if character uses ranged attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = 1 if ranged, 0 if melee
IsCharacterRanged
          rem Quick check if character uses ranged attacks
          rem Input: temp1 = character index (0-MaxCharacter), CharacterAttackTypes[] (global data table) = character attack types
          rem Output: temp2 = 1 if ranged, 0 if melee
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          let temp2  = CharacterAttackTypes[temp1]
          return

          rem Is Character Melee
          rem
          rem Quick check if character uses melee attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = 1 if melee, 0 if ranged
IsCharacterMelee
          rem Quick check if character uses melee attacks
          rem Input: temp1 = character index (0-MaxCharacter), CharacterAttackTypes[] (global data table) = character attack types
          rem Output: temp2 = 1 if melee, 0 if ranged
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          let temp2  = CharacterAttackTypes[temp1]
          let temp2  = temp2 ^ 1
          rem XOR to flip 0<->1
          return

          rem Get Character Damage
          rem
          rem Get base damage value for character attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = base damage value
GetCharacterDamage
          rem Get base damage value for character attacks based on weight class
          rem Input: temp1 = character index (0-MaxCharacter), CharacterWeights[] (global data table) = character weights
          rem Output: temp2 = base damage value (12=light, 18=medium, 22=heavy)
          rem Mutates: temp2 (return value), temp3 (used for weight lookup)
          rem Called Routines: None
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
          rem Heavy characters
GetCharacterDamageEnd
          return          
          rem Get Missile Width
          rem
          rem Fast lookup of character missile width.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile width
GetMissileWidth
          rem Fast lookup of character missile width
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileWidths[] (global data table) = character missile widths
          rem Output: temp2 = missile width
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          let temp2  = CharacterMissileWidths[temp1]
          return
          
          rem Get Missile Height
          rem
          rem Fast lookup of character missile height.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile height
GetMissileHeight
          rem Fast lookup of character missile height
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileHeights[] (global data table) = character missile heights
          rem Output: temp2 = missile height
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          let temp2  = CharacterMissileHeights[temp1]
          return
          
          rem Get Missile Flags
          rem
          rem Fast lookup of character missile flags.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile flags
GetMissileFlags
          rem Fast lookup of character missile flags
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileFlags[] (global data table) = character missile flags
          rem Output: temp2 = missile flags
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          let temp2  = CharacterMissileFlags[temp1]
          return
          
          rem Get Missile Momentum X
          rem
          rem Fast lookup of character missile horizontal momentum.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile momentum X
GetMissileMomentumX
          rem Fast lookup of character missile horizontal momentum
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileMomentumX[] (global data table) = character missile horizontal momentum
          rem Output: temp2 = missile momentum X
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          let temp2  = CharacterMissileMomentumX[temp1]
          return
          
          rem Get Missile Momentum Y
          rem
          rem Fast lookup of character missile vertical momentum.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile momentum Y
GetMissileMomentumY
          rem Fast lookup of character missile vertical momentum
          rem Input: temp1 = character index (0-MaxCharacter), CharacterMissileMomentumY[] (global data table) = character missile vertical momentum
          rem Output: temp2 = missile momentum Y
          rem Mutates: temp2 (return value)
          rem Called Routines: None
          rem Constraints: None
          let temp2  = CharacterMissileMomentumY[temp1]
          return
