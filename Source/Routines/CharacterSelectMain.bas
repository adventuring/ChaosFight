          rem ChaosFight - Source/Routines/CharacterSelectMain.bas

          rem

          rem Copyright © 2025 Bruce-Robert Pocock.

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
          rem Returns: Far (return otherbank)

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

          if !joy0right then return otherbank

          goto HandleCharacterSelectCycle

HCSC_CheckJoy0Left

          rem Check joy0 left button
          rem Returns: Far (return otherbank)

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

          if !joy0left then return otherbank

HCSC_CheckJoy1Left

          rem Check joy1 left button
          rem Returns: Far (return otherbank)

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

          if !joy1left then return otherbank

HandleCharacterSelectCycle
          rem Returns: Far (return thisbank)

          asm

HandleCharacterSelectCycle

end

          rem Perform character cycling
          rem Returns: Far (return otherbank)

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

          rem Preserve player index for updates and lock handling

          let temp4 = temp1

          rem Load current character selection

          let temp1 = playerCharacter[temp4]

          rem temp3 stores the player index for inline cycling logic

          let temp3 = temp4

          if temp2 = 0 then goto HCSC_CycleLeft

          goto HCSC_CycleRight

HCSC_CycleLeft

          rem Handle stick-left navigation with ordered wrap logic
          rem Returns: Far (return otherbank)

          if temp1 = RandomCharacter then goto HCSC_LeftFromRandom

          if temp1 = NoCharacter then goto HCSC_LeftFromNoOrCPU

          if temp1 = CPUCharacter then goto HCSC_LeftFromNoOrCPU

          if temp1 = 0 then goto HCSC_LeftFromZero

          let temp1 = temp1 - 1

          goto HCSC_CycleDone

HCSC_LeftFromRandom

          if temp3 = 0 then temp1 = MaxCharacter : goto HCSC_CycleDone

          if temp3 = 1 then gosub HCSC_GetPlayer2Tail : temp1 = temp6 : goto HCSC_CycleDone

          let temp1 = NoCharacter

          goto HCSC_CycleDone

HCSC_LeftFromNoOrCPU

          let temp1 = MaxCharacter

          goto HCSC_CycleDone

HCSC_LeftFromZero

          let temp1 = RandomCharacter

          goto HCSC_CycleDone

HCSC_CycleRight

          rem Handle stick-right navigation with ordered wrap logic
          rem Returns: Far (return otherbank)

          if temp1 = RandomCharacter then goto HCSC_RightFromRandom

          if temp1 = NoCharacter then goto HCSC_RightFromNoOrCPU

          if temp1 = CPUCharacter then goto HCSC_RightFromNoOrCPU

          if temp1 = MaxCharacter then goto HCSC_RightFromMax

          let temp1 = temp1 + 1

          goto HCSC_CycleDone

HCSC_RightFromRandom

          let temp1 = 0

          goto HCSC_CycleDone

HCSC_RightFromNoOrCPU

          let temp1 = RandomCharacter

          goto HCSC_CycleDone

HCSC_RightFromMax

          if temp3 = 0 then temp1 = RandomCharacter : goto HCSC_CycleDone

          if temp3 = 1 then gosub HCSC_GetPlayer2Tail : temp1 = temp6 : goto HCSC_CycleDone

          let temp1 = NoCharacter

          goto HCSC_CycleDone

HCSC_GetPlayer2Tail
          rem Returns: Far (return thisbank)

          asm

HCSC_GetPlayer2Tail

end

          rem Determine whether Player 2 wraps to CPU or NO
          rem Returns: Far (return otherbank)

          let temp6 = CPUCharacter

          if playerCharacter[2] = NoCharacter then goto HCSC_P2TailCheckP4

          let temp6 = NoCharacter

          goto HCSC_P2TailDone

HCSC_P2TailCheckP4

          if playerCharacter[3] = NoCharacter then goto HCSC_P2TailDone

          let temp6 = NoCharacter

HCSC_P2TailDone

          return thisbank

HCSC_CycleDone

          rem Character cycling complete
          rem Returns: Far (return otherbank)

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

          rem Play navigation sound

          let temp1 = SoundMenuNavigate

          gosub PlaySoundEffect bank15

          return otherbank

CharacterSelectInputEntry
          rem Returns: Far (return otherbank)

          asm

CharacterSelectInputEntry



end

          gosub CharacterSelectCheckControllerRescan bank6



          rem Consolidated input handling with Quadtari multiplexing
          rem Returns: Far (return otherbank)

          let temp3 = 0

          rem Player offset: 0=P1/P2, 2=P3/P4

          if controllerStatus & SetQuadtariDetected then temp3 = qtcontroller * 2

          gosub CharacterSelectHandleTwoPlayers



          if controllerStatus & SetQuadtariDetected then qtcontroller = qtcontroller ^ 1 else qtcontroller = 0

          goto CharacterSelectInputComplete



CharacterSelectHandleTwoPlayers
          rem Returns: Far (return thisbank)

          asm

CharacterSelectHandleTwoPlayers



end

          rem Handle input for two players (P1/P2 or P3/P4 based on temp3)
          rem Returns: Far (return otherbank)

          rem temp3 = player offset (0 or 2)



          rem Check if second player should be active (Quadtari)

          let temp4 = 0

          if temp3 = 0 then temp4 = 255

          if controllerStatus & SetQuadtariDetected then temp4 = 255



          if temp3 < 2 then goto ProcessPlayerInput

          if controllerStatus & SetQuadtariDetected then goto ProcessPlayerInput

          return thisbank

ProcessPlayerInput



          rem Handle Player 1/3 input (joy0)

          if joy0left then temp1 = temp3 : temp2 = 0 : gosub HandleCharacterSelectCycle

          if joy0right then temp1 = temp3 : temp2 = 1 : gosub HandleCharacterSelectCycle

          rem NOTE: DASM raises ’Label mismatch’ if multiple banks re-include HandleCharacterSelectFire

          if joy0up then temp1 = temp3 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank6

          if joy0fire then temp1 = temp3 : gosub HandleCharacterSelectFire bank7



          rem Handle Player 2/4 input (joy1) - only if active

          if !temp4 then return thisbank

          if joy1left then temp1 = temp3 + 1 : temp2 = 0 : gosub HandleCharacterSelectCycle

          if joy1right then temp1 = temp3 + 1 : temp2 = 1 : gosub HandleCharacterSelectCycle

          if joy1up then temp1 = temp3 + 1 : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank6

          if joy1fire then temp1 = temp3 + 1 : gosub HandleCharacterSelectFire bank7

          return thisbank





CharacterSelectInputComplete

          rem Handle random character re-rolls if any players need it
          rem Returns: Far (return otherbank)

          gosub CharacterSelectHandleRandomRolls



          rem Update character select animations

          gosub SelectUpdateAnimations bank6

          rem Draw selection screen

          rem Draw character selection screen

          gosub SelectDrawScreen bank6

          return otherbank

          rem

          rem Random Character Roll Handler

          rem Re-roll random selections until valid (0-15), then lock



CharacterSelectHandleRandomRolls
          rem Returns: Far (return thisbank)

          asm

CharacterSelectHandleRandomRolls

end

          rem Check each player for pending random roll
          rem Returns: Far (return otherbank)

          let temp1 = 1

          if controllerStatus & SetQuadtariDetected then temp1 = 3

          for currentPlayer = 0 to temp1

          if playerCharacter[currentPlayer] = RandomCharacter then gosub CharacterSelectRollRandomPlayer

          next

          goto CharacterSelectRollsDone



CharacterSelectRollRandomPlayer
          rem Returns: Far (return thisbank)

          asm

CharacterSelectRollRandomPlayer



end

          rem Handle random character roll for the current player’s slot.
          rem Returns: Far (return otherbank)

          rem Requirements: Each frame, if selection is RandomCharacter,

          rem sample rand & $1f and accept the result when it is < NumCharacters.

          rem Does NOT lock the character - player must press fire to lock.

          rem

          rem Input: currentPlayer (global) = player index (0-3)

          rem Output: playerCharacter[currentPlayer] updated when roll succeeds

          rem

          rem Mutates: temp2, playerCharacter[]

          rem

          rem Called Routines: None

CharacterSelectRollRandomPlayerReroll

          rem if not valid, try next frame.
          rem Returns: Far (return otherbank)

          let temp2 = rand & $1f

          rem Valid roll - character ID updated, but not locked

          if temp2 >= NumCharacters then return otherbank

          let playerCharacter[currentPlayer] = temp2

          return otherbank

CharacterSelectRollsDone

          return thisbank

CharacterSelectCheckReady

          rem
          rem Returns: Far (return otherbank)

          rem Check If Ready To Proceed

          rem 2-player mode: P1 must be locked AND (P2 locked OR P2 on

          rem CPU)

          if controllerStatus & SetQuadtariDetected then goto CharacterSelectQuadtariReady

          rem P1 is locked, check P2

          let temp1 = 0 : gosub GetPlayerLocked bank6 : if !temp2 then goto CharacterSelectReadyDone

          rem P2 not locked, check if on CPU

          let temp1 = 1 : gosub GetPlayerLocked bank6 : if temp2 then goto CharacterSelectFinish

          if playerCharacter[1] = CPUCharacter then goto CharacterSelectFinish

          goto CharacterSelectReadyDone



CharacterSelectQuadtariReady

          rem 4-player mode: Count players who are ready (locked OR on
          rem Returns: Far (return otherbank)

          rem   CPU/NO)

          let readyCount = 0

          for currentPlayer = 0 to 3

          let temp1 = currentPlayer

          gosub GetPlayerLocked bank6

          if temp2 then goto CharacterSelectQuadtariReadyIncrement

          let temp4 = playerCharacter[currentPlayer]

          if temp4 = CPUCharacter then goto CharacterSelectQuadtariReadyIncrement

          if temp4 = NoCharacter then goto CharacterSelectQuadtariReadyIncrement

          goto CharacterSelectQuadtariReadyNext

CharacterSelectQuadtariReadyIncrement

          let readyCount = readyCount + 1

CharacterSelectQuadtariReadyNext

          next

          if readyCount >= 2 then goto CharacterSelectFinish



CharacterSelectReadyDone
          rem Returns: Far (return otherbank)

          rem Update sound effects (active sound effects need per-frame updates)
          gosub UpdateSoundEffect bank15

          return otherbank

CharacterSelectFinish

          rem Finalize selections and transition to falling animation
          rem Returns: Far (return otherbank)

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

          for currentPlayer = 0 to 3

          if playerCharacter[currentPlayer] = NoCharacter then goto CharacterSelectSkipFacing

          let playerState[currentPlayer] = playerState[currentPlayer] | PlayerStateBitFacing

CharacterSelectSkipFacing

          next



          rem Update sound effects (active sound effects need per-frame updates)
          gosub UpdateSoundEffect bank15

          rem Transition to falling animation

          let gameMode = ModeFallingAnimation

          gosub ChangeGameMode bank14

          return thisbank
