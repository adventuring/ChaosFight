HandleCharacterSelectCycle
          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
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
          rem   SetPlayerLocked (bank10) - accesses playerLocked state,
          rem   PlaySoundEffect (bank15) - plays navigation sound
          rem
          rem Constraints: Must be colocated with HCSC_CheckJoy0,
          rem HCSC_CheckJoy0Left,
          rem              HCSC_CheckJoy1Left, HCSC_DoCycle,
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
          rem SetPlayerLocked (bank10),
          rem   PlaySoundEffect (bank15)
          rem
          rem Constraints: Must be colocated with
          let temp1 = playerCharacter[temp1]
          rem Get current character index
          let temp3 = temp1
          rem Cycle based on direction
          gosub CycleCharacterLeft bank12
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
          rem Called Routines: SetPlayerLocked (bank10),
          rem PlaySoundEffect (bank15)
          let playerCharacter[temp1] = temp1
          let temp2 = PlayerLockedUnlocked
          gosub SetPlayerLocked
          let temp1 = SoundMenuNavigate
          rem Play navigation sound
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
          rem Called Routines: SetPlayerLocked (bank10) - accesses
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
          if joy1down then temp4 = 1 else temp4 = 0
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
          if joy0down then temp4 = 1 else temp4 = 0
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
          rem Called Routines: SetPlayerLocked (bank10),
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
          gosub SetPlayerLocked
          let temp1 = SoundMenuSelect
          rem Play selection sound
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
          rem Called Routines: SetPlayerLocked (bank10),
          rem PlaySoundEffect (bank15)
          rem Constraints: Must be colocated with HandleCharacterSelectFire
          let temp3 = temp1
          let temp1 = temp3
          let temp2 = PlayerHandicapped
          gosub SetPlayerLocked
          let temp1 = SoundMenuSelect
          rem Play selection sound
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
          let temp1 = SoundMenuSelect
          rem Play selection sound
          gosub PlaySoundEffect bank15
          rem Fall through - character will stay as RandomCharacter
          rem until roll succeeds
          return

CharacterSelectInputEntry
          gosub CharacterSelectCheckControllerRescan bank10

          rem Consolidated input handling with Quadtari multiplexing
          let temp3 = qtcontroller * 2
          rem Player offset: 0=P1/P2, 2=P3/P4
          gosub CharacterSelectHandleTwoPlayers

          qtcontroller = qtcontroller ^ 1
          goto CharacterSelectInputComplete

CharacterSelectHandleTwoPlayers
          rem Handle input for two players (P1/P2 or P3/P4 based on temp3)
          rem temp3 = player offset (0 or 2)

          rem Check if second player should be active (Quadtari)
          let temp4 = 0
          if temp3 = 0 then temp4 = 255
          if controllerStatus & SetQuadtariDetected then temp4 = 255

          rem Handle Player 1/3 input (joy0)
          if joy0left then temp1 = temp3 : temp2 = 0 : gosub HandleCharacterSelectCycle
          if joy0right then temp1 = temp3 : temp2 = 1 : gosub HandleCharacterSelectCycle
          if joy0up then temp1 = temp3 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          if joy0down then temp1 = temp3 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          if joy0fire then temp1 = temp3 : gosub HandleCharacterSelectFire

          rem Handle Player 2/4 input (joy1) - only if active
          if !temp4 then return
          if joy1left then temp1 = temp3 + 1 : temp2 = 0 : gosub HandleCharacterSelectCycle
          if joy1right then temp1 = temp3 + 1 : temp2 = 1 : gosub HandleCharacterSelectCycle
          if joy1up then temp1 = temp3 + 1 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          if joy1down then temp1 = temp3 + 1 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked
          if joy1fire then temp1 = temp3 + 1 : gosub HandleCharacterSelectFire
          return
          


CharacterSelectInputComplete
          gosub CharacterSelectHandleRandomRolls
          rem Handle random character re-rolls if any players need it
          
          gosub SelectUpdateAnimations bank6
          rem Update character select animations
          rem Draw selection screen
          gosub SelectDrawScreen bank6
          rem Draw character selection screen
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariPlayersInline
          goto CharacterSelectSkipQuadtariPlayersInline

CharacterSelectQuadtariPlayersInline
          rem Draw Player 3 selection (bottom left)
          player0x = 56 : player0y = 80
          gosub SelectDrawSprite bank6
          
          rem Draw Player 4 selection (bottom right)
          player1x = 104 : player1y = 80
          gosub SelectDrawSprite bank6
          goto CharacterSelectInputComplete

CharacterSelectSkipQuadtariPlayersInline
          rem Draw Player 1 selection (top left)
          player0x = 56 : player0y = 40
          gosub SelectDrawSprite bank6
          
          rem Draw Player 2 selection (top right)
          player1x = 104 : player1y = 40
          gosub SelectDrawSprite bank6
          
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
          let temp2 = rand & 31
          rem Roll 5-bit random: rand & 31 (0-31)
          rem If > 15, stay as RandomCharacter and retry next frame
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[0] = temp2
          rem Valid! Set character and lock with normal or handicap
          if randomSelectFlags_R[0] then goto CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked
          goto CharacterSelectLockPlayer0Done
CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked
CharacterSelectLockPlayer0Done
          let randomSelectFlags_W[0] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer1
          let temp2 = rand & 31
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[1] = temp2
          if randomSelectFlags_R[1] then goto CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked
          goto CharacterSelectLockPlayer1Done
CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked
CharacterSelectLockPlayer1Done
          let randomSelectFlags_W[1] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer2
          let temp2 = rand & 31
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[2] = temp2
          if randomSelectFlags_R[2] then goto CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked
          goto CharacterSelectLockPlayer2Done
CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked
CharacterSelectLockPlayer2Done
          let randomSelectFlags_W[2] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer3
          let temp2 = rand & 31
          if temp2 > MaxCharacter then goto CharacterSelectRollsDone
          let playerCharacter[3] = temp2
          if randomSelectFlags_R[3] then goto CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub SetPlayerLocked
          goto CharacterSelectLockPlayer3Done
CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerHandicapped : gosub SetPlayerLocked
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
          let temp1 = 0 : gosub GetPlayerLocked : if !temp2 then goto CharacterSelectReadyDone
          rem P1 is locked, check P2
          let temp1 = 1 : gosub GetPlayerLocked : if temp2 then goto CharacterSelectFinish
          rem P2 not locked, check if on CPU
          if playerCharacter[1] = CPUCharacter then goto CharacterSelectFinish
          goto CharacterSelectReadyDone
          
CharacterSelectQuadtariReady
          rem 4-player mode: Count players who are ready (locked OR on
          let readyCount = 0
          rem   CPU/NO)
          rem Count P1 ready
          let temp1 = 0 : gosub GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 0 : gosub GetPlayerLocked : if !temp2 && playerCharacter[0] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 0 : gosub GetPlayerLocked : if !temp2 && playerCharacter[0] = NoCharacter then readyCount = readyCount + 1
          rem Count P2 ready
          let temp1 = 1 : gosub GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked : if !temp2 && playerCharacter[1] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked : if !temp2 && playerCharacter[1] = NoCharacter then readyCount = readyCount + 1
          rem Count P3 ready
          let temp1 = 2 : gosub GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked : if !temp2 && playerCharacter[2] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked : if !temp2 && playerCharacter[2] = NoCharacter then readyCount = readyCount + 1
          rem Count P4 ready
          let temp1 = 3 : gosub GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked : if !temp2 && playerCharacter[3] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked : if !temp2 && playerCharacter[3] = NoCharacter then readyCount = readyCount + 1
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
          if playerCharacter[0] = NoCharacter then DoneCharacter1Facing
          let playerState[0] = playerState[0] | 1
DoneCharacter1Facing
          if playerCharacter[1] = NoCharacter then DoneCharacter2Facing
          let playerState[1] = playerState[1] | 1
DoneCharacter2Facing
          if playerCharacter[2] = NoCharacter then DoneCharacter3Facing
          let playerState[2] = playerState[2] | 1
DoneCharacter3Facing
          if playerCharacter[3] = NoCharacter then DoneCharacter4Facing
          let playerState[3] = playerState[3] | 1
DoneCharacter4Facing
          
          let gameMode = ModeFallingAnimation
          rem Transition to falling animation
          gosub ChangeGameMode bank14
          return

CycleRightFromNO
          let temp1 = 0
          rem NoCharacter(255) goes to 0
          return
          
          rem Animation helpers moved to CharacterSelectRender.bas (bank 10)

