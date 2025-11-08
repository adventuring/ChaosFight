HandleCharacterSelectCycle
          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem PlayerLockedHelpers.bas moved to Bank 1
          rem Character Select - Per-frame Loop
          rem
          rem Per-frame character selection screen with Quadtari
          rem   support.
          rem Called from MainLoop each frame (gameMode 3).
          rem Players cycle through NumCharacters characters and lock in
          rem   their choice.
          rem Setup is handled by SetupCharacterSelect in
          rem   ChangeGameMode.bas
          rem This function processes one frame and returns.
          rem FLOW PER FRAME:
          rem   1. Handle input with Quadtari multiplexing
          rem   2. Update animations
          rem   3. Check if ready to proceed
          rem   4. Draw screen
          rem   5. Return to MainLoop
          rem QUADTARI MULTIPLEXING:
          rem   Even frames (qtcontroller=0): joy0=P1, joy1=P2
          rem   Odd frames (qtcontroller=1): joy0=P3, joy1=P4
          rem AVAILABLE VARIABLES:
          rem   playerCharacter[0-3) - Selected character indices (0-15)
          rem
          rem   playerLocked[0-3) - Lock state (0=unlocked, 1=locked)
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   readyCount - Number of locked players
          rem Shared Character Select Input Handlers
          rem Consolidated input handlers for character selection
          rem Handle character cycling (left/right)
          rem
          rem INPUT: temp1 = player index (0-3), temp2 = direction
          rem (0=left, 1=right)
          rem        temp3 = player number (0-3)
          rem Uses: joy0left/joy0right for players 0,2;
          rem joy1left/joy1right for players 1,3
          rem
          rem OUTPUT: Updates playerCharacter[playerIndex] and plays sound
          rem Handle character cycling (left/right) for a player
          rem
          rem Input: temp1 = player index (0-3)
          rem        temp2 = direction (0=left, 1=right)
          rem        playerCharacter[] (global array) = current character
          rem        selections
          rem        joy0left, joy0right, joy1left, joy1right (hardware)
          rem        = joystick states
          rem
          rem Output: playerCharacter[temp1] updated, playerLocked
          rem state set to unlocked
          rem
          rem Mutates: playerCharacter[temp1] (cycled),
          rem playerLocked state (set to unlocked),
          rem         temp1, temp2, temp3 (passed to helper routines)
          rem
          rem Called Routines: CycleCharacterLeft, CycleCharacterRight -
          rem access playerCharacter[],
          rem   SetPlayerLocked (bank14) - accesses playerLocked state,
          rem   PlaySoundEffect (bank15) - plays navigation sound
          rem
          rem Constraints: Must be colocated with HCSC_CheckJoy0,
          rem HCSC_CheckJoy0Left,
          rem              HCSC_CheckJoy1Left, HCSC_DoCycle,
          rem              HCSC_CycleLeft, HCSC_CycleDone
          rem (all called via goto)
          rem Determine which joy port to use
          if temp1 = 0 then HCSC_CheckJoy0
          if temp1 = 2 then HCSC_CheckJoy0
          rem Players 1,3 use joy1
          if temp2 = 0 then HCSC_CheckJoy1Left
          if !joy1right then return
          goto HCSC_DoCycle
HCSC_CheckJoy0
          rem Check joy0 for players 0,2
          rem
          rem Input: temp1, temp2 (from
          rem HandleCharacterSelectCycle)
          rem        joy0left, joy0right (hardware) = joystick states
          rem
          rem Output: Dispatches to HCSC_CheckJoy0Left or HCSC_DoCycle
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectCycle
          rem Players 0,2 use joy0
          if temp2 = 0 then HCSC_CheckJoy0Left
          if !joy0right then return
          goto HCSC_DoCycle
HCSC_CheckJoy0Left
          rem Check joy0 left button
          rem
          rem Input: joy0left (hardware) = joystick state
          rem
          rem Output: Returns if not pressed, continues to HCSC_DoCycle
          rem if pressed
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with HandleCharacterSelectCycle
          if !joy0left then return
HCSC_CheckJoy1Left
          rem Check joy1 left button
          rem
          rem Input: joy1left (hardware) = joystick state
          rem
          rem Output: Returns if not pressed, continues to HCSC_DoCycle
          rem if pressed
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with HandleCharacterSelectCycle
          if !joy1left then return
HCSC_DoCycle
          rem Perform character cycling
          rem
          rem Input: temp1, temp2 (from
          rem HandleCharacterSelectCycle)
          rem        playerCharacter[] (global array) = current character
          rem        selections
          rem
          rem Output: playerCharacter[temp1] cycled, playerLocked
          rem state set to unlocked
          rem
          rem Mutates: playerCharacter[temp1], playerLocked state,
          rem temp1, temp2, temp3
          rem
          rem Called Routines: CycleCharacterLeft, CycleCharacterRight,
          rem SetPlayerLocked (bank14),
          rem   PlaySoundEffect (bank15)
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectCycle, HCSC_CycleLeft, HCSC_CycleDone
          let temp1 = playerCharacter[temp1] : rem Get current character index
          let temp3 = temp1
          rem Cycle based on direction
          if temp2 = 0 then HCSC_CycleLeft
          gosub CycleCharacterRight
          goto HCSC_CycleDone
HCSC_CycleLeft
          rem Cycle character left
          rem
          rem Input: temp1, temp3 (from HCSC_DoCycle)
          rem
          rem Output: temp1 updated with cycled character index
          rem
          rem Mutates: temp1 (cycled character index)
          rem
          rem Called Routines: CycleCharacterLeft - accesses
          rem playerCharacter[]
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectCycle, HCSC_DoCycle, HCSC_CycleDone
          gosub CycleCharacterLeft
HCSC_CycleDone
          rem Character cycling complete
          rem
          rem Input: temp1, temp1 (from
          rem HandleCharacterSelectCycle)
          rem        temp1 (from CycleCharacterLeft/Right)
          rem
          rem Output: playerCharacter[temp1] updated, playerLocked
          rem state set to unlocked
          rem
          rem Mutates: playerCharacter[temp1], playerLocked state,
          rem temp1, temp2
          rem
          rem Called Routines: SetPlayerLocked (bank14),
          rem PlaySoundEffect (bank15)
          let playerCharacter[temp1] = temp1
          let temp2 = PlayerLockedUnlocked
          gosub SetPlayerLocked bank14
          let temp1 = SoundMenuNavigate : rem Play navigation sound
          gosub PlaySoundEffect bank15
          return
          
HandleCharacterSelectFire
          rem Handle fire input (selection)
          rem
          rem Handle fire input (selection) for a player
          rem
          rem Input: temp1 = player index (0-3)
          rem        joy0fire/joy0down (players 0,2) or joy1fire/joy1down (players 1,3)
          rem        playerCharacter[] (global array) = current character selections
          rem        randomSelectFlags[] (global array) = random selection flags
          rem Output: playerLocked state updated, randomSelectFlags[] updated if random selected
          rem
          rem Mutates: playerLocked state (set to normal or handicap),
          rem randomSelectFlags[] (if random),
          rem         temp1, temp2, temp3, temp4 (passed to helper
          rem         routines)
          rem
          rem Called Routines: SetPlayerLocked (bank14) - accesses
          rem playerLocked state,
          rem   PlaySoundEffect (bank15) - plays selection sound
          rem
          rem Constraints: Must be colocated with HCSF_CheckJoy0,
          rem HCSF_HandleFire,
          rem HCSF_HandleHandicap, HCSF_HandleRandom (all called via goto)
          rem Determine which joy port to use
          if temp1 = 0 then HCSF_CheckJoy0
          if temp1 = 2 then HCSF_CheckJoy0
          rem Players 1,3 use joy1
          if !joy1fire then return
          let temp2 = 1
          if joy1down then let temp4 = 1 else let temp4 = 0
          goto HCSF_HandleFire
HCSF_CheckJoy0
          rem Check joy0 for players 0,2
          rem
          rem Input: temp1 (from HandleCharacterSelectFire)
          rem        joy0fire, joy0down (hardware) = joystick states
          rem
          rem Output: Dispatches to HCSF_HandleFire or returns
          rem
          rem Mutates: temp2, temp4
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectFire
          rem Players 0,2 use joy0
          if !joy0fire then return
          let temp2 = 1
          if joy0down then let temp4 = 1 else let temp4 = 0
HCSF_HandleFire
          rem Handle fire button press
          rem
          rem Input: temp1, temp4 (from
          rem HandleCharacterSelectFire)
          rem        playerCharacter[] (global array) = current character
          rem        selections
          rem
          rem Output: Dispatches to HCSF_HandleRandom,
          rem HCSF_HandleHandicap, or locks normally
          rem
          rem Mutates: playerLocked state, randomSelectFlags[] (if
          rem random)
          rem
          rem Called Routines: SetPlayerLocked (bank14),
          rem PlaySoundEffect (bank15)
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectFire
          rem Check if RandomCharacter selected
          if playerCharacter[temp1] = RandomCharacter then HCSF_HandleRandom
          rem Check for handicap mode (down+fire = 75% health)
          if temp4 then HCSF_HandleHandicap
          let temp3 = temp1
          let temp1 = temp3
          let temp2 = PlayerLockedNormal
          gosub SetPlayerLocked bank14
          let temp1 = SoundMenuSelect : rem Play selection sound
          gosub PlaySoundEffect bank15
          return
HCSF_HandleHandicap
          rem Handle handicap mode selection (75% health)
          rem
          rem Input: temp1 (from HandleCharacterSelectFire)
          rem
          rem Output: playerLocked state set to handicap
          rem
          rem Mutates: playerLocked state (set to handicap)
          rem
          rem Called Routines: SetPlayerLocked (bank14),
          rem PlaySoundEffect (bank15)
          let temp3 = temp1 : rem Constraints: Must be colocated with HandleCharacterSelectFire
          let temp1 = temp3
          let temp2 = PlayerHandicapped
          gosub SetPlayerLocked bank14
          let temp1 = SoundMenuSelect : rem Play selection sound
          gosub PlaySoundEffect bank15
          return
HCSF_HandleRandom
          rem Handle random character selection
          rem
          rem Input: temp1, temp4 (from
          rem HandleCharacterSelectFire)
          rem        randomSelectFlags[] (global array) = random
          rem        selection flags
          rem
          rem Output: randomSelectFlags[temp1] set, selection
          rem sound played
          rem
          rem Mutates: randomSelectFlags[temp1] (set to $80
          rem if handicap, 0 otherwise)
          rem
          rem Called Routines: PlaySoundEffect (bank15)
          rem
          rem Constraints: Must be colocated with
          rem HandleCharacterSelectFire
          rem Random selection initiated - will be handled by
          rem CharacterSelectHandleRandomRolls
          rem Store handicap flag if down was held
          if temp4 then randomSelectFlags_W[temp1] = $80 else randomSelectFlags_W[temp1] = 0
          let temp1 = SoundMenuSelect : rem Play selection sound
          gosub PlaySoundEffect bank15
          rem Fall through - character will stay as RandomCharacter
          rem until roll succeeds
          return

CharacterSelectInputEntry
          rem Per-frame character select input handler with Quadtari
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
          rem
          rem Output: Dispatches to CharacterSelectHandleQuadtari or
          rem CharacterSelectInputComplete
          rem
          rem Mutates: qtcontroller (toggled to 1), playerCharacter[],
          rem playerLocked state
          rem
          rem Called Routines: CharacterSelectCheckControllerRescan -
          rem accesses controller state,
          rem   SetPlayerLocked (bank14) - accesses playerLocked state,
          rem   HandleCharacterSelectCycle - accesses playerCharacter[],
          rem   playerLocked,
          rem   HandleCharacterSelectFire - accesses playerCharacter[],
          rem   playerLocked
          rem
          rem Constraints: Must be colocated with
          rem CS_Player0LockClearDone, CS_Player1LockClearDone,
          rem              CS_HandlePlayer0Left, CS_HandlePlayer0Right,
          rem              CS_HandlePlayer0Fire,
          rem              CS_HandlePlayer1Left, CS_HandlePlayer1Right,
          rem              CS_HandlePlayer1Fire,
          rem              CharacterSelectHandleQuadtari,
          rem              CharacterSelectInputComplete
          rem              (all called via goto)
          rem              Entry point for character select input
          rem              (called from MainLoop)
          gosub CharacterSelectCheckControllerRescan : rem Check for controller re-detection on Select/Pause/ColorB&W switches
          
          rem Quadtari controller multiplexing
          
          if qtcontroller then goto CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          
          if joy0left then CS_HandlePlayer0Left
          if joy0right then CS_HandlePlayer0Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14 : goto CS_Player0LockClearDone
          if joy0down then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
CS_Player0LockClearDone
          rem Player 0 lock clear complete (label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with CharacterSelectInputEntry
          if joy0fire then CS_HandlePlayer0Fire
          
          rem Handle Player 2 input (joy1 on even frames)
          
          if joy1left then CS_HandlePlayer1Left
          if joy1right then CS_HandlePlayer1Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14 : goto CS_Player1LockClearDone
          if joy1down then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
CS_Player1LockClearDone
          rem Player 1 lock clear complete (label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with CharacterSelectInputEntry
          if joy1fire then CS_HandlePlayer1Fire
          
          let qtcontroller = 1
          goto CharacterSelectInputComplete
          
CS_HandlePlayer0Left
          let temp1 = 0 : let temp2 = 0 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer0Right
          let temp1 = 0 : let temp2 = 1 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer0Fire
          let temp1 = 0 : gosub HandleCharacterSelectFire
          return
CS_HandlePlayer1Left
          let temp1 = 1 : let temp2 = 0 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer1Right
          let temp1 = 1 : let temp2 = 1 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer1Fire
          let temp1 = 1 : gosub HandleCharacterSelectFire
          return

CharacterSelectHandleQuadtari
          rem Handle Player 3 input (joy0 on odd frames)
          if !(controllerStatus & SetQuadtariDetected) then CS_SkipPlayer3
          if joy0left then CS_HandlePlayer3Left
          if joy0right then CS_HandlePlayer3Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14 : goto CS_Player3LockClearDone
          if joy0down then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
CS_Player3LockClearDone
          if joy0fire then CS_HandlePlayer3Fire
CS_SkipPlayer3
          
          rem Handle Player 4 input (joy1 on odd frames)
          
          if !(controllerStatus & SetQuadtariDetected) then CS_SkipPlayer4
          if joy1left then CS_HandlePlayer4Left
          if joy1right then CS_HandlePlayer4Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14 : goto CS_Player4LockClearDone
          if joy1down then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank14
CS_Player4LockClearDone
          if joy1fire then CS_HandlePlayer4Fire
CS_SkipPlayer4
          
          let qtcontroller = 0
          goto CharacterSelectInputComplete
          
CS_HandlePlayer3Left
          let temp1 = 2 : let temp2 = 0 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer3Right
          let temp1 = 2 : let temp2 = 1 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer3Fire
          let temp1 = 2 : gosub HandleCharacterSelectFire
          return
CS_HandlePlayer4Left
          let temp1 = 3 : let temp2 = 0 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer4Right
          let temp1 = 3 : let temp2 = 1 : gosub HandleCharacterSelectCycle
          return
CS_HandlePlayer4Fire
          let temp1 = 3 : gosub HandleCharacterSelectFire
          return

CharacterSelectInputComplete
          gosub CharacterSelectHandleRandomRolls : rem Handle random character re-rolls if any players need it
          
          gosub SelectUpdateAnimations : rem Update character select animations

          rem Check if all players are ready to start (may transition to
          gosub CharacterSelectCheckReady : rem   next mode)

          gosub SelectDrawScreen : rem Draw character selection screen

          rem drawscreen called by MainLoop
          return
          return

          rem
          rem Random Character Roll Handler
          rem Re-roll random selections until valid (0-15), then lock
          
CharacterSelectHandleRandomRolls
          rem Check each player for pending random roll
          if playerCharacter[0] = RandomCharacter then goto CharacterSelectRollPlayer0
          if playerCharacter[1] = RandomCharacter then goto CharacterSelectRollPlayer1
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectCheckRollQuadtari
          goto CharacterSelectRollsDone
          
CharacterSelectCheckRollQuadtari
          if playerCharacter[2] = RandomCharacter then goto CharacterSelectRollPlayer2
          if playerCharacter[3] = RandomCharacter then goto CharacterSelectRollPlayer3
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer0
          let temp2 = rand & 31 : rem Roll 5-bit random: rand & 31 (0-31)
          rem If > 15, stay as RandomCharacter and retry next frame
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[0] = temp2 : rem Valid! Set character and lock with normal or handicap
          if randomSelectFlags_R[0] then goto CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto CharacterSelectLockPlayer0Done
CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
CharacterSelectLockPlayer0Done
          let randomSelectFlags_W[0] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer1
          let temp2 = rand & 31
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[1] = temp2
          if randomSelectFlags_R[1] then goto CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto CharacterSelectLockPlayer1Done
CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
CharacterSelectLockPlayer1Done
          let randomSelectFlags_W[1] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer2
          let temp2 = rand & 31
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[2] = temp2
          if randomSelectFlags_R[2] then goto CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto CharacterSelectLockPlayer2Done
CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
CharacterSelectLockPlayer2Done
          let randomSelectFlags_W[2] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer3
          let temp2 = rand & 31
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[3] = temp2
          if randomSelectFlags_R[3] then goto CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank14
          goto CharacterSelectLockPlayer3Done
CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked bank14
CharacterSelectLockPlayer3Done
          let randomSelectFlags_W[3] = 0
          
CharacterSelectRollsDone
          return

CharacterSelectCheckReady
          rem
          rem Check If Ready To Proceed
          rem 2-player mode: P1 must be locked AND (P2 locked OR P2 on
          rem CPU)
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectQuadtariReady
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if !temp2 then goto CharacterSelectReadyDone
          rem P1 is locked, check P2
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then goto CharacterSelectFinish
          rem P2 not locked, check if on CPU
          if playerCharacter[1] = CPUCharacter then goto CharacterSelectFinish
          goto CharacterSelectReadyDone
          
CharacterSelectQuadtariReady
          rem 4-player mode: Count players who are ready (locked OR on
          let readyCount = 0 : rem   CPU/NO)
          rem Count P1 ready
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[0] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[0] = NoCharacter then readyCount = readyCount + 1
          rem Count P2 ready
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[1] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[1] = NoCharacter then readyCount = readyCount + 1
          rem Count P3 ready
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[2] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[2] = NoCharacter then readyCount = readyCount + 1
          rem Count P4 ready
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[3] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if !temp2 && playerCharacter[3] = NoCharacter then readyCount = readyCount + 1
          if readyCount >= 2 then goto CharacterSelectFinish
          
CharacterSelectReadyDone
          return

CharacterSelectFinish
          rem Finalize selections and transition to falling animation
          rem
          rem Input: playerCharacter[] (global array) = character selections,
          rem        playerState[] (global array) = facing flags per player
          rem
          rem Output: Facing bit set for each active player,
          rem         gameMode set to ModeFallingAnimation
          rem
          rem Mutates: playerState[], gameMode
          rem Initialize facing bit (bit 0) for all selected players
          rem (default: face right = 1)
          if playerCharacter[0] = NoCharacter then SkipCharacter1Facing
          let playerState[0] = playerState[0] | 1
SkipCharacter1Facing
          if playerCharacter[1] = NoCharacter then SkipCharacter2Facing
          let playerState[1] = playerState[1] | 1
SkipCharacter2Facing
          if playerCharacter[2] = NoCharacter then SkipCharacter3Facing
          let playerState[2] = playerState[2] | 1
SkipCharacter3Facing
          if playerCharacter[3] = NoCharacter then SkipCharacter4Facing
          let playerState[3] = playerState[3] | 1
SkipCharacter4Facing
          
          let gameMode = ModeFallingAnimation : rem Transition to falling animation
          gosub ChangeGameMode bank14
          return

CycleCharacterLeft
          rem
          rem Character Cycling Helpers
          rem Handle wraparound cycling for characters with special
          rem   values
          rem
          rem Input: temp1 = playerCharacter value, temp2 = direction
          rem   (0=left, 1=right), temp3 = player number
          rem Output: temp1 = new playerCharacter value
          rem Decrement character with special value wraparound
          rem P1: RandomCharacter(253) ↔ 0 ↔ 15 ↔ RandomCharacter
          rem P2: CPUCharacter(254) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔
          rem   CPUCharacter
          rem P3/P4: NoCharacter(255) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔
          rem   NoCharacter
          
          if temp1 = RandomCharacter then goto CycleFromRandom
          rem Check if we’re at a special value
          if temp1 = CPUCharacter then goto CycleFromCPU
          if temp1 = NoCharacter then goto CycleFromNO
          
          rem Normal character (0-15): decrement
          rem Check if we’re at 0 before decrementing (need to wrap to
          rem special)
          if !temp1 then goto CharacterSelectLeftWrapCheck
          let temp1 = temp1 - 1
          return
          
CharacterSelectLeftWrapCheck
          if temp3 = 0 then goto CSLWrapPlayer0Left
          rem After 0, wrap to player-specific special character
          if temp3 = 1 then goto SelectP2LeftWrap
          let temp1 = NoCharacter
          return

CSLWrapPlayer0Left
          let temp1 = RandomCharacter
          return
          
SelectP2LeftWrap
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not
          if !(controllerStatus & SetQuadtariDetected) then goto SelectP2LeftWrapCPU
          rem both NO)
          rem Check if P3 or P4 are NOT both NO
          if playerCharacter[2] = NoCharacter then goto CheckP4_LeftWrap
          let temp1 = NoCharacter
          return
SelectP2LeftWrapCPU
          let temp1 = CPUCharacter
          return
CheckP4_LeftWrap
          if playerCharacter[3] = NoCharacter then goto BothNO_LeftWrap
          let temp1 = NoCharacter
          return
BothNO_LeftWrap
          let temp1 = CPUCharacter : rem Both P3 and P4 are NO, so P2 wraps to CPU
          return
          
CycleFromRandom
          rem RandomCharacter(253) left cycle: direction-dependent
          rem P1: ... Random → 15 → 14 → ...
          rem P2: ... Random → NO (if available) → CPU OR Random → 15
          rem P3/P4: Random → NO
          rem Check if this is P2 with NO available
          if temp3 = 1 then goto SelectP2LeftFromRandom
          rem P1 or P3/P4: Random left goes to NO (P3/P4) or 15 (P1)
          if temp3 = 0 then goto CycleFromRandomPlayer0
          rem P1 → 15
          let temp1 = NoCharacter : rem P3/P4 → NO
          return

CycleFromRandomPlayer0
          let temp1 = MaxCharacter
          return
          
SelectP2LeftFromRandom
          rem P2 left from Random: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then goto SelectP2LeftFromRandomMax
          rem Check if P3 or P4 are NOT both NO
          if playerCharacter[2] = NoCharacter then CheckP4_LeftFromRandom
          let temp1 = NoCharacter
          return

SelectP2LeftFromRandomMax
          let temp1 = MaxCharacter
          return
CheckP4_LeftFromRandom
          if playerCharacter[3] = NoCharacter then BothNO_LeftFromRandom
          let temp1 = NoCharacter
          return
BothNO_LeftFromRandom
          let temp1 = MaxCharacter : rem Both P3 and P4 are NO, so NO not available, go to 15
          return
          
CycleFromCPU
          rem CPUCharacter(254) left cycle: goes to RandomCharacter(253)
          rem   for all players
          rem For P2, this is the left direction from CPU
          rem P2 left from CPU: if NO available, NO → Random, else
          rem   Random
          rem Actually, left from CPU means we’re decrementing, so CPU
          rem   is after Random
          rem The cycle is: ... Random → CPU → Random ...
          rem So left from CPU should go to Random (we already have
          let temp1 = RandomCharacter : rem   this)
          return
          
CycleFromNO
          rem NoCharacter(255) left cycle: direction-dependent
          rem P2 with NO available: NO → CPU (left), NO → Random (right)
          rem P3/P4: NO → Random (both directions since NO is start/end)
          rem For left cycle (decrement): P2 goes from NO to CPU
          if temp3 = 1 then goto CycleFromNOPlayer2
          rem P2 left from NO → CPU
          let temp1 = RandomCharacter : rem P3/P4: NO → Random
          return

CycleFromNOPlayer2
          let temp1 = CPUCharacter
          return
          
CycleCharacterRight
          if temp1 = RandomCharacter then goto CycleRightFromRandom
          rem Increment character with special value wraparound
          if temp1 = CPUCharacter then goto CycleRightFromCPU
          if temp1 = NoCharacter then goto CycleRightFromNO
          
          let temp1 = temp1 + 1 : rem Normal character (0-15): increment
          rem Check if we went past 15 (wrap to RandomCharacter)
          if temp1 > MaxCharacter then goto CharacterSelectRightWrapCheck
          return
          
CharacterSelectRightWrapCheck
          let temp1 = RandomCharacter : rem After 15, go to RandomCharacter instead of wrapping to 0
          return
          
CycleRightFromRandom
          if temp3 = 0 then goto CycleRightFromRandomPlayer0
          rem RandomCharacter(253) goes to special for each player
          if temp3 = 1 then goto SelectP2RightFromRandom
          let temp1 = NoCharacter
          return

CycleRightFromRandomPlayer0
          let temp1 = 0
          return
          
SelectP2RightFromRandom
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not
          if !(controllerStatus & SetQuadtariDetected) then goto SelectP2RightFromRandomCPU
          rem both NO)
          rem Check if P3 or P4 are NOT both NO
          if playerCharacter[2] = NoCharacter then goto CheckP4_RightFromRandom
          let temp1 = NoCharacter
          return
SelectP2RightFromRandomCPU
          let temp1 = CPUCharacter
          return
CheckP4_RightFromRandom
          if playerCharacter[3] = NoCharacter then goto BothNO_RightFromRandom
          let temp1 = NoCharacter
          return
BothNO_RightFromRandom
          let temp1 = CPUCharacter : rem Both P3 and P4 are NO, so P2 goes to CPU
          return
          
CycleRightFromCPU
          rem CPUCharacter(254) wraps based on player
          rem P1: CPU → Random → ...
          rem P2: CPU → NO (if available) → Random → ... OR CPU → Random
          rem P3/P4: Should not reach CPU, but handle gracefully
          if temp3 = 1 then goto SelectP2RightFromCPU
          goto CycleRightFromCPUDone
SelectP2RightFromCPU
          rem P2 from CPU: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then goto SelectP2RightFromCPURandom
          rem Check if P3 or P4 are NOT both NO
          if playerCharacter[2] = NoCharacter then goto CheckP4_RightFromCPU
          let temp1 = NoCharacter
          return
SelectP2RightFromCPURandom
          let temp1 = RandomCharacter
          return
CheckP4_RightFromCPU
          if playerCharacter[3] = NoCharacter then goto BothNO_RightFromCPU
          let temp1 = NoCharacter
          return
BothNO_RightFromCPU
          let temp1 = RandomCharacter : rem Both P3 and P4 are NO, so skip NO and go to Random
          return
CycleRightFromCPUDone
          let temp1 = RandomCharacter : rem Default for P1 or other players (not P2)
          return
          
CycleRightFromNO
          let temp1 = 0 : rem NoCharacter(255) goes to 0
          return
          
SelectDrawScreen
          rem Character Select drawing (sprites and HUD)
          rem Playfield layout is static; no runtime register writes
          
          rem Draw Player 1 selection (top left)
          player0x = 56 : player0y = 40
          gosub SelectDrawSprite
          let temp1 = 0
          gosub SelectDrawNumber
          
          rem Draw Player 2 selection (top right)
          player1x = 104 : player1y = 40
          gosub SelectDrawSprite
          let temp1 = 1
          gosub SelectDrawNumber
          
          if !(controllerStatus & SetQuadtariDetected) then goto SelectDrawScreenDone
          
          rem Draw Player 3 selection (bottom left)
          player0x = 56 : player0y = 80
          gosub SelectDrawSprite
          let temp1 = 2
          gosub SelectDrawNumber
          
          rem Draw Player 4 selection (bottom right)
          player1x = 104 : player1y = 80
          gosub SelectDrawSprite
          let temp1 = 3
          gosub SelectDrawNumber
          
SelectDrawScreenDone
          return
          
SelectDrawSprite
          rem Draw character sprite based on current position and
          rem   playerCharacter
          let temp3 = 255 : rem Determine which player based on position
          rem Initialize to invalid
          if player0x = 56 then goto SelectDeterminePlayerP0
          if player1x = 104 then goto SelectDeterminePlayerP1
          goto SelectDrawSpriteDone
          
SelectDeterminePlayerP0
          if player0y = 40 then let temp3 = 0 : goto SelectLoadSprite
          if player0y = 80 then let temp3 = 2 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
          
SelectDeterminePlayerP1
          if player1y = 40 then let temp3 = 1 : goto SelectLoadSprite
          if player1y = 80 then let temp3 = 3 : goto SelectLoadSprite
          goto SelectDrawSpriteDone
          
SelectLoadSprite
          rem Load sprite for determined player
          if temp3 > 3 then goto SelectDrawSpriteDone
          let temp6 = temp3
          let temp1 = playerCharacter[temp6] : rem Save player number
          
          rem Check for special characters (?, CPU, NO) before normal
          rem art loading
          rem Special characters don’t animate, so handle them separately
          if temp1 = NoCharacter then goto SelectLoadSpecialSprite
          rem NoCharacter = 255
          if temp1 = CPUCharacter then goto SelectLoadSpecialSprite
          rem CPUCharacter = 254
          if temp1 = RandomCharacter then goto SelectLoadSpecialSprite
          rem RandomCharacter = 253
          
          rem Normal character - use animation state
          rem Use character select animation state
          rem characterSelectPlayerAnimationSequence has animation sequence (bit 0:
          rem   0=idle, 1=walk)
          rem characterSelectPlayerAnimationFrame has animation frame counter
          rem   (0-7)
          rem Map to proper animation action: 0=idle (ActionIdle=1),
          rem 1=walk (ActionWalking=3)
          if characterSelectPlayerAnimationSequence_R[temp6] then goto SelectLoadWalkingSprite
          
          let temp2 = characterSelectPlayerAnimationFrame_R[temp6] : rem Idle animation
          rem frame
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          let temp3 = 1 : rem temp3=action, temp4=player
          let temp4 = temp6 : rem ActionIdle = 1
          gosub LocateCharacterArt bank14
          goto SelectLoadSpriteColor
          
SelectLoadSpecialSprite
          rem Map special character indices to sprite indices
          rem NoCharacter (255) -> SpriteNo (2)
          rem CPUCharacter (254) -> SpriteCPU (1)
          rem RandomCharacter (253) -> SpriteQuestionMark (0)
          rem temp1 still contains character index from SelectLoadSprite
          let temp3 = temp6 : rem Character index already in temp1
          rem Player number saved in temp6
          if temp1 = NoCharacter then let temp6 = SpriteNo : goto SelectLoadSpecialSpriteCall
          if temp1 = CPUCharacter then let temp6 = SpriteCPU : goto SelectLoadSpecialSpriteCall
          let temp6 = SpriteQuestionMark
          rem RandomCharacter = 253
          
SelectLoadSpecialSpriteCall
          rem LoadSpecialSprite expects: temp6 = sprite index, temp3 =
          rem player number
          rem Preserve player number from temp6 to temp3 before overwriting temp6
          rem temp3 now has player number
          gosub LoadSpecialSprite bank10 : rem temp6 now has sprite index
          goto SelectLoadSpriteColor : rem Special sprites don’t need animation handling, go to color
          
SelectLoadWalkingSprite
          let temp2 = characterSelectPlayerAnimationSequence_R[temp6] : rem Walking animation
          let temp3 = 3 : rem Use sequence counter as frame (0-3 for 4-frame walk)
          let temp4 = temp6 : rem ActionWalking = 3
          gosub LocateCharacterArt bank14
          
SelectLoadSpriteColor
          let temp1 = playerCharacter[temp6] : rem Now set player color
          let temp2 = 0
          let temp3 = temp6 : rem not hurt
          let temp4 = 0 : rem player number
          rem not flashing
          gosub LoadCharacterColors
          
          rem temp3 restored via LoadCharacterColors
          let temp1 = temp6
          gosub GetPlayerLocked bank14
          let temp5 = temp2
          let temp3 = temp6
          if !temp5 then goto SelectApplyUnlockedColor
          if temp5 = PlayerHandicapped then goto SelectApplyHandicapColor
          
SelectDrawSpriteDone
          return

SelectApplyUnlockedColor
          gosub SelectSetPlayerColorUnlocked
          goto SelectDrawSpriteDone

SelectApplyHandicapColor
          gosub SelectSetPlayerColorHandicap
          goto SelectDrawSpriteDone
          
SelectDrawNumber
          rem Draw player number indicator (1-4) beneath selection
          rem Input: temp1 = player index (0-3)

          if temp1 > 3 then let temp1 = 3
          
          gosub GetPlayerLocked bank14
          let temp6 = temp2
          
          let temp4 = ColGrey(14)
          if temp6 = PlayerLockedNormal then goto SDN_SetBrightColor
          if temp6 = PlayerHandicapped then goto SDN_SetDimColor
          goto SDN_SelectPosition
          
SDN_SetBrightColor
          on temp1 goto SDN_SetBrightColor0 SDN_SetBrightColor1 SDN_SetBrightColor2 SDN_SetBrightColor3

SDN_SetBrightColor0
          let temp4 = ColIndigo(14)
          goto SDN_SelectPosition

SDN_SetBrightColor1
          let temp4 = ColRed(14)
          goto SDN_SelectPosition

SDN_SetBrightColor2
          let temp4 = ColYellow(14)
          goto SDN_SelectPosition

SDN_SetBrightColor3
          let temp4 = ColTurquoise(14)
          goto SDN_SelectPosition
          
SDN_SetDimColor
          on temp1 goto SDN_SetDimColor0 SDN_SetDimColor1 SDN_SetDimColor2 SDN_SetDimColor3

SDN_SetDimColor0
          let temp4 = ColIndigo(6)
          goto SDN_SelectPosition

SDN_SetDimColor1
          let temp4 = ColRed(6)
          goto SDN_SelectPosition

SDN_SetDimColor2
          let temp4 = ColYellow(6)
          goto SDN_SelectPosition

SDN_SetDimColor3
          let temp4 = ColTurquoise(6)

SDN_SelectPosition
          on temp1 goto SDN_Player0 SDN_Player1 SDN_Player2 SDN_Player3
          
SDN_Player0
          let temp2 = 56
          let temp3 = 48
          let temp5 = 0
          let temp1 = 1
          goto SDN_DrawDigit
          
SDN_Player1
          let temp2 = 104
          let temp3 = 48
          let temp5 = 1
          let temp1 = 2
          goto SDN_DrawDigit
          
SDN_Player2
          let temp2 = 56
          let temp3 = 88
          let temp5 = 0
          let temp1 = 3
          goto SDN_DrawDigit
          
SDN_Player3
          let temp2 = 104
          let temp3 = 88
          let temp5 = 1
          let temp1 = 4
          
SDN_DrawDigit
          gosub DrawDigit bank16
          return

SelectSetPlayerColorUnlocked
          rem Override sprite color to indicate unlocked state (white)
          rem Input: temp3 = player number (0-3)
          if temp3 > 3 then temp3 = 3
          on temp3 goto SelectSetPlayerColorUnlocked0 SelectSetPlayerColorUnlocked1 SelectSetPlayerColorUnlocked2 SelectSetPlayerColorUnlocked3

SelectSetPlayerColorUnlocked0
          COLUP0 = ColGrey(14)
          return

SelectSetPlayerColorUnlocked1
          _COLUP1 = ColGrey(14)
          return

SelectSetPlayerColorUnlocked2
          COLUP2 = ColGrey(14)
          return

SelectSetPlayerColorUnlocked3
          COLUP3 = ColGrey(14)
          return

SelectSetPlayerColorHandicap
          rem Override sprite color to indicate handicap lock (dim player color)
          rem Input: temp3 = player number (0-3)
          if temp3 > 3 then temp3 = 3
          on temp3 goto SelectSetPlayerColorHandicap0 SelectSetPlayerColorHandicap1 SelectSetPlayerColorHandicap2 SelectSetPlayerColorHandicap3
SelectSetPlayerColorHandicap0
          COLUP0 = ColIndigo(6)
          return

SelectSetPlayerColorHandicap1
          _COLUP1 = ColRed(6)
          return

SelectSetPlayerColorHandicap2
          COLUP2 = ColYellow(6)
          return

SelectSetPlayerColorHandicap3
          COLUP3 = ColTurquoise(6)
          return
          
SelectDrawLocks
          rem Legacy playfield borders removed; no runtime playfield writes
          return
          
          rem
          rem Animation Updates

SelectUpdateAnimations
          rem Update character select animations for all players
          rem Players cycle through idle/walk animations to show
          rem   selected characters
          rem Each player updates independently with staggered timing
          
          rem Update Player 1 animations (characters)
          rem Locked players don’t animate
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then goto SelectSkipPlayer0Animation
          rem CPU doesn’t animate
          if playerCharacter[0] = CPUCharacter then goto SelectSkipPlayer0Animation
          rem NO doesn’t animate
          if playerCharacter[0] = NoCharacter then goto SelectSkipPlayer0Animation
          rem Random doesn’t animate
          if playerCharacter[0] = RandomCharacter then goto SelectSkipPlayer0Animation
          let temp1 = 0
          gosub SelectUpdatePlayerAnimation
          
SelectSkipPlayer0Animation
          rem Update Player 2 animations
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then goto SelectSkipPlayer1Animation
          if playerCharacter[1] = CPUCharacter then goto SelectSkipPlayer1Animation
          if playerCharacter[1] = NoCharacter then goto SelectSkipPlayer1Animation
          if playerCharacter[1] = RandomCharacter then goto SelectSkipPlayer1Animation
          let temp1 = 1
          gosub SelectUpdatePlayerAnimation
          
SelectSkipPlayer1Animation
          rem Update Player 3 animations (if Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto SelectSkipPlayer23Animation
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then goto SelectSkipPlayer2Animation
          if playerCharacter[2] = NoCharacter then goto SelectSkipPlayer2Animation
          if playerCharacter[2] = RandomCharacter then goto SelectSkipPlayer2Animation
          let temp1 = 2
          gosub SelectUpdatePlayerAnimation
          
SelectSkipPlayer2Animation
          rem Update Player 4 animations (if Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto SelectSkipPlayer23Animation
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then goto SelectSkipPlayer23Animation
          if playerCharacter[3] = NoCharacter then goto SelectSkipPlayer23Animation
          if playerCharacter[3] = RandomCharacter then goto SelectSkipPlayer23Animation
          let temp1 = 3
          gosub SelectUpdatePlayerAnimation
          
SelectSkipPlayer23Animation
          return
          
          rem
          rem Update Individual Player Animation
          
SelectUpdatePlayerAnimation
          rem Update animation for a single player
          rem
          rem Input: playerIndex = player index (0-3)
          let temp2 = characterSelectPlayerAnimationFrame_R[temp1] + 1 : rem Increment frame counter
          let characterSelectPlayerAnimationFrame_W[temp1] = temp2
          
          rem Check if it’s time to advance frame (every 6 frames for
          rem 10fps at 60fps)
          if characterSelectPlayerAnimationFrame_R[temp1] >= AnimationFrameDelay then goto SelectAdvanceAnimationFrame
          return
          
SelectAdvanceAnimationFrame
          let characterSelectPlayerAnimationFrame_W[temp1] = 0 : rem Reset frame counter
          
          rem Check current animation sequence
          
          if !characterSelectPlayerAnimationSequence_R[temp1] then goto SelectAdvanceIdleAnimation
          rem Walking animation: cycle through 4 frames (0-3)
          let temp2 = (characterSelectPlayerAnimationSequence_R[temp1] + 1) & 3 : rem Use bit 0-1 of sequence counter
          let characterSelectPlayerAnimationSequence_W[temp1] = temp2
          
          rem After 4 walk frames (frame 3→0), switch to idle
          
          if characterSelectPlayerAnimationSequence_R[temp1] then return
          let characterSelectPlayerAnimationSequence_W[temp1] = 0 : rem Switch back to idle after walk cycle
          
          rem Toggle to walk sequence after idle
          goto SelectAnimationWaitForToggle : rem Just set sequence flag to 1 (walk) for next cycle
          
SelectAdvanceIdleAnimation
          rem Idle animation cycles every 60 frames, then toggles to
          rem   walk
          rem Use higher bit in sequence to count idle cycles
          rem Every 60 frames (10 idle animations), toggle to walk
          if frame & 63 then return
          rem Check every 64 frames roughly
          
          let characterSelectPlayerAnimationSequence_W[temp1] = 1 : rem Toggle to walk
          rem Start walking
          return
          
SelectAnimationWaitForToggle
          return
          rem Just return, toggling handled above

          rem
          rem Controller Rescan Detection
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          rem to handle Quadtari being connected/disconnected
          
CharacterSelectCheckControllerRescan
          rem Check for Game Select or Pause button press
          if switchselect then goto CharacterSelectDoRescan
          let temp6 = switchbw : rem Check for Color/B&W switch toggle
          if temp6 = colorBWPrevious_R then goto CharacterSelectRescanDone
          gosub SelDetectQuad bank6 : rem Switch toggled, do rescan
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
          
CharacterSelectDoRescan
          gosub SelDetectQuad bank6 : rem Re-detect Quadtari via bank6
          rem Debounce - wait for switch release (drawscreen called by
          rem MainLoop)
          
CharacterSelectRescanDone
          return

