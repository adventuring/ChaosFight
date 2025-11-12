          rem ChaosFight - Source/Routines/CharacterDamage.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character damage lookup based on weight class
          rem
          rem Provides the shared GetCharacterDamage routine used by combat and
          rem missile systems. Keeps the damage helper colocated with other
          rem character select utilities in bank 6 to balance ROM usage.

GetCharacterDamage
          rem Get base damage value for character attacks.
          rem Input: temp1 = character index (0-MaxCharacter)
          rem Output: temp2 = base damage value (12=light, 18=medium, 22=heavy)
          rem Mutates: temp2 (return value), temp3 (scratch for weight lookup)
          rem Constraints: None
          rem Base damage varies by character weight class
          rem Light characters: 10-15 weight units
          rem Medium characters: 16-25 weight units
          rem Heavy characters: 26+ weight units

let temp3 = CharacterWeights[temp1]
          rem Retrieve weight for character

          rem Calculate damage based on weight class thresholds
if temp3 <= 15 then temp2 = 12 : goto GetCharacterDamageEnd
if temp3 <= 25 then temp2 = 18 : goto GetCharacterDamageEnd
let temp2 = 22
GetCharacterDamageEnd
return

          asm
GetCharacterDamage = .GetCharacterDamage
end

