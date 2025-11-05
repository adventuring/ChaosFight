          rem ChaosFight - Source/Routines/DisplayWinScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem DISPLAY WIN SCREEN
          rem ==========================================================
          rem Displays winner screen with fixed playfield pattern and
          rem   1-3 characters
          rem Called from WinnerAnnouncement.bas per-frame loop.
          rem
          rem Layout:
          rem   - Fixed playfield pattern (podium/platform design)
          rem   - 1 player: Winner centered on podium
          rem   - 2 players: Winner centered, runner-up on left platform
          rem - 3+ players: Winner centered high, 2nd on left, 3rd on
          rem   right
          rem ==========================================================

DisplayWinScreen
          dim DWS_playersRemaining = temp1
          dim DWS_winnerIndex = temp2
          dim DWS_secondIndex = temp3
          dim DWS_thirdIndex = temp4
          dim DWS_winnerOrder = temp5
          dim DWS_secondOrder = temp6
          dim DWS_thirdOrder = temp7
          dim DWS_currentOrder = temp8
          dim DWS_bwMode = temp2
          
          rem Set admin screen layout (32×32 for character display)
          gosub bank8 SetAdminScreenLayout
          
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
          
          rem Load playfield colors based on B&W mode
          gosub DWS_GetBWMode
          if DWS_bwMode then DWS_LoadBWColors
          pfcolors WinnerScreenColorsColor
          goto DWS_LoadPlayfieldDone
DWS_LoadBWColors
          pfcolors WinnerScreenColorsBW
DWS_LoadPlayfieldDone
          
          rem Get players remaining count (SCRAM read)
          let DWS_playersRemaining = playersRemaining_R
          
          rem Get winner index (already set by FindWinner, SCRAM read)
          rem Read after DWS_GetBWMode to avoid temp2 conflict
          let DWS_winnerIndex = winnerPlayerIndex_R
          
          rem Calculate rankings from eliminationOrder
          rem Winner = not eliminated (already have winnerPlayerIndex)
          rem 2nd place = highest eliminationOrder (last eliminated)
          rem 3rd place = second highest eliminationOrder
          
          rem Find 2nd and 3rd place rankings
          let DWS_secondIndex = 255
          let DWS_thirdIndex = 255
          let DWS_secondOrder = 0
          let DWS_thirdOrder = 0
          
          rem Check all players for ranking
          let temp1 = 0
DWS_RankLoop
          rem Skip if this is the winner
          if temp1 = DWS_winnerIndex then DWS_RankNext
          
          rem Get this player's elimination order (SCRAM read)
          let DWS_currentOrder = eliminationOrder_R[temp1]
          
          rem Check if this is 2nd place (higher order than current 2nd)
          if DWS_currentOrder > DWS_secondOrder then DWS_UpdateSecond
          goto DWS_CheckThird
          
DWS_UpdateSecond
          rem Move current 2nd to 3rd, then update 2nd
          let DWS_thirdOrder = DWS_secondOrder
          let DWS_thirdIndex = DWS_secondIndex
          let DWS_secondOrder = DWS_currentOrder
          let DWS_secondIndex = temp1
          goto DWS_RankNext
          
DWS_CheckThird
          rem Check if this is 3rd place (higher order than current 3rd,
          rem   but lower than 2nd)
          if DWS_currentOrder > DWS_thirdOrder then let DWS_thirdOrder = DWS_currentOrder : let DWS_thirdIndex = temp1
          
DWS_RankNext
          let temp1 = temp1 + 1
          if temp1 < 4 then goto DWS_RankLoop
          
          rem Position characters based on playersRemaining
          rem 1 player: Winner centered (X=80, Y=row 24 = 192 pixels)
          rem 2 players: Winner centered (X=80), Runner-up left (X=40)
          rem 3+ players: Winner centered high (X=80, Y=row 16), 2nd
          rem   left (X=40), 3rd right (X=120)
          
          rem Position winner (always centered)
          if DWS_playersRemaining = 1 then DWS_Position1Player
          if DWS_playersRemaining = 2 then DWS_Position2Players
          goto DWS_Position3Players
          
DWS_Position1Player
          rem 1 player: Winner centered on podium
          let playerX[0] = 80
          let playerY[0] = 192
          rem Load winner sprite
          let temp1 = playerChar[DWS_winnerIndex]
          let temp2 = 0
          rem Animation frame 0 (idle)
          let temp3 = 0
          rem Player 0
          gosub bank10 LoadCharacterSprite
          rem Hide other players
          let playerX[1] = 0
          let playerX[2] = 0
          let playerX[3] = 0
          return
          
DWS_Position2Players
          rem 2 players: Winner centered, runner-up left
          rem Winner (P0)
          let playerX[0] = 80
          let playerY[0] = 192
          let temp1 = playerChar[DWS_winnerIndex]
          let temp2 = 0
          let temp3 = 0
          gosub bank10 LoadCharacterSprite
          
          rem Runner-up (P1) - only if valid
          if DWS_secondIndex = 255 then DWS_Hide2Player
          let playerX[1] = 40
          let playerY[1] = 192
          let temp1 = playerChar[DWS_secondIndex]
          let temp2 = 0
          let temp3 = 1
          gosub bank10 LoadCharacterSprite
          goto DWS_Hide2PlayerDone
DWS_Hide2Player
          let playerX[1] = 0
DWS_Hide2PlayerDone
          rem Hide unused players
          let playerX[2] = 0
          let playerX[3] = 0
          return
          
DWS_Position3Players
          rem 3+ players: Winner centered high, 2nd left, 3rd right
          rem Winner (P0) - higher platform
          let playerX[0] = 80
          let playerY[0] = 128
          rem Row 16 = 128 pixels (16 * 8)
          let temp1 = playerChar[DWS_winnerIndex]
          let temp2 = 0
          let temp3 = 0
          gosub bank10 LoadCharacterSprite
          
          rem 2nd place (P1) - left platform
          if DWS_secondIndex = 255 then DWS_Hide3Player2
          let playerX[1] = 40
          let playerY[1] = 192
          let temp1 = playerChar[DWS_secondIndex]
          let temp2 = 0
          let temp3 = 1
          gosub bank10 LoadCharacterSprite
          goto DWS_Hide3Player2Done
DWS_Hide3Player2
          let playerX[1] = 0
DWS_Hide3Player2Done
          
          rem 3rd place (P2) - right platform
          if DWS_thirdIndex = 255 then DWS_Hide3Player3
          let playerX[2] = 120
          let playerY[2] = 192
          let temp1 = playerChar[DWS_thirdIndex]
          let temp2 = 0
          let temp3 = 2
          gosub bank10 LoadCharacterSprite
          goto DWS_Hide3Player3Done
DWS_Hide3Player3
          let playerX[2] = 0
DWS_Hide3Player3Done
          rem Hide unused player
          let playerX[3] = 0
          return
          
DWS_GetBWMode
          rem Check if B&W mode is active
          rem switchbw=1 means B&W mode, systemFlags bit 6 (ColorBWOverride) can force B&W
          rem Uses temp2 for DWS_bwMode (DWS_winnerIndex saved by
          rem   caller)
          let temp2 = 0
          if switchbw then let temp2 = 1
          if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          let DWS_bwMode = temp2
          return

