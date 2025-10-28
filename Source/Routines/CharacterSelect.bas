          rem ChaosFight - Source/Routines/CharacterSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CharacterSelect1
          rem Initialize character selections
          PlayerChar[0] = 0
          PlayerChar[1] = 0
          PlayerChar[2] = 0
          PlayerChar[3] = 0
          PlayerLocked[0] = 0
          PlayerLocked[1] = 0
          PlayerLocked[2] = 0
          PlayerLocked[3] = 0
          ControllerStatus = ControllerStatus & ClearQuadtariDetected
          
          rem Initialize character select animations
          CharSelectAnimTimer = 0
          CharSelectAnimState = 0 
          rem Start with idle animation
          CharSelectCharIndex = 0 
          rem Start with first character
          CharSelectAnimFrame = 0

          rem Check for Quadtari adapter
          gosub DetectQuadtari

          rem Set background color (B&W safe)
          COLUBK = ColBlack(0) 
          rem Always black background

CharacterSelect1Loop
          rem Quadtari controller multiplexing:
          rem On even frames (qtcontroller=0): handle controllers 0 and 1
          rem On odd frames (qtcontroller=1): handle controllers 2 and 3 (if Quadtari detected)
          
          if qtcontroller then goto HandleQuadtariControllers
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then PlayerChar[0] = PlayerChar[0] - 1 : goto CheckPlayer0LeftWrap
          goto SkipPlayer0Left

CheckPlayer0LeftWrap
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = MaxCharacter : PlayerLocked[0] = 0
          
SkipPlayer0Left
          if joy0right then PlayerChar[0] = PlayerChar[0] + 1 : goto CheckPlayer0RightWrap
          goto SkipPlayer0Right

CheckPlayer0RightWrap
          if PlayerChar[0] > MaxCharacter then PlayerChar[0] = 0 : PlayerLocked[0] = 0
          
SkipPlayer0Right
          if joy0up then PlayerLocked[0] = 0 
          rem Unlock by moving up
          if joy0down then goto CheckJoy0Fire
          goto Joy0DownDone

CheckJoy0Fire
          if joy0fire then goto Joy0DownDone
          PlayerLocked[0] = 0
          
Joy0DownDone
          rem Unlock by moving down (without fire)
          if joy0fire then goto Player0Lock
          goto Player0CheckDone

Player0Lock
          if joy0down then goto Player0Handicap
          PlayerLocked[0] = 1 
          rem Locked normal (100% health)
          goto Player0CheckDone

Player0Handicap
          PlayerLocked[0] = 2 
          rem Locked with handicap (75% health)
Player0CheckDone

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then PlayerChar[1] = PlayerChar[1] - 1 : goto CheckPlayer1LeftWrap
          goto SkipPlayer1Left

CheckPlayer1LeftWrap
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = MaxCharacter : PlayerLocked[1] = 0
SkipPlayer1Left
          if joy1right then PlayerChar[1] = PlayerChar[1] + 1 : goto CheckPlayer1RightWrap
          goto SkipPlayer1Right

CheckPlayer1RightWrap
          if PlayerChar[1] > MaxCharacter then PlayerChar[1] = 0 : PlayerLocked[1] = 0
SkipPlayer1Right
          if joy1up then PlayerLocked[1] = 0 
          rem Unlock by moving up
          if joy1down then goto CheckJoy1Fire

          goto Joy1DownDone

CheckJoy1Fire
          if joy1fire then goto Joy1DownDone

          PlayerLocked[1] = 0
Joy1DownDone
          rem Unlock by moving down (without fire)
          if joy1fire then goto Joy1FireCheck

          goto SkipJoy1Fire

Joy1FireCheck
          if joy1down then PlayerLocked[1] = 2 : goto Joy1FireDone

          rem Locked with handicap (75% health)
          PlayerLocked[1] = 1
Joy1FireDone 
          rem Locked normal (100% health)

SkipJoy1Fire
          qtcontroller = 1  rem Switch to odd frame mode for next iteration
          goto HandleInputComplete

HandleQuadtariControllers
          rem Handle Player 3 input (joy0 on odd frames, Quadtari only)
          if ControllerStatus & SetQuadtariDetected then goto HandlePlayer2Input

          goto SkipPlayer2Input

HandlePlayer2Input
          if joy0left then PlayerChar[2] = PlayerChar[2] - 1 : goto CheckPlayer2LeftWrap

          goto SkipPlayer2Left

CheckPlayer2LeftWrap
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = MaxCharacter : PlayerLocked[2] = 0
SkipPlayer2Left
          if joy0right then PlayerChar[2] = PlayerChar[2] + 1 : goto CheckPlayer2RightWrap

          goto SkipPlayer2Right

CheckPlayer2RightWrap
          if PlayerChar[2] > MaxCharacter then PlayerChar[2] = 0 : PlayerLocked[2] = 0
SkipPlayer2Right
          if joy0up then PlayerLocked[2] = 0 
          rem Unlock by moving up
          if joy0down then goto CheckJoy0Fire2

          goto Joy0DownDone2

CheckJoy0Fire2
          if joy0fire then goto Joy0DownDone2
          PlayerLocked[2] = 0
Joy0DownDone2
          rem Unlock by moving down (without fire)
          if joy0fire then goto CheckJoy0Down2

          goto Joy0FireDone2

CheckJoy0Down2
          if joy0down then goto SetHandicap2

          PlayerLocked[2] = 1 
          rem Locked normal (100% health)
          goto Joy0FireDone2

SetHandicap2
          PlayerLocked[2] = 2 
          rem Locked with handicap (75% health)
Joy0FireDone2

          rem Handle Player 4 input (joy1 on odd frames, Quadtari only)
          if ControllerStatus & SetQuadtariDetected then goto HandlePlayer3Input

          goto SkipPlayer3Input

HandlePlayer3Input
          if joy1left then PlayerChar[3] = PlayerChar[3] - 1 : if PlayerChar[3] > MaxCharacter then PlayerChar[3] = MaxCharacter : PlayerLocked[3] = 0
          if joy1right then PlayerChar[3] = PlayerChar[3] + 1 : if PlayerChar[3] > MaxCharacter then PlayerChar[3] = 0 : PlayerLocked[3] = 0
          if joy1up then PlayerLocked[3] = 0 
          rem Unlock by moving up
          if joy1down then goto CheckJoy1Fire3

          goto Joy1DownDone3

CheckJoy1Fire3
          if joy1fire then goto Joy1DownDone3

          PlayerLocked[3] = 0
Joy1DownDone3
          rem Unlock by moving down (without fire)
          if joy1fire then goto Joy1FireCheck3

          goto SkipJoy1Fire

Joy1FireCheck3
          if joy1down then goto SetHandicap3

          PlayerLocked[3] = 1
          rem Locked normal (100% health)
          goto Joy1FireDone3

SetHandicap3
          PlayerLocked[3] = 2
          rem Locked with handicap (75% health)
Joy1FireDone3
          
          qtcontroller = 0  rem Switch back to even frame mode for next iteration
SkipPlayer2Input
SkipPlayer3Input
SkipJoy1Fire

HandleInputComplete

          rem Update character select animations
          gosub UpdateCharacterSelectAnimations

          rem Check if all players are ready to start
          gosub CheckAllPlayersReady1

          rem Draw character selection screen
          gosub DrawCharacterSelect1

          drawscreen
          goto CharacterSelect1Loop

          rem Check if all players are ready
CheckAllPlayersReady1
          ReadyCount = 0

          rem Count locked players
          if PlayerLocked[0] then ReadyCount = ReadyCount + 1
          if PlayerLocked[1] then ReadyCount = ReadyCount + 1
          if ControllerStatus & SetQuadtariDetected then goto CheckQuadtariPlayers

          goto SkipQuadtariPlayers
          
CheckQuadtariPlayers
          if PlayerLocked[2] then ReadyCount = ReadyCount + 1
          if PlayerLocked[3] then ReadyCount = ReadyCount + 1
SkipQuadtariPlayers
          rem Check if enough players are ready
          if ControllerStatus & SetQuadtariDetected then goto CheckQuadtariReady

          rem Need at least 1 player ready for 2-player mode
          if PlayerLocked[0] then goto CharacterSelectComplete1

          if PlayerLocked[1] then goto CharacterSelectComplete1

          goto SkipQuadtariCheck
          
CheckQuadtariReady
          rem Need at least 2 players ready for 4-player mode
          if ReadyCount >= 2 then goto CharacterSelectComplete1
SkipQuadtariCheck
          return

          rem Draw character selection screen
DrawCharacterSelect1
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0
          pf3 = 0 : pf4 = 0 : pf5 = 0

          rem Draw Player 1 selection (top left) with number
          player0x = 56 : player0y = 40 
          rem Adjusted for 16px left margin (40+16)
          gosub DrawCharacterSprite1

          rem Draw "1" indicator below Player 1 using playfield
          gosub DrawPlayerNumber1

          rem Draw Player 2 selection (top right) with number
          player1x = 104 : player1y = 40 
          rem Adjusted for 16px margins (120-16)
          gosub DrawCharacterSprite1

          rem Draw "2" indicator below Player 2 using playfield
          gosub DrawPlayerNumber1

          rem Draw Player 3 selection (bottom left) if Quadtari detected
          if ControllerStatus & SetQuadtariDetected then goto DrawPlayer3
          goto SkipPlayer3
DrawPlayer3
          player0x = 56 : player0y = 80 
          rem Adjusted for 16px left margin
          gosub DrawCharacterSprite1

          rem Draw "3" indicator below Player 3 using playfield
          gosub DrawPlayerNumber1

          rem Draw Player 4 selection (bottom right) if Quadtari detected
          if ControllerStatus & SetQuadtariDetected then goto DrawPlayer4
          goto SkipPlayer4
DrawPlayer4
          player1x = 104 : player1y = 80 
          rem Adjusted for 16px margins
          gosub DrawCharacterSprite1

          rem Draw "4" indicator below Player 4 using playfield
          gosub DrawPlayerNumber1
SkipPlayer3
SkipPlayer4

          rem Draw locked status indicators (playfield blocks framing characters)
          gosub DrawLockedIndicators1

          return

          rem Draw locked status indicators
DrawLockedIndicators1
          rem Draw playfield blocks around locked characters
          if PlayerLocked[0] then goto DrawPlayer0Border
          goto SkipPlayer0Border
DrawPlayer0Border
          rem Draw border around Player 1
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
SkipPlayer0Border

          if PlayerLocked[1] then goto DrawPlayer1Border
          goto SkipPlayer1Border
DrawPlayer1Border
          rem Draw border around Player 2
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
SkipPlayer1Border

          if ControllerStatus & SetQuadtariDetected then goto CheckPlayer2Locked
          goto SkipPlayer2Locked
CheckPlayer2Locked
          if PlayerLocked[2] then goto DrawPlayer2Border
          goto SkipPlayer2Locked
DrawPlayer2Border 
          rem Draw border around Player 3
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001

          if ControllerStatus & SetQuadtariDetected then goto CheckPlayer3Locked
          goto SkipPlayer3Locked
CheckPlayer3Locked
          if PlayerLocked[3] then goto DrawPlayer3Border
          goto SkipPlayer3Locked
DrawPlayer3Border 
          rem Draw border around Player 4
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
          return

          rem Draw player number indicator
DrawPlayerNumber1
          rem This function draws the player number (1-4) below the character
          rem using playfield pixels in a simple digit pattern
          rem Player numbers are determined by position in the grid

          rem Player 1 (top left) - draw "1"
          if player0x = 56 then goto CheckPlayer0Y1
          goto SkipPlayer0Check1
CheckPlayer0Y1
          if player0y = 40 then goto DrawPlayer0Border1
          goto SkipPlayer0Check1
DrawPlayer0Border1 
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00011000
          pf2 = pf2 | %00001000
          pf3 = pf3 | %00001000

          rem Player 2 (top right) - draw "2"
          if player1x = 104 then goto CheckPlayer1Y1
          goto SkipPlayer1Check1
CheckPlayer1Y1
          if player1y = 40 then goto DrawPlayer1Border1
          goto SkipPlayer1Check1
DrawPlayer1Border1 
          pf3 = pf3 | %00010000
          pf4 = pf4 | %00001000
          pf5 = pf5 | %00010000

          rem Player 3 (bottom left) - draw "3"
          if player0x = 56 then goto CheckPlayer0Y2
          goto SkipPlayer0Check2
CheckPlayer0Y2
          if player0y = 80 then goto DrawPlayer0Border2
          goto SkipPlayer0Check2
DrawPlayer0Border2 
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00001000
          pf2 = pf2 | %00001000
          pf3 = pf3 | %00001000

          rem Player 4 (bottom right) - draw "4"
          if player1x = 104 then goto CheckPlayer1Y2
          goto SkipPlayer1Check2
CheckPlayer1Y2
          if player1y = 80 then goto DrawPlayer1Border2
          goto SkipPlayer1Check2
DrawPlayer1Border2 
          pf3 = pf3 | %00010000
          pf4 = pf4 | %00010000
          pf5 = pf5 | %00010000
          return

          rem Update character select animations
UpdateCharacterSelectAnimations
          rem Check if any player is holding DOWN (for handicap preview)
          rem If so, freeze their character in "recovery from far fall" pose (animation state 9)
          dim HandicapMode = temp1
          HandicapMode = 0
          
          rem Check each player for DOWN held (even frame for P1/P2)
          if qtcontroller then goto SkipEvenFrameCheck 
                    if joy0down then HandicapMode = HandicapMode | 1 
          rem P1 handicap flag
          if joy1down then HandicapMode = HandicapMode | 2 
          rem P2 handicap flag
          
          
          rem Check each player for DOWN held (odd frame for P3/P4)
          if qtcontroller then goto CheckQuadtariHandicap
          goto SkipOddFrameCheck
CheckQuadtariHandicap
          if ControllerStatus & SetQuadtariDetected then goto HandleOddFrameCheck
          goto SkipOddFrameCheck
HandleOddFrameCheck 
                    if joy0down then HandicapMode = HandicapMode | 4 
          rem P3 handicap flag
          if joy1down then HandicapMode = HandicapMode | 8 
          rem P4 handicap flag
          
          
          rem If any player is holding down, set animation to "recovery" pose
          if HandicapMode then goto HandleHandicapMode
          goto NormalAnimation
HandleHandicapMode
          CharSelectAnimState = 9 
          rem Animation state 9 = "Recovering to standing"
          CharSelectAnimFrame = 0  
          rem First frame of recovery animation
          rem Do not update timer or frame - freeze the animation
          return
NormalAnimation
          
          rem Normal animation updates (only when no handicap mode active)
          rem Increment animation timer
          CharSelectAnimTimer = CharSelectAnimTimer + 1
          
          rem Change animation state every 60 frames (1 second at 60fps)
          if CharSelectAnimTimer > 60 then 
          CharSelectAnimTimer = 0
          rem Randomly choose new animation state
          CharSelectAnimState = rand & 3 
          rem 0-3: idle, running, attacking, special
          if CharSelectAnimState > 2 then CharSelectAnimState = 0 
          rem Keep to 0-2 range
          CharSelectAnimFrame = 0
          rem Cycle through characters for variety
          CharSelectCharIndex = CharSelectCharIndex + 1
          if CharSelectCharIndex > MaxCharacter then CharSelectCharIndex = 0
          
          
          rem Update animation frame within current state
          CharSelectAnimFrame = CharSelectAnimFrame + 1
          if CharSelectAnimFrame > 7 then CharSelectAnimFrame = 0 
          rem 8-frame animation cycles
          
          return

          rem Draw character sprite with animation
DrawCharacterSprite1
          rem Draw animated character sprite based on current animation state
          rem Each character has unique 8x16 graphics with unique colors per scanline
          rem Animation states: 0=idle, 1=running, 2=attacking (hurt simulation)
          rem Colors are based on player number and hurt status, not animation state
          
          rem Set character color based on hurt status and color/B&W mode
          rem Colors are based on player number (1=Blue, 2=Red, 3=Yellow, 4=Green)
          rem Hurt state uses same color but dimmer luminance
          
          rem Check if character is in hurt/recovery state
          rem For character select, we will use a simple hurt simulation
          temp1 = CharSelectAnimState 
          rem Use animation state as hurt simulation for demo
          
          if temp1 <> 2 then goto NormalColorState
          rem Hurt state - dimmer colors
          if switchbw then goto HurtBWColor
          rem Player color but dimmer
          if CharSelectPlayer = 1 then COLUP0 = ColBlue(6) 
          rem Dark blue
          if CharSelectPlayer = 2 then COLUP0 = ColRed(6)  
          rem Dark red  
          if CharSelectPlayer = 3 then COLUP0 = ColYellow(6)
          rem Dark yellow
          if CharSelectPlayer = 4 then COLUP0 = ColGreen(6) 
          rem Dark green
          goto ColorStateDone
HurtBWColor
          COLUP0 = ColGrey(6) 
          rem Dark grey for hurt (B&W)
          goto ColorStateDone
NormalColorState
          rem Normal state - bright colors
          if switchbw then goto NormalBWColor
          rem Player color - bright
          if CharSelectPlayer = 1 then COLUP0 = ColBlue(12) 
          rem Bright blue
          if CharSelectPlayer = 2 then COLUP0 = ColRed(12)  
          rem Bright red
          if CharSelectPlayer = 3 then COLUP0 = ColYellow(12)
          rem Bright yellow
          if CharSelectPlayer = 4 then COLUP0 = ColGreen(12) 
          rem Bright green
          goto ColorStateDone
NormalBWColor
          COLUP0 = ColGrey(14) 
          rem Bright grey (B&W)
ColorStateDone
          
          rem Draw different sprite patterns based on animation state and frame
          if CharSelectAnimState = 0 then goto IdleAnimation
          if CharSelectAnimState = 1 then goto RunningAnimation
          if CharSelectAnimState = 2 then goto AttackingAnimation
          goto AnimationDone
IdleAnimation
          rem Idle animation - simple standing pose
          goto AnimationDone
RunningAnimation
          rem Running animation - alternating leg positions
          if CharSelectAnimFrame & 1 then goto LeftLegForward
          rem Frame 0,2,4,6 - right leg forward
          goto AnimationDone
LeftLegForward
          rem Frame 1,3,5,7 - left leg forward
          goto AnimationDone
AttackingAnimation
          rem Attacking animation - arm extended
          if CharSelectAnimFrame < 4 then goto WindupFrames
          rem Attack frames - arm forward
          goto AnimationDone
WindupFrames
          rem Windup frames - arm back
          goto AnimationDone
AnimationDone
          return

CharacterSelectComplete1
          rem Character selection complete
          rem Store selected characters for use in game
          SelectedChar1 = PlayerChar[0]
          SelectedChar2 = PlayerChar[1]
          SelectedChar3 = PlayerChar[2]
          SelectedChar4 = PlayerChar[3]

          rem Proceed to falling animation
          return

          rem Detect Quadtari adapter
DetectQuadtari
          rem CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          rem Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) AND Right (INPT2 LOW, INPT3 HIGH)
          
          rem Check left side: if INPT0 is HIGH then not detected
          if INPT0{7} then goto QuadtariNotDetected
          rem Check left side: if INPT1 is LOW then not detected
          if !INPT1{7} then goto QuadtariNotDetected
          
          rem Check right side: if INPT2 is HIGH then not detected
          if INPT2{7} then goto QuadtariNotDetected
          rem Check right side: if INPT3 is LOW then not detected
          if !INPT3{7} then goto QuadtariNotDetected
          
QuadtariNotDetected
          rem Quadtari not detected - could set visual indicator
          rem COLUBK = $40  ; red background if desired
          ControllerStatus = ControllerStatus & ClearQuadtariDetected
          return
          
SkipQuadtariNotDetected
          rem Quadtari detected
          ControllerStatus = ControllerStatus | SetQuadtariDetected
          return
