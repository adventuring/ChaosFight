;;; ChaosFight - Source/Routines/SpriteLoader.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; SUPPORTED SPRITE CONFIGURATIONS:
          ;; P0 = character | ?
          ;; P1 = character | CPU | No | ?
          ;; P2 = character | No | ?
          ;; P3 = character | No | ?
          ;; P4 = digit | blank (arena select only)
          ;; P5 = digit | ? (arena select only)
          ;;
          ;; Multi-bank sprite loading system - supports 32 characters across 4 banks


LoadCharacterSprite .proc
          ;; Load character sprite data - calls LocateCharacterArt (bank9)
          ;; Returns: Far (return otherbank)
          ;; Input: currentCharacter (global), currentPlayer (global)
          ;; temp2 = animation frame (0-7), temp3 = animation action (0-15)
          ;; Output: Sprite loaded via bank9 routines
          ;; Inputs are trusted in internal context; skip range validation
          ;; CRITICAL: Only run during game mode - publisher prelude has no characters
          ;; This prevents stack overflow when called during publisher prelude (gameMode = 0)
          ;; Special sprite cases (NoCharacter, CPUCharacter, RandomCharacter) are safe to handle
          ;; but normal character loading must be guarded
          ;; Handle special sprite cases first (these are safe)
          ;; Cross-bank call to CopyGlyphToPlayer in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterCopyGlyphToPlayerBank15-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCopyGlyphToPlayerBank15 hi (encoded)]
          lda # <(AfterCopyGlyphToPlayerBank15-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCopyGlyphToPlayerBank15 hi (encoded)] [SP+0: AfterCopyGlyphToPlayerBank15 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCopyGlyphToPlayerBank15 hi (encoded)] [SP+1: AfterCopyGlyphToPlayerBank15 lo] [SP+0: CopyGlyphToPlayer hi (raw)]
          lda # <(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCopyGlyphToPlayerBank15 hi (encoded)] [SP+2: AfterCopyGlyphToPlayerBank15 lo] [SP+1: CopyGlyphToPlayer hi (raw)] [SP+0: CopyGlyphToPlayer lo]
          ldx # 15
          jmp BS_jsr

AfterCopyGlyphToPlayerBank15:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterCopyGlyphToPlayerBank16-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCopyGlyphToPlayerBank16 hi (encoded)]
          lda # <(AfterCopyGlyphToPlayerBank16-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCopyGlyphToPlayerBank16 hi (encoded)] [SP+0: AfterCopyGlyphToPlayerBank16 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCopyGlyphToPlayerBank16 hi (encoded)] [SP+1: AfterCopyGlyphToPlayerBank16 lo] [SP+0: CopyGlyphToPlayer hi (raw)]
          lda # <(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCopyGlyphToPlayerBank16 hi (encoded)] [SP+2: AfterCopyGlyphToPlayerBank16 lo] [SP+1: CopyGlyphToPlayer hi (raw)] [SP+0: CopyGlyphToPlayer lo]
          ldx # 15
          jmp BS_jsr

AfterCopyGlyphToPlayerBank16:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterCopyGlyphToPlayerBank16Second-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCopyGlyphToPlayerBank16Second hi (encoded)]
          lda # <(AfterCopyGlyphToPlayerBank16Second-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCopyGlyphToPlayerBank16Second hi (encoded)] [SP+0: AfterCopyGlyphToPlayerBank16Second lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCopyGlyphToPlayerBank16Second hi (encoded)] [SP+1: AfterCopyGlyphToPlayerBank16Second lo] [SP+0: CopyGlyphToPlayer hi (raw)]
          lda # <(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCopyGlyphToPlayerBank16Second hi (encoded)] [SP+2: AfterCopyGlyphToPlayerBank16Second lo] [SP+1: CopyGlyphToPlayer hi (raw)] [SP+0: CopyGlyphToPlayer lo]
          ldx # 15
          jmp BS_jsr

AfterCopyGlyphToPlayerBank16Second:

          ;; Normal character sprite loading
          lda currentPlayer
          sta temp4
          lda currentCharacter
          sta temp1
          ;; Cross-bank call to LocateCharacterArt in bank 8
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterLocateCharacterArt-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLocateCharacterArt hi (encoded)]
          lda # <(AfterLocateCharacterArt-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLocateCharacterArt hi (encoded)] [SP+0: AfterLocateCharacterArt lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LocateCharacterArt-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLocateCharacterArt hi (encoded)] [SP+1: AfterLocateCharacterArt lo] [SP+0: LocateCharacterArt hi (raw)]
          lda # <(LocateCharacterArt-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLocateCharacterArt hi (encoded)] [SP+2: AfterLocateCharacterArt lo] [SP+1: LocateCharacterArt hi (raw)] [SP+0: LocateCharacterArt lo]
          ldx # 8
          jmp BS_jsr
AfterLocateCharacterArt:


          jmp BS_return

.pend

LoadPlayerSprite .proc
          ;;
          ;; LOAD PLAYER SPRITE (generic Dispatcher)
          ;; Load sprite data for any player using character art system
          ;;
          ;; Input:
          ;;        currentPlayer (global) = player index (0-3)
          ;;        playerCharacter[] (global array) = character indices per player
          ;;        temp2 = animation frame (0-7) from sprite 10fps counter
          ;;        temp3 = animation action (0-15) from currentAnimationSeq
          ;;        temp4 = player number (0-3)
          ;;
          ;; Note: Frame is relative to sprite own 10fps counter, NOT global frame counter
          ;;
          ;; Output: Sprite data loaded via LocateCharacterArt (bank9)
          ;;
          ;; Mutates: currentCharacter (global), temp1 (passed to LocateCharacterArt)
          ;;
          ;; Called Routines: LocateCharacterArt (bank9) - see LoadCharacterSprite
          ;;
          ;; Constraints: Must be colocated with LoadPlayerSpriteDispatch (called via goto)
          ;;
          ;; Get character index for this player from playerCharacter array
          ;; Use currentPlayer global variable (set by caller)
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
; Set currentCharacter from playerCharacter[currentPlayer]
          ;; CRITICAL: Guard against invalid characters - prevent calling bank 2 when no characters on screen
          ;; Handle special sprite cases first (these are safe and don’t need bank dispatch)
          ;; Cross-bank call to CopyGlyphToPlayer in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterCopyGlyphToPlayerBank16First-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCopyGlyphToPlayerBank16First hi (encoded)]
          lda # <(AfterCopyGlyphToPlayerBank16First-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCopyGlyphToPlayerBank16First hi (encoded)] [SP+0: AfterCopyGlyphToPlayerBank16First lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCopyGlyphToPlayerBank16First hi (encoded)] [SP+1: AfterCopyGlyphToPlayerBank16First lo] [SP+0: CopyGlyphToPlayer hi (raw)]
          lda # <(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCopyGlyphToPlayerBank16First hi (encoded)] [SP+2: AfterCopyGlyphToPlayerBank16First lo] [SP+1: CopyGlyphToPlayer hi (raw)] [SP+0: CopyGlyphToPlayer lo]
          ldx # 15
          jmp BS_jsr
AfterCopyGlyphToPlayerBank16First:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterCopyGlyphToPlayerBank16SecondFirst-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCopyGlyphToPlayerBank16SecondFirst hi (encoded)]
          lda # <(AfterCopyGlyphToPlayerBank16SecondFirst-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCopyGlyphToPlayerBank16SecondFirst hi (encoded)] [SP+0: AfterCopyGlyphToPlayerBank16SecondFirst lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCopyGlyphToPlayerBank16SecondFirst hi (encoded)] [SP+1: AfterCopyGlyphToPlayerBank16SecondFirst lo] [SP+0: CopyGlyphToPlayer hi (raw)]
          lda # <(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCopyGlyphToPlayerBank16SecondFirst hi (encoded)] [SP+2: AfterCopyGlyphToPlayerBank16SecondFirst lo] [SP+1: CopyGlyphToPlayer hi (raw)] [SP+0: CopyGlyphToPlayer lo]
          ldx # 15
          jmp BS_jsr
AfterCopyGlyphToPlayerBank16SecondFirst:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterCopyGlyphToPlayerBank16SecondSecond-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCopyGlyphToPlayerBank16SecondSecond hi (encoded)]
          lda # <(AfterCopyGlyphToPlayerBank16SecondSecond-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCopyGlyphToPlayerBank16SecondSecond hi (encoded)] [SP+0: AfterCopyGlyphToPlayerBank16SecondSecond lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCopyGlyphToPlayerBank16SecondSecond hi (encoded)] [SP+1: AfterCopyGlyphToPlayerBank16SecondSecond lo] [SP+0: CopyGlyphToPlayer hi (raw)]
          lda # <(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCopyGlyphToPlayerBank16SecondSecond hi (encoded)] [SP+2: AfterCopyGlyphToPlayerBank16SecondSecond lo] [SP+1: CopyGlyphToPlayer hi (raw)] [SP+0: CopyGlyphToPlayer lo]
          ldx # 15
          jmp BS_jsr
AfterCopyGlyphToPlayerBank16SecondSecond:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 15
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterCopyGlyphToPlayerBank16Third-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCopyGlyphToPlayerBank16Third hi (encoded)]
          lda # <(AfterCopyGlyphToPlayerBank16Third-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCopyGlyphToPlayerBank16Third hi (encoded)] [SP+0: AfterCopyGlyphToPlayerBank16Third lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCopyGlyphToPlayerBank16Third hi (encoded)] [SP+1: AfterCopyGlyphToPlayerBank16Third lo] [SP+0: CopyGlyphToPlayer hi (raw)]
          lda # <(CopyGlyphToPlayer-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCopyGlyphToPlayerBank16Third hi (encoded)] [SP+2: AfterCopyGlyphToPlayerBank16Third lo] [SP+1: CopyGlyphToPlayer hi (raw)] [SP+0: CopyGlyphToPlayer lo]
          ldx # 15
          jmp BS_jsr
AfterCopyGlyphToPlayerBank16Third:

          ;; Inline LocateCharacterArt to reduce call chain depth (stack overflow fix)
          ;; Returns: Far (return otherbank)
          ;; CRITICAL: Inlined to reduce stack depth from 19 to 15 bytes (within 16-byte limit)
          ;; Original: cross-bank call to LocateCharacterArt bank9 (4 bytes saved by inlining)
          lda currentCharacter
          sta temp1
          ;; Save original character index in temp6 for bank-relative calculation
          lda temp1
          sta temp6
          ;; Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          ;; Use jmp instead of cross-bank call to to avoid stack push
          lda temp1
          cmp # 8
          bcs CheckBank3
          jmp LoadPlayerSprite_Bank2Dispatch

CheckBank3:


          ;; if temp1 < 16 then jmp LoadPlayerSprite_Bank3Dispatch
          lda temp1
          cmp # 16
          bcs CheckBank4
          jmp LoadPlayerSprite_Bank3Dispatch

CheckBank4:


          ;; if temp1 < 24 then jmp LoadPlayerSprite_Bank4Dispatch
          lda temp1
          cmp # 24
          bcs LoadPlayerSprite_Bank5Dispatch
          jmp LoadPlayerSprite_Bank4Dispatch

          ;; temp1 >= 24, fall through to LoadPlayerSprite_Bank5Dispatch (defined below)

LoadPlayerSprite_Bank2Dispatch
          ;; Bank 2: Characters 0-7 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank2 uses BS_return which requires return address
          lda temp1
          sta temp6
          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank2 in bank 1
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank2-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank2 hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank2-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank2 hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank2 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank2-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank2 hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank2 lo] [SP+0: SetPlayerCharacterArtBank2 hi (raw)]
          lda # <(SetPlayerCharacterArtBank2-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank2 hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank2 lo] [SP+1: SetPlayerCharacterArtBank2 hi (raw)] [SP+0: SetPlayerCharacterArtBank2 lo]
          ldx # 1
          jmp BS_jsr
AfterSetPlayerCharacterArtBank2:

          jmp BS_return

LoadPlayerSprite_Bank3Dispatch
          ;; Bank 3: Characters 8-15 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank3 uses BS_return which requires return address
          ;; Set temp6 = temp1 - 8          lda temp1          sec          sbc # 8          sta temp6
          lda temp1
          sec
          sbc # 8
          sta temp6

          lda temp1
          sec
          sbc # 8
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank3 in bank 2
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank3-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank3 hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank3-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank3 hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank3 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank3-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank3 hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank3 lo] [SP+0: SetPlayerCharacterArtBank3 hi (raw)]
          lda # <(SetPlayerCharacterArtBank3-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank3 hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank3 lo] [SP+1: SetPlayerCharacterArtBank3 hi (raw)] [SP+0: SetPlayerCharacterArtBank3 lo]
          ldx # 2
          jmp BS_jsr
AfterSetPlayerCharacterArtBank3:

          jmp BS_return

LoadPlayerSprite_Bank4Dispatch
          ;; Bank 4: Characters 16-23 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank4 uses BS_return which requires return address
          ;; Set temp6 = temp1 - 16          lda temp1          sec          sbc # 16          sta temp6
          lda temp1
          sec
          sbc # 16
          sta temp6

          lda temp1
          sec
          sbc # 16
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank4 in bank 3
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank4-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank4 hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank4-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank4 hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank4 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank4-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank4 hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank4 lo] [SP+0: SetPlayerCharacterArtBank4 hi (raw)]
          lda # <(SetPlayerCharacterArtBank4-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank4 hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank4 lo] [SP+1: SetPlayerCharacterArtBank4 hi (raw)] [SP+0: SetPlayerCharacterArtBank4 lo]
          ldx # 3
          jmp BS_jsr
AfterSetPlayerCharacterArtBank4:

          jmp BS_return

LoadPlayerSprite_Bank5Dispatch
          ;; Bank 5: Characters 24-31 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank5 uses BS_return which requires return address
          ;; Set temp6 = temp1 - 24          lda temp1          sec          sbc # 24          sta temp6
          lda temp1
          sec
          sbc # 24
          sta temp6

          lda temp1
          sec
          sbc # 24
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank5 in bank 4
          ;; Return address: ENCODED with caller bank 15 ($f0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank5-1)) & $0f) | $f0  ;;; Encode bank 15 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank5 hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank5-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank5 hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank5 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank5-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank5 hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank5 lo] [SP+0: SetPlayerCharacterArtBank5 hi (raw)]
          lda # <(SetPlayerCharacterArtBank5-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank5 hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank5 lo] [SP+1: SetPlayerCharacterArtBank5 hi (raw)] [SP+0: SetPlayerCharacterArtBank5 lo]
          ldx # 4
          jmp BS_jsr
AfterSetPlayerCharacterArtBank5:

          jmp BS_return

.pend

