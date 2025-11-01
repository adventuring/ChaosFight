          rem ChaosFight - Source/Routines/SpriteLoader.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.


          rem MULTI-BANK SPRITE LOADING SYSTEM

          rem Loads character sprite data and colors from multiple banks
          rem Supports up to 32 characters (0-31) across 4 banks
          rem Current implementation: 16 characters (0-15) in 2 banks
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
          rem Validate character index
          gosub ValidateCharacterIndex
          rem tail call
          if ! temp5 then goto LoadSpecialSprite
          
          rem Check if character is special placeholder
          if temp1 = 255 then let temp6 = SpriteNo : gosub LoadSpecialSprite : return 
          rem NoCharacter = 255
          
          if temp1 = 254 then let temp6 = SpriteCPU : gosub LoadSpecialSprite : return 
          rem CPUCharacter = 254
          
          rem Use character art location system for sprite loading
          rem Input: temp1 = character index, temp2 = animation frame, temp3 = player number
          rem Default to animation sequence 0 and frame 0 for basic loading
          let temp2 = 0 
          rem Animation frame (0=idle)
          let temp8 = 0 
          rem Animation sequence (0=default)
          let temp7 = temp3 
          rem Player number for art system
          
          rem Use assembly routine to locate and set character art
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayerCharacterArt are implemented
          rem For now, use placeholder sprite data
          let temp4 = temp1
          rem Store character index for later use
          
          return

          rem =================================================================
          rem LOAD SPECIAL SPRITE
          rem =================================================================
          rem Loads special placeholder sprites (QuestionMark, CPU, No)
          rem Input: temp6 = sprite index (SpriteQuestionMark=0, SpriteCPU=1, SpriteNo=2)
          rem        temp3 = player number (0-3)
          rem Output: Appropriate player sprite pointer set to special sprite data
LoadSpecialSprite
          rem Set sprite pointer based on sprite index
          if ! temp6 then goto LoadQuestionMarkSprite
          if temp6 = 1 then goto LoadCPUSprite
          if temp6 = 2 then goto LoadNoSprite
          rem Invalid sprite index, default to question mark
          goto LoadQuestionMarkSprite
          
LoadQuestionMarkSprite
          rem Set pointer to QuestionMarkSprite data
          if ! temp3 then player0pointerlo = <QuestionMarkSprite : player0pointerhi = >QuestionMarkSprite : player0height = 16 : return
          if temp3 = 1 then player1pointerlo = <QuestionMarkSprite : player1pointerhi = >QuestionMarkSprite : player1height = 16 : return
          if temp3 = 2 then player2pointerlo = <QuestionMarkSprite : player2pointerhi = >QuestionMarkSprite : player2height = 16 : return
          player3pointerlo = <QuestionMarkSprite : player3pointerhi = >QuestionMarkSprite : player3height = 16 : return
          
LoadCPUSprite
          rem Set pointer to CPUSprite data
          if ! temp3 then player0pointerlo = <CPUSprite : player0pointerhi = >CPUSprite : player0height = 16 : return
          if temp3 = 1 then player1pointerlo = <CPUSprite : player1pointerhi = >CPUSprite : player1height = 16 : return
          if temp3 = 2 then player2pointerlo = <CPUSprite : player2pointerhi = >CPUSprite : player2height = 16 : return
          player3pointerlo = <CPUSprite : player3pointerhi = >CPUSprite : player3height = 16 : return
          
LoadNoSprite
          rem Set pointer to NoSprite data
          if ! temp3 then player0pointerlo = <NoSprite : player0pointerhi = >NoSprite : player0height = 16 : return
          if temp3 = 1 then player1pointerlo = <NoSprite : player1pointerhi = >NoSprite : player1height = 16 : return
          if temp3 = 2 then player2pointerlo = <NoSprite : player2pointerhi = >NoSprite : player2height = 16 : return
          player3pointerlo = <NoSprite : player3pointerhi = >NoSprite : player3height = 16 : return

          rem =================================================================
          rem LOAD PLAYER SPRITES
          rem =================================================================
          rem Load sprite data into specific player registers
          rem These functions contain the actual player graphics commands
          
LoadPlayer0Sprite
          rem Use art location system for player 0 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          let temp3 = 0 
          rem Player 0
          let temp7 = temp3 
          rem Player number for art system
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer0CharacterArt are implemented
          rem For now, use placeholder sprite data
          let temp4 = temp1
          rem Store character index for later use
          return
          
LoadPlayer1Sprite
          rem Use art location system for player 1 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          let temp3 = 1 
          rem Player 1
          let temp7 = temp3 
          rem Player number for art system
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer1CharacterArt are implemented
          rem For now, use placeholder sprite data
          let temp4 = temp1
          rem Store character index for later use
          return
          
LoadPlayer2Sprite
          rem Use art location system for player 2 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          let temp3 = 2 
          rem Player 2
          let temp7 = temp3 
          rem Player number for art system
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer2CharacterArt are implemented
          rem For now, use placeholder sprite data
          let temp4 = temp1
          rem Store character index for later use
          return
          
LoadPlayer3Sprite
          rem Use art location system for player 3 sprite loading
          rem temp1 = character index, temp2 = animation frame already set
          let temp3 = 3 
          rem Player 3
          let temp7 = temp3 
          rem Player number for art system
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer3CharacterArt are implemented
          rem For now, use placeholder sprite data
          let temp4 = temp1
          rem Store character index for later use
          return


          rem Validate character index range
          rem Input: temp1 = character index to validate
          rem Output: temp5 = validation result (0=invalid, 1=valid)
ValidateCharacterIndex
          rem Check if character index is within valid range (0-15 for current implementation)
          if temp1 > 15 then goto InvalidCharacter
          let temp5 = 1 : return
InvalidCharacter
          
          rem Invalid character index
          let temp5 = 0
          return


          rem Load character/player color based on TV standard, B&W, hurt, and flashing states
          rem Input: temp1 = character index, temp2 = hurt (0/1), temp3 = player (0-3)
          rem        temp4 = flashing (0/1), temp5 = flashing mode (0=per-line, 1=player-index)
          rem Output: Appropriate COLUPx updated
LoadCharacterColors
          rem Highest priority: hurt state
          if temp2 then goto HurtColor

          rem Next priority: flashing state
          if temp4 then goto FlashingColor

NormalColor
#ifdef TV_SECAM
          rem SECAM: always use player index colors (no luminance control)
          goto PlayerIndexColors
#else
          rem Determine effective B&W override locally; if enabled, use player colors
          if ColorBWOverride then goto PlayerIndexColors

          rem NTSC/PAL: Character-specific colors would be used here when tables exist
          rem Placeholder: fall back to player index colors until character tables are wired
          goto PlayerIndexColors
#endif

FlashingColor
          rem Flashing mode selection
          if ! temp5 then goto PerLineFlashing
          goto PlayerIndexColors

PerLineFlashing
          rem Simple time/row-based flashing placeholder
          rem Use alternating bright/dim player index colors by frame bit
          if frame & 8 then goto PlayerIndexColorsDim
          goto PlayerIndexColors

PlayerIndexColors
          rem Solid player index colors (bright)
          if ! temp3 then LET temp6 = ColIndigo(14) : goto SetColor
          if temp3 = 1 then LET temp6 = ColRed(14) : goto SetColor
          if temp3 = 2 then LET temp6 = ColYellow(14) : goto SetColor
          let temp6 = ColGreen(14)

          goto SetColor

PlayerIndexColorsDim
          rem Dimmed player index colors
          if ! temp3 then LET temp6 = ColIndigo(6) : goto SetColor
          if temp3 = 1 then LET temp6 = ColRed(6) : goto SetColor
          if temp3 = 2 then LET temp6 = ColYellow(6) : goto SetColor
          let temp6 = ColGreen(6)

          goto SetColor

HurtColor
#ifdef TV_SECAM
          rem SECAM hurt is always magenta
          let temp6 = ColMagenta(10)
          goto SetColor
#else
          rem Dimmed version of normal color: use dim player index color as fallback
          goto PlayerIndexColorsDim
#endif

SetColor
          rem Set color based on player index (multisprite kernel supports COLUP2/COLUP3)
          if ! temp3 then COLUP0 = temp6 : return
          if temp3 = 1 then COLUP1 = temp6 : return
          if temp3 = 2 then COLUP2 = temp6 : return
          COLUP3 = temp6 : return


          if frame & 8 then goto PlayerIndexColorsDim
          goto PlayerIndexColors

PlayerIndexColors
          rem Solid player index colors (bright)
          if ! temp3 then LET temp6 = ColIndigo(14) : goto SetColor
          if temp3 = 1 then LET temp6 = ColRed(14) : goto SetColor
          if temp3 = 2 then LET temp6 = ColYellow(14) : goto SetColor
          let temp6 = ColGreen(14)

          goto SetColor

PlayerIndexColorsDim
          rem Dimmed player index colors
          if ! temp3 then LET temp6 = ColIndigo(6) : goto SetColor
          if temp3 = 1 then LET temp6 = ColRed(6) : goto SetColor
          if temp3 = 2 then LET temp6 = ColYellow(6) : goto SetColor
          let temp6 = ColGreen(6)

          goto SetColor

HurtColor
#ifdef TV_SECAM
          rem SECAM hurt is always magenta
          let temp6 = ColMagenta(10)
          goto SetColor
#else
          rem Dimmed version of normal color: use dim player index color as fallback
          goto PlayerIndexColorsDim
#endif

SetColor
          rem Set color based on player index (multisprite kernel supports COLUP2/COLUP3)
          if ! temp3 then COLUP0 = temp6 : return
          if temp3 = 1 then COLUP1 = temp6 : return
          if temp3 = 2 then COLUP2 = temp6 : return
          COLUP3 = temp6 : return

