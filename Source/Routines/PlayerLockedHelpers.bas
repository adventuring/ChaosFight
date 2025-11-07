GetPlayerLocked
          rem
          rem ChaosFight - Source/Routines/PlayerLockedHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Player Locked Helper Functions
          rem Helper functions to access bit-packed playerLocked
          rem variable
          rem playerLocked is a single byte with 2 bits per player:
          rem   Bits 0-1: Player 0 (0=unlocked, 1=normal, 2=handicap)
          rem
          rem   Bits 2-3: Player 1
          rem   Bits 4-5: Player 2
          rem   Bits 6-7: Player 3
          rem Get Player Locked State
          rem Gets the locked state for a specific player
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = locked state (0=unlocked, 1=normal,
          rem 2=handicap)
          rem Get the locked state for a specific player from bit-packed
          rem playerLocked variable
          rem Input: temp1 = player index (0-3), playerLocked (global) =
          rem bit-packed locked states
          rem Output: temp2 = locked state (0=unlocked, 1=normal,
          rem 2=handicap)
          rem Mutates: temp2 (return value), temp3 (used for bit
          rem extraction)
          rem Called Routines: None
          dim GPL_playerIndex = temp1 : rem Constraints: None
          dim GPL_lockedState = temp2
          dim GPL_playerLocked = temp3
          let GPL_playerLocked = playerLocked
          
          rem Extract 2 bits for this player
          rem Player 0: bits 0-1 (shift right 0, mask %00000011)
          rem Player 1: bits 2-3 (shift right 2, mask %00000011)
          rem Player 2: bits 4-5 (shift right 4, mask %00000011)
          if GPL_playerIndex = 0 then GPL_ExtractBits0 : rem Player 3: bits 6-7 (shift right 6, mask %00000011)
          if GPL_playerIndex = 1 then GPL_ExtractBits2
          if GPL_playerIndex = 2 then GPL_ExtractBits4
          if GPL_playerIndex = 3 then GPL_ExtractBits6
          let GPL_lockedState = 0 : rem Invalid index, return 0
          goto GPL_Done
          
GPL_ExtractBits0
          let GPL_lockedState = GPL_playerLocked & 3 : rem Player 0: bits 0-1
          goto GPL_Done
          
GPL_ExtractBits2
          let GPL_lockedState = GPL_playerLocked / 4 : rem Player 1: bits 2-3
          let GPL_lockedState = GPL_lockedState & 3
          goto GPL_Done
          
GPL_ExtractBits4
          let GPL_lockedState = GPL_playerLocked / 16 : rem Player 2: bits 4-5
          let GPL_lockedState = GPL_lockedState & 3
          goto GPL_Done
          
GPL_ExtractBits6
          let GPL_lockedState = GPL_playerLocked / 64 : rem Player 3: bits 6-7
          let GPL_lockedState = GPL_lockedState & 3
          goto GPL_Done
          
GPL_Done
          let temp2 = GPL_lockedState
          return

SetPlayerLocked
          rem
          rem Set Player Locked State
          rem Sets the locked state for a specific player
          rem INPUT: temp1 = player index (0-3)
          rem         temp2 = locked state (0=unlocked, 1=normal,
          rem         2=handicap)
          rem OUTPUT: playerLocked variable updated
          rem Set the locked state for a specific player in bit-packed
          rem playerLocked variable
          rem Input: temp1 = player index (0-3), temp2 = locked state
          rem (0=unlocked, 1=normal, 2=handicap), playerLocked (global)
          rem = current bit-packed locked states
          rem Output: playerLocked (global) updated with new state for
          rem specified player
          rem Mutates: playerLocked (global), temp3-temp5 (used for bit
          rem manipulation)
          rem Called Routines: None
          dim SPL_playerIndex = temp1 : rem Constraints: None
          dim SPL_lockedState = temp2
          dim SPL_playerLocked = temp3
          dim SPL_mask = temp4
          dim SPL_cleared = temp5
          
          let SPL_playerLocked = playerLocked : rem Get current playerLocked value
          
          rem Clear the 2 bits for this player
          rem Player 0: clear bits 0-1 (mask %11111100)
          rem Player 1: clear bits 2-3 (mask %11110011)
          rem Player 2: clear bits 4-5 (mask %11001111)
          if SPL_playerIndex = 0 then SPL_ClearBits0 : rem Player 3: clear bits 6-7 (mask %00111111)
          if SPL_playerIndex = 1 then SPL_ClearBits2
          if SPL_playerIndex = 2 then SPL_ClearBits4
          if SPL_playerIndex = 3 then SPL_ClearBits6
          return
          rem Invalid index, return
          
SPL_ClearBits0
          rem Player 0: clear bits 0-1 (mask %11111100 = 252)
          let SPL_mask = 252
          let SPL_cleared = SPL_playerLocked & SPL_mask
          let SPL_cleared = SPL_cleared | SPL_lockedState
          goto SPL_Update
          
SPL_ClearBits2
          rem Player 1: clear bits 2-3 (mask %11110011 = 243)
          let SPL_mask = 243
          let SPL_cleared = SPL_playerLocked & SPL_mask
          let SPL_cleared = SPL_cleared | (SPL_lockedState * 4)
          goto SPL_Update
          
SPL_ClearBits4
          rem Player 2: clear bits 4-5 (mask %11001111 = 207)
          let SPL_mask = 207
          let SPL_cleared = SPL_playerLocked & SPL_mask
          let SPL_cleared = SPL_cleared | (SPL_lockedState * 16)
          goto SPL_Update
          
SPL_ClearBits6
          rem Player 3: clear bits 6-7 (mask %00111111 = 63)
          let SPL_mask = 63
          let SPL_cleared = SPL_playerLocked & SPL_mask
          let SPL_cleared = SPL_cleared | (SPL_lockedState * 64)
          goto SPL_Update
          
SPL_Update
          let playerLocked = SPL_cleared
          return

