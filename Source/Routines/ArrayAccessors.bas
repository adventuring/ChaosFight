          rem ChaosFight - Source/Routines/ArrayAccessors.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem ARRAY ACCESSOR SUBROUTINES - Simulate arrays for player data
          rem =================================================================

          rem Input/Output Variable Usage:
          rem   temp1 = player index (0-3) for all accessors
          rem   temp2 = value to set for all Set* routines
          rem   temp3 = temporary calculations
          rem   temp4 = return value for all Get* routines

          rem =================================================================
          rem PLAYER X POSITION ACCESSORS
          rem =================================================================

          rem Get PlayerX for a given player index (0-3)
          rem Input: index (in temp1)
          rem Output: value (in temp4)
GetPlayerXSub
  on temp1 goto GetP0X, GetP1X, GetP2X, GetP3X
  
  GetP0X:
    temp4 = Player1X
    return
    
  GetP1X:
    temp4 = Player2X
    return
    
  GetP2X:
    temp4 = Player3X
    return
    
  GetP3X:
    temp4 = Player4X
    return

          rem Set PlayerX for a given player index (0-3)
rem Input: index (in temp1), value (in temp2)
SetPlayerXSub
  on temp1 goto SetP0X, SetP1X, SetP2X, SetP3X
  
  SetP0X:
    Player1X = temp2
    return
    
  SetP1X:
    Player2X = temp2
    return
    
  SetP2X:
    Player3X = temp2
    return
    
  SetP3X:
    Player4X = temp2
    return

          rem =================================================================
rem PLAYER Y POSITION ACCESSORS
          rem =================================================================

          rem Get PlayerY for a given player index (0-3)
rem Input: index (in temp1)
rem Output: value (in temp4)
GetPlayerYSub
  on temp1 goto GetP0Y, GetP1Y, GetP2Y, GetP3Y
  
  GetP0Y:
    temp4 = Player1Y
    return
    
  GetP1Y:
    temp4 = Player2Y
    return
    
  GetP2Y:
    temp4 = Player3Y
    return
    
  GetP3Y:
    temp4 = Player4Y
    return

          rem Set PlayerY for a given player index (0-3)
rem Input: index (in temp1), value (in temp2)
SetPlayerYSub
  on temp1 goto SetP0Y, SetP1Y, SetP2Y, SetP3Y
  
  SetP0Y:
    Player1Y = temp2
    return
    
  SetP1Y:
    Player2Y = temp2
    return
    
  SetP2Y:
    Player3Y = temp2
    return
    
  SetP3Y:
    Player4Y = temp2
    return

          rem =================================================================
rem PLAYER CHARACTER TYPE ACCESSORS
          rem =================================================================

          rem Get PlayerChar for a given player index (0-3)
rem Input: index (in temp1)
rem Output: value (in temp4)
GetPlayerCharacterSub
  on temp1 goto GetP0Char, GetP1Char, GetP2Char, GetP3Char
  
  GetP0Char:
    temp4 = PlayerChar(0)
    return
    
  GetP1Char:
    temp4 = PlayerChar(1)
    return
    
  GetP2Char:
    temp4 = PlayerChar(2)
    return
    
  GetP3Char:
    temp4 = PlayerChar(3)
    return

rem =================================================================
rem PLAYER STATE ACCESSORS
          rem =================================================================

          rem Get PlayerState for a given player index (0-3)
rem Input: index (in temp1)
rem Output: value (in temp4)
GetPlayerStateSub
  on temp1 goto GetP0State, GetP1State, GetP2State, GetP3State
  
  GetP0State:
    temp4 = Player1State
    return
    
  GetP1State:
    temp4 = Player2State
    return
    
  GetP2State:
    temp4 = Player3State
    return
    
  GetP3State:
    temp4 = Player4State
    return

          rem Set PlayerState for a given player index (0-3)
rem Input: index (in temp1), value (in temp2)
SetPlayerStateSub
  on temp1 goto SetP0State, SetP1State, SetP2State, SetP3State
  
  SetP0State:
    Player1State = temp2
    return
    
  SetP1State:
    Player2State = temp2
    return
    
  SetP2State:
    Player3State = temp2
    return
    
  SetP3State:
    Player4State = temp2
    return

          rem Set player animation state (preserves other state flags)
rem Input: index (in temp1), animation state (in animState variable)
rem Note: Animation state is in bits 4-7 of PlayerState
SetPlayerAnimStateSub
  dim currentState = temp4
  dim animState = temp3
  gosub GetPlayerStateSub
  currentState = temp4
  rem Clear animation bits (4-7) and set new animation state
  temp2 = (currentState & %00001111) | (animState << 4)
  gosub SetPlayerStateSub
  return

          rem =================================================================
rem PLAYER HEALTH ACCESSORS
          rem =================================================================

          rem Get PlayerHealth for a given player index (0-3)
rem Input: index (in temp1)
rem Output: value (in temp4)
GetPlayerHealthSub
  on temp1 goto GetP0Health, GetP1Health, GetP2Health, GetP3Health
  
  GetP0Health:
    temp4 = Player1Health
    return
    
  GetP1Health:
    temp4 = Player2Health
    return
    
  GetP2Health:
    temp4 = Player3Health
    return
    
  GetP3Health:
    temp4 = Player4Health
    return

          rem Set PlayerHealth for a given player index (0-3)
rem Input: index (in temp1), value (in temp2)
SetPlayerHealthSub
  on temp1 goto SetP0Health, SetP1Health, SetP2Health, SetP3Health
  
  SetP0Health:
    Player1Health = temp2
    return
    
  SetP1Health:
    Player2Health = temp2
    return
    
  SetP2Health:
    Player3Health = temp2
    return
    
  SetP3Health:
    Player4Health = temp2
    return
