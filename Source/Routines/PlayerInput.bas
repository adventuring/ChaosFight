          rem ChaosFight - Source/Routines/PlayerInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER INPUT HANDLING
          rem =================================================================
          rem All input handling for the four players, with character-specific
          rem control logic dispatched to character-specific subroutines.

          rem QUADTARI MULTIPLEXING:
          rem   Even frames (qtcontroller=0): joy0=Player1, joy1=Player2
          rem   Odd frames (qtcontroller=1): joy0=Player3, joy1=Player4

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   PlayerX[0-3] - X positions
          rem   PlayerY[0-3] - Y positions
          rem   PlayerState[0-3] - State flags (attacking, guarding, jumping, etc.)
          rem   PlayerChar[0-3] - Character type indices (0-15)
          rem   PlayerMomentumX[0-3] - Horizontal momentum
          rem   ControllerStatus - Packed controller detection status
          rem   qtcontroller - Multiplexing state (0=P1/P2, 1=P3/P4)

          rem STATE FLAGS (in PlayerState):
          rem   Bit 0: Facing (1 = right, 0 = left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (disabled during hitstun)
          rem   Bits 4-7: Animation state

          rem CHARACTER INDICES (0-15):
          rem   0=Bernie, 1=Curling, 2=Dragonet, 3=EXO, 4=FatTony, 5=Grizzard,
          rem   6=Harpy, 7=Knight, 8=Frooty, 9=Nefertem, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Veg Dog
          rem =================================================================

          rem Main input handler for all players
HandleAllPlayerInput
          if qtcontroller then goto HandleQuadtariPlayers
          
          rem Even frame: Handle Players 1 & 2 - only if alive  
          temp1 = 0 : gosub IsPlayerAlive
          if temp2 = 0 then goto SkipPlayer0Input
          if (PlayerState[0] & 8) <> 0 then goto SkipPlayer0Input
          temp1 = 0 : gosub HandleLeftPortPlayer
          
SkipPlayer0Input
          
          temp1 = 1 : gosub IsPlayerAlive
          if temp2 = 0 then goto SkipPlayer1Input
          if (PlayerState[1] & 8) <> 0 then goto SkipPlayer1Input
          goto HandlePlayer1Input
          
          goto SkipPlayer1Input
          
HandlePlayer1Input
          temp1 = 1 : gosub HandleRightPortPlayer 
          rem Player 1 uses Joy1
SkipPlayer1Input
          
          qtcontroller = 1 
          rem Switch to odd frame
          return

HandleQuadtariPlayers
          rem Odd frame: Handle Players 3 & 4 (if Quadtari detected and alive)
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Input
          if SelectedChar3 = 0 then goto SkipPlayer3Input
                    temp1 = 2 : gosub IsPlayerAlive
          if temp2 = 0 then goto SkipPlayer3Input
          if (PlayerState[2] & 8) <> 0 then goto SkipPlayer3Input
          temp1 = 2 : gosub HandleLeftPortPlayer
          
SkipPlayer3Input
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Input
          if SelectedChar4 = 0 then goto SkipPlayer4Input
                    temp1 = 3 : gosub IsPlayerAlive
          if temp2 = 0 then goto SkipPlayer4Input
          if (PlayerState[3] & 8) <> 0 then goto SkipPlayer4Input
          temp1 = 3 : gosub HandleRightPortPlayer
          
SkipPlayer4Input
          
          
          qtcontroller = 0 
          rem Switch back to even frame
          return

          rem =================================================================
          rem LEFT PORT PLAYER INPUT HANDLER (Joy0 - Players 1 & 3)
          rem =================================================================
          rem INPUT: temp1 = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
HandleLeftPortPlayer
          rem Process left/right movement
          if joy0left then PlayerX[temp1] = PlayerX[temp1] - 1 : PlayerState[temp1] = PlayerState[temp1] & NOT 1 : PlayerMomentumX[temp1] = 255
          if joy0right then PlayerX[temp1] = PlayerX[temp1] + 1 : PlayerState[temp1] = PlayerState[temp1] | 1 : PlayerMomentumX[temp1] = 1

          rem Process jump input (UP + enhanced buttons)
          temp3 = 0 
          rem Jump pressed flag
          if joy0up then temp3 = 1
          
          rem Check Genesis/Joy2b+ Button C/II (INPT0 for Player 1, INPT2 for Player 3)
          if temp1 = 0 then goto CheckPlayer1Buttons
          goto SkipPlayer1Buttons
CheckPlayer1Buttons
          if !ControllerStatus{0} then goto CheckPlayer1Joy2bPlus
          if !INPT0{7} then temp3 = 1
          goto SkipPlayer1Buttons
CheckPlayer1Joy2bPlus
          if !ControllerStatus{1} then goto SkipPlayer1Buttons
          if !INPT0{7} then temp3 = 1
SkipPlayer1Buttons
          if temp1 = 2 then goto CheckPlayer3Buttons
          goto SkipPlayer3Buttons
CheckPlayer3Buttons
          if !ControllerStatus{0} then goto CheckPlayer3Joy2bPlus
          if !INPT0{7} then temp3 = 1
          goto SkipPlayer3Buttons
CheckPlayer3Joy2bPlus
          if !ControllerStatus{1} then goto SkipPlayer3Buttons
          if !INPT0{7} then temp3 = 1
SkipPlayer3Buttons
EnhancedJumpDone0
          
          rem Execute jump if pressed and not already jumping
          if temp3 = 0 then SkipLeftPortJump
          if (PlayerState[temp1] & 4) <> 0 then SkipLeftPortJump
          temp4 = PlayerChar[temp1] 
          rem Character type
                    on temp4 goto BernieJump, CurlingJump, DragonetJump, EXOJump, FatTonyJump, GrizzardJump, HarpyJump, KnightJump, FrootyJump, NefertemJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, VegDogJump
SkipLeftPortJump

          

          rem Process down/guard input
          if joy0down then temp4 = PlayerChar[temp1] : on temp4 goto BernieDown, CurlingDown, DragonetDown, EXODown, FatTonyDown, GrizzardDown, HarpyDown, KnightDown, FrootyDown, NefertemDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, VegDogDown
          if !joy0down then PlayerState[temp1] = PlayerState[temp1] & NOT 2
          
          
          rem Process attack input
          if !joy0fire then goto SkipLeftPortAttack
          if (PlayerState[temp1] & 1) <> 0 then SkipLeftPortAttack
          temp4 = PlayerChar[temp1] : on temp4 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
SkipLeftPortAttack
          
          
          return

          rem =================================================================
          rem RIGHT PORT PLAYER INPUT HANDLER (Joy1 - Players 2 & 4)
          rem =================================================================
          rem INPUT: temp1 = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
HandleRightPortPlayer
          rem Process left/right movement
          if joy1left then 
                    PlayerX[temp1] = PlayerX[temp1] - 1
          PlayerState[temp1] = PlayerState[temp1] & NOT 1 
          rem Face left
                    PlayerMomentumX[temp1] = 255
          
          if joy1right then 
                    PlayerX[temp1] = PlayerX[temp1] + 1
          PlayerState[temp1] = PlayerState[temp1] | 1  
          rem Face right
                    PlayerMomentumX[temp1] = 1
          

          rem Process jump input (UP + enhanced buttons)
          temp3 = 0 
          rem Jump pressed flag
          if joy1up then temp3 = 1
          
          rem Check Genesis/Joy2b+ Button C/II (INPT2 for Player 2, INPT2 for Player 4)
          if temp1 = 1 then goto CheckPlayer2Buttons
          goto SkipPlayer2Buttons
CheckPlayer2Buttons
          if !(ControllerStatus & $04) then goto CheckPlayer2Joy2bPlus
          if !(INPT2 & $80) then temp3 = 1
          goto SkipPlayer2Buttons
CheckPlayer2Joy2bPlus
          if !(ControllerStatus & $08) then goto SkipPlayer2Buttons
          if !(INPT2 & $80) then temp3 = 1
SkipPlayer2Buttons
          if temp1 = 3 then goto CheckPlayer4Buttons
          goto SkipPlayer4Buttons
CheckPlayer4Buttons
          if !RightPortGenesis then goto CheckPlayer4Joy2bPlus
          if !INPT2{7} then temp3 = 1
          goto SkipPlayer4Buttons
CheckPlayer4Joy2bPlus
          if !RightPortJoy2bPlus then goto SkipPlayer4Buttons
          if !INPT2{7} then temp3 = 1
SkipPlayer4Buttons
EnhancedJumpDone1
          
          rem Execute jump if pressed and not already jumping
          if temp3 = 0 then SkipRightPortJump
          if (PlayerState[temp1] & 4) <> 0 then SkipRightPortJump
          temp4 = PlayerChar[temp1] 
          rem Character type
                    on temp4 goto BernieJump, CurlingJump, DragonetJump, EXOJump, FatTonyJump, GrizzardJump, HarpyJump, KnightJump, FrootyJump, NefertemJump, NinjishJump, PorkChopJump, RadishJump, RoboTitoJump, UrsuloJump, VegDogJump
SkipRightPortJump

          

          rem Process down/guard input
          if joy1down then 
          temp4 = PlayerChar[temp1] 
          rem Character type
                    on temp4 goto BernieDown, CurlingDown, DragonetDown, EXODown, FatTonyDown, GrizzardDown, HarpyDown, KnightDown, FrootyDown, NefertemDown, NinjishDown, PorkChopDown, RadishDown, RoboTitoDown, UrsuloDown, VegDogDown

          PlayerState[temp1] = PlayerState[temp1] & NOT 2 
          rem Clear guard bit
          
          
          rem Process attack input
          if !joy1fire then goto SkipRightPortAttack
          if (PlayerState[temp1] & 1) <> 0 then SkipRightPortAttack
          temp4 = PlayerChar[temp1] 
          rem Character type
                    on temp4 goto BernieAttack, CurlingSweeperAttack, DragonetAttack, EXOPilotAttack, FatTonyAttack, MegaxAttack, HarpyAttack, KnightGuyAttack, FrootyAttack, NefertemAttack, NinjishGuyAttack, PorkChopAttack, RadishGoblinAttack, RoboTitoAttack, UrsuloAttack, VegDogAttack
SkipRightPortAttack
          
          
          return

          rem =================================================================
          rem PAUSE BUTTON HANDLING WITH DEBOUNCING
          rem =================================================================
          rem Handles SELECT switch and Joy2b+ Button III with proper debouncing
          rem Uses PauseButtonPrev for debouncing state
          
HandlePauseInput
          rem Check SELECT switch (always available)
          temp1 = 0
          if switchselect then temp1 = 1
          
          rem Check Joy2b+ Button III (INPT1 for Player 1, INPT3 for Player 2)
          if LeftPortJoy2bPlus then goto CheckJoy2bButtons
          if RightPortJoy2bPlus then goto CheckJoy2bButtons
          goto Joy2bPauseDone
CheckJoy2bButtons
          if !INPT1{7} then temp1 = 1 
          rem Player 1 Button III
          if !INPT3{7} then temp1 = 1 
          rem Player 2 Button III
Joy2bPauseDone
          
          rem Debounce: only toggle if button just pressed (was 0, now 1)
          if temp1 = 0 then goto SkipPauseToggle
          if PauseButtonPrev then goto SkipPauseToggle
          GameState = GameState ^ 1 
          rem Toggle pause (0<->1)
SkipPauseToggle
          
          
          rem Update previous button state for next frame
          PauseButtonPrev = temp1
          
          return

          rem =================================================================
          rem OLD INDIVIDUAL PLAYER HANDLERS - REPLACED BY GENERIC ROUTINES
          rem =================================================================
          rem The original HandlePlayer1Input, HandlePlayer2Input, HandlePlayer3Input,
          rem and HandlePlayer4Input have been consolidated into HandleGenericPlayerInput
          rem to eliminate code duplication and improve maintainability.

