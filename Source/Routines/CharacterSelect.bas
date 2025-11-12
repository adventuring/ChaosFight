          rem ChaosFight - Source/Routines/CharacterSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CharacterSelectEntry
          rem Initializes character select screen state
          rem Notes: PlayerLockedHelpers.bas resides in Bank 6
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
          let playerCharacter[0] = 0
          rem Initialize character selections
          let playerCharacter[1] = 0
          let playerCharacter[2] = 0
          let playerCharacter[3] = 0
          let playerLocked = 0
          rem Initialize playerLocked (bit-packed, all unlocked)
          rem NOTE: Do NOT clear controllerStatus flags here - monotonic
          rem   detection (upgrades only)
          rem Controller detection is handled by CtrlDetPads with
          rem   monotonic state machine
          
          let characterSelectAnimationTimer  = 0
          rem Initialize character select animations
          let characterSelectAnimationState  = 0
          let characterSelectCharacterIndex  = 0
          rem Start with idle animation
          let characterSelectAnimationFrame  = 0
          rem Start with first character

          gosub CharacterSelectDetectQuadtari
          rem Check for Quadtari adapter

          COLUBK = ColGray(0)
          rem Set background color (B&W safe)
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
          rem Called Routines: SetPlayerLocked (bank6) - accesses
          rem playerLocked state
          rem
          rem Constraints: Must be colocated with SelectStickLeft,
          rem SelectStickRight, Player1LockSelection,
          rem Player1HandicapSelection, Player1LockSelectionDone,
          rem Player2LockSelection, Player2HandicapSelection,
          rem Player2LockSelectionDone, Player3LockSelection,
          rem Player3HandicapSelection, Player3LockSelectionDone,
          rem Player4LockSelection, Player4HandicapSelection,
          rem Player4LockSelectionDone, CharacterSelectHandleQuadtari
          rem              Entry point for character select screen loop
          rem Quadtari controller multiplexing:
          rem On even frames (qtcontroller=0): handle controllers 0 and
          rem   1
          rem On odd frames (qtcontroller=1): handle controllers 2 and 3
          rem   (if Quadtari detected)
          
          if qtcontroller then goto CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          let currentPlayer = 0
          
          if joy0left then gosub SelectStickLeft
          if joy0right then gosub SelectStickRight

          rem Unlock by moving up
          if joy0up then let temp1 = currentPlayer : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked

          if joy0fire then Player1LockSelection
          goto DonePlayer1

Player1LockSelection
          if joy0down then Player1HandicapSelection
          let temp2 = PlayerLockedNormal
          goto Player1LockSelectionDone
          rem Locked normal (100% health)

Player1HandicapSelection
          let temp2 = PlayerHandicapped 
Player1LockSelectionDone
          let temp1 = currentPlayer
          gosub SetPlayerLocked
DonePlayer1

          rem Handle Player 2 input (joy1 on even frames)
          let currentPlayer = 1
          
          if joy1left then gosub SelectStickLeft
          if joy1right then gosub SelectStickRight

          rem Unlock by moving up
          if joy1up then let temp1 = currentPlayer : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked

          if joy1fire then Player2LockSelection
          goto DonePlayer2

Player2LockSelection
          if joy1down then Player2HandicapSelection
          let temp2 = PlayerLockedNormal
          goto Player2LockSelectionDone
          rem Locked normal (100% health)

Player2HandicapSelection
          let temp2 = PlayerHandicapped 
Player2LockSelectionDone
          let temp1 = currentPlayer
          gosub SetPlayerLocked
DonePlayer2
          qtcontroller = 1
          rem Switch to odd frame mode for next iteration
          goto CharacterSelectHandleComplete

CharacterSelectHandleQuadtari
          rem Handle Player 3 input (joy0 on odd frames, Quadtari only)
          if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer3

          goto CharacterSelectSkipPlayer3

CharacterSelectHandlePlayer3
          let currentPlayer = 2
          
          if joy0left then gosub SelectStickLeft
          if joy0right then gosub SelectStickRight

          rem Unlock by moving up
          if joy0up then let temp1 = currentPlayer : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked

          if joy0fire then Player3LockSelection
          goto DonePlayer3

Player3LockSelection
          if joy0down then Player3HandicapSelection
          let temp2 = PlayerLockedNormal
          goto Player3LockSelectionDone
          
Player3HandicapSelection
          let temp2 = PlayerHandicapped 
          
Player3LockSelectionDone
          let temp1 = currentPlayer
          gosub SetPlayerLocked
DonePlayer3

          rem Handle Player 4 input (joy1 on odd frames, Quadtari only)

          if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer4

          goto CharacterSelectSkipPlayer4

CharacterSelectHandlePlayer4
          let currentPlayer = 3
          
          if joy1left then gosub SelectStickLeft
          if joy1right then gosub SelectStickRight

          rem Unlock by moving up
          if joy1up then let temp1 = currentPlayer : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked

          if joy1fire then Player4LockSelection
          goto DonePlayer4

Player4LockSelection
          if joy1down then Player4HandicapSelection
          let temp2 = PlayerLockedNormal
          goto Player4LockSelectionDone
          rem Locked normal (100% health)

Player4HandicapSelection
          let temp2 = PlayerHandicapped 
Player4LockSelectionDone
          let temp1 = currentPlayer
          gosub SetPlayerLocked
          rem Locked with handicap (75% health)
DonePlayer4
          
          qtcontroller = 0
          rem Switch back to even frame mode for next iteration
CharacterSelectDonePlayer3
CharacterSelectDonePlayer4
SelectStick1OddFrameSkip

SelectStickLeft
          rem Handle stick-left navigation for the active player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerCharacter[] (global) = browsing selections
          rem Output: playerCharacter[currentPlayer] decremented with wrap
          rem        to MaxCharacter, lock state cleared on wrap
          rem Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          rem        SetPlayerLocked)
          rem Called Routines: SetPlayerLocked (bank6)
          rem Constraints: currentPlayer must be set by caller
          let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] - 1
          if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = MaxCharacter
          if playerCharacter[currentPlayer] > MaxCharacter then let temp1 = currentPlayer : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          return

SelectStickRight
          rem Handle stick-right navigation for the active player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerCharacter[] (global) = browsing selections
          rem Output: playerCharacter[currentPlayer] incremented with wrap
          rem        to 0, lock state cleared on wrap
          rem Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          rem        SetPlayerLocked)
          rem Called Routines: SetPlayerLocked (bank6)
          rem Constraints: currentPlayer must be set by caller
          let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] + 1
          if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = 0
          if playerCharacter[currentPlayer] > MaxCharacter then let temp1 = currentPlayer : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          return

CharacterSelectHandleComplete

          rem Check if all players are ready to start (inline
          let readyCount  = 0
          rem   SelAllReady)

          rem Count locked players

          let temp1 = 0 : gosub GetPlayerLocked : if temp2 then let readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked : if temp2 then let readyCount = readyCount + 1
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariPlayersInline

          goto CharacterSelectDoneQuadtariPlayersInline

CharacterSelectQuadtariPlayersInline
          let temp1 = 2 : gosub GetPlayerLocked : if temp2 then let readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked : if temp2 then let readyCount = readyCount + 1
CharacterSelectDoneQuadtariPlayersInline
          rem Check if enough players are ready
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariReadyInline

          rem Need at least 1 player ready for 2-player mode
          let temp1 = 0 : gosub GetPlayerLocked : if temp2 then goto CharacterSelectCompleted

          let temp1 = 1 : gosub GetPlayerLocked : if temp2 then goto CharacterSelectCompleted

          goto CharacterSelectDoneQuadtariReadyInline

CharacterSelectQuadtariReadyInline
          rem Need at least 2 players ready for 4-player mode
          if readyCount>= 2 then goto CharacterSelectCompleted
CharacterSelectDoneQuadtariReadyInline

          gosub CharacterSelectDrawScreen
          rem Draw character selection screen

          rem drawscreen called by MainLoop
          return
          goto CharacterSelectLoop



CharacterSelectDrawScreen
          rem Draw character selection screen via shared renderer
          gosub SelectDrawScreen bank6
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
          if playerCharacter[0] = NoCharacter then DoneCharacter1FacingSel
          let playerState[0] = playerState[0] | 1
DoneCharacter1FacingSel
          if playerCharacter[1] = NoCharacter then DoneCharacter2FacingSel
          let playerState[1] = playerState[1] | 1
DoneCharacter2FacingSel
          if playerCharacter[2] = NoCharacter then DoneCharacter3FacingSel
          let playerState[2] = playerState[2] | 1
DoneCharacter3FacingSel
          if playerCharacter[3] = NoCharacter then DoneCharacter4FacingSel
          let playerState[3] = playerState[3] | 1
DoneCharacter4FacingSel

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
          
          goto CharacterSelectQuadtariDetected
          rem All checks passed - Quadtari detected

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
          rem   CtrlDetPads (SELECT handler) is the sole routine that upgrades controller
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
          let controllerStatus  = controllerStatus | SetQuadtariDetected
          rem OR merge ensures upgrades only, never downgrades
          return
