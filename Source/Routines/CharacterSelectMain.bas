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
          rem   playerChar[0-3) - Selected character indices (0-15)
          rem
          rem   playerLocked[0-3) - Lock state (0=unlocked, 1=locked)
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   readyCount - Number of locked players
          rem Shared Character Select Input Handlers
          rem Consolidated input handlers for character selection
          rem Handle character cycling (left/right)
          rem INPUT: temp1 = player index (0-3), temp2 = direction (0=left, 1=right)
          rem        temp3 = player number (0-3)
          rem Uses: joy0left/joy0right for players 0,2; joy1left/joy1right for players 1,3
          rem OUTPUT: Updates playerChar[playerIndex] and plays sound
          rem Handle character cycling (left/right) for a player
          rem Input: temp1 = player index (0-3)
          rem        temp2 = direction (0=left, 1=right)
          rem        playerChar[] (global array) = current character selections
          rem        joy0left, joy0right, joy1left, joy1right (hardware) = joystick states
          rem Output: playerChar[HCSC_playerIndex] updated, playerLocked state set to unlocked
          rem Mutates: playerChar[HCSC_playerIndex] (cycled), playerLocked state (set to unlocked),
          rem         temp1, temp2, temp3 (passed to helper routines)
          rem Called Routines: CycleCharacterLeft, CycleCharacterRight - access playerChar[],
          rem   SetPlayerLocked (bank144) - accesses playerLocked state,
          rem   PlaySoundEffect (bank15) - plays navigation sound
          rem Constraints: Must be colocated with HCSC_CheckJoy0, HCSC_CheckJoy0Left,
          rem              HCSC_CheckJoy1Left, HCSC_DoCycle, HCSC_CycleLeft, HCSC_CycleDone
          dim HCSC_playerIndex = temp1 : rem              (all called via goto)
          dim HCSC_direction = temp2
          dim HCSC_playerNumber = temp3
          dim HCSC_characterIndex = temp1
          dim HCSC_soundId = temp1
          if HCSC_playerIndex = 0 then HCSC_CheckJoy0 : rem Determine which joy port to use
          if HCSC_playerIndex = 2 then HCSC_CheckJoy0
          if HCSC_direction = 0 then HCSC_CheckJoy1Left : rem Players 1,3 use joy1
          if !joy1right then return
          goto HCSC_DoCycle
HCSC_CheckJoy0
          rem Check joy0 for players 0,2
          rem Input: HCSC_playerIndex, HCSC_direction (from HandleCharacterSelectCycle)
          rem        joy0left, joy0right (hardware) = joystick states
          rem Output: Dispatches to HCSC_CheckJoy0Left or HCSC_DoCycle
          rem Mutates: None (dispatcher only)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with HandleCharacterSelectCycle
          if HCSC_direction = 0 then HCSC_CheckJoy0Left : rem Players 0,2 use joy0
          if !joy0right then return
          goto HCSC_DoCycle
HCSC_CheckJoy0Left
          rem Check joy0 left button
          rem Input: joy0left (hardware) = joystick state
          rem Output: Returns if not pressed, continues to HCSC_DoCycle if pressed
          rem Mutates: None
          rem Called Routines: None
          if !joy0left then return : rem Constraints: Must be colocated with HandleCharacterSelectCycle
HCSC_CheckJoy1Left
          rem Check joy1 left button
          rem Input: joy1left (hardware) = joystick state
          rem Output: Returns if not pressed, continues to HCSC_DoCycle if pressed
          rem Mutates: None
          rem Called Routines: None
          if !joy1left then return : rem Constraints: Must be colocated with HandleCharacterSelectCycle
HCSC_DoCycle
          rem Perform character cycling
          rem Input: HCSC_playerIndex, HCSC_direction (from HandleCharacterSelectCycle)
          rem        playerChar[] (global array) = current character selections
          rem Output: playerChar[HCSC_playerIndex] cycled, playerLocked state set to unlocked
          rem Mutates: playerChar[HCSC_playerIndex], playerLocked state, temp1, temp2, temp3
          rem Called Routines: CycleCharacterLeft, CycleCharacterRight, SetPlayerLocked (bank144),
          rem   PlaySoundEffect (bank15)
          rem Constraints: Must be colocated with HandleCharacterSelectCycle, HCSC_CycleLeft, HCSC_CycleDone
          let HCSC_characterIndex = playerChar[HCSC_playerIndex] : rem Get current character index
          let HCSC_playerNumber = HCSC_playerIndex
          let temp1 = HCSC_characterIndex
          let temp3 = HCSC_playerNumber
          if HCSC_direction = 0 then HCSC_CycleLeft : rem Cycle based on direction
          gosub CycleCharacterRight
          goto HCSC_CycleDone
HCSC_CycleLeft
          rem Cycle character left
          rem Input: temp1, temp3 (from HCSC_DoCycle)
          rem Output: temp1 updated with cycled character index
          rem Mutates: temp1 (cycled character index)
          rem Called Routines: CycleCharacterLeft - accesses playerChar[]
          rem Constraints: Must be colocated with HandleCharacterSelectCycle, HCSC_DoCycle, HCSC_CycleDone
          gosub CycleCharacterLeft
HCSC_CycleDone
          rem Character cycling complete
          rem Input: HCSC_characterIndex, HCSC_playerIndex (from HandleCharacterSelectCycle)
          rem        temp1 (from CycleCharacterLeft/Right)
          rem Output: playerChar[HCSC_playerIndex] updated, playerLocked state set to unlocked
          rem Mutates: playerChar[HCSC_playerIndex], playerLocked state, temp1, temp2
          rem Called Routines: SetPlayerLocked (bank144), PlaySoundEffect (bank15)
          let HCSC_characterIndex = temp1 : rem Constraints: Must be colocated with HandleCharacterSelectCycle
          let playerChar[HCSC_playerIndex] = HCSC_characterIndex
          let temp1 = HCSC_playerIndex
          let temp2 = PlayerLockedUnlocked
          gosub SetPlayerLocked bank144
          let HCSC_soundId = SoundMenuNavigate : rem Play navigation sound
          let temp1 = HCSC_soundId
          gosub PlaySoundEffect bank15
          return
          
HandleCharacterSelectFire
          rem Handle fire input (selection)
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0fire/joy0down for players 0,2; joy1fire/joy1down for players 1,3
          rem OUTPUT: Updates playerLocked and plays sound
          rem Handle fire input (selection) for a player
          rem Input: temp1 = player index (0-3)
          rem        playerChar[] (global array) = current character selections
          rem        joy0fire, joy0down, joy1fire, joy1down (hardware) = joystick states
          rem        randomSelectFlags[] (global array) = random selection flags
          rem Output: playerLocked state updated, randomSelectFlags[] updated if random selected
          rem Mutates: playerLocked state (set to normal or handicap), randomSelectFlags[] (if random),
          rem         temp1, temp2, temp3, temp4 (passed to helper routines)
          rem Called Routines: SetPlayerLocked (bank144) - accesses playerLocked state,
          rem   PlaySoundEffect (bank15) - plays selection sound
          rem Constraints: Must be colocated with HCSF_CheckJoy0, HCSF_HandleFire,
          dim HCSF_playerIndex = temp1 : rem              HCSF_HandleHandicap, HCSF_HandleRandom (all called via goto)
          dim HCSF_soundId = temp1
          dim HCSF_playerNumber = temp3
          dim HCSF_joyFire = temp2
          dim HCSF_joyDown = temp4
          if HCSF_playerIndex = 0 then HCSF_CheckJoy0 : rem Determine which joy port to use
          if HCSF_playerIndex = 2 then HCSF_CheckJoy0
          if !joy1fire then return : rem Players 1,3 use joy1
          let HCSF_joyFire = 1
          if joy1down then let HCSF_joyDown = 1 else let HCSF_joyDown = 0
          goto HCSF_HandleFire
HCSF_CheckJoy0
          rem Check joy0 for players 0,2
          rem Input: HCSF_playerIndex (from HandleCharacterSelectFire)
          rem        joy0fire, joy0down (hardware) = joystick states
          rem Output: Dispatches to HCSF_HandleFire or returns
          rem Mutates: HCSF_joyFire, HCSF_joyDown
          rem Called Routines: None
          rem Constraints: Must be colocated with HandleCharacterSelectFire
          if !joy0fire then return : rem Players 0,2 use joy0
          let HCSF_joyFire = 1
          if joy0down then let HCSF_joyDown = 1 else let HCSF_joyDown = 0
HCSF_HandleFire
          rem Handle fire button press
          rem Input: HCSF_playerIndex, HCSF_joyDown (from HandleCharacterSelectFire)
          rem        playerChar[] (global array) = current character selections
          rem Output: Dispatches to HCSF_HandleRandom, HCSF_HandleHandicap, or locks normally
          rem Mutates: playerLocked state, randomSelectFlags[] (if random)
          rem Called Routines: SetPlayerLocked (bank144), PlaySoundEffect (bank15)
          rem Constraints: Must be colocated with HandleCharacterSelectFire
          if playerChar[HCSF_playerIndex] = RandomCharacter then HCSF_HandleRandom : rem Check if RandomCharacter selected
          rem Check for handicap mode (down+fire = 75% health)
          if HCSF_joyDown then HCSF_HandleHandicap
          let HCSF_playerNumber = HCSF_playerIndex
          let temp1 = HCSF_playerNumber
          let temp2 = PlayerLockedNormal
          gosub SetPlayerLocked bank144
          let HCSF_soundId = SoundMenuSelect : rem Play selection sound
          let temp1 = HCSF_soundId
          gosub PlaySoundEffect bank15
          return
HCSF_HandleHandicap
          rem Handle handicap mode selection (75% health)
          rem Input: HCSF_playerIndex (from HandleCharacterSelectFire)
          rem Output: playerLocked state set to handicap
          rem Mutates: playerLocked state (set to handicap)
          rem Called Routines: SetPlayerLocked (bank144), PlaySoundEffect (bank15)
          let HCSF_playerNumber = HCSF_playerIndex : rem Constraints: Must be colocated with HandleCharacterSelectFire
          let temp1 = HCSF_playerNumber
          let temp2 = PlayerLockedHandicap
          gosub SetPlayerLocked bank144
          let HCSF_soundId = SoundMenuSelect : rem Play selection sound
          let temp1 = HCSF_soundId
          gosub PlaySoundEffect bank15
          return
HCSF_HandleRandom
          rem Handle random character selection
          rem Input: HCSF_playerIndex, HCSF_joyDown (from HandleCharacterSelectFire)
          rem        randomSelectFlags[] (global array) = random selection flags
          rem Output: randomSelectFlags[HCSF_playerIndex] set, selection sound played
          rem Mutates: randomSelectFlags[HCSF_playerIndex] (set to $80 if handicap, 0 otherwise)
          rem Called Routines: PlaySoundEffect (bank15)
          rem Constraints: Must be colocated with HandleCharacterSelectFire
          rem Random selection initiated - will be handled by CharacterSelectHandleRandomRolls
          if HCSF_joyDown then randomSelectFlags[HCSF_playerIndex] = $80 else randomSelectFlags[HCSF_playerIndex] = 0 : rem Store handicap flag if down was held
          let HCSF_soundId = SoundMenuSelect : rem Play selection sound
          let temp1 = HCSF_soundId
          gosub PlaySoundEffect bank15
          rem Fall through - character will stay as RandomCharacter until roll succeeds
          return

CharacterSelectInputEntry
          rem Per-frame character select input handler with Quadtari multiplexing
          rem Input: qtcontroller (global) = Quadtari controller frame toggle
          rem        joy0left, joy0right, joy0up, joy0down, joy0fire (hardware) = Player 1/3 joystick
          rem        joy1left, joy1right, joy1up, joy1down, joy1fire (hardware) = Player 2/4 joystick
          rem        playerChar[] (global array) = current character selections
          rem        playerLocked (global) = player lock states
          rem Output: Dispatches to CharacterSelectHandleQuadtari or CharacterSelectInputComplete
          rem Mutates: qtcontroller (toggled to 1), playerChar[], playerLocked state
          rem Called Routines: CharacterSelectCheckControllerRescan - accesses controller state,
          rem   SetPlayerLocked (bank1) - accesses playerLocked state,
          rem   HandleCharacterSelectCycle - accesses playerChar[], playerLocked,
          rem   HandleCharacterSelectFire - accesses playerChar[], playerLocked
          rem Constraints: Must be colocated with CS_Player0LockClearDone, CS_Player1LockClearDone,
          rem              CS_HandlePlayer0Left, CS_HandlePlayer0Right, CS_HandlePlayer0Fire,
          rem              CS_HandlePlayer1Left, CS_HandlePlayer1Right, CS_HandlePlayer1Fire,
          rem              CharacterSelectHandleQuadtari, CharacterSelectInputComplete
          rem              (all called via goto)
          rem              Entry point for character select input (called from MainLoop)
          gosub CharacterSelectCheckControllerRescan : rem Check for controller re-detection on Select/Pause/ColorB&W switches
          
          if qtcontroller then goto CharacterSelectHandleQuadtari : rem Quadtari controller multiplexing
          
          if joy0left then CS_HandlePlayer0Left : rem Handle Player 1 input (joy0 on even frames)
          if joy0right then CS_HandlePlayer0Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1 : goto CS_Player0LockClearDone
          if joy0down then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
CS_Player0LockClearDone
          rem Player 0 lock clear complete (label only)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          if joy0fire then CS_HandlePlayer0Fire : rem Constraints: Must be colocated with CharacterSelectInputEntry
          
          if joy1left then CS_HandlePlayer1Left : rem Handle Player 2 input (joy1 on even frames)
          if joy1right then CS_HandlePlayer1Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1 : goto CS_Player1LockClearDone
          if joy1down then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
CS_Player1LockClearDone
          rem Player 1 lock clear complete (label only)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          if joy1fire then CS_HandlePlayer1Fire : rem Constraints: Must be colocated with CharacterSelectInputEntry
          
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
          if !(controllerStatus & SetQuadtariDetected) then CS_SkipPlayer3 : rem Handle Player 3 input (joy0 on odd frames)
          if selectedChar3_R = 0 then CS_SkipPlayer3
          if joy0left then CS_HandlePlayer3Left
          if joy0right then CS_HandlePlayer3Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1 : goto CS_Player3LockClearDone
          if joy0down then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
CS_Player3LockClearDone
          if joy0fire then CS_HandlePlayer3Fire
CS_SkipPlayer3
          
          if !(controllerStatus & SetQuadtariDetected) then CS_SkipPlayer4 : rem Handle Player 4 input (joy1 on odd frames)
          if selectedChar4_R = 0 then CS_SkipPlayer4
          if joy1left then CS_HandlePlayer4Left
          if joy1right then CS_HandlePlayer4Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1 : goto CS_Player4LockClearDone
          if joy1down then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank1
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
          if playerChar[0] = RandomCharacter then goto CharacterSelectRollPlayer0 : rem Check each player for pending random roll
          if playerChar[1] = RandomCharacter then goto CharacterSelectRollPlayer1
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectCheckRollQuadtari
          goto CharacterSelectRollsDone
          
CharacterSelectCheckRollQuadtari
          if playerChar[2] = RandomCharacter then goto CharacterSelectRollPlayer2
          if playerChar[3] = RandomCharacter then goto CharacterSelectRollPlayer3
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer0
          dim CSR0_rolledValue = temp2
          let CSR0_rolledValue = rand & 31 : rem Roll 5-bit random: rand & 31 (0-31)
          if CSR0_rolledValue > MaxCharacter then goto CharacterSelectRollsDone : rem If > 15, stay as RandomCharacter and retry next frame
          let playerChar[0] = CSR0_rolledValue : rem Valid! Set character and lock with normal or handicap
          if randomSelectFlags[0] then goto CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          goto CharacterSelectLockPlayer0Done
CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank1
CharacterSelectLockPlayer0Done
          let randomSelectFlags[0] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer1
          dim CSR1_rolledValue = temp2
          let CSR1_rolledValue = rand & 31
          if CSR1_rolledValue > MaxCharacter then goto CharacterSelectRollsDone
          let playerChar[1] = CSR1_rolledValue
          if randomSelectFlags[1] then goto CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          goto CharacterSelectLockPlayer1Done
CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank1
CharacterSelectLockPlayer1Done
          let randomSelectFlags[1] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer2
          dim CSR2_rolledValue = temp2
          let CSR2_rolledValue = rand & 31
          if CSR2_rolledValue > MaxCharacter then goto CharacterSelectRollsDone
          let playerChar[2] = CSR2_rolledValue
          if randomSelectFlags[2] then goto CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          goto CharacterSelectLockPlayer2Done
CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank1
CharacterSelectLockPlayer2Done
          let randomSelectFlags[2] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer3
          dim CSR3_rolledValue = temp2
          let CSR3_rolledValue = rand & 31
          if CSR3_rolledValue > MaxCharacter then goto CharacterSelectRollsDone
          let playerChar[3] = CSR3_rolledValue
          if randomSelectFlags[3] then goto CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank1
          goto CharacterSelectLockPlayer3Done
CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerLockedHandicap : gosub SetPlayerLocked bank1
CharacterSelectLockPlayer3Done
          let randomSelectFlags[3] = 0
          
CharacterSelectRollsDone
          return

          rem
          rem Check If Ready To Proceed
CharacterSelectCheckReady
          rem 2-player mode: P1 must be locked AND (P2 locked OR P2 on
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectQuadtariReady : rem   CPU)
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if !temp2 then goto CharacterSelectReadyDone
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then goto CharacterSelectFinish : rem P1 is locked, check P2
          if playerChar[1] = CPUCharacter then goto CharacterSelectFinish : rem P2 not locked, check if on CPU
          goto CharacterSelectReadyDone
          
CharacterSelectQuadtariReady
          rem 4-player mode: Count players who are ready (locked OR on
          let readyCount = 0 : rem   CPU/NO)
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1 : rem Count P1 ready
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[0] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 0 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[0] = NoCharacter then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1 : rem Count P2 ready
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[1] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[1] = NoCharacter then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1 : rem Count P3 ready
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[2] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[2] = NoCharacter then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if temp2 then readyCount = readyCount + 1 : rem Count P4 ready
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[3] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank14 : if !temp2 && playerChar[3] = NoCharacter then readyCount = readyCount + 1
          if readyCount >= 2 then goto CharacterSelectFinish
          
CharacterSelectReadyDone
          return

CharacterSelectFinish
          let selectedChar1 = playerChar[0] : rem Store final selections
          let selectedChar2_W = playerChar[1]
          let selectedChar3_W = playerChar[2]
          let selectedChar4_W = playerChar[3]
          
          rem Initialize facing bit (bit 0) for all selected players
          if selectedChar1 = NoCharacter then SkipChar1Facing : rem (default: face right = 1)
          let playerState[0] = playerState[0] | 1
SkipChar1Facing
          if selectedChar2_R = NoCharacter then SkipChar2Facing
          let playerState[1] = playerState[1] | 1
SkipChar2Facing
          if selectedChar3_R = NoCharacter then SkipChar3Facing
          let playerState[2] = playerState[2] | 1
SkipChar3Facing
          if selectedChar4_R = NoCharacter then SkipChar4Facing
          let playerState[3] = playerState[3] | 1
SkipChar4Facing
          
          let gameMode = ModeFallingAnimation : rem Transition to falling animation
          gosub ChangeGameMode bank14
          return

CycleCharacterLeft
          rem
          rem Character Cycling Helpers
          rem Handle wraparound cycling for characters with special
          rem   values
          rem Input: temp1 = playerChar value, temp2 = direction
          rem   (0=left, 1=right), temp3 = player number
          dim CCL_characterIndex = temp1 : rem Output: temp1 = new playerChar value
          dim CCL_playerNumber = temp3
          rem Decrement character with special value wraparound
          rem P1: RandomCharacter(253) ↔ 0 ↔ 15 ↔ RandomCharacter
          rem P2: CPUCharacter(254) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔
          rem   CPUCharacter
          rem P3/P4: NoCharacter(255) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔
          rem   NoCharacter
          
          if CCL_characterIndex = RandomCharacter then CycleFromRandom : return : rem Check if we’re at a special value
          if CCL_characterIndex = CPUCharacter then CycleFromCPU : return
          if CCL_characterIndex = NoCharacter then CycleFromNO : return
          
          rem Normal character (0-15): decrement
          rem Check if we’re at 0 before decrementing (need to wrap to
          if !CCL_characterIndex then goto CharacterSelectLeftWrapCheck : rem   special)
          let CCL_characterIndex = CCL_characterIndex - 1
          let temp1 = CCL_characterIndex
          return
          
CharacterSelectLeftWrapCheck
          dim CSLWC_characterIndex = temp1
          dim CSLWC_playerNumber = temp3
          if CSLWC_playerNumber = 0 then let CSLWC_characterIndex = RandomCharacter : let temp1 = CSLWC_characterIndex : return : rem After 0, wrap to player-specific special character
          if CSLWC_playerNumber = 1 then goto SelectP2LeftWrap
          let CSLWC_characterIndex = NoCharacter
          let temp1 = CSLWC_characterIndex
          return
          
SelectP2LeftWrap
          dim SP2LW_characterIndex = temp1
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not
          if !(controllerStatus & SetQuadtariDetected) then let SP2LW_characterIndex = CPUCharacter : let temp1 = SP2LW_characterIndex : return : rem both NO)
          if playerChar[2] = NoCharacter then goto CheckP4_LeftWrap : rem Check if P3 or P4 are NOT both NO
          let SP2LW_characterIndex = NoCharacter
          let temp1 = SP2LW_characterIndex
          return
CheckP4_LeftWrap
          if playerChar[3] = NoCharacter then goto BothNO_LeftWrap
          let SP2LW_characterIndex = NoCharacter
          let temp1 = SP2LW_characterIndex
          return
BothNO_LeftWrap
          let SP2LW_characterIndex = CPUCharacter : rem Both P3 and P4 are NO, so P2 wraps to CPU
          let temp1 = SP2LW_characterIndex
          return
          
CycleFromRandom
          dim CFR_characterIndex = temp1
          dim CFR_playerNumber = temp3
          rem RandomCharacter(253) left cycle: direction-dependent
          rem P1: ... Random → 15 → 14 → ...
          rem P2: ... Random → NO (if available) → CPU OR Random → 15
          rem P3/P4: Random → NO
          if CFR_playerNumber = 1 then goto SelectP2LeftFromRandom : rem Check if this is P2 with NO available
          rem P1 or P3/P4: Random left goes to NO (P3/P4) or 15 (P1)
          if CFR_playerNumber = 0 then let CFR_characterIndex = MaxCharacter : let temp1 = CFR_characterIndex : return
          rem P1 → 15
          let CFR_characterIndex = NoCharacter : rem P3/P4 → NO
          let temp1 = CFR_characterIndex
          return
          
SelectP2LeftFromRandom
          dim SP2LFR_characterIndex = temp1
          rem P2 left from Random: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then let SP2LFR_characterIndex = MaxCharacter : let temp1 = SP2LFR_characterIndex : return
          if playerChar[2] = NoCharacter then CheckP4_LeftFromRandom : rem Check if P3 or P4 are NOT both NO
          let SP2LFR_characterIndex = NoCharacter
          let temp1 = SP2LFR_characterIndex
          return
CheckP4_LeftFromRandom
          if playerChar[3] = NoCharacter then BothNO_LeftFromRandom
          let SP2LFR_characterIndex = NoCharacter
          let temp1 = SP2LFR_characterIndex
          return
BothNO_LeftFromRandom
          let SP2LFR_characterIndex = MaxCharacter : rem Both P3 and P4 are NO, so NO not available, go to 15
          let temp1 = SP2LFR_characterIndex
          return
          
CycleFromCPU
          dim CFC_characterIndex = temp1
          rem CPUCharacter(254) left cycle: goes to RandomCharacter(253)
          rem   for all players
          rem For P2, this is the left direction from CPU
          rem P2 left from CPU: if NO available, NO → Random, else
          rem   Random
          rem Actually, left from CPU means we’re decrementing, so CPU
          rem   is after Random
          rem The cycle is: ... Random → CPU → Random ...
          rem So left from CPU should go to Random (we already have
          let CFC_characterIndex = RandomCharacter : rem   this)
          let temp1 = CFC_characterIndex
          return
          
CycleFromNO
          dim CFNO_characterIndex = temp1
          dim CFNO_playerNumber = temp3
          rem NoCharacter(255) left cycle: direction-dependent
          rem P2 with NO available: NO → CPU (left), NO → Random (right)
          rem P3/P4: NO → Random (both directions since NO is start/end)
          rem For left cycle (decrement): P2 goes from NO to CPU
          if CFNO_playerNumber = 1 then let CFNO_characterIndex = CPUCharacter : let temp1 = CFNO_characterIndex : return
          rem P2 left from NO → CPU
          let CFNO_characterIndex = RandomCharacter : rem P3/P4: NO → Random
          let temp1 = CFNO_characterIndex
          return
          
CycleCharacterRight
          dim CCR_characterIndex = temp1
          dim CCR_playerNumber = temp3
          if CCR_characterIndex = RandomCharacter then CycleRightFromRandom : return : rem Increment character with special value wraparound
          if CCR_characterIndex = CPUCharacter then CycleRightFromCPU : return
          if CCR_characterIndex = NoCharacter then CycleRightFromNO : return
          
          let CCR_characterIndex = CCR_characterIndex + 1 : rem Normal character (0-15): increment
          if CCR_characterIndex > MaxCharacter then goto CharacterSelectRightWrapCheck : rem Check if we went past 15 (wrap to RandomCharacter)
          let temp1 = CCR_characterIndex
          return
          
CharacterSelectRightWrapCheck
          dim CSRWC_characterIndex = temp1
          let CSRWC_characterIndex = RandomCharacter : rem After 15, go to RandomCharacter instead of wrapping to 0
          let temp1 = CSRWC_characterIndex
          return
          
CycleRightFromRandom
          dim CRFR_characterIndex = temp1
          dim CRFR_playerNumber = temp3
          if CRFR_playerNumber = 0 then let CRFR_characterIndex = 0 : let temp1 = CRFR_characterIndex : return : rem RandomCharacter(253) goes to special for each player
          if CRFR_playerNumber = 1 then goto SelectP2RightFromRandom
          let CRFR_characterIndex = NoCharacter
          let temp1 = CRFR_characterIndex
          return
          
SelectP2RightFromRandom
          dim SP2RFR_characterIndex = temp1
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not
          if !(controllerStatus & SetQuadtariDetected) then let SP2RFR_characterIndex = CPUCharacter : let temp1 = SP2RFR_characterIndex : return : rem both NO)
          if playerChar[2] = NoCharacter then goto CheckP4_RightFromRandom : rem Check if P3 or P4 are NOT both NO
          let SP2RFR_characterIndex = NoCharacter
          let temp1 = SP2RFR_characterIndex
          return
CheckP4_RightFromRandom
          if playerChar[3] = NoCharacter then goto BothNO_RightFromRandom
          let SP2RFR_characterIndex = NoCharacter
          let temp1 = SP2RFR_characterIndex
          return
BothNO_RightFromRandom
          let SP2RFR_characterIndex = CPUCharacter : rem Both P3 and P4 are NO, so P2 goes to CPU
          let temp1 = SP2RFR_characterIndex
          return
          
CycleRightFromCPU
          dim CRFC_characterIndex = temp1
          dim CRFC_playerNumber = temp3
          rem CPUCharacter(254) wraps based on player
          rem P1: CPU → Random → ...
          rem P2: CPU → NO (if available) → Random → ... OR CPU → Random
          if CRFC_playerNumber = 1 then goto SelectP2RightFromCPU : rem P3/P4: Should not reach CPU, but handle gracefully
          goto CycleRightFromCPUDone
SelectP2RightFromCPU
          dim SP2RFC_characterIndex = temp1
          rem P2 from CPU: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then let SP2RFC_characterIndex = RandomCharacter : let temp1 = SP2RFC_characterIndex : return
          if playerChar[2] = NoCharacter then goto CheckP4_RightFromCPU : rem Check if P3 or P4 are NOT both NO
          let SP2RFC_characterIndex = NoCharacter
          let temp1 = SP2RFC_characterIndex
          return
CheckP4_RightFromCPU
          if playerChar[3] = NoCharacter then goto BothNO_RightFromCPU
          let SP2RFC_characterIndex = NoCharacter
          let temp1 = SP2RFC_characterIndex
          return
BothNO_RightFromCPU
          let SP2RFC_characterIndex = RandomCharacter : rem Both P3 and P4 are NO, so skip NO and go to Random
          let temp1 = SP2RFC_characterIndex
          return
CycleRightFromCPUDone
          dim CRFCD_characterIndex = temp1
          let CRFCD_characterIndex = RandomCharacter : rem Default for P1 or other players (not P2)
          let temp1 = CRFCD_characterIndex
          return
          
CycleRightFromNO
          dim CRFNO_characterIndex = temp1
          let CRFNO_characterIndex = 0 : rem NoCharacter(255) goes to 0
          let temp1 = CRFNO_characterIndex
          return
          
SelectDrawScreen
          rem
          rem Character Select Drawing Functions
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0 : pf3 = 0 : pf4 = 0 : pf5 = 0
          
          rem Draw Player 1 selection (top left)
          player0x = 56 : player0y = 40
          gosub SelectDrawSprite
          rem numbers are not shown on character select
          
          rem Draw Player 2 selection (top right)
          player1x = 104 : player1y = 40
          gosub SelectDrawSprite
          rem numbers are not shown on character select
          
          if controllerStatus & SetQuadtariDetected then goto SelectDrawP3 : rem Draw Player 3 selection (bottom left) if Quadtari
          goto SelectSkipP3
SelectDrawP3
          player0x = 56 : player0y = 80
          gosub SelectDrawSprite
          rem numbers are not shown on character select
          
          if controllerStatus & SetQuadtariDetected then goto SelectDrawP4 : rem Draw Player 4 selection (bottom right) if Quadtari
          goto SelectSkipP4
SelectDrawP4
          player1x = 104 : player1y = 80
          gosub SelectDrawSprite
          rem numbers are not shown on character select
SelectSkipP3
SelectSkipP4
          
          rem Draw locked status indicators
          goto SelectDrawLocks : rem tail call
          
SelectDrawSprite
          dim SDS_playerNumber = temp3
          dim SDS_playerNumberSaved = temp6
          dim SDS_characterIndex = temp1
          dim SDS_animationFrame = temp2
          dim SDS_animationAction = temp3
          dim SDS_playerNumberForArt = temp4
          dim SDS_isHurt = temp2
          dim SDS_isFlashing = temp4
          rem Draw character sprite based on current position and
          rem   playerChar
          let SDS_playerNumber = 255 : rem Determine which player based on position
          if player0x = 56 then goto SelectDeterminePlayerP0 : rem Initialize to invalid
          if player1x = 104 then goto SelectDeterminePlayerP1
          goto SelectDrawSpriteDone
          
SelectDeterminePlayerP0
          dim SDPP0_playerNumber = temp3
          if player0y = 40 then let SDPP0_playerNumber = 0 : let temp3 = SDPP0_playerNumber : goto SelectLoadSprite
          if player0y = 80 then let SDPP0_playerNumber = 2 : let temp3 = SDPP0_playerNumber : goto SelectLoadSprite
          goto SelectDrawSpriteDone
          
SelectDeterminePlayerP1
          dim SDPP1_playerNumber = temp3
          if player1y = 40 then let SDPP1_playerNumber = 1 : let temp3 = SDPP1_playerNumber : goto SelectLoadSprite
          if player1y = 80 then let SDPP1_playerNumber = 3 : let temp3 = SDPP1_playerNumber : goto SelectLoadSprite
          goto SelectDrawSpriteDone
          
SelectLoadSprite
          dim SLS_playerNumber = temp3
          dim SLS_playerNumberSaved = temp6
          dim SLS_characterIndex = temp1
          dim SLS_animationFrame = temp2
          dim SLS_animationAction = temp3
          dim SLS_playerNumberForArt = temp4
          dim SLS_spriteIndex = temp6
          if SLS_playerNumber > 3 then goto SelectDrawSpriteDone : rem Load sprite for determined player
          let SLS_playerNumberSaved = SLS_playerNumber
          let SLS_characterIndex = playerChar[SLS_playerNumberSaved] : rem Save player number
          
          rem Check for special characters (?, CPU, NO) before normal art loading
          if SLS_characterIndex = NoCharacter then goto SelectLoadSpecialSprite : rem Special characters don’t animate, so handle them separately
          if SLS_characterIndex = CPUCharacter then goto SelectLoadSpecialSprite : rem NoCharacter = 255
          if SLS_characterIndex = RandomCharacter then goto SelectLoadSpecialSprite : rem CPUCharacter = 254
          rem RandomCharacter = 253
          
          rem Normal character - use animation state
          rem Use character select animation state
          rem charSelectPlayerAnimSeq has animation sequence (bit 0:
          rem   0=idle, 1=walk)
          rem charSelectPlayerAnimFrame has animation frame counter
          rem   (0-7)
          rem Map to proper animation action: 0=idle (ActionIdle=1),
          if charSelectPlayerAnimSeq[SLS_playerNumberSaved] then goto SelectLoadWalkingSprite : rem 1=walk (ActionWalking=3)
          
          let SLS_animationFrame = charSelectPlayerAnimFrame[SLS_playerNumberSaved] : rem Idle animation
          rem frame
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          let SLS_animationAction = 1 : rem temp3=action, temp4=player
          let SLS_playerNumberForArt = SLS_playerNumberSaved : rem ActionIdle = 1
          let temp1 = SLS_characterIndex
          let temp2 = SLS_animationFrame
          let temp3 = SLS_animationAction
          let temp4 = SLS_playerNumberForArt
          gosub LocateCharacterArt bank14
          goto SelectLoadSpriteColor
          
SelectLoadSpecialSprite
          dim SLSS_characterIndex = temp1
          dim SLSS_spriteIndex = temp6
          dim SLSS_playerNumber = temp3
          rem Map special character indices to sprite indices
          rem NoCharacter (255) -> SpriteNo (2)
          rem CPUCharacter (254) -> SpriteCPU (1)
          rem RandomCharacter (253) -> SpriteQuestionMark (0)
          rem temp1 still contains character index from SelectLoadSprite
          let SLSS_characterIndex = temp1 : rem temp6 still contains player number saved (SLS_playerNumberSaved)
          let SLSS_playerNumber = temp6 : rem Character index already in temp1
          if SLSS_characterIndex = NoCharacter then let SLSS_spriteIndex = SpriteNo : goto SelectLoadSpecialSpriteCall : rem Player number saved in temp6
          if SLSS_characterIndex = CPUCharacter then let SLSS_spriteIndex = SpriteCPU : goto SelectLoadSpecialSpriteCall
          let SLSS_spriteIndex = SpriteQuestionMark
          rem RandomCharacter = 253
          
SelectLoadSpecialSpriteCall
          rem LoadSpecialSprite expects: temp6 = sprite index, temp3 = player number
          let temp3 = SLSS_playerNumber : rem Preserve player number from temp6 to temp3 before overwriting temp6
          let temp6 = SLSS_spriteIndex : rem temp3 now has player number
          gosub LoadSpecialSprite bank10 : rem temp6 now has sprite index
          goto SelectLoadSpriteColor : rem Special sprites don’t need animation handling, go to color
          
SelectLoadWalkingSprite
          dim SLWS_playerNumberSaved = temp6
          dim SLWS_animationFrame = temp2
          dim SLWS_animationAction = temp3
          dim SLWS_playerNumberForArt = temp4
          dim SLWS_characterIndex = temp1
          dim SLWS_isHurt = temp2
          dim SLWS_isFlashing = temp4
          let SLWS_animationFrame = charSelectPlayerAnimSeq[SLS_playerNumberSaved] : rem Walking animation
          let SLWS_animationAction = 3 : rem Use sequence counter as frame (0-3 for 4-frame walk)
          let SLWS_playerNumberForArt = SLS_playerNumberSaved : rem ActionWalking = 3
          let temp1 = SLS_characterIndex
          let temp2 = SLWS_animationFrame
          let temp3 = SLWS_animationAction
          let temp4 = SLWS_playerNumberForArt
          gosub LocateCharacterArt bank14
          
SelectLoadSpriteColor
          dim SLSC_playerNumberSaved = temp6
          dim SLSC_characterIndex = temp1
          dim SLSC_isHurt = temp2
          dim SLSC_playerNumber = temp3
          dim SLSC_isFlashing = temp4
          let SLSC_characterIndex = playerChar[SLSC_playerNumberSaved] : rem Now set player color
          let SLSC_isHurt = 0
          let SLSC_playerNumber = SLSC_playerNumberSaved : rem not hurt
          let SLSC_isFlashing = 0 : rem player number
          let temp2 = SLSC_isHurt : rem not flashing
          let temp3 = SLSC_playerNumber
          let temp4 = SLSC_isFlashing
          gosub LoadCharacterColors
          
          rem temp3 restored via LoadCharacterColors
          
SelectDrawSpriteDone
          return
          
SelectDrawNumber
          dim SDN_playerIndex = temp1
          rem Draw player number indicator below character
          rem Determine which player based on position (same as
          rem   SelectDrawSprite logic)
          if player0x = 56 then goto SelectNumberPlayerP0 : rem Check if we have valid player position
          if player1x = 104 then goto SelectNumberPlayerP1
          goto SelectDrawNumberDone : rem No valid position, skip number
          
SelectNumberPlayerP0
          dim SNP0_playerIndex = temp1
          if player0y = 40 then let SNP0_playerIndex = 0 : let temp1 = SNP0_playerIndex : goto NumberPositionCalculate
          if player0y = 80 then let SNP0_playerIndex = 2 : let temp1 = SNP0_playerIndex : goto NumberPositionCalculate
          goto SelectDrawNumberDone
          
SelectNumberPlayerP1
          dim SNP1_playerIndex = temp1
          if player1y = 40 then let SNP1_playerIndex = 1 : let temp1 = SNP1_playerIndex : goto NumberPositionCalculate
          if player1y = 80 then let SNP1_playerIndex = 3 : let temp1 = SNP1_playerIndex : goto NumberPositionCalculate
          goto SelectDrawNumberDone
          
NumberPositionCalculate
          dim NPC_playerIndex = temp1
          dim NPC_xPos = temp2
          dim NPC_yPos = temp3
          dim NPC_color = temp4
          dim NPC_spriteSelect = temp5
          dim NPC_digit = temp1
          rem playerIndex now has player index (0-3)
          rem Determine X and Y positions and which sprite to use
          rem P1 (index 0): x=56, y=48, sprite=player0, shows P1
          rem P2 (index 1): x=104, y=48, sprite=player1, shows P1 (virtual sprite)
          rem P3 (index 2): x=56, y=88, sprite=player0, shows P2 (virtual sprite)
          rem P4 (index 3): x=104, y=88, sprite=player1, shows P3 (virtual sprite)
          
          if !NPC_playerIndex then goto SelectNumberP1
          if NPC_playerIndex = 1 then goto SelectNumberP2 : rem P1 (0)
          if NPC_playerIndex = 2 then goto SelectNumberP3 : rem P2 (1)
          goto SelectNumberP4 : rem P3 (2)
          rem P4 (3)
          
SelectNumberP1
          dim SNP1_xPos = temp2
          dim SNP1_yPos = temp3
          dim SNP1_spriteSelect = temp5
          dim SNP1_color = temp4
          dim SNP1_digit = temp1
          let SNP1_xPos = 56
          let SNP1_yPos = 48
          let SNP1_spriteSelect = 0
          let SNP1_color = ColIndigo(14)
          let SNP1_digit = 1
          let temp1 = SNP1_digit : rem P1: left, top row, player0, indigo
          let temp2 = SNP1_xPos
          let temp3 = SNP1_yPos
          let temp4 = SNP1_color
          let temp5 = SNP1_spriteSelect
          goto DrawNumberDigit
          
SelectNumberP2
          dim SNP2_xPos = temp2
          dim SNP2_yPos = temp3
          dim SNP2_spriteSelect = temp5
          dim SNP2_color = temp4
          dim SNP2_digit = temp1
          let SNP2_xPos = 104
          let SNP2_yPos = 48
          let SNP2_spriteSelect = 1
          let SNP2_color = ColRed(14)
          let SNP2_digit = 1
          let temp1 = SNP2_digit : rem P2 (virtual sprite): right, top row, player1, red, shows P1
          let temp2 = SNP2_xPos
          let temp3 = SNP2_yPos
          let temp4 = SNP2_color
          let temp5 = SNP2_spriteSelect
          goto DrawNumberDigit
          
SelectNumberP3
          dim SNP3_xPos = temp2
          dim SNP3_yPos = temp3
          dim SNP3_spriteSelect = temp5
          dim SNP3_color = temp4
          dim SNP3_digit = temp1
          let SNP3_xPos = 56
          let SNP3_yPos = 88
          let SNP3_spriteSelect = 0
          let SNP3_color = ColYellow(14)
          let SNP3_digit = 2
          let temp1 = SNP3_digit : rem P3 (virtual sprite): left, bottom row, player0, yellow, shows P2
          let temp2 = SNP3_xPos
          let temp3 = SNP3_yPos
          let temp4 = SNP3_color
          let temp5 = SNP3_spriteSelect
          goto DrawNumberDigit
          
SelectNumberP4
          dim SNP4_xPos = temp2
          dim SNP4_yPos = temp3
          dim SNP4_spriteSelect = temp5
          dim SNP4_color = temp4
          dim SNP4_digit = temp1
          let SNP4_xPos = 104
          let SNP4_yPos = 88
          let SNP4_spriteSelect = 1
          let SNP4_color = ColGreen(14)
          let SNP4_digit = 3
          let temp1 = SNP4_digit : rem P4 (virtual sprite): right, bottom row, player1, green, shows P3
          let temp2 = SNP4_xPos
          let temp3 = SNP4_yPos
          let temp4 = SNP4_color
          let temp5 = SNP4_spriteSelect
          
DrawNumberDigit
          dim DND_digit = temp1
          dim DND_xPos = temp2
          dim DND_yPos = temp3
          dim DND_color = temp4
          dim DND_spriteSelect = temp5
          rem digit already has player digit (1-4)
          rem xPos=X, yPos=Y, color=color, spriteSelect=sprite already
          rem   set
          rem Call DrawDigit with these parameters (DrawPlayerNumber
          rem   expects temp1=digit, temp2=X, temp3=Y, temp4=color,
          rem   temp5=sprite)
          gosub DrawDigit bank1 : rem DrawDigit is in Bank 1 (FontRendering.bas) with MainLoop and drawscreen
          
SelectDrawNumberDone
          return
          
SelectDrawLocks
          let temp1 = 0 : gosub GetPlayerLocked bank1 : if temp2 then goto SelectDrawP0Border : rem Draw locked status borders using playfield
          goto SelectSkipP0Border
SelectDrawP0Border
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
SelectSkipP0Border
          
          let temp1 = 1 : gosub GetPlayerLocked bank1 : if temp2 then goto SelectDrawP1Border
          goto SelectSkipP1Border
SelectDrawP1Border
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
SelectSkipP1Border
          
          if controllerStatus & SetQuadtariDetected then goto SelectCheckP2Lock
          goto SelectSkipCheckP2Lock
SelectCheckP2Lock
          let temp1 = 2 : gosub GetPlayerLocked bank1 : if temp2 then SelectDrawP2Border
          let temp1 = 3 : gosub GetPlayerLocked bank1 : if temp2 then SelectDrawP3Border
SelectSkipCheckP2Lock
          return
          
SelectDrawP2Border
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
          return
          
SelectDrawP3Border
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
          return
          
          rem
          rem Animation Updates

SelectUpdateAnimations
          rem Update character select animations for all players
          rem Players cycle through idle/walk animations to show
          rem   selected characters
          rem Each player updates independently with staggered timing
          
          rem Update Player 1 animations (characters)
          let temp1 = 0 : gosub GetPlayerLocked bank1 : if temp2 then goto SelectSkipPlayer0Anim  : rem Locked players don’t animate
          if playerChar[0] = CPUCharacter then goto SelectSkipPlayer0Anim  : rem CPU doesn’t animate
          if playerChar[0] = NoCharacter then goto SelectSkipPlayer0Anim  : rem NO doesn’t animate
          if playerChar[0] = RandomCharacter then goto SelectSkipPlayer0Anim  : rem Random doesn’t animate
          let temp1 = 0
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer0Anim
          let temp1 = 1 : gosub GetPlayerLocked bank1 : if temp2 then goto SelectSkipPlayer1Anim : rem Update Player 2 animations
          if playerChar[1] = CPUCharacter then goto SelectSkipPlayer1Anim
          if playerChar[1] = NoCharacter then goto SelectSkipPlayer1Anim
          if playerChar[1] = RandomCharacter then goto SelectSkipPlayer1Anim
          let temp1 = 1
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer1Anim
          if !(controllerStatus & SetQuadtariDetected) then goto SelectSkipPlayer23Anim : rem Update Player 3 animations (if Quadtari)
          let temp1 = 2 : gosub GetPlayerLocked bank1 : if temp2 then goto SelectSkipPlayer2Anim
          if playerChar[2] = NoCharacter then goto SelectSkipPlayer2Anim
          if playerChar[2] = RandomCharacter then goto SelectSkipPlayer2Anim
          let temp1 = 2
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer2Anim
          if !(controllerStatus & SetQuadtariDetected) then goto SelectSkipPlayer23Anim : rem Update Player 4 animations (if Quadtari)
          let temp1 = 3 : gosub GetPlayerLocked bank1 : if temp2 then goto SelectSkipPlayer23Anim
          if playerChar[3] = NoCharacter then goto SelectSkipPlayer23Anim
          if playerChar[3] = RandomCharacter then goto SelectSkipPlayer23Anim
          let temp1 = 3
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer23Anim
          return
          
          rem
          rem Update Individual Player Animation
          
SelectUpdatePlayerAnim
          dim SUPA_playerIndex = temp1
          rem Update animation for a single player
          rem Input: playerIndex = player index (0-3)
          let charSelectPlayerAnimFrame[SUPA_playerIndex] = charSelectPlayerAnimFrame[SUPA_playerIndex] + 1 : rem Increment frame counter
          
          rem Check if it’s time to advance frame (every 6 frames for
          if charSelectPlayerAnimFrame[SUPA_playerIndex] >= AnimationFrameDelay then goto SelectAdvanceAnimFrame : rem   10fps at 60fps)
          return
          
SelectAdvanceAnimFrame
          dim SAAF_playerIndex = temp1
          dim SAAF_sequenceValue = temp2
          let charSelectPlayerAnimFrame[SAAF_playerIndex] = 0 : rem Reset frame counter
          
          if !charSelectPlayerAnimSeq[SAAF_playerIndex] then goto SelectAdvanceIdleAnim : rem Check current animation sequence
          rem Walking animation: cycle through 4 frames (0-3)
          let SAAF_sequenceValue = (charSelectPlayerAnimSeq[SAAF_playerIndex] + 1) & 3 : rem Use bit 0-1 of sequence counter
          let charSelectPlayerAnimSeq[SAAF_playerIndex] = SAAF_sequenceValue
          
          if charSelectPlayerAnimSeq[SAAF_playerIndex] then return : rem After 4 walk frames (frame 3→0), switch to idle
          let charSelectPlayerAnimSeq[SAAF_playerIndex] = 0 : rem Switch back to idle after walk cycle
          
          rem Toggle to walk sequence after idle
          goto SelectAnimWaitForToggle : rem Just set sequence flag to 1 (walk) for next cycle
          
SelectAdvanceIdleAnim
          dim SAAI_playerIndex = temp1
          rem Idle animation cycles every 60 frames, then toggles to
          rem   walk
          rem Use higher bit in sequence to count idle cycles
          if frame & 63 then return : rem Every 60 frames (10 idle animations), toggle to walk
          rem Check every 64 frames roughly
          
          let charSelectPlayerAnimSeq[SAAI_playerIndex] = 1 : rem Toggle to walk
          rem Start walking
          return
          
SelectAnimWaitForToggle
          return
          rem Just return, toggling handled above

          rem
          rem Controller Rescan Detection
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          rem to handle Quadtari being connected/disconnected
          
CharacterSelectCheckControllerRescan
          dim CSCR_switchBW = temp6
          if switchselect then goto CharacterSelectDoRescan : rem Check for Game Select or Pause button press
          let CSCR_switchBW = switchbw : rem Check for Color/B&W switch toggle
          if CSCR_switchBW = colorBWPrevious_R then goto CharacterSelectRescanDone
          gosub SelDetectQuad bank6 : rem Switch toggled, do rescan
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
          
CharacterSelectDoRescan
          gosub SelDetectQuad bank6 : rem Re-detect Quadtari via bank6
          rem Debounce - wait for switch release (drawscreen called by MainLoop)
          
CharacterSelectRescanDone
          return

