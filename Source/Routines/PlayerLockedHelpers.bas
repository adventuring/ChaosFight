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

          rem Extract 2 bits for this player using computed shift
          rem Shift amount = player_index * 2
          temp2 = temp1 * 2
          temp3 = temp3 / (2 ^ temp2)
          temp2 = temp3 & 3

          rem Invalid index check (temp1 should be 0-3)
          rem Restructure to avoid forward jumps that cause bank address issues
          if temp1 < 0 then temp2 = 0 : return
          if temp1 > 3 then temp2 = 0 : return
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

          rem Invalid index check (temp1 should be 0-3)
          rem Restructure to avoid forward jumps that cause bank address issues
          if temp1 < 0 then return
          if temp1 > 3 then return

          temp3 = playerLocked
          rem Get current playerLocked value

          rem Compute mask and shift value based on player index
          rem Shift amount = player_index * 2
          temp4 = temp1 * 2

          rem Create mask to clear the 2 bits for this player
          rem Mask = ~(3 << shift) & 255
          temp5 = 3 * (2 ^ temp4)
          temp5 = temp5 ^ 255  ; XOR with 255 gives bitwise NOT
          temp5 = temp3 & temp5 ; Clear the bits

          rem Set the new value
          temp4 = temp2 * (2 ^ (temp1 * 2))
          temp5 = temp5 | temp4

          let playerLocked = temp5
          return

