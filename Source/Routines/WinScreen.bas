          rem ChaosFight - Source/Routines/WinScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem WIN SCREEN SYSTEM
          rem =================================================================
          rem Displays final rankings after game completion, showing players
          rem in elimination order with the winner at top.

          rem RANKING SYSTEM:
          rem   1st Place: Winner (last alive or last eliminated)
          rem   2nd Place: Last player eliminated 
          rem   3rd Place: Second-to-last eliminated
          rem   4th Place: First eliminated

          rem DISPLAY RULES:
          rem   - Only show players who joined the game (character <> NO)
          rem   - Winner displayed prominently at top
          rem   - Others shown in descending elimination order
          rem   - Character name, placement, and visual representation
          rem =================================================================

          rem =================================================================
          rem DISPLAY WIN SCREEN
          rem =================================================================
          rem Main win screen display routine called when GameState = 2.
DisplayWinScreen
          rem Set background color for win screen
          COLUBK = ColGray(0) 
          rem Dark blue background
          
          rem Display title
          gosub DisplayWinScreenTitle
          
          rem Display rankings
          gosub DisplayFinalRankings
          
          rem Handle win screen input (advance to character select) 
          gosub HandleWinScreenInput
          
          rem Update timers
          let WinScreenTimer = WinScreenTimer + 1
          
          return

          rem =================================================================
          rem DISPLAY WIN SCREEN TITLE
          rem =================================================================
          rem Show "GAME OVER" and "FINAL RESULTS" text.
DisplayWinScreenTitle
          rem Display "GAME OVER" at top of screen
          let temp1 = 52 
          rem X position (centered)
          let temp2 = 20 
          rem Y position
          let temp3 = 14 
          rem Color (white)
          let temp4 = 0  
          rem Character data offset for "GAME"
          gosub DisplayText
          
          let temp1 = 88 
          rem X position
          let temp2 = 20 
          rem Y position  
          let temp4 = 4  
          rem Character data offset for "OVER"
          gosub DisplayText
          
          rem Display "FINAL RESULTS" 
          let temp1 = 40 
          rem X position (centered)
          let temp2 = 40 
          rem Y position
          let temp3 = 12 
          rem Color (light blue)
          let temp4 = 8  
          rem Character data offset for "FINAL RESULTS"
          gosub DisplayText
          
          return

          rem =================================================================
          rem DISPLAY FINAL RANKINGS
          rem =================================================================
          rem Show players in final ranking order with their placements.
DisplayFinalRankings
          rem Display each rank position
          let DisplayRank = 1
          gosub DisplayRankPosition
          let DisplayRank = 2  
          gosub DisplayRankPosition
          let DisplayRank = 3
          gosub DisplayRankPosition  
          let DisplayRank = 4
          gosub DisplayRankPosition
          
          return

          rem =================================================================
          rem DISPLAY RANK POSITION
          rem =================================================================
          rem Display single rank position with player info.
          rem INPUT: DisplayRank = rank to display (1-4)
DisplayRankPosition
          rem Find player for this rank
          gosub FindPlayerByRank
          if temp1 = 255 then return 
          rem No player for this rank
          
          rem Skip if player did not join the game
          if ! temp1 then goto CheckPlayer1Selected
          goto CheckPlayer1Done
CheckPlayer1Selected
          if SelectedChar1 = 255 then return
CheckPlayer1Done
          if temp1 = 1 then goto CheckPlayer2Selected
          goto CheckPlayer2Done
CheckPlayer2Selected
          if SelectedChar2 = 255 then return
CheckPlayer2Done
          if temp1 = 2 then goto CheckPlayer3Selected
          goto CheckPlayer3Done
CheckPlayer3Selected
          if SelectedChar3 = 255 then return
CheckPlayer3Done
          if temp1 = 3 then goto CheckPlayer4Selected
          goto CheckPlayer4Done
CheckPlayer4Selected
          if SelectedChar4 = 255 then return
CheckPlayer4Done
          
          rem Calculate display position
          let temp2 = 50 + (DisplayRank * 25) 
          rem Y position
          let temp3 = 30                      
          rem X position
          
          rem Display rank number
          gosub DisplayRankNumber
          
          rem Display player character name
          let temp4 = temp1 
          rem Player index
          gosub DisplayPlayerCharacterName
          
          rem Display winner crown for 1st place
if DisplayRank = 1 then 
          gosub DisplayWinnerCrown
          
          
          return

          rem =================================================================
          rem FIND PLAYER BY RANK  
          rem =================================================================
          rem Find which player should be displayed at specified rank.
          rem INPUT: DisplayRank = rank position (1-4)
          rem OUTPUT: temp1 = player index (0-3) or 255 if none
FindPlayerByRank
if DisplayRank = 1 then 
          rem First place: Winner
          let temp1 = WinnerPlayerIndex
          return
          
          
          rem For places 2-4, find by elimination order
          rem Rank 2 = last eliminated (highest elimination order)
          rem Rank 3 = second-to-last eliminated  
          rem Rank 4 = first eliminated (lowest elimination order)
          
          let temp5 = 0    
          rem Best elimination order found
          let temp1 = 255  
          rem Player index result
          
          rem Search for player with appropriate elimination order
          let temp6 = 0 
          rem Check player 0
          gosub CheckPlayerForRank
          let temp6 = 1 
          rem Check player 1
          gosub CheckPlayerForRank
          let temp6 = 2 
          rem Check player 2  
          gosub CheckPlayerForRank
          let temp6 = 3 
          rem Check player 3
          gosub CheckPlayerForRank
          
          return

          rem =================================================================
          rem CHECK PLAYER FOR RANK
          rem =================================================================  
          rem Check if player matches the rank we are looking for.
          rem INPUT: temp6 = player to check, DisplayRank = target rank
          rem MODIFIES: temp1, temp5 (best match so far)
CheckPlayerForRank
          rem Skip if player did not join
          if ! temp6 then goto CheckPlayer1Joined
          goto CheckPlayer1JoinedDone
CheckPlayer1Joined
          if SelectedChar1 = 255 then return
CheckPlayer1JoinedDone
          if temp6 = 1 then goto CheckPlayer2Joined
          goto CheckPlayer2JoinedDone
CheckPlayer2Joined
          if SelectedChar2 = 255 then return
CheckPlayer2JoinedDone
          if temp6 = 2 then goto CheckPlayer3Joined
          goto CheckPlayer3JoinedDone
CheckPlayer3Joined
          if SelectedChar3 = 255 then return
CheckPlayer3JoinedDone
          if temp6 = 3 then goto CheckPlayer4Joined
          goto CheckPlayer4JoinedDone
CheckPlayer4Joined
          if SelectedChar4 = 255 then return
CheckPlayer4JoinedDone
          
          rem Skip winner (already handled in rank 1)
          if temp6 = WinnerPlayerIndex then return
          
          rem Get this player elimination order
          if ! temp6 then let temp4 = EliminationOrder[0]
          if temp6 = 1 then let temp4 = EliminationOrder[1]
          if temp6 = 2 then let temp4 = EliminationOrder[2] 
          if temp6 = 3 then let temp4 = EliminationOrder[3]
          
          rem Skip if not eliminated
          if ! temp4 then return
          
          rem Check if this matches target rank
if DisplayRank = 2 then 
          rem Want highest elimination order
          if temp4 > temp5 then let temp5 = temp4 : let temp1 = temp6
          
if DisplayRank = 3 then 
          rem Want second highest (skip if matches rank 2 winner)
          gosub FindRank2EliminationOrder
          if temp4 >= temp3 then goto SkipRank2Check
          if temp4 <= temp5 then goto SkipRank2Check
          let temp5 = temp4 : let temp1 = temp6
SkipRank2Check
          
if DisplayRank = 4 then 
          rem Want lowest elimination order
          if ! temp5 || temp4 < temp5 then let temp5 = temp4 : let temp1 = temp6
          
          
          return

          rem =================================================================
          rem FIND RANK 2 ELIMINATION ORDER
          rem =================================================================
          rem Helper to find the elimination order of rank 2 player.
          rem OUTPUT: temp3 = elimination order of rank 2 player
FindRank2EliminationOrder
          let temp3 = 0 
          rem Highest elimination order
          
          if EliminationOrder[0] <= temp3 then goto SkipElim0
          if ! WinnerPlayerIndex then goto SkipElim0
          let temp3 = EliminationOrder[0]
SkipElim0
          if EliminationOrder[1] <= temp3 then goto SkipElim1
          if 1 = WinnerPlayerIndex then goto SkipElim1
          let temp3 = EliminationOrder[1]
SkipElim1
          if EliminationOrder[2] <= temp3 then goto SkipElim2
          if 2 = WinnerPlayerIndex then goto SkipElim2
          let temp3 = EliminationOrder[2]
SkipElim2
          if EliminationOrder[3] <= temp3 then goto SkipElim3
          if 3 = WinnerPlayerIndex then goto SkipElim3
          let temp3 = EliminationOrder[3]
SkipElim3
          
          return

          rem =================================================================
          rem DISPLAY RANK NUMBER
          rem =================================================================
          rem Display the rank number (1st, 2nd, 3rd, 4th).
          rem INPUT: DisplayRank = rank number, temp2 = Y pos, temp3 = X pos
DisplayRankNumber
          rem Set color based on rank
          if DisplayRank = 1 then let temp4 = ColGold(14)    
          rem Gold for winner
          if DisplayRank = 2 then let temp4 = ColGrey(12)    
          rem Silver for 2nd
          if DisplayRank = 3 then let temp4 = ColOrange(10)  
          rem Bronze for 3rd  
          if DisplayRank = 4 then let temp4 = ColGrey(8)     
          rem Grey for 4th
          
          rem Display rank text (simplified number display)
          let temp5 = temp3 
          rem X position
          let temp6 = temp2 
          rem Y position
          
          if DisplayRank = 1 then gosub Display1stPlace
          if DisplayRank = 2 then gosub Display2ndPlace
          if DisplayRank = 3 then gosub Display3rdPlace
          if DisplayRank = 4 then gosub Display4thPlace
          
          return

          rem =================================================================
          rem DISPLAY PLAYER CHARACTER NAME
          rem =================================================================
          rem Display the character name for the player.
          rem INPUT: temp4 = player index, temp2 = Y pos
DisplayPlayerCharacterName
          rem Get character type for this player
          if ! temp4 then let temp5 = SelectedChar1
          if temp4 = 1 then let temp5 = SelectedChar2
          if temp4 = 2 then let temp5 = SelectedChar3
          if temp4 = 3 then let temp5 = SelectedChar4
          
          rem Display character name based on character type
          let temp6 = temp3 + 40 
          rem X offset for name
          gosub DisplayCharacterName
          
          return

          rem =================================================================
          rem WIN SCREEN INPUT HANDLING
          rem =================================================================
          rem Handle input to advance from win screen back to character select.
HandleWinScreenInput
          rem Any fire button or select advances to character select
if joy0fire then goto CheckAutoAdvance
if joy1fire then goto CheckAutoAdvance
if switchselect then goto CheckAutoAdvance
          goto CharacterSelect
CheckAutoAdvance
          
          rem Auto-advance after 10 seconds
if WinScreenTimer <= 600 then goto WinScreenLoop 
          goto CharacterSelect
          
          
          return

          rem =================================================================
          rem DISPLAY ROUTINES FOR RANK POSITIONS  
          rem =================================================================
          rem Simple text display routines for each rank.
Display1stPlace
          rem Display "1ST" using simple sprite pattern
          rem Set gold color for winner
          COLUP0 = ColGold(14)
          
          rem Draw "1" using player0 sprite
          player0:
          %00011000 
          rem   ##
          %00111000 
          rem  ###  
          %01011000 
          rem # ##
          %00011000 
          rem   ##
          %00011000 
          rem   ##
          %00011000 
          rem   ##
          %01111110 
          rem ######
          %00000000  : rem
end
          end
          
          player0x = temp5
          player0y = temp6
          return

Display2ndPlace  
          rem Display "2ND" using simple sprite pattern
          rem Set silver color for second place
          COLUP0 = ColGrey(12)
          
          player0:
          %01111100 
          rem #####
          %11000110 
          rem ##  ##
          %00000110 
          rem    ##
          %01111100 
          rem #####
          %11000000 
          rem ##
          %11000000 
          rem ##
          %11111110 
          rem ######
          %00000000  : rem
end
          end
          
          player0x = temp5
          player0y = temp6
          return

Display3rdPlace
          rem Display "3RD" using simple sprite pattern
          rem Set bronze color for third place
          COLUP! ColOrange(10)
          
          player0:
          %01111100 
          rem #####
          %11000110 
          rem ##  ##
          %00000110 
          rem    ##
          %00111100 
          rem  ####
          %00000110 
          rem    ##
          %11000110 
          rem ##  ##
          %01111100 
          rem #####
          %00000000  : rem
end
          end
          
          player0x = temp5
          player0y = temp6
          return

Display4thPlace
          rem Display "4TH" using simple sprite pattern  
          rem Set grey color for fourth place
          COLUP! ColGrey(8)
          
          player0:
          %11000110 
          rem ##  ##
          %11000110 
          rem ##  ##
          %11000110 
          rem ##  ##
          %11111110 
          rem ######
          %00000110 
          rem    ##
          %00000110 
          rem    ##
          %00000110 
          rem    ##
          %00000000  : rem
end
          end
          
          player0x = temp5
          player0y = temp6
          return

          rem =================================================================
          rem DISPLAY WINNER CROWN
          rem =================================================================
          rem Display crown symbol next to winner.
DisplayWinnerCrown
          rem Display crown sprite using player1
          COLUP1 = ColGold(15) 
          rem Bright gold crown
          
          player1:
          %00111100 
          rem  ####
          %01111110 
          rem ######
          %11111111 
          rem ########
          %10101001 
          rem # # #  #
          %10111101 
          rem # #### #
          %10111101 
          rem # #### #
          %11111111 
          rem ########
          %00000000  : rem
end
          end
          
          player1x = temp3 - 20 
          rem Position left of rank number
          player1y = temp2 - 2  
          rem Slightly above rank
          return

          rem =================================================================
          rem DISPLAY CHARACTER NAME
          rem =================================================================  
          rem Display character name based on character type.
          rem INPUT: temp5 = character type, temp6 = X pos, temp2 = Y pos
DisplayCharacterName
          rem Display character name using sprites (simplified)
          rem INPUT: temp5 = character type, temp6 = X pos, temp2 = Y pos
          
          rem Use missile0 for character name display
          rem Missiles inherit colors from COLUP0/COLUP1 (multisprite kernel)
          rem Set optimal text color for platform-specific visibility
          gosub SetWinScreenTextColor
          
          rem Simple character identification patterns
          rem This is a basic implementation - full font system would be better
          if temp5 = 0 then 
          rem Bernie
          missile0:
          %11111100 
          rem B
          %11000110  
          %11111100  
          %11000110  
          %11111100  
          %00000000
          %00000000
          %00000000
          end
          
          if temp5 = 1 then 
          rem Curler -> C
          missile0:
          %01111110 
          rem C
          %11000000  
          %11000000  
          %11000000  
          %01111110  
          %00000000
          %00000000
          %00000000
          end
          
          if temp5 = 2 then 
          rem Dragonet -> D
          missile0:
          %11111100 
          rem D
          %11000110  
          %11000110  
          %11000110  
          %11111100  
          %00000000
          %00000000
          %00000000
          end
          
          rem Add more character name patterns as needed
          
          missile0x = temp6
          missile0y = temp2
          return

          rem =================================================================
          rem DISPLAY TEXT
          rem =================================================================
          rem Generic text display routine.
          rem INPUT: temp1 = X, temp2 = Y, temp3 = color, temp4 = text data offset
DisplayText
          rem Generic text display using playfield
          rem INPUT: temp1 = X, temp2 = Y, temp3 = color, temp4 = text data offset
          
          rem Set playfield color for text
          COLUPF = temp3
          
          rem Simple text rendering using playfield pixels
          rem This is a basic implementation for essential text display
          rem Full font system would provide better text rendering
          
          rem Draw simple text pattern in playfield
          rem Position based on temp1, temp2 coordinates
          let temp5 = temp1 / 8 
          rem Convert X to playfield column
          let temp6 = temp2 / 8 
          rem Convert Y to playfield row
          
          rem Set a few playfield pixels for basic text effect
if temp5 >= 32 then goto SkipTextEffect
if temp6 >= 12 then goto SkipTextEffect 
          rem Use pfpixel to draw simple text pattern
          rem pfpixel temp5 temp6 on
          rem pfpixel temp5+1 temp6 on
          rem pfpixel temp5 temp6+1 on
          rem pfpixel temp5+1 temp6+1 on
SkipTextEffect
          
          
          return
