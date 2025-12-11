;;; ChaosFight - Source/Routines/DisplayWinScreen.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

DisplayWinScreen .proc
          ;; Displays the winner podium with character sprites
          ;; Returns: Far (return otherbank)
          ;; Layout:
          ;; - Fixed playfield pattern (podium/platform design)
          ;; - 1 player: Winner centered on podium
          ;; - 2 players: Winner centered, runner-up on left platform
          ;; - 3+ players: Winner centered high, 2nd on left, 3rd on right
          ;; Called from WinnerAnnouncementLoop per-frame loop
          ;; Input: playersRemaining_R (global SCRAM) = number of
          ;; players remaining
          ;; winnerPlayerIndex_R (global SCRAM) = winner player
          ;; index
          ;; eliminationOrder_R[] (global SCRAM array) =
          ;; elimination order for each player
          ;; playerCharacter[] (global array) = player character
          ;; selections
          ;; WinnerScreenPlayfield (ROM constant) = playfield
          ;; pattern data
          ;; WinnerScreenColorsColor (ROM constant) = color table
          ;;
          ;; Output: Screen layout set, playfield pattern loaded,
          ;; colors loaded, player sprites positioned and loaded
          ;;
          ;; Mutates: pfrowheight, pfrows (set via
          ;; SetGameScreenLayout),
          ;; PF1pointer, PF2pointer (playfield pointers, set
          ;; via inline assembly),
          ;; pfcolortable (playfield color table pointer, set
          ;; via DWS_LoadColorColors),
          ;; playerX[0-3], playerY[0-3] (TIA registers), player
          ;; sprite pointers (via LoadCharacterSprite),
          ;; temp1-temp6 plus SCRAM scratch (used for ranking calculations)
          ;;
          ;; Called Routines: SetGameScreenLayout (bank7) - sets
          ;; screen layout,
          ;; DWS_LoadColorColors - set color table
          ;; pointers,
          ;; LoadCharacterSprite (bank10) - loads character sprites
          ;;
          ;; Constraints: Must be colocated with DWS_RankLoop,
          ;; DWS_UpdateSecond, DWS_CheckThird,
          ;; DWS_RankNext, DWS_Position1Player,
          ;; DWS_Position2Players, DWS_Position3Players,
          ;; DWS_Hide2Player, DWS_Hide2PlayerDone,
          ;; DWS_Hide3Player2, DWS_Hide3Player2Done,
          ;; DWS_Hide3Player3, DWS_Hide3Player3Done,
          ;; DWS_GetBWMode, DWS_LoadBWColors,
          ;; DWS_LoadColorColors (all called via goto or
          ;; gosub)
          ;; Called from WinnerAnnouncementLoop per-frame loop

          ;; Set screen layout (32×8 for character display) - inlined
          lda # ScreenPfRowHeight
          sta pfrowheight
          lda # ScreenPfRows
          sta pfrows

          ;; Load winner screen playfield pattern
          ;; Set playfield pointers to WinnerScreenPlayfield data (optimized: load once, store twice)
          lda # <WinnerScreenPlayfield
          sta PF1pointer
          sta PF2pointer
          lda # >WinnerScreenPlayfield
          sta PF1pointer+1
          sta PF2pointer+1

          ;; Winner screen always uses color mode
          jsr LoadColorColorsWinScreen

          ;; Get players remaining count (SCRAM read)
          lda playersRemaining_R
          sta temp1

          ;; Get winner index (already set by FindWinner, SCRAM read)
          ;; Read after GetBWModeWinScreen to avoid temp2 conflict
          lda winnerPlayerIndex_R
          sta temp2

          ;; Calculate rankings from eliminationOrder
          Winner = not eliminated (already have winnerPlayerIndex)
          ;; 2nd place = highest eliminationOrder (last eliminated)
          ;; 3rd place = second highest eliminationOrder

          ;; Find 2nd and 3rd place rankings
          lda # 255
          sta temp3
          lda # 255
          sta temp4
          lda # 0
          sta temp5
          lda # 0
          sta winScreenThirdPlaceOrder

          ;; Check all players for ranking
          lda # 0
          sta temp1

.pend

DWS_RankLoop .proc
          ;; Ranking loop - check all players for 2nd and 3rd place
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp1 (player index), temp2,
          ;; temp3, temp5,
          ;; temp4, winScreenThirdPlaceOrder (from
          ;; DisplayWinScreen)
          ;; eliminationOrder_R[] (global SCRAM array) =
          ;; elimination order
          ;;
          ;; Output: temp3, temp4, temp5,
          ;; winScreenThirdPlaceOrder updated
          ;;
          ;; Mutates: temp1 (incremented), temp3,
          ;; temp4, temp5, winScreenThirdPlaceOrder,
          ;; winScreenCandidateOrder
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; UpdateSecondPlace, CheckThirdPlace, RankNextWinScreen
          ;; Skip if this is the winner
          lda temp1
          cmp temp2
          bne GetEliminationOrder
          jmp RankNextWinScreen
GetEliminationOrder:


          ;; Get this player’s elimination order (SCRAM read)
          ;; let winScreenCandidateOrder = eliminationOrder_R[temp1]         
          lda temp1
          asl
          tax
          lda eliminationOrder_R,x
          sta winScreenCandidateOrder

          ;; Check if this is 2nd place (higher order than current 2nd)
          ;; if winScreenCandidateOrder > temp5 then DWS_UpdateSecond
          lda winScreenCandidateOrder
          cmp temp5
          bcc DWS_CheckThird
          beq DWS_CheckThird
          jmp DWS_UpdateSecond

DWS_UpdateSecond:
          ;; Move current 2nd to 3rd, then update 2nd
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp3, temp5, winScreenCandidateOrder,
          ;; temp1 (from DWS_RankLoop)
          ;;
          ;; Output: temp4, winScreenThirdPlaceOrder updated,
          ;; temp3, temp5 updated
          ;;
          ;; Mutates: temp4, winScreenThirdPlaceOrder,
          ;; temp3, temp5
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with DisplayWinScreen, DWS_RankLoop
          lda temp5
          sta winScreenThirdPlaceOrder
          lda temp3
          sta temp4
          lda winScreenCandidateOrder
          sta temp5
          lda temp1
          sta temp3
          jmp RankNextWinScreen

DWS_CheckThird .proc
          ;; Check if this is 3rd place (higher order than current 3rd,
          ;; Returns: Far (return otherbank)
          ;; but lower than 2nd)
          ;;
          ;; Input: winScreenCandidateOrder,
          ;; winScreenThirdPlaceOrder, temp1 (from
          ;; DWS_RankLoop)
          ;;
          ;; Output: temp4, winScreenThirdPlaceOrder updated if higher
          ;;
          ;; Mutates: temp4, winScreenThirdPlaceOrder
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; DWS_RankLoop, DWS_RankNext
          ;; if winScreenCandidateOrder > winScreenThirdPlaceOrder then let winScreenThirdPlaceOrder = winScreenCandidateOrder : let temp4 = temp1
          lda winScreenCandidateOrder
          cmp winScreenThirdPlaceOrder
          bcc DWS_CheckThirdDone
          beq DWS_CheckThirdDone
          lda winScreenCandidateOrder
          sta winScreenThirdPlaceOrder
          lda temp1
          sta temp4
DWS_CheckThirdDone:
          jmp RankNextWinScreen

DWS_RankNext .proc
          ;; Ranking loop continuation
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp1 (player index, from DWS_RankLoop)
          ;;
          ;; Output: temp1 incremented, loops back to DWS_RankLoop if <
          ;; 4
          ;;
          ;; Mutates: temp1 (incremented)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with DisplayWinScreen, DWS_RankLoop
          inc temp1
          ;; if temp1 < 4 then goto DWS_RankLoop
          lda temp1
          cmp # 4
          bcs PositionCharacters
          jmp DWS_RankLoop
PositionCharacters:

          

          ;; Position characters based on playersRemaining
          ;; 1 player: Winner centered (X=80,y=row 24 = 192 pixels)
          ;; 2 players: Winner centered (X=80), Runner-up left (X=40)
          ;; 3+ players: Winner centered high (X=80,y=row 16), 2nd
          ;; left (X=40), 3rd right (X=120)

          ;; Position winner (always centered)
          lda temp1
          cmp # 1
          bne CheckTwoPlayers
          jmp Position1PlayerWinScreen
CheckTwoPlayers:


          lda temp1
          cmp # 2
          bne PositionThreePlayers
          jmp DWS_Position2Players
PositionThreePlayers:


          jmp Position3PlayersWinScreen

          jsr BS_return

.pend

LoadIdleSpriteWinScreen .proc

          ;; Helper: Set temp2=0, temp3=0 and load sprite (saves bytes by eliminating repeated assignments)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from DisplayWinScreen, so use return thisbank
          lda # 0
          sta temp2
          lda # 0
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(AfterLoadCharacterSpriteWinScreen-1)
          pha
          lda # <(AfterLoadCharacterSpriteWinScreen-1)
          pha
          lda # >(LoadCharacterSprite-1)
          pha
          lda # <(LoadCharacterSprite-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterLoadCharacterSpriteWinScreen:


          rts

.pend

Position1PlayerWinScreen .proc
          ;; 1 player: Winner centered on podium
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp2, playerCharacter[] (from
          ;; DisplayWinScreen)
          ;;
          ;; Output: playerX[0], playerY[0] set, winner sprite loaded,
          ;; other players hidden
          ;;
          ;; Mutates: playerX[0-3], playerY[0] (TIA registers), player
          ;; sprite pointers (via LoadCharacterSprite),
          ;; currentCharacter, currentPlayer,
          ;; temp2-temp3 (passed to LoadCharacterSprite)
          ;;
          ;; Called Routines: LoadCharacterSprite (bank16) - loads
          ;; character sprite
          ;; Constraints: Must be colocated with DisplayWinScreen
          lda # 0
          asl
          tax
          lda # 80
          sta playerX,x
          lda # 0
          asl
          tax
          lda # 192
          sta playerY,x
          ;; Load winner sprite
          ;; let currentCharacter = playerCharacter[temp2]         
          lda temp2
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 0
          sta currentPlayer
          ;; Player 0
          jsr LoadIdleSpriteWinScreen

          jsr HidePlayers123WinScreen

          jsr BS_return

Position2PlayersWinScreen
          ;; 2 players: Winner centered, runner-up left
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp2, temp3, playerCharacter[]
          ;; (from DisplayWinScreen)
          ;;
          ;; Output: playerX[0-1], playerY[0-1] set, winner and
          ;; runner-up sprites loaded, other players hidden
          ;;
          ;; Mutates: playerX[0-3], playerY[0-1] (TIA registers),
          ;; player sprite pointers (via LoadCharacterSprite),
          ;; currentCharacter, currentPlayer,
          ;; temp2-temp3 (passed to LoadCharacterSprite)
          ;;
          ;; Called Routines: LoadCharacterSprite (bank16) - loads
          ;; character sprites
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; DWS_Hide2Player, DWS_Hide2PlayerDone
          ;; Winner (P0)
          lda # 0
          asl
          tax
          lda # 80
          sta playerX,x
          lda # 0
          asl
          tax
          lda # 192
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp2]         
          lda temp2
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 0
          sta currentPlayer
          jsr LoadIdleSpriteWinScreen

          ;; Runner-up (P1) - only if valid
          lda temp3
          cmp # 255
          bne PositionRunnerUp
          jmp Hide2PlayerWinScreen
PositionRunnerUp:


          lda 1
          asl
          tax
          lda 40
          sta playerX,x
          lda 1
          asl
          tax
          lda 192
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp3]         
          lda temp3
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 1
          sta currentPlayer
          jsr LoadIdleSpriteWinScreen

          jmp Hide2PlayerWinScreenDone

.pend

Hide2PlayerWinScreen .proc
          ;; Hide Player 2 (no runner-up)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from Position2PlayersWinScreen)
          ;;
          ;; Output: playerX[1] set to 0
          ;;
          ;; Mutates: playerX[1] (TIA register)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; Position2PlayersWinScreen, Hide2PlayerWinScreenDone
          lda 1
          asl
          tax
          lda 0
          sta playerX,x

Hide2PlayerWinScreenDone
          ;; Hide Player 2 complete (label only)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen
          jsr HidePlayers123WinScreen

          jsr BS_return

Position3PlayersWinScreen
          ;; 3+ players: Winner centered high, 2nd left, 3rd right
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp2, temp3, temp4,
          ;; playerCharacter[] (from DisplayWinScreen)
          ;;
          ;; Output: playerX[0-2], playerY[0-2] set, winner/2nd/3rd
          ;; sprites loaded, player 4 hidden
          ;;
          ;; Mutates: playerX[0-3], playerY[0-2] (TIA registers),
          ;; player sprite pointers (via LoadCharacterSprite),
          ;; currentCharacter, currentPlayer,
          ;; temp2-temp3 (passed to LoadCharacterSprite)
          ;;
          ;; Called Routines: LoadCharacterSprite (bank16) - loads
          ;; character sprites
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; Hide3Player2WinScreen, Hide3Player2WinScreenDone,
          ;; Hide3Player3WinScreen, Hide3Player3WinScreenDone
          ;; Winner (P0) - higher platform
          lda # 0
          asl
          tax
          lda # 80
          sta playerX,x
          ;; Row 16 = 128 pixels (16 × 8)
          lda # 0
          asl
          tax
          lda # 128
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp2]         
          lda temp2
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 0
          sta currentPlayer
          jsr LoadIdleSpriteWinScreen

          ;; 2nd place (P1) - left platform
          lda temp3
          cmp # 255
          bne PositionSecondPlace
          jmp DWS_Hide3Player2
PositionSecondPlace:


          lda # 1
          asl
          tax
          lda # 40
          sta playerX,x
          lda # 1
          asl
          tax
          lda # 192
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp3]         
          lda temp3
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 1
          sta currentPlayer
          jsr LoadIdleSpriteWinScreen

          jmp Hide3Player2WinScreenDone

Hide3Player2WinScreen:
          ;; Hide Player 2 (no 2nd place)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from Position3PlayersWinScreen)
          ;;
          ;; Output: playerX[1] set to 0
          ;;
          ;; Mutates: playerX[1] (TIA register)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; Position3PlayersWinScreen, Hide3Player2WinScreenDone
          lda # 1
          asl
          tax
          lda # 0
          sta playerX,x

          jsr BS_return

Hide3Player2WinScreenDone:
          ;; Hide Player 2 complete (label only)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen

          ;; 3rd place (P2) - right platform
          lda temp4
          cmp # 255
          bne PositionThirdPlace
          jmp Hide3Player3WinScreen
PositionThirdPlace:


          lda # 2
          asl
          tax
          lda # 120
          sta playerX,x
          lda # 2
          asl
          tax
          lda # 192
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp4]         
          lda temp4
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 2
          sta currentPlayer
          jsr LoadIdleSpriteWinScreen

          jmp DWS_Hide3Player3Done

DWS_Hide3Player3:
          ;; Hide Player 3 (no 3rd place)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from Position3PlayersWinScreen)
          ;;
          ;; Output: playerX[2] set to 0
          ;;
          ;; Mutates: playerX[2] (TIA register)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; Position3PlayersWinScreen, Hide3Player3WinScreenDone
          lda # 2
          asl
          tax
          lda # 0
          sta playerX,x

          jsr BS_return

DWS_Hide3Player3Done:
          ;; Hide Player 3 complete (label only)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen
          ;; Hide unused player
          lda # 3
          asl
          tax
          lda # 0
          sta playerX,x
          jsr BS_return

.pend

DWS_HidePlayers123 .proc
          ;; Helper: Hide players 1, 2, 3 (saves bytes by consolidating repeated code)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from DisplayWinScreen, so use return thisbank
          lda # 1
          asl
          tax
          lda # 0
          sta playerX,x
          lda # 2
          asl
          tax
          lda # 0
          sta playerX,x
          lda # 3
          asl
          tax
          lda # 0
          sta playerX,x
          rts

.pend

GetBWModeWinScreen .proc

          ;; Get Color/BW mode state for arena loading
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: systemFlags (global) = system flags including ColorBWOverride bit
          ;;
          ;; Output: temp2 = 1 if BW mode (ColorBWOverride active), 0 if color mode
          ;;
          ;; Mutates: temp2 (used as return otherbank value)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must reside in bank 15 (DisplayWinScreen.bas)
          lda systemFlags
          and # SystemFlagColorBWOverride
          sta temp2
          ;; if temp2 then let temp2 = 1
          lda temp2
          beq GetBWModeWinScreenDone
          lda # 1
          sta temp2
GetBWModeWinScreenDone:
          jsr BS_return

.pend

LoadColorColorsWinScreen .proc

          ;; TODO: #1309 ; rem Load color colors (gold gradient)
          ;; TODO: #1309 ; rem Input: WinnerScreenColorsColor table
          ;; TODO: #1309 ; rem Output: pfcolortable pointer set to WinnerScreenColorsColor
          ;; TODO: #1309 ; rem Mutates: pfcolortable (via inline assembly)
          ;; TODO: #1309 ; rem Called Routines: None (uses inline assembly)
          ;; TODO: #1309 ; rem Constraints: Must be colocated with DisplayWinScreen


          ;; TODO: #1309 ; rem Set pfcolortable pointer to WinnerScreenColorsColor
            lda # <WinnerScreenColorsColor
            sta pfcolortable
            lda # >WinnerScreenColorsColor
            sta pfcolortable+1
          rts

.pend

