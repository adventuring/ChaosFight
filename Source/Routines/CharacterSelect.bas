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
          rem NOTE: Do NOT clear controllerStatus flags here - monotonic
          rem   detection (upgrades only)
          rem Controller detection is handled by DetectControllers with
          rem   monotonic state machine
          
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
          rem On even frames (qtcontroller=0): handle controllers 0 and
          rem   1
          rem On odd frames (qtcontroller=1): handle controllers 2 and 3
          rem   (if Quadtari detected)
          
          if qtcontroller then goto SelHandleQuad
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then let playerChar[0] = playerChar[0] - 1 : goto SelChkP0Left
          goto SelSkipP0Left

SelChkP0Left
          if playerChar[0] > MaxCharacter then let playerChar[0] = MaxCharacter
          if playerChar[0] > MaxCharacter then let playerLocked[0] = 0
          
SelSkipP0Left
          if joy0right then let playerChar[0] = playerChar[0] + 1 : goto SelChkP0Right
          goto SelSkipP0Right

SelChkP0Right
          if playerChar[0] > MaxCharacter then let playerChar[0] = 0
          if playerChar[0] > MaxCharacter then let playerLocked[0] = 0
          
SelSkipP0Right
          if joy0up then let playerLocked[0] = 0
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
          if joy1left then let playerChar[1] = playerChar[1] - 1 : goto SelChkP1Left
          goto SelSkipP1Left

SelChkP1Left
          if playerChar[1] > MaxCharacter then let playerChar[1] = MaxCharacter
          if playerChar[1] > MaxCharacter then let playerLocked[1] = 0
SelSkipP1Left
          if joy1right then let playerChar[1] = playerChar[1] + 1 : goto SelChkP1Right
          goto SelSkipP1Right

SelChkP1Right
          if playerChar[1] > MaxCharacter then let playerChar[1] = 0
          if playerChar[1] > MaxCharacter then let playerLocked[1] = 0
SelSkipP1Right
          if joy1up then let playerLocked[1] = 0
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
          if joy1down then let playerLocked[1] = 2 : goto SelJoy1Done

          rem Locked with handicap (75% health)
          let playerLocked[1] = 1
SelJoy1Done 
          rem Locked normal (100% health)

SelSkipJoy1Even
          let qtcontroller  = 1 : rem Switch to odd frame mode for next iteration
          goto SelHandleDone

SelHandleQuad
          rem Handle Player 3 input (joy0 on odd frames, Quadtari only)
          if controllerStatus & SetQuadtariDetected then SelHandleP2

          goto SelSkipP2

SelHandleP2
          if joy0left then let playerChar[2] = playerChar[2] - 1 : goto SelChkP2Left

          goto SelSkipP2Left

SelChkP2Left
          if playerChar[2] > MaxCharacter then let playerChar[2] = MaxCharacter
          if playerChar[2] > MaxCharacter then let playerLocked[2] = 0
SelSkipP2Left
          if joy0right then let playerChar[2] = playerChar[2] + 1 : goto SelChkP2Right

          goto SelSkipP2Right

SelChkP2Right
          if playerChar[2] > MaxCharacter then let playerChar[2] = 0
          if playerChar[2] > MaxCharacter then let playerLocked[2] = 0
SelSkipP2Right
          if joy0up then let playerLocked[2] = 0
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
          if joy1left then let playerChar[3] = playerChar[3] - 1 : goto SelCheckP3Left
          goto SelSkipP3Left
SelCheckP3Left
          if playerChar[3] > MaxCharacter then let playerChar[3] = MaxCharacter
          if playerChar[3] > MaxCharacter then let playerLocked[3] = 0
SelSkipP3Left
          if joy1right then let playerChar[3] = playerChar[3] + 1 : goto SelCheckP3Right
          goto SelSkipP3Right
SelCheckP3Right
          if playerChar[3] > MaxCharacter then let playerChar[3] = 0
          if playerChar[3] > MaxCharacter then let playerLocked[3] = 0
SelSkipP3Right
          if joy1up then let playerLocked[3] = 0
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
          
          let qtcontroller  = 0 : rem Switch back to even frame mode for next iteration
SelSkipP2
SelSkipP3Alt
SelSkipJoy1Odd

SelHandleDone

          rem Update character select animations
          gosub SelUpdateAnim

          rem Check if all players are ready to start (inline
          rem   SelAllReady)
          let readyCount  = 0

          rem Count locked players
          if playerLocked[0] then let readyCount = readyCount + 1
          if playerLocked[1] then let readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then SelQuadPlayersInline

          goto SelSkipQuadPlyInline
          
SelQuadPlayersInline
          if playerLocked[2] then let readyCount = readyCount + 1
          if playerLocked[3] then let readyCount = readyCount + 1
SelSkipQuadPlyInline
          rem Check if enough players are ready
          if controllerStatus & SetQuadtariDetected then SelQuadReadyInline

          rem Need at least 1 player ready for 2-player mode
          if playerLocked[0] then goto SelScreenDone

          if playerLocked[1] then goto SelScreenDone

          goto SelSkipQuadChkInline
          
SelQuadReadyInline
          rem Need at least 2 players ready for 4-player mode
          if readyCount>= 2 then goto SelScreenDone
SelSkipQuadChkInline

          rem Draw character selection screen
          gosub SelDrawScreen

          drawscreen
          goto SelScreenLoop



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

          rem Draw Player 4 selection (bottom right) if Quadtari
          rem   detected
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

          rem Draw locked status indicators (playfield blocks framing
          rem   characters)
          rem tail call
          goto SelDrawLocks


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
          goto DonePlayer2Locked
SelChkP2Lock
          if playerLocked[2] then SelDrawP2Border
          goto DonePlayer2Locked
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
          rem This function draws the player number (1-4) below the
          rem   character
          rem using playfield pixels in a simple digit pattern
          rem Player numbers are determined by position in the grid

          rem Player 1 (top left) - draw "1"
          if player0x  = 56 then SelChkP0Y1
          goto DonePlayer0Check1
SelChkP0Y1
          if player0y  = 40 then SelDrawP0Top
          goto DonePlayer0Check1
SelDrawP0Top 
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00011000
          pf2 = pf2 | %00001000
          pf3 = pf3 | %00001000

          rem Player 2 (top right) - draw "2"
          if player1x  = 104 then SelChkP1Y1
          goto DonePlayer1Check1
SelChkP1Y1
          if player1y  = 40 then SelDrawP1Top
          goto DonePlayer1Check1
SelDrawP1Top 
          pf3 = pf3 | %00010000
          pf4 = pf4 | %00001000
          pf5 = pf5 | %00010000

          rem Player 3 (bottom left) - draw "3"
          if player0x  = 56 then SelChkP0Y2
          goto DonePlayer0Check2
SelChkP0Y2
          if player0y  = 80 then SelDrawP0Bot
          goto DonePlayer0Check2
SelDrawP0Bot 
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00001000
          pf2 = pf2 | %00001000
          pf3 = pf3 | %00001000

          rem Player 4 (bottom right) - draw "4"
          if player1x  = 104 then SelChkP1Y2
          goto DonePlayer1Check2
SelChkP1Y2
          if player1y  = 80 then SelDrawP1Bot
          goto DonePlayer1Check2
SelDrawP1Bot 
          pf3 = pf3 | %00010000
          pf4 = pf4 | %00010000
          pf5 = pf5 | %00010000
          return

          rem Update character select animations
SelUpdateAnim
          rem Check if any player is holding DOWN (for handicap preview)
          rem If so, freeze their character in "recovery from far fall"
          rem   pose (animation state 9)
          rem HandicapMode is defined in Variables.bas as variable i
          let HandicapMode  = 0
          
          rem Check each player for DOWN held (even frame for P1/P2)
          if qtcontroller then goto DoneEvenFrameCheck 
                    if joy0down then let HandicapMode  = HandicapMode | 1
          rem P1 handicap flag
          if joy1down then let HandicapMode  = HandicapMode | 2
          rem P2 handicap flag
          
          
          rem Check each player for DOWN held (odd frame for P3/P4)
          if qtcontroller then SelQuadHandi
          goto DoneOddFrameCheck
SelQuadHandi
          if controllerStatus & SetQuadtariDetected then SelOddFrame
          goto DoneOddFrameCheck
SelOddFrame 
                    if joy0down then let HandicapMode  = HandicapMode | 4
          rem P3 handicap flag
          if joy1down then let HandicapMode  = HandicapMode | 8
          rem P4 handicap flag
          
          
          rem If any player is holding down, set animation to "recovery"
          rem   pose
          if HandicapMode then SelHandleHandi
          goto SelAnimNormal
SelHandleHandi
          let charSelectAnimState = ActionRecovering
          rem Animation state 9 = "Recovering to standing"
          let charSelectAnimFrame  = 0
          rem First frame of recovery animation
          rem Do not update timer or frame - freeze the animation
          return
SelAnimNormal
          
          rem Normal animation updates (only when no handicap mode
          rem   active)
          rem Increment animation timer
          let charSelectAnimTimer  = charSelectAnimTimer + 1
          
          rem Change animation state every 60 frames (1 second at 60fps)
          if charSelectAnimTimer > FramesPerSecond then 
          let charSelectAnimTimer  = 0
          rem Randomly choose new animation state
          let charSelectAnimState  = rand & 3
          rem 0-3: idle, running, attacking, special
          if charSelectAnimState > 2 then let charSelectAnimState  = 0
          rem Keep to 0-2 range
          let charSelectAnimFrame  = 0
          rem Cycle through characters for variety
          let charSelectCharIndex  = charSelectCharIndex + 1
          if charSelectCharIndex > MaxCharacter then let charSelectCharIndex  = 0
          
          
          rem Update animation frame within current state
          let charSelectAnimFrame  = charSelectAnimFrame + 1
          if charSelectAnimFrame > 7 then let charSelectAnimFrame  = 0
          rem 8-frame animation cycles
          
          return

          rem Draw character sprite with animation
SelDrawSprite
          rem Draw animated character sprite based on current animation
          rem   state
          rem Each character has unique 8x16 graphics with unique colors
          rem   per scanline
          rem Animation states: ActionStanding=idle,
          rem   ActionWalking=running, ActionAttackWindup=attacking
          rem   (hurt simulation)
          rem Colors are based on player number and hurt status, not
          rem   animation state
          
          rem Set character color based on hurt status and color/B&W
          rem   mode
          rem Colors are based on player number (1=Blue, 2=Red,
          rem   3=Yellow, 4=Green)
          rem Hurt state uses same color but dimmer luminance
          
          rem Check if character is in hurt/recovery state
          rem For character select, we will use a simple hurt simulation
          let temp1  = charSelectAnimState
          rem Use animation state as hurt simulation for demo
          
          if !(temp1 = 2) then SelColorNormal
          rem Hurt state - dimmer colors
          if switchbw then SelHurtBW
          rem Player color but dimmer
          if charSelectPlayer = 1 then COLUP0  = ColIndigo(6)
          rem Dark indigo (Player 1)
          if charSelectPlayer = 2 then COLUP0  = ColRed(6)
          rem Dark red (Player 2)
          if charSelectPlayer = 3 then COLUP0  = ColYellow(6)
          rem Dark yellow (Player 3)
          if charSelectPlayer = 4 then COLUP0  = ColGreen(6)
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
          if charSelectPlayer = 1 then COLUP0  = ColIndigo(12)
          rem Bright indigo (Player 1)
          if charSelectPlayer = 2 then COLUP0  = ColRed(12)
          rem Bright red (Player 2)
          if charSelectPlayer = 3 then COLUP0  = ColYellow(12)
          rem Bright yellow (Player 3)
          if charSelectPlayer = 4 then COLUP0  = ColGreen(12)
          rem Bright green
          goto SelColorDone
SelColorBW
          let COLUP0  = ColGrey(14)
          rem Bright grey (B&W)
SelColorDone
          
          rem Draw different sprite patterns based on animation state
          rem   and frame
          if charSelectAnimState = ActionStanding then SelAnimIdle
          if charSelectAnimState = ActionWalking then SelAnimRun
          if charSelectAnimState = ActionAttackWindup then SelAnimAttack
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
          let selectedChar2_W  = playerChar[1]
          let selectedChar3_W  = playerChar[2]
          let selectedChar4_W  = playerChar[3]
          
          rem Initialize facing bit (bit 0) for all selected players
          rem   (default: face right = 1)
          if selectedChar1 <> NoCharacter then let playerState[0] = playerState[0] | 1
          if selectedChar2_R <> NoCharacter then let playerState[1] = playerState[1] | 1
          if selectedChar3_R <> NoCharacter then let playerState[2] = playerState[2] | 1
          if selectedChar4_R <> NoCharacter then let playerState[3] = playerState[3] | 1

          rem Proceed to falling animation
          return

          rem Detect Quadtari adapter
SelDetectQuad
          rem CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          rem Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH)
          rem   AND Right (INPT2 LOW, INPT3 HIGH)
          
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
          rem Quadtari not detected in this detection cycle
          rem NOTE: Do NOT clear controllerStatus - monotonic detection
          rem   (upgrades only)
          rem If Quadtari was previously detected, it remains detected
          rem   (monotonic state machine)
          rem Only DetectControllers (called via SELECT) can update
          rem   controller status
          return
          
SelSkipQuadAbs
          rem Quadtari detected - use monotonic merge to preserve
          rem   existing capabilities
          rem OR merge ensures upgrades only, never downgrades
          let controllerStatus  = controllerStatus | SetQuadtariDetected
          return
