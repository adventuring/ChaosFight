          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem 
          rem MULTI-BANK SPRITE LOADING SYSTEM
          rem 
          rem Loads character sprite data and colors from multiple banks
          rem Supports up to 32 characters (0-31) across 4 banks
          rem Current implementation: 16 characters (0-15) in 2 banks
          rem Special sprites: QuestionMark, CPU, No for placeholders

          rem 
          rem MULTI-BANK SPRITE LOADING FUNCTIONS
          rem 
          rem Loads sprites from appropriate bank based on character index
          rem Handles special sprites (QuestionMark, CPU, No) for placeholders

          rem 
          rem CHARACTER COLOR TABLES
          rem 
          rem Character-specific colors loaded from XCF artwork
          rem Each character has per-row color data

          rem NTSC Colors (loaded from XCF artwork)
          data CharacterColorsNTSC
          $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  rem Bernie - White rows
          $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C  rem CurlingSweeper - Yellow rows
          $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A  rem Dragonet - Red rows
          $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  rem EXOPilot - White rows
          $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C  rem FatTony - Yellow rows
          $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A  rem GrizzardHandler - Red rows
          $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  rem Harpy - White rows
          $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C  rem KnightGuy - Yellow rows
          $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A  rem MagicalFaerie - Red rows
          $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  rem MysteryMan - White rows
          $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C  rem NinjishGuy - Yellow rows
          $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A  rem PorkChop - Red rows
          $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  rem RadishGoblin - White rows
          $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C  rem RoboTito - Yellow rows
          $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A  rem Ursulo - Red rows
          $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E  rem VegDog - White rows
          end

          rem 
          rem SPRITE LOADING FUNCTIONS
          rem 

          rem Load sprite data for a character based on character index
          rem Input: temp1 = character index (0-31), temp2 = animation frame (0-7)
          rem        temp3 = player number (0-3)
          rem Output: Sprite data loaded into appropriate player register
LoadCharacterSprite
  rem Validate character index
  gosub ValidateCharacterIndex
  if temp5 = 0 then
    rem Invalid character - load question mark
    gosub LoadSpecialSprite
    return
  endif
  
  rem Check if character is special placeholder
  if temp1 = NoCharacter then
    rem No character selected - load "NO" sprite
    temp6 = SpriteNo
    gosub LoadSpecialSprite
    return
  endif
  
  if temp1 = CPUCharacter then
    rem CPU player - load "CPU" sprite
    temp6 = SpriteCPU
    gosub LoadSpecialSprite
    return
  endif
  
  rem Load from appropriate bank
  if temp2 = 0 then
    rem Load from Bank 0 (characters 0-7)
    gosub bank0 LoadBank0Sprite
  else if temp2 = 1 then
    rem Load from Bank 1 (characters 8-15)
    gosub bank1 LoadBank1Sprite
  else if temp2 = 2 then
    rem Load from Bank 2 (characters 16-23) - future
    gosub bank2 LoadBank2Sprite
  else if temp2 = 3 then
    rem Load from Bank 3 (characters 24-31) - future
    gosub bank3 LoadBank3Sprite
  endif
  
  return

          rem Load sprite data from character sprite
          rem Input: temp4 = sprite pointer
LoadSpriteData
          rem Load the actual sprite data from the generated files
          rem This loads placeholder sprite data until character conversion is complete
          %00011000
          %00111100
          %01111110
          %00011000
          %00011000
          %00011000
          %00011000
          %00011000
          return

          rem Load special sprite (QuestionMark, CPU, No)
          rem Input: temp6 = special sprite index (0-2)
LoadSpecialSprite
  rem Load special sprite based on index
  if temp6 = SpriteQuestionMark then
    gosub LoadQuestionMarkSprite
  else if temp6 = SpriteCPU then
    gosub LoadCPUSprite
  else if temp6 = SpriteNo then
    gosub LoadNoSprite
  endif
  return

          rem Load Question Mark sprite
LoadQuestionMarkSprite
  rem Load from SpecialSprites.bas
  gosub bank0 LoadSpecialSpriteData
  return

          rem Load CPU sprite
LoadCPUSprite
  rem Load from SpecialSprites.bas
  gosub bank0 LoadSpecialSpriteData
  return

          rem Load No sprite
LoadNoSprite
  rem Load from SpecialSprites.bas
  gosub bank0 LoadSpecialSpriteData
  return

          rem Load special sprite data from bank 0
          rem Input: temp6 = sprite index (0-2)
LoadSpecialSpriteData
  rem Calculate pointer offset
  temp7 = temp6 * 2  : rem Each sprite has 2 frames (though we only use frame 0)
  
  rem Load sprite pointer
  temp8 = SpecialSpritePointers(temp6)
  
  rem Load sprite data based on player
  if temp3 = 0 then
    player0:
    gosub LoadSpriteData
    end
  else if temp3 = 1 then
    player1:
    gosub LoadSpriteData
    end
  else if temp3 = 2 then
    missile1:
    gosub LoadSpriteData
    end
  else if temp3 = 3 then
    ball:
    gosub LoadSpriteData
    end
  endif
  
  return

          rem Load character colors based on character index and hurt state
          rem Input: temp1 = character index (0-15), temp2 = hurt state (0=normal, 1=hurt)
          rem Output: Color loaded into appropriate COLUP register
LoadCharacterColors
  rem Calculate color offset (character index * 8)
  temp3 = temp1 * 8
  
  rem Load base color from XCF artwork
  temp4 = CharacterColorsNTSC[temp3]
  
  rem Apply hurt state (dimmer if hurt)
  if temp2 then
    temp4 = temp4 - 6  : rem Dimmer for hurt state
    if temp4 < 0 then temp4 = 0
  endif
  
  rem Set color based on player
  if temp1 = 0 then COLUP0 = temp4
  else if temp1 = 1 then COLUP1 = temp4
  else if temp1 = 2 then COLUPF = temp4
  else if temp1 = 3 then COLUBK = temp4
  endif
  
  return
