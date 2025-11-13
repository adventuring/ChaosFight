          rem ChaosFight - Source/Routines/DisplayWinScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
DisplayWinScreen
          rem Displays the winner podium with character sprites
          rem Layout:
          rem   - Fixed playfield pattern (podium/platform design)
          rem   - 1 player: Winner centered on podium
          rem   - 2 players: Winner centered, runner-up on left platform
          rem   - 3+ players: Winner centered high, 2nd on left, 3rd on right
          rem Called from WinnerAnnouncementLoop per-frame loop
          rem Input: playersRemaining_R (global SCRAM) = number of
          rem players remaining
          rem        winnerPlayerIndex_R (global SCRAM) = winner player
          rem        index
          rem        eliminationOrder_R[] (global SCRAM array) =
          rem        elimination order for each player
          rem        playerCharacter[] (global array) = player character
          rem        selections
          rem        WinnerScreenPlayfield (ROM constant) = playfield
          rem        pattern data
          rem        WinnerScreenColorsColor (ROM constant) = color table
          rem
          rem Output: Screen layout set, playfield pattern loaded,
          rem colors loaded, player sprites positioned and loaded
          rem
          rem Mutates: pfrowheight, pfrows (set via
          rem SetGameScreenLayout),
          rem         PF1pointer, PF2pointer (playfield pointers, set
          rem         via inline assembly),
          rem         pfcolortable (playfield color table pointer, set
          rem         via DWS_LoadColorColors),
          rem         playerX[0-3], playerY[0-3] (TIA registers), player
          rem         sprite pointers (via LoadCharacterSprite),
          rem         temp1-temp6 plus SCRAM scratch (used for ranking calculations)
          rem
          rem Called Routines: SetGameScreenLayout (bank7) - sets
          rem screen layout,
          rem   DWS_LoadColorColors - set color table
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
          rem Called from WinnerAnnouncementLoop per-frame loop

          gosub SetGameScreenLayout bank7
          rem Set screen layout (32×8 for character display)

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

          gosub DWS_LoadColorColors
          rem Winner screen always uses color mode

          let temp1 = playersRemaining_R
          rem Get players remaining count (SCRAM read)

          rem Get winner index (already set by FindWinner, SCRAM read)
          let temp2 = winnerPlayerIndex_R
          rem Read after DWS_GetBWMode to avoid temp2 conflict

          rem Calculate rankings from eliminationOrder
          rem Winner = not eliminated (already have winnerPlayerIndex)
          rem 2nd place = highest eliminationOrder (last eliminated)
          rem 3rd place = second highest eliminationOrder

          let temp3 = 255
          rem Find 2nd and 3rd place rankings
          let temp4 = 255
          let temp5 = 0
          let winScreenThirdPlaceOrder_W = 0

          let temp1 = 0
          rem Check all players for ranking
DWS_RankLoop
          rem Ranking loop - check all players for 2nd and 3rd place
          rem
          rem Input: temp1 (player index), temp2,
          rem temp3, temp5,
          rem        temp4, winScreenThirdPlaceOrder_R (from
          rem        DisplayWinScreen)
          rem        eliminationOrder_R[] (global SCRAM array) =
          rem        elimination order
          rem
          rem Output: temp3, temp4, temp5,
          rem winScreenThirdPlaceOrder_W updated
          rem
          rem Mutates: temp1 (incremented), temp3,
          rem temp4, temp5, winScreenThirdPlaceOrder_W,
          rem         winScreenCandidateOrder_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_UpdateSecond, DWS_CheckThird, DWS_RankNext
          rem Skip if this is the winner
          if temp1 = temp2 then DWS_RankNext

          rem Get this player’s elimination order (SCRAM read)
          let winScreenCandidateOrder_W = eliminationOrder_R[temp1]

          rem Check if this is 2nd place (higher order than current 2nd)

          if winScreenCandidateOrder_R > temp5 then DWS_UpdateSecond
          goto DWS_CheckThird

DWS_UpdateSecond
          rem Move current 2nd to 3rd, then update 2nd
          rem
          rem Input: temp3, temp5, winScreenCandidateOrder_R,
          rem temp1 (from DWS_RankLoop)
          rem
          rem Output: temp4, winScreenThirdPlaceOrder_W updated,
          rem temp3, temp5 updated
          rem
          rem Mutates: temp4, winScreenThirdPlaceOrder_W,
          rem temp3, temp5
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with DisplayWinScreen, DWS_RankLoop
          let winScreenThirdPlaceOrder_W = temp5
          let temp4 = temp3
          let temp5 = winScreenCandidateOrder_R
          let temp3 = temp1
          goto DWS_RankNext

DWS_CheckThird
          rem Check if this is 3rd place (higher order than current 3rd,
          rem but lower than 2nd)
          rem
          rem Input: winScreenCandidateOrder_R,
          rem winScreenThirdPlaceOrder_R, temp1 (from
          rem DWS_RankLoop)
          rem
          rem Output: temp4, winScreenThirdPlaceOrder_W updated if higher
          rem
          rem Mutates: temp4, winScreenThirdPlaceOrder_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_RankLoop, DWS_RankNext
          if winScreenCandidateOrder_R > winScreenThirdPlaceOrder_R then let winScreenThirdPlaceOrder_W = winScreenCandidateOrder_R : temp4 = temp1

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
          rem Constraints: Must be colocated with DisplayWinScreen, DWS_RankLoop
          let temp1 = temp1 + 1
          if temp1 < 4 then goto DWS_RankLoop

          rem Position characters based on playersRemaining
          rem 1 player: Winner centered (X=80, Y=row 24 = 192 pixels)
          rem 2 players: Winner centered (X=80), Runner-up left (X=40)
          rem 3+ players: Winner centered high (X=80, Y=row 16), 2nd
          rem   left (X=40), 3rd right (X=120)

          rem Position winner (always centered)

          if temp1 = 1 then DWS_Position1Player
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
          rem         currentCharacter, currentPlayer,
          rem         temp2-temp3 (passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite (bank16) - loads
          rem character sprite
          rem Constraints: Must be colocated with DisplayWinScreen
          let playerX[0] = 80
          let playerY[0] = 192
          let currentCharacter = playerCharacter[temp2]
          rem Load winner sprite
          let currentPlayer = 0
          let temp2 = 0
          rem Animation frame 0 (idle)
          let temp3 = 0
          rem Animation action 0 (idle)
          gosub LoadCharacterSprite bank16
          rem Player 0
          let playerX[1] = 0
          rem Hide other players
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
          rem         currentCharacter, currentPlayer,
          rem         temp2-temp3 (passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite (bank16) - loads
          rem character sprites
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_Hide2Player, DWS_Hide2PlayerDone
          let playerX[0] = 80
          rem Winner (P0)
          let playerY[0] = 192
          let currentCharacter = playerCharacter[temp2]
          let currentPlayer = 0
          let temp2 = 0
          rem Animation frame 0 (idle)
          let temp3 = 0
          rem Animation action 0 (idle)
          gosub LoadCharacterSprite bank16

          rem Runner-up (P1) - only if valid

          if temp3 = 255 then DWS_Hide2Player
          let playerX[1] = 40
          let playerY[1] = 192
          let currentCharacter = playerCharacter[temp3]
          let currentPlayer = 1
          let temp2 = 0
          rem Animation frame 0 (idle)
          let temp3 = 0
          rem Animation action 0 (idle)
          gosub LoadCharacterSprite bank16
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
          let playerX[2] = 0
          rem Hide unused players
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
          rem         currentCharacter, currentPlayer,
          rem         temp2-temp3 (passed to LoadCharacterSprite)
          rem
          rem Called Routines: LoadCharacterSprite (bank16) - loads
          rem character sprites
          rem
          rem Constraints: Must be colocated with DisplayWinScreen,
          rem DWS_Hide3Player2, DWS_Hide3Player2Done,
          rem              DWS_Hide3Player3, DWS_Hide3Player3Done
          let playerX[0] = 80
          rem Winner (P0) - higher platform
          let playerY[0] = 128
          rem Row 16 = 128 pixels (16 * 8)
          let currentCharacter = playerCharacter[temp2]
          let currentPlayer = 0
          let temp2 = 0
          rem Animation frame 0 (idle)
          let temp3 = 0
          rem Animation action 0 (idle)
          gosub LoadCharacterSprite bank16

          rem 2nd place (P1) - left platform

          if temp3 = 255 then DWS_Hide3Player2
          let playerX[1] = 40
          let playerY[1] = 192
          let currentCharacter = playerCharacter[temp3]
          let currentPlayer = 1
          let temp2 = 0
          rem Animation frame 0 (idle)
          let temp3 = 0
          rem Animation action 0 (idle)
          gosub LoadCharacterSprite bank16
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

          rem 3rd place (P2) - right platform

          if temp4 = 255 then DWS_Hide3Player3
          let playerX[2] = 120
          let playerY[2] = 192
          let currentCharacter = playerCharacter[temp4]
          let currentPlayer = 2
          let temp2 = 0
          rem Animation frame 0 (idle)
          let temp3 = 0
          rem Animation action 0 (idle)
          gosub LoadCharacterSprite bank16
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
          let playerX[3] = 0
          rem Hide unused player
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

