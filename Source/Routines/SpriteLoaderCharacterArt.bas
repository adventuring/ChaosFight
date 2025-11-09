          rem ChaosFight - Source/Routines/SpriteLoaderCharacterArt.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.

LocateCharacterArt
          rem batariBASIC wrapper for character art location with bank
          rem Character Art Location Wrapper
          rem Wrapper that determines correct bank and switches to it
          rem
          rem Input: temp1 = character index (0-31)
          rem temp2 = animation frame (0-7) from sprite 10fps counter,
          rem   NOT global frame
          rem        temp3 = action (0-15)
          rem        temp4 = player number (0-3)
          rem
          rem Output: Player sprite pointer set to character artwork
          rem Note: Frame is relative to sprite own 10fps counter, NOT
          rem   global frame counter
          rem Determine which bank contains this character and calculate
          rem   bank-relative index
          rem
          rem Input: temp1 = character index (0-31)
          rem        temp2 = animation frame (0-7) from sprite 10fps
          rem        counter
          rem        temp3 = action (0-15)
          rem        temp4 = player number (0-3)
          rem
          rem Output: Player sprite pointer set to character artwork via
          rem bank-specific routine
          rem
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative
          rem character index)
          rem           player0-3pointerlo/hi, player0-3height (via
          rem           SetPlayerCharacterArtBankX)
          rem
          rem Called Routines: SetPlayerCharacterArtBank2 (bank2),
          rem SetPlayerCharacterArtBank3 (bank3),
          rem   SetPlayerCharacterArtBank4 (bank4),
          rem   SetPlayerCharacterArtBank5 (bank5)
          rem   - These routines access character frame maps and sprite
          rem   data in their banks
          rem
          rem Constraints: Must be colocated with LoadFromBank2,
          rem LoadFromBank3, LoadFromBank4,
          rem              LoadFromBank5 (all called via goto)
          rem Characters 0-7: Bank 2 (bank-relative 0-7)
          rem Characters 8-15: Bank 3 (bank-relative 0-7)
          rem Characters 16-23: Bank 4 (bank-relative 0-7)
          rem Characters 24-31: Bank 5 (bank-relative 0-7)
          
          let temp6 = temp1
          rem Save original character index in temp6
          rem temp6 = bank-relative character index (0-7) - will be
          rem   calculated per bank
          
          rem Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4,
          rem 24-31=Bank5
          if temp1 < 8 then LoadFromBank2
          if temp1 < 16 then LoadFromBank3
          if temp1 < 24 then goto LoadFromBank4
          goto LoadFromBank5
          
LoadFromBank2
          rem Load character art from Bank 2
          rem
          rem Input: temp1 = character index (0-7), temp2 = animation
          rem frame, temp3 = action,
          rem        temp4 = player number
          rem
          rem Output: Player sprite pointer set via
          rem SetPlayerCharacterArtBank2
          rem
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative
          rem index 0-7)
          rem
          rem Called Routines: SetPlayerCharacterArtBank2 (bank2) -
          rem accesses Bank 2 character data
          rem
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 2: Characters 0-7
          let temp6 = temp1
          rem Bank-relative index is same as character index (0-7)
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          let temp5 = temp4
          rem Copy player number to temp5 for bank routine
          rem Bank routine expects: temp6=char, temp2=frame,
          gosub SetPlayerCharacterArtBank2 bank2
          rem temp3=action, temp5=player
          return
          
LoadFromBank3
          rem Load character art from Bank 3
          rem
          rem Input: temp1 = character index (8-15), temp2 = animation
          rem frame, temp3 = action,
          rem        temp4 = player number
          rem
          rem Output: Player sprite pointer set via
          rem SetPlayerCharacterArtBank3
          rem
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative
          rem index 0-7)
          rem
          rem Called Routines: SetPlayerCharacterArtBank3 (bank3) -
          rem accesses Bank 3 character data
          rem
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 3: Characters 8-15
          let temp6 = temp1 - 8
          rem Calculate bank-relative index: character index - 8
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          let temp5 = temp4
          rem Copy player number to temp5 for bank routine
          rem Bank routine expects: temp6=char, temp2=frame,
          gosub SetPlayerCharacterArtBank3 bank3
          rem temp3=action, temp5=player
          return
          
LoadFromBank4
          rem Load character art from Bank 4
          rem
          rem Input: temp1 = character index (16-23), temp2 = animation
          rem frame, temp3 = action,
          rem        temp4 = player number
          rem
          rem Output: Player sprite pointer set via
          rem SetPlayerCharacterArtBank4
          rem
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative
          rem index 0-7)
          rem
          rem Called Routines: SetPlayerCharacterArtBank4 (bank4) -
          rem accesses Bank 4 character data
          rem
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 4: Characters 16-23
          let temp6 = temp1 - 16
          rem Calculate bank-relative index: character index - 16
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          let temp5 = temp4
          rem Copy player number to temp5 for bank routine
          rem Bank routine expects: temp6=char, temp2=frame,
          gosub SetPlayerCharacterArtBank4 bank4
          rem temp3=action, temp5=player
          return
          
LoadFromBank5
          rem Load character art from Bank 5
          rem
          rem Input: temp1 = character index (24-31), temp2 = animation
          rem frame, temp3 = action,
          rem        temp4 = player number
          rem
          rem Output: Player sprite pointer set via
          rem SetPlayerCharacterArtBank5
          rem
          rem Mutates: temp5 (set from temp4), temp6 (bank-relative
          rem index 0-7)
          rem
          rem Called Routines: SetPlayerCharacterArtBank5 (bank5) -
          rem accesses Bank 5 character data
          rem
          rem Constraints: Must be colocated with LocateCharacterArt
          rem Bank 5: Characters 24-31
          let temp6 = temp1 - 24
          rem Calculate bank-relative index: character index - 24
          rem temp6 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          let temp5 = temp4
          rem Copy player number to temp5 for bank routine
          rem Bank routine expects: temp6=char, temp2=frame,
          gosub SetPlayerCharacterArtBank5 bank5
          rem temp3=action, temp5=player
          return
          
SetPlayerCharacterArt
          rem
          rem SET PLAYER CHARACTER ART (bataribasic Interface)
          rem Convenience function that calls LocateCharacterArt
          rem
          rem Input: temp1 = character index, temp2 = animation frame
          rem        temp3 = action, temp4 = player number
          rem
          rem Output: Player sprite pointer set via LocateCharacterArt
          rem
          rem Mutates: See LocateCharacterArt
          rem
          rem Called Routines: LocateCharacterArt (tail call)
          rem
          rem Constraints: Must be colocated with LocateCharacterArt
          rem (tail call)
          rem              Only reachable via gosub/goto (could be own
          rem              file)
          goto LocateCharacterArt
          rem tail call

