;;; ChaosFight - Source/Routines/SpriteLoaderCharacterArt.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




LocateCharacterArt .proc
          ;; batariBASIC wrapper for character art location with bank
          ;; Returns: Far (return otherbank)

          ;; Character Art Location Wrapper

          ;; Wrapper that determines correct bank and switches to it

          ;;
          ;; Input: temp1 = character index (0-31)

          ;; temp2 = animation frame (0-7) from sprite 10fps counter,

          ;; NOT global frame

          ;; temp3 = action (0-15)

          ;; temp4 = player number (0-3)

          ;;
          ;; Output: Player sprite pointer set to character artwork

          ;; Note: Frame is relative to sprite own 10fps counter, NOT

          ;; global frame counter

          ;; Determine which bank contains this character and calculate

          ;; bank-relative index

          ;;
          ;; Input: temp1 = character index (0-31)

          ;; temp2 = animation frame (0-7) from sprite 10fps

          ;; counter

          ;; temp3 = action (0-15)

          ;; temp4 = player number (0-3)

          ;;
          ;; Output: Player sprite pointer set to character artwork via

          ;; bank-specific routine

          ;;
          ;; Mutates: temp5 (set from temp4), temp6 (bank-relative

          ;; character index)

          ;; player0-3pointerlo/hi, player0-3height (via

          ;; SetPlayerCharacterArtBankX)

          ;;
          ;; Called Routines: SetPlayerCharacterArtBank2 (bank2),

          ;; SetPlayerCharacterArtBank3 (bank3),

          ;; SetPlayerCharacterArtBank4 (bank4),

          ;; SetPlayerCharacterArtBank5 (bank5)

          ;; - These routines access character frame maps and sprite

          ;; data in their banks

          ;;
          ;; Constraints: Must be colocated with Bank2Dispatch,

          ;; Bank3Dispatch, Bank4Dispatch,

          ;; Bank5Dispatch (all called via goto)

          ;; Characters 0-7: Bank 2 (bank-relative 0-7)

          ;; Characters 8-15: Bank 3 (bank-relative 0-7)

          ;; Characters 16-23: Bank 4 (bank-relative 0-7)

          ;; Characters 24-31: Bank 5 (bank-relative 0-7)



          ;; CRITICAL: Guard against calling bank 2 when no characters on screen
          ;; Handle special sprite cases first (these are safe and don’t need bank dispatch)
          jmp BS_return
          jmp BS_return
          jmp BS_return
          ;; Save original character index in temp6

          lda temp1
          sta temp6

          ;; temp6 = bank-relative character index (0-7) - will be

          ;; calculated per bank



          ;; Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4,

          ;; 24-31=Bank5

          ;; if temp1 < 8 then jmp Bank2Dispatch          lda temp1          cmp 8          bcs .skip_8740          jmp
          lda temp1
          cmp # 8
          bcs CheckBank3
          goto_label:

          jmp Bank2Dispatch
CheckBank3:

          lda temp1
          cmp # 8
          bcs CheckBank3Label
          jmp Bank2Dispatch
CheckBank3Label:

          

          ;; if temp1 < 16 then jmp Bank3Dispatch          lda temp1          cmp 16          bcs .skip_4567          jmp
          lda temp1
          cmp # 16
          bcs CheckBank4
          jmp Bank3Dispatch
CheckBank4:

          lda temp1
          cmp # 16
          bcs CheckBank4Label
          jmp Bank3Dispatch
CheckBank4Label:

          

          ;; if temp1 < 24 then jmp Bank4Dispatch          lda temp1          cmp 24          bcs .skip_5602          jmp
          lda temp1
          cmp # 24
          bcs Bank5Dispatch
          jmp Bank4Dispatch
Bank5Dispatch:

          lda temp1
          cmp # 24
          bcs Bank5DispatchDone
          jmp Bank4Dispatch
Bank5DispatchDone:

          

          jmp Bank5Dispatch



Bank2Dispatch

          ;; Load character art from Bank 2
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 = character index (0-7), temp2 = animation

          ;; frame, temp3 = action,

          ;; temp4 = player number

          ;;
          ;; Output: Player sprite pointer set via

          ;; SetPlayerCharacterArtBank2

          ;;
          ;; Mutates: temp5 (set from temp4), temp6 (bank-relative

          ;; index 0-7)

          ;;
          ;; Called Routines: SetPlayerCharacterArtBank2 (bank2) -

          ;; accesses Bank 2 character data

          ;;
          ;; Constraints: Must be colocated with LocateCharacterArt

          ;; Bank 2: Characters 0-7

          ;; Bank-relative index is same as character index (0-7)

          lda temp1
          sta temp6

          ;; temp6 = bank-relative index (0-7)

          ;; temp2 = animation frame, temp3 = action

          ;; Copy player number to temp5 for bank routine

          lda temp4
          sta temp5

          ;; Bank routine expects: temp6=char, temp2=frame,

          ;; temp3=action, temp5=player

          ;; Cross-bank call to SetPlayerCharacterArtBank2 in bank 2
          lda # >(AfterSetPlayerCharacterArtBank2-1)
          pha
          lda # <(AfterSetPlayerCharacterArtBank2-1)
          pha
          lda # >(SetPlayerCharacterArtBank2-1)
          pha
          lda # <(SetPlayerCharacterArtBank2-1)
          pha
                    ldx # 1
          jmp BS_jsr
AfterSetPlayerCharacterArtBank2:


          jmp BS_return



Bank3Dispatch

          ;; Load character art from Bank 3
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 = character index (8-15), temp2 = animation

          ;; frame, temp3 = action,

          ;; temp4 = player number

          ;;
          ;; Output: Player sprite pointer set via

          ;; SetPlayerCharacterArtBank3

          ;;
          ;; Mutates: temp5 (set from temp4), temp6 (bank-relative

          ;; index 0-7)

          ;;
          ;; Called Routines: SetPlayerCharacterArtBank3 (bank3) -

          ;; accesses Bank 3 character data

          ;;
          ;; Constraints: Must be colocated with LocateCharacterArt

          ;; Bank 3: Characters 8-15

          ;; Calculate bank-relative index: character index - 8

          ;; Set temp6 = temp1 - 8          lda temp1          sec          sbc # 8          sta temp6
          lda temp1
          sec
          sbc # 8
          sta temp6

          lda temp1
          sec
          sbc # 8
          sta temp6


          ;; temp6 = bank-relative index (0-7)

          ;; temp2 = animation frame, temp3 = action

          ;; Copy player number to temp5 for bank routine

          lda temp4
          sta temp5

          ;; Bank routine expects: temp6=char, temp2=frame,

          ;; temp3=action, temp5=player

          ;; Cross-bank call to SetPlayerCharacterArtBank3 in bank 2
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(SLCAB3_return_point-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: SLCAB3_return_point hi (encoded)]
          lda # <(SLCAB3_return_point-1)
          pha
          ;; STACK PICTURE: [SP+1: SLCAB3_return_point hi (encoded)] [SP+0: SLCAB3_return_point lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank3-1)
          pha
          ;; STACK PICTURE: [SP+2: SLCAB3_return_point hi (encoded)] [SP+1: SLCAB3_return_point lo] [SP+0: SetPlayerCharacterArtBank3 hi (raw)]
          lda # <(SetPlayerCharacterArtBank3-1)
          pha
          ;; STACK PICTURE: [SP+3: SLCAB3_return_point hi (encoded)] [SP+2: SLCAB3_return_point lo] [SP+1: SetPlayerCharacterArtBank3 hi (raw)] [SP+0: SetPlayerCharacterArtBank3 lo]
          ldx # 2
          jmp BS_jsr
SLCAB3_return_point:


          jmp BS_return



Bank4Dispatch

          ;; Load character art from Bank 4
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 = character index (16-23), temp2 = animation

          ;; frame, temp3 = action,

          ;; temp4 = player number

          ;;
          ;; Output: Player sprite pointer set via

          ;; SetPlayerCharacterArtBank4

          ;;
          ;; Mutates: temp5 (set from temp4), temp6 (bank-relative

          ;; index 0-7)

          ;;
          ;; Called Routines: SetPlayerCharacterArtBank4 (bank4) -

          ;; accesses Bank 4 character data

          ;;
          ;; Constraints: Must be colocated with LocateCharacterArt

          ;; Bank 4: Characters 16-23

          ;; Calculate bank-relative index: character index - 16

          ;; Set temp6 = temp1 - 16          lda temp1          sec          sbc # 16          sta temp6
          lda temp1
          sec
          sbc # 16
          sta temp6

          lda temp1
          sec
          sbc # 16
          sta temp6


          ;; temp6 = bank-relative index (0-7)

          ;; temp2 = animation frame, temp3 = action

          ;; Copy player number to temp5 for bank routine

          lda temp4
          sta temp5

          ;; Bank routine expects: temp6=char, temp2=frame,

          ;; temp3=action, temp5=player

          ;; Cross-bank call to SetPlayerCharacterArtBank4 in bank 3
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(SLCAB4_return_point-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: SLCAB4_return_point hi (encoded)]
          lda # <(SLCAB4_return_point-1)
          pha
          ;; STACK PICTURE: [SP+1: SLCAB4_return_point hi (encoded)] [SP+0: SLCAB4_return_point lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank4-1)
          pha
          ;; STACK PICTURE: [SP+2: SLCAB4_return_point hi (encoded)] [SP+1: SLCAB4_return_point lo] [SP+0: SetPlayerCharacterArtBank4 hi (raw)]
          lda # <(SetPlayerCharacterArtBank4-1)
          pha
          ;; STACK PICTURE: [SP+3: SLCAB4_return_point hi (encoded)] [SP+2: SLCAB4_return_point lo] [SP+1: SetPlayerCharacterArtBank4 hi (raw)] [SP+0: SetPlayerCharacterArtBank4 lo]
          ldx # 3
          jmp BS_jsr
SLCAB4_return_point:


          jmp BS_return



SLCAB5_Bank5Dispatch:

          ;; Load character art from Bank 5
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 = character index (24-31), temp2 = animation

          ;; frame, temp3 = action,

          ;; temp4 = player number

          ;;
          ;; Output: Player sprite pointer set via

          ;; SetPlayerCharacterArtBank5

          ;;
          ;; Mutates: temp5 (set from temp4), temp6 (bank-relative

          ;; index 0-7)

          ;;
          ;; Called Routines: SetPlayerCharacterArtBank5 (bank5) -

          ;; accesses Bank 5 character data

          ;;
          ;; Constraints: Must be colocated with LocateCharacterArt

          ;; Bank 5: Characters 24-31

          ;; Calculate bank-relative index: character index - 24

          ;; Set temp6 = temp1 - 24          lda temp1          sec          sbc # 24          sta temp6
          lda temp1
          sec
          sbc # 24
          sta temp6

          lda temp1
          sec
          sbc # 24
          sta temp6


          ;; temp6 = bank-relative index (0-7)

          ;; temp2 = animation frame, temp3 = action

          ;; Copy player number to temp5 for bank routine

          lda temp4
          sta temp5

          ;; Bank routine expects: temp6=char, temp2=frame,

          ;; temp3=action, temp5=player

          ;; Cross-bank call to SetPlayerCharacterArtBank5 in bank 5
          lda # >(SLCAB5_return_point-1)
          pha
          lda # <(SLCAB5_return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank5-1)
          pha
          lda # <(SetPlayerCharacterArtBank5-1)
          pha
                    ldx # 4
          jmp BS_jsr
SLCAB5_return_point:


          jmp BS_return



.pend

