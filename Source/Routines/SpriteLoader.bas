          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          asm
; SUPPORTED SPRITE CONFIGURATIONS:
; P0 = character | ?
; P1 = character | CPU | No | ?
; P2 = character | No | ?
; P3 = character | No | ?
; P4 = digit | blank (arena select only)
; P5 = digit | ? (arena select only)
;
; Multi-bank sprite loading system - supports 32 characters across 4 banks
end

LoadCharacterSprite
          rem Returns: Far (return otherbank)
          asm
LoadCharacterSprite
end
          rem Load character sprite data - calls LocateCharacterArt (bank9)
          rem Returns: Far (return otherbank)
          rem Input: currentCharacter (global), currentPlayer (global)
          rem        temp2 = animation frame (0-7), temp3 = animation action (0-15)
          rem Output: Sprite loaded via bank9 routines
          rem Inputs are trusted in internal context; skip range validation
          rem CRITICAL: Only run during game mode - publisher prelude has no characters
          rem This prevents stack overflow when called during publisher prelude (gameMode = 0)
          rem Special sprite cases (NoCharacter, CPUCharacter, RandomCharacter) are safe to handle
          rem but normal character loading must be guarded
          rem Handle special sprite cases first (these are safe)
          if currentCharacter = NoCharacter then let temp3 = currentPlayer : let temp4 = SpriteNo : gosub CopyGlyphToPlayer bank16 : return otherbank

          if currentCharacter = CPUCharacter then let temp3 = currentPlayer : let temp4 = SpriteCPU : gosub CopyGlyphToPlayer bank16 : return otherbank

          if currentCharacter = RandomCharacter then let temp3 = currentPlayer : let temp4 = SpriteQuestionMark : gosub CopyGlyphToPlayer bank16 : return otherbank

          rem Normal character sprite loading
          let temp4 = currentPlayer
          let temp1 = currentCharacter
          gosub LocateCharacterArt bank9

          return otherbank

LoadPlayerSprite
          rem Returns: Far (return otherbank)
          asm
LoadPlayerSprite
end
          asm
;
; LOAD PLAYER SPRITE (generic Dispatcher)
; Load sprite data for any player using character art system
;
; Input: currentPlayer (global) = player index (0-3)
;        playerCharacter[] (global array) = character indices per
;        player
;        temp2 = animation frame (0-7) from sprite 10fps
;        counter
;        temp3 = animation action (0-15) from
;        currentAnimationSeq
;        temp4 = player number (0-3)
; Note: Frame is relative to sprite own 10fps counter, NOT
;   global frame counter
;
; Output: Sprite data loaded via LocateCharacterArt (bank9)
;
; Mutates: currentCharacter (global), temp1 (passed to
; LocateCharacterArt)
;
; Called Routines: LocateCharacterArt (bank9) - see
; LoadCharacterSprite
;
; Constraints: Must be colocated with
; LoadPlayerSpriteDispatch (called via goto)
end
          asm
; Get character index for this player from playerCharacter array
; Use currentPlayer global variable (set by caller)
end
          let currentCharacter = playerCharacter[currentPlayer]
          asm
; Set currentCharacter from playerCharacter[currentPlayer]
end
          rem CRITICAL: Guard against invalid characters - prevent calling bank 2 when no characters on screen
          rem Handle special sprite cases first (these are safe and don’t need bank dispatch)
          if currentCharacter = NoCharacter then let temp3 = currentPlayer : let temp4 = SpriteNo : gosub CopyGlyphToPlayer bank16 : return otherbank
          if currentCharacter = CPUCharacter then let temp3 = currentPlayer : let temp4 = SpriteCPU : gosub CopyGlyphToPlayer bank16 : return otherbank
          if currentCharacter = RandomCharacter then let temp3 = currentPlayer : let temp4 = SpriteQuestionMark : gosub CopyGlyphToPlayer bank16 : return otherbank
          rem Inline LocateCharacterArt to reduce call chain depth (stack overflow fix)
          rem Returns: Far (return otherbank)
          rem CRITICAL: Inlined to reduce stack depth from 19 to 15 bytes (within 16-byte limit)
          rem Original: gosub LocateCharacterArt bank9 (4 bytes saved by inlining)
          let temp1 = currentCharacter
          rem Save original character index in temp6 for bank-relative calculation
          let temp6 = temp1
          rem Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          rem Use goto instead of gosub to avoid stack push
          if temp1 < 8 then goto LoadPlayerSprite_Bank2Dispatch
          if temp1 < 16 then goto LoadPlayerSprite_Bank3Dispatch
          if temp1 < 24 then goto LoadPlayerSprite_Bank4Dispatch
          goto LoadPlayerSprite_Bank5Dispatch

LoadPlayerSprite_Bank2Dispatch
          rem Bank 2: Characters 0-7 (bank-relative 0-7)
          rem CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank2 uses BS_return which requires return address
          let temp6 = temp1
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank2 bank2
          return otherbank

LoadPlayerSprite_Bank3Dispatch
          rem Bank 3: Characters 8-15 (bank-relative 0-7)
          rem CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank3 uses BS_return which requires return address
          let temp6 = temp1 - 8
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank3 bank3
          return otherbank

LoadPlayerSprite_Bank4Dispatch
          rem Bank 4: Characters 16-23 (bank-relative 0-7)
          rem CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank4 uses BS_return which requires return address
          let temp6 = temp1 - 16
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank4 bank4
          return otherbank

LoadPlayerSprite_Bank5Dispatch
          rem Bank 5: Characters 24-31 (bank-relative 0-7)
          rem CRITICAL: Must use gosub, not goto - SetPlayerCharacterArtBank5 uses BS_return which requires return address
          let temp6 = temp1 - 24
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank5 bank5
          return otherbank
