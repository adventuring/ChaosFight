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
          rem Mutates: temp2
          rem
          rem Called Routines: None
          rem Constraints: None

          rem Invalid index check (temp1 should be 0-3)
          if temp1 < 0 then temp2 = 0 : return
          if temp1 > 3 then temp2 = 0 : return

          rem Extract 2 bits for this player
          rem Use bit shift operations compatible with batariBASIC
          if temp1 = 0 then temp2 = playerLocked & 3 : return
          if temp1 = 1 then temp2 = (playerLocked >> 2) & 3 : return
          if temp1 = 2 then temp2 = (playerLocked >> 4) & 3 : return
          if temp1 = 3 then temp2 = (playerLocked >> 6) & 3 : return

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
          rem Mutates: playerLocked (global)
          rem
          rem Called Routines: None
          rem Constraints: None

          rem Invalid index check (temp1 should be 0-3)
          if temp1 < 0 then return
          if temp1 > 3 then return

          rem Clear the 2 bits for this player and set the new value
          rem Use bit operations compatible with batariBASIC
          if temp1 = 0 then playerLocked = (playerLocked & 252) | temp2 : return
          if temp1 = 1 then playerLocked = (playerLocked & 243) | (temp2 << 2) : return
          if temp1 = 2 then playerLocked = (playerLocked & 207) | (temp2 << 4) : return
          if temp1 = 3 then playerLocked = (playerLocked & 63) | (temp2 << 6) : return

          return

