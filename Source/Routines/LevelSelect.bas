          rem ChaosFight - Source/Routines/LevelSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem LEVEL SELECT - PER-FRAME LOOP
          rem =================================================================
          rem Per-frame level select screen with arena cycling (01-16/??)
          rem Called from MainLoop each frame (gameMode 5).
          rem Players can cycle through arenas 01-16 or select random (??).
          rem
          rem Setup is handled by BeginLevelSelect in ChangeGameMode.bas
          rem This function processes one frame and returns.
          rem =================================================================

LevelSelect1
LevelSelect1Loop
          rem Check Game Select switch - return to Character Select
          if switchselect then ReturnToCharacterSelect
          
          rem Check fire button hold detection (1 second to return to Character Select)
          temp1 = 0
          rem Check Player 1 fire button
          if joy0fire then temp1 = 1
          rem Check Player 2 fire button
          if joy1fire then temp1 = 1
          rem Check Quadtari players (3 & 4) if active
          if controllerStatus & SetQuadtariDetected then CheckQuadtariFireHold
          
          rem If fire button held, increment timer
          if temp1 then goto IncrementFireHold
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
          rem Decrement arena, wrap from 0 to RandomArena (255)
          if selectedArena = 0 then selectedArena = RandomArena : goto LevelSelectLeftSound
          if selectedArena = RandomArena then selectedArena = MaxArenaID : goto LevelSelectLeftSound
          selectedArena = selectedArena - 1
LevelSelectLeftSound
          rem Play navigation sound
          temp1 = SoundSelect
          gosub bank15 PlaySoundEffect
LevelSelectSkipLeft
          
          if joy0right then LevelSelectRight
          goto LevelSelectSkipRight
LevelSelectRight
          rem Increment arena, wrap from MaxArenaID to 0, then to RandomArena
          if selectedArena = MaxArenaID then selectedArena = RandomArena : goto LevelSelectRightSound
          if selectedArena = RandomArena then selectedArena = 0 : goto LevelSelectRightSound
          selectedArena = selectedArena + 1
          rem Wrap from 255 to 0 if needed
          if selectedArena > MaxArenaID && selectedArena < RandomArena then selectedArena = 0
LevelSelectRightSound
          rem Play navigation sound
          temp1 = SoundSelect
          gosub bank15 PlaySoundEffect
LevelSelectSkipRight
          
          rem Display arena number (01-16) or ?? (random)
          rem Display using player0 (tens digit) and player1 (ones digit)
          rem Position: center of screen (X=80 for tens, X=88 for ones, Y=20)
          if selectedArena = RandomArena then DisplayRandomArena
          
          rem Display arena number (selectedArena + 1 = 1-16)
          rem Convert to two-digit display: tens and ones
          temp1 = selectedArena + 1
          rem temp1 = arena number (1-16)
          rem Calculate tens digit
          temp2 = temp1 / 10
          rem Calculate ones digit using optimized assembly
          asm
            lda temp2
            sta temp3
            asl a
            asl a
            asl a
            clc
            adc temp3
            asl a
            sta temp3
          end
          rem temp3 = temp2 * 10
          temp4 = temp1 - temp3
          rem temp4 = ones digit (0-9)
          
          rem Draw tens digit (player0) - may be 0 for 01-09
          temp1 = temp2
          temp2 = 80
          temp3 = 20
          temp4 = ColGrey(14)
          temp5 = 0
          gosub DrawDigit
          
          rem Draw ones digit (player1)
          temp1 = temp4
          temp2 = 88
          temp3 = 20
          temp4 = ColGrey(14)
          temp5 = 1
          gosub DrawDigit
          
          goto DisplayDone
          
DisplayRandomArena
          rem Display "??" for random arena
          rem Use player0 and player1 for two question marks
          rem Question mark is digit 10 (hex A) in font
          temp1 = 10
          rem Question mark digit
          temp2 = 80
          rem X position for first ?
          temp3 = 20
          rem Y position
          temp4 = ColGrey(14)
          rem White
          temp5 = 0
          rem Use player0
          gosub DrawDigit
          
          rem Second question mark
          temp2 = 88
          rem X position for second ?
          temp5 = 1
          rem Use player1
          gosub DrawDigit
          
DisplayDone
          
          rem Handle fire button press (confirm selection, start game)
          if joy0fire then LevelSelectConfirm
          goto LevelSelectSkipConfirm
LevelSelectConfirm
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          gosub StartGame1
          return
LevelSelectSkipConfirm
          
          drawscreen
          goto LevelSelect1Loop

CheckQuadtariFireHold
          rem Check Player 3 and 4 fire buttons (Quadtari)
          if !INPT0{7} then temp1 = 1
          rem Player 3 fire button (left port, odd frame)
          if !INPT2{7} then temp1 = 1
          rem Player 4 fire button (right port, odd frame)
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