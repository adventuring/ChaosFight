          rem ChaosFight - Source/Routines/LevelSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem ARENA SELECT - PER-FRAME LOOP
          rem =================================================================
          rem Per-frame arena select screen with arena cycling (01-16/??)
          rem Called from MainLoop each frame (gameMode 5).
          rem Players can cycle through arenas 01-16 or select random (??).
          rem
          rem Setup is handled by BeginLevelSelect in ChangeGameMode.bas
          rem This function processes one frame and returns.
          rem =================================================================

LevelSelect1
LevelSelect1Loop
          dim LS1_firePressed = temp1
          dim LS1_arenaNumber = temp1
          dim LS1_tensDigit = temp2
          dim LS1_multiplier = temp3
          dim LS1_onesDigit = temp4
          dim LS1_digit = temp1
          dim LS1_xPos = temp2
          dim LS1_yPos = temp3
          dim LS1_color = temp4
          dim LS1_spriteSelect = temp5
          dim LS1_soundId = temp1
          rem Check Game Select switch - return to Character Select
          if switchselect then ReturnToCharacterSelect
          
          rem Check fire button hold detection (1 second to return to Character Select)
          let LS1_firePressed = 0
          rem Check Player 1 fire button
          if joy0fire then let LS1_firePressed = 1
          rem Check Player 2 fire button
          if joy1fire then let LS1_firePressed = 1
          rem Check Quadtari players (3 & 4) if active
          if controllerStatus & SetQuadtariDetected then CheckQuadtariFireHold
          
          rem If fire button held, increment timer
          if LS1_firePressed then goto IncrementFireHold
          rem Fire released, reset timer
          let fireHoldTimer = 0
          goto FireHoldCheckDone
          
IncrementFireHold
          let fireHoldTimer = fireHoldTimer + 1
          rem 60 frames = 1 second @ 60fps
          if fireHoldTimer >= 60 then goto ReturnToCharacterSelect
FireHoldCheckDone
          
          rem Handle LEFT/RIGHT navigation for arena selection
          if joy0left then LevelSelectLeft
          goto LevelSelectSkipLeft
LevelSelectLeft
          dim LSL_soundId = temp1
          rem Decrement arena, wrap from 0 to RandomArena (255)
          if selectedArena = 0 then selectedArena = RandomArena : goto LevelSelectLeftSound
          if selectedArena = RandomArena then selectedArena = MaxArenaID : goto LevelSelectLeftSound
          selectedArena = selectedArena - 1
LevelSelectLeftSound
          rem Play navigation sound
          let LSL_soundId = SoundSelect
          let temp1 = LSL_soundId
          gosub bank15 PlaySoundEffect
LevelSelectSkipLeft
          
          if joy0right then LevelSelectRight
          goto LevelSelectSkipRight
LevelSelectRight
          dim LSR_soundId = temp1
          rem Increment arena, wrap from MaxArenaID to 0, then to RandomArena
          if selectedArena = MaxArenaID then selectedArena = RandomArena : goto LevelSelectRightSound
          if selectedArena = RandomArena then selectedArena = 0 : goto LevelSelectRightSound
          selectedArena = selectedArena + 1
          rem Wrap from 255 to 0 if needed
          if selectedArena > MaxArenaID && selectedArena < RandomArena then selectedArena = 0
LevelSelectRightSound
          rem Play navigation sound
          let LSR_soundId = SoundSelect
          let temp1 = LSR_soundId
          gosub bank15 PlaySoundEffect
LevelSelectSkipRight
          
          rem Display arena number (01-16) or ?? (random)
          rem Display using player0 (tens digit) and player1 (ones digit)
          rem Position: center of screen (X=80 for tens, X=88 for ones, Y=20)
          if selectedArena = RandomArena then DisplayRandomArena
          
          rem Display arena number (selectedArena + 1 = 1-16)
          rem Convert to two-digit display: tens and ones
          let LS1_arenaNumber = selectedArena + 1
          rem arenaNumber = arena number (1-16)
          rem Calculate tens digit
          let LS1_tensDigit = LS1_arenaNumber / 10
          rem Calculate ones digit using optimized assembly
          asm
            lda LS1_tensDigit
            sta LS1_multiplier
            asl a
            asl a
            asl a
            clc
            adc LS1_multiplier
            asl a
            sta LS1_multiplier
          end
          rem multiplier = tensDigit * 10
          let LS1_onesDigit = LS1_arenaNumber - LS1_multiplier
          rem onesDigit = ones digit (0-9)
          
          rem Draw tens digit (player0) - may be 0 for 01-09
          let LS1_digit = LS1_tensDigit
          let LS1_xPos = 80
          let LS1_yPos = 20
          let LS1_color = ColGrey(14)
          let LS1_spriteSelect = 0
          let temp1 = LS1_digit
          let temp2 = LS1_xPos
          let temp3 = LS1_yPos
          let temp4 = LS1_color
          let temp5 = LS1_spriteSelect
          gosub DrawDigit
          
          rem Draw ones digit (player1)
          let LS1_digit = LS1_onesDigit
          let LS1_xPos = 88
          let temp1 = LS1_digit
          let temp2 = LS1_xPos
          gosub DrawDigit
          
          goto DisplayDone
          
DisplayRandomArena
          dim DRA_digit = temp1
          dim DRA_xPos = temp2
          dim DRA_yPos = temp3
          dim DRA_color = temp4
          dim DRA_spriteSelect = temp5
          rem Display "??" for random arena
          rem Use player0 and player1 for two question marks
          rem Question mark is digit 10 (hex A) in font
          let DRA_digit = 10
          rem Question mark digit
          let DRA_xPos = 80
          rem X position for first ?
          let DRA_yPos = 20
          rem Y position
          let DRA_color = ColGrey(14)
          rem White
          let DRA_spriteSelect = 0
          rem Use player0
          let temp1 = DRA_digit
          let temp2 = DRA_xPos
          let temp3 = DRA_yPos
          let temp4 = DRA_color
          let temp5 = DRA_spriteSelect
          gosub DrawDigit
          
          rem Second question mark
          let DRA_xPos = 88
          rem X position for second ?
          let DRA_spriteSelect = 1
          rem Use player1
          let temp2 = DRA_xPos
          let temp5 = DRA_spriteSelect
          gosub DrawDigit
          
DisplayDone
          
          rem Handle fire button press (confirm selection, start game)
          if joy0fire then LevelSelectConfirm
          goto LevelSelectSkipConfirm
LevelSelectConfirm
          dim LSC_soundId = temp1
          rem Play selection sound
          let LSC_soundId = SoundMenuSelect
          let temp1 = LSC_soundId
          gosub bank15 PlaySoundEffect
          gosub StartGame1
          return
LevelSelectSkipConfirm
          
          drawscreen
          goto LevelSelect1Loop

CheckQuadtariFireHold
          dim CQFH_firePressed = temp1
          rem Check Player 3 and 4 fire buttons (Quadtari)
          if !INPT0{7} then let CQFH_firePressed = 1
          rem Player 3 fire button (left port, odd frame)
          if !INPT2{7} then let CQFH_firePressed = 1
          rem Player 4 fire button (right port, odd frame)
          let temp1 = CQFH_firePressed
          return

ReturnToCharacterSelect
          rem Return to Character Select screen
          let fireHoldTimer = 0
          let gameMode = ModeCharacterSelect
          gosub bank13 ChangeGameMode
          return

StartGame1
          rem Start game with selected arena
          let gameMode = ModeGame
          gosub bank13 ChangeGameMode
          return