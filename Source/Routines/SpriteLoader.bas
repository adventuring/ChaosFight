          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.


          rem MULTI-BANK SPRITE LOADING SYSTEM

          rem Loads character sprite data and colors from multiple banks
          rem Supports up to 32 characters (0-31) across 4 banks
          rem Current implementation: NumCharacters characters (0-MaxCharacter) in 2 banks
          rem Special sprites: QuestionMark, CPU, No for special selections.


          rem MULTI-BANK SPRITE LOADING FUNCTIONS

          rem Loads sprites from appropriate bank based on character index
          rem Handles special sprites (QuestionMark, CPU, No) for placeholders


          rem =================================================================
          rem SOLID PLAYER COLOR TABLES
          rem =================================================================
          rem Solid color tables for P1-P4 normal and hurt states
          rem P1=Indigo, P2=Red, P3=Yellow, P4=Green

          rem Player Colors - Light versions for normal state
          data PlayerColorsLight
              ColIndigo(14), ColRed(14), ColYellow(14), ColGreen(14)
end

          rem Player Colors - Dark versions for hurt state  
          data PlayerColorsDark
              ColIndigo(6), ColRed(6), ColYellow(6), ColGreen(6)
end

          rem SPRITE LOADING FUNCTIONS


          rem Load sprite data for a character based on character index
          rem Input: temp1 = character index (0-31), temp2 = animation frame (0-7)
          rem        temp3 = player number (0-3)
          rem Output: Sprite data loaded into appropriate player register
LoadCharacterSprite
          dim LCS_characterIndex = temp1
          dim LCS_animationFrame = temp2
          dim LCS_playerNumber = temp3
          dim LCS_animationAction = temp3
          dim LCS_playerNumberAlt = temp4
          dim LCS_isValid = temp5
          dim LCS_spriteIndex = temp6
          rem Validate character index
          let temp1 = LCS_characterIndex
          gosub ValidateCharacterIndex
          let LCS_isValid = temp5
          rem tail call
          if !LCS_isValid then goto LoadSpecialSprite
          
          rem Check if character is special placeholder
          rem tail call
          if LCS_characterIndex = 255 then let LCS_spriteIndex = SpriteNo : goto LoadSpecialSprite
          rem NoCharacter = 255
          
          rem tail call
          if LCS_characterIndex = 254 then let LCS_spriteIndex = SpriteCPU : goto LoadSpecialSprite
          rem CPUCharacter = 254
          
          rem tail call
          if LCS_characterIndex = 253 then let LCS_spriteIndex = SpriteQuestionMark : goto LoadSpecialSprite
          rem RandomCharacter = 253
          
          rem Use character art location system for sprite loading
          rem Input: characterIndex = character index, animationFrame = animation frame
          rem        playerNumber = player number OR playerNumberAlt = player number (caller provides)
          rem Default to animation sequence 0 (idle) for character select
          rem LocateCharacterArt expects: temp1=char, temp2=frame, temp3=action, temp4=player
          
          rem Check if player number in temp3 or temp4
          rem If temp4 is not set (0 and caller might have used temp3), copy from temp3
          if !LCS_playerNumberAlt then let LCS_playerNumberAlt = LCS_playerNumber
          
          rem Move player number to temp4 and set temp3 to animation action (0=idle)
          let LCS_animationAction = 0
          rem animation action/sequence 0 = idle
          rem playerNumberAlt already has player number from caller
          let temp1 = LCS_characterIndex
          let temp2 = LCS_animationFrame
          let temp3 = LCS_animationAction
          let temp4 = LCS_playerNumberAlt
          gosub bank10 LocateCharacterArt
          return

          rem =================================================================
          rem LOAD SPECIAL SPRITE
          rem =================================================================
          rem Loads special placeholder sprites (QuestionMark, CPU, No)
          rem Input: temp6 = sprite index (SpriteQuestionMark=0, SpriteCPU=1, SpriteNo=2)
          rem        temp3 = player number (0-3)
          rem Output: Appropriate player sprite pointer set to special sprite data
LoadSpecialSprite
          dim LSS_spriteIndex = temp6
          dim LSS_playerNumber = temp3
          rem Set sprite pointer based on sprite index
          if !LSS_spriteIndex then LoadQuestionMarkSprite
          if LSS_spriteIndex = 1 then goto LoadCPUSprite
          if LSS_spriteIndex = 2 then goto LoadNoSprite
          rem Invalid sprite index, default to question mark
          goto LoadQuestionMarkSprite
          
LoadQuestionMarkSprite
          dim LQMS_playerNumber = temp3
          rem Set pointer to QuestionMarkSprite data
          rem Use skip-over pattern to avoid complex compound statements
          if !LQMS_playerNumber then LoadQuestionMarkSpriteP0
          if LQMS_playerNumber = 1 then LoadQuestionMarkSpriteP1
          if LQMS_playerNumber = 2 then goto LoadQuestionMarkSpriteP2
          goto LoadQuestionMarkSpriteP3
          
LoadQuestionMarkSpriteP0
          asm
            lda # <QuestionMarkSprite
            sta player0pointerlo
            lda # >QuestionMarkSprite
            sta player0pointerhi
end
          player0height = 16
          return
          
LoadQuestionMarkSpriteP1
          asm
            lda # <QuestionMarkSprite
            sta player1pointerlo
            lda # >QuestionMarkSprite
            sta player1pointerhi
end
          player1height = 16
          return
          
LoadQuestionMarkSpriteP2
          asm
            lda # <QuestionMarkSprite
            sta player2pointerlo
            lda # >QuestionMarkSprite
            sta player2pointerhi
end
          player2height = 16
          return
          
LoadQuestionMarkSpriteP3
          asm
            lda # <QuestionMarkSprite
            sta player3pointerlo
            lda # >QuestionMarkSprite
            sta player3pointerhi
end
          player3height = 16
          return
          
LoadCPUSprite
          dim LCS2_playerNumber = temp3
          rem Set pointer to CPUSprite data
          rem Use skip-over pattern to avoid complex compound statements
          if !LCS2_playerNumber then LoadCPUSpriteP0
          if LCS2_playerNumber = 1 then LoadCPUSpriteP1
          if LCS2_playerNumber = 2 then goto LoadCPUSpriteP2
          goto LoadCPUSpriteP3
          
LoadCPUSpriteP0
          asm
            lda # <CPUSprite
            sta player0pointerlo
            lda # >CPUSprite
            sta player0pointerhi
end
          player0height = 16
          return
          
LoadCPUSpriteP1
          asm
            lda # <CPUSprite
            sta player1pointerlo
            lda # >CPUSprite
            sta player1pointerhi
end
          player1height = 16
          return
          
LoadCPUSpriteP2
          asm
            lda # <CPUSprite
            sta player2pointerlo
            lda # >CPUSprite
            sta player2pointerhi
end
          player2height = 16
          return
          
LoadCPUSpriteP3
          asm
            lda # <CPUSprite
            sta player3pointerlo
            lda # >CPUSprite
            sta player3pointerhi
end
          player3height = 16
          return
          
LoadNoSprite
          dim LNS_playerNumber = temp3
          rem Set pointer to NoSprite data
          rem Use skip-over pattern to avoid complex compound statements
          if !LNS_playerNumber then LoadNoSpriteP0
          if LNS_playerNumber = 1 then LoadNoSpriteP1
          if LNS_playerNumber = 2 then goto LoadNoSpriteP2
          goto LoadNoSpriteP3
          
LoadNoSpriteP0
          asm
            lda # <NoSprite
            sta player0pointerlo
            lda # >NoSprite
            sta player0pointerhi
end
          player0height = 16
          return
          
LoadNoSpriteP1
          asm
            lda # <NoSprite
            sta player1pointerlo
            lda # >NoSprite
            sta player1pointerhi
end
          player1height = 16
          return
          
LoadNoSpriteP2
          asm
            lda # <NoSprite
            sta player2pointerlo
            lda # >NoSprite
            sta player2pointerhi
end
          player2height = 16
          return
          
LoadNoSpriteP3
          asm
            lda # <NoSprite
            sta player3pointerlo
            lda # >NoSprite
            sta player3pointerhi
end
          player3height = 16
          return

          rem =================================================================
          rem LOAD PLAYER SPRITE (generic dispatcher)
          rem =================================================================
          rem Load sprite data for any player using character art system
          rem Input: temp1 = character index (from playerChar array) - may be unset, will get from player
          rem        temp2 = animation frame (0-7) from sprite 10fps counter
          rem        temp3 = animation action (0-15) from currentAnimationSeq
          rem        temp4 = player number (0-3)
          rem Note: Frame is relative to sprite own 10fps counter, NOT global frame counter
LoadPlayerSprite
          dim LPS_playerNumber = temp4
          dim LPS_characterIndex = temp1
          rem Get character index for this player from playerChar array
          rem Use skip-over pattern to avoid complex compound statements
          if !LPS_playerNumber then LoadPlayerSpriteP0
          if LPS_playerNumber = 1 then LoadPlayerSpriteP1
          if LPS_playerNumber = 2 then LoadPlayerSpriteP2
          if LPS_playerNumber = 3 then LoadPlayerSpriteP3
          return
          
LoadPlayerSpriteP0
          let LPS_characterIndex = playerChar[0]
          goto LoadPlayerSpriteDispatch
          
LoadPlayerSpriteP1
          let LPS_characterIndex = playerChar[1]
          goto LoadPlayerSpriteDispatch
          
LoadPlayerSpriteP2
          let LPS_characterIndex = playerChar[2]
          goto LoadPlayerSpriteDispatch
          
LoadPlayerSpriteP3
          let LPS_characterIndex = playerChar[3]
          goto LoadPlayerSpriteDispatch
          
LoadPlayerSpriteDispatch
          dim LPSD_characterIndex = temp1
          dim LPSD_animationFrame = temp2
          dim LPSD_animationAction = temp3
          dim LPSD_playerNumber = temp4
          rem characterIndex = character index, animationFrame = frame (10fps counter), animationAction = action, playerNumber = player
          rem Call character art location system (in bank10)
          rem LocateCharacterArt expects: temp1=char, temp2=frame, temp3=action, temp4=player
          rem temp variables are already set by LoadPlayerSpriteP0-P3
          rem Just ensure temp1 is set from LPS_characterIndex
          let temp1 = LPS_characterIndex
          gosub bank10 LocateCharacterArt
          return

          rem =================================================================
          rem LOAD PLAYER SPRITES (legacy player-specific functions)
          rem =================================================================
          rem Load sprite data into specific player registers
          rem These functions contain the actual player graphics commands
          
LoadPlayer0Sprite
          dim LP0S_playerNumber = temp3
          rem Use art location system for player 0 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          rem playerNumber = player number (0)
          let LP0S_playerNumber = 0
          let temp3 = LP0S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          gosub LoadCharacterSprite
          return
          
LoadPlayer1Sprite
          dim LP1S_playerNumber = temp3
          rem Use art location system for player 1 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          rem playerNumber = player number (1)
          let LP1S_playerNumber = 1
          let temp3 = LP1S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          gosub LoadCharacterSprite
          return
          
LoadPlayer2Sprite
          dim LP2S_playerNumber = temp3
          rem Use art location system for player 2 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          rem playerNumber = player number (2)
          let LP2S_playerNumber = 2
          let temp3 = LP2S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          gosub LoadCharacterSprite
          return
          
LoadPlayer3Sprite
          dim LP3S_playerNumber = temp3
          rem Use art location system for player 3 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          rem playerNumber = player number (3)
          let LP3S_playerNumber = 3
          let temp3 = LP3S_playerNumber
          rem Use LoadCharacterSprite which handles LocateCharacterArt
          gosub LoadCharacterSprite
          return


          rem Validate character index range
          rem Input: temp1 = character index to validate
          rem Output: temp5 = validation result (0=invalid, 1=valid)
ValidateCharacterIndex
          dim VCI_characterIndex = temp1
          dim VCI_isValid = temp5
          rem Check if character index is within valid range (0-MaxCharacter for current implementation)
          if VCI_characterIndex > MaxCharacter then InvalidCharacter
          let VCI_isValid = 1
          let temp5 = VCI_isValid
          return
InvalidCharacter
          
          rem Invalid character index
          let VCI_isValid = 0
          let temp5 = VCI_isValid
          return


          rem Load character/player color based on TV standard, B&W, hurt, and flashing states
          rem Input: temp1 = character index, temp2 = hurt (0/1), temp3 = player (0-3)
          rem        temp4 = flashing (0/1), temp5 = flashing mode (0=frame-based, 1=player-index)
          rem Output: Appropriate COLUPx updated
          rem Note: Players use solid colors only (no per-line coloring)
LoadCharacterColors
          dim LCC_characterIndex = temp1
          dim LCC_isHurt = temp2
          dim LCC_playerNumber = temp3
          dim LCC_isFlashing = temp4
          dim LCC_flashingMode = temp5
          dim LCC_color = temp6
          rem Highest priority: hurt state
          if LCC_isHurt then goto HurtColor

          rem Next priority: flashing state
          if LCC_isFlashing then FlashingColor

NormalColor
          dim NC_color = temp6
          dim NC_playerNumber = temp3
#ifdef TV_SECAM
          rem SECAM: always use player index colors (no luminance control)
          goto PlayerIndexColors
#else
          rem Determine effective B&W override locally; if enabled, use player colors
          if colorBWOverride then PlayerIndexColors

          rem NTSC/PAL: Character-specific colors would be used here when tables exist
          rem Placeholder: fall back to player index colors until character tables are wired
          goto PlayerIndexColors
#endif

FlashingColor
          dim FC_flashingMode = temp5
          rem Flashing mode selection
          let FC_flashingMode = LCC_flashingMode
          if !FC_flashingMode then PerLineFlashing
          goto PlayerIndexColors

PerLineFlashing
          dim PLF_color = temp6
          rem Frame-based flashing (not per-line - players use solid colors)
          rem Use alternating bright/dim player index colors by frame bit
          if frame & 8 then PlayerIndexColorsDim
          goto PlayerIndexColors

PlayerIndexColors
          dim PIC_color = temp6
          rem Solid player index colors (bright)
          if !LCC_playerNumber then let PIC_color = ColIndigo(14) : let temp6 = PIC_color : goto SetColor
          if LCC_playerNumber = 1 then let PIC_color = ColRed(14) : let temp6 = PIC_color : goto SetColor
          if LCC_playerNumber = 2 then let PIC_color = ColYellow(14) : let temp6 = PIC_color : goto SetColor
          let PIC_color = ColGreen(14)
          let temp6 = PIC_color
          goto SetColor

PlayerIndexColorsDim
          dim PICD_color = temp6
          rem Dimmed player index colors
          if !LCC_playerNumber then let PICD_color = ColIndigo(6) : let temp6 = PICD_color : goto SetColor
          if LCC_playerNumber = 1 then let PICD_color = ColRed(6) : let temp6 = PICD_color : goto SetColor
          if LCC_playerNumber = 2 then let PICD_color = ColYellow(6) : let temp6 = PICD_color : goto SetColor
          let PICD_color = ColGreen(6)
          let temp6 = PICD_color
          goto SetColor

HurtColor
          dim HC_color = temp6
#ifdef TV_SECAM
          rem SECAM hurt is always magenta
          let HC_color = ColMagenta(10)
          let temp6 = HC_color
          goto SetColor
#else
          rem Dimmed version of normal color: use dim player index color as fallback
          goto PlayerIndexColorsDim
#endif

SetColor
          dim SC_color = temp6
          dim SC_playerNumber = temp3
          rem Set color based on player index (multisprite kernel supports COLUP2/COLUP3)
          rem temp6 already contains the color from previous code paths
          let SC_color = temp6
          let SC_playerNumber = LCC_playerNumber
          if !SC_playerNumber then let COLUP0 = SC_color : return
          if SC_playerNumber = 1 then let _COLUP1 = SC_color : return
          if SC_playerNumber = 2 then let COLUP2 = SC_color : return
          let COLUP3 = SC_color
          return
