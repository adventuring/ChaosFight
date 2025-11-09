          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          const CPUSprite_length = 16
          const NoSprite_length = 16

          asm
; MULTI-BANK SPRITE LOADING SYSTEM
;
; Loads character sprite data and colors from multiple banks
; Supports up to 32 characters (0-31) across 4 banks
; Current implementation: NumCharacters characters
;   (0-MaxCharacter) in 2 banks
; Special sprites: QuestionMark, CPU, No for special
;   selections.
;
;
; MULTI-BANK SPRITE LOADING FUNCTIONS
          end

          asm
; Loads sprites from appropriate bank based on character
;   index
;
; Handles special sprites (QuestionMark, CPU, No) for
;   placeholders
;
;
; Solid Player Color Tables
; Solid color tables for P1-P4 normal and hurt states
; P1=Indigo, P2=Red, P3=Yellow, P4=Turquoise (SECAM maps to
;   Green)
          end

LoadCharacterSprite
          asm
; SPRITE LOADING FUNCTIONS
; Load sprite data for a character based on character index
;
; Input: currentCharacter (global) = character index (0-31)
;        temp2 = animation frame (0-7)
;        temp3 = player number (0-3), may be in temp4
;        instead
;        MaxCharacter (constant) = maximum valid character
;        index
;
; Output: Sprite data loaded into appropriate player
; register
;         via LocateCharacterArt (bank10)
;
; Mutates: temp1, temp2, temp3, temp4 (passed to
; LocateCharacterArt)
;
; Called Routines: LocateCharacterArt (bank10) accesses:
;   - temp1, temp2, temp3, temp4, temp5, temp6
;   - Sets player sprite pointers via
;   SetPlayerCharacterArtBankX
;   - Modifies player0-3pointerlo/hi, player0-3height
;
; Constraints: Must be colocated with LoadSpecialSprite
; (called via goto)
;              Must be in same file as special sprite
;              loaders
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
          temp5 = 1
          goto ValidateCharacterDoneInline
ValidateInvalidCharacterInline
          temp5 = 0
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
          temp3 = 0
          asm
; action (0=idle)
; animation action/sequence 0 = idle
; playerNumberAlt already has player number from caller
          end
          temp1 = currentCharacter
          asm
; Set temp variables for cross-bank call
          end
          gosub LocateCharacterArt bank10
          return

LoadSpecialSprite
          asm
;
; Load Special Sprite
; Loads special placeholder sprites (QuestionMark, CPU, No)
;
; Input: temp6 = sprite index (SpriteQuestionMark=0,
;   SpriteCPU=1, SpriteNo=2)
;        temp3 = player number (0-3)
;
; Output: Appropriate player sprite pointer set to special
;   sprite data
;         player0-3height set to 16
;         SCRAM PlayerFrameBuffer_W[0-63] written (sprite data
;         copied to RAM)
;
; Mutates: temp6 (read only), temp3 (read only)
;           PlayerFrameBuffer_W[0-15], [16-31], [32-47],
;           [48-63] (SCRAM)
;           player0height, player1height, player2height,
;           player3height
;
; Called Routines: None (uses inline assembly to copy sprite
; data)
;
; Constraints: Must be colocated with LoadCharacterSprite
; (called from it)
;              Must be in same file as QuestionMark/CPU/No
;              sprite loaders
; Depends on QuestionMarkSprite, CPUSprite, NoSprite data
          end
          if !temp6 then goto LoadQuestionMarkSprite
          asm
; Set sprite pointer based on sprite index
          end
          if temp6 = 1 then LoadCPUSprite
          if temp6 = 2 then goto LoadNoSprite
          goto LoadQuestionMarkSprite
          asm
; Invalid sprite index, default to question mark
          end
          
LoadQuestionMarkSprite
          asm
; Set pointer to QuestionMarkSprite data
;
; Input: temp3 = player number (0-3)
;
; Output: Dispatches to player-specific loader
;
; Mutates: None (dispatcher only)
;
; Called Routines: None (dispatcher only)
;
; Constraints: Must be colocated with
; LoadQuestionMarkSpriteP0-P3
          end
          if !temp3 then LoadQuestionMarkSpriteP0
          asm
; Use skip-over pattern to avoid complex compound statements
          end
          if temp3 = 1 then LoadQuestionMarkSpriteP1
          if temp3 = 2 then LoadQuestionMarkSpriteP2
          goto LoadQuestionMarkSpriteP3
          
LoadQuestionMarkSpriteP0
          asm
          ; Copy QuestionMarkSprite data from ROM to RAM buffer
          ;
          ; Input: temp3 = player number (0, read but not used in this
          ; function)
          ;        QuestionMarkSprite (ROM data) = source sprite data
          ;
          ; Output: PlayerFrameBuffer_W[0-15] (SCRAM) = sprite data copied
          ;         player0height = 16
          ;
          ; Mutates: PlayerFrameBuffer_W[0-15] (SCRAM write port), player0height
          ;
          ; Called Routines: None (uses inline assembly)
          ;
          ; Constraints: Must be colocated with LoadQuestionMarkSprite
          ;              Depends on QuestionMarkSprite ROM data
          ;              Depends on InitializeSpritePointers setting
          ;              pointers
          ; Copy QuestionMarkSprite data from ROM to RAM buffer
          ; (PlayerFrameBuffer_W[0-15])
          ; Pointers already initialized to RAM addresses by
          ; InitializeSpritePointers
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta PlayerFrameBuffer_W,y
            dey
            bpl .CopyLoop
end
          player0height = 16
          return
          
LoadQuestionMarkSpriteP1
          asm
; Copy QuestionMarkSprite data from ROM to RAM buffer
; (PlayerFrameBuffer_W[16-31])
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta PlayerFrameBuffer_W+16,y
            dey
            bpl .CopyLoop
end
          player1height = 16
          return
          
LoadQuestionMarkSpriteP2
          rem Copy QuestionMarkSprite data from ROM to RAM buffer
          rem (PlayerFrameBuffer_W[32-47])
          asm
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta PlayerFrameBuffer_W+32,y
            dey
            bpl .CopyLoop
end
          player2height = 16
          return
          
LoadQuestionMarkSpriteP3
          rem Copy QuestionMarkSprite data from ROM to RAM buffer
          rem (PlayerFrameBuffer_W[48-63])
          asm
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta PlayerFrameBuffer_W+48,y
            dey
            bpl .CopyLoop
end
          player3height = 16
          return
          
LoadCPUSprite
          asm
; Set pointer to CPUSprite data
;
; Input: temp3 = player number (0-3)
;
; Output: Dispatches to player-specific loader
;
; Mutates: None (dispatcher only)
;
; Called Routines: None (dispatcher only)
;
; Constraints: Must be colocated with LoadCPUSpriteP0-P3
          end
          if !temp3 then LoadCPUSpriteP0
          asm
; Use skip-over pattern to avoid complex compound statements
          end
          if temp3 = 1 then LoadCPUSpriteP1
          if temp3 = 2 then LoadCPUSpriteP2
          goto LoadCPUSpriteP3
          
LoadCPUSpriteP0
          asm
          ; rem Copy CPUSprite data from ROM to RAM buffer
          ; rem
          ; rem Input: temp3 = player number (0, read but not used in this
          ; rem function)
          ; rem        CPUSprite (ROM data) = source sprite data
          ; rem
          ; rem Output: PlayerFrameBuffer_W[0-15] (SCRAM) = sprite data copied
          ; rem         player0height = 16
          ; rem
          ; rem Mutates: PlayerFrameBuffer_W[0-15] (SCRAM write port), player0height
          ; rem
          ; rem Called Routines: None (uses inline assembly)
          ; rem
          ; rem Constraints: Must be colocated with LoadCPUSprite
          ; rem              Depends on CPUSprite ROM data
          ; rem Copy CPUSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[0-15])
          ; rem Pointers already initialized to RAM addresses by
          ; rem InitializeSpritePointers
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta PlayerFrameBuffer_W,y
            dey
            bpl .CopyLoop
end
          player0height = 16
          return
          
LoadCPUSpriteP1
          rem Copy CPUSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[16-31])
          asm
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta PlayerFrameBuffer_W+16,y
            dey
            bpl .CopyLoop
end
          player1height = 16
          return
          
LoadCPUSpriteP2
          rem Copy CPUSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[32-47])
          asm
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta PlayerFrameBuffer_W+32,y
            dey
            bpl .CopyLoop
end
          player2height = 16
          return
          
LoadCPUSpriteP3
          rem Copy CPUSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[48-63])
          asm
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta PlayerFrameBuffer_W+48,y
            dey
            bpl .CopyLoop
end
          player3height = 16
          return
          
LoadNoSprite
          asm
; Set pointer to NoSprite data
;
; Input: temp3 = player number (0-3)
;
; Output: Dispatches to player-specific loader
;
; Mutates: None (dispatcher only)
;
; Called Routines: None (dispatcher only)
          end
          asm
;
; Constraints: Must be colocated with LoadNoSpriteP0-P3
          end
          if !temp3 then LoadNoSpriteP0
          asm
; Use skip-over pattern to avoid complex compound statements
          end
          if temp3 = 1 then LoadNoSpriteP1
          if temp3 = 2 then LoadNoSpriteP2
          goto LoadNoSpriteP3
          
LoadNoSpriteP0
          asm
          ; rem Copy NoSprite data from ROM to RAM buffer
          ; rem
          ; rem Input: temp3 = player number (0, read but not used in this
          ; rem function)
          ; rem        NoSprite (ROM data) = source sprite data
          ; rem
          ; rem Output: PlayerFrameBuffer_W[0-15] (SCRAM) = sprite data copied
          ; rem         player0height = 16
          ; rem
          ; rem Mutates: PlayerFrameBuffer_W[0-15] (SCRAM write port), player0height
          ; rem
          ; rem Called Routines: None (uses inline assembly)
          ; rem
          ; rem Constraints: Must be colocated with LoadNoSprite
          ; rem              Depends on NoSprite ROM data
          ; rem Copy NoSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[0-15])
          ; rem Pointers already initialized to RAM addresses by
          ; rem InitializeSpritePointers
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta PlayerFrameBuffer_W,y
            dey
            bpl .CopyLoop
end
          player0height = 16
          return
          
LoadNoSpriteP1
          rem Copy NoSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[16-31])
          asm
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta PlayerFrameBuffer_W+16,y
            dey
            bpl .CopyLoop
end
          player1height = 16
          return
          
LoadNoSpriteP2
          rem Copy NoSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[32-47])
          asm
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta PlayerFrameBuffer_W+32,y
            dey
            bpl .CopyLoop
end
          player2height = 16
          return
          
LoadNoSpriteP3
          rem Copy NoSprite data from ROM to RAM buffer (PlayerFrameBuffer_W[48-63])
          asm
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta PlayerFrameBuffer_W+48,y
            dey
            bpl .CopyLoop
end
          player3height = 16
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
; currentCharacter = character index (global variable),
; animationFrame =
;   frame (10fps counter), animationAction = action,
;   playerNumber = player
;
; Input: currentCharacter (global) = character index
; (already set)
;        temp2 = animation frame (0-7)
;        temp3 = animation action (0-15)
;        temp4 = player number (0-3)
;
; Output: Sprite data loaded via LocateCharacterArt (bank10)
;
; Mutates: temp1 (set from currentCharacter, passed to
; LocateCharacterArt)
;
; Called Routines: LocateCharacterArt (bank10) - see
; LoadCharacterSprite
;
; Constraints: Must be colocated with LoadPlayerSprite
; (called from it)
          end
          asm
; Call character art location system (in bank14)
; LocateCharacterArt expects: temp1=char, temp2=frame,
;   temp3=action, temp4=player
; Set temp1 from currentCharacter (already set from
; playerCharacter[currentPlayer])
          end
          temp1 = currentCharacter
          gosub LocateCharacterArt bank10
          return

LoadPlayer0Sprite
          asm
;
; LOAD PLAYER SPRITES (legacy Player-specific Functions)
; Load sprite data into specific player registers
; These functions contain the actual player graphics
;   commands
;
; Use art location system for player 0 sprite loading
;
; Input: currentCharacter (global) = character index (must
; be set)
;        temp2 = animation frame (0-7, must be set by
;        caller)
;
; Output: Sprite data loaded via LoadCharacterSprite
;
; Mutates: temp3 (set to 0, passed to LoadCharacterSprite)
;
; Called Routines: LoadCharacterSprite - see its
; documentation
;
; Constraints: Must be colocated with LoadCharacterSprite
; (tail call)
;              Only reachable via gosub/goto (could be own
;              file)
; temp1 = character index, temp2 = animation frame already
;   set
          end
          temp3 = 0
          asm
; playerNumber = player number (0)
; Use LoadCharacterSprite which handles LocateCharacterArt
          end
          goto LoadCharacterSprite
          asm
; tail call
          end

LoadPlayer1Sprite
          asm
; Use art location system for player 1 sprite loading
;
; Input: currentCharacter (global) = character index (must
; be set)
;        temp2 = animation frame (0-7, must be set by
;        caller)
;
; Output: Sprite data loaded via LoadCharacterSprite
;
; Mutates: temp3 (set to 1, passed to LoadCharacterSprite)
;
; Called Routines: LoadCharacterSprite - see its
; documentation
;
; Constraints: Must be colocated with LoadCharacterSprite
; (tail call)
;              Only reachable via gosub/goto (could be own
;              file)
; temp1 = character index, temp2 = animation frame already
;   set
          end
          temp3 = 1
          asm
; playerNumber = player number (1)
; Use LoadCharacterSprite which handles LocateCharacterArt
          end
          goto LoadCharacterSprite
          asm
; tail call
          end
          
LoadPlayer2Sprite
          asm
; Use art location system for player 2 sprite loading
;
; Input: currentCharacter (global) = character index (must
; be set)
;        temp2 = animation frame (0-7, must be set by
;        caller)
;
; Output: Sprite data loaded via LoadCharacterSprite
;
; Mutates: temp3 (set to 2, passed to LoadCharacterSprite)
;
; Called Routines: LoadCharacterSprite - see its
; documentation
;
; Constraints: Must be colocated with LoadCharacterSprite
; (tail call)
;              Only reachable via gosub/goto (could be own
;              file)
; temp1 = character index, temp2 = animation frame already
;   set
          end
          temp3 = 2
          asm
; playerNumber = player number (2)
; Use LoadCharacterSprite which handles LocateCharacterArt
          end
          goto LoadCharacterSprite
          asm
; tail call
          end
          
LoadPlayer3Sprite
          asm
; Use art location system for player 3 sprite loading
;
; Input: currentCharacter (global) = character index (must
; be set)
;        temp2 = animation frame (0-7, must be set by
;        caller)
;
; Output: Sprite data loaded via LoadCharacterSprite
;
; Mutates: temp3 (set to 3, passed to LoadCharacterSprite)
;
; Called Routines: LoadCharacterSprite - see its
; documentation
;
; Constraints: Must be colocated with LoadCharacterSprite
; (tail call)
;              Only reachable via gosub/goto (could be own
;              file)
; temp1 = character index, temp2 = animation frame already
;   set
          end
          temp3 = 3
          asm
; playerNumber = player number (3)
; Use LoadCharacterSprite which handles LocateCharacterArt
          end
          goto LoadCharacterSprite
          asm
; tail call
          end




          rem Character color tables for NTSC
          data CharacterColorsNTSC
            $0E, $1C, $28, $44, $1A, $86, $1C, $2A, $3A, $C6, $16, $46, $2C, $66, $36, $56
          end

          rem Character color tables for PAL (adjusted for PAL color encoding)
          data CharacterColorsPAL
            $0E, $2C, $38, $54, $2A, $96, $2C, $3A, $4A, $D6, $26, $56, $3C, $76, $46, $66
          end

LoadCharacterColors
          asm
; Load character color based on TV standard, B&W, hurt, and
;   flashing states
;
; Input: temp1 = character index (0-15)
;        temp2 = hurt state (0/1)
;        temp3 = player number (0-3)
;        temp4 = flashing state (0/1)
;        temp5 = flashing mode (0=per-line, 1=player-index)
;        frame (global) = frame counter for flashing
;        systemFlags (global) = system flags including B&W
;        override
;
; Output: Appropriate COLUP0/COLUP1/COLUP2/COLUP3 updated
; Note: Colors are per-character on NTSC/PAL, per-player on B&W/SECAM
;
; Mutates: temp6 (color calculation, internal use)
;           COLUP0, COLUP1, COLUP2, COLUP3 (TIA registers)
;
; Called Routines: None (all logic inline)
;
; Constraints: Must be colocated with NormalColor,
; FlashingColor,
;              PerLineFlashing, PlayerIndexColors,
;              PlayerIndexColorsDim,
;              HurtColor, SetColor (all called via goto)
; WARNING: temp6 is mutated during execution. Do not use
; temp6
; after calling this subroutine.
          end
          if temp2 then goto HurtColor
          asm
; Highest priority: hurt state
          end

          if temp4 then FlashingColor
          asm
; Next priority: flashing state
          end

NormalColor
          asm
; Calculate normal (non-hurt, non-flashing) player color
;
; Input: temp3 = player number (0-3, from
; LoadCharacterColors)
;        systemFlags (global) = system flags including B&W
;        override
;
; Output: Dispatches to PlayerIndexColors
;
; Mutates: None (dispatcher only)
;
; Called Routines: None (dispatcher only)
;
; Constraints: Must be colocated with LoadCharacterColors
; Determine effective B&W override locally; if enabled, use
          end
          if (systemFlags & SystemFlagColorBWOverride)
#ifdef TV_SECAM
            PlayerIndexColors
#endif
            PlayerIndexColors
          asm
; NTSC/PAL: Use character-specific colors
          end
#ifdef TV_NTSC
          temp6 = CharacterColorsNTSC[temp1]
#endif
#ifdef TV_PAL
          temp6 = CharacterColorsPAL[temp1]
#endif
          goto SetColor

FlashingColor
          asm
; Flashing mode selection
;
; Input: temp5 = flashing mode (0=per-line, 1=player-index)
;        temp1 = character index (0-15)
;        temp3 = player number (0-3)
;        systemFlags (global) = B&W override flag
          end
          if temp5 = 0 then PerLineFlashing
          PlayerIndexColors
          
PerLineFlashing
          asm
; Frame-based flashing (not per-line - players use solid
;   colors)
;
; Input: frame (global) = frame counter for flashing
;        temp3 = player number (0-3, from
;        LoadCharacterColors)
;
; Output: Dispatches to PlayerIndexColorsDim or
; PlayerIndexColors
;
; Mutates: None (dispatcher only)
;
; Called Routines: None (dispatcher only)
;
; Constraints: Must be colocated with LoadCharacterColors
; Use alternating bright/dim player index colors by frame
          end
          if frame & 8 then PlayerIndexColors
          asm
; Use character color when frame bit 3 is clear
          end
#ifdef TV_NTSC
          temp6 = CharacterColorsNTSC[temp1]
#endif
#ifdef TV_PAL
          temp6 = CharacterColorsPAL[temp1]
#endif
          goto SetColor
          
PlayerIndexColors
          asm
; Calculate bright player index colors
;
; Input: temp3 = player number (0-3, from
; LoadCharacterColors)
;
; Output: temp6 = color value, dispatches to SetColor
;
; Mutates: temp6 (color value)
;
; Called Routines: None (dispatcher only)
; Constraints: Must be colocated with LoadCharacterColors, SetColor
; Solid player index colors (bright, luminance 12)
; Player 1=Indigo, Player 2=Red, Player 3=Yellow, Player
;   4=Turquoise (SECAM maps to Green)
          end
          if !temp3 then goto PlayerIndexColorsPlayer0
          if temp3 = 1 then goto PlayerIndexColorsPlayer1
          if temp3 = 2 then goto PlayerIndexColorsPlayer2
          goto PlayerIndexColorsPlayer3

PlayerIndexColorsPlayer0
          asm
; Player 1: Indigo (SECAM maps to Blue)
          end
          temp6 = ColIndigo(12)
          goto SetColor

PlayerIndexColorsPlayer1
          asm
; Player 2: Red
          end
          temp6 = ColRed(12)
          goto SetColor

PlayerIndexColorsPlayer2
          asm
; Player 3: Yellow (SECAM maps to Yellow)
          end
          temp6 = ColYellow(12)
          goto SetColor

PlayerIndexColorsPlayer3
          asm
; Player 4: Turquoise (SECAM maps to Green)
          end
          temp6 = ColTurquoise(12)
          goto SetColor

PlayerIndexColorsDim
          asm
; Dimmed player index colors
;
; Input: temp3 = player number (0-3, from
; LoadCharacterColors)
;
; Output: temp6 = dimmed color value, dispatches to SetColor
;
; Mutates: temp6 (color value)
;
; Called Routines: None (dispatcher only)
;
; Constraints: Must be colocated with LoadCharacterColors,
; SetColor
; Player 1=Indigo, Player 2=Red, Player 3=Yellow, Player
;   4=Turquoise (SECAM maps to Green, dimmed to luminance 6)
          end
          if !temp3 then goto PlayerIndexColorsDimPlayer0
          if temp3 = 1 then goto PlayerIndexColorsDimPlayer1
          if temp3 = 2 then goto PlayerIndexColorsDimPlayer2
          goto PlayerIndexColorsDimPlayer3

PlayerIndexColorsDimPlayer0
          asm
; Player 1: Indigo (dimmed)
          end
          temp6 = ColIndigo(6)
          goto SetColor

PlayerIndexColorsDimPlayer1
          asm
; Player 2: Red (dimmed)
          end
          temp6 = ColRed(6)
          goto SetColor

PlayerIndexColorsDimPlayer2
          asm
; Player 3: Yellow (dimmed)
          end
          temp6 = ColYellow(6)
          goto SetColor

PlayerIndexColorsDimPlayer3
          asm
; Player 4: Turquoise (dimmed)
          end
          temp6 = ColTurquoise(6)
          goto SetColor

HurtColor
          asm
; Calculate hurt state player color
;
; Input: temp3 = player number (0-3, from
; LoadCharacterColors)
;
; Output: temp6 = hurt color value, dispatches to SetColor
;
; Mutates: temp6 (color value)
;
; Called Routines: None (dispatcher only)
;
; Constraints: Must be colocated with LoadCharacterColors,
; SetColor
          end
#ifdef TV_SECAM
          temp6 = ColMagenta(10)
          goto SetColor
#else
          asm
; Dimmed version of normal color
; First get the normal color, then dim it
          end
          if (systemFlags & SystemFlagColorBWOverride) then PlayerIndexColorsDim
          asm
; NTSC/PAL: dim the character color
          end
#ifdef TV_NTSC
          temp6 = CharacterColorsNTSC[temp1] - 6
#endif
#ifdef TV_PAL
          temp6 = CharacterColorsPAL[temp1] - 6
#endif
          if temp6 < 0 then temp6 = 0
          goto SetColor
#endif

SetColor
          asm
; Set color based on player index (multisprite kernel
;   supports COLUP2/COLUP3)
;
; Input: temp6 = color value (from previous color
; calculation)
;        temp3 = player number (0-3, from
;        LoadCharacterColors)
;
; Output: COLUP0, _COLUP1, COLUP2, or COLUP3 updated
;
; Mutates: COLUP0, _COLUP1, COLUP2, COLUP3 (TIA registers)
;
; Called Routines: None
;
; Constraints: Must be colocated with LoadCharacterColors
; Use temp6 directly instead of alias to avoid symbol
; conflict
; temp6 already contains the color from
;   previous code paths
          end
          if temp3 = 0 then COLUP0 = temp6 : goto SetColorDone
          if temp3 = 1 then _COLUP1 = temp6 : goto SetColorDone
          if temp3 = 2 then COLUP2 = temp6 : goto SetColorDone
          COLUP3 = temp6
SetColorDone
          return
