          rem ChaosFight - Source/Common/Macros.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Macros

rem =================================================================
rem MACROS
rem =================================================================

rem =================================================================
rem ARRAY ACCESSOR MACROS - Simulate arrays using accessor functions
rem =================================================================

rem Get PlayerX for a given player index (0-3)
macro GetPlayerX index
  if index = 0 then w
  else if index = 1 then y
  else if index = 2 then Player3X
  else if index = 3 then Player4X
end

rem Set PlayerX for a given player index (0-3)
macro SetPlayerX index, value
  if index = 0 then w = value
  else if index = 1 then y = value
  else if index = 2 then Player3X = value
  else if index = 3 then Player4X = value
end

rem Get PlayerY for a given player index (0-3)
macro GetPlayerY index
  if index = 0 then x
  else if index = 1 then z
  else if index = 2 then Player3Y
  else if index = 3 then Player4Y
end

rem Set PlayerY for a given player index (0-3)
macro SetPlayerY index, value
  if index = 0 then x = value
  else if index = 1 then z = value
  else if index = 2 then Player3Y = value
  else if index = 3 then Player4Y = value
end

rem Get PlayerState for a given player index (0-3)
macro GetPlayerState index
  if index = 0 then Player1State
  else if index = 1 then Player2State
  else if index = 2 then Player3State
  else if index = 3 then Player4State
end

rem Set PlayerState for a given player index (0-3)
macro SetPlayerState index, value
  if index = 0 then Player1State = value
  else if index = 1 then Player2State = value
  else if index = 2 then Player3State = value
  else if index = 3 then Player4State = value
end

rem Get PlayerHealth for a given player index (0-3)
macro GetPlayerHealth index
  if index = 0 then Player1Health
  else if index = 1 then Player2Health
  else if index = 2 then Player3Health
  else if index = 3 then Player4Health
end

rem Set PlayerHealth for a given player index (0-3)
macro SetPlayerHealth index, value
  if index = 0 then Player1Health = value
  else if index = 1 then Player2Health = value
  else if index = 2 then Player3Health = value
  else if index = 3 then Player4Health = value
end

rem =================================================================
rem PACKED DATA ACCESSOR MACROS
rem =================================================================

rem Get player facing direction from packed state (bits 0-1)
macro GetPlayerFacing player_state
  (player_state) & %00000011
end

rem Set player facing direction in packed state (0=right, 1=left, 2=up, 3=down)
macro SetPlayerFacing player_state, facing
  player_state = (player_state) & %11111100 | facing
end

rem Get AttackCooldown from packed timers (low nibble)
macro GetAttackCooldown timers
  (timers) & %00001111
end

rem Set AttackCooldown in packed timers
macro SetAttackCooldown timers, value
  timers = (timers) & %11110000 | (value & %00001111)
end

rem Get RecoveryFrames from packed timers (high nibble)
macro GetRecoveryFrames timers
  (timers) >> 4
end

rem Set RecoveryFrames in packed timers
macro SetRecoveryFrames timers, value
  timers = (timers) & %00001111 | ((value & %00001111) << 4)
end