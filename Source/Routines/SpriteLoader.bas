          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          const CPUSprite_length = 16
          const NoSprite_length = 16

          rem Player color tables for indexed lookup
          data PlayerColors12
          ColIndigo(12), ColRed(12), ColYellow(12), ColTurquoise(12)
          end

          data PlayerColors6
          ColIndigo(6), ColRed(6), ColYellow(6), ColTurquoise(6)
          end

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
          asm
; Validate character index
; Inline ValidateCharacterIndex
; Check if character index is within valid range
end
          if currentCharacter > MaxCharacter then ValidateInvalidCharacterInline
          asm
;   (0-MaxCharacter for current implementation)
end
          let temp5 = 1
          goto ValidateCharacterDoneInline
ValidateInvalidCharacterInline
          let temp5 = 0
ValidateCharacterDoneInline
          if !temp5 then goto LoadSpecialSprite
          asm
; tail call
end

          asm
; Check if character is special placeholder
end
          if currentCharacter = 255 then temp6 = SpriteNo : goto LoadSpecialSprite
          asm
; tail call
; NoCharacter = 255
end

          if currentCharacter = 254 then temp6 = SpriteCPU : goto LoadSpecialSprite
          asm
; tail call
; CPUCharacter = 254
end

          if currentCharacter = 253 then temp6 = SpriteQuestionMark : goto LoadSpecialSprite
          asm
; tail call
; RandomCharacter = 253
end

          asm
; Use character art location system for sprite loading
end
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
end

          asm
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

CopySpecialSpriteToPlayer
          rem Generic function to copy special sprite data to player buffer
          rem Input: temp3 = player number (0-3)
          rem        temp4 = sprite type (0=QuestionMark, 1=CPU, 2=No)
          rem Output: Sprite data copied to appropriate player buffer
          rem         Player height set to 16

          rem Calculate buffer offset: player * 16
          temp5 = temp3 * 16

          if temp4 = 0 then goto CopyQuestionMark
          if temp4 = 1 then goto CopyCPU
          goto CopyNo

CopyQuestionMark
          asm
            ldy #15
.CopyQuestionLoop:
            lda QuestionMarkSprite,y
            sta PlayerFrameBuffer_W,y
            dey
            bpl .CopyQuestionLoop
end
          goto SetPlayerHeight

CopyCPU
          asm
            ldy #15
.CopyCPULoop:
            lda CPUSprite,y
            sta PlayerFrameBuffer_W,y
            dey
            bpl .CopyCPULoop
end
          goto SetPlayerHeight

CopyNo
          rem will never be player 1
          if temp3 = 1 then goto CopyNoP1
          if temp3 = 2 then goto CopyNoP2
          goto CopyNoP3

CopyNoP1
          asm
            ldy #15
.CopyNoP1Loop:
            lda NoSprite,y
            sta PlayerFrameBuffer_W+16,y
            dey
            bpl .CopyNoP1Loop
end
          goto SetPlayerHeight

CopyNoP2
          asm
            ldy #15
.CopyNoP2Loop:
            lda NoSprite,y
            sta PlayerFrameBuffer_W+32,y
            dey
            bpl .CopyNoP2Loop
end
          goto SetPlayerHeight

CopyNoP3
          asm
            ldy #15
.CopyNoP3Loop:
            lda NoSprite,y
            sta PlayerFrameBuffer_W+48,y
            dey
            bpl .CopyNoP3Loop
end
          goto SetPlayerHeight

SetPlayerHeight
          if temp3 = 0 then player0height = 16
          if temp3 = 1 then player1height = 16
          if temp3 = 2 then player2height = 16
          if temp3 = 3 then player3height = 16
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
          let temp4 = 0  ; QuestionMark
          goto CopySpecialSpriteToPlayer

P1Load
          rem P1: QuestionMark/CPU/No
          let temp4 = temp6  ; temp6 = 0,1,2 directly maps to sprite types
          goto CopySpecialSpriteToPlayer

P2Load
          rem P2: QuestionMark/No
          if temp6 = 2 then let temp4 = 2 : goto CopySpecialSpriteToPlayer  ; No
          let temp4 = 0 : goto CopySpecialSpriteToPlayer                    ; QuestionMark

P3Load
          rem P3: QuestionMark/No
          if temp6 = 2 then let temp4 = 2 : goto CopySpecialSpriteToPlayer  ; No
          let temp4 = 0 : goto CopySpecialSpriteToPlayer                    ; QuestionMark

P5Load
          rem P5: Direct ROM pointer to QuestionMark
          asm
            lda #<QuestionMarkSprite
            sta player5pointer
            lda #>QuestionMarkSprite
            sta player5pointer+1
end
          player5height = 16
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
          goto LoadPlayerSpriteDispatch
          
LoadPlayerSpriteDispatch
          asm
; Load player sprite via bank10 art system
; Input: currentCharacter, temp2=frame, temp3=action, temp4=player
; Output: Sprite loaded via LocateCharacterArt (bank10)
end
          asm
; Call character art location system (in bank14)
; LocateCharacterArt expects: temp1=char, temp2=frame,
;   temp3=action, temp4=player
; Set temp1 from currentCharacter (already set from
; playerCharacter[currentPlayer])
end
          let temp1 = currentCharacter
          gosub LocateCharacterArt bank10
          return

LoadCharacterColors
          asm
; Load character color based on TV standard and hurt state
; Input: temp1=char, temp2=hurt, temp3=player
; Output: Sets COLUP0-3 based on TV standard (char colors on NTSC/PAL, player colors on SECAM)
;
; Constraints: Must be colocated with NormalColor,
;              PlayerIndexColors, PlayerIndexColorsDim,
;              HurtColor, SetColor (all called via goto)
; WARNING: temp6 is mutated during execution. Do not use
; temp6
; after calling this subroutine.
end
          if temp2 then goto HurtColor
          asm
; Highest priority: hurt state
end

NormalColor
          asm
; Normal color dispatch - character colors (NTSC/PAL) or player colors (SECAM)
end
#ifdef TV_SECAM
          PlayerIndexColors
#else
          asm
; NTSC/PAL: Use character-specific colors
end
#ifdef TV_NTSC
          let temp6 = CharacterColorsNTSC[temp1]
#endif
#ifdef TV_PAL
          let temp6 = CharacterColorsPAL[temp1]
#endif
#endif
          goto SetColor

PlayerIndexColors
          asm
; Bright player colors (luminance 12) - table lookup
; P1=Indigo, P2=Red, P3=Yellow, P4=Turquoise
end
          let temp6 = PlayerColors12[temp3]
          goto SetColor

PlayerIndexColorsDim
          asm
; Dimmed player colors (luminance 6) - table lookup
; P1=Indigo, P2=Red, P3=Yellow, P4=Turquoise
end
          let temp6 = PlayerColors6[temp3]
          goto SetColor

HurtColor
          asm
; Hurt state colors - magenta (SECAM) or dimmed player colors (NTSC/PAL)
end
#ifdef TV_SECAM
          let temp6 = ColMagenta(14)
          goto SetColor
#else
          let temp6 = PlayerColors6[temp3]
          goto SetColor
#endif

SetColor
          asm
; Set player color register based on player number
; Input: temp6=color, temp3=player
; Output: Sets COLUP0-3 appropriately
end
          if temp3 = 0 then COLUP0 = temp6 : goto SetColorDone
          if temp3 = 1 then _COLUP1 = temp6 : goto SetColorDone
          if temp3 = 2 then COLUP2 = temp6 : goto SetColorDone
          COLUP3 = temp6
SetColorDone
          return
