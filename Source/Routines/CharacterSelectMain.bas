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
          rem   SetPlayerLocked (bank6) - accesses playerLocked state,
          rem   PlaySoundEffect (bank15) - plays navigation sound
          rem
          rem Constraints: Must be colocated with HCSC_CheckJoy0,
          rem HCSC_CheckJoy0Left,
          rem              HCSC_CheckJoy1Left, HandleCharacterSelectCycle
HCSC_CheckJoy0
          rem Check joy0 for players 0,2
          rem
          rem Input: temp1, temp2 (from
          rem HandleCharacterSelectCycle)
          rem        joy0left, joy0right (hardware) = joystick states
          rem
          rem Output: Dispatches to HCSC_CheckJoy0Left or HandleCharacterSelectCycle
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
          goto HandleCharacterSelectCycle
HCSC_CheckJoy0Left
          rem Check joy0 left button
          rem
          rem Input: joy0left (hardware) = joystick state
          rem
          rem Output: Returns if not pressed, continues to HandleCharacterSelectCycle
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
          rem Output: Returns if not pressed, continues to HandleCharacterSelectCycle
          rem if pressed
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with HandleCharacterSelectCycle
          if !joy1left then return
HandleCharacterSelectCycle
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
          rem SetPlayerLocked (bank6),
          rem   PlaySoundEffect (bank15)
          rem
          rem Constraints: Must be colocated with
          let temp4 = temp1
          rem Preserve player index for updates and lock handling
          let temp1 = playerCharacter[temp4]
          rem Load current character selection
          let temp3 = temp4
          rem temp3 stores the player index for inline cycling logic
          if temp2 = 0 then goto HCSC_CycleLeft
          goto HCSC_CycleRight
HCSC_CycleLeft
          rem Handle stick-left navigation with ordered wrap logic
          if temp1 = RandomCharacter then goto HCSC_LeftFromRandom
          if temp1 = NoCharacter then goto HCSC_LeftFromNo
          if temp1 = CPUCharacter then goto HCSC_LeftFromCPU
          if temp1 = 0 then goto HCSC_LeftFromZero
          let temp1 = temp1 - 1
          goto HCSC_CycleDone
HCSC_LeftFromRandom
          if temp3 = 0 then temp1 = MaxCharacter : goto HCSC_CycleDone
          if temp3 = 1 then gosub HCSC_GetPlayer2Tail : temp1 = temp6 : goto HCSC_CycleDone
          let temp1 = NoCharacter
          goto HCSC_CycleDone
HCSC_LeftFromNo
          let temp1 = MaxCharacter
          goto HCSC_CycleDone
HCSC_LeftFromCPU
          let temp1 = MaxCharacter
          goto HCSC_CycleDone
HCSC_LeftFromZero
          let temp1 = RandomCharacter
          goto HCSC_CycleDone
HCSC_CycleRight
          rem Handle stick-right navigation with ordered wrap logic
          if temp1 = RandomCharacter then goto HCSC_RightFromRandom
          if temp1 = NoCharacter then goto HCSC_RightFromNo
          if temp1 = CPUCharacter then goto HCSC_RightFromCPU
          if temp1 = MaxCharacter then goto HCSC_RightFromMax
          let temp1 = temp1 + 1
          goto HCSC_CycleDone
HCSC_RightFromRandom
          let temp1 = 0
          goto HCSC_CycleDone
HCSC_RightFromNo
          let temp1 = RandomCharacter
          goto HCSC_CycleDone
HCSC_RightFromCPU
          let temp1 = RandomCharacter
          goto HCSC_CycleDone
HCSC_RightFromMax
          if temp3 = 0 then temp1 = RandomCharacter : goto HCSC_CycleDone
          if temp3 = 1 then gosub HCSC_GetPlayer2Tail : temp1 = temp6 : goto HCSC_CycleDone
          let temp1 = NoCharacter
          goto HCSC_CycleDone
HCSC_GetPlayer2Tail
          rem Determine whether Player 2 wraps to CPU or NO
          let temp6 = CPUCharacter
          if playerCharacter[2] = NoCharacter then goto HCSC_P2TailCheckP4
          let temp6 = NoCharacter
          goto HCSC_P2TailDone
HCSC_P2TailCheckP4
          if playerCharacter[3] = NoCharacter then goto HCSC_P2TailDone
          let temp6 = NoCharacter
HCSC_P2TailDone
          return
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
          rem Called Routines: SetPlayerLocked (bank6),
          rem PlaySoundEffect (bank15)
          let playerCharacter[temp3] = temp1
          let temp2 = PlayerLockedUnlocked
          let temp1 = temp3
          gosub SetPlayerLocked bank6
          let temp1 = SoundMenuNavigate
          rem Play navigation sound
          gosub PlaySoundEffect bank15
          return

CharacterSelectInputEntry
          gosub CharacterSelectCheckControllerRescan bank6

          rem Consolidated input handling with Quadtari multiplexing
          let temp3 = 0
          if controllerStatus & SetQuadtariDetected then temp3 = qtcontroller * 2
          rem Player offset: 0=P1/P2, 2=P3/P4
          gosub CharacterSelectHandleTwoPlayers

          if controllerStatus & SetQuadtariDetected then qtcontroller = qtcontroller ^ 1 else qtcontroller = 0
          goto CharacterSelectInputComplete

CharacterSelectHandleTwoPlayers
          rem Handle input for two players (P1/P2 or P3/P4 based on temp3)
          rem temp3 = player offset (0 or 2)

          rem Check if second player should be active (Quadtari)
          let temp4 = 0
          if temp3 = 0 then temp4 = 255
          if controllerStatus & SetQuadtariDetected then temp4 = 255

          if temp3 < 2 then goto ProcessPlayerInput
          if controllerStatus & SetQuadtariDetected then goto ProcessPlayerInput
          return
ProcessPlayerInput

          rem Handle Player 1/3 input (joy0)
          if joy0left then temp1 = temp3 : temp2 = 0 : gosub HandleCharacterSelectCycle
          if joy0right then temp1 = temp3 : temp2 = 1 : gosub HandleCharacterSelectCycle
          if joy0up then temp1 = temp3 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank6
          rem NOTE: DASM raises "Label mismatch" if multiple banks re-include HandleCharacterSelectFire
          if joy0fire then temp1 = temp3 : gosub HandleCharacterSelectFire bank7

          rem Handle Player 2/4 input (joy1) - only if active
          if !temp4 then return
          if joy1left then temp1 = temp3 + 1 : temp2 = 0 : gosub HandleCharacterSelectCycle
          if joy1right then temp1 = temp3 + 1 : temp2 = 1 : gosub HandleCharacterSelectCycle
          if joy1up then temp1 = temp3 + 1 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank6
          if joy1fire then temp1 = temp3 + 1 : gosub HandleCharacterSelectFire bank7
          return



CharacterSelectInputComplete
          gosub CharacterSelectHandleRandomRolls
          rem Handle random character re-rolls if any players need it

          gosub SelectUpdateAnimations bank6
          rem Update character select animations
          rem Draw selection screen
          gosub SelectDrawScreen bank6
          rem Draw character selection screen
          return

          rem
          rem Random Character Roll Handler
          rem Re-roll random selections until valid (0-15), then lock

CharacterSelectHandleRandomRolls
          rem Check each player for pending random roll
          let temp1 = 1
          if controllerStatus & SetQuadtariDetected then temp1 = 3
          for currentPlayer = 0 to temp1
          if playerCharacter[currentPlayer] = RandomCharacter then gosub CharacterSelectRollRandomPlayer
          next
          goto CharacterSelectRollsDone

CharacterSelectRollRandomPlayer
          rem Handle random character roll for the current player’s slot.
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        randomSelectFlags_R[] (SCRAM, read port) = handicap flags
          rem Output: playerCharacter[currentPlayer] updated when roll succeeds
          rem
          rem Mutates: temp1-temp2, playerCharacter[], randomSelectFlags_W[],
          rem           playerLocked[] via SetPlayerLocked
          rem
          rem Called Routines: SetPlayerLocked
          let temp2 = rand & 31
          rem Roll 5-bit random: rand & 31 (0-31)
          rem If > MaxCharacter, stay as RandomCharacter and retry next frame
          if temp2 > MaxCharacter then return
          let playerCharacter[currentPlayer] = temp2
          rem Valid! Set character and lock with normal or handicap
          if randomSelectFlags_R[currentPlayer] then goto CharacterSelectRollRandomPlayerHandicap
          let temp1 = currentPlayer : temp2 = PlayerLockedNormal : gosub SetPlayerLocked bank6
          goto CharacterSelectRollRandomPlayerLockDone
CharacterSelectRollRandomPlayerHandicap
          let temp1 = currentPlayer : temp2 = PlayerHandicapped : gosub SetPlayerLocked bank6
CharacterSelectRollRandomPlayerLockDone
          let randomSelectFlags_W[currentPlayer] = 0
          return

CharacterSelectRollsDone
          return

CharacterSelectCheckReady
          rem
          rem Check If Ready To Proceed
          rem 2-player mode: P1 must be locked AND (P2 locked OR P2 on
          rem CPU)
          if controllerStatus & SetQuadtariDetected then goto CharacterSelectQuadtariReady
          let temp1 = 0 : gosub GetPlayerLocked bank6 : if !temp2 then goto CharacterSelectReadyDone
          rem P1 is locked, check P2
          let temp1 = 1 : gosub GetPlayerLocked bank6 : if temp2 then goto CharacterSelectFinish
          rem P2 not locked, check if on CPU
          if playerCharacter[1] = CPUCharacter then goto CharacterSelectFinish
          goto CharacterSelectReadyDone

CharacterSelectQuadtariReady
          rem 4-player mode: Count players who are ready (locked OR on
          let readyCount = 0
          rem   CPU/NO)
          rem Count P1 ready
          let temp1 = 0 : gosub GetPlayerLocked bank6 : if temp2 then readyCount = readyCount + 1
          let temp1 = 0 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[0] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 0 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[0] = NoCharacter then readyCount = readyCount + 1
          rem Count P2 ready
          let temp1 = 1 : gosub GetPlayerLocked bank6 : if temp2 then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[1] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 1 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[1] = NoCharacter then readyCount = readyCount + 1
          rem Count P3 ready
          let temp1 = 2 : gosub GetPlayerLocked bank6 : if temp2 then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[2] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 2 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[2] = NoCharacter then readyCount = readyCount + 1
          rem Count P4 ready
          let temp1 = 3 : gosub GetPlayerLocked bank6 : if temp2 then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[3] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 3 : gosub GetPlayerLocked bank6 : if !temp2 && playerCharacter[3] = NoCharacter then readyCount = readyCount + 1
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

