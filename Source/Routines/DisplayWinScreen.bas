DisplayWinScreen
          rem
          rem ChaosFight - Source/Routines/DisplayWinScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Display Win Screen
          rem
          rem Displays the winner screen with fixed playfield pattern and up to three characters.
          rem Called from WinnerAnnouncement.bas per-frame loop. Layout:
          rem   - Fixed playfield pattern (podium/platform design)
          rem   - 1 player: Winner centered on podium
          rem   - 2 players: Winner centered, runner-up on left platform
          rem - 3+ players: Winner centered high, 2nd on left, 3rd on right
          rem
          rem Input: playersRemaining_R (global SCRAM) = number of
          rem players remaining
          rem        winnerPlayerIndex_R (global SCRAM) = winner player
          rem        index
          rem        eliminationOrder_R[] (global SCRAM array) =
          rem        elimination order for each player
          rem        playerCharacter[] (global array) = player character
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
          rem         temp1-temp6 plus SCRAM scratch (used for ranking calculations),
          rem         temp2
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
          rem Called from WinnerAnnouncement per-frame loop
          
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
          if temp2 then gosub DWS_LoadBWColors else gosub DWS_LoadColorColors
          
          let temp1 = playersRemaining_R : rem Get players remaining count (SCRAM read)
          
          rem Get winner index (already set by FindWinner, SCRAM read)
          let temp2 = winnerPlayerIndex_R : rem Read after DWS_GetBWMode to avoid temp2 conflict
          
          rem Calculate rankings from eliminationOrder
          rem Winner = not eliminated (already have winnerPlayerIndex)
          rem 2nd place = highest eliminationOrder (last eliminated)
          rem 3rd place = second highest eliminationOrder
          
          let temp3 = 255 : rem Find 2nd and 3rd place rankings
          let temp4 = 255
          let temp5 = 0
          let w095 = 0
          
          let temp1 = 0 : rem Check all players for ranking
DWS_RankLoop
          rem Ranking loop - check all players for 2nd and 3rd place
          rem
          rem Input: temp1 (player index), temp2,
          rem temp3, temp5,
          rem        temp4, r095 (from
          rem        DisplayWinScreen)
          rem        eliminationOrder_R[] (global SCRAM array) =
          rem        elimination order
          rem
          rem Output: temp3, temp4, temp5,
          rem w095 updated
          rem
          rem Mutates: temp1 (incremented), temp3,
          rem temp4, temp5, w095,
          rem         w094
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_UpdateSecond, DWS_CheckThird, DWS_RankNext
          if temp1 = temp2 then DWS_RankNext : rem Skip if this is the winner
          
          let w094 = eliminationOrder_R[temp1] : rem Get this player’s elimination order (SCRAM read)
          
          if r094 > temp5 then DWS_UpdateSecond : rem Check if this is 2nd place (higher order than current 2nd)
          goto DWS_CheckThird
          
DWS_UpdateSecond
          rem Move current 2nd to 3rd, then update 2nd
          rem
          rem Input: temp3, temp5, r094,
          rem temp1 (from DWS_RankLoop)
          rem
          rem Output: temp4, w095 updated,
          rem temp3, temp5 updated
          rem
          rem Mutates: temp4, w095, temp3,
          rem temp5
          rem
          rem Called Routines: None
          let w095 = temp5 : rem Constraints: Must be colocated with DisplayWinScreen, DWS_RankLoop
          let temp4 = temp3
          let temp5 = r094
          let temp3 = temp1
          goto DWS_RankNext
          
DWS_CheckThird
          rem Check if this is 3rd place (higher order than current 3rd,
          rem but lower than 2nd)
          rem
          rem Input: r094, r095, temp1 (from
          rem DWS_RankLoop)
          rem
          rem Output: temp4, w095 updated if higher
          rem
          rem Mutates: temp4, w095
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_RankLoop, DWS_RankNext
          if r094 > r095 then let w095 = r094 : let temp4 = temp1
          
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
          
          if temp1 = 1 then DWS_Position1Player : rem Position winner (always centered)
          if temp1 = 2 then DWS_Position2Players
          goto DWS_Position3Players
          
DWS_Position1Player
          rem 1 player: Winner centered on podium
          rem
          rem Input: temp2, playerCharacter[] (from
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
          let currentCharacter = playerCharacter[temp2] : rem Load winner sprite
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
          rem Input: temp2, temp3, playerCharacter[]
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
          let currentCharacter = playerCharacter[temp2]
          let LCS_animationFrame = 0
          let LCS_playerNumber = 0
          gosub LoadCharacterSprite bank10
          
          if temp3 = 255 then DWS_Hide2Player : rem Runner-up (P1) - only if valid
          let playerX[1] = 40
          let playerY[1] = 192
          let currentCharacter = playerCharacter[temp3]
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
          rem Input: temp2, temp3, temp4,
          rem playerCharacter[] (from DisplayWinScreen)
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
          let currentCharacter = playerCharacter[temp2]
          let LCS_animationFrame = 0
          let LCS_playerNumber = 0
          gosub LoadCharacterSprite bank10
          
          if temp3 = 255 then DWS_Hide3Player2 : rem 2nd place (P1) - left platform
          let playerX[1] = 40
          let playerY[1] = 192
          let currentCharacter = playerCharacter[temp3]
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
          
          if temp4 = 255 then DWS_Hide3Player3 : rem 3rd place (P2) - right platform
          let playerX[2] = 120
          let playerY[2] = 192
          let currentCharacter = playerCharacter[temp4]
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
          rem Output: temp2 set to 1 if B&W mode, 0 otherwise
          rem
          rem Mutates: temp2 (used for B&W mode check), temp2
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen
          rem   (ColorBWOverride) can force B&W
          rem switchbw=1 means B&W mode, systemFlags bit 6
          rem Uses temp2 for temp2 (temp2 saved by
          let temp2 = 0 : rem   caller)
          if switchbw then let temp2 = 1
          if systemFlags & SystemFlagColorBWOverride then let temp2 = 1
          return

DWS_LoadBWColors
          asm
          ; rem Load B&W colors (all white)
          ; rem
          ; rem Input: WinnerScreenColorsBW (ROM constant) = B&W color
          ; rem table
          ; rem
          ; rem Output: pfcolortable pointer set to WinnerScreenColorsBW
          ; rem
          ; rem Mutates: pfcolortable (playfield color table pointer, set
          ; rem via inline assembly)
          ; rem
          ; rem Called Routines: None (uses inline assembly)
          ; rem
          ; rem Constraints: Must be colocated with DisplayWinScreen
          ; rem Set pfcolortable pointer to WinnerScreenColorsBW
            lda #<WinnerScreenColorsBW
            sta pfcolortable
            lda #>WinnerScreenColorsBW
            sta pfcolortable+1
end
          return

DWS_LoadColorColors
          asm
          ; rem Load color colors (gold gradient)
          ; rem
          ; rem Input: WinnerScreenColorsColor (ROM constant) = color
          ; rem table
          ; rem
          ; rem Output: pfcolortable pointer set to
          ; rem WinnerScreenColorsColor
          ; rem
          ; rem Mutates: pfcolortable (playfield color table pointer, set
          ; rem via inline assembly)
          ; rem
          ; rem Called Routines: None (uses inline assembly)
          ; rem
          ; rem Constraints: Must be colocated with DisplayWinScreen
          ; rem Set pfcolortable pointer to WinnerScreenColorsColor
            lda #<WinnerScreenColorsColor
            sta pfcolortable
            lda #>WinnerScreenColorsColor
            sta pfcolortable+1
end
          return

