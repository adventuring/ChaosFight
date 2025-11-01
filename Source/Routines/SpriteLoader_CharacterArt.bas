          rem ChaosFight - Source/Routines/SpriteLoader_CharacterArt.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem batariBASIC wrapper for character art location with bank switching
          
          rem =================================================================
          rem CHARACTER ART LOCATION WRAPPER
          rem =================================================================
          rem Wrapper that determines correct bank and switches to it
          rem Input: temp1 = character index (0-31)
          rem        temp2 = animation frame (0-7)
          rem        temp3 = animation sequence (0-15)
          rem        temp7 = player number (0-3)
          rem Output: Player sprite pointer set to character artwork
          
LocateCharacterArt
          rem Determine which bank contains this character
          rem Characters 0-7 and 16-23: Bank 2
          rem Characters 8-15 and 24-31: Bank 3 (or Bank 5 for 24-31)
          
          rem Map character to bank group: 0-7=0, 8-15=1, 16-23=2, 24-31=3
          let temp4 = temp1 / 8
          
          rem Switch to appropriate bank based on character group
          if temp4 = 0 then goto LoadFromBank2
          if temp4 = 1 then goto LoadFromBank3
          if temp4 = 2 then goto LoadFromBank2  rem 16-23 use Bank 2 (copies)
          goto LoadFromBank3  rem 24-31 use Bank 3 (copies)
          
LoadFromBank2
          rem Switch to Bank 2 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          gosub bank2 SetPlayerCharacterArt_Bank2
          return
          
LoadFromBank3
          rem Switch to Bank 3 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          gosub bank3 SetPlayerCharacterArt_Bank3
          return
          
LoadFromBank4
          rem Switch to Bank 4 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          rem Characters 16-23 (replicas of 0-7)
          gosub bank4 SetPlayerCharacterArt_Bank4
          return
          
LoadFromBank5
          rem Switch to Bank 5 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          rem Characters 24-31 (replicas of 8-15)
          gosub bank5 SetPlayerCharacterArt_Bank5
          return
          
SetPlayerCharacterArt_Bank4
          rem Called when in Bank 4 context
          rem temp1, temp2, temp3, temp7 already set
          asm
          lda temp1
          ldx temp2
          ldy temp3
          jsr LocateCharacterArt_Bank4
          lda temp7
          jsr SetPlayerCharacterArt_Bank4
          end
          return
          
SetPlayerCharacterArt_Bank5
          rem Called when in Bank 5 context
          rem temp1, temp2, temp3, temp7 already set
          asm
          lda temp1
          ldx temp2
          ldy temp3
          jsr LocateCharacterArt_Bank5
          lda temp7
          jsr SetPlayerCharacterArt_Bank5
          end
          return
          
          rem =================================================================
          rem SET PLAYER CHARACTER ART (batariBASIC interface)
          rem =================================================================
          rem Convenience function that calls LocateCharacterArt
          rem Input: temp1 = character index, temp2 = animation frame
          rem        temp3 = animation sequence, temp7 = player number
SetPlayerCharacterArt
          gosub LocateCharacterArt
          return


          rem batariBASIC wrapper for character art location with bank switching
          
          rem =================================================================
          rem CHARACTER ART LOCATION WRAPPER
          rem =================================================================
          rem Wrapper that determines correct bank and switches to it
          rem Input: temp1 = character index (0-31)
          rem        temp2 = animation frame (0-7)
          rem        temp3 = animation sequence (0-15)
          rem        temp7 = player number (0-3)
          rem Output: Player sprite pointer set to character artwork
          
LocateCharacterArt
          rem Determine which bank contains this character
          rem Characters 0-7 and 16-23: Bank 2
          rem Characters 8-15 and 24-31: Bank 3 (or Bank 5 for 24-31)
          
          rem Map character to bank group: 0-7=0, 8-15=1, 16-23=2, 24-31=3
          let temp4 = temp1 / 8
          
          rem Switch to appropriate bank based on character group
          if temp4 = 0 then goto LoadFromBank2
          if temp4 = 1 then goto LoadFromBank3
          if temp4 = 2 then goto LoadFromBank2  rem 16-23 use Bank 2 (copies)
          goto LoadFromBank3  rem 24-31 use Bank 3 (copies)
          
LoadFromBank2
          rem Switch to Bank 2 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          gosub bank2 SetPlayerCharacterArt_Bank2
          return
          
LoadFromBank3
          rem Switch to Bank 3 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          gosub bank3 SetPlayerCharacterArt_Bank3
          return
          
LoadFromBank4
          rem Switch to Bank 4 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          rem Characters 16-23 (replicas of 0-7)
          gosub bank4 SetPlayerCharacterArt_Bank4
          return
          
LoadFromBank5
          rem Switch to Bank 5 and call its character art routine
          rem temp1, temp2, temp3, temp7 already set
          rem Characters 24-31 (replicas of 8-15)
          gosub bank5 SetPlayerCharacterArt_Bank5
          return
          
SetPlayerCharacterArt_Bank4
          rem Called when in Bank 4 context
          rem temp1, temp2, temp3, temp7 already set
          asm
          lda temp1
          ldx temp2
          ldy temp3
          jsr LocateCharacterArt_Bank4
          lda temp7
          jsr SetPlayerCharacterArt_Bank4
          end
          return
          
SetPlayerCharacterArt_Bank5
          rem Called when in Bank 5 context
          rem temp1, temp2, temp3, temp7 already set
          asm
          lda temp1
          ldx temp2
          ldy temp3
          jsr LocateCharacterArt_Bank5
          lda temp7
          jsr SetPlayerCharacterArt_Bank5
          end
          return
          
          rem =================================================================
          rem SET PLAYER CHARACTER ART (batariBASIC interface)
          rem =================================================================
          rem Convenience function that calls LocateCharacterArt
          rem Input: temp1 = character index, temp2 = animation frame
          rem        temp3 = animation sequence, temp7 = player number
SetPlayerCharacterArt
          gosub LocateCharacterArt
          return

