;;; ChaosFight - Source/Routines/SpriteLoader.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; TODO: ; SUPPORTED SPRITE CONFIGURATIONS:
          ;; TODO: ; P0 = character | ?
          ;; TODO: ; P1 = character | CPU | No | ?
          ;; TODO: ; P2 = character | No | ?
          ;; TODO: ; P3 = character | No | ?
          ;; TODO: ; P4 = digit | blank (arena select only)
          ;; TODO: ; P5 = digit | ? (arena select only)
          ;; TODO: ;
; Multi-bank sprite loading system - supports 32 characters across 4 banks


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
          lda # >(return_point1-1)
          pha
          lda # <(return_point1-1)
          pha
          lda # >(CopyGlyphToPlayer-1)
          pha
          lda # <(CopyGlyphToPlayer-1)
          pha
          ldx # 15
          jmp BS_jsr

return_point1:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 16
          lda # >(return_point2-1)
          pha
          lda # <(return_point2-1)
          pha
          lda # >(CopyGlyphToPlayer-1)
          pha
          lda # <(CopyGlyphToPlayer-1)
          pha
          ldx # 15
          jmp BS_jsr

return_point2:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 16
          lda # >(return_point3-1)
          pha
          lda # <(return_point3-1)
          pha
          lda # >(CopyGlyphToPlayer-1)
          pha
          lda # <(CopyGlyphToPlayer-1)
          pha
          ldx # 15
          jmp BS_jsr

return_point3:

          ;; Normal character sprite loading
          lda currentPlayer
          sta temp4
          lda currentCharacter
          sta temp1
          ;; Cross-bank call to LocateCharacterArt in bank 9
          lda # >(return_point4-1)
          pha
          lda # <(return_point4-1)
          pha
          lda # >(LocateCharacterArt-1)
          pha
          lda # <(LocateCharacterArt-1)
          pha
                    ldx # 8
          jmp BS_jsr
return_point:


          jsr BS_return

.pend

LoadPlayerSprite .proc
          ;; TODO: ;
          ;; TODO: ; LOAD PLAYER SPRITE (generic Dispatcher)
; Load sprite data for any player using character art system
          ;; TODO: ;
Input:

currentPlayer

;
playerCharacter[] (global array) = character indices per
;
player:
          ;; TODO: ;        temp2 = animation frame (0-7) from sprite 10fps
          ;; TODO: ;        counter
          ;; TODO: ;        temp3 = animation action (0-15) from
          ;; TODO: ;        currentAnimationSeq
;
temp4 = player number (0-3)
          ;; TODO: ; Note: Frame is relative to sprite own 10fps counter, NOT
          ;; TODO: ;   global frame counter
          ;; TODO: ;
          ;; TODO: ; Output: Sprite data loaded via LocateCharacterArt (bank9)
          ;; TODO: ;
          ;; TODO: ; Mutates: currentCharacter (global), temp1 (passed to
          ;; TODO: ; LocateCharacterArt)
          ;; TODO: ;
          ;; TODO: ; Called Routines: LocateCharacterArt (bank9) - see
          ;; TODO: ; LoadCharacterSprite
          ;; TODO: ;
          ;; TODO: ; Constraints: Must be colocated with
          ;; TODO: ; LoadPlayerSpriteDispatch (called via goto)
; Get character index for this player from playerCharacter array
          ;; TODO: ; Use currentPlayer global variable (set by caller)
          ;; let currentCharacter = playerCharacter[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
; Set currentCharacter from playerCharacter[currentPlayer]
          ;; CRITICAL: Guard against invalid characters - prevent calling bank 2 when no characters on screen
          ;; Handle special sprite cases first (these are safe and don’t need bank dispatch)
          ;; Cross-bank call to CopyGlyphToPlayer in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CopyGlyphToPlayer-1)
          pha
          lda # <(CopyGlyphToPlayer-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CopyGlyphToPlayer-1)
          pha
          lda # <(CopyGlyphToPlayer-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:

          ;; Cross-bank call to CopyGlyphToPlayer in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CopyGlyphToPlayer-1)
          pha
          lda # <(CopyGlyphToPlayer-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:

          ;; Inline LocateCharacterArt to reduce call chain depth (stack overflow fix)
          ;; Returns: Far (return otherbank)
          ;; CRITICAL: Inlined to reduce stack depth from 19 to 15 bytes (within 16-byte limit)
          ;; Original: gosub LocateCharacterArt bank9 (4 bytes saved by inlining)
          lda currentCharacter
          sta temp1
          ;; Save original character index in temp6 for bank-relative calculation
          lda temp1
          sta temp6
          ;; Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          ;; Use goto instead of gosub to avoid stack push
          ;; if temp1 < 8 then goto LoadPlayerSprite_Bank2Dispatch          lda temp1          cmp 8          bcs .skip_4485          jmp
          lda temp1
          cmp # 8
          bcs skip_7079
          goto_label:

          jmp goto_label
skip_7079:

          lda temp1
          cmp # 8
          bcs skip_3862
          jmp goto_label
skip_3862:

          
          ;; if temp1 < 16 then goto LoadPlayerSprite_Bank3Dispatch          lda temp1          cmp 16          bcs .skip_8460          jmp
          lda temp1
          cmp # 16
          bcs skip_1377
          jmp goto_label
skip_1377:

          lda temp1
          cmp # 16
          bcs skip_5784
          jmp goto_label
skip_5784:

          
          ;; if temp1 < 24 then goto LoadPlayerSprite_Bank4Dispatch          lda temp1          cmp 24          bcs .skip_2409          jmp
          lda temp1
          cmp # 24
          bcs skip_6013
          jmp goto_label
skip_6013:

          lda temp1
          cmp # 24
          bcs skip_466
          jmp goto_label
skip_466:

          
          jmp LoadPlayerSprite_Bank5Dispatch

LoadPlayerSprite_Bank2Dispatch
          ;; Bank 2: Characters 0-7 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank2 uses BS_return which requires return address
          lda temp1
          sta temp6
          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank2 in bank 2
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank2-1)
          pha
          lda # <(SetPlayerCharacterArtBank2-1)
          pha
                    ldx # 1
          jmp BS_jsr
return_point:

          jsr BS_return

LoadPlayerSprite_Bank3Dispatch
          ;; Bank 3: Characters 8-15 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank3 uses BS_return which requires return address
          ;; let temp6 = temp1 - 8          lda temp1          sec          sbc 8          sta temp6
          lda temp1
          sec
          sbc 8
          sta temp6

          lda temp1
          sec
          sbc 8
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank3 in bank 3
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank3-1)
          pha
          lda # <(SetPlayerCharacterArtBank3-1)
          pha
                    ldx # 2
          jmp BS_jsr
return_point:

          jsr BS_return

LoadPlayerSprite_Bank4Dispatch
          ;; Bank 4: Characters 16-23 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank4 uses BS_return which requires return address
          ;; let temp6 = temp1 - 16          lda temp1          sec          sbc 16          sta temp6
          lda temp1
          sec
          sbc 16
          sta temp6

          lda temp1
          sec
          sbc 16
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank4 in bank 4
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank4-1)
          pha
          lda # <(SetPlayerCharacterArtBank4-1)
          pha
                    ldx # 3
          jmp BS_jsr
return_point:

          jsr BS_return

LoadPlayerSprite_Bank5Dispatch
          ;; Bank 5: Characters 24-31 (bank-relative 0-7)
          ;; CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank5 uses BS_return which requires return address
          ;; let temp6 = temp1 - 24          lda temp1          sec          sbc 24          sta temp6
          lda temp1
          sec
          sbc 24
          sta temp6

          lda temp1
          sec
          sbc 24
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank5 in bank 5
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank5-1)
          pha
          lda # <(SetPlayerCharacterArtBank5-1)
          pha
                    ldx # 4
          jmp BS_jsr
return_point:

          jsr BS_return

.pend

