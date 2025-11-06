          rem ChaosFight - Source/Routines/SelScreenEntry.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem PlayerLockedHelpers.bas moved to Bank 1

SelScreenEntry
          rem Initialize character select screen state
          rem Input: None (entry point)
          rem Output: playerChar[] initialized, playerLocked initialized, animation state initialized,
          rem         COLUBK set, Quadtari detection called
          rem Mutates: playerChar[0-3] (set to 0), playerLocked (set to 0), charSelectAnimTimer,
          rem         charSelectAnimState, charSelectCharIndex, charSelectAnimFrame, COLUBK (TIA register)
          rem Called Routines: SelDetectQuad - accesses controller detection state
          rem Constraints: Entry point for character select screen initialization
          rem              Must be colocated with SelScreenLoop (called via goto)
          rem Initialize character selections
          let playerChar[0] = 0
          let playerChar[1] = 0
          let playerChar[2] = 0
          let playerChar[3] = 0
          rem Initialize playerLocked (bit-packed, all unlocked)
          let playerLocked = 0
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
          rem Per-frame character select screen loop with Quadtari multiplexing
          rem Input: qtcontroller (global) = Quadtari controller frame toggle
          rem        joy0left, joy0right, joy0up, joy0down, joy0fire (hardware) = Player 1/3 joystick
          rem        joy1left, joy1right, joy1up, joy1down, joy1fire (hardware) = Player 2/4 joystick
          rem        playerChar[] (global array) = current character selections
          rem        playerLocked (global) = player lock states
          rem        MaxCharacter (constant) = maximum character index
          rem Output: Dispatches to SelHandleQuad or processes even frame input, then returns
          rem Mutates: qtcontroller (toggled), playerChar[], playerLocked state, temp1, temp2 (passed to SetPlayerLocked)
          rem Called Routines: SetPlayerLocked (bank1) - accesses playerLocked state
          rem Constraints: Must be colocated with SelChkP0Left, SelSkipP0Left, SelChkP0Right, SelSkipP0Right,
          rem              SelChkJoy0Fire, SelJoy0Down, SelP0Lock, SelP0Handi, SelP0Done,
          rem              SelChkP1Left, SelSkipP1Left, SelChkP1Right, SelSkipP1Right,
          rem              SelChkJoy1Fire, SelJoy1Down, SelJoy1Chk, SelJoy1Done, SelSkipJoy1Even,
          rem              SelHandleQuad (all called via goto)
          rem              Entry point for character select screen loop
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
          if playerChar[0] > MaxCharacter then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          
SelSkipP0Left
          if joy0right then let playerChar[0] = playerChar[0] + 1 : goto SelChkP0Right
          goto SelSkipP0Right

SelChkP0Right
          if playerChar[0] > MaxCharacter then let playerChar[0] = 0
          if playerChar[0] > MaxCharacter then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          
SelSkipP0Right
          if joy0up then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          rem Unlock by moving up
          if joy0down then SelChkJoy0Fire
          goto SelJoy0Down

SelChkJoy0Fire
          if joy0fire then SelJoy0Down
          let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          
SelJoy0Down
          rem Unlock by moving down (without fire)
          if joy0fire then SelP0Lock
          goto SelP0Done

SelP0Lock
          if joy0down then SelP0Handi
          let temp1 = 0 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          rem Locked normal (100% health)
          goto SelP0Done

SelP0Handi
          let temp1 = 0 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank1
          rem Locked with handicap (75% health)
SelP0Done

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then let playerChar[1] = playerChar[1] - 1 : goto SelChkP1Left
          goto SelSkipP1Left

SelChkP1Left
          if playerChar[1] > MaxCharacter then let playerChar[1] = MaxCharacter
          if playerChar[1] > MaxCharacter then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP1Left
          if joy1right then let playerChar[1] = playerChar[1] + 1 : goto SelChkP1Right
          goto SelSkipP1Right

SelChkP1Right
          if playerChar[1] > MaxCharacter then let playerChar[1] = 0
          if playerChar[1] > MaxCharacter then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP1Right
          if joy1up then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          rem Unlock by moving up
          if joy1down then SelChkJoy1Fire

          goto SelJoy1Down

SelChkJoy1Fire
          if joy1fire then SelJoy1Down

          let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelJoy1Down
          rem Unlock by moving down (without fire)
          if joy1fire then SelJoy1Chk

          goto SelSkipJoy1Even

SelJoy1Chk
          if joy1down then let temp1 = 1 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank1 : goto SelJoy1Done

          rem Locked with handicap (75% health)
          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
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
          if playerChar[2] > MaxCharacter then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP2Left
          if joy0right then let playerChar[2] = playerChar[2] + 1 : goto SelChkP2Right

          goto SelSkipP2Right

SelChkP2Right
          if playerChar[2] > MaxCharacter then let playerChar[2] = 0
          if playerChar[2] > MaxCharacter then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP2Right
          if joy0up then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          rem Unlock by moving up
          if joy0down then SelChkJoy0Fire2

          goto SelJoy0Down2

SelChkJoy0Fire2
          if joy0fire then SelJoy0Down2
          let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelJoy0Down2
          rem Unlock by moving down (without fire)
          if joy0fire then SelChkJoy0Down2

          goto SelJoy0Done2

SelChkJoy0Down2
          if joy0down then SelSetHand2

          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          rem Locked normal (100% health)
          goto SelJoy0Done2

SelSetHand2
          let temp1 = 2 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank1
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
          if playerChar[3] > MaxCharacter then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP3Left
          if joy1right then let playerChar[3] = playerChar[3] + 1 : goto SelCheckP3Right
          goto SelSkipP3Right
SelCheckP3Right
          if playerChar[3] > MaxCharacter then let playerChar[3] = 0
          if playerChar[3] > MaxCharacter then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP3Right
          if joy1up then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          rem Unlock by moving up
          if joy1down then SelChkJoy1Fire3

          goto SelJoy1Down3

SelChkJoy1Fire3
          if joy1fire then SelJoy1Down3

          let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelJoy1Down3
          rem Unlock by moving down (without fire)
          if joy1fire then SelJoy1Chk3

          goto SelSkipJoy1Odd

SelJoy1Chk3
          if joy1down then SelSetHand3

          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          rem Locked normal (100% health)
          goto SelJoy1Done3

SelSetHand3
          let temp1 = 3 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank14
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
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then SelQuadPlayersInline

          goto SelSkipQuadPlyInline
          
SelQuadPlayersInline
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
SelSkipQuadPlyInline
          rem Check if enough players are ready
          if controllerStatus & SetQuadtariDetected then SelQuadReadyInline

          rem Need at least 1 player ready for 2-player mode
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then goto SelScreenDone

          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then goto SelScreenDone

          goto SelSkipQuadChkInline
          
SelQuadReadyInline
          rem Need at least 2 players ready for 4-player mode
          if readyCount>= 2 then goto SelScreenDone
SelSkipQuadChkInline

          rem Draw character selection screen
          gosub SelDrawScreen

          rem drawscreen called by MainLoop
          return
          goto SelScreenLoop



          rem Draw character selection screen
SelDrawScreen
          rem Draw character selection screen with player sprites and numbers
          rem Input: playerChar[] (global array) = current character selections
          rem        controllerStatus (global) = controller detection state
          rem        player0-3x, player0-3y (TIA registers) = sprite positions (set by caller or inline)
          rem Output: pf0-pf5 (playfield registers) cleared, player sprites drawn, numbers drawn
          rem Mutates: pf0-pf5 (playfield registers), player0-3x, player0-3y (TIA registers),
          rem         player sprite pointers (via SelDrawSprite), playfield data (via SelDrawNumber)
          rem Called Routines: SelDrawSprite - accesses playerChar[], draws character sprites,
          rem   SelDrawNumber - draws player number indicators
          rem Constraints: Must be colocated with SelDrawP3, SelSkipP3, SelDrawP4, SelSkipP4
          rem              (all called via goto)
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

          rem Draw 1 indicator below Player 1 using playfield
          gosub SelDrawNumber

          rem Draw Player 2 selection (top right) with number
          let player1x = 104
          let player1y = 40
          rem Adjusted for 16px margins (120-16)
          gosub SelDrawSprite

          rem Draw 2 indicator below Player 2 using playfield
          gosub SelDrawNumber

          rem Draw Player 3 selection (bottom left) if Quadtari detected
          if controllerStatus & SetQuadtariDetected then SelDrawP3
          goto SelSkipP3
SelDrawP3
          rem Draw Player 3 character sprite and number
          rem Input: playerChar[] (global array) = current character selections
          rem        player0x, player0y (TIA registers) = sprite position (set inline)
          rem Output: Player 3 sprite drawn, number indicator drawn
          rem Mutates: player sprite pointers (via SelDrawSprite), playfield data (via SelDrawNumber)
          rem Called Routines: SelDrawSprite, SelDrawNumber
          rem Constraints: Must be colocated with SelDrawScreen, SelSkipP3
          player0x = 56
          player0y = 80 
          rem Adjusted for 16px left margin
          gosub SelDrawSprite

          rem Draw 3 indicator below Player 3 using playfield
          gosub SelDrawNumber

          rem Draw Player 4 selection (bottom right) if Quadtari
          rem   detected
          if controllerStatus & SetQuadtariDetected then SelDrawP4
          goto SelSkipP4
SelDrawP4
          rem Draw Player 4 character sprite and number
          rem Input: playerChar[] (global array) = current character selections
          rem        player1x, player1y (TIA registers) = sprite position (set inline)
          rem Output: Player 4 sprite drawn, number indicator drawn
          rem Mutates: player sprite pointers (via SelDrawSprite), playfield data (via SelDrawNumber)
          rem Called Routines: SelDrawSprite, SelDrawNumber
          rem Constraints: Must be colocated with SelDrawScreen, SelSkipP4
          let player1x = 104
          let player1y = 80
          rem Adjusted for 16px margins
          gosub SelDrawSprite

          rem Draw 4 indicator below Player 4 using playfield
          gosub SelDrawNumber
SelSkipP3
SelSkipP4

          rem Draw locked status indicators (playfield blocks framing
          rem   characters)
          rem tail call
          goto SelDrawLocks


          rem Draw locked status indicators
SelDrawLocks
          rem Draw locked status indicators (playfield blocks framing locked characters)
          rem Input: playerLocked (global) = player lock states, controllerStatus (global) = controller detection state
          rem Output: Playfield blocks drawn around locked characters
          rem Mutates: temp1-temp2 (used for calculations), pf0, pf1 (TIA registers) = playfield registers (bits set for borders)
          rem Called Routines: GetPlayerLocked (bank14) - gets lock state for each player
          rem Constraints: Players 3/4 only checked if Quadtari detected. Borders drawn using playfield bits
          rem Draw playfield blocks around locked characters
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then SelDrawP0Border
          goto SelSkipP0Border
SelDrawP0Border
          rem Helper: Draw border around Player 1
          rem Input: pf0, pf1 (TIA registers) = playfield registers
          rem Output: Border bits set for Player 1
          rem Mutates: pf0, pf1 (TIA registers) = playfield registers (bits ORed)
          rem Called Routines: None
          rem Constraints: Internal helper for SelDrawLocks, only called when Player 1 is locked
          rem Draw border around Player 1
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
SelSkipP0Border

          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then SelDrawP1Border
          goto SelSkipP1Border
SelDrawP1Border
          rem Helper: Draw border around Player 2
          rem Input: pf0, pf1 (TIA registers) = playfield registers
          rem Output: Border bits set for Player 2
          rem Mutates: pf0, pf1 (TIA registers) = playfield registers (bits ORed)
          rem Called Routines: None
          rem Constraints: Internal helper for SelDrawLocks, only called when Player 2 is locked
          rem Draw border around Player 2
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
SelSkipP1Border

          if controllerStatus & SetQuadtariDetected then SelectCheckPlayer2Lock
          goto SelectCheckPlayer3Lock
SelectCheckPlayer2Lock
          rem Helper: Check if Player 3 is locked and draw border
          rem Input: temp1 = player index (2), playerLocked (global) = player lock states
          rem Output: Border drawn if Player 3 is locked
          rem Mutates: temp1-temp2 (used for calculations), pf0, pf1 (TIA registers) = playfield registers (via SelectDrawPlayer2Border)
          rem Called Routines: GetPlayerLocked (bank14) - gets lock state, SelectDrawPlayer2Border - draws border
          rem Constraints: Internal helper for SelDrawLocks, only called if Quadtari detected
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then SelectDrawPlayer2Border
          rem Continue to Player 3 check
SelectDrawPlayer2Border 
          rem Helper: Draw border around Player 3
          rem Input: pf0, pf1 (TIA registers) = playfield registers
          rem Output: Border bits set for Player 3
          rem Mutates: pf0, pf1 (TIA registers) = playfield registers (bits ORed)
          rem Called Routines: None
          rem Constraints: Internal helper for SelectCheckPlayer2Lock, only called when Player 3 is locked
          rem Draw border around Player 3
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001

          if controllerStatus & SetQuadtariDetected then SelectCheckPlayer3Lock
          return
SelectCheckPlayer3Lock
          rem Helper: Check if Player 4 is locked and draw border
          rem Input: temp1 = player index (3), playerLocked (global) = player lock states
          rem Output: Border drawn if Player 4 is locked
          rem Mutates: temp1-temp2 (used for calculations), pf0, pf1 (TIA registers) = playfield registers (via SelectDrawPlayer3Border)
          rem Called Routines: GetPlayerLocked (bank14) - gets lock state, SelectDrawPlayer3Border - draws border
          rem Constraints: Internal helper for SelDrawLocks, only called if Quadtari detected
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then SelectDrawPlayer3Border
          return
SelectDrawPlayer3Border 
          rem Helper: Draw border around Player 4
          rem Input: pf0, pf1 (TIA registers) = playfield registers
          rem Output: Border bits set for Player 4
          rem Mutates: pf0, pf1 (TIA registers) = playfield registers (bits ORed)
          rem Called Routines: None
          rem Constraints: Internal helper for SelectCheckPlayer3Lock, only called when Player 4 is locked
          rem Draw border around Player 4
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
          return

          rem Draw player number indicator
SelDrawNumber
          rem Draw player number indicator (1-4) below character using playfield pixels
          rem Input: player0x, player0y, player1x, player1y (TIA registers) = sprite positions
          rem Output: Player number drawn using playfield bits (1-4 based on position)
          rem Mutates: pf0-pf5 (TIA registers) = playfield registers (bits ORed for digit patterns)
          rem Called Routines: None
          rem Constraints: Player numbers determined by position in grid (top left=1, top right=2, bottom left=3, bottom right=4). Uses simple digit patterns
          rem This function draws the player number (1-4) below the
          rem   character
          rem using playfield pixels in a simple digit pattern
          rem Player numbers are determined by position in the grid

          rem Player 1 (top left) - draw 1
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

          rem Player 2 (top right) - draw 2
          if player1x  = 104 then SelChkP1Y1
          goto DonePlayer1Check1
SelChkP1Y1
          if player1y  = 40 then SelDrawP1Top
          goto DonePlayer1Check1
SelDrawP1Top 
          pf3 = pf3 | %00010000
          pf4 = pf4 | %00001000
          pf5 = pf5 | %00010000

          rem Player 3 (bottom left) - draw 3
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

          rem Player 4 (bottom right) - draw 4
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
          rem Update character select animations (handicap preview, normal animation cycling)
          rem Input: qtcontroller (global) = Quadtari frame toggle, joy0down, joy1down (hardware) = joystick DOWN states, controllerStatus (global) = controller detection state, charSelectAnimTimer, charSelectAnimState, charSelectCharIndex, charSelectAnimFrame (global) = animation state, HandicapMode (global) = handicap flags, ActionRecovering (global constant) = recovery animation state (9), FramesPerSecond, MaxCharacter (global constants) = animation constants, rand (global) = random number generator
          rem Output: Animation state updated (frozen in recovery if handicap preview, or cycled normally)
          rem Mutates: HandicapMode (global) = handicap flags (set based on DOWN held), charSelectAnimState (global) = animation state (set to ActionRecovering if handicap, or random 0-2), charSelectAnimTimer (global) = animation timer (incremented or reset), charSelectCharIndex (global) = character index (cycled), charSelectAnimFrame (global) = animation frame (set to 0 or incremented)
          rem Called Routines: None
          rem Constraints: Handicap preview freezes animation in recovery pose (ActionRecovering=9) when any player holds DOWN. Normal animation cycles every 60 frames (1 second) with random state selection (0-2: idle, running, attacking). 8-frame animation cycles
          rem Check if any player is holding DOWN (for handicap preview)
          rem If so, freeze their character in recovery from far fall
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
          rem Helper: Check Players 3/4 for DOWN held (odd frame)
          rem Input: controllerStatus (global) = controller detection state, joy0down, joy1down (hardware) = joystick DOWN states, HandicapMode (global) = handicap flags
          rem Output: Handicap flags set for Players 3/4 if DOWN held
          rem Mutates: HandicapMode (global) = handicap flags (bits 2-3 set)
          rem Called Routines: None
          rem Constraints: Internal helper for SelUpdateAnim, only called on odd frames
          if controllerStatus & SetQuadtariDetected then SelOddFrame
          goto DoneOddFrameCheck
SelOddFrame 
          rem Helper: Check Players 3/4 DOWN states
          rem Input: joy0down, joy1down (hardware) = joystick DOWN states, HandicapMode (global) = handicap flags
          rem Output: Handicap flags set for Players 3/4
          rem Mutates: HandicapMode (global) = handicap flags (bits 2-3 set)
          rem Called Routines: None
          rem Constraints: Internal helper for SelQuadHandi, only called if Quadtari detected
                    if joy0down then let HandicapMode  = HandicapMode | 4
          rem P3 handicap flag
          if joy1down then let HandicapMode  = HandicapMode | 8
          rem P4 handicap flag
          
          
          rem If any player is holding down, set animation to recovery
          rem   pose
          if HandicapMode then SelHandleHandi
          goto SelAnimNormal
SelHandleHandi
          rem Helper: Freeze animation in recovery pose for handicap preview
          rem Input: ActionRecovering (global constant) = recovery animation state (9)
          rem Output: Animation frozen in recovery pose
          rem Mutates: charSelectAnimState (global) = animation state (set to ActionRecovering), charSelectAnimFrame (global) = animation frame (set to 0)
          rem Called Routines: None
          rem Constraints: Internal helper for SelUpdateAnim, only called when HandicapMode is set. Animation frozen (timer not updated)
          let charSelectAnimState = ActionRecovering
          rem Animation state 9 = Recovering to standing
          let charSelectAnimFrame  = 0
          rem First frame of recovery animation
          rem Do not update timer or frame - freeze the animation
          return
SelAnimNormal
          rem Helper: Update normal animation (cycling through states and frames)
          rem Input: charSelectAnimTimer, charSelectAnimState, charSelectCharIndex, charSelectAnimFrame (global) = animation state, FramesPerSecond, MaxCharacter (global constants) = animation constants, rand (global) = random number generator
          rem Output: Animation state and frame updated
          rem Mutates: charSelectAnimTimer (global) = animation timer (incremented or reset), charSelectAnimState (global) = animation state (random 0-2 every 60 frames), charSelectCharIndex (global) = character index (cycled), charSelectAnimFrame (global) = animation frame (incremented, wraps at 8)
          rem Called Routines: None
          rem Constraints: Internal helper for SelUpdateAnim, only called when no handicap preview. Changes animation state every 60 frames (1 second) with random selection (0-2)
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
          rem Draw animated character sprite based on current animation state
          rem Input: charSelectAnimState, charSelectAnimFrame (global) = animation state and frame, charSelectPlayer (global) = player number (1-4), switchbw (global) = B&W switch state, ActionStanding, ActionWalking, ActionAttackWindup (global constants) = animation states, ColIndigo, ColRed, ColYellow, ColGreen, ColGrey (global constants) = color functions
          rem Output: Character sprite drawn with appropriate color and animation pattern
          rem Mutates: temp1 (used for animation state check), COLUP0 (TIA register) = player color (set based on player number and hurt status), player sprite graphics (set based on animation state and frame)
          rem Called Routines: None
          rem Constraints: Colors based on player number (1=Indigo, 2=Red, 3=Yellow, 4=Green) and hurt status (dimmer if hurt). Animation states: ActionStanding=idle, ActionWalking=running, ActionAttackWindup=attacking. Uses animation state 2 as hurt simulation
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
          rem Helper: Set hurt color for B&W mode
          rem Input: None
          rem Output: COLUP0 set to dark grey
          rem Mutates: COLUP0 (TIA register) = player color (set to ColGrey(6))
          rem Called Routines: None
          rem Constraints: Internal helper for SelDrawSprite, only called in hurt state and B&W mode
          let COLUP0  = ColGrey(6)
          rem Dark grey for hurt (B&W)
          goto SelColorDone
SelColorNormal
          rem Helper: Set normal color (bright)
          rem Input: charSelectPlayer (global) = player number, switchbw (global) = B&W switch state
          rem Output: COLUP0 set to bright player color or bright grey (B&W)
          rem Mutates: COLUP0 (TIA register) = player color (set to bright color)
          rem Called Routines: SelColorBW - sets B&W color
          rem Constraints: Internal helper for SelDrawSprite, only called in normal state
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
          rem Helper: Set normal color for B&W mode
          rem Input: None
          rem Output: COLUP0 set to bright grey
          rem Mutates: COLUP0 (TIA register) = player color (set to ColGrey(14))
          rem Called Routines: None
          rem Constraints: Internal helper for SelColorNormal, only called in B&W mode
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
          rem Helper: Draw idle animation (standing pose)
          rem Input: None
          rem Output: Idle sprite pattern set
          rem Mutates: Player sprite graphics (set to idle pattern)
          rem Called Routines: None
          rem Constraints: Internal helper for SelDrawSprite, only called for ActionStanding
          rem Idle animation - simple standing pose
          goto SelAnimDone
SelAnimRun
          rem Helper: Draw running animation (alternating leg positions)
          rem Input: charSelectAnimFrame (global) = animation frame
          rem Output: Running sprite pattern set (alternating legs)
          rem Mutates: Player sprite graphics (set to running pattern)
          rem Called Routines: SelLeftLeg - sets left leg forward pattern
          rem Constraints: Internal helper for SelDrawSprite, only called for ActionWalking. Frames 0,2,4,6 = right leg forward, frames 1,3,5,7 = left leg forward
          rem Running animation - alternating leg positions
          if charSelectAnimFrame & 1 then SelLeftLeg
          rem Frame 0,2,4,6 - right leg forward
          goto SelAnimDone
SelLeftLeg
          rem Helper: Set left leg forward pattern for running
          rem Input: None
          rem Output: Left leg forward sprite pattern set
          rem Mutates: Player sprite graphics (set to left leg forward pattern)
          rem Called Routines: None
          rem Constraints: Internal helper for SelAnimRun, only called for odd frames (1,3,5,7)
          rem Frame 1,3,5,7 - left leg forward
          goto SelAnimDone
SelAnimAttack
          rem Helper: Draw attacking animation (arm extended)
          rem Input: charSelectAnimFrame (global) = animation frame
          rem Output: Attacking sprite pattern set (arm extended or windup)
          rem Mutates: Player sprite graphics (set to attack pattern)
          rem Called Routines: SelWindup - sets windup pattern
          rem Constraints: Internal helper for SelDrawSprite, only called for ActionAttackWindup. Frames 0-3 = windup, frames 4-7 = attack
          rem Attacking animation - arm extended
          if charSelectAnimFrame < 4 then SelWindup
          rem Attack frames - arm forward
          goto SelAnimDone
SelWindup
          rem Helper: Set windup pattern for attack
          rem Input: None
          rem Output: Windup sprite pattern set
          rem Mutates: Player sprite graphics (set to windup pattern)
          rem Called Routines: None
          rem Constraints: Internal helper for SelAnimAttack, only called for frames 0-3
          rem Windup frames - arm back
          goto SelAnimDone
SelAnimDone
          return

SelScreenDone
          rem Character selection complete (stores selected characters and initializes facing directions)
          rem Input: playerChar[] (global array) = current character selections, selectedChar1, selectedChar2_R, selectedChar3_R, selectedChar4_R (global SCRAM) = stored selections, playerState[] (global array) = player states, NoCharacter (global constant) = no character constant
          rem Output: Selected characters stored, facing directions initialized (default: face right = 1)
          rem Mutates: selectedChar1 (global) = player 1 selection (set), selectedChar2_W, selectedChar3_W, selectedChar4_W (global SCRAM) = player 2-4 selections (set), playerState[] (global array) = player states (facing bit set for selected players)
          rem Called Routines: None
          rem Constraints: Only sets facing bit for players with valid character selections (not NoCharacter). Default facing: right (bit 0 = 1)
          rem Character selection complete
          rem Store selected characters for use in game
          let selectedChar1  = playerChar[0]
          let selectedChar2_W  = playerChar[1]
          let selectedChar3_W  = playerChar[2]
          let selectedChar4_W  = playerChar[3]
          
          rem Initialize facing bit (bit 0) for all selected players
          rem   (default: face right = 1)
          if selectedChar1 = NoCharacter then SkipChar1FacingSel
          let playerState[0] = playerState[0] | 1
SkipChar1FacingSel
          if selectedChar2_R = NoCharacter then SkipChar2FacingSel
          let playerState[1] = playerState[1] | 1
SkipChar2FacingSel
          if selectedChar3_R = NoCharacter then SkipChar3FacingSel
          let playerState[2] = playerState[2] | 1
SkipChar3FacingSel
          if selectedChar4_R = NoCharacter then SkipChar4FacingSel
          let playerState[3] = playerState[3] | 1
SkipChar4FacingSel

          rem Proceed to falling animation
          return

          rem Detect Quadtari adapter
SelDetectQuad
          rem Detect Quadtari adapter (canonical detection: check paddle ports INPT0-3)
          rem Input: INPT0-3 (hardware registers) = paddle port states, controllerStatus (global) = controller detection state, SetQuadtariDetected (global constant) = Quadtari detection flag
          rem Output: Quadtari detection flag set if adapter detected
          rem Mutates: controllerStatus (global) = controller detection state (Quadtari flag set if detected)
          rem Called Routines: None
          rem Constraints: Requires BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) AND Right (INPT2 LOW, INPT3 HIGH). Uses monotonic merge (OR) to preserve existing capabilities (upgrades only, never downgrades). If Quadtari was previously detected, it remains detected
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
          rem Helper: Quadtari not detected in this detection cycle
          rem Input: None
          rem Output: No changes (monotonic detection preserves previous state)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Internal helper for SelDetectQuad, only called when Quadtari not detected. Does NOT clear controllerStatus - monotonic detection (upgrades only). Only DetectControllers (called via SELECT) can update controller status
          rem Quadtari not detected in this detection cycle
          rem NOTE: Do NOT clear controllerStatus - monotonic detection
          rem   (upgrades only)
          rem If Quadtari was previously detected, it remains detected
          rem   (monotonic state machine)
          rem Only DetectControllers (called via SELECT) can update
          rem   controller status
          return
          
SelSkipQuadAbs
          rem Helper: Quadtari detected - set detection flag
          rem Input: controllerStatus (global) = controller detection state, SetQuadtariDetected (global constant) = Quadtari detection flag
          rem Output: Quadtari detection flag set
          rem Mutates: controllerStatus (global) = controller detection state (Quadtari flag set via OR merge)
          rem Called Routines: None
          rem Constraints: Internal helper for SelDetectQuad, only called when Quadtari detected. Uses monotonic merge (OR) to preserve existing capabilities (upgrades only, never downgrades)
          rem Quadtari detected - use monotonic merge to preserve
          rem   existing capabilities
          rem OR merge ensures upgrades only, never downgrades
          let controllerStatus  = controllerStatus | SetQuadtariDetected
          return
