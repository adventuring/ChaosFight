          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Special sprite lengths no longer needed (font-driven)

          rem Player color tables moved to Source/Data/PlayerColors.bas

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
          asm
LoadCharacterSprite
end
          rem Load character sprite data - calls LocateCharacterArt (bank10)
          rem Input: currentCharacter (global), currentPlayer (global)
          rem        temp2 = animation frame (0-7), temp3 = animation action (0-15)
          rem Output: Sprite loaded via bank10 routines
          rem Inputs are trusted in internal context; skip range validation

          rem Handle special sprite cases first
          if currentCharacter = NoCharacter then let temp3 = currentPlayer : let temp4 = SpriteNo : gosub CopyGlyphToPlayer bank16 : return

          if currentCharacter = CPUCharacter then let temp3 = currentPlayer : let temp4 = SpriteCPU : gosub CopyGlyphToPlayer bank16 : return

          if currentCharacter = RandomCharacter then let temp3 = currentPlayer : let temp4 = SpriteQuestionMark : gosub CopyGlyphToPlayer bank16 : return

          rem Normal character sprite loading
          let temp4 = currentPlayer
          let temp1 = currentCharacter
          gosub LocateCharacterArt bank10
          return

LoadPlayerSprite
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
; Output: Sprite data loaded via LocateCharacterArt (bank10)
;
; Mutates: currentCharacter (global), temp1 (passed to
; LocateCharacterArt)
;
; Called Routines: LocateCharacterArt (bank10) - see
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
          rem Inline dispatch to save size (same-bank)
          let temp1 = currentCharacter
          gosub LocateCharacterArt bank10
          return

LoadPlayerSpriteDispatch
          rem removed (was a small shim); callers now use inline block above
          rem (label kept only if referenced by generated code)
          return

