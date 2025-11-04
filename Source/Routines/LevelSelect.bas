          rem ChaosFight - Source/Routines/ArenaSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem ARENA SELECT - PER-FRAME LOOP
          rem =================================================================
          rem Per-frame arena select screen with arena cycling ( 1-32/random)
          rem Called from MainLoop each frame (gameMode 5).
          rem Players can cycle through arenas 1-32 or select random (random).
          rem
          rem Setup is handled by BeginArenaSelect in ChangeGameMode.bas
          rem This function processes one frame and returns.
          rem =================================================================

ArenaSelect1
ArenaSelect1Loop
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
          rem Update character idle animations
          gosub ArenaSelectUpdateAnimations
          rem Draw locked-in player characters
          gosub ArenaSelectDrawCharacters
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
          if joy0left then ArenaSelectLeft
          goto ArenaSelectSkipLeft
ArenaSelectLeft
          dim ASL_soundId = temp1
          rem Decrement arena, wrap from 0 to RandomArena (255)
          if selectedArena = 0 then selectedArena = RandomArena : goto ArenaSelectLeftSound
          if selectedArena = RandomArena then selectedArena = MaxArenaID : goto ArenaSelectLeftSound
          selectedArena = selectedArena - 1
ArenaSelectLeftSound
          rem Play navigation sound
          let ASL_soundId = SoundSelect
          let temp1 = ASL_soundId
          gosub bank15 PlaySoundEffect
ArenaSelectSkipLeft
          
          if joy0right then ArenaSelectRight
          goto ArenaSelectSkipRight
ArenaSelectRight
          dim ASR_soundId = temp1
          rem Increment arena, wrap from MaxArenaID to 0, then to RandomArena
          if selectedArena = MaxArenaID then selectedArena = RandomArena : goto ArenaSelectRightSound
          if selectedArena = RandomArena then selectedArena = 0 : goto ArenaSelectRightSound
          selectedArena = selectedArena + 1
          rem Wrap from 255 to 0 if needed
          if selectedArena > MaxArenaID && selectedArena < RandomArena then selectedArena = 0
ArenaSelectRightSound
          rem Play navigation sound
          let ASR_soundId = SoundSelect
          let temp1 = ASR_soundId
          gosub bank15 PlaySoundEffect
ArenaSelectSkipRight
          
          rem Display arena number ( 1-32) or ?? (random)
          rem Display using player4 (tens digit) and player5 (ones digit)
          rem Position: center of screen (X=80 for tens, X=88 for ones, Y=20)
          rem Note: Tens digit only shown for arenas 10-32 (tensDigit > 0)
          if selectedArena = RandomArena then DisplayRandomArena
          
          rem Display arena number (selectedArena + 1 = 1-32)
          rem Convert to two-digit display: tens and ones
          rem Supports up to 32 arenas (tens digit: blank for 1-9, 1 for 10-19, 2 for 20-29, 3 for 30-32)
          let LS1_arenaNumber = selectedArena + 1
          rem arenaNumber = arena number (1-32)
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
          
          rem Draw tens digit (player4) - only if tensDigit > 0 (for arenas 10-32)
          if LS1_tensDigit > 0 then DrawTensDigit
          goto SkipTensDigit
DrawTensDigit
          let LS1_digit = LS1_tensDigit
          let LS1_xPos = 80
          let LS1_yPos = 20
          let LS1_color = ColGrey(14)
          let LS1_spriteSelect = 4
          rem Use player4 for tens digit
          let temp1 = LS1_digit
          let temp2 = LS1_xPos
          let temp3 = LS1_yPos
          let temp4 = LS1_color
          let temp5 = LS1_spriteSelect
          gosub DrawDigit
SkipTensDigit
          
          rem Draw ones digit (player5)
          let LS1_digit = LS1_onesDigit
          let LS1_xPos = 88
          let LS1_spriteSelect = 5
          rem Use player5 for ones digit
          let temp1 = LS1_digit
          let temp2 = LS1_xPos
          let temp3 = LS1_yPos
          let temp4 = LS1_color
          let temp5 = LS1_spriteSelect
          gosub DrawDigit
          
          goto DisplayDone
          
DisplayRandomArena
          dim DRA_digit = temp1
          dim DRA_xPos = temp2
          dim DRA_yPos = temp3
          dim DRA_color = temp4
          dim DRA_spriteSelect = temp5
          rem Display "??" for random arena
          rem Use player4 and player5 for two question marks
          rem Question mark is digit 10 (hex A) in font
          let DRA_digit = 10
          rem Question mark digit
          let DRA_xPos = 80
          rem X position for first ?
          let DRA_yPos = 20
          rem Y position
          let DRA_color = ColGrey(14)
          rem White
          let DRA_spriteSelect = 4
          rem Use player4
          let temp1 = DRA_digit
          let temp2 = DRA_xPos
          let temp3 = DRA_yPos
          let temp4 = DRA_color
          let temp5 = DRA_spriteSelect
          gosub DrawDigit
          
          rem Second question mark
          let DRA_xPos = 88
          rem X position for second ?
          let DRA_spriteSelect = 5
          rem Use player5
          let temp2 = DRA_xPos
          let temp5 = DRA_spriteSelect
          gosub DrawDigit
          
DisplayDone
          
          rem Handle fire button press (confirm selection, start game)
          if joy0fire then ArenaSelectConfirm
          goto ArenaSelectSkipConfirm
ArenaSelectConfirm
          dim ASC_soundId = temp1
          rem Play selection sound
          let ASC_soundId = SoundMenuSelect
          let temp1 = ASC_soundId
          gosub bank15 PlaySoundEffect
          gosub StartGame1
          return
ArenaSelectSkipConfirm
          
          drawscreen
          goto ArenaSelect1Loop

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

          rem =================================================================
          rem CHARACTER DISPLAY AND ANIMATION
          rem =================================================================
          
ArenaSelectUpdateAnimations
          dim ASUA_playerIndex = temp1
          dim ASUA_animFrame = temp2
          rem Update idle animations for all selected characters
          rem Each player updates independently with simple frame counter
          
          rem Update Player 1 animation (if character selected)
          if selectedChar1 = 255 then ArenaSelectSkipPlayer0Anim
          rem NoCharacter = 255
          if selectedChar1 = 254 then ArenaSelectSkipPlayer0Anim
          rem CPUCharacter = 254
          if selectedChar1 = 253 then ArenaSelectSkipPlayer0Anim
          rem RandomCharacter = 253
          let ASUA_playerIndex = 0
          gosub ArenaSelectUpdatePlayerAnim
          
ArenaSelectSkipPlayer0Anim
          rem Update Player 2 animation (if character selected)
          if selectedChar2 = 255 then ArenaSelectSkipPlayer1Anim
          if selectedChar2 = 254 then ArenaSelectSkipPlayer1Anim
          if selectedChar2 = 253 then ArenaSelectSkipPlayer1Anim
          let ASUA_playerIndex = 1
          gosub ArenaSelectUpdatePlayerAnim
          
ArenaSelectSkipPlayer1Anim
          rem Update Player 3 animation (if Quadtari and character selected)
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipPlayer23Anim
          if selectedChar3 = 255 then ArenaSelectSkipPlayer2Anim
          if selectedChar3 = 254 then ArenaSelectSkipPlayer2Anim
          if selectedChar3 = 253 then ArenaSelectSkipPlayer2Anim
          let ASUA_playerIndex = 2
          gosub ArenaSelectUpdatePlayerAnim
          
ArenaSelectSkipPlayer2Anim
          rem Update Player 4 animation (if Quadtari and character selected)
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipPlayer23Anim
          if selectedChar4 = 255 then ArenaSelectSkipPlayer23Anim
          if selectedChar4 = 254 then ArenaSelectSkipPlayer23Anim
          if selectedChar4 = 253 then ArenaSelectSkipPlayer23Anim
          let ASUA_playerIndex = 3
          gosub ArenaSelectUpdatePlayerAnim
          
ArenaSelectSkipPlayer23Anim
          return
          
ArenaSelectUpdatePlayerAnim
          dim ASUPA_playerIndex = temp1
          dim ASUPA_frameCounter = temp2
          rem Update idle animation frame for a single player
          rem Input: playerIndex = player index (0-3)
          rem Simple frame counter that cycles every 60 frames (1 second at 60fps)
          rem Increment frame counter (stored in arenaSelectAnimFrame array)
          rem For now, use a simple counter that wraps every 8 frames
          rem In the future, this could use arenaSelectAnimFrame[playerIndex] array
          rem For simplicity, just cycle through frames 0-7 for idle animation
          rem Frame updates every 8 frames (7.5fps at 60fps)
          let ASUPA_frameCounter = frame & 7
          rem Simple frame-based animation (cycles every 8 frames)
          return
          
ArenaSelectDrawCharacters
          dim ASDC_playerIndex = temp1
          dim ASDC_characterIndex = temp1
          dim ASDC_animationFrame = temp2
          dim ASDC_animationAction = temp3
          dim ASDC_playerNumber = temp4
          rem Draw all selected characters at their character select positions
          rem Characters remain in same positions as character select screen
          
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0 : pf3 = 0 : pf4 = 0 : pf5 = 0
          
          rem Draw Player 1 character (top left) if selected
          if selectedChar1 = 255 then ArenaSelectSkipDrawP0
          if selectedChar1 = 254 then ArenaSelectSkipDrawP0
          if selectedChar1 = 253 then ArenaSelectSkipDrawP0
          player0x = 56 : player0y = 40
          let ASDC_playerIndex = 0
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP0
          rem Draw Player 2 character (top right) if selected
          if selectedChar2 = 255 then ArenaSelectSkipDrawP1
          if selectedChar2 = 254 then ArenaSelectSkipDrawP1
          if selectedChar2 = 253 then ArenaSelectSkipDrawP1
          player1x = 104 : player1y = 40
          let ASDC_playerIndex = 1
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP1
          rem Draw Player 3 character (bottom left) if Quadtari and selected
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipDrawP23
          if selectedChar3 = 255 then ArenaSelectSkipDrawP2
          if selectedChar3 = 254 then ArenaSelectSkipDrawP2
          if selectedChar3 = 253 then ArenaSelectSkipDrawP2
          player2x = 56 : player2y = 80
          let ASDC_playerIndex = 2
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP2
          rem Draw Player 4 character (bottom right) if Quadtari and selected
          if !(controllerStatus & SetQuadtariDetected) then ArenaSelectSkipDrawP23
          if selectedChar4 = 255 then ArenaSelectSkipDrawP23
          if selectedChar4 = 254 then ArenaSelectSkipDrawP23
          if selectedChar4 = 253 then ArenaSelectSkipDrawP23
          player3x = 104 : player3y = 80
          let ASDC_playerIndex = 3
          gosub ArenaSelectDrawPlayerSprite
          
ArenaSelectSkipDrawP23
          return
          
ArenaSelectDrawPlayerSprite
          dim ASDPS_playerIndex = temp1
          dim ASDPS_characterIndex = temp1
          dim ASDPS_animationFrame = temp2
          dim ASDPS_animationAction = temp3
          dim ASDPS_playerNumber = temp4
          rem Draw character sprite for specified player
          rem Input: playerIndex = player index (0-3)
          rem Uses selectedChar1-4 and player positions set by caller
          
          rem Get character index based on player
          if ASDPS_playerIndex = 0 then let ASDPS_characterIndex = selectedChar1
          if ASDPS_playerIndex = 1 then let ASDPS_characterIndex = selectedChar2
          if ASDPS_playerIndex = 2 then let ASDPS_characterIndex = selectedChar3
          if ASDPS_playerIndex = 3 then let ASDPS_characterIndex = selectedChar4
          
          rem Use idle animation (action 1 = AnimIdle)
          let ASDPS_animationAction = 1
          rem Simple frame counter cycles 0-7
          let ASDPS_animationFrame = frame & 7
          rem Player number for art system
          let ASDPS_playerNumber = ASDPS_playerIndex
          
          rem Load character sprite using art location system
          rem LocateCharacterArt expects: temp1=char, temp2=frame, temp3=action, temp4=player
          let temp1 = ASDPS_characterIndex
          let temp2 = ASDPS_animationFrame
          let temp3 = ASDPS_animationAction
          let temp4 = ASDPS_playerNumber
          gosub bank10 LocateCharacterArt
          
          rem Set character color based on player number
          rem LoadCharacterColors expects: temp1=char, temp2=hurt, temp3=player, temp4=flashing, temp5=mode
          let temp1 = ASDPS_characterIndex
          let temp2 = 0
          rem Not hurt
          let temp3 = ASDPS_playerNumber
          let temp4 = 0
          rem Not flashing
          let temp5 = 0
          rem Not used
          gosub bank10 LoadCharacterColors
          
          return