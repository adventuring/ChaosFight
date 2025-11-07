SelScreenEntry
          rem ChaosFight - Source/Routines/SelScreenEntry.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem PlayerLockedHelpers.bas moved to Bank 1

          rem Initialize character select screen state
          rem
          rem Input: None (entry point)
          rem
          rem Output: playerCharacter[] initialized, playerLocked
          rem initialized, animation state initialized,
          rem         COLUBK set, Quadtari detection called
          rem
          rem Mutates: playerCharacter[0-3] (set to 0), playerLocked (set to
          rem 0), characterSelectAnimationTimer,
          rem         characterSelectAnimationState, characterSelectCharacterIndex,
          rem         characterSelectAnimationFrame, COLUBK (TIA register)
          rem
          rem Called Routines: SelDetectQuad - accesses controller
          rem detection state
          rem
          rem Constraints: Entry point for character select screen
          rem initialization
          rem              Must be colocated with SelScreenLoop (called
          rem              via goto)
          let playerCharacter[0] = 0 : rem Initialize character selections
          let playerCharacter[1] = 0
          let playerCharacter[2] = 0
          let playerCharacter[3] = 0
          let playerLocked = 0 : rem Initialize playerLocked (bit-packed, all unlocked)
          rem NOTE: Do NOT clear controllerStatus flags here - monotonic
          rem   detection (upgrades only)
          rem Controller detection is handled by DetectControllers with
          rem   monotonic state machine
          
          let characterSelectAnimationTimer  = 0 : rem Initialize character select animations
          let characterSelectAnimationState  = 0
          let characterSelectCharacterIndex  = 0 : rem Start with idle animation
          let characterSelectAnimationFrame  = 0 : rem Start with first character

          gosub SelDetectQuad : rem Check for Quadtari adapter

          let COLUBK  = ColGray(0) : rem Set background color (B&W safe)
          rem Always black background

SelScreenLoop
          rem Per-frame character select screen loop with Quadtari
          rem multiplexing
          rem
          rem Input: qtcontroller (global) = Quadtari controller frame
          rem toggle
          rem        joy0left, joy0right, joy0up, joy0down, joy0fire
          rem        (hardware) = Player 1/3 joystick
          rem        joy1left, joy1right, joy1up, joy1down, joy1fire
          rem        (hardware) = Player 2/4 joystick
          rem        playerCharacter[] (global array) = current character
          rem        selections
          rem        playerLocked (global) = player lock states
          rem        MaxCharacter (constant) = maximum character index
          rem
          rem Output: Dispatches to SelHandleQuad or processes even
          rem frame input, then returns
          rem
          rem Mutates: qtcontroller (toggled), playerCharacter[],
          rem playerLocked state, temp1, temp2 (passed to
          rem SetPlayerLocked)
          rem
          rem Called Routines: SetPlayerLocked (bank1) - accesses
          rem playerLocked state
          rem
          rem Constraints: Must be colocated with SelChkP0Left,
          rem SelSkipP0Left, SelChkP0Right, SelSkipP0Right,
          rem              SelChkJoy0Fire, SelJoy0Down, SelP0Lock,
          rem              SelP0Handi, SelP0Done,
          rem              SelChkP1Left, SelSkipP1Left, SelChkP1Right,
          rem              SelSkipP1Right,
          rem              SelChkJoy1Fire, SelJoy1Down, SelJoy1Chk,
          rem              SelJoy1Done, SelSkipJoy1Even,
          rem              SelHandleQuad (all called via goto)
          rem              Entry point for character select screen loop
          rem Quadtari controller multiplexing:
          rem On even frames (qtcontroller=0): handle controllers 0 and
          rem   1
          rem On odd frames (qtcontroller=1): handle controllers 2 and 3
          rem   (if Quadtari detected)
          
          if qtcontroller then goto SelHandleQuad
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then let playerCharacter[0] = playerCharacter[0] - 1 : goto SelChkP0Left
          goto SelSkipP0Left

SelChkP0Left
          if playerCharacter[0] > MaxCharacter then let playerCharacter[0] = MaxCharacter
          if playerCharacter[0] > MaxCharacter then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          
SelSkipP0Left
          if joy0right then let playerCharacter[0] = playerCharacter[0] + 1 : goto SelChkP0Right
          goto SelSkipP0Right

SelChkP0Right
          if playerCharacter[0] > MaxCharacter then let playerCharacter[0] = 0
          if playerCharacter[0] > MaxCharacter then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          
SelSkipP0Right
          if joy0up then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          if joy0down then SelChkJoy0Fire : rem Unlock by moving up
          goto SelJoy0Down

SelChkJoy0Fire
          if joy0fire then SelJoy0Down
          let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          
SelJoy0Down
          if joy0fire then SelP0Lock : rem Unlock by moving down (without fire)
          goto SelP0Done

SelP0Lock
          if joy0down then SelP0Handi
          let temp1 = 0 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          goto SelP0Done : rem Locked normal (100% health)

SelP0Handi
          let temp1 = 0 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank1
SelP0Done
          rem Locked with handicap (75% health)

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then let playerCharacter[1] = playerCharacter[1] - 1 : goto SelChkP1Left
          goto SelSkipP1Left

SelChkP1Left
          if playerCharacter[1] > MaxCharacter then let playerCharacter[1] = MaxCharacter
          if playerCharacter[1] > MaxCharacter then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP1Left
          if joy1right then let playerCharacter[1] = playerCharacter[1] + 1 : goto SelChkP1Right
          goto SelSkipP1Right

SelChkP1Right
          if playerCharacter[1] > MaxCharacter then let playerCharacter[1] = 0
          if playerCharacter[1] > MaxCharacter then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP1Right
          if joy1up then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          if joy1down then SelChkJoy1Fire : rem Unlock by moving up

          goto SelJoy1Down

SelChkJoy1Fire
          if joy1fire then SelJoy1Down

          let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelJoy1Down
          if joy1fire then SelJoy1Chk : rem Unlock by moving down (without fire)

          goto SelSkipJoy1Even

SelJoy1Chk
          if joy1down then let temp1 = 1 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank1 : goto SelJoy1Done

          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1 : rem Locked with handicap (75% health)
SelJoy1Done 
          rem Locked normal (100% health)

SelSkipJoy1Even
          let qtcontroller  = 1 : rem Switch to odd frame mode for next iteration
          goto SelHandleDone

SelHandleQuad
          if controllerStatus & SetQuadtariDetected then SelHandleP2 : rem Handle Player 3 input (joy0 on odd frames, Quadtari only)

          goto SelSkipP2

SelHandleP2
          if joy0left then let playerCharacter[2] = playerCharacter[2] - 1 : goto SelChkP2Left

          goto SelSkipP2Left

SelChkP2Left
          if playerCharacter[2] > MaxCharacter then let playerCharacter[2] = MaxCharacter
          if playerCharacter[2] > MaxCharacter then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP2Left
          if joy0right then let playerCharacter[2] = playerCharacter[2] + 1 : goto SelChkP2Right

          goto SelSkipP2Right

SelChkP2Right
          if playerCharacter[2] > MaxCharacter then let playerCharacter[2] = 0
          if playerCharacter[2] > MaxCharacter then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP2Right
          if joy0up then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          if joy0down then SelChkJoy0Fire2 : rem Unlock by moving up

          goto SelJoy0Down2

SelChkJoy0Fire2
          if joy0fire then SelJoy0Down2
          let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelJoy0Down2
          if joy0fire then SelChkJoy0Down2 : rem Unlock by moving down (without fire)

          goto SelJoy0Done2

SelChkJoy0Down2
          if joy0down then SelSetHand2

          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          goto SelJoy0Done2 : rem Locked normal (100% health)

SelSetHand2
          let temp1 = 2 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank1
SelJoy0Done2
          rem Locked with handicap (75% health)

          if controllerStatus & SetQuadtariDetected then SelHandleP3 : rem Handle Player 4 input (joy1 on odd frames, Quadtari only)

          goto SelSkipP3Alt

SelHandleP3
          if joy1left then let playerCharacter[3] = playerCharacter[3] - 1 : goto SelCheckP3Left
          goto SelSkipP3Left
SelCheckP3Left
          if playerCharacter[3] > MaxCharacter then let playerCharacter[3] = MaxCharacter
          if playerCharacter[3] > MaxCharacter then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP3Left
          if joy1right then let playerCharacter[3] = playerCharacter[3] + 1 : goto SelCheckP3Right
          goto SelSkipP3Right
SelCheckP3Right
          if playerCharacter[3] > MaxCharacter then let playerCharacter[3] = 0
          if playerCharacter[3] > MaxCharacter then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelSkipP3Right
          if joy1up then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
          if joy1down then SelChkJoy1Fire3 : rem Unlock by moving up

          goto SelJoy1Down3

SelChkJoy1Fire3
          if joy1fire then SelJoy1Down3

          let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
SelJoy1Down3
          if joy1fire then SelJoy1Chk3 : rem Unlock by moving down (without fire)

          goto SelSkipJoy1Odd

SelJoy1Chk3
          if joy1down then SelSetHand3

          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto SelJoy1Done3 : rem Locked normal (100% health)

SelSetHand3
          let temp1 = 3 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
SelJoy1Done3
          rem Locked with handicap (75% health)
          
          let qtcontroller  = 0 : rem Switch back to even frame mode for next iteration
SelSkipP2
SelSkipP3Alt
SelSkipJoy1Odd

SelHandleDone

          gosub SelUpdateAnimation : rem Update character select animations

          rem Check if all players are ready to start (inline
          let readyCount  = 0 : rem   SelAllReady)

          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1 : rem Count locked players
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then SelQuadPlayersInline

          goto SelSkipQuadPlyInline
          
SelQuadPlayersInline
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
SelSkipQuadPlyInline
          if controllerStatus & SetQuadtariDetected then SelQuadReadyInline : rem Check if enough players are ready

          rem Need at least 1 player ready for 2-player mode
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then goto SelScreenDone

          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then goto SelScreenDone

          goto SelSkipQuadChkInline
          
SelQuadReadyInline
          if readyCount>= 2 then goto SelScreenDone : rem Need at least 2 players ready for 4-player mode
SelSkipQuadChkInline

          gosub SelDrawScreen : rem Draw character selection screen

          rem drawscreen called by MainLoop
          return
          goto SelScreenLoop



SelDrawScreen
          rem Draw character selection screen via shared renderer
          gosub bank10 SelectDrawScreen
          return

SelDrawScreenLegacy
          rem Legacy implementation retained for historical reference; do not execute
          return
LegacySelDrawScreenBody
          rem Draw character selection screen
          rem Draw character selection screen with player sprites and
          rem numbers
          rem
          rem Input: playerCharacter[] (global array) = current character
          rem selections
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        player0-3x, player0-3y (TIA registers) = sprite
          rem        positions (set by caller or inline)
          rem
          rem Output: player sprites drawn, numbers drawn
          rem
          rem Mutates: player0-3x, player0-3y (TIA registers),
          rem         player sprite pointers (via SelDrawSprite),
          rem         playfield data (via SelDrawNumber)
          rem
          rem Called Routines: SelDrawSprite - accesses playerCharacter[],
          rem draws character sprites,
          rem   SelDrawNumber - draws player number indicators
          rem
          rem Constraints: Must be colocated with SelDrawP3, SelSkipP3,
          rem SelDrawP4, SelSkipP4
          rem              (all called via goto)
          rem Draw Player 1 selection (top left) with number
          player0x = 56
          player0y = 40 
          gosub SelDrawSprite : rem Adjusted for 16px left margin (40+16)

          gosub SelDrawNumber : rem Draw 1 indicator below Player 1 using playfield

          let player1x = 104 : rem Draw Player 2 selection (top right) with number
          let player1y = 40
          gosub SelDrawSprite : rem Adjusted for 16px margins (120-16)

          gosub SelDrawNumber : rem Draw 2 indicator below Player 2 using playfield

          if controllerStatus & SetQuadtariDetected then SelDrawP3 : rem Draw Player 3 selection (bottom left) if Quadtari detected
          goto SelSkipP3
SelDrawP3
          rem Draw Player 3 character sprite and number
          rem
          rem Input: playerCharacter[] (global array) = current character
          rem selections
          rem        player0x, player0y (TIA registers) = sprite
          rem        position (set inline)
          rem
          rem Output: Player 3 sprite drawn, number indicator drawn
          rem
          rem Mutates: player sprite pointers (via SelDrawSprite),
          rem playfield data (via SelDrawNumber)
          rem
          rem Called Routines: SelDrawSprite, SelDrawNumber
          rem
          rem Constraints: Must be colocated with SelDrawScreen,
          rem SelSkipP3
          player0x = 56
          player0y = 80 
          gosub SelDrawSprite : rem Adjusted for 16px left margin

          gosub SelDrawNumber : rem Draw 3 indicator below Player 3 using playfield

          rem Draw Player 4 selection (bottom right) if Quadtari
          if controllerStatus & SetQuadtariDetected then SelDrawP4 : rem   detected
          goto SelSkipP4
SelDrawP4
          rem Draw Player 4 character sprite and number
          rem
          rem Input: playerCharacter[] (global array) = current character
          rem selections
          rem        player1x, player1y (TIA registers) = sprite
          rem        position (set inline)
          rem
          rem Output: Player 4 sprite drawn, number indicator drawn
          rem
          rem Mutates: player sprite pointers (via SelDrawSprite),
          rem playfield data (via SelDrawNumber)
          rem
          rem Called Routines: SelDrawSprite, SelDrawNumber
          let player1x = 104 : rem Constraints: Must be colocated with SelDrawScreen, SelSkipP4
          let player1y = 80
          gosub SelDrawSprite : rem Adjusted for 16px margins

          gosub SelDrawNumber : rem Draw 4 indicator below Player 4 using playfield
SelSkipP3
SelSkipP4

          rem Draw locked status indicators (playfield blocks framing
          rem   characters)
          goto SelDrawLocks : rem tail call


SelDrawLocks
          rem Draw locked status indicators
          rem Draw locked status indicators (playfield blocks framing
          rem locked characters)
          rem
          rem Input: playerLocked (global) = player lock states,
          rem controllerStatus (global) = controller detection state
          rem
          rem Output: Playfield blocks drawn around locked characters
          rem
          rem Mutates: temp1-temp2 (used for calculations)
          rem (TIA registers) = playfield registers (bits set for
          rem borders)
          rem
          rem Called Routines: GetPlayerLocked (bank14) - gets lock
          rem state for each player
          rem
          rem Constraints: Players 3/4 only checked if Quadtari
          rem detected. Borders drawn using playfield bits
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then SelDrawP0Border : rem Draw playfield blocks around locked characters
          goto SelSkipP0Border
SelDrawP0Border
SelSkipP0Border
          rem Helper: Draw border around Player 1
          rem
          rem Input: legacy playfield registers (unused)
          rem
          rem Output: Border bits set for Player 1
          rem
          rem Mutates: legacy playfield registers (unused)
          rem (bits ORed)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelDrawLocks, only called
          rem when Player 1 is locked
          rem Draw border around Player 1

          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then SelDrawP1Border
          goto SelSkipP1Border
SelDrawP1Border
SelSkipP1Border
          rem Helper: Draw border around Player 2
          rem
          rem Input: legacy playfield registers (unused)
          rem
          rem Output: Border bits set for Player 2
          rem
          rem Mutates: legacy playfield registers (unused)
          rem (bits ORed)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelDrawLocks, only called
          rem when Player 2 is locked
          rem Draw border around Player 2

          if controllerStatus & SetQuadtariDetected then SelectCheckPlayer2Lock
          goto SelectCheckPlayer3Lock
SelectCheckPlayer2Lock
          rem Helper: Check if Player 3 is locked and draw border
          rem
          rem Input: temp1 = player index (2), playerLocked (global) =
          rem player lock states
          rem
          rem Output: Border drawn if Player 3 is locked
          rem
          rem Mutates: temp1-temp2 (used for calculations)
          rem (TIA registers) = playfield registers (via
          rem SelectDrawPlayer2Border)
          rem
          rem Called Routines: GetPlayerLocked (bank14) - gets lock
          rem state, SelectDrawPlayer2Border - draws border
          rem
          rem Constraints: Internal helper for SelDrawLocks, only called
          rem if Quadtari detected
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then SelectDrawPlayer2Border
          rem Continue to Player 3 check
SelectDrawPlayer2Border 
          rem Helper: Draw border around Player 3
          rem
          rem Input: legacy playfield registers (unused)
          rem
          rem Output: Border bits set for Player 3
          rem
          rem Mutates: legacy playfield registers (unused)
          rem (bits ORed)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelectCheckPlayer2Lock,
          rem only called when Player 3 is locked
          rem Draw border around Player 3

          if controllerStatus & SetQuadtariDetected then SelectCheckPlayer3Lock
          return
SelectCheckPlayer3Lock
          rem Helper: Check if Player 4 is locked and draw border
          rem
          rem Input: temp1 = player index (3), playerLocked (global) =
          rem player lock states
          rem
          rem Output: Border drawn if Player 4 is locked
          rem
          rem Mutates: temp1-temp2 (used for calculations)
          rem (TIA registers) = playfield registers (via
          rem SelectDrawPlayer3Border)
          rem
          rem Called Routines: GetPlayerLocked (bank14) - gets lock
          rem state, SelectDrawPlayer3Border - draws border
          rem
          rem Constraints: Internal helper for SelDrawLocks, only called
          rem if Quadtari detected
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then SelectDrawPlayer3Border
          return
SelectDrawPlayer3Border 
          return
SelDrawNumber
          rem Draw number indicator via shared renderer
          gosub bank10 SelectDrawNumber
          return

SelDrawNumberLegacy
          rem Legacy implementation retained for historical reference; do not execute
          return
LegacySelDrawNumberBody
          rem Helper: Draw border around Player 4
          rem
          rem Input: legacy playfield registers (unused)
          rem
          rem Output: Border bits set for Player 4
          rem
          rem Mutates: legacy playfield registers (unused)
          rem (bits ORed)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelectCheckPlayer3Lock,
          rem only called when Player 4 is locked
          rem Draw border around Player 4
          rem Draw player number indicator
          rem Draw player number indicator (1-4) below character using
          rem playfield pixels
          rem
          rem Input: player0x, player0y, player1x, player1y (TIA
          rem registers) = sprite positions
          rem
          rem Output: Player number drawn using playfield bits (1-4
          rem based on position)
          rem
          rem Mutates: legacy playfield registers (unused)
          rem (bits ORed for digit patterns)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Player numbers determined by position in grid
          rem (top left=1, top right=2, bottom left=3, bottom right=4).
          rem Uses simple digit patterns
          rem This function draws the player number (1-4) below the
          rem   character
          rem using playfield pixels in a simple digit pattern
          rem Player numbers are determined by position in the grid

          if player0x  = 56 then SelChkP0Y1 : rem Player 1 (top left) - draw 1
          goto DonePlayer0Check1
SelChkP0Y1
          if player0y  = 40 then SelDrawP0Top
          goto DonePlayer0Check1
SelDrawP0Top 
          return

          if player1x  = 104 then SelChkP1Y1 : rem Player 2 (top right) - draw 2
          goto DonePlayer1Check1
SelChkP1Y1
          if player1y  = 40 then SelDrawP1Top
          goto DonePlayer1Check1
SelDrawP1Top 
          return

          if player0x  = 56 then SelChkP0Y2 : rem Player 3 (bottom left) - draw 3
          goto DonePlayer0Check2
SelChkP0Y2
          if player0y  = 80 then SelDrawP0Bot
          goto DonePlayer0Check2
SelDrawP0Bot 
          return

          if player1x  = 104 then SelChkP1Y2 : rem Player 4 (bottom right) - draw 4
          goto DonePlayer1Check2
SelChkP1Y2
          if player1y  = 80 then SelDrawP1Bot
          goto DonePlayer1Check2
SelDrawP1Bot 
          return
          return

SelUpdateAnimation
          rem Update character select animations
          rem Update character select animations (handicap preview,
          rem normal animation cycling)
          rem
          rem Input: qtcontroller (global) = Quadtari frame toggle,
          rem joy0down, joy1down (hardware) = joystick DOWN states,
          rem controllerStatus (global) = controller detection state,
          rem characterSelectAnimationTimer, characterSelectAnimationState,
          rem characterSelectCharacterIndex, characterSelectAnimationFrame (global) =
          rem animation state, HandicapMode (global) = handicap flags,
          rem ActionRecovering (global constant) = recovery animation
          rem state (9), FramesPerSecond, MaxCharacter (global
          rem constants) = animation constants, rand (global) = random
          rem number generator
          rem
          rem Output: Animation state updated (frozen in recovery if
          rem handicap preview, or cycled normally)
          rem
          rem Mutates: HandicapMode (global) = handicap flags (set based
          rem on DOWN held), characterSelectAnimationState (global) = animation
          rem state (set to ActionRecovering if handicap, or random
          rem 0-2), characterSelectAnimationTimer (global) = animation timer
          rem (incremented or reset), characterSelectCharacterIndex (global) =
          rem character index (cycled), characterSelectAnimationFrame (global) =
          rem animation frame (set to 0 or incremented)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Handicap preview freezes animation in
          rem recovery pose (ActionRecovering=9) when any player holds
          rem DOWN. Normal animation cycles every 60 frames (1 second)
          rem with random state selection (0-2: idle, running,
          rem attacking). 8-frame animation cycles
          rem Check if any player is holding DOWN (for handicap preview)
          rem If so, freeze their character in recovery from far fall
          rem   pose (animation state 9)
          let HandicapMode  = 0 : rem HandicapMode is defined in Variables.bas as variable i
          
          if qtcontroller then goto DoneEvenFrameCheck : rem Check each player for DOWN held (even frame for P1/P2)
                    if joy0down then let HandicapMode  = HandicapMode | 1
          if joy1down then let HandicapMode  = HandicapMode | 2 : rem P1 handicap flag
          rem P2 handicap flag
          
          
          if qtcontroller then SelQuadHandi : rem Check each player for DOWN held (odd frame for P3/P4)
          goto DoneOddFrameCheck
SelQuadHandi
          rem Helper: Check Players 3/4 for DOWN held (odd frame)
          rem
          rem Input: controllerStatus (global) = controller detection
          rem state, joy0down, joy1down (hardware) = joystick DOWN
          rem states, HandicapMode (global) = handicap flags
          rem
          rem Output: Handicap flags set for Players 3/4 if DOWN held
          rem
          rem Mutates: HandicapMode (global) = handicap flags (bits 2-3
          rem set)
          rem
          rem Called Routines: None
          if controllerStatus & SetQuadtariDetected then SelOddFrame : rem Constraints: Internal helper for SelUpdateAnimation, only called on odd frames
          goto DoneOddFrameCheck
SelOddFrame 
          rem Helper: Check Players 3/4 DOWN states
          rem
          rem Input: joy0down, joy1down (hardware) = joystick DOWN
          rem states, HandicapMode (global) = handicap flags
          rem
          rem Output: Handicap flags set for Players 3/4
          rem
          rem Mutates: HandicapMode (global) = handicap flags (bits 2-3
          rem set)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelQuadHandi, only called
          rem if Quadtari detected
                    if joy0down then let HandicapMode  = HandicapMode | 4
          if joy1down then let HandicapMode  = HandicapMode | 8 : rem P3 handicap flag
          rem P4 handicap flag
          
          
          rem If any player is holding down, set animation to recovery
          if HandicapMode then SelHandleHandi : rem   pose
          goto SelectAnimationNormal
SelHandleHandi
          rem Helper: Freeze animation in recovery pose for handicap
          rem preview
          rem
          rem Input: ActionRecovering (global constant) = recovery
          rem animation state (9)
          rem
          rem Output: Animation frozen in recovery pose
          rem
          rem Mutates: characterSelectAnimationState (global) = animation state
          rem (set to ActionRecovering), characterSelectAnimationFrame (global) =
          rem animation frame (set to 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelUpdateAnimation, only
          rem called when HandicapMode is set. Animation frozen (timer
          rem not updated)
          let characterSelectAnimationState = ActionRecovering
          let characterSelectAnimationFrame  = 0 : rem Animation state 9 = Recovering to standing
          rem First frame of recovery animation
          rem Do not update timer or frame - freeze the animation
          return
SelectAnimationNormal
          rem Helper: Update normal animation (cycling through states
          rem and frames)
          rem
          rem Input: characterSelectAnimationTimer, characterSelectAnimationState,
          rem characterSelectCharacterIndex, characterSelectAnimationFrame (global) =
          rem animation state, FramesPerSecond, MaxCharacter (global
          rem constants) = animation constants, rand (global) = random
          rem number generator
          rem
          rem Output: Animation state and frame updated
          rem
          rem Mutates: characterSelectAnimationTimer (global) = animation timer
          rem (incremented or reset), characterSelectAnimationState (global) =
          rem animation state (random 0-2 every 60 frames),
          rem characterSelectCharacterIndex (global) = character index (cycled),
          rem characterSelectAnimationFrame (global) = animation frame
          rem (incremented, wraps at 8)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelUpdateAnimation, only
          rem called when no handicap preview. Changes animation state
          rem every 60 frames (1 second) with random selection (0-2)
          rem Normal animation updates (only when no handicap mode
          rem   active)
          let characterSelectAnimationTimer  = characterSelectAnimationTimer + 1 : rem Increment animation timer
          
          rem Change animation state every 60 frames (1 second at 60fps)
          if characterSelectAnimationTimer <= FramesPerSecond then goto SelectAnimationAdvance
SelectAnimationReset
          let characterSelectAnimationTimer  = 0
          let characterSelectAnimationState  = rand & 3 : rem Randomly choose new animation state
          if characterSelectAnimationState > 2 then let characterSelectAnimationState  = 0 : rem 0-3: idle, running, attacking, special
          let characterSelectAnimationFrame  = 0 : rem Keep to 0-2 range
          let characterSelectCharacterIndex  = characterSelectCharacterIndex + 1 : rem Cycle through characters for variety
          if characterSelectCharacterIndex > MaxCharacter then let characterSelectCharacterIndex  = 0
SelectAnimationAdvance
          let characterSelectAnimationFrame  = characterSelectAnimationFrame + 1 : rem Update animation frame within current state
          if characterSelectAnimationFrame <= 7 then return
          let characterSelectAnimationFrame  = 0
          rem 8-frame animation cycles
          
          return

SelDrawSprite
          rem Draw character sprite with animation
          rem Draw animated character sprite based on current animation
          rem state
          rem
          rem Input: characterSelectAnimationState, characterSelectAnimationFrame (global) =
          rem animation state and frame, characterSelectPlayer (global) =
          rem player number (1-4), switchbw (global) = B&W switch state,
          rem ActionStanding, ActionWalking, ActionAttackWindup (global
          rem constants) = animation states, ColIndigo, ColRed,
          rem ColYellow, ColGreen, ColGrey (global constants) = color
          rem functions
          rem
          rem Output: Character sprite drawn with appropriate color and
          rem animation pattern
          rem
          rem Mutates: temp1 (used for animation state check), COLUP0
          rem (TIA register) = player color (set based on player number
          rem and hurt status), player sprite graphics (set based on
          rem animation state and frame)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Colors based on player number (1=Indigo,
          rem 2=Red, 3=Yellow, 4=Green) and hurt status (dimmer if
          rem hurt). Animation states: ActionStanding=idle,
          rem ActionWalking=running, ActionAttackWindup=attacking. Uses
          rem animation state 2 as hurt simulation
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
          let temp1  = characterSelectAnimationState : rem For character select, we will use a simple hurt simulation
          rem Use animation state as hurt simulation for demo
          
          if !(temp1 = 2) then SelColorNormal
          if switchbw then SelHurtBW : rem Hurt state - dimmer colors
          if characterSelectPlayer = 1 then COLUP0  = ColIndigo(6) : rem Player color but dimmer
          if characterSelectPlayer = 2 then COLUP0  = ColRed(6) : rem Dark indigo (Player 1)
          if characterSelectPlayer = 3 then COLUP0  = ColYellow(6) : rem Dark red (Player 2)
          if characterSelectPlayer = 4 then COLUP0  = ColGreen(6) : rem Dark yellow (Player 3)
          goto SelColorDone : rem Dark green
SelHurtBW
          rem Helper: Set hurt color for B&W mode
          rem
          rem Input: None
          rem
          rem Output: COLUP0 set to dark grey
          rem
          rem Mutates: COLUP0 (TIA register) = player color (set to
          rem ColGrey(6))
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelectDrawSprite, only
          rem called in hurt state and B&W mode
          let COLUP0  = ColGrey(6)
          goto SelColorDone : rem Dark grey for hurt (B&W)
SelColorNormal
          rem Helper: Set normal color (bright)
          rem
          rem Input: characterSelectPlayer (global) = player number, switchbw
          rem (global) = B&W switch state
          rem
          rem Output: COLUP0 set to bright player color or bright grey
          rem (B&W)
          rem
          rem Mutates: COLUP0 (TIA register) = player color (set to
          rem bright color)
          rem
          rem Called Routines: SelColorBW - sets B&W color
          rem
          rem Constraints: Internal helper for SelDrawSprite, only
          rem called in normal state
          if switchbw then SelColorBW : rem Normal state - bright colors
          if characterSelectPlayer = 1 then COLUP0  = ColIndigo(12) : rem Player color - bright
          if characterSelectPlayer = 2 then COLUP0  = ColRed(12) : rem Bright indigo (Player 1)
          if characterSelectPlayer = 3 then COLUP0  = ColYellow(12) : rem Bright red (Player 2)
          if characterSelectPlayer = 4 then COLUP0  = ColGreen(12) : rem Bright yellow (Player 3)
          goto SelColorDone : rem Bright green
SelColorBW
          rem Helper: Set normal color for B&W mode
          rem
          rem Input: None
          rem
          rem Output: COLUP0 set to bright grey
          rem
          rem Mutates: COLUP0 (TIA register) = player color (set to
          rem ColGrey(14))
          rem
          rem Called Routines: None
          let COLUP0  = ColGrey(14) : rem Constraints: Internal helper for SelColorNormal, only called in B&W mode
SelColorDone
          rem Bright grey (B&W)
          
          rem Draw different sprite patterns based on animation state
          if characterSelectAnimationState = ActionStanding then SelectAnimationIdle : rem   and frame
          if characterSelectAnimationState = ActionWalking then SelectAnimationRun
          if characterSelectAnimationState = ActionAttackWindup then SelectAnimationAttack
          goto SelectAnimationDone
SelectAnimationIdle
          rem Helper: Draw idle animation (standing pose)
          rem
          rem Input: None
          rem
          rem Output: Idle sprite pattern set
          rem
          rem Mutates: Player sprite graphics (set to idle pattern)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelDrawSprite, only
          rem called for ActionStanding
          goto SelectAnimationDone : rem Idle animation - simple standing pose
SelectAnimationRun
          rem Helper: Draw running animation (alternating leg positions)
          rem
          rem Input: characterSelectAnimationFrame (global) = animation frame
          rem
          rem Output: Running sprite pattern set (alternating legs)
          rem
          rem Mutates: Player sprite graphics (set to running pattern)
          rem
          rem Called Routines: SelLeftLeg - sets left leg forward
          rem pattern
          rem
          rem Constraints: Internal helper for SelDrawSprite, only
          rem called for ActionWalking. Frames 0,2,4,6 = right leg
          rem forward, frames 1,3,5,7 = left leg forward
          if characterSelectAnimationFrame & 1 then SelLeftLeg : rem Running animation - alternating leg positions
          goto SelectAnimationDone : rem Frame 0,2,4,6 - right leg forward
SelLeftLeg
          rem Helper: Set left leg forward pattern for running
          rem
          rem Input: None
          rem
          rem Output: Left leg forward sprite pattern set
          rem
          rem Mutates: Player sprite graphics (set to left leg forward
          rem pattern)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelectAnimationRun, only called
          rem for odd frames (1,3,5,7)
          goto SelectAnimationDone : rem Frame 1,3,5,7 - left leg forward
SelectAnimationAttack
          rem Helper: Draw attacking animation (arm extended)
          rem
          rem Input: characterSelectAnimationFrame (global) = animation frame
          rem
          rem Output: Attacking sprite pattern set (arm extended or
          rem windup)
          rem
          rem Mutates: Player sprite graphics (set to attack pattern)
          rem
          rem Called Routines: SelectWindup - sets windup pattern
          rem
          rem Constraints: Internal helper for SelectDrawSprite, only
          rem called for ActionAttackWindup. Frames 0-3 = windup, frames
          rem 4-7 = attack
          if characterSelectAnimationFrame < 4 then SelectWindup : rem Attacking animation - arm extended
          goto SelectAnimationDone : rem Attack frames - arm forward
SelectWindup
          rem Helper: Set windup pattern for attack
          rem
          rem Input: None
          rem
          rem Output: Windup sprite pattern set
          rem
          rem Mutates: Player sprite graphics (set to windup pattern)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelectAnimationAttack, only
          rem called for frames 0-3
          goto SelectAnimationDone : rem Windup frames - arm back
SelectAnimationDone
          return

SelScreenDone
          rem Character selection complete (stores selected characters
          rem and initializes facing directions)
          rem
          rem Input: playerCharacter[] (global array) = current character
          rem selections, selectedCharacter1, selectedCharacter2_R,
          rem selectedCharacter3_R, selectedCharacter4_R (global SCRAM) = stored
          rem selections, playerState[] (global array) = player states,
          rem NoCharacter (global constant) = no character constant
          rem
          rem Output: Selected characters stored, facing directions
          rem initialized (default: face right = 1)
          rem
          rem Mutates: selectedCharacter1 (global) = player 1 selection
          rem (set), selectedCharacter2_W, selectedCharacter3_W, selectedCharacter4_W
          rem (global SCRAM) = player 2-4 selections (set),
          rem playerState[] (global array) = player states (facing bit
          rem set for selected players)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only sets facing bit for players with valid
          rem character selections (not NoCharacter). Default facing:
          rem right (bit 0 = 1)
          rem Character selection complete
          let selectedCharacter1  = playerCharacter[0] : rem Store selected characters for use in game
          let selectedCharacter2_W  = playerCharacter[1]
          let selectedCharacter3_W  = playerCharacter[2]
          let selectedCharacter4_W  = playerCharacter[3]
          
          rem Initialize facing bit (bit 0) for all selected players
          if selectedCharacter1 = NoCharacter then SkipCharacter1FacingSel : rem (default: face right = 1)
          let playerState[0] = playerState[0] | 1
SkipCharacter1FacingSel
          if selectedCharacter2_R = NoCharacter then SkipCharacter2FacingSel
          let playerState[1] = playerState[1] | 1
SkipCharacter2FacingSel
          if selectedCharacter3_R = NoCharacter then SkipCharacter3FacingSel
          let playerState[2] = playerState[2] | 1
SkipCharacter3FacingSel
          if selectedCharacter4_R = NoCharacter then SkipCharacter4FacingSel
          let playerState[3] = playerState[3] | 1
SkipCharacter4FacingSel

          rem Proceed to falling animation
          return

SelDetectQuad
          rem Detect Quadtari adapter
          rem Detect Quadtari adapter (canonical detection: check paddle
          rem ports INPT0-3)
          rem
          rem Input: INPT0-3 (hardware registers) = paddle port states,
          rem controllerStatus (global) = controller detection state,
          rem SetQuadtariDetected (global constant) = Quadtari detection
          rem flag
          rem
          rem Output: Quadtari detection flag set if adapter detected
          rem
          rem Mutates: controllerStatus (global) = controller detection
          rem state (Quadtari flag set if detected)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Requires BOTH sides present: Left (INPT0 LOW,
          rem INPT1 HIGH) AND Right (INPT2 LOW, INPT3 HIGH). Uses
          rem monotonic merge (OR) to preserve existing capabilities
          rem (upgrades only, never downgrades). If Quadtari was
          rem previously detected, it remains detected
          rem CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          rem Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH)
          rem   AND Right (INPT2 LOW, INPT3 HIGH)
          
          if INPT0{7} then SelQuadAbsent : rem Check left side: if INPT0 is HIGH then not detected
          if !INPT1{7} then SelQuadAbsent : rem Check left side: if INPT1 is LOW then not detected
          
          if INPT2{7} then SelQuadAbsent : rem Check right side: if INPT2 is HIGH then not detected
          if !INPT3{7} then SelQuadAbsent : rem Check right side: if INPT3 is LOW then not detected
          
          goto SelSkipQuadAbs : rem All checks passed - Quadtari detected

SelQuadAbsent
          return
          rem Helper: Quadtari not detected in this detection cycle
          rem
          rem Input: None
          rem
          rem Output: No changes (monotonic detection preserves previous
          rem state)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelDetectQuad, only
          rem called when Quadtari not detected. Does NOT clear
          rem controllerStatus - monotonic detection (upgrades only).
          rem Only DetectControllers (called via SELECT) can update
          rem controller status
          rem Quadtari not detected in this detection cycle
          rem NOTE: Do NOT clear controllerStatus - monotonic detection
          rem   (upgrades only)
          rem If Quadtari was previously detected, it remains detected
          rem   (monotonic state machine)
          rem Only DetectControllers (called via SELECT) can update
          rem   controller status
          
SelSkipQuadAbs
          rem Helper: Quadtari detected - set detection flag
          rem
          rem Input: controllerStatus (global) = controller detection
          rem state, SetQuadtariDetected (global constant) = Quadtari
          rem detection flag
          rem
          rem Output: Quadtari detection flag set
          rem
          rem Mutates: controllerStatus (global) = controller detection
          rem state (Quadtari flag set via OR merge)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SelDetectQuad, only
          rem called when Quadtari detected. Uses monotonic merge (OR)
          rem to preserve existing capabilities (upgrades only, never
          rem downgrades)
          rem Quadtari detected - use monotonic merge to preserve
          rem   existing capabilities
          let controllerStatus  = controllerStatus | SetQuadtariDetected : rem OR merge ensures upgrades only, never downgrades
          return
