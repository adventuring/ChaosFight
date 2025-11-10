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
; Load character sprite data - calls LocateCharacterArt (bank10)
; Input: currentCharacter, temp2=frame, temp3=player
; Output: Sprite loaded via bank10 routines
end
          rem Inputs are trusted in internal context; skip range validation

          asm
; Check if character is special placeholder
end
          if currentCharacter = NoCharacter then temp6 = SpriteNo : gosub LoadSpecialSprite : return

          if currentCharacter = 254 then temp6 = SpriteCPU : gosub LoadSpecialSprite : return
          asm
; tail call
; CPUCharacter = 254
end

          if currentCharacter = RandomCharacter then temp6 = SpriteQuestionMark : gosub LoadSpecialSprite : return
          rem  Use character art location system for sprite loading
          asm
;
; Input: currentCharacter = character index (global
; variable), animationFrame =
;   animation frame
; playerNumber = player number OR playerNumberAlt = player
;   number (caller provides)
; Default to animation sequence 0 (idle) for character
;   select
; LocateCharacterArt expects: temp1=char, temp2=frame,
;   temp3=action, temp4=player
;
; Check if player number in temp3 or temp4
; If temp4 is not set (0 and caller might have used temp3),
end
          if !temp4 then temp4 = temp3
          asm
;   copy from temp3
;
; Move player number to temp4 and set temp3 to animation
end
          let temp3 = 0
          asm
; action (0=idle)
; animation action/sequence 0 = idle
; playerNumberAlt already has player number from caller
end
          let temp1 = currentCharacter
          asm
; Set temp variables for cross-bank call
end
          gosub LocateCharacterArt bank10
          return

CopyGlyphToPlayer
          rem Input: temp3 = player number (0-3)
          rem        temp4 = sprite type (0=QuestionMark, 1=CPU, 2=No)
          rem Output: Sprite data loaded from unified font
          if temp4 = 0 then temp1 = GlyphQuestionMark : goto _CopyFromFont
          if temp4 = 1 then temp1 = GlyphCPU : goto _CopyFromFont
          temp1 = GlyphNo
_CopyFromFont
          gosub SetPlayerGlyphFromFont bank16
          return

LoadSpecialSprite
          asm
; Load special sprites (QuestionMark/CPU/No) to RAM buffers
; Input: temp6=sprite type, temp3=player
; Output: Sprite copied to player buffer, height set to 16
end

          rem Dispatch based on player number
          on temp3 goto P0Load, P1Load, P2Load, P3Load, P5Load, P5Load

P0Load
          rem P0: Only QuestionMark
          let temp4 = 0  : goto CopyGlyphToPlayer

P1Load
          rem P1: QuestionMark/CPU/No
          let temp4 = temp6 : goto CopyGlyphToPlayer

P2Load
          rem P2: QuestionMark/No
          if temp6 = 2 then let temp4 = 2 : goto CopyGlyphToPlayer
          let temp4 = 0 : goto CopyGlyphToPlayer

P3Load
          rem P3: QuestionMark/No
          if temp6 = 2 then let temp4 = 2 : goto CopyGlyphToPlayer
          let temp4 = 0 : goto CopyGlyphToPlayer

P5Load
          rem P5: Point to font glyph for QuestionMark
          let temp1 = GlyphQuestionMark
          let temp3 = 5
          gosub SetPlayerGlyphFromFont bank16
          return
LoadPlayerSprite
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

LoadCharacterColors
          asm
; Load character color based on TV standard and hurt state
; Input: temp1=char, temp2=hurt, temp3=player
; Output: Sets COLUP0-3 based on TV standard (char colors on NTSC/PAL, player colors on SECAM)
; WARNING: temp6 is mutated during execution. Do not use temp6 after calling this subroutine.
end

          ; Determine color based on hurt state
          if temp2 = 0 then let temp6 = PlayerColors12[temp3] : goto SetColor

          ; Hurt state: magenta (SECAM) or dimmed player colors (NTSC/PAL)
#ifdef TV_SECAM
          let temp6 = ColMagenta(14)
#else
          let temp6 = PlayerColors6[temp3]
#endif

SetColor
          ; Set the appropriate color register
          if temp3 = 0 then COLUP0 = temp6 : return
          if temp3 = 1 then _COLUP1 = temp6 : return
          if temp3 = 2 then COLUP2 = temp6 : return
          COLUP3 = temp6
          return
