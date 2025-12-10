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
          jsr DWS_LoadColorColors

          ;; Get players remaining count (SCRAM read)
          lda playersRemaining_R
          sta temp1

          ;; Get winner index (already set by FindWinner, SCRAM read)
          ;; Read after DWS_GetBWMode to avoid temp2 conflict
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
          ;; DWS_UpdateSecond, DWS_CheckThird, DWS_RankNext
          ;; Skip if this is the winner
          lda temp1
          cmp temp2
          bne skip_2447
          ;; TODO: DWS_RankNext
skip_2447:


          ;; Get this player’s elimination order (SCRAM read)
          ;; let winScreenCandidateOrder = eliminationOrder_R[temp1]         
          lda temp1
          asl
          tax
          lda eliminationOrder_R,x
          sta winScreenCandidateOrder

          ;; Check if this is 2nd place (higher order than current 2nd)
                    if winScreenCandidateOrder > temp5 then DWS_UpdateSecond
          jmp DWS_CheckThird

DWS_UpdateSecond
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
          jmp DWS_RankNext

.pend

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
                    if winScreenCandidateOrder > winScreenThirdPlaceOrder then let winScreenThirdPlaceOrder = winScreenCandidateOrder : let temp4 = temp1

.pend

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
          cmp 4
          bcs .skip_6175
          jmp
          lda temp1
          cmp # 4
          bcs skip_8911
          goto_label:

          jmp goto_label
skip_8911:

          lda temp1
          cmp # 4
          bcs skip_8620
          jmp goto_label
skip_8620:

          

          ;; Position characters based on playersRemaining
          ;; 1 player: Winner centered (X=80,y=row 24 = 192 pixels)
          ;; 2 players: Winner centered (X=80), Runner-up left (X=40)
          ;; 3+ players: Winner centered high (X=80,y=row 16), 2nd
          ;; left (X=40), 3rd right (X=120)

          ;; Position winner (always centered)
          lda temp1
          cmp # 1
          bne skip_3654
          ;; TODO: DWS_Position1Player
skip_3654:


          lda temp1
          cmp # 2
          bne skip_9466
          ;; TODO: DWS_Position2Players
skip_9466:


          jmp DWS_Position3Players

.pend

DWS_LoadIdleSprite .proc

          ;; Helper: Set temp2=0, temp3=0 and load sprite (saves bytes by eliminating repeated assignments)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from DisplayWinScreen, so use return thisbank
          lda # 0
          sta temp2
          lda # 0
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(LoadCharacterSprite-1)
          pha
          lda # <(LoadCharacterSprite-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


          rts

DWS_Position1Player
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
          lda 0
          asl
          tax
          lda 80
          sta playerX,x
          lda 0
          asl
          tax
          lda 192
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
          jsr DWS_LoadIdleSprite

          jsr DWS_HidePlayers123

          jsr BS_return

DWS_Position2Players
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
          lda 0
          asl
          tax
          lda 80
          sta playerX,x
          lda 0
          asl
          tax
          lda 192
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp2]         
          lda temp2
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 0
          sta currentPlayer
          jsr DWS_LoadIdleSprite

          ;; Runner-up (P1) - only if valid
          lda temp3
          cmp # 255
          bne skip_6581
          ;; TODO: DWS_Hide2Player
skip_6581:


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
          jsr DWS_LoadIdleSprite

          jmp DWS_Hide2PlayerDone

.pend

DWS_Hide2Player .proc
          ;; Hide Player 2 (no runner-up)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from DWS_Position2Players)
          ;;
          ;; Output: playerX[1] set to 0
          ;;
          ;; Mutates: playerX[1] (TIA register)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; DWS_Position2Players, DWS_Hide2PlayerDone
          lda 1
          asl
          tax
          lda 0
          sta playerX,x

DWS_Hide2PlayerDone
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
          jsr DWS_HidePlayers123

          jsr BS_return

DWS_Position3Players
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
          ;; DWS_Hide3Player2, DWS_Hide3Player2Done,
          ;; DWS_Hide3Player3, DWS_Hide3Player3Done
          ;; Winner (P0) - higher platform
          lda 0
          asl
          tax
          lda 80
          sta playerX,x
          ;; Row 16 = 128 pixels (16 × 8)
          lda 0
          asl
          tax
          lda 128
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp2]         
          lda temp2
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 0
          sta currentPlayer
          jsr DWS_LoadIdleSprite

          ;; 2nd place (P1) - left platform
          lda temp3
          cmp # 255
          bne skip_5564
          ;; TODO: DWS_Hide3Player2
skip_5564:


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
          jsr DWS_LoadIdleSprite

          jmp DWS_Hide3Player2Done

.pend

DWS_Hide3Player2 .proc
          ;; Hide Player 2 (no 2nd place)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from DWS_Position3Players)
          ;;
          ;; Output: playerX[1] set to 0
          ;;
          ;; Mutates: playerX[1] (TIA register)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; DWS_Position3Players, DWS_Hide3Player2Done
          lda 1
          asl
          tax
          lda 0
          sta playerX,x

DWS_Hide3Player2Done
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
          bne skip_8912
          ;; TODO: DWS_Hide3Player3
skip_8912:


          lda 2
          asl
          tax
          lda 120
          sta playerX,x
          lda 2
          asl
          tax
          lda 192
          sta playerY,x
          ;; let currentCharacter = playerCharacter[temp4]         
          lda temp4
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda # 2
          sta currentPlayer
          jsr DWS_LoadIdleSprite

          jmp DWS_Hide3Player3Done

.pend

DWS_Hide3Player3 .proc
          ;; Hide Player 3 (no 3rd place)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from DWS_Position3Players)
          ;;
          ;; Output: playerX[2] set to 0
          ;;
          ;; Mutates: playerX[2] (TIA register)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with DisplayWinScreen,
          ;; DWS_Position3Players, DWS_Hide3Player3Done
          lda 2
          asl
          tax
          lda 0
          sta playerX,x

DWS_Hide3Player3Done
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
          lda 3
          asl
          tax
          lda 0
          sta playerX,x
          jsr BS_return

.pend

DWS_HidePlayers123 .proc
          ;; Helper: Hide players 1, 2, 3 (saves bytes by consolidating repeated code)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from DisplayWinScreen, so use return thisbank
          lda 1
          asl
          tax
          lda 0
          sta playerX,x
          lda 2
          asl
          tax
          lda 0
          sta playerX,x
          lda 3
          asl
          tax
          lda 0
          sta playerX,x
          rts

.pend

DWS_GetBWMode .proc

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
          and SystemFlagColorBWOverride
          sta temp2
          if temp2 then let temp2 = 1
          lda temp2
          beq skip_6171
          jmp skip_6171
skip_6171:
          jsr BS_return

.pend

DWS_LoadColorColors .proc

          ;; TODO: ; rem Load color colors (gold gradient)
          ;; TODO: ; rem Input: WinnerScreenColorsColor table
          ;; TODO: ; rem Output: pfcolortable pointer set to WinnerScreenColorsColor
          ;; TODO: ; rem Mutates: pfcolortable (via inline assembly)
          ;; TODO: ; rem Called Routines: None (uses inline assembly)
          ;; TODO: ; rem Constraints: Must be colocated with DisplayWinScreen


          ;; TODO: ; rem Set pfcolortable pointer to WinnerScreenColorsColor
            lda # <WinnerScreenColorsColor
            sta pfcolortable
            lda # >WinnerScreenColorsColor
            sta pfcolortable+1
          rts

.pend

