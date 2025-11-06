          rem ChaosFight - Source/Routines/SpriteLoaderCharacterArt.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem batariBASIC wrapper for character art location with bank
          rem   switching
          
          rem ==========================================================
          rem CHARACTER ART LOCATION WRAPPER
          rem ==========================================================
          rem Wrapper that determines correct bank and switches to it
          rem Input: temp1 = character index (0-31)
          rem temp2 = animation frame (0-7) from sprite 10fps counter,
          rem   NOT global frame
          rem        temp3 = action (0-15)
          rem        temp4 = player number (0-3)
          rem Output: Player sprite pointer set to character artwork
          rem Note: Frame is relative to sprite own 10fps counter, NOT
          rem   global frame counter
          
LocateCharacterArt
          rem Determine which bank contains this character and calculate
          rem   bank-relative index
          rem Input: temp1 = character index (0-31)
          rem        temp2 = animation frame (0-7) from sprite 10fps counter
          rem        temp3 = action (0-15)
          rem        temp4 = player number (0-3)
          rem Output: Player sprite pointer set to character artwork via bank-specific routine
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative character index)
          rem           player0-3pointerlo/hi, player0-3height (via SetPlayerCharacterArtBankX)
          rem Called Routines: SetPlayerCharacterArtBank2 (bank2), SetPlayerCharacterArtBank3 (bank3),
          rem   SetPlayerCharacterArtBank4 (bank4), SetPlayerCharacterArtBank5 (bank5)
          rem   - These routines access character frame maps and sprite data in their banks
          rem Constraints: Must be colocated with LoadFromBank2, LoadFromBank3, LoadFromBank4,
          rem              LoadFromBank5 (all called via goto)
          rem Characters 0-7: Bank 2 (bank-relative 0-7)
          rem Characters 8-15: Bank 3 (bank-relative 0-7)
          rem Characters 16-23: Bank 4 (bank-relative 0-7)
          rem Characters 24-31: Bank 5 (bank-relative 0-7)
          
          rem Save original character index in temp6
          let temp6 = temp1
          rem temp6 = bank-relative character index (0-7) - will be
          rem   calculated per bank
          
          rem Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4,
          rem   24-31=Bank5
          if temp1 < 8 then LoadFromBank2
          if temp1 < 16 then LoadFromBank3
          if temp1 < 24 then goto LoadFromBank4
          goto LoadFromBank5
          
LoadFromBank2
          rem Load character art from Bank 2
          rem Input: temp1 = character index (0-7), temp2 = animation frame, temp3 = action,
          rem        temp4 = player number
          rem Output: Player sprite pointer set via SetPlayerCharacterArtBank2
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative index 0-7)
          rem Called Routines: SetPlayerCharacterArtBank2 (bank2) - accesses Bank 2 character data
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 2: Characters 0-7
          rem Bank-relative index is same as character index (0-7)
          let temp6 = temp1
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp5 for bank routine
          let temp5 = temp4
          rem Bank routine expects: temp6=char, temp2=frame,
          rem   temp3=action, temp5=player
          gosub SetPlayerCharacterArtBank2 bank2
          return
          
LoadFromBank3
          rem Load character art from Bank 3
          rem Input: temp1 = character index (8-15), temp2 = animation frame, temp3 = action,
          rem        temp4 = player number
          rem Output: Player sprite pointer set via SetPlayerCharacterArtBank3
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative index 0-7)
          rem Called Routines: SetPlayerCharacterArtBank3 (bank3) - accesses Bank 3 character data
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 3: Characters 8-15
          rem Calculate bank-relative index: character index - 8
          let temp6 = temp1 - 8
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp5 for bank routine
          let temp5 = temp4
          rem Bank routine expects: temp6=char, temp2=frame,
          rem   temp3=action, temp5=player
          gosub SetPlayerCharacterArtBank3 bank3
          return
          
LoadFromBank4
          rem Load character art from Bank 4
          rem Input: temp1 = character index (16-23), temp2 = animation frame, temp3 = action,
          rem        temp4 = player number
          rem Output: Player sprite pointer set via SetPlayerCharacterArtBank4
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative index 0-7)
          rem Called Routines: SetPlayerCharacterArtBank4 (bank4) - accesses Bank 4 character data
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 4: Characters 16-23
          rem Calculate bank-relative index: character index - 16
          let temp6 = temp1 - 16
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp5 for bank routine
          let temp5 = temp4
          rem Bank routine expects: temp6=char, temp2=frame,
          rem   temp3=action, temp5=player
          gosub SetPlayerCharacterArtBank4 bank4
          return
          
LoadFromBank5
          rem Load character art from Bank 5
          rem Input: temp1 = character index (24-31), temp2 = animation frame, temp3 = action,
          rem        temp4 = player number
          rem Output: Player sprite pointer set via SetPlayerCharacterArtBank5
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative index 0-7)
          rem Called Routines: SetPlayerCharacterArtBank5 (bank5) - accesses Bank 5 character data
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 5: Characters 24-31
          rem Calculate bank-relative index: character index - 24
          let temp6 = temp1 - 24
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp5 for bank routine
          let temp5 = temp4
          rem Bank routine expects: temp6=char, temp2=frame,
          rem   temp3=action, temp5=player
          gosub SetPlayerCharacterArtBank5 bank5
          return
          
          rem ==========================================================
          rem SET PLAYER CHARACTER ART (batariBASIC interface)
          rem ==========================================================
          rem Convenience function that calls LocateCharacterArt
          rem Input: temp1 = character index, temp2 = animation frame
          rem        temp3 = action, temp4 = player number
          rem Output: Player sprite pointer set via LocateCharacterArt
          rem Mutates: See LocateCharacterArt
          rem Called Routines: LocateCharacterArt (tail call)
          rem Constraints: Must be colocated with LocateCharacterArt (tail call)
          rem              Only reachable via gosub/goto (could be own file)
SetPlayerCharacterArt
          rem tail call
          goto LocateCharacterArt

