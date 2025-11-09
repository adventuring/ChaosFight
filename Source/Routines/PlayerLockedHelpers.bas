          rem ChaosFight - Source/Routines/PlayerLockedHelpers.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

GetPlayerLocked
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
          rem Input: temp1 = player index (0-3), playerLocked (bit-packed)
          rem Output: temp2 = locked state (0=unlocked, 1=normal, 2=handicap)
          rem Mutates: temp2, temp3
          rem
          rem Called Routines: None
          rem Constraints: None
          temp3 = playerLocked
          
          rem Extract 2 bits for this player
          rem Player 0: bits 0-1 (shift right 0, mask %00000011)
          rem Player 1: bits 2-3 (shift right 2, mask %00000011)
          rem Player 2: bits 4-5 (shift right 4, mask %00000011)
          rem Player 3: bits 6-7 (shift right 6, mask %00000011)
          if temp1 = 0 then GPL_ExtractBits0
          if temp1 = 1 then GPL_ExtractBits2
          if temp1 = 2 then GPL_ExtractBits4
          if temp1 = 3 then GPL_ExtractBits6
          temp2 = 0
          rem Invalid index, return 0
          goto GPL_Done
          
GPL_ExtractBits0
          temp2 = temp3 & 3
          rem Player 0: bits 0-1
          goto GPL_Done
          
GPL_ExtractBits2
          temp2 = temp3 / 4
          rem Player 1: bits 2-3
          temp2 = temp2 & 3
          goto GPL_Done
          
GPL_ExtractBits4
          temp2 = temp3 / 16
          rem Player 2: bits 4-5
          temp2 = temp2 & 3
          goto GPL_Done
          
GPL_ExtractBits6
          temp2 = temp3 / 64
          rem Player 3: bits 6-7
          temp2 = temp2 & 3
          goto GPL_Done
          
GPL_Done
          return

SetPlayerLocked
          rem
          rem Set Player Locked State
          rem Sets the locked state for a specific player
          rem
          rem INPUT: temp1 = player index (0-3)
          rem         temp2 = locked state (0=unlocked, 1=normal,
          rem         2=handicap)
          rem
          rem OUTPUT: playerLocked variable updated
          rem Set the locked state for a specific player in bit-packed
          rem playerLocked variable
          rem
          rem Input: temp1 = player index (0-3), temp2 = locked state
          rem (0=unlocked, 1=normal, 2=handicap), playerLocked (global)
          rem = current bit-packed locked states
          rem
          rem Output: playerLocked (global) updated with new state for
          rem specified player
          rem
          rem Mutates: playerLocked (global), temp3-temp5 (used for bit
          rem manipulation)
          rem
          rem Called Routines: None
          rem Constraints: None
          
          temp3 = playerLocked
          rem Get current playerLocked value
          
          rem Clear the 2 bits for this player
          rem Player 0: clear bits 0-1 (mask %11111100)
          rem Player 1: clear bits 2-3 (mask %11110011)
          rem Player 2: clear bits 4-5 (mask %11001111)
          rem Player 3: clear bits 6-7 (mask %00111111)
          if temp1 = 0 then SPL_ClearBits0
          if temp1 = 1 then SPL_ClearBits2
          if temp1 = 2 then SPL_ClearBits4
          if temp1 = 3 then SPL_ClearBits6
          return
          rem Invalid index, return
          
SPL_ClearBits0
          rem Player 0: clear bits 0-1 (mask %11111100 = 252)
          temp4 = 252
          temp5 = temp3 & temp4
          temp5 = temp5 | temp2
          goto SPL_Update
          
SPL_ClearBits2
          rem Player 1: clear bits 2-3 (mask %11110011 = 243)
          temp4 = 243
          temp5 = temp3 & temp4
          temp5 = temp5 | (temp2 * 4)
          goto SPL_Update
          
SPL_ClearBits4
          rem Player 2: clear bits 4-5 (mask %11001111 = 207)
          temp4 = 207
          temp5 = temp3 & temp4
          temp5 = temp5 | (temp2 * 16)
          goto SPL_Update
          
SPL_ClearBits6
          rem Player 3: clear bits 6-7 (mask %00111111 = 63)
          temp4 = 63
          temp5 = temp3 & temp4
          temp5 = temp5 | (temp2 * 64)
          goto SPL_Update
          
SPL_Update
          let playerLocked = temp5
          return

