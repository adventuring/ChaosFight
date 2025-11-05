          rem ChaosFight - Source/Routines/CharacterData.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem CHARACTER DATA LOOKUP ROUTINES
          rem ==========================================================
          rem Provides O(1) character property lookups using direct
          rem   array access.
          rem All character data is defined in CharacterDefinitions.bas
          rem   and
          rem accessed through these optimized lookup routines.
          rem ==========================================================

          rem ==========================================================
          rem GET CHARACTER WEIGHT
          rem ==========================================================
          rem Fast lookup of character weight using direct array access.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = character weight
GetCharacterWeight
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterWeights[temp1]
          return

          rem ==========================================================
          rem GET CHARACTER ATTACK TYPE
          rem ==========================================================
          rem Fast lookup of character attack type (0=melee, 1=ranged).
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = attack type (0=melee, 1=ranged)
GetCharacterAttackType
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterAttackTypes[temp1]
          return

          rem ==========================================================
          rem GET CHARACTER MISSILE HEIGHT
          rem ==========================================================
          rem Fast lookup of character missile height for ranged
          rem   attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile height (0=no missile, 1-2=height)
GetCharacterMissileHeight
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterMissileHeights[temp1]
          return

          rem ==========================================================
          rem GET CHARACTER MISSILE MAX X
          rem ==========================================================
          rem Fast lookup of character missile maximum X range.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile max X range
GetCharacterMissileMaxX
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterMissileMaxX[temp1]
          return

          rem ==========================================================
          rem GET CHARACTER MISSILE MAX Y
          rem ==========================================================
          rem Fast lookup of character missile maximum Y range.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile max Y range
GetCharacterMissileMaxY
          rem Use direct array access for O(1) lookup
          let temp2  = CharacterMissileMaxY[temp1]
          return

          rem ==========================================================
          rem IS CHARACTER RANGED
          rem ==========================================================
          rem Quick check if character uses ranged attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = 1 if ranged, 0 if melee
IsCharacterRanged
          let temp2  = CharacterAttackTypes[temp1]
          return

          rem ==========================================================
          rem IS CHARACTER MELEE
          rem ==========================================================
          rem Quick check if character uses melee attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = 1 if melee, 0 if ranged
IsCharacterMelee
          let temp2  = CharacterAttackTypes[temp1]
          let temp2  = temp2 ^ 1
          rem XOR to flip 0<->1
          return

          rem ==========================================================
          rem GET CHARACTER DAMAGE
          rem ==========================================================
          rem Get base damage value for character attacks.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = base damage value
GetCharacterDamage
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
          rem ==========================================================
          rem GET MISSILE WIDTH
          rem ==========================================================
          rem Fast lookup of character missile width.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile width
GetMissileWidth
          let temp2  = CharacterMissileWidths[temp1]
          return
          
          rem ==========================================================
          rem GET MISSILE HEIGHT
          rem ==========================================================
          rem Fast lookup of character missile height.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile height
GetMissileHeight
          let temp2  = CharacterMissileHeights[temp1]
          return
          
          rem ==========================================================
          rem GET MISSILE FLAGS
          rem ==========================================================
          rem Fast lookup of character missile flags.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile flags
GetMissileFlags
          let temp2  = CharacterMissileFlags[temp1]
          return
          
          rem ==========================================================
          rem GET MISSILE MOMENTUM X
          rem ==========================================================
          rem Fast lookup of character missile horizontal momentum.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile momentum X
GetMissileMomentumX
          let temp2  = CharacterMissileMomentumX[temp1]
          return
          
          rem ==========================================================
          rem GET MISSILE MOMENTUM Y
          rem ==========================================================
          rem Fast lookup of character missile vertical momentum.
          rem INPUT: temp1 = character index (0-MaxCharacter)
          rem OUTPUT: temp2 = missile momentum Y
GetMissileMomentumY
          let temp2  = CharacterMissileMomentumY[temp1]
          return
