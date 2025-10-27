rem ChaosFight - Source/Routines/Physics.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

rem =================================================================
rem PHYSICS SYSTEM - Weight-based wall collisions and movement
rem =================================================================

rem Handle weight-based wall collision for a player
rem Input: player index (in temp1)
rem Modifies: Player momentum based on character weight
rem Weight affects: wall bounce coefficient (heavier = less bounce)
HandleWallCollision
  rem Get character type for this player
  gosub GetPlayerCharacterSub
  rem temp4 now contains character type
  
  rem Get character weight
  on temp4 goto GetChar0, GetChar1, GetChar2, GetChar3, GetChar4, GetChar5, GetChar6, GetChar7, GetChar8, GetChar9, GetChar10, GetChar11, GetChar12, GetChar13, GetChar14, GetChar15
  GetChar0: temp3 = CharacterWeights(0) : goto DoneWeight
  GetChar1: temp3 = CharacterWeights(1) : goto DoneWeight
  GetChar2: temp3 = CharacterWeights(2) : goto DoneWeight
  GetChar3: temp3 = CharacterWeights(3) : goto DoneWeight
  GetChar4: temp3 = CharacterWeights(4) : goto DoneWeight
  GetChar5: temp3 = CharacterWeights(5) : goto DoneWeight
  GetChar6: temp3 = CharacterWeights(6) : goto DoneWeight
  GetChar7: temp3 = CharacterWeights(7) : goto DoneWeight
  GetChar8: temp3 = CharacterWeights(8) : goto DoneWeight
  GetChar9: temp3 = CharacterWeights(9) : goto DoneWeight
  GetChar10: temp3 = CharacterWeights(10) : goto DoneWeight
  GetChar11: temp3 = CharacterWeights(11) : goto DoneWeight
  GetChar12: temp3 = CharacterWeights(12) : goto DoneWeight
  GetChar13: temp3 = CharacterWeights(13) : goto DoneWeight
  GetChar14: temp3 = CharacterWeights(14) : goto DoneWeight
  GetChar15: temp3 = CharacterWeights(15) : goto DoneWeight
  
DoneWeight:
  rem Weight is now in temp3 (0-40)
  rem Calculate bounce coefficient: higher weight = lower bounce
  rem Formula: bounce = 50 - weight / 2
  rem Lighter characters bounce more, heavier characters bounce less
  rem Example weights: 12 (light) = 44 bounce, 40 (heavy) = 30 bounce
  
  rem Get player momentum
  gosub GetPlayerMomentumSub
  rem temp4 now contains momentum value
  
  rem Calculate bounced momentum: momentum = momentum * bounce / 50
  rem Using integer math: momentum = (momentum * bounce) / 50
  temp2 = temp4 * (50 - temp3 / 2) / 50
  if temp2 = 0 && temp4 != 0 then temp2 = 1 : rem Ensure at least 1 if was moving
  gosub SetPlayerMomentumSub
  return

rem Check if player hit left wall and needs weight-based bounce
rem Input: player index (in temp1)
CheckLeftWallCollision
  gosub GetPlayerXSub
  if temp4 < 10 then
    rem Hit left wall - reverse momentum with weight-based reduction
    rem Apply weighted bounce
    gosub HandleWallCollision
    rem Ensure position is corrected
    gosub GetPlayerXSub
    if temp4 < 10 then
      temp2 = 10
      gosub SetPlayerXSub
    endif
  endif
  return

rem Check if player hit right wall and needs weight-based bounce
rem Input: player index (in temp1)
CheckRightWallCollision
  gosub GetPlayerXSub
  if temp4 > 150 then
    rem Hit right wall - reverse momentum with weight-based reduction
    rem Apply weighted bounce
    gosub HandleWallCollision
    rem Ensure position is corrected
    gosub GetPlayerXSub
    if temp4 > 150 then
      temp2 = 150
      gosub SetPlayerXSub
    endif
  endif
  return

rem Get player momentum for a given player index
rem Input: index (in temp1)
rem Output: momentum (in temp4)
GetPlayerMomentumSub
  on temp1 goto GetM0, GetM1, GetM2, GetM3
  
  GetM0:
    temp4 = Player1MomentumX
    return
    
  GetM1:
    temp4 = Player2MomentumX
    return
    
  GetM2:
    temp4 = Player3MomentumX
    return
    
  GetM3:
    temp4 = Player4MomentumX
    return

rem Set player momentum for a given player index
rem Input: index (in temp1), momentum (in temp2)
SetPlayerMomentumSub
  on temp1 goto SetM0, SetM1, SetM2, SetM3
  
  SetM0:
    Player1MomentumX = temp2
    return
    
  SetM1:
    Player2MomentumX = temp2
    return
    
  SetM2:
    Player3MomentumX = temp2
    return
    
  SetM3:
    Player4MomentumX = temp2
    return

rem =================================================================
rem CHARACTER WEIGHTS DATA
rem =================================================================
rem Reference to weights from CharacterDefinitions.bas
rem This is just for documentation - actual weights are read from CharacterWeights array

rem Character weights affect:
rem   - Wall bounce coefficient (heavier = less bounce)
rem   - Movement speed resistance
rem   - Impact resistance

rem Weight values (from CharacterDefinitions.bas):
rem Bernie: 21, Curling: 25, Dragonet: 20, EXO Pilot: 23
rem Fat Tony: 22, Grizzard Handler: 20, Harpy: 19, Knight Guy: 12
rem Magical Faerie: 17, Mystery Man: 18, Ninjish Guy: 40, Pork Chop: 15
rem Radish Goblin: 19, Robo Tito: 18, Ursulo: 16, Veg Dog: 17
