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
          lda ScreenPfRowHeight
          sta pfrowheight
          ;; lda ScreenPfRows (duplicate)
          ;; sta pfrows (duplicate)

          ;; Load winner screen playfield pattern
          ;; Set playfield pointers to WinnerScreenPlayfield data (optimized: load once, store twice)
          ;; lda # <WinnerScreenPlayfield (duplicate)
          ;; sta PF1pointer (duplicate)
          ;; sta PF2pointer (duplicate)
          ;; lda # >WinnerScreenPlayfield (duplicate)
          ;; sta PF1pointer+1 (duplicate)
          ;; sta PF2pointer+1 (duplicate)

          ;; Winner screen always uses color mode
          jsr DWS_LoadColorColors

          ;; Get players remaining count (SCRAM read)
          ;; lda playersRemaining_R (duplicate)
          ;; sta temp1 (duplicate)

          ;; Get winner index (already set by FindWinner, SCRAM read)
          ;; Read after DWS_GetBWMode to avoid temp2 conflict
          ;; lda winnerPlayerIndex_R (duplicate)
          ;; sta temp2 (duplicate)

          ;; Calculate rankings from eliminationOrder
          ;; Winner = not eliminated (already have winnerPlayerIndex)
          ;; 2nd place = highest eliminationOrder (last eliminated)
          ;; 3rd place = second highest eliminationOrder

          ;; Find 2nd and 3rd place rankings
          ;; lda # 255 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda # 255 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta winScreenThirdPlaceOrder (duplicate)

          ;; Check all players for ranking
          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)

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
          ;; lda temp1 (duplicate)
          cmp temp2
          bne skip_2447
          ;; TODO: DWS_RankNext
skip_2447:


          ;; Get this player’s elimination order (SCRAM read)
                    ;; let winScreenCandidateOrder = eliminationOrder_R[temp1]         
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda eliminationOrder_R,x (duplicate)
          ;; sta winScreenCandidateOrder (duplicate)

          ;; Check if this is 2nd place (higher order than current 2nd)
                    ;; if winScreenCandidateOrder > temp5 then DWS_UpdateSecond
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
          ;; lda temp5 (duplicate)
          ;; sta winScreenThirdPlaceOrder (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda winScreenCandidateOrder (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; jmp DWS_RankNext (duplicate)

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
                    ;; if winScreenCandidateOrder > winScreenThirdPlaceOrder then let winScreenThirdPlaceOrder = winScreenCandidateOrder : let temp4 = temp1

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
          ;; ;; if temp1 < 4 then goto DWS_RankLoop
          ;; lda temp1 (duplicate)
          ;; cmp 4 (duplicate)
          bcs .skip_6175
          ;; jmp (duplicate)
          ;; lda temp1 (duplicate)
          ;; cmp # 4 (duplicate)
          ;; bcs skip_8911 (duplicate)
          goto_label:

          ;; jmp goto_label (duplicate)
skip_8911:

          ;; lda temp1 (duplicate)
          ;; cmp # 4 (duplicate)
          ;; bcs skip_8620 (duplicate)
          ;; jmp goto_label (duplicate)
skip_8620:

          

          ;; Position characters based on playersRemaining
          ;; 1 player: Winner centered (X=80,y=row 24 = 192 pixels)
          ;; 2 players: Winner centered (X=80), Runner-up left (X=40)
          ;; 3+ players: Winner centered high (X=80,y=row 16), 2nd
          ;; left (X=40), 3rd right (X=120)

          ;; Position winner (always centered)
          ;; lda temp1 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_3654 (duplicate)
          ;; TODO: DWS_Position1Player
skip_3654:


          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_9466 (duplicate)
          ;; TODO: DWS_Position2Players
skip_9466:


          ;; jmp DWS_Position3Players (duplicate)

.pend

DWS_LoadIdleSprite .proc

          ;; Helper: Set temp2=0, temp3=0 and load sprite (saves bytes by eliminating repeated assignments)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from DisplayWinScreen, so use return thisbank
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to LoadCharacterSprite in bank 16
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadCharacterSprite-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadCharacterSprite-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 15
          ;; jmp BS_jsr (duplicate)
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
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 80 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 192 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Load winner sprite
                    ;; let currentCharacter = playerCharacter[temp2]         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; Player 0
          ;; jsr DWS_LoadIdleSprite (duplicate)

          ;; jsr DWS_HidePlayers123 (duplicate)

          ;; jsr BS_return (duplicate)

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
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 80 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 192 (duplicate)
          ;; sta playerY,x (duplicate)
                    ;; let currentCharacter = playerCharacter[temp2]         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; jsr DWS_LoadIdleSprite (duplicate)

          ;; Runner-up (P1) - only if valid
          ;; lda temp3 (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_6581 (duplicate)
          ;; TODO: DWS_Hide2Player
skip_6581:


          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 40 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 192 (duplicate)
          ;; sta playerY,x (duplicate)
                    ;; let currentCharacter = playerCharacter[temp3]         
          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; jsr DWS_LoadIdleSprite (duplicate)

          ;; jmp DWS_Hide2PlayerDone (duplicate)

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
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerX,x (duplicate)

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
          ;; jsr DWS_HidePlayers123 (duplicate)

          ;; jsr BS_return (duplicate)

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
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 80 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; Row 16 = 128 pixels (16 × 8)
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 128 (duplicate)
          ;; sta playerY,x (duplicate)
                    ;; let currentCharacter = playerCharacter[temp2]         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; jsr DWS_LoadIdleSprite (duplicate)

          ;; 2nd place (P1) - left platform
          ;; lda temp3 (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_5564 (duplicate)
          ;; TODO: DWS_Hide3Player2
skip_5564:


          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 40 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 192 (duplicate)
          ;; sta playerY,x (duplicate)
                    ;; let currentCharacter = playerCharacter[temp3]         
          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; jsr DWS_LoadIdleSprite (duplicate)

          ;; jmp DWS_Hide3Player2Done (duplicate)

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
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerX,x (duplicate)

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
          ;; lda temp4 (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_8912 (duplicate)
          ;; TODO: DWS_Hide3Player3
skip_8912:


          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 120 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 192 (duplicate)
          ;; sta playerY,x (duplicate)
                    ;; let currentCharacter = playerCharacter[temp4]         
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda # 2 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; jsr DWS_LoadIdleSprite (duplicate)

          ;; jmp DWS_Hide3Player3Done (duplicate)

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
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerX,x (duplicate)

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
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; jsr BS_return (duplicate)

.pend

DWS_HidePlayers123 .proc
          ;; Helper: Hide players 1, 2, 3 (saves bytes by consolidating repeated code)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from DisplayWinScreen, so use return thisbank
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; rts (duplicate)

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
          ;; lda systemFlags (duplicate)
          and SystemFlagColorBWOverride
          ;; sta temp2 (duplicate)
          ;; if temp2 then let temp2 = 1
          ;; lda temp2 (duplicate)
          beq skip_6171
          ;; jmp skip_6171 (duplicate)
skip_6171:
          ;; jsr BS_return (duplicate)

.pend

DWS_LoadColorColors .proc

          ;; TODO: ; rem Load color colors (gold gradient)
          ;; TODO: ; rem Input: WinnerScreenColorsColor table
          ;; TODO: ; rem Output: pfcolortable pointer set to WinnerScreenColorsColor
          ;; TODO: ; rem Mutates: pfcolortable (via inline assembly)
          ;; TODO: ; rem Called Routines: None (uses inline assembly)
          ;; TODO: ; rem Constraints: Must be colocated with DisplayWinScreen


          ;; TODO: ; rem Set pfcolortable pointer to WinnerScreenColorsColor
            ;; lda # <WinnerScreenColorsColor (duplicate)
            ;; sta pfcolortable (duplicate)
            ;; lda # >WinnerScreenColorsColor (duplicate)
            ;; sta pfcolortable+1 (duplicate)
          ;; rts (duplicate)

.pend

