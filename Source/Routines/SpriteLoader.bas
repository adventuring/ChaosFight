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
          rem Handles special sprites (QuestionMark, CPU, No) for
          rem   placeholders


          rem ==========================================================
          rem SOLID PLAYER COLOR TABLES
          rem ==========================================================
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

          rem SPRITE LOADING FUNCTIONS


          rem Load sprite data for a character based on character index
          rem Input: currentCharacter (global) = character index (0-31)
          rem        temp2 = animation frame (0-7)
          rem        temp3 = player number (0-3), may be in temp4 instead
          rem        MaxCharacter (constant) = maximum valid character index
          rem Output: Sprite data loaded into appropriate player register
          rem         via LocateCharacterArt (bank14)
          rem Mutates: temp1, temp2, temp3, temp4 (passed to LocateCharacterArt)
          rem Called Routines: LocateCharacterArt (bank14) accesses:
          rem   - temp1, temp2, temp3, temp4, temp5, temp6
          rem   - Sets player sprite pointers via SetPlayerCharacterArtBankX
          rem   - Modifies player0-3pointerlo/hi, player0-3height
          rem Constraints: Must be colocated with LoadSpecialSprite (called via goto)
          rem              Must be in same file as special sprite loaders
LoadCharacterSprite
          dim LCS_animationFrame = temp2
          dim LCS_playerNumber = temp3
          dim LCS_animationAction = temp3
          dim LCS_playerNumberAlt = temp4
          dim LCS_isValid = temp5
          dim LCS_spriteIndex = temp6
          rem Validate character index
          rem Inline ValidateCharacterIndex
          dim VCI_isValid = temp5
          rem Check if character index is within valid range
          rem   (0-MaxCharacter for current implementation)
          if currentCharacter > MaxCharacter then ValidateInvalidCharacterInline
          let VCI_isValid = 1
          goto ValidateCharacterDoneInline
ValidateInvalidCharacterInline
          let VCI_isValid = 0
ValidateCharacterDoneInline
          let LCS_isValid = VCI_isValid
          rem tail call
          if !LCS_isValid then goto LoadSpecialSprite
          
          rem Check if character is special placeholder
          rem tail call
          if currentCharacter = 255 then let LCS_spriteIndex = SpriteNo : goto LoadSpecialSprite
          rem NoCharacter = 255
          
          rem tail call
          if currentCharacter = 254 then let LCS_spriteIndex = SpriteCPU : goto LoadSpecialSprite
          rem CPUCharacter = 254
          
          rem tail call
          if currentCharacter = 253 then let LCS_spriteIndex = SpriteQuestionMark : goto LoadSpecialSprite
          rem RandomCharacter = 253
          
          rem Use character art location system for sprite loading
          rem Input: currentCharacter = character index (global variable), animationFrame =
          rem   animation frame
          rem playerNumber = player number OR playerNumberAlt = player
          rem   number (caller provides)
          rem Default to animation sequence 0 (idle) for character
          rem   select
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          rem   temp3=action, temp4=player
          
          rem Check if player number in temp3 or temp4
          rem If temp4 is not set (0 and caller might have used temp3),
          rem   copy from temp3
          if !LCS_playerNumberAlt then let LCS_playerNumberAlt = LCS_playerNumber
          
          rem Move player number to temp4 and set temp3 to animation
          rem   action (0=idle)
          let LCS_animationAction = 0
          rem animation action/sequence 0 = idle
          rem playerNumberAlt already has player number from caller
          rem Set temp variables for cross-bank call
          let temp1 = currentCharacter
          let temp2 = LCS_animationFrame
          let temp3 = LCS_animationAction
          let temp4 = LCS_playerNumberAlt
          gosub LocateCharacterArt bank14
          return

          rem ==========================================================
          rem LOAD SPECIAL SPRITE
          rem ==========================================================
          rem Loads special placeholder sprites (QuestionMark, CPU, No)
          rem Input: temp6 = sprite index (SpriteQuestionMark=0,
          rem   SpriteCPU=1, SpriteNo=2)
          rem        temp3 = player number (0-3)
          rem Output: Appropriate player sprite pointer set to special
          rem   sprite data
          rem         player0-3height set to 16
          rem         SCRAM w000-w063 written (sprite data copied to RAM)
          rem Mutates: temp6 (read only), temp3 (read only)
          rem           w000-w015, w016-w031, w032-w047, w048-w063 (SCRAM)
          rem           player0height, player1height, player2height, player3height
          rem Called Routines: None (uses inline assembly to copy sprite data)
          rem Constraints: Must be colocated with LoadCharacterSprite (called from it)
          rem              Must be in same file as QuestionMark/CPU/No sprite loaders
          rem              Depends on QuestionMarkSprite, CPUSprite, NoSprite data
LoadSpecialSprite
          dim LSS_spriteIndex = temp6
          dim LSS_playerNumber = temp3
          rem Set sprite pointer based on sprite index
          if !LSS_spriteIndex then goto LoadQuestionMarkSprite
          if LSS_spriteIndex = 1 then goto LoadCPUSprite
          if LSS_spriteIndex = 2 then goto LoadNoSprite
          rem Invalid sprite index, default to question mark
          goto LoadQuestionMarkSprite
          
LoadQuestionMarkSprite
          dim LQMS_playerNumber = temp3
          rem Set pointer to QuestionMarkSprite data
          rem Input: temp3 = player number (0-3)
          rem Output: Dispatches to player-specific loader
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadQuestionMarkSpriteP0-P3
          rem Use skip-over pattern to avoid complex compound statements
          if !LQMS_playerNumber then goto LoadQuestionMarkSpriteP0
          if LQMS_playerNumber = 1 then goto LoadQuestionMarkSpriteP1
          if LQMS_playerNumber = 2 then goto LoadQuestionMarkSpriteP2
          goto LoadQuestionMarkSpriteP3
          
LoadQuestionMarkSpriteP0
          rem Copy QuestionMarkSprite data from ROM to RAM buffer
          rem Input: temp3 = player number (0, read but not used in this function)
          rem        QuestionMarkSprite (ROM data) = source sprite data
          rem Output: w000-w015 (SCRAM) = sprite data copied
          rem         player0height = 16
          rem Mutates: w000-w015 (SCRAM write port), player0height
          rem Called Routines: None (uses inline assembly)
          rem Constraints: Must be colocated with LoadQuestionMarkSprite
          rem              Depends on QuestionMarkSprite ROM data
          rem              Depends on InitializeSpritePointers setting pointers
          rem Copy QuestionMarkSprite data from ROM to RAM buffer (w000-w015)
          rem Pointers already initialized to RAM addresses by InitializeSpritePointers
          asm
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
          rem Copy QuestionMarkSprite data from ROM to RAM buffer (w016-w031)
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
          rem Copy QuestionMarkSprite data from ROM to RAM buffer (w032-w047)
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
          rem Copy QuestionMarkSprite data from ROM to RAM buffer (w048-w063)
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
          rem Input: temp3 = player number (0-3)
          rem Output: Dispatches to player-specific loader
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadCPUSpriteP0-P3
          rem Use skip-over pattern to avoid complex compound statements
          if !LCS2_playerNumber then LoadCPUSpriteP0
          if LCS2_playerNumber = 1 then LoadCPUSpriteP1
          if LCS2_playerNumber = 2 then goto LoadCPUSpriteP2
          goto LoadCPUSpriteP3
          
LoadCPUSpriteP0
          rem Copy CPUSprite data from ROM to RAM buffer
          rem Input: temp3 = player number (0, read but not used in this function)
          rem        CPUSprite (ROM data) = source sprite data
          rem Output: w000-w015 (SCRAM) = sprite data copied
          rem         player0height = 16
          rem Mutates: w000-w015 (SCRAM write port), player0height
          rem Called Routines: None (uses inline assembly)
          rem Constraints: Must be colocated with LoadCPUSprite
          rem              Depends on CPUSprite ROM data
          rem Copy CPUSprite data from ROM to RAM buffer (w000-w015)
          rem Pointers already initialized to RAM addresses by InitializeSpritePointers
          asm
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
          rem Input: temp3 = player number (0-3)
          rem Output: Dispatches to player-specific loader
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadNoSpriteP0-P3
          rem Use skip-over pattern to avoid complex compound statements
          if !LNS_playerNumber then LoadNoSpriteP0
          if LNS_playerNumber = 1 then LoadNoSpriteP1
          if LNS_playerNumber = 2 then goto LoadNoSpriteP2
          goto LoadNoSpriteP3
          
LoadNoSpriteP0
          rem Copy NoSprite data from ROM to RAM buffer
          rem Input: temp3 = player number (0, read but not used in this function)
          rem        NoSprite (ROM data) = source sprite data
          rem Output: w000-w015 (SCRAM) = sprite data copied
          rem         player0height = 16
          rem Mutates: w000-w015 (SCRAM write port), player0height
          rem Called Routines: None (uses inline assembly)
          rem Constraints: Must be colocated with LoadNoSprite
          rem              Depends on NoSprite ROM data
          rem Copy NoSprite data from ROM to RAM buffer (w000-w015)
          rem Pointers already initialized to RAM addresses by InitializeSpritePointers
          asm
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

          rem ==========================================================
          rem LOAD PLAYER SPRITE (generic dispatcher)
          rem ==========================================================
          rem Load sprite data for any player using character art system
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerChar[] (global array) = character indices per player
          rem        temp2 = animation frame (0-7) from sprite 10fps counter
          rem        temp3 = animation action (0-15) from currentAnimationSeq
          rem        temp4 = player number (0-3)
          rem Note: Frame is relative to sprite own 10fps counter, NOT
          rem   global frame counter
          rem Output: Sprite data loaded via LocateCharacterArt (bank14)
          rem Mutates: currentCharacter (global), temp1 (passed to LocateCharacterArt)
          rem Called Routines: LocateCharacterArt (bank14) - see LoadCharacterSprite
          rem Constraints: Must be colocated with LoadPlayerSpriteDispatch (called via goto)
LoadPlayerSprite
          dim LPS_playerNumber = temp4
          rem Get character index for this player from playerChar array
          rem Use currentPlayer global variable (set by caller)
          rem Set currentCharacter from playerChar[currentPlayer]
          let currentCharacter = playerChar[currentPlayer]
          goto LoadPlayerSpriteDispatch
          
LoadPlayerSpriteDispatch
          dim LPSD_animationFrame = temp2
          dim LPSD_animationAction = temp3
          dim LPSD_playerNumber = temp4
          rem currentCharacter = character index (global variable), animationFrame =
          rem   frame (10fps counter), animationAction = action,
          rem   playerNumber = player
          rem Input: currentCharacter (global) = character index (already set)
          rem        temp2 = animation frame (0-7)
          rem        temp3 = animation action (0-15)
          rem        temp4 = player number (0-3)
          rem Output: Sprite data loaded via LocateCharacterArt (bank14)
          rem Mutates: temp1 (set from currentCharacter, passed to LocateCharacterArt)
          rem Called Routines: LocateCharacterArt (bank14) - see LoadCharacterSprite
          rem Constraints: Must be colocated with LoadPlayerSprite (called from it)
          rem Call character art location system (in bank14)
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          rem   temp3=action, temp4=player
          rem Set temp1 from currentCharacter (already set from playerChar[currentPlayer])
          let temp1 = currentCharacter
          gosub LocateCharacterArt bank14
          return

          rem ==========================================================
          rem LOAD PLAYER SPRITES (legacy player-specific functions)
          rem ==========================================================
          rem Load sprite data into specific player registers
          rem These functions contain the actual player graphics
          rem   commands
          
LoadPlayer0Sprite
          dim LP0S_playerNumber = temp3
          rem Use art location system for player 0 sprite loading
          rem Input: currentCharacter (global) = character index (must be set)
          rem        temp2 = animation frame (0-7, must be set by caller)
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem Mutates: temp3 (set to 0, passed to LoadCharacterSprite)
          rem Called Routines: LoadCharacterSprite - see its documentation
          rem Constraints: Must be colocated with LoadCharacterSprite (tail call)
          rem              Only reachable via gosub/goto (could be own file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          rem playerNumber = player number (0)
          let LP0S_playerNumber = 0
          let temp3 = LP0S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          rem tail call
          goto LoadCharacterSprite
          
LoadPlayer1Sprite
          dim LP1S_playerNumber = temp3
          rem Use art location system for player 1 sprite loading
          rem Input: currentCharacter (global) = character index (must be set)
          rem        temp2 = animation frame (0-7, must be set by caller)
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem Mutates: temp3 (set to 1, passed to LoadCharacterSprite)
          rem Called Routines: LoadCharacterSprite - see its documentation
          rem Constraints: Must be colocated with LoadCharacterSprite (tail call)
          rem              Only reachable via gosub/goto (could be own file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          rem playerNumber = player number (1)
          let LP1S_playerNumber = 1
          let temp3 = LP1S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          rem tail call
          goto LoadCharacterSprite
          
LoadPlayer2Sprite
          dim LP2S_playerNumber = temp3
          rem Use art location system for player 2 sprite loading
          rem Input: currentCharacter (global) = character index (must be set)
          rem        temp2 = animation frame (0-7, must be set by caller)
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem Mutates: temp3 (set to 2, passed to LoadCharacterSprite)
          rem Called Routines: LoadCharacterSprite - see its documentation
          rem Constraints: Must be colocated with LoadCharacterSprite (tail call)
          rem              Only reachable via gosub/goto (could be own file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          rem playerNumber = player number (2)
          let LP2S_playerNumber = 2
          let temp3 = LP2S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          rem tail call
          goto LoadCharacterSprite
          
LoadPlayer3Sprite
          dim LP3S_playerNumber = temp3
          rem Use art location system for player 3 sprite loading
          rem Input: currentCharacter (global) = character index (must be set)
          rem        temp2 = animation frame (0-7, must be set by caller)
          rem Output: Sprite data loaded via LoadCharacterSprite
          rem Mutates: temp3 (set to 3, passed to LoadCharacterSprite)
          rem Called Routines: LoadCharacterSprite - see its documentation
          rem Constraints: Must be colocated with LoadCharacterSprite (tail call)
          rem              Only reachable via gosub/goto (could be own file)
          rem temp1 = character index, temp2 = animation frame already
          rem   set
          rem playerNumber = player number (3)
          let LP3S_playerNumber = 3
          let temp3 = LP3S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          rem tail call
          goto LoadCharacterSprite





          rem Load player color based on TV standard, B&W, hurt, and
          rem   flashing states
          rem Input: temp2 = hurt state (0/1)
          rem        temp3 = player number (0-3)
          rem        temp4 = flashing state (0/1)
          rem        temp5 = flashing mode (0=frame-based, 1=player-index)
          rem        frame (global) = frame counter for flashing
          rem        systemFlags (global) = system flags including B&W override
          rem Output: Appropriate COLUP0/COLUP1/COLUP2/COLUP3 updated
          rem Note: Colors are per-player, not per-character. Players use
          rem   solid colors only (no per-line coloring)
          rem Mutates: temp6 (color calculation, internal use)
          rem           COLUP0, COLUP1, COLUP2, COLUP3 (TIA registers)
          rem Called Routines: None (all logic inline)
          rem Constraints: Must be colocated with NormalColor, FlashingColor,
          rem              PerLineFlashing, PlayerIndexColors, PlayerIndexColorsDim,
          rem              HurtColor, SetColor (all called via goto)
          rem WARNING: temp6 is mutated during execution. Do not use temp6
          rem   after calling this subroutine.
LoadCharacterColors
          dim LoadCharacterColors_isHurt = temp2
          dim LoadCharacterColors_playerNumber = temp3
          dim LoadCharacterColors_isFlashing = temp4
          dim LoadCharacterColors_flashingMode = temp5
          dim LoadCharacterColors_color = temp6
          rem Highest priority: hurt state
          if LoadCharacterColors_isHurt then goto HurtColor

          rem Next priority: flashing state
          if LoadCharacterColors_isFlashing then FlashingColor

NormalColor
          dim NormalColor_color = temp6
          dim NormalColor_playerNumber = temp3
          rem Calculate normal (non-hurt, non-flashing) player color
          rem Input: temp3 = player number (0-3, from LoadCharacterColors)
          rem        systemFlags (global) = system flags including B&W override
          rem Output: Dispatches to PlayerIndexColors
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadCharacterColors
#ifdef TV_SECAM
          rem SECAM: always use player index colors (no luminance
          rem   control)
          goto PlayerIndexColors
#else
          rem Determine effective B&W override locally; if enabled, use
          rem   player colors
          if systemFlags & SystemFlagColorBWOverride then PlayerIndexColors

          rem NTSC/PAL: Character-specific colors would be used here
          rem   when tables exist
          rem Placeholder: fall back to player index colors until
          rem   character tables are wired
          goto PlayerIndexColors
#endif

FlashingColor
          dim FlashingColor_flashingMode = temp5
          rem Flashing mode selection
          rem Input: temp5 = flashing mode (0=frame-based, 1=player-index)
          rem Output: Dispatches to PerLineFlashing or PlayerIndexColors
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadCharacterColors
          let FlashingColor_flashingMode = LoadCharacterColors_flashingMode
          if !FlashingColor_flashingMode then PerLineFlashing
          goto PlayerIndexColors
          
PerLineFlashing
          dim PerLineFlashing_color = temp6
          rem Frame-based flashing (not per-line - players use solid
          rem   colors)
          rem Input: frame (global) = frame counter for flashing
          rem        temp3 = player number (0-3, from LoadCharacterColors)
          rem Output: Dispatches to PlayerIndexColorsDim or PlayerIndexColors
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadCharacterColors
          rem Use alternating bright/dim player index colors by frame
          rem   bit
          if frame & 8 then PlayerIndexColorsDim
          goto PlayerIndexColors
          
PlayerIndexColors
          rem Calculate bright player index colors
          rem Input: temp3 = player number (0-3, from LoadCharacterColors)
          rem Output: temp6 = color value, dispatches to SetColor
          rem Mutates: temp6 (color value)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadCharacterColors, SetColor
          dim PlayerIndexColors_color = temp6
          rem Solid player index colors (bright)
          rem Player 1=Indigo, Player 2=Red, Player 3=Yellow, Player
          rem   4=Turquoise (SECAM maps to Green)
#ifdef TV_SECAM
          rem SECAM: Player 4 uses Green instead of Turquoise (Turquoise
          rem   maps to Cyan on SECAM)
          if !LoadCharacterColors_playerNumber then let PlayerIndexColors_color = ColIndigo(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor
          rem Player 1: Indigo -> Blue on SECAM
          if LoadCharacterColors_playerNumber = 1 then let PlayerIndexColors_color = ColRed(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor
          rem Player 2: Red
          if LoadCharacterColors_playerNumber = 2 then let PlayerIndexColors_color = ColYellow(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor
          rem Player 3: Yellow
          let PlayerIndexColors_color = ColGreen(14)
          rem Player 4: Green (SECAM-specific, Turquoise would be Cyan)
          let LoadCharacterColors_color = PlayerIndexColors_color
          goto SetColor
#else
          rem NTSC/PAL: Use Turquoise for Player 4
          if !LoadCharacterColors_playerNumber then let PlayerIndexColors_color = ColIndigo(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor
          rem Player 1: Indigo
          if LoadCharacterColors_playerNumber = 1 then let PlayerIndexColors_color = ColRed(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor
          rem Player 2: Red
          if LoadCharacterColors_playerNumber = 2 then let PlayerIndexColors_color = ColYellow(14) : let LoadCharacterColors_color = PlayerIndexColors_color : goto SetColor
          rem Player 3: Yellow
          let PlayerIndexColors_color = ColTurquoise(14)
          rem Player 4: Turquoise
          let LoadCharacterColors_color = PlayerIndexColors_color
          goto SetColor
#endif

PlayerIndexColorsDim
          dim PlayerIndexColorsDim_color = temp6
          rem Dimmed player index colors
          rem Input: temp3 = player number (0-3, from LoadCharacterColors)
          rem Output: temp6 = dimmed color value, dispatches to SetColor
          rem Mutates: temp6 (color value)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadCharacterColors, SetColor
          rem Player 1=Indigo, Player 2=Red, Player 3=Yellow, Player
          rem   4=Turquoise (SECAM maps to Green)
#ifdef TV_SECAM
          rem SECAM: Player 4 uses Green instead of Turquoise (Turquoise
          rem   maps to Cyan on SECAM)
          if !LoadCharacterColors_playerNumber then let PlayerIndexColorsDim_color = ColIndigo(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor
          rem Player 1: Indigo -> Blue on SECAM (dimmed)
          if LoadCharacterColors_playerNumber = 1 then let PlayerIndexColorsDim_color = ColRed(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor
          rem Player 2: Red (dimmed)
          if LoadCharacterColors_playerNumber = 2 then let PlayerIndexColorsDim_color = ColYellow(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor
          rem Player 3: Yellow (dimmed)
          let PlayerIndexColorsDim_color = ColGreen(6)
          rem Player 4: Green (SECAM-specific, Turquoise would be Cyan)
          let LoadCharacterColors_color = PlayerIndexColorsDim_color
          goto SetColor
#else
          rem NTSC/PAL: Use Turquoise for Player 4
          if !LoadCharacterColors_playerNumber then let PlayerIndexColorsDim_color = ColIndigo(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor
          rem Player 1: Indigo (dimmed)
          if LoadCharacterColors_playerNumber = 1 then let PlayerIndexColorsDim_color = ColRed(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor
          rem Player 2: Red (dimmed)
          if LoadCharacterColors_playerNumber = 2 then let PlayerIndexColorsDim_color = ColYellow(6) : let LoadCharacterColors_color = PlayerIndexColorsDim_color : goto SetColor
          rem Player 3: Yellow (dimmed)
          let PlayerIndexColorsDim_color = ColTurquoise(6)
          rem Player 4: Turquoise (dimmed)
          let LoadCharacterColors_color = PlayerIndexColorsDim_color
          goto SetColor
#endif

HurtColor
          dim HurtColor_color = temp6
          rem Calculate hurt state player color
          rem Input: temp3 = player number (0-3, from LoadCharacterColors)
          rem Output: temp6 = hurt color value, dispatches to SetColor
          rem Mutates: temp6 (color value)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with LoadCharacterColors, SetColor
#ifdef TV_SECAM
          rem SECAM hurt is always magenta
          let HurtColor_color = ColMagenta(10)
          let LoadCharacterColors_color = HurtColor_color
          goto SetColor
#else
          rem Dimmed version of normal color: use dim player index color
          rem   as fallback
          goto PlayerIndexColorsDim
#endif
          
SetColor
          rem Set color based on player index (multisprite kernel
          rem   supports COLUP2/COLUP3)
          rem Input: temp6 = color value (from previous color calculation)
          rem        temp3 = player number (0-3, from LoadCharacterColors)
          rem Output: COLUP0, COLUP1, COLUP2, or COLUP3 updated
          rem Mutates: COLUP0, COLUP1, COLUP2, COLUP3 (TIA registers)
          rem Called Routines: None
          rem Constraints: Must be colocated with LoadCharacterColors
          rem Use temp6 directly instead of alias to avoid symbol conflict
          rem LoadCharacterColors_color already contains the color from
          rem   previous code paths
          let temp6 = LoadCharacterColors_color
          if !LoadCharacterColors_playerNumber then let COLUP0 = temp6 : return
          if LoadCharacterColors_playerNumber = 1 then let _COLUP1 = temp6 : return
          if LoadCharacterColors_playerNumber = 2 then let COLUP2 = temp6 : return
          let COLUP3 = temp6
          return
