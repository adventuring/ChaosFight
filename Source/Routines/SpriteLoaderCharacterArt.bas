          rem ChaosFight - Source/Routines/SpriteLoaderCharacterArt.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem batariBASIC wrapper for character art location with bank switching
          
          rem =================================================================
          rem CHARACTER ART LOCATION WRAPPER
          rem =================================================================
          rem Wrapper that determines correct bank and switches to it
          rem Input: temp1 = character index (0-31)
          rem        temp2 = animation frame (0-7) from sprite 10fps counter, NOT global frame
          rem        temp3 = action (0-15)
          rem        temp7 = player number (0-3)
          rem Output: Player sprite pointer set to character artwork
          rem Note: Frame is relative to sprite own 10fps counter, NOT global frame counter
          
LocateCharacterArt
          rem Determine which bank contains this character and calculate bank-relative index
          rem Characters 0-7: Bank 2 (bank-relative 0-7)
          rem Characters 8-15: Bank 3 (bank-relative 0-7)
          rem Characters 16-23: Bank 4 (bank-relative 0-7)
          rem Characters 24-31: Bank 5 (bank-relative 0-7)
          
          rem Save original character index
          let temp9 = temp1
          rem temp9 = bank-relative character index (0-7) - will be calculated per bank
          
          rem Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          if temp1 < 8 then goto LoadFromBank2
          if temp1 < 16 then goto LoadFromBank3
          if temp1 < 24 then goto LoadFromBank4
          goto LoadFromBank5
          
LoadFromBank2
          rem Bank 2: Characters 0-7
          rem Bank-relative index is same as character index (0-7)
          let temp9 = temp1
          rem temp9 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp8 for bank routine
          let temp8 = temp7
          rem Bank routine expects: temp9=char, temp2=frame, temp3=action, temp8=player
          gosub bank2 SetPlayerCharacterArtBank2
          return
          
LoadFromBank3
          rem Bank 3: Characters 8-15
          rem Calculate bank-relative index: character index - 8
          let temp9 = temp1 - 8
          rem temp9 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp8 for bank routine
          let temp8 = temp7
          rem Bank routine expects: temp9=char, temp2=frame, temp3=action, temp8=player
          gosub bank3 SetPlayerCharacterArtBank3
          return
          
LoadFromBank4
          rem Bank 4: Characters 16-23
          rem Calculate bank-relative index: character index - 16
          let temp9 = temp1 - 16
          rem temp9 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp8 for bank routine
          let temp8 = temp7
          rem Bank routine expects: temp9=char, temp2=frame, temp3=action, temp8=player
          gosub bank4 SetPlayerCharacterArtBank4
          return
          
LoadFromBank5
          rem Bank 5: Characters 24-31
          rem Calculate bank-relative index: character index - 24
          let temp9 = temp1 - 24
          rem temp9 = bank-relative index (0-7)
          rem temp2 = animation frame, temp3 = action
          rem Copy player number to temp8 for bank routine
          let temp8 = temp7
          rem Bank routine expects: temp9=char, temp2=frame, temp3=action, temp8=player
          gosub bank5 SetPlayerCharacterArtBank5
          return
          
          rem =================================================================
          rem SET PLAYER CHARACTER ART (batariBASIC interface)
          rem =================================================================
          rem Convenience function that calls LocateCharacterArt
          rem Input: temp1 = character index, temp2 = animation frame
          rem        temp3 = action, temp7 = player number
SetPlayerCharacterArt
          gosub LocateCharacterArt
          return

