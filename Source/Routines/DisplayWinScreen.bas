DisplayWinScreen
          rem
          rem ChaosFight - Source/Routines/DisplayWinScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Display Win Screen
          rem
          rem Displays winner screen with fixed playfield pattern and
          rem   1-3 characters
          rem Called from WinnerAnnouncement.bas per-frame loop.
          rem Layout:
          rem   - Fixed playfield pattern (podium/platform design)
          rem   - 1 player: Winner centered on podium
          rem   - 2 players: Winner centered, runner-up on left platform
          rem - 3+ players: Winner centered high, 2nd on left, 3rd on
          rem   right
          rem Displays winner screen with fixed playfield pattern and
          rem 1-3 characters
          rem
          rem Input: playersRemaining_R (global SCRAM) = number of
          rem players remaining
          rem        winnerPlayerIndex_R (global SCRAM) = winner player
          rem        index
          rem        eliminationOrder_R[] (global SCRAM array) =
          rem        elimination order for each player
          rem        playerChar[] (global array) = player character
          rem        selections
          rem        switchbw (hardware) = Color/B&W switch state
          rem        systemFlags (global) = system flags
          rem        (SystemFlagColorBWOverride)
          rem        WinnerScreenPlayfield (ROM constant) = playfield
          rem        pattern data
          rem        WinnerScreenColorsBW, WinnerScreenColorsColor (ROM
          rem        constants) = color tables
          rem
          rem Output: Screen layout set, playfield pattern loaded,
          rem colors loaded, player sprites positioned and loaded
          rem
          rem Mutates: pfrowheight, pfrows (set via
          rem SetAdminScreenLayout),
          rem         PF1pointer, PF2pointer (playfield pointers, set
          rem         via inline assembly),
          rem         pfcolortable (playfield color table pointer, set
          rem         via DWS_LoadBWColors/ColorColors),
          rem         playerX[0-3], playerY[0-3] (TIA registers), player
          rem         sprite pointers (via LoadCharacterSprite),
          rem         temp1-temp8 (used for ranking calculations),
          rem         DWS_bwMode
          rem
          rem Called Routines: SetAdminScreenLayout (bank8) - sets
          rem screen layout,
          rem   DWS_GetBWMode - accesses switchbw, systemFlags,
          rem   DWS_LoadBWColors, DWS_LoadColorColors - set color table
          rem   pointers,
          rem   LoadCharacterSprite (bank10) - loads character sprites
          rem
          rem Constraints: Must be colocated with DWS_RankLoop,
          rem DWS_UpdateSecond, DWS_CheckThird,
          rem              DWS_RankNext, DWS_Position1Player,
          rem              DWS_Position2Players, DWS_Position3Players,
          rem              DWS_Hide2Player, DWS_Hide2PlayerDone,
          rem              DWS_Hide3Player2, DWS_Hide3Player2Done,
          rem              DWS_Hide3Player3, DWS_Hide3Player3Done,
          rem              DWS_GetBWMode, DWS_LoadBWColors,
          rem              DWS_LoadColorColors (all called via goto or
          rem              gosub)
          dim DWS_playersRemaining = temp1 : rem              Called from WinnerAnnouncement per-frame loop
          dim DWS_winnerIndex = temp2
          dim DWS_secondIndex = temp3
          dim DWS_thirdIndex = temp4
          dim DWS_winnerOrder = temp5
          dim DWS_secondOrder = temp6
          dim DWS_thirdOrder = temp7
          dim DWS_currentOrder = temp8
          dim DWS_bwMode = temp2
          
          gosub SetAdminScreenLayout bank8 : rem Set admin screen layout (32×32 for character display)
          
          rem Load winner screen playfield pattern
          rem Set playfield pointers to WinnerScreenPlayfield data
          asm
          lda #<WinnerScreenPlayfield
          sta PF1pointer
          lda #>WinnerScreenPlayfield
          sta PF1pointer+1
          lda #<WinnerScreenPlayfield
          sta PF2pointer
          lda #>WinnerScreenPlayfield
          sta PF2pointer+1
end
          
          gosub DWS_GetBWMode : rem Load playfield colors based on B&W mode
          if DWS_bwMode then gosub DWS_LoadBWColors else gosub DWS_LoadColorColors
          
          let DWS_playersRemaining = playersRemaining_R : rem Get players remaining count (SCRAM read)
          
          rem Get winner index (already set by FindWinner, SCRAM read)
          let DWS_winnerIndex = winnerPlayerIndex_R : rem Read after DWS_GetBWMode to avoid temp2 conflict
          
          rem Calculate rankings from eliminationOrder
          rem Winner = not eliminated (already have winnerPlayerIndex)
          rem 2nd place = highest eliminationOrder (last eliminated)
          rem 3rd place = second highest eliminationOrder
          
          let DWS_secondIndex = 255 : rem Find 2nd and 3rd place rankings
          let DWS_thirdIndex = 255
          let DWS_secondOrder = 0
          let DWS_thirdOrder = 0
          
          let temp1 = 0 : rem Check all players for ranking
DWS_RankLoop
          rem Ranking loop - check all players for 2nd and 3rd place
          rem
          rem Input: temp1 (player index), DWS_winnerIndex,
          rem DWS_secondIndex, DWS_secondOrder,
          rem        DWS_thirdIndex, DWS_thirdOrder (from
          rem        DisplayWinScreen)
          rem        eliminationOrder_R[] (global SCRAM array) =
          rem        elimination order
          rem
          rem Output: DWS_secondIndex, DWS_thirdIndex, DWS_secondOrder,
          rem DWS_thirdOrder updated
          rem
          rem Mutates: temp1 (incremented), DWS_secondIndex,
          rem DWS_thirdIndex, DWS_secondOrder, DWS_thirdOrder,
          rem         DWS_currentOrder
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_UpdateSecond, DWS_CheckThird, DWS_RankNext
          if temp1 = DWS_winnerIndex then DWS_RankNext : rem Skip if this is the winner
          
          let DWS_currentOrder = eliminationOrder_R[temp1] : rem Get this player’s elimination order (SCRAM read)
          
          if DWS_currentOrder > DWS_secondOrder then DWS_UpdateSecond : rem Check if this is 2nd place (higher order than current 2nd)
          goto DWS_CheckThird
          
DWS_UpdateSecond
          rem Move current 2nd to 3rd, then update 2nd
          rem
          rem Input: DWS_secondIndex, DWS_secondOrder, DWS_currentOrder,
          rem temp1 (from DWS_RankLoop)
          rem
          rem Output: DWS_thirdIndex, DWS_thirdOrder updated,
          rem DWS_secondIndex, DWS_secondOrder updated
          rem
          rem Mutates: DWS_thirdIndex, DWS_thirdOrder, DWS_secondIndex,
          rem DWS_secondOrder
          rem
          rem Called Routines: None
          let DWS_thirdOrder = DWS_secondOrder : rem Constraints: Must be colocated with DisplayWinScreen, DWS_RankLoop
          let DWS_thirdIndex = DWS_secondIndex
          let DWS_secondOrder = DWS_currentOrder
          let DWS_secondIndex = temp1
          goto DWS_RankNext
          
DWS_CheckThird
          rem Check if this is 3rd place (higher order than current 3rd,
          rem but lower than 2nd)
          rem
          rem Input: DWS_currentOrder, DWS_thirdOrder, temp1 (from
          rem DWS_RankLoop)
          rem
          rem Output: DWS_thirdIndex, DWS_thirdOrder updated if higher
          rem
          rem Mutates: DWS_thirdIndex, DWS_thirdOrder
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_RankLoop, DWS_RankNext
          if DWS_currentOrder > DWS_thirdOrder then let DWS_thirdOrder = DWS_currentOrder : let DWS_thirdIndex = temp1
          
DWS_RankNext
          rem Ranking loop continuation
          rem
          rem Input: temp1 (player index, from DWS_RankLoop)
          rem
          rem Output: temp1 incremented, loops back to DWS_RankLoop if <
          rem 4
          rem
          rem Mutates: temp1 (incremented)
          rem
          rem Called Routines: None
          let temp1 = temp1 + 1 : rem Constraints: Must be colocated with DisplayWinScreen, DWS_RankLoop
          if temp1 < 4 then goto DWS_RankLoop
          
          rem Position characters based on playersRemaining
          rem 1 player: Winner centered (X=80, Y=row 24 = 192 pixels)
          rem 2 players: Winner centered (X=80), Runner-up left (X=40)
          rem 3+ players: Winner centered high (X=80, Y=row 16), 2nd
          rem   left (X=40), 3rd right (X=120)
          
          if DWS_playersRemaining = 1 then DWS_Position1Player : rem Position winner (always centered)
          if DWS_playersRemaining = 2 then DWS_Position2Players
          goto DWS_Position3Players
          
DWS_Position1Player
          rem 1 player: Winner centered on podium
          rem
          rem Input: DWS_winnerIndex, playerChar[] (from
          rem DisplayWinScreen)
          rem
          rem Output: playerX[0], playerY[0] set, winner sprite loaded,
          rem other players hidden
          rem
          rem Mutates: playerX[0-3], playerY[0] (TIA registers), player
          rem sprite pointers (via LoadCharacterSprite),
          rem         currentCharacter, LCS_animationFrame,
          rem         LCS_playerNumber (passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite (bank10) - loads
          rem character sprite
          let playerX[0] = 80 : rem Constraints: Must be colocated with DisplayWinScreen
          let playerY[0] = 192
          let currentCharacter = playerChar[DWS_winnerIndex] : rem Load winner sprite
          let LCS_animationFrame = 0
          let LCS_playerNumber = 0 : rem Animation frame 0 (idle)
          gosub LoadCharacterSprite bank10 : rem Player 0
          let playerX[1] = 0 : rem Hide other players
          let playerX[2] = 0
          let playerX[3] = 0
          return
          
DWS_Position2Players
          rem 2 players: Winner centered, runner-up left
          rem
          rem Input: DWS_winnerIndex, DWS_secondIndex, playerChar[]
          rem (from DisplayWinScreen)
          rem
          rem Output: playerX[0-1], playerY[0-1] set, winner and
          rem runner-up sprites loaded, other players hidden
          rem
          rem Mutates: playerX[0-3], playerY[0-1] (TIA registers),
          rem player sprite pointers (via LoadCharacterSprite),
          rem         currentCharacter, LCS_animationFrame,
          rem         LCS_playerNumber (passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite (bank10) - loads
          rem character sprites
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_Hide2Player, DWS_Hide2PlayerDone
          let playerX[0] = 80 : rem Winner (P0)
          let playerY[0] = 192
          let currentCharacter = playerChar[DWS_winnerIndex]
          let LCS_animationFrame = 0
          let LCS_playerNumber = 0
          gosub LoadCharacterSprite bank10
          
          if DWS_secondIndex = 255 then DWS_Hide2Player : rem Runner-up (P1) - only if valid
          let playerX[1] = 40
          let playerY[1] = 192
          let currentCharacter = playerChar[DWS_secondIndex]
          let LCS_animationFrame = 0
          let LCS_playerNumber = 1
          gosub LoadCharacterSprite bank10
          goto DWS_Hide2PlayerDone
DWS_Hide2Player
          rem Hide Player 2 (no runner-up)
          rem
          rem Input: None (called from DWS_Position2Players)
          rem
          rem Output: playerX[1] set to 0
          rem
          rem Mutates: playerX[1] (TIA register)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_Position2Players, DWS_Hide2PlayerDone
          let playerX[1] = 0
DWS_Hide2PlayerDone
          rem Hide Player 2 complete (label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen
          let playerX[2] = 0 : rem Hide unused players
          let playerX[3] = 0
          return
          
DWS_Position3Players
          rem 3+ players: Winner centered high, 2nd left, 3rd right
          rem
          rem Input: DWS_winnerIndex, DWS_secondIndex, DWS_thirdIndex,
          rem playerChar[] (from DisplayWinScreen)
          rem
          rem Output: playerX[0-2], playerY[0-2] set, winner/2nd/3rd
          rem sprites loaded, player 4 hidden
          rem
          rem Mutates: playerX[0-3], playerY[0-2] (TIA registers),
          rem player sprite pointers (via LoadCharacterSprite),
          rem         currentCharacter, LCS_animationFrame,
          rem         LCS_playerNumber (passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite (bank10) - loads
          rem character sprites
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_Hide3Player2, DWS_Hide3Player2Done,
          rem              DWS_Hide3Player3, DWS_Hide3Player3Done
          let playerX[0] = 80 : rem Winner (P0) - higher platform
          let playerY[0] = 128
          rem Row 16 = 128 pixels (16 * 8)
          let currentCharacter = playerChar[DWS_winnerIndex]
          let LCS_animationFrame = 0
          let LCS_playerNumber = 0
          gosub LoadCharacterSprite bank10
          
          if DWS_secondIndex = 255 then DWS_Hide3Player2 : rem 2nd place (P1) - left platform
          let playerX[1] = 40
          let playerY[1] = 192
          let currentCharacter = playerChar[DWS_secondIndex]
          let LCS_animationFrame = 0
          let LCS_playerNumber = 1
          gosub LoadCharacterSprite bank10
          goto DWS_Hide3Player2Done
DWS_Hide3Player2
          rem Hide Player 2 (no 2nd place)
          rem
          rem Input: None (called from DWS_Position3Players)
          rem
          rem Output: playerX[1] set to 0
          rem
          rem Mutates: playerX[1] (TIA register)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_Position3Players, DWS_Hide3Player2Done
          let playerX[1] = 0
DWS_Hide3Player2Done
          rem Hide Player 2 complete (label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen
          
          if DWS_thirdIndex = 255 then DWS_Hide3Player3 : rem 3rd place (P2) - right platform
          let playerX[2] = 120
          let playerY[2] = 192
          let currentCharacter = playerChar[DWS_thirdIndex]
          let LCS_animationFrame = 0
          let LCS_playerNumber = 2
          gosub LoadCharacterSprite bank10
          goto DWS_Hide3Player3Done
DWS_Hide3Player3
          rem Hide Player 3 (no 3rd place)
          rem
          rem Input: None (called from DWS_Position3Players)
          rem
          rem Output: playerX[2] set to 0
          rem
          rem Mutates: playerX[2] (TIA register)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_Position3Players, DWS_Hide3Player3Done
          let playerX[2] = 0
DWS_Hide3Player3Done
          rem Hide Player 3 complete (label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen
          let playerX[3] = 0 : rem Hide unused player
          return
          
DWS_GetBWMode
          rem Check if B&W mode is active
          rem
          rem Input: switchbw (hardware) = Color/B&W switch state
          rem        systemFlags (global) = system flags
          rem        (SystemFlagColorBWOverride)
          rem
          rem Output: DWS_bwMode set to 1 if B&W mode, 0 otherwise
          rem
          rem Mutates: temp2 (used for B&W mode check), DWS_bwMode
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen
          rem   (ColorBWOverride) can force B&W
          rem switchbw=1 means B&W mode, systemFlags bit 6
          rem Uses temp2 for DWS_bwMode (DWS_winnerIndex saved by
          let temp2 = 0 : rem   caller)
          if switchbw then let temp2 = 1
          if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          let DWS_bwMode = temp2
          return

DWS_LoadBWColors
          asm
          rem Load B&W colors (all white)
          rem
          rem Input: WinnerScreenColorsBW (ROM constant) = B&W color
          rem table
          rem
          rem Output: pfcolortable pointer set to WinnerScreenColorsBW
          rem
          rem Mutates: pfcolortable (playfield color table pointer, set
          rem via inline assembly)
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with DisplayWinScreen
          rem Set pfcolortable pointer to WinnerScreenColorsBW
            lda #<WinnerScreenColorsBW
            sta pfcolortable
            lda #>WinnerScreenColorsBW
            sta pfcolortable+1
end
          return

DWS_LoadColorColors
          asm
          rem Load color colors (gold gradient)
          rem
          rem Input: WinnerScreenColorsColor (ROM constant) = color
          rem table
          rem
          rem Output: pfcolortable pointer set to
          rem WinnerScreenColorsColor
          rem
          rem Mutates: pfcolortable (playfield color table pointer, set
          rem via inline assembly)
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with DisplayWinScreen
          rem Set pfcolortable pointer to WinnerScreenColorsColor
            lda #<WinnerScreenColorsColor
            sta pfcolortable
            lda #>WinnerScreenColorsColor
            sta pfcolortable+1
end
          return

