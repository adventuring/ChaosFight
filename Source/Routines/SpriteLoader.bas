          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.


          rem MULTI-BANK SPRITE LOADING SYSTEM

          rem Loads character sprite data and colors from multiple banks
          rem Supports up to 32 characters (0-31) across 4 banks
          rem Current implementation: NumCharacters characters
          rem   (0-MaxCharacter) in 2 banks
          rem Special sprites: QuestionMark, CPU, No for special
          rem   selections.


          rem MULTI-BANK SPRITE LOADING FUNCTIONS

          rem Loads sprites from appropriate bank based on character
          rem   index
          rem
          rem Handles special sprites (QuestionMark, CPU, No) for
          rem   placeholders


          rem Solid Player Color Tables
          rem Solid color tables for P1-P4 normal and hurt states
          rem P1=Indigo, P2=Red, P3=Yellow, P4=Turquoise (SECAM maps to
          rem   Green)

          rem Player Colors - Light versions for normal state
          data PlayerColorsLight
              ColIndigo(14), ColRed(14), ColYellow(14), ColTurquoise(14)
end

          rem Player Colors - Dark versions for hurt state
          data PlayerColorsDark
              ColIndigo(6), ColRed(6), ColYellow(6), ColTurquoise(6)
end

LoadCharacterSprite
          rem SPRITE LOADING FUNCTIONS
          rem Load sprite data for a character based on character index
          rem
          rem Input: currentCharacter (global) = character index (0-31)
          rem        temp2 = animation frame (0-7)
          rem        temp3 = player number (0-3), may be in temp4
          rem        instead
          rem        MaxCharacter (constant) = maximum valid character
          rem        index
          rem
          rem Output: Sprite data loaded into appropriate player
          rem register
          rem         via LocateCharacterArt (bank14)
          rem
          rem Mutates: temp1, temp2, temp3, temp4 (passed to
          rem LocateCharacterArt)
          rem
          rem Called Routines: LocateCharacterArt (bank14) accesses:
          rem   - temp1, temp2, temp3, temp4, temp5, temp6
          rem   - Sets player sprite pointers via
          rem   SetPlayerCharacterArtBankX
          rem   - Modifies player0-3pointerlo/hi, player0-3height
          rem
          rem Constraints: Must be colocated with LoadSpecialSprite
          rem (called via goto)
          rem              Must be in same file as special sprite
          rem              loaders
          dim LCS_animationFrame = temp2
          dim LCS_playerNumber = temp3
          dim LCS_animationAction = temp3
          dim LCS_playerNumberAlt = temp4
          dim LCS_isValid = temp5
          dim LCS_spriteIndex = temp6
          rem Validate character index
          dim VCI_isValid = temp5 : rem Inline ValidateCharacterIndex
          rem Check if character index is within valid range
          if currentCharacter > MaxCharacter then ValidateInvalidCharacterInline : rem   (0-MaxCharacter for current implementation)
          let VCI_isValid = 1
          goto ValidateCharacterDoneInline
ValidateInvalidCharacterInline
          let VCI_isValid = 0
ValidateCharacterDoneInline
          let LCS_isValid = VCI_isValid
          if !LCS_isValid then goto LoadSpecialSprite : rem tail call
          
          rem Check if character is special placeholder
          if currentCharacter = 255 then let LCS_spriteIndex = SpriteNo : goto LoadSpecialSprite : rem tail call
          rem NoCharacter = 255
          
          if currentCharacter = 254 then let LCS_spriteIndex = SpriteCPU : goto LoadSpecialSprite : rem tail call
          rem CPUCharacter = 254
          
          if currentCharacter = 253 then let LCS_spriteIndex = SpriteQuestionMark : goto LoadSpecialSprite : rem tail call
          rem RandomCharacter = 253
          
          rem Use character art location system for sprite loading
          rem
          rem Input: currentCharacter = character index (global
          rem variable), animationFrame =
          rem   animation frame
          rem playerNumber = player number OR playerNumberAlt = player
          rem   number (caller provides)
          rem Default to animation sequence 0 (idle) for character
          rem   select
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          rem   temp3=action, temp4=player
          
          rem Check if player number in temp3 or temp4
          rem If temp4 is not set (0 and caller might have used temp3),
          if !LCS_playerNumberAlt then let LCS_playerNumberAlt = LCS_playerNumber : rem   copy from temp3
          
          rem Move player number to temp4 and set temp3 to animation
          let LCS_animationAction = 0 : rem action (0=idle)
          rem animation action/sequence 0 = idle
          rem playerNumberAlt already has player number from caller
          let temp1 = currentCharacter : rem Set temp variables for cross-bank call
          let temp2 = LCS_animationFrame
          let temp3 = LCS_animationAction
          let temp4 = LCS_playerNumberAlt
          gosub LocateCharacterArt bank14
          return

LoadSpecialSprite
          rem
          rem Load Special Sprite
          rem Loads special placeholder sprites (QuestionMark, CPU, No)
          rem
          rem Input: temp6 = sprite index (SpriteQuestionMark=0,
          rem   SpriteCPU=1, SpriteNo=2)
          rem        temp3 = player number (0-3)
          rem
          rem Output: Appropriate player sprite pointer set to special
          rem   sprite data
          rem         player0-3height set to 16
          rem         SCRAM w000-w063 written (sprite data copied to
          rem         RAM)
          rem
          rem Mutates: temp6 (read only), temp3 (read only)
          rem           w000-w015, w016-w031, w032-w047, w048-w063
          rem           (SCRAM)
          rem           player0height, player1height, player2height,
          rem           player3height
          rem
          rem Called Routines: None (uses inline assembly to copy sprite
          rem data)
          rem
          rem Constraints: Must be colocated with LoadCharacterSprite
          rem (called from it)
          rem              Must be in same file as QuestionMark/CPU/No
          rem              sprite loaders
          dim LSS_spriteIndex = temp6 : rem Depends on QuestionMarkSprite, CPUSprite, NoSprite data
          dim LSS_playerNumber = temp3
          if !LSS_spriteIndex then goto LoadQuestionMarkSprite : rem Set sprite pointer based on sprite index
          if LSS_spriteIndex = 1 then goto LoadCPUSprite
          if LSS_spriteIndex = 2 then goto LoadNoSprite
          goto LoadQuestionMarkSprite : rem Invalid sprite index, default to question mark
          
LoadQuestionMarkSprite
          dim LQMS_playerNumber = temp3
          rem Set pointer to QuestionMarkSprite data
          rem
          rem Input: temp3 = player number (0-3)
          rem
          rem Output: Dispatches to player-specific loader
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with
          rem LoadQuestionMarkSpriteP0-P3
          if !LQMS_playerNumber then goto LoadQuestionMarkSpriteP0 : rem Use skip-over pattern to avoid complex compound statements
          if LQMS_playerNumber = 1 then goto LoadQuestionMarkSpriteP1
          if LQMS_playerNumber = 2 then goto LoadQuestionMarkSpriteP2
          goto LoadQuestionMarkSpriteP3
          
LoadQuestionMarkSpriteP0
          asm
          ; Copy QuestionMarkSprite data from ROM to RAM buffer
          ;
          ; Input: temp3 = player number (0, read but not used in this
          ; function)
          ;        QuestionMarkSprite (ROM data) = source sprite data
          ;
          ; Output: w000-w015 (SCRAM) = sprite data copied
          ;         player0height = 16
          ;
          ; Mutates: w000-w015 (SCRAM write port), player0height
          ;
          ; Called Routines: None (uses inline assembly)
          ;
          ; Constraints: Must be colocated with LoadQuestionMarkSprite
          ;              Depends on QuestionMarkSprite ROM data
          ;              Depends on InitializeSpritePointers setting
          ;              pointers
          ; Copy QuestionMarkSprite data from ROM to RAM buffer
          ; (w000-w015)
          ; Pointers already initialized to RAM addresses by
          ; InitializeSpritePointers
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta w000,y
            dey
            bpl .CopyLoop
          end
          player0height = 16
          return
          
LoadQuestionMarkSpriteP1
          rem Copy QuestionMarkSprite data from ROM to RAM buffer
          rem (w016-w031)
          asm
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta w016,y
            dey
            bpl .CopyLoop
          end
          player1height = 16
          return
          
LoadQuestionMarkSpriteP2
          rem Copy QuestionMarkSprite data from ROM to RAM buffer
          rem (w032-w047)
          asm
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta w032,y
            dey
            bpl .CopyLoop
          end
          player2height = 16
          return
          
LoadQuestionMarkSpriteP3
          rem Copy QuestionMarkSprite data from ROM to RAM buffer
          rem (w048-w063)
          asm
            ldy #15
.CopyLoop:
            lda QuestionMarkSprite,y
            sta w048,y
            dey
            bpl .CopyLoop
          end
          player3height = 16
          return
          
LoadCPUSprite
          dim LCS2_playerNumber = temp3
          rem Set pointer to CPUSprite data
          rem
          rem Input: temp3 = player number (0-3)
          rem
          rem Output: Dispatches to player-specific loader
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with LoadCPUSpriteP0-P3
          if !LCS2_playerNumber then LoadCPUSpriteP0 : rem Use skip-over pattern to avoid complex compound statements
          if LCS2_playerNumber = 1 then LoadCPUSpriteP1
          if LCS2_playerNumber = 2 then goto LoadCPUSpriteP2
          goto LoadCPUSpriteP3
          
LoadCPUSpriteP0
          asm
          ; rem Copy CPUSprite data from ROM to RAM buffer
          ; rem
          ; rem Input: temp3 = player number (0, read but not used in this
          ; rem function)
          ; rem        CPUSprite (ROM data) = source sprite data
          ; rem
          ; rem Output: w000-w015 (SCRAM) = sprite data copied
          ; rem         player0height = 16
          ; rem
          ; rem Mutates: w000-w015 (SCRAM write port), player0height
          ; rem
          ; rem Called Routines: None (uses inline assembly)
          ; rem
          ; rem Constraints: Must be colocated with LoadCPUSprite
          ; rem              Depends on CPUSprite ROM data
          ; rem Copy CPUSprite data from ROM to RAM buffer (w000-w015)
          ; rem Pointers already initialized to RAM addresses by
          ; rem InitializeSpritePointers
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta w000,y
            dey
            bpl .CopyLoop
          end
          player0height = 16
          return
          
LoadCPUSpriteP1
          rem Copy CPUSprite data from ROM to RAM buffer (w016-w031)
          asm
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta w016,y
            dey
            bpl .CopyLoop
          end
          player1height = 16
          return
          
LoadCPUSpriteP2
          rem Copy CPUSprite data from ROM to RAM buffer (w032-w047)
          asm
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta w032,y
            dey
            bpl .CopyLoop
          end
          player2height = 16
          return
          
LoadCPUSpriteP3
          rem Copy CPUSprite data from ROM to RAM buffer (w048-w063)
          asm
            ldy #15
.CopyLoop:
            lda CPUSprite,y
            sta w048,y
            dey
            bpl .CopyLoop
          end
          player3height = 16
          return
          
LoadNoSprite
          dim LNS_playerNumber = temp3
          rem Set pointer to NoSprite data
          rem
          rem Input: temp3 = player number (0-3)
          rem
          rem Output: Dispatches to player-specific loader
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with LoadNoSpriteP0-P3
          if !LNS_playerNumber then LoadNoSpriteP0 : rem Use skip-over pattern to avoid complex compound statements
          if LNS_playerNumber = 1 then LoadNoSpriteP1
          if LNS_playerNumber = 2 then goto LoadNoSpriteP2
          goto LoadNoSpriteP3
          
LoadNoSpriteP0
          asm
          ; rem Copy NoSprite data from ROM to RAM buffer
          ; rem
          ; rem Input: temp3 = player number (0, read but not used in this
          ; rem function)
          ; rem        NoSprite (ROM data) = source sprite data
          ; rem
          ; rem Output: w000-w015 (SCRAM) = sprite data copied
          ; rem         player0height = 16
          ; rem
          ; rem Mutates: w000-w015 (SCRAM write port), player0height
          ; rem
          ; rem Called Routines: None (uses inline assembly)
          ; rem
          ; rem Constraints: Must be colocated with LoadNoSprite
          ; rem              Depends on NoSprite ROM data
          ; rem Copy NoSprite data from ROM to RAM buffer (w000-w015)
          ; rem Pointers already initialized to RAM addresses by
          ; rem InitializeSpritePointers
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta w000,y
            dey
            bpl .CopyLoop
          end
          player0height = 16
          return
          
LoadNoSpriteP1
          rem Copy NoSprite data from ROM to RAM buffer (w016-w031)
          asm
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta w016,y
            dey
            bpl .CopyLoop
          end
          player1height = 16
          return
          
LoadNoSpriteP2
          rem Copy NoSprite data from ROM to RAM buffer (w032-w047)
          asm
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta w032,y
            dey
            bpl .CopyLoop
          end
          player2height = 16
          return
          
LoadNoSpriteP3
          rem Copy NoSprite data from ROM to RAM buffer (w048-w063)
          asm
            ldy #15
.CopyLoop:
            lda NoSprite,y
            sta w048,y
            dey
            bpl .CopyLoop
          end
          player3height = 16
          return

LoadPlayerSprite
          rem
          rem LOAD PLAYER SPRITE (generic Dispatcher)
          rem Load sprite data for any player using character art system
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerChar[] (global array) = character indices per
          rem        player
          rem        temp2 = animation frame (0-7) from sprite 10fps
          rem        counter
          rem        temp3 = animation action (0-15) from
          rem        currentAnimationSeq
          rem        temp4 = player number (0-3)
          rem Note: Frame is relative to sprite own 10fps counter, NOT
          rem   global frame counter
          rem
          rem Output: Sprite data loaded via LocateCharacterArt (bank14)
          rem
          rem Mutates: currentCharacter (global), temp1 (passed to
          rem LocateCharacterArt)
          rem
          rem Called Routines: LocateCharacterArt (bank14) - see
          rem LoadCharacterSprite
          rem
          rem Constraints: Must be colocated with
          rem LoadPlayerSpriteDispatch (called via goto)
          dim LPS_playerNumber = temp4
          rem Get character index for this player from playerChar array
          rem Use currentPlayer global variable (set by caller)
          let currentCharacter = playerChar[currentPlayer] : rem Set currentCharacter from playerChar[currentPlayer]
          goto LoadPlayerSpriteDispatch
          
LoadPlayerSpriteDispatch
          dim LPSD_animationFrame = temp2
          dim LPSD_animationAction = temp3
          dim LPSD_playerNumber = temp4
          rem currentCharacter = character index (global variable),
          rem animationFrame =
          rem   frame (10fps counter), animationAction = action,
          rem   playerNumber = player
          rem
          rem Input: currentCharacter (global) = character index
          rem (already set)
          rem        temp2 = animation frame (0-7)
          rem        temp3 = animation action (0-15)
          rem        temp4 = player number (0-3)
          rem
          rem Output: Sprite data loaded via LocateCharacterArt (bank14)
          rem
          rem Mutates: temp1 (set from currentCharacter, passed to
          rem LocateCharacterArt)
          rem
          rem Called Routines: LocateCharacterArt (bank14) - see
          rem LoadCharacterSprite
          rem
          rem Constraints: Must be colocated with LoadPlayerSprite
          rem (called from it)
          rem Call character art location system (in bank14)
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          rem   temp3=action, temp4=player
          rem Set temp1 from currentCharacter (already set from
          rem playerChar[currentPlayer])
          let temp1 = currentCharacter
          gosub LocateCharacterArt bank14
          return

LoadPlayer0Sprite
          rem
          rem LOAD PLAYER SPRITES (legacy Player-specific Functions)
          rem Load sprite data into specific player registers
          rem These functions contain the actual player graphics
          rem   commands
          
          dim LP0S_playerNumber = temp3
          rem Use art location system for player 0 sprite loading
          rem
          rem Input: currentCharacter (global) = character index (must
          rem be set)
          rem        temp2 = animation frame (0-7, must be set by
          rem        caller)
          rem
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem
          rem Mutates: temp3 (set to 0, passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite - see its
          rem documentation
          rem
          rem Constraints: Must be colocated with LoadCharacterSprite
          rem (tail call)
          rem              Only reachable via gosub/goto (could be own
          rem              file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          let LP0S_playerNumber = 0 : rem playerNumber = player number (0)
          let temp3 = LP0S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          goto LoadCharacterSprite : rem tail call
          
LoadPlayer1Sprite
          dim LP1S_playerNumber = temp3
          rem Use art location system for player 1 sprite loading
          rem
          rem Input: currentCharacter (global) = character index (must
          rem be set)
          rem        temp2 = animation frame (0-7, must be set by
          rem        caller)
          rem
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem
          rem Mutates: temp3 (set to 1, passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite - see its
          rem documentation
          rem
          rem Constraints: Must be colocated with LoadCharacterSprite
          rem (tail call)
          rem              Only reachable via gosub/goto (could be own
          rem              file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          let LP1S_playerNumber = 1 : rem playerNumber = player number (1)
          let temp3 = LP1S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          goto LoadCharacterSprite : rem tail call
          
LoadPlayer2Sprite
          dim LP2S_playerNumber = temp3
          rem Use art location system for player 2 sprite loading
          rem
          rem Input: currentCharacter (global) = character index (must
          rem be set)
          rem        temp2 = animation frame (0-7, must be set by
          rem        caller)
          rem
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem
          rem Mutates: temp3 (set to 2, passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite - see its
          rem documentation
          rem
          rem Constraints: Must be colocated with LoadCharacterSprite
          rem (tail call)
          rem              Only reachable via gosub/goto (could be own
          rem              file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          let LP2S_playerNumber = 2 : rem playerNumber = player number (2)
          let temp3 = LP2S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          goto LoadCharacterSprite : rem tail call
          
LoadPlayer3Sprite
          dim LP3S_playerNumber = temp3
          rem Use art location system for player 3 sprite loading
          rem
          rem Input: currentCharacter (global) = character index (must
          rem be set)
          rem        temp2 = animation frame (0-7, must be set by
          rem        caller)
          rem
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem
          rem Mutates: temp3 (set to 3, passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite - see its
          rem documentation
          rem
          rem Constraints: Must be colocated with LoadCharacterSprite
          rem (tail call)
          rem              Only reachable via gosub/goto (could be own
          rem              file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          let LP3S_playerNumber = 3 : rem playerNumber = player number (3)
          let temp3 = LP3S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          goto LoadCharacterSprite : rem tail call





LoadCharacterColors
          rem Load player color based on TV standard, B&W, hurt, and
          rem   flashing states
          rem
          rem Input: temp2 = hurt state (0/1)
          rem        temp3 = player number (0-3)
          rem        temp4 = flashing state (0/1)
          rem        temp5 = flashing mode (0=frame-based,
          rem        1=player-index)
          rem        frame (global) = frame counter for flashing
          rem        systemFlags (global) = system flags including B&W
          rem        override
          rem
          rem Output: Appropriate COLUP0/COLUP1/COLUP2/COLUP3 updated
          rem Note: Colors are per-player, not per-character. Players
          rem use
          rem   solid colors only (no per-line coloring)
          rem
          rem Mutates: temp6 (color calculation, internal use)
          rem           COLUP0, COLUP1, COLUP2, COLUP3 (TIA registers)
          rem
          rem Called Routines: None (all logic inline)
          rem
          rem Constraints: Must be colocated with NormalColor,
          rem FlashingColor,
          rem              PerLineFlashing, PlayerIndexColors,
          rem              PlayerIndexColorsDim,
          rem              HurtColor, SetColor (all called via goto)
          rem WARNING: temp6 is mutated during execution. Do not use
          rem temp6
          dim LoadCharacterColors_isHurt = temp2 : rem after calling this subroutine.
          dim LoadCharacterColors_playerNumber = temp3
          dim LoadCharacterColors_isFlashing = temp4
          dim LoadCharacterColors_flashingMode = temp5
          dim LoadCharacterColors_color = temp6
          if LoadCharacterColors_isHurt then goto HurtColor : rem Highest priority: hurt state

          if LoadCharacterColors_isFlashing then FlashingColor : rem Next priority: flashing state

NormalColor
          dim NormalColor_color = temp6
          dim NormalColor_playerNumber = temp3
          rem Calculate normal (non-hurt, non-flashing) player color
          rem
          rem Input: temp3 = player number (0-3, from
          rem LoadCharacterColors)
          rem        systemFlags (global) = system flags including B&W
          rem        override
          rem
          rem Output: Dispatches to PlayerIndexColors
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with LoadCharacterColors
          rem Determine effective B&W override locally; if enabled, use
          if systemFlags & SystemFlagColorBWOverride then PlayerIndexColors : rem   player colors

          rem NTSC/PAL: Character-specific colors would be used here
          rem   when tables exist
          rem Placeholder: fall back to player index colors until
          goto PlayerIndexColors : rem   character tables are wired

FlashingColor
          dim FlashingColor_flashingMode = temp5
          rem Flashing mode selection
          rem
          rem Input: temp5 = flashing mode (0=frame-based,
          rem 1=player-index)
          rem
          rem Output: Dispatches to PerLineFlashing or PlayerIndexColors
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          let FlashingColor_flashingMode = LoadCharacterColors_flashingMode : rem Constraints: Must be colocated with LoadCharacterColors
          if !FlashingColor_flashingMode then PerLineFlashing
          goto PlayerIndexColors
          
PerLineFlashing
          dim PerLineFlashing_color = temp6
          rem Frame-based flashing (not per-line - players use solid
          rem   colors)
          rem
          rem Input: frame (global) = frame counter for flashing
          rem        temp3 = player number (0-3, from
          rem        LoadCharacterColors)
          rem
          rem Output: Dispatches to PlayerIndexColorsDim or
          rem PlayerIndexColors
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with LoadCharacterColors
          rem Use alternating bright/dim player index colors by frame
          if frame & 8 then PlayerIndexColorsDim : rem   bit
          goto PlayerIndexColors
          
PlayerIndexColors
          rem Calculate bright player index colors
          rem
          rem Input: temp3 = player number (0-3, from
          rem LoadCharacterColors)
          rem
          rem Output: temp6 = color value, dispatches to SetColor
          rem
          rem Mutates: temp6 (color value)
          rem
          rem Called Routines: None (dispatcher only)
          dim PlayerIndexColors_color = temp6 : rem Constraints: Must be colocated with LoadCharacterColors, SetColor
          rem Solid player index colors (bright)
          rem Player 1=Indigo, Player 2=Red, Player 3=Yellow, Player
          rem   4=Turquoise (SECAM maps to Green)
          if !LoadCharacterColors_playerNumber then let PlayerIndexColors_color = ColIndigo(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor : rem NTSC/PAL: Use Turquoise for Player 4
          if LoadCharacterColors_playerNumber = 1 then let PlayerIndexColors_color = ColRed(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor : rem Player 1: Indigo
          if LoadCharacterColors_playerNumber = 2 then let PlayerIndexColors_color = ColYellow(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor : rem Player 2: Red
          let PlayerIndexColors_color = ColTurquoise(14) : rem Player 3: Yellow
          let LoadCharacterColors_color = PlayerIndexColors_color : rem Player 4: Turquoise
          goto SetColor

PlayerIndexColorsDim
          dim PlayerIndexColorsDim_color = temp6
          rem Dimmed player index colors
          rem
          rem Input: temp3 = player number (0-3, from
          rem LoadCharacterColors)
          rem
          rem Output: temp6 = dimmed color value, dispatches to SetColor
          rem
          rem Mutates: temp6 (color value)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with LoadCharacterColors,
          rem SetColor
          rem Player 1=Indigo, Player 2=Red, Player 3=Yellow, Player
          rem   4=Turquoise (SECAM maps to Green)
          if !LoadCharacterColors_playerNumber then let PlayerIndexColorsDim_color = ColIndigo(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor : rem NTSC/PAL: Use Turquoise for Player 4
          if LoadCharacterColors_playerNumber = 1 then let PlayerIndexColorsDim_color = ColRed(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor : rem Player 1: Indigo (dimmed)
          if LoadCharacterColors_playerNumber = 2 then let PlayerIndexColorsDim_color = ColYellow(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor : rem Player 2: Red (dimmed)
          let PlayerIndexColorsDim_color = ColTurquoise(6) : rem Player 3: Yellow (dimmed)
          let LoadCharacterColors_color = PlayerIndexColorsDim_color : rem Player 4: Turquoise (dimmed)
          goto SetColor

HurtColor
          dim HurtColor_color = temp6
          rem Calculate hurt state player color
          rem
          rem Input: temp3 = player number (0-3, from
          rem LoadCharacterColors)
          rem
          rem Output: temp6 = hurt color value, dispatches to SetColor
          rem
          rem Mutates: temp6 (color value)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with LoadCharacterColors,
          rem SetColor
#ifdef TV_SECAM
          let HurtColor_color = ColMagenta(10) : rem SECAM hurt is always magenta
          let LoadCharacterColors_color = HurtColor_color
          goto SetColor
#else
          rem Dimmed version of normal color: use dim player index color
          goto PlayerIndexColorsDim : rem   as fallback
#endif
          
SetColor
          rem Set color based on player index (multisprite kernel
          rem   supports COLUP2/COLUP3)
          rem
          rem Input: temp6 = color value (from previous color
          rem calculation)
          rem        temp3 = player number (0-3, from
          rem        LoadCharacterColors)
          rem
          rem Output: COLUP0, COLUP1, COLUP2, or COLUP3 updated
          rem
          rem Mutates: COLUP0, COLUP1, COLUP2, COLUP3 (TIA registers)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with LoadCharacterColors
          rem Use temp6 directly instead of alias to avoid symbol
          rem conflict
          rem LoadCharacterColors_color already contains the color from
          let temp6 = LoadCharacterColors_color : rem   previous code paths
          if !LoadCharacterColors_playerNumber then let COLUP0 = temp6 : return
          if LoadCharacterColors_playerNumber = 1 then let _COLUP1 = temp6 : return
          if LoadCharacterColors_playerNumber = 2 then let COLUP2 = temp6 : return
          let COLUP3 = temp6
          return
