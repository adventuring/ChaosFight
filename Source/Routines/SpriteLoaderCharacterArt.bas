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
SetPlayerCharacterArt
          rem tail call
          goto LocateCharacterArt

