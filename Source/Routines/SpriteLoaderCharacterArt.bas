          rem ChaosFight - Source/Routines/SpriteLoaderCharacterArt.bas

          rem Copyright © 2025 Bruce-Robert Pocock.



LocateCharacterArt
          rem Returns: Far (return otherbank)

          asm

LocateCharacterArt

end

          rem batariBASIC wrapper for character art location with bank
          rem Returns: Far (return otherbank)

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

          rem Constraints: Must be colocated with Bank2Dispatch,

          rem Bank3Dispatch, Bank4Dispatch,

          rem              Bank5Dispatch (all called via goto)

          rem Characters 0-7: Bank 2 (bank-relative 0-7)

          rem Characters 8-15: Bank 3 (bank-relative 0-7)

          rem Characters 16-23: Bank 4 (bank-relative 0-7)

          rem Characters 24-31: Bank 5 (bank-relative 0-7)



          rem Save original character index in temp6

          let temp6 = temp1

          rem temp6 = bank-relative character index (0-7) - will be

          rem   calculated per bank



          rem Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4,

          rem 24-31=Bank5

          if temp1 < 8 then goto Bank2Dispatch

          if temp1 < 16 then goto Bank3Dispatch

          if temp1 < 24 then goto Bank4Dispatch

          goto Bank5Dispatch



Bank2Dispatch

          rem Load character art from Bank 2
          rem Returns: Far (return otherbank)

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

          rem Bank-relative index is same as character index (0-7)

          let temp6 = temp1

          rem temp6 = bank-relative index (0-7)

          rem temp2 = animation frame, temp3 = action

          rem Copy player number to temp5 for bank routine

          let temp5 = temp4

          rem Bank routine expects: temp6=char, temp2=frame,

          rem temp3=action, temp5=player

          gosub SetPlayerCharacterArtBank2 bank2

          return otherbank



Bank3Dispatch

          rem Load character art from Bank 3
          rem Returns: Far (return otherbank)

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

          rem Calculate bank-relative index: character index - 8

          let temp6 = temp1 - 8

          rem temp6 = bank-relative index (0-7)

          rem temp2 = animation frame, temp3 = action

          rem Copy player number to temp5 for bank routine

          let temp5 = temp4

          rem Bank routine expects: temp6=char, temp2=frame,

          rem temp3=action, temp5=player

          gosub SetPlayerCharacterArtBank3 bank3

          return otherbank



Bank4Dispatch

          rem Load character art from Bank 4
          rem Returns: Far (return otherbank)

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

          rem Calculate bank-relative index: character index - 16

          let temp6 = temp1 - 16

          rem temp6 = bank-relative index (0-7)

          rem temp2 = animation frame, temp3 = action

          rem Copy player number to temp5 for bank routine

          let temp5 = temp4

          rem Bank routine expects: temp6=char, temp2=frame,

          rem temp3=action, temp5=player

          gosub SetPlayerCharacterArtBank4 bank4

          return otherbank



Bank5Dispatch

          rem Load character art from Bank 5
          rem Returns: Far (return otherbank)

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

          rem Calculate bank-relative index: character index - 24

          let temp6 = temp1 - 24

          rem temp6 = bank-relative index (0-7)

          rem temp2 = animation frame, temp3 = action

          rem Copy player number to temp5 for bank routine

          let temp5 = temp4

          rem Bank routine expects: temp6=char, temp2=frame,

          rem temp3=action, temp5=player

          gosub SetPlayerCharacterArtBank5 bank5

          return otherbank


