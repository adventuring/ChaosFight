          rem ChaosFight - Source/Routines/SelScreenEntry.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

SelScreenEntry
          rem Initialize character selections
          let playerChar[0] = 0
          let playerChar[1] = 0
          let playerChar[2] = 0
          let playerChar[3] = 0
          let playerLocked[0] = 0
          let playerLocked[1] = 0
          let playerLocked[2] = 0
          let playerLocked[3] = 0
          let controllerStatus  = controllerStatus & ClearQuadtariDetected
          
          rem Initialize character select animations
          let charSelectAnimTimer  = 0
          let charSelectAnimState  = 0
          rem Start with idle animation
          let charSelectCharIndex  = 0
          rem Start with first character
          let charSelectAnimFrame  = 0

          rem Check for Quadtari adapter
          gosub SelDetectQuad

          rem Set background color (B&W safe)
          let COLUBK  = ColGray(0)
          rem Always black background

SelScreenLoop
          rem Quadtari controller multiplexing:
          rem On even frames (qtcontroller=0): handle controllers 0 and 1
          rem On odd frames (qtcontroller=1): handle controllers 2 and 3 (if Quadtari detected)
          
          if qtcontroller then goto SelHandleQuad
          
          rem Handle Player 1 input (joy0 on even frames)
          let if joy0left then playerChar[0] = playerChar[0] - 1 : goto SelChkP0Left
          goto SelSkipP0Left

SelChkP0Left
          if playerChar[0] > MaxCharacter then playerChar[0] = MaxCharacter
          if playerChar[0] > MaxCharacter then playerLocked[0] = 0
          
SelSkipP0Left
          let if joy0right then playerChar[0] = playerChar[0] + 1 : goto SelChkP0Right
          goto SelSkipP0Right

SelChkP0Right
          if playerChar[0] > MaxCharacter then playerChar[0] = 0
          if playerChar[0] > MaxCharacter then playerLocked[0] = 0
          
SelSkipP0Right
          let if joy0up then playerLocked[0] = 0
          rem Unlock by moving up
          if joy0down then SelChkJoy0Fire
          goto SelJoy0Down

SelChkJoy0Fire
          if joy0fire then SelJoy0Down
          let playerLocked[0] = 0
          
SelJoy0Down
          rem Unlock by moving down (without fire)
          if joy0fire then SelP0Lock
          goto SelP0Done

SelP0Lock
          if joy0down then SelP0Handi
          let playerLocked[0] = 1
          rem Locked normal (100% health)
          goto SelP0Done

SelP0Handi
          let playerLocked[0] = 2
          rem Locked with handicap (75% health)
SelP0Done

          rem Handle Player 2 input (joy1 on even frames)
          let if joy1left then playerChar[1] = playerChar[1] - 1 : goto SelChkP1Left
          goto SelSkipP1Left

SelChkP1Left
          if playerChar[1] > MaxCharacter then playerChar[1] = MaxCharacter
          if playerChar[1] > MaxCharacter then playerLocked[1] = 0
SelSkipP1Left
          let if joy1right then playerChar[1] = playerChar[1] + 1 : goto SelChkP1Right
          goto SelSkipP1Right

SelChkP1Right
          if playerChar[1] > MaxCharacter then playerChar[1] = 0
          if playerChar[1] > MaxCharacter then playerLocked[1] = 0
SelSkipP1Right
          let if joy1up then playerLocked[1] = 0
          rem Unlock by moving up
          if joy1down then SelChkJoy1Fire

          goto SelJoy1Down

SelChkJoy1Fire
          if joy1fire then SelJoy1Down

          let playerLocked[1] = 0
SelJoy1Down
          rem Unlock by moving down (without fire)
          if joy1fire then SelJoy1Chk

          goto SelSkipJoy1Even

SelJoy1Chk
          let if joy1down then playerLocked[1] = 2 : goto SelJoy1Done

          rem Locked with handicap (75% health)
          let playerLocked[1] = 1
SelJoy1Done 
          rem Locked normal (100% health)

SelSkipJoy1Even
          let qtcontroller  = 1  rem Switch to odd frame mode for next iteration
          goto SelHandleDone

SelHandleQuad
          rem Handle Player 3 input (joy0 on odd frames, Quadtari only)
          if controllerStatus & SetQuadtariDetected then SelHandleP2

          goto SelSkipP2

SelHandleP2
          let if joy0left then playerChar[2] = playerChar[2] - 1 : goto SelChkP2Left

          goto SelSkipP2Left

SelChkP2Left
          if playerChar[2] > MaxCharacter then playerChar[2] = MaxCharacter
          if playerChar[2] > MaxCharacter then playerLocked[2] = 0
SelSkipP2Left
          let if joy0right then playerChar[2] = playerChar[2] + 1 : goto SelChkP2Right

          goto SelSkipP2Right

SelChkP2Right
          if playerChar[2] > MaxCharacter then playerChar[2] = 0
          if playerChar[2] > MaxCharacter then playerLocked[2] = 0
SelSkipP2Right
          let if joy0up then playerLocked[2] = 0
          rem Unlock by moving up
          if joy0down then SelChkJoy0Fire2

          goto SelJoy0Down2

SelChkJoy0Fire2
          if joy0fire then SelJoy0Down2
          let playerLocked[2] = 0
SelJoy0Down2
          rem Unlock by moving down (without fire)
          if joy0fire then SelChkJoy0Down2

          goto SelJoy0Done2

SelChkJoy0Down2
          if joy0down then SelSetHand2

          let playerLocked[2] = 1
          rem Locked normal (100% health)
          goto SelJoy0Done2

SelSetHand2
          let playerLocked[2] = 2
          rem Locked with handicap (75% health)
SelJoy0Done2

          rem Handle Player 4 input (joy1 on odd frames, Quadtari only)
          if controllerStatus & SetQuadtariDetected then SelHandleP3

          goto SelSkipP3Alt

SelHandleP3
          let if joy1left then playerChar[3] = playerChar[3] - 1 : goto SelCheckP3Left
          goto SelSkipP3Left
SelCheckP3Left
          if playerChar[3] > MaxCharacter then playerChar[3] = MaxCharacter
          if playerChar[3] > MaxCharacter then playerLocked[3] = 0
SelSkipP3Left
          let if joy1right then playerChar[3] = playerChar[3] + 1 : goto SelCheckP3Right
          goto SelSkipP3Right
SelCheckP3Right
          if playerChar[3] > MaxCharacter then playerChar[3] = 0
          if playerChar[3] > MaxCharacter then playerLocked[3] = 0
SelSkipP3Right
          let if joy1up then playerLocked[3] = 0
          rem Unlock by moving up
          if joy1down then SelChkJoy1Fire3

          goto SelJoy1Down3

SelChkJoy1Fire3
          if joy1fire then SelJoy1Down3

          let playerLocked[3] = 0
SelJoy1Down3
          rem Unlock by moving down (without fire)
          if joy1fire then SelJoy1Chk3

          goto SelSkipJoy1Odd

SelJoy1Chk3
          if joy1down then SelSetHand3

          let playerLocked[3] = 1
          rem Locked normal (100% health)
          goto SelJoy1Done3

SelSetHand3
          let playerLocked[3] = 2
          rem Locked with handicap (75% health)
SelJoy1Done3
          
          let qtcontroller  = 0  rem Switch back to even frame mode for next iteration
SelSkipP2
SelSkipP3Alt
SelSkipJoy1Odd

SelHandleDone

          rem Update character select animations
          gosub SelUpdateAnim

          rem Check if all players are ready to start
          gosub SelAllReady

          rem Draw character selection screen
          gosub SelDrawScreen

          drawscreen
          goto SelScreenLoop

          rem Check if all players are ready
SelAllReady
          let readyCount  = 0

          rem Count locked players
          if playerLocked[0] then readyCount = readyCount + 1
          if playerLocked[1] then readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then SelQuadPlayers

          goto SelSkipQuadPly
          
SelQuadPlayers
          if playerLocked[2] then readyCount = readyCount + 1
          if playerLocked[3] then readyCount = readyCount + 1
SelSkipQuadPly
          rem Check if enough players are ready
          if controllerStatus & SetQuadtariDetected then SelQuadReady

          rem Need at least 1 player ready for 2-player mode
          if playerLocked[0] then goto SelScreenDone

          if playerLocked[1] then goto SelScreenDone

          goto SelSkipQuadChk
          
SelQuadReady
          rem Need at least 2 players ready for 4-player mode
          let if readyCount > = 2 then goto SelScreenDone
SelSkipQuadChk
          return

          rem Draw character selection screen
SelDrawScreen
          rem Clear playfield
          pf0 = 0
          pf1 = 0
          pf2 = 0
          pf3 = 0
          pf4 = 0
          pf5 = 0

          rem Draw Player 1 selection (top left) with number
          player0x = 56
          player0y = 40 
          rem Adjusted for 16px left margin (40+16)
          gosub SelDrawSprite

          rem Draw "1" indicator below Player 1 using playfield
          gosub SelDrawNumber

          rem Draw Player 2 selection (top right) with number
          let player1x = 104
          let player1y = 40
          rem Adjusted for 16px margins (120-16)
          gosub SelDrawSprite

          rem Draw "2" indicator below Player 2 using playfield
          gosub SelDrawNumber

          rem Draw Player 3 selection (bottom left) if Quadtari detected
          if controllerStatus & SetQuadtariDetected then SelDrawP3
          goto SelSkipP3
SelDrawP3
          player0x = 56
          player0y = 80 
          rem Adjusted for 16px left margin
          gosub SelDrawSprite

          rem Draw "3" indicator below Player 3 using playfield
          gosub SelDrawNumber

          rem Draw Player 4 selection (bottom right) if Quadtari detected
          if controllerStatus & SetQuadtariDetected then SelDrawP4
          goto SelSkipP4
SelDrawP4
          let player1x = 104
          let player1y = 80
          rem Adjusted for 16px margins
          gosub SelDrawSprite

          rem Draw "4" indicator below Player 4 using playfield
          gosub SelDrawNumber
SelSkipP3
SelSkipP4

          rem Draw locked status indicators (playfield blocks framing characters)
          gosub SelDrawLocks

          return

          rem Draw locked status indicators
SelDrawLocks
          rem Draw playfield blocks around locked characters
          if playerLocked[0] then SelDrawP0Border
          goto SelSkipP0Border
SelDrawP0Border
          rem Draw border around Player 1
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
SelSkipP0Border

          if playerLocked[1] then SelDrawP1Border
          goto SelSkipP1Border
SelDrawP1Border
          rem Draw border around Player 2
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
SelSkipP1Border

          if controllerStatus & SetQuadtariDetected then SelChkP2Lock
          goto SkipPlayer2Locked
SelChkP2Lock
          if playerLocked[2] then SelDrawP2Border
          goto SkipPlayer2Locked
SelDrawP2Border 
          rem Draw border around Player 3
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001

          if controllerStatus & SetQuadtariDetected then SelChkP3Lock
          goto SelSkipP3Locked
SelChkP3Lock
          if playerLocked[3] then SelDrawP3Border
          goto SelSkipP3Locked
SelDrawP3Border 
          rem Draw border around Player 4
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
          return

          rem Draw player number indicator
SelDrawNumber
          rem This function draws the player number (1-4) below the character
          rem using playfield pixels in a simple digit pattern
          rem Player numbers are determined by position in the grid

          rem Player 1 (top left) - draw "1"
          let if player0x  = 56 then SelChkP0Y1
          goto SkipPlayer0Check1
SelChkP0Y1
          let if player0y  = 40 then SelDrawP0Top
          goto SkipPlayer0Check1
SelDrawP0Top 
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00011000
          pf2 = pf2 | %00001000
          pf3 = pf3 | %00001000

          rem Player 2 (top right) - draw "2"
          let if player1x  = 104 then SelChkP1Y1
          goto SkipPlayer1Check1
SelChkP1Y1
          let if player1y  = 40 then SelDrawP1Top
          goto SkipPlayer1Check1
SelDrawP1Top 
          pf3 = pf3 | %00010000
          pf4 = pf4 | %00001000
          pf5 = pf5 | %00010000

          rem Player 3 (bottom left) - draw "3"
          let if player0x  = 56 then SelChkP0Y2
          goto SkipPlayer0Check2
SelChkP0Y2
          let if player0y  = 80 then SelDrawP0Bot
          goto SkipPlayer0Check2
SelDrawP0Bot 
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00001000
          pf2 = pf2 | %00001000
          pf3 = pf3 | %00001000

          rem Player 4 (bottom right) - draw "4"
          let if player1x  = 104 then SelChkP1Y2
          goto SkipPlayer1Check2
SelChkP1Y2
          let if player1y  = 80 then SelDrawP1Bot
          goto SkipPlayer1Check2
SelDrawP1Bot 
          pf3 = pf3 | %00010000
          pf4 = pf4 | %00010000
          pf5 = pf5 | %00010000
          return

          rem Update character select animations
SelUpdateAnim
          rem Check if any player is holding DOWN (for handicap preview)
          rem If so, freeze their character in "recovery from far fall" pose (animation state 9)
          rem HandicapMode is defined in Variables.bas as variable i
          let HandicapMode  = 0
          
          rem Check each player for DOWN held (even frame for P1/P2)
          if qtcontroller then goto SkipEvenFrameCheck 
                    let if joy0down then HandicapMode  = HandicapMode | 1
          rem P1 handicap flag
          let if joy1down then HandicapMode  = HandicapMode | 2
          rem P2 handicap flag
          
          
          rem Check each player for DOWN held (odd frame for P3/P4)
          if qtcontroller then SelQuadHandi
          goto SkipOddFrameCheck
SelQuadHandi
          if controllerStatus & SetQuadtariDetected then SelOddFrame
          goto SkipOddFrameCheck
SelOddFrame 
                    let if joy0down then HandicapMode  = HandicapMode | 4
          rem P3 handicap flag
          let if joy1down then HandicapMode  = HandicapMode | 8
          rem P4 handicap flag
          
          
          rem If any player is holding down, set animation to "recovery" pose
          if HandicapMode then SelHandleHandi
          goto SelAnimNormal
SelHandleHandi
          let charSelectAnimState = AnimRecovering
          rem Animation state 9 = "Recovering to standing"
          let charSelectAnimFrame  = 0
          rem First frame of recovery animation
          rem Do not update timer or frame - freeze the animation
          return
SelAnimNormal
          
          rem Normal animation updates (only when no handicap mode active)
          rem Increment animation timer
          let charSelectAnimTimer  = charSelectAnimTimer + 1
          
          rem Change animation state every 60 frames (1 second at 60fps)
          if charSelectAnimTimer > FramesPerSecond then 
          let charSelectAnimTimer  = 0
          rem Randomly choose new animation state
          let charSelectAnimState  = rand & 3
          rem 0-3: idle, running, attacking, special
          let if charSelectAnimState > 2 then charSelectAnimState  = 0
          rem Keep to 0-2 range
          let charSelectAnimFrame  = 0
          rem Cycle through characters for variety
          let charSelectCharIndex  = charSelectCharIndex + 1
          let if charSelectCharIndex > MaxCharacter then charSelectCharIndex  = 0
          
          
          rem Update animation frame within current state
          let charSelectAnimFrame  = charSelectAnimFrame + 1
          let if charSelectAnimFrame > 7 then charSelectAnimFrame  = 0
          rem 8-frame animation cycles
          
          return

          rem Draw character sprite with animation
SelDrawSprite
          rem Draw animated character sprite based on current animation state
          rem Each character has unique 8x16 graphics with unique colors per scanline
          rem Animation states: AnimStanding=idle, AnimWalking=running, AnimAttackWindup=attacking (hurt simulation)
          rem Colors are based on player number and hurt status, not animation state
          
          rem Set character color based on hurt status and color/B&W mode
          rem Colors are based on player number (1=Blue, 2=Red, 3=Yellow, 4=Green)
          rem Hurt state uses same color but dimmer luminance
          
          rem Check if character is in hurt/recovery state
          rem For character select, we will use a simple hurt simulation
          let temp1  = charSelectAnimState
          rem Use animation state as hurt simulation for demo
          
          if temp1 <> 2 then SelColorNormal
          rem Hurt state - dimmer colors
          if switchbw then SelHurtBW
          rem Player color but dimmer
          let if charSelectPlayer = 1 then COLUP0  = ColBlue(6)
          rem Dark blue
          let if charSelectPlayer = 2 then COLUP0  = ColRed(6)
          rem Dark red  
          let if charSelectPlayer = 3 then COLUP0  = ColYellow(6)
          rem Dark yellow
          let if charSelectPlayer = 4 then COLUP0  = ColGreen(6)
          rem Dark green
          goto SelColorDone
SelHurtBW
          let COLUP0  = ColGrey(6)
          rem Dark grey for hurt (B&W)
          goto SelColorDone
SelColorNormal
          rem Normal state - bright colors
          if switchbw then SelColorBW
          rem Player color - bright
          let if charSelectPlayer = 1 then COLUP0  = ColBlue(12)
          rem Bright blue
          let if charSelectPlayer = 2 then COLUP0  = ColRed(12)
          rem Bright red
          let if charSelectPlayer = 3 then COLUP0  = ColYellow(12)
          rem Bright yellow
          let if charSelectPlayer = 4 then COLUP0  = ColGreen(12)
          rem Bright green
          goto SelColorDone
SelColorBW
          let COLUP0  = ColGrey(14)
          rem Bright grey (B&W)
SelColorDone
          
          rem Draw different sprite patterns based on animation state and frame
          let if charSelectAnimState = AnimStanding then SelAnimIdle
          let if charSelectAnimState = AnimWalking then SelAnimRun
          let if charSelectAnimState = AnimAttackWindup then SelAnimAttack
          goto SelAnimDone
SelAnimIdle
          rem Idle animation - simple standing pose
          goto SelAnimDone
SelAnimRun
          rem Running animation - alternating leg positions
          if charSelectAnimFrame & 1 then SelLeftLeg
          rem Frame 0,2,4,6 - right leg forward
          goto SelAnimDone
SelLeftLeg
          rem Frame 1,3,5,7 - left leg forward
          goto SelAnimDone
SelAnimAttack
          rem Attacking animation - arm extended
          if charSelectAnimFrame < 4 then SelWindup
          rem Attack frames - arm forward
          goto SelAnimDone
SelWindup
          rem Windup frames - arm back
          goto SelAnimDone
SelAnimDone
          return

SelScreenDone
          rem Character selection complete
          rem Store selected characters for use in game
          let selectedChar1  = playerChar[0]
          let selectedChar2  = playerChar[1]
          let selectedChar3  = playerChar[2]
          let selectedChar4  = playerChar[3]

          rem Proceed to falling animation
          return

          rem Detect Quadtari adapter
SelDetectQuad
          rem CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          rem Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) AND Right (INPT2 LOW, INPT3 HIGH)
          
          rem Check left side: if INPT0 is HIGH then not detected
          if INPT0{7} then SelQuadAbsent
          rem Check left side: if INPT1 is LOW then not detected
          if !INPT1{7} then SelQuadAbsent
          
          rem Check right side: if INPT2 is HIGH then not detected
          if INPT2{7} then SelQuadAbsent
          rem Check right side: if INPT3 is LOW then not detected
          if !INPT3{7} then SelQuadAbsent
          
          rem All checks passed - Quadtari detected
          goto SelSkipQuadAbs

SelQuadAbsent
          rem Quadtari not detected - could set visual indicator
          rem COLUBK = $40  ; red background if desired
          let controllerStatus  = controllerStatus & ClearQuadtariDetected
          return
          
SelSkipQuadAbs
          rem Quadtari detected
          let controllerStatus  = controllerStatus | SetQuadtariDetected
          return
