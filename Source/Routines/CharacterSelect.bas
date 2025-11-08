          rem ChaosFight - Source/Routines/CharacterSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CharacterSelectEntry
          rem Initializes character select screen state
          rem Notes: PlayerLockedHelpers.bas moved to Bank 14
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
          rem Called Routines: CharacterSelectDetectQuadtari - accesses controller
          rem detection state
          rem
          rem Constraints: Entry point for character select screen
          rem initialization
          rem              Must be colocated with CharacterSelectLoop (called
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

          gosub CharacterSelectDetectQuadtari : rem Check for Quadtari adapter

          let COLUBK  = ColGray(0) : rem Set background color (B&W safe)
          rem Always black background

CharacterSelectLoop
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
          rem Output: Dispatches to CharacterSelectHandleQuadtari or processes even
          rem frame input, then returns
          rem
          rem Mutates: qtcontroller (toggled), playerCharacter[],
          rem playerLocked state, temp1, temp2 (passed to
          rem SetPlayerLocked)
          rem
          rem Called Routines: SetPlayerLocked (bank14) - accesses
          rem playerLocked state
          rem
          rem Constraints: Must be colocated with Player1LeftSelectionQ,
          rem Player1LeftSelectionSkip, Player1RightSelectionQ, Player1RightSelectionSkip,
          rem              SelectStick0FireQ, SelectStick0Down, Player1LockSelection,
          rem              Player1HandicapSelection, Player1LockSelectionDone,
          rem              Player2LeftSelectionQ, Player2LeftSelectionSkip, Player2RightSelectionQ,
          rem              Player2RightSelectionSkip,
          rem              SelectStick1FireQ, SelectStick1Down, SelectStick1DownQ,
          rem              Player2LockSelectionDone, SelectStick1EvenFrameSkip,
          rem              CharacterSelectHandleQuadtari (all called via goto)
          rem              Entry point for character select screen loop
          rem Quadtari controller multiplexing:
          rem On even frames (qtcontroller=0): handle controllers 0 and
          rem   1
          rem On odd frames (qtcontroller=1): handle controllers 2 and 3
          rem   (if Quadtari detected)
          
          if qtcontroller then goto CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then let playerCharacter[0] = playerCharacter[0] - 1 : goto Player1LeftSelectionQ
          goto Player1LeftSelectionSkip

Player1LeftSelectionQ
          if playerCharacter[0] > MaxCharacter then let playerCharacter[0] = MaxCharacter
          if playerCharacter[0] > MaxCharacter then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
          
Player1LeftSelectionSkip
          if joy0right then let playerCharacter[0] = playerCharacter[0] + 1 : goto Player1RightSelectionQ
          goto Player1RightSelectionSkip

Player1RightSelectionQ
          if playerCharacter[0] > MaxCharacter then let playerCharacter[0] = 0
          if playerCharacter[0] > MaxCharacter then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
          
Player1RightSelectionSkip
          if joy0up then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
          rem Unlock by moving up
          if joy0down then SelectStick0FireQ
          goto SelectStick0Down

SelectStick0FireQ
          if joy0fire then SelectStick0Down
          let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
          
SelectStick0Down
          rem Unlock by moving down (without fire)
          if joy0fire then Player1LockSelection
          goto Player1LockSelectionDone

Player1LockSelection
          if joy0down then Player1HandicapSelection
          let temp1 = 0 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto Player1LockSelectionDone : rem Locked normal (100% health)

Player1HandicapSelection
          let temp1 = 0 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
Player1LockSelectionDone
          rem Locked with handicap (75% health)

          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then let playerCharacter[1] = playerCharacter[1] - 1 : goto Player2LeftSelectionQ
          goto Player2LeftSelectionSkip

Player2LeftSelectionQ
          if playerCharacter[1] > MaxCharacter then let playerCharacter[1] = MaxCharacter
          if playerCharacter[1] > MaxCharacter then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
Player2LeftSelectionSkip
          if joy1right then let playerCharacter[1] = playerCharacter[1] + 1 : goto Player2RightSelectionQ
          goto Player2RightSelectionSkip

Player2RightSelectionQ
          if playerCharacter[1] > MaxCharacter then let playerCharacter[1] = 0
          if playerCharacter[1] > MaxCharacter then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
Player2RightSelectionSkip
          if joy1up then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
          rem Unlock by moving up
          if joy1down then SelectStick1FireQ

          goto SelectStick1Down

SelectStick1FireQ
          if joy1fire then SelectStick1Down

          let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
SelectStick1Down
          rem Unlock by moving down (without fire)
          if joy1fire then SelectStick1DownQ

          goto SelectStick1EvenFrameSkip

SelectStick1DownQ
          if joy1down then let temp1 = 1 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14 : goto Player2LockSelectionDone

          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14 : rem Locked with handicap (75% health)
Player2LockSelectionDone 
          rem Locked normal (100% health)

SelectStick1EvenFrameSkip
          let qtcontroller  = 1 : rem Switch to odd frame mode for next iteration
          goto CharacterSelectHandleComplete

CharacterSelectHandleQuadtari
          rem Handle Player 3 input (joy0 on odd frames, Quadtari only)
          if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer3

          goto CharacterSelectSkipPlayer3

CharacterSelectHandlePlayer3
          if joy0left then let playerCharacter[2] = playerCharacter[2] - 1 : goto Player3LeftSelectionQ

          goto Player3LeftSelectionSkip

Player3LeftSelectionQ
          if playerCharacter[2] > MaxCharacter then let playerCharacter[2] = MaxCharacter
          if playerCharacter[2] > MaxCharacter then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
Player3LeftSelectionSkip
          if joy0right then let playerCharacter[2] = playerCharacter[2] + 1 : goto Player3RightSelectionQ

          goto Player3RightSelectionSkip

Player3RightSelectionQ
          if playerCharacter[2] > MaxCharacter then let playerCharacter[2] = 0
          if playerCharacter[2] > MaxCharacter then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
Player3RightSelectionSkip
          if joy0up then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
          rem Unlock by moving up
          if joy0down then SelectStick0FirePlayer3Q

          goto SelectStick0DownPlayer3

SelectStick0FirePlayer3Q
          if joy0fire then SelectStick0DownPlayer3
          let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
SelectStick0DownPlayer3
          rem Unlock by moving down (without fire)
          if joy0fire then SelectStick0DownPlayer3Q

          goto Player3LockSelectionDone

SelectStick0DownPlayer3Q
          if joy0down then Player3HandicapSelection

          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto Player3LockSelectionDone : rem Locked normal (100% health)

Player3HandicapSelection
          let temp1 = 2 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
Player3LockSelectionDone
          rem Locked with handicap (75% health)

          rem Handle Player 4 input (joy1 on odd frames, Quadtari only)

          if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer4

          goto CharacterSelectSkipPlayer4

CharacterSelectHandlePlayer4
          if joy1left then let playerCharacter[3] = playerCharacter[3] - 1 : goto Player4LeftSelectionQ
          goto Player4LeftSelectionSkip
Player4LeftSelectionQ
          if playerCharacter[3] > MaxCharacter then let playerCharacter[3] = MaxCharacter
          if playerCharacter[3] > MaxCharacter then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
Player4LeftSelectionSkip
          if joy1right then let playerCharacter[3] = playerCharacter[3] + 1 : goto Player4RightSelectionQ
          goto Player4RightSelectionSkip
Player4RightSelectionQ
          if playerCharacter[3] > MaxCharacter then let playerCharacter[3] = 0
          if playerCharacter[3] > MaxCharacter then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
Player4RightSelectionSkip
          if joy1up then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
          rem Unlock by moving up
          if joy1down then SelectStick1FirePlayer4Q

          goto SelectStick1DownPlayer4

SelectStick1FirePlayer4Q
          if joy1fire then SelectStick1DownPlayer4

          let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
SelectStick1DownPlayer4
          rem Unlock by moving down (without fire)
          if joy1fire then SelectStick1DownPlayer4Q

          goto SelectStick1OddFrameSkip

SelectStick1DownPlayer4Q
          if joy1down then Player4HandicapSelection

          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto Player4LockSelectionDone : rem Locked normal (100% health)

Player4HandicapSelection
          let temp1 = 3 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
Player4LockSelectionDone
          rem Locked with handicap (75% health)
          
          let qtcontroller  = 0 : rem Switch back to even frame mode for next iteration
CharacterSelectSkipPlayer3
CharacterSelectSkipPlayer4
SelectStick1OddFrameSkip

CharacterSelectHandleComplete

          gosub CharacterSelectUpdateAnimation : rem Update character select animations

          rem Check if all players are ready to start (inline
          let readyCount  = 0 : rem   SelAllReady)

          rem Count locked players

          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariPlayersInline

          goto CharacterSelectSkipQuadtariPlayersInline
          
CharacterSelectQuadtariPlayersInline
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then let readyCount = readyCount + 1
CharacterSelectSkipQuadtariPlayersInline
          rem Check if enough players are ready
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariReadyInline

          rem Need at least 1 player ready for 2-player mode
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then goto CharacterSelectCompleted

          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then goto CharacterSelectCompleted

          goto CharacterSelectSkipQuadtariReadyInline
          
CharacterSelectQuadtariReadyInline
          rem Need at least 2 players ready for 4-player mode
          if readyCount>= 2 then goto CharacterSelectCompleted
CharacterSelectSkipQuadtariReadyInline

          gosub CharacterSelectDrawScreen : rem Draw character selection screen

          rem drawscreen called by MainLoop
          return
          goto CharacterSelectLoop



CharacterSelectDrawScreen
          rem Draw character selection screen via shared renderer
          gosub bank6 SelectDrawScreen
          return

CharacterSelectDrawScreenLegacy
          rem Legacy implementation retained for historical reference; do not execute
          return
LegacyCharacterSelectDrawScreenBody
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
          rem         player sprite pointers (via CharacterSelectDrawSprite),
          rem         playfield data (via CharacterSelectDrawNumber)
          rem
          rem Called Routines: CharacterSelectDrawSprite - accesses playerCharacter[],
          rem draws character sprites,
          rem   CharacterSelectDrawNumber - draws player number indicators
          rem
          rem Constraints: Must be colocated with CharacterSelectDrawPlayer3, CharacterSelectSkipPlayer3Draw,
          rem CharacterSelectDrawPlayer4, CharacterSelectSkipPlayer4Draw
          rem              (all called via goto)
          rem Draw Player 1 selection (top left) with number
          player0x = 56
          player0y = 40 
          gosub CharacterSelectDrawSprite : rem Adjusted for 16px left margin (40+16)

          gosub CharacterSelectDrawNumber : rem Draw 1 indicator below Player 1 using playfield

          let player1x = 104 : rem Draw Player 2 selection (top right) with number
          let player1y = 40
          gosub CharacterSelectDrawSprite : rem Adjusted for 16px margins (120-16)

          gosub CharacterSelectDrawNumber : rem Draw 2 indicator below Player 2 using playfield

          rem Draw Player 3 selection (bottom left) if Quadtari detected

          if controllerStatus & SetQuadtariDetected then CharacterSelectDrawPlayer3
          goto CharacterSelectSkipPlayer3Draw
CharacterSelectDrawPlayer3
          rem Draw Player 3 character sprite and number
          rem
          rem Input: playerCharacter[] (global array) = current character
          rem selections
          rem        player0x, player0y (TIA registers) = sprite
          rem        position (set inline)
          rem
          rem Output: Player 3 sprite drawn, number indicator drawn
          rem
          rem Mutates: player sprite pointers (via CharacterSelectDrawSprite),
          rem playfield data (via CharacterSelectDrawNumber)
          rem
          rem Called Routines: CharacterSelectDrawSprite, CharacterSelectDrawNumber
          rem
          rem Constraints: Must be colocated with CharacterSelectDrawScreen,
          rem CharacterSelectSkipPlayer3Draw
          player0x = 56
          player0y = 80 
          gosub CharacterSelectDrawSprite : rem Adjusted for 16px left margin

          gosub CharacterSelectDrawNumber : rem Draw 3 indicator below Player 3 using playfield

          rem Draw Player 4 selection (bottom right) if Quadtari
          rem detected
          if controllerStatus & SetQuadtariDetected then CharacterSelectDrawPlayer4
          goto CharacterSelectSkipPlayer4Draw
CharacterSelectDrawPlayer4
          rem Draw Player 4 character sprite and number
          rem
          rem Input: playerCharacter[] (global array) = current character
          rem selections
          rem        player1x, player1y (TIA registers) = sprite
          rem        position (set inline)
          rem
          rem Output: Player 4 sprite drawn, number indicator drawn
          rem
          rem Mutates: player sprite pointers (via CharacterSelectDrawSprite),
          rem playfield data (via CharacterSelectDrawNumber)
          rem
          rem Called Routines: CharacterSelectDrawSprite, CharacterSelectDrawNumber
          rem Constraints: Must be colocated with CharacterSelectDrawScreen, CharacterSelectSkipPlayer4Draw
          let player1x = 104
          let player1y = 80
          gosub CharacterSelectDrawSprite : rem Adjusted for 16px margins

          gosub CharacterSelectDrawNumber : rem Draw 4 indicator below Player 4 using playfield
CharacterSelectSkipPlayer3Draw
CharacterSelectSkipPlayer4Draw

          rem Tail call into CharacterSelectDrawLocks to render lock borders
          goto CharacterSelectDrawLocks : rem tail call


CharacterSelectDrawLocks
          rem Draw locked status indicators (playfield blocks framing locked characters)
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
          rem Draw playfield blocks around locked characters
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then CharacterSelectDrawPlayer1Border
          goto CharacterSelectSkipPlayer1Border
CharacterSelectDrawPlayer1Border
CharacterSelectSkipPlayer1Border
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
          rem Constraints: Internal helper for CharacterSelectDrawLocks, only called
          rem when Player 1 is locked
          rem Draw border around Player 1

          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then CharacterSelectDrawPlayer2Border
          goto CharacterSelectSkipPlayer2Border
CharacterSelectDrawPlayer2Border
CharacterSelectSkipPlayer2Border
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
          rem Constraints: Internal helper for CharacterSelectDrawLocks, only called
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
          rem Constraints: Internal helper for CharacterSelectDrawLocks, only called
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
          rem Constraints: Internal helper for CharacterSelectDrawLocks, only called
          rem if Quadtari detected
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then SelectDrawPlayer3Border
          return
SelectDrawPlayer3Border 
          return
CharacterSelectDrawNumber
          rem Draw number indicator via shared renderer
          gosub bank6 SelectDrawNumber
          return

CharacterSelectDrawNumberLegacy
          rem Legacy implementation retained for historical reference; do not execute
          return
LegacyCharacterSelectDrawNumberBody
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

          rem Player 1 (top left) - draw 1

          if player0x  = 56 then Player1TopRowQ
          goto DonePlayer0Check1
Player1TopRowQ
          if player0y  = 40 then Player1DrawTopDigit
          goto DonePlayer0Check1
Player1DrawTopDigit 
          return

          rem Player 2 (top right) - draw 2

          if player1x  = 104 then Player2TopRowQ
          goto DonePlayer1Check1
Player2TopRowQ
          if player1y  = 40 then Player2DrawTopDigit
          goto DonePlayer1Check1
Player2DrawTopDigit 
          return

          rem Player 3 (bottom left) - draw 3

          if player0x  = 56 then Player1BottomRowQ
          goto DonePlayer0Check2
Player1BottomRowQ
          if player0y  = 80 then Player1DrawBottomDigit
          goto DonePlayer0Check2
Player1DrawBottomDigit 
          return

          rem Player 4 (bottom right) - draw 4

          if player1x  = 104 then Player2BottomRowQ
          goto DonePlayer1Check2
Player2BottomRowQ
          if player1y  = 80 then Player2DrawBottomDigit
          goto DonePlayer1Check2
Player2DrawBottomDigit 
          return
          return

CharacterSelectUpdateAnimation
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
          
          rem Check each player for DOWN held (even frame for P1/P2)
          
          if qtcontroller then goto DoneEvenFrameCheck
                    if joy0down then let HandicapMode  = HandicapMode | 1
          rem P1 handicap flag
          if joy1down then let HandicapMode  = HandicapMode | 2
          rem P2 handicap flag
          
          
          rem Check each player for DOWN held (odd frame for P3/P4)
          
          
          if qtcontroller then CharacterSelectQuadtariHandicap
          goto DoneOddFrameCheck
CharacterSelectQuadtariHandicap
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
          rem Constraints: Internal helper for CharacterSelectUpdateAnimation, only called on odd frames
          if controllerStatus & SetQuadtariDetected then CharacterSelectOddFrame
          goto DoneOddFrameCheck
CharacterSelectOddFrame 
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
          rem Constraints: Internal helper for CharacterSelectQuadtariHandicap, only called
          rem if Quadtari detected
                    if joy0down then let HandicapMode  = HandicapMode | 4
          rem P3 handicap flag
          if joy1down then let HandicapMode  = HandicapMode | 8
          rem P4 handicap flag
          
          
          rem If any player is holding down, set animation to recovery
          rem pose
          if HandicapMode then CharacterSelectHandleHandicap
          goto SelectAnimationNormal
CharacterSelectHandleHandicap
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
          rem Constraints: Internal helper for CharacterSelectUpdateAnimation, only
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
          rem Constraints: Internal helper for CharacterSelectUpdateAnimation, only
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
          rem 0-3: idle, running, attacking, special
          if characterSelectAnimationState > 2 then let characterSelectAnimationState  = 0
          let characterSelectAnimationFrame  = 0 : rem Keep to 0-2 range
          let characterSelectCharacterIndex  = characterSelectCharacterIndex + 1 : rem Cycle through characters for variety
          if characterSelectCharacterIndex > MaxCharacter then let characterSelectCharacterIndex  = 0
SelectAnimationAdvance
          let characterSelectAnimationFrame  = characterSelectAnimationFrame + 1 : rem Update animation frame within current state
          if characterSelectAnimationFrame <= 7 then return
          let characterSelectAnimationFrame  = 0
          rem 8-frame animation cycles
          
          return

CharacterSelectDrawSprite
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
          
          if !(temp1 = 2) then CharacterSelectColorNormal
          rem Hurt state - dimmer colors
          if switchbw then CharacterSelectHurtBlackWhite
          rem Player color but dimmer
          if characterSelectPlayer = 1 then COLUP0  = ColIndigo(6)
          rem Dark indigo (Player 1)
          if characterSelectPlayer = 2 then COLUP0  = ColRed(6)
          rem Dark red (Player 2)
          if characterSelectPlayer = 3 then COLUP0  = ColYellow(6)
          rem Dark yellow (Player 3)
          if characterSelectPlayer = 4 then COLUP0  = ColGreen(6)
          goto CharacterSelectColorDone : rem Dark green
CharacterSelectHurtBlackWhite
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
          goto CharacterSelectColorDone : rem Dark grey for hurt (B&W)
CharacterSelectColorNormal
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
          rem Called Routines: CharacterSelectColorBlackWhite - sets B&W color
          rem
          rem Constraints: Internal helper for CharacterSelectDrawSprite, only
          rem called in normal state
          rem Normal state - bright colors
          if switchbw then CharacterSelectColorBlackWhite
          rem Player color - bright
          if characterSelectPlayer = 1 then COLUP0  = ColIndigo(12)
          rem Bright indigo (Player 1)
          if characterSelectPlayer = 2 then COLUP0  = ColRed(12)
          rem Bright red (Player 2)
          if characterSelectPlayer = 3 then COLUP0  = ColYellow(12)
          rem Bright yellow (Player 3)
          if characterSelectPlayer = 4 then COLUP0  = ColGreen(12)
          goto CharacterSelectColorDone : rem Bright green
CharacterSelectColorBlackWhite
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
          rem Constraints: Internal helper for CharacterSelectColorNormal, only called in B&W mode
          let COLUP0  = ColGrey(14)
CharacterSelectColorDone
          rem Bright grey (B&W)
          
          rem Draw different sprite patterns based on animation state
          rem and frame
          if characterSelectAnimationState = ActionStanding then SelectAnimationIdle
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
          rem Constraints: Internal helper for CharacterSelectDrawSprite, only
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
          rem Called Routines: CharacterSelectLeftLeg - sets left leg forward
          rem pattern
          rem
          rem Constraints: Internal helper for CharacterSelectDrawSprite, only
          rem called for ActionWalking. Frames 0,2,4,6 = right leg
          rem forward, frames 1,3,5,7 = left leg forward
          rem Running animation - alternating leg positions
          if characterSelectAnimationFrame & 1 then CharacterSelectLeftLeg
          goto SelectAnimationDone : rem Frame 0,2,4,6 - right leg forward
CharacterSelectLeftLeg
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
          rem Attacking animation - arm extended
          if characterSelectAnimationFrame < 4 then SelectWindup
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

CharacterSelectCompleted
          rem Character selection complete (stores selected characters
          rem and initializes facing directions)
          rem
          rem Input: playerCharacter[] (global array) = current character
          rem selections, playerState[] (global array) = player states,
          rem NoCharacter (global constant) = no character constant
          rem
          rem Output: Selected characters stored, facing directions
          rem initialized (default: face right = 1)
          rem
          rem Mutates: playerState[] (global array) = player states (facing bit
          rem set for selected players)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only sets facing bit for players with valid
          rem character selections (not NoCharacter). Default facing:
          rem right (bit 0 = 1)
          rem Character selection complete
          rem Initialize facing bit (bit 0) for all selected players
          rem (default: face right = 1)
          if playerCharacter[0] = NoCharacter then SkipCharacter1FacingSel
          let playerState[0] = playerState[0] | 1
SkipCharacter1FacingSel
          if playerCharacter[1] = NoCharacter then SkipCharacter2FacingSel
          let playerState[1] = playerState[1] | 1
SkipCharacter2FacingSel
          if playerCharacter[2] = NoCharacter then SkipCharacter3FacingSel
          let playerState[2] = playerState[2] | 1
SkipCharacter3FacingSel
          if playerCharacter[3] = NoCharacter then SkipCharacter4FacingSel
          let playerState[3] = playerState[3] | 1
SkipCharacter4FacingSel

          rem Proceed to falling animation
          return

CharacterSelectDetectQuadtari
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
          
          rem Check left side: if INPT0 is HIGH then not detected
          
          if INPT0{7} then CharacterSelectQuadtariAbsent
          rem Check left side: if INPT1 is LOW then not detected
          if !INPT1{7} then CharacterSelectQuadtariAbsent
          
          rem Check right side: if INPT2 is HIGH then not detected
          
          if INPT2{7} then CharacterSelectQuadtariAbsent
          rem Check right side: if INPT3 is LOW then not detected
          if !INPT3{7} then CharacterSelectQuadtariAbsent
          
          goto CharacterSelectQuadtariDetected : rem All checks passed - Quadtari detected

CharacterSelectQuadtariAbsent
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
          rem Constraints: Helper for CharacterSelectDetectQuadtari; only executes when Quadtari
          rem   is absent. Monotonic detection means controllerStatus is never cleared here.
          rem   DetectControllers (SELECT handler) is the sole routine that upgrades controller
          rem   status flags.
          
CharacterSelectQuadtariDetected
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
          rem Constraints: Internal helper for CharacterSelectDetectQuadtari, only
          rem called when Quadtari detected. Uses monotonic merge (OR)
          rem to preserve existing capabilities (upgrades only, never
          rem downgrades)
          rem Quadtari detected - use monotonic merge to preserve
          rem   existing capabilities
          let controllerStatus  = controllerStatus | SetQuadtariDetected : rem OR merge ensures upgrades only, never downgrades
          return
