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
          rem Determine which bank contains this character
          rem Characters 0-7: Bank 2
          rem Characters 8-15: Bank 3
          rem Characters 16-23: Bank 4
          rem Characters 24-31: Bank 5
          
          rem Map character to bank group: 0-7=0, 8-15=1, 16-23=2, 24-31=3
          let temp4 = temp1 / 8
          
          rem Switch to appropriate bank based on character group
          rem Characters 0-7: Bank 2
          rem Characters 8-15: Bank 3
          rem Characters 16-23: Bank 4
          rem Characters 24-31: Bank 5
          if temp4 = 0 then goto LoadFromBank2
          if temp4 = 1 then goto LoadFromBank3
          if temp4 = 2 then goto LoadFromBank4
          goto LoadFromBank5
          
LoadFromBank2
          rem Switch to Bank 2 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          gosub bank2 SetPlayerCharacterArtBank2
          return
          
LoadFromBank3
          rem Switch to Bank 3 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          gosub bank3 SetPlayerCharacterArtBank3
          return
          
LoadFromBank4
          rem Switch to Bank 4 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          rem Characters 16-23
          gosub bank4 SetPlayerCharacterArtBank4
          return
          
LoadFromBank5
          rem Switch to Bank 5 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          rem Characters 24-31
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

