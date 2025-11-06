          rem ChaosFight - Source/Routines/CharacterSelectMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem PlayerLockedHelpers.bas moved to Bank 14
          
          rem ==========================================================
          rem CHARACTER SELECT - PER-FRAME LOOP
          rem ==========================================================
          rem Per-frame character selection screen with Quadtari
          rem   support.
          rem Called from MainLoop each frame (gameMode 3).
          rem Players cycle through NumCharacters characters and lock in
          rem   their choice.
          rem
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
          rem   playerLocked[0-3) - Lock state (0=unlocked, 1=locked)
          rem   QuadtariDetected - Whether 4-player mode is active
          rem   readyCount - Number of locked players
          rem ==========================================================

          rem ==========================================================
          rem SHARED CHARACTER SELECT INPUT HANDLERS
          rem ==========================================================
          rem Consolidated input handlers for character selection
          
          rem Handle character cycling (left/right)
          rem INPUT: temp1 = player index (0-3), temp2 = direction (0=left, 1=right)
          rem        temp3 = player number (0-3)
          rem Uses: joy0left/joy0right for players 0,2; joy1left/joy1right for players 1,3
          rem OUTPUT: Updates playerChar[playerIndex] and plays sound
HandleCharacterSelectCycle
          dim HCSC_playerIndex = temp1
          dim HCSC_direction = temp2
          dim HCSC_playerNumber = temp3
          dim HCSC_characterIndex = temp1
          dim HCSC_soundId = temp1
          rem Determine which joy port to use
          if HCSC_playerIndex = 0 then HCSC_CheckJoy0
          if HCSC_playerIndex = 2 then HCSC_CheckJoy0
          rem Players 1,3 use joy1
          if HCSC_direction = 0 then HCSC_CheckJoy1Left
          if !joy1right then return
          goto HCSC_DoCycle
HCSC_CheckJoy0
          rem Players 0,2 use joy0
          if HCSC_direction = 0 then HCSC_CheckJoy0Left
          if !joy0right then return
          goto HCSC_DoCycle
HCSC_CheckJoy0Left
          if !joy0left then return
HCSC_CheckJoy1Left
          if !joy1left then return
HCSC_DoCycle
          rem Get current character index
          let HCSC_characterIndex = playerChar[HCSC_playerIndex]
          let HCSC_playerNumber = HCSC_playerIndex
          let temp1 = HCSC_characterIndex
          let temp3 = HCSC_playerNumber
          rem Cycle based on direction
          if HCSC_direction = 0 then HCSC_CycleLeft
          gosub CycleCharacterRight
          goto HCSC_CycleDone
HCSC_CycleLeft
          gosub CycleCharacterLeft
HCSC_CycleDone
          let HCSC_characterIndex = temp1
          let playerChar[HCSC_playerIndex] = HCSC_characterIndex
          let temp1 = HCSC_playerIndex
          let temp2 = PlayerLockedUnlocked
          gosub bank14 SetPlayerLocked
          rem Play navigation sound
          let HCSC_soundId = SoundMenuNavigate
          let temp1 = HCSC_soundId
          gosub bank15 PlaySoundEffect
          return
          
          rem Handle fire input (selection)
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0fire/joy0down for players 0,2; joy1fire/joy1down for players 1,3
          rem OUTPUT: Updates playerLocked and plays sound
HandleCharacterSelectFire
          dim HCSF_playerIndex = temp1
          dim HCSF_soundId = temp1
          dim HCSF_playerNumber = temp3
          dim HCSF_joyFire = temp2
          dim HCSF_joyDown = temp4
          rem Determine which joy port to use
          if HCSF_playerIndex = 0 then HCSF_CheckJoy0
          if HCSF_playerIndex = 2 then HCSF_CheckJoy0
          rem Players 1,3 use joy1
          if !joy1fire then return
          let HCSF_joyFire = 1
          if joy1down then let HCSF_joyDown = 1 else let HCSF_joyDown = 0
          goto HCSF_HandleFire
HCSF_CheckJoy0
          rem Players 0,2 use joy0
          if !joy0fire then return
          let HCSF_joyFire = 1
          if joy0down then let HCSF_joyDown = 1 else let HCSF_joyDown = 0
HCSF_HandleFire
          rem Check if RandomCharacter selected
          if playerChar[HCSF_playerIndex] = RandomCharacter then HCSF_HandleRandom
          rem Check for handicap mode (down+fire = 75% health)
          if HCSF_joyDown then HCSF_HandleHandicap
          let HCSF_playerNumber = HCSF_playerIndex
          let temp1 = HCSF_playerNumber
          let temp2 = PlayerLockedNormal
          gosub bank14 SetPlayerLocked
          rem Play selection sound
          let HCSF_soundId = SoundMenuSelect
          let temp1 = HCSF_soundId
          gosub bank15 PlaySoundEffect
          return
HCSF_HandleHandicap
          let HCSF_playerNumber = HCSF_playerIndex
          let temp1 = HCSF_playerNumber
          let temp2 = PlayerLockedHandicap
          gosub bank14 SetPlayerLocked
          rem Play selection sound
          let HCSF_soundId = SoundMenuSelect
          let temp1 = HCSF_soundId
          gosub bank15 PlaySoundEffect
          return
HCSF_HandleRandom
          rem Random selection initiated - will be handled by CharacterSelectHandleRandomRolls
          rem Store handicap flag if down was held
          if HCSF_joyDown then randomSelectFlags[HCSF_playerIndex] = $80 else randomSelectFlags[HCSF_playerIndex] = 0
          rem Play selection sound
          let HCSF_soundId = SoundMenuSelect
          let temp1 = HCSF_soundId
          gosub bank15 PlaySoundEffect
          rem Fall through - character will stay as RandomCharacter until roll succeeds
          return

CharacterSelectInputEntry
          rem Check for controller re-detection on Select/Pause/ColorB&W switches
          gosub CharacterSelectCheckControllerRescan
          
          rem Quadtari controller multiplexing
          if qtcontroller then CharacterSelectHandleQuadtari
          
          rem Handle Player 1 input (joy0 on even frames)
          if joy0left then CS_HandlePlayer0Left
          if joy0right then CS_HandlePlayer0Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked : goto CS_Player0LockClearDone
          if joy0down then let temp1 = 0 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked
CS_Player0LockClearDone
          if joy0fire then CS_HandlePlayer0Fire
          
          rem Handle Player 2 input (joy1 on even frames)
          if joy1left then CS_HandlePlayer1Left
          if joy1right then CS_HandlePlayer1Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked : goto CS_Player1LockClearDone
          if joy1down then let temp1 = 1 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked
CS_Player1LockClearDone
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
          if selectedChar3_R = 0 then CS_SkipPlayer3
          if joy0left then CS_HandlePlayer3Left
          if joy0right then CS_HandlePlayer3Right
          rem Use skip-over pattern to avoid complex || operator
          if joy0up then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked : goto CS_Player3LockClearDone
          if joy0down then let temp1 = 2 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked
CS_Player3LockClearDone
          if joy0fire then CS_HandlePlayer3Fire
CS_SkipPlayer3
          
          rem Handle Player 4 input (joy1 on odd frames)
          if !(controllerStatus & SetQuadtariDetected) then CS_SkipPlayer4
          if selectedChar4_R = 0 then CS_SkipPlayer4
          if joy1left then CS_HandlePlayer4Left
          if joy1right then CS_HandlePlayer4Right
          rem Use skip-over pattern to avoid complex || operator
          if joy1up then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked : goto CS_Player4LockClearDone
          if joy1down then let temp1 = 3 : let temp2 = PlayerLockedUnlocked : gosub bank14 SetPlayerLocked
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
          rem Handle random character re-rolls if any players need it
          gosub CharacterSelectHandleRandomRolls
          
          rem Update character select animations
          gosub SelectUpdateAnimations

          rem Check if all players are ready to start (may transition to
          rem   next mode)
          gosub CharacterSelectCheckReady

          rem Draw character selection screen
          gosub SelectDrawScreen

          rem drawscreen called by MainLoop
          return
          return

          rem ==========================================================
          rem RANDOM CHARACTER ROLL HANDLER
          rem ==========================================================
          rem Re-roll random selections until valid (0-15), then lock
          
CharacterSelectHandleRandomRolls
          rem Check each player for pending random roll
          if playerChar[0] = RandomCharacter then CharacterSelectRollPlayer0
          if playerChar[1] = RandomCharacter then CharacterSelectRollPlayer1
          if controllerStatus & SetQuadtariDetected then CharacterSelectCheckRollQuadtari
          goto CharacterSelectRollsDone
          
CharacterSelectCheckRollQuadtari
          if playerChar[2] = RandomCharacter then CharacterSelectRollPlayer2
          if playerChar[3] = RandomCharacter then CharacterSelectRollPlayer3
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer0
          dim CSR0_rolledValue = temp2
          rem Roll 5-bit random: rand & 31 (0-31)
          let CSR0_rolledValue = rand & 31
          rem If > 15, stay as RandomCharacter and retry next frame
          if CSR0_rolledValue > MaxCharacter then CharacterSelectRollsDone
          rem Valid! Set character and lock with normal or handicap
          let playerChar[0] = CSR0_rolledValue
          if randomSelectFlags[0] then goto CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerLockedNormal : gosub bank14 SetPlayerLocked
          goto CharacterSelectLockPlayer0Done
CharacterSelectLockPlayer0Handicap
          let temp1 = 0 : let temp2 = PlayerLockedHandicap : gosub bank14 SetPlayerLocked
CharacterSelectLockPlayer0Done
          let randomSelectFlags[0] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer1
          dim CSR1_rolledValue = temp2
          let CSR1_rolledValue = rand & 31
          if CSR1_rolledValue > MaxCharacter then CharacterSelectRollsDone
          let playerChar[1] = CSR1_rolledValue
          if randomSelectFlags[1] then goto CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerLockedNormal : gosub bank14 SetPlayerLocked
          goto CharacterSelectLockPlayer1Done
CharacterSelectLockPlayer1Handicap
          let temp1 = 1 : let temp2 = PlayerLockedHandicap : gosub bank14 SetPlayerLocked
CharacterSelectLockPlayer1Done
          let randomSelectFlags[1] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer2
          dim CSR2_rolledValue = temp2
          let CSR2_rolledValue = rand & 31
          if CSR2_rolledValue > MaxCharacter then CharacterSelectRollsDone
          let playerChar[2] = CSR2_rolledValue
          if randomSelectFlags[2] then goto CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerLockedNormal : gosub bank14 SetPlayerLocked
          goto CharacterSelectLockPlayer2Done
CharacterSelectLockPlayer2Handicap
          let temp1 = 2 : let temp2 = PlayerLockedHandicap : gosub bank14 SetPlayerLocked
CharacterSelectLockPlayer2Done
          let randomSelectFlags[2] = 0
          goto CharacterSelectRollsDone
          
CharacterSelectRollPlayer3
          dim CSR3_rolledValue = temp2
          let CSR3_rolledValue = rand & 31
          if CSR3_rolledValue > MaxCharacter then CharacterSelectRollsDone
          let playerChar[3] = CSR3_rolledValue
          if randomSelectFlags[3] then goto CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerLockedNormal : gosub bank14 SetPlayerLocked
          goto CharacterSelectLockPlayer3Done
CharacterSelectLockPlayer3Handicap
          let temp1 = 3 : let temp2 = PlayerLockedHandicap : gosub bank14 SetPlayerLocked
CharacterSelectLockPlayer3Done
          let randomSelectFlags[3] = 0
          
CharacterSelectRollsDone
          return

          rem ==========================================================
          rem CHECK IF READY TO PROCEED
          rem ==========================================================
CharacterSelectCheckReady
          rem 2-player mode: P1 must be locked AND (P2 locked OR P2 on
          rem   CPU)
          if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariReady
          let temp1 = 0 : gosub bank14 GetPlayerLocked : if !temp2 then CharacterSelectReadyDone
          rem P1 is locked, check P2
          let temp1 = 1 : gosub bank14 GetPlayerLocked : if temp2 then CharacterSelectFinish
          rem P2 not locked, check if on CPU
          if playerChar[1] = CPUCharacter then CharacterSelectFinish
          goto CharacterSelectReadyDone
          
CharacterSelectQuadtariReady
          rem 4-player mode: Count players who are ready (locked OR on
          rem   CPU/NO)
          let readyCount = 0
          rem Count P1 ready
          let temp1 = 0 : gosub bank14 GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 0 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[0] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 0 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[0] = NoCharacter then readyCount = readyCount + 1
          rem Count P2 ready
          let temp1 = 1 : gosub bank14 GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 1 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[1] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 1 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[1] = NoCharacter then readyCount = readyCount + 1
          rem Count P3 ready
          let temp1 = 2 : gosub bank14 GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 2 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[2] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 2 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[2] = NoCharacter then readyCount = readyCount + 1
          rem Count P4 ready
          let temp1 = 3 : gosub bank14 GetPlayerLocked : if temp2 then readyCount = readyCount + 1
          let temp1 = 3 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[3] = CPUCharacter then readyCount = readyCount + 1
          let temp1 = 3 : gosub bank14 GetPlayerLocked : if !temp2 && playerChar[3] = NoCharacter then readyCount = readyCount + 1
          if readyCount >= 2 then CharacterSelectFinish
          
CharacterSelectReadyDone
          return

CharacterSelectFinish
          rem Store final selections
          let selectedChar1 = playerChar[0]
          let selectedChar2_W = playerChar[1]
          let selectedChar3_W = playerChar[2]
          let selectedChar4_W = playerChar[3]
          
          rem Initialize facing bit (bit 0) for all selected players
          rem   (default: face right = 1)
          if selectedChar1 = NoCharacter then SkipChar1Facing
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
          
          rem Transition to falling animation
          let gameMode = ModeFallingAnimation
          gosub bank14 ChangeGameMode
          return

          rem ==========================================================
          rem CHARACTER CYCLING HELPERS
          rem ==========================================================
          rem Handle wraparound cycling for characters with special
          rem   values
          rem Input: temp1 = playerChar value, temp2 = direction
          rem   (0=left, 1=right), temp3 = player number
          rem Output: temp1 = new playerChar value
          
CycleCharacterLeft
          dim CCL_characterIndex = temp1
          dim CCL_playerNumber = temp3
          rem Decrement character with special value wraparound
          rem P1: RandomCharacter(253) ↔ 0 ↔ 15 ↔ RandomCharacter
          rem P2: CPUCharacter(254) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔
          rem   CPUCharacter
          rem P3/P4: NoCharacter(255) ↔ 0 ↔ 15 ↔ RandomCharacter(253) ↔
          rem   NoCharacter
          
          rem Check if we’re at a special value
          if CCL_characterIndex = RandomCharacter then CycleFromRandom : return
          if CCL_characterIndex = CPUCharacter then CycleFromCPU : return
          if CCL_characterIndex = NoCharacter then CycleFromNO : return
          
          rem Normal character (0-15): decrement
          rem Check if we’re at 0 before decrementing (need to wrap to
          rem   special)
          if !CCL_characterIndex then CharacterSelectLeftWrapCheck
          let CCL_characterIndex = CCL_characterIndex - 1
          let temp1 = CCL_characterIndex
          return
          
CharacterSelectLeftWrapCheck
          dim CSLWC_characterIndex = temp1
          dim CSLWC_playerNumber = temp3
          rem After 0, wrap to player-specific special character
          if CSLWC_playerNumber = 0 then let CSLWC_characterIndex = RandomCharacter : let temp1 = CSLWC_characterIndex : return
          if CSLWC_playerNumber = 1 then SelectP2LeftWrap
          let CSLWC_characterIndex = NoCharacter
          let temp1 = CSLWC_characterIndex
          return
          
SelectP2LeftWrap
          dim SP2LW_characterIndex = temp1
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not
          rem   both NO)
          if !(controllerStatus & SetQuadtariDetected) then let SP2LW_characterIndex = CPUCharacter : let temp1 = SP2LW_characterIndex : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] = NoCharacter then CheckP4_LeftWrap
          let SP2LW_characterIndex = NoCharacter
          let temp1 = SP2LW_characterIndex
          return
CheckP4_LeftWrap
          if playerChar[3] = NoCharacter then BothNO_LeftWrap
          let SP2LW_characterIndex = NoCharacter
          let temp1 = SP2LW_characterIndex
          return
BothNO_LeftWrap
          rem Both P3 and P4 are NO, so P2 wraps to CPU
          let SP2LW_characterIndex = CPUCharacter
          let temp1 = SP2LW_characterIndex
          return
          
CycleFromRandom
          dim CFR_characterIndex = temp1
          dim CFR_playerNumber = temp3
          rem RandomCharacter(253) left cycle: direction-dependent
          rem P1: ... Random → 15 → 14 → ...
          rem P2: ... Random → NO (if available) → CPU OR Random → 15
          rem P3/P4: Random → NO
          rem Check if this is P2 with NO available
          if CFR_playerNumber = 1 then SelectP2LeftFromRandom
          rem P1 or P3/P4: Random left goes to NO (P3/P4) or 15 (P1)
          if CFR_playerNumber = 0 then let CFR_characterIndex = MaxCharacter : let temp1 = CFR_characterIndex : return
          rem P1 → 15
          rem P3/P4 → NO
          let CFR_characterIndex = NoCharacter
          let temp1 = CFR_characterIndex
          return
          
SelectP2LeftFromRandom
          dim SP2LFR_characterIndex = temp1
          rem P2 left from Random: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then let SP2LFR_characterIndex = MaxCharacter : let temp1 = SP2LFR_characterIndex : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] = NoCharacter then CheckP4_LeftFromRandom
          let SP2LFR_characterIndex = NoCharacter
          let temp1 = SP2LFR_characterIndex
          return
CheckP4_LeftFromRandom
          if playerChar[3] = NoCharacter then BothNO_LeftFromRandom
          let SP2LFR_characterIndex = NoCharacter
          let temp1 = SP2LFR_characterIndex
          return
BothNO_LeftFromRandom
          rem Both P3 and P4 are NO, so NO not available, go to 15
          let SP2LFR_characterIndex = MaxCharacter
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
          rem   this)
          let CFC_characterIndex = RandomCharacter
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
          rem P3/P4: NO → Random
          let CFNO_characterIndex = RandomCharacter
          let temp1 = CFNO_characterIndex
          return
          
CycleCharacterRight
          dim CCR_characterIndex = temp1
          dim CCR_playerNumber = temp3
          rem Increment character with special value wraparound
          if CCR_characterIndex = RandomCharacter then CycleRightFromRandom : return
          if CCR_characterIndex = CPUCharacter then CycleRightFromCPU : return
          if CCR_characterIndex = NoCharacter then CycleRightFromNO : return
          
          rem Normal character (0-15): increment
          let CCR_characterIndex = CCR_characterIndex + 1
          rem Check if we went past 15 (wrap to RandomCharacter)
          if CCR_characterIndex > MaxCharacter then CharacterSelectRightWrapCheck
          let temp1 = CCR_characterIndex
          return
          
CharacterSelectRightWrapCheck
          dim CSRWC_characterIndex = temp1
          rem After 15, go to RandomCharacter instead of wrapping to 0
          let CSRWC_characterIndex = RandomCharacter
          let temp1 = CSRWC_characterIndex
          return
          
CycleRightFromRandom
          dim CRFR_characterIndex = temp1
          dim CRFR_playerNumber = temp3
          rem RandomCharacter(253) goes to special for each player
          if CRFR_playerNumber = 0 then let CRFR_characterIndex = 0 : let temp1 = CRFR_characterIndex : return
          if CRFR_playerNumber = 1 then SelectP2RightFromRandom
          let CRFR_characterIndex = NoCharacter
          let temp1 = CRFR_characterIndex
          return
          
SelectP2RightFromRandom
          dim SP2RFR_characterIndex = temp1
          rem P2: Check if NO is available (if Quadtari and P3 or P4 not
          rem   both NO)
          if !(controllerStatus & SetQuadtariDetected) then let SP2RFR_characterIndex = CPUCharacter : let temp1 = SP2RFR_characterIndex : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] = NoCharacter then CheckP4_RightFromRandom
          let SP2RFR_characterIndex = NoCharacter
          let temp1 = SP2RFR_characterIndex
          return
CheckP4_RightFromRandom
          if playerChar[3] = NoCharacter then BothNO_RightFromRandom
          let SP2RFR_characterIndex = NoCharacter
          let temp1 = SP2RFR_characterIndex
          return
BothNO_RightFromRandom
          rem Both P3 and P4 are NO, so P2 goes to CPU
          let SP2RFR_characterIndex = CPUCharacter
          let temp1 = SP2RFR_characterIndex
          return
          
CycleRightFromCPU
          dim CRFC_characterIndex = temp1
          dim CRFC_playerNumber = temp3
          rem CPUCharacter(254) wraps based on player
          rem P1: CPU → Random → ...
          rem P2: CPU → NO (if available) → Random → ... OR CPU → Random
          rem P3/P4: Should not reach CPU, but handle gracefully
          if CRFC_playerNumber = 1 then SelectP2RightFromCPU
          goto CycleRightFromCPUDone
SelectP2RightFromCPU
          dim SP2RFC_characterIndex = temp1
          rem P2 from CPU: Check if NO is available
          if !(controllerStatus & SetQuadtariDetected) then let SP2RFC_characterIndex = RandomCharacter : let temp1 = SP2RFC_characterIndex : return
          rem Check if P3 or P4 are NOT both NO
          if playerChar[2] = NoCharacter then CheckP4_RightFromCPU
          let SP2RFC_characterIndex = NoCharacter
          let temp1 = SP2RFC_characterIndex
          return
CheckP4_RightFromCPU
          if playerChar[3] = NoCharacter then BothNO_RightFromCPU
          let SP2RFC_characterIndex = NoCharacter
          let temp1 = SP2RFC_characterIndex
          return
BothNO_RightFromCPU
          rem Both P3 and P4 are NO, so skip NO and go to Random
          let SP2RFC_characterIndex = RandomCharacter
          let temp1 = SP2RFC_characterIndex
          return
CycleRightFromCPUDone
          dim CRFCD_characterIndex = temp1
          rem Default for P1 or other players (not P2)
          let CRFCD_characterIndex = RandomCharacter
          let temp1 = CRFCD_characterIndex
          return
          
CycleRightFromNO
          dim CRFNO_characterIndex = temp1
          rem NoCharacter(255) goes to 0
          let CRFNO_characterIndex = 0
          let temp1 = CRFNO_characterIndex
          return
          
          rem ==========================================================
          rem CHARACTER SELECT DRAWING FUNCTIONS
          rem ==========================================================

SelectDrawScreen
          rem Clear playfield
          pf0 = 0 : pf1 = 0 : pf2 = 0 : pf3 = 0 : pf4 = 0 : pf5 = 0
          
          rem Draw Player 1 selection (top left)
          player0x = 56 : player0y = 40
          gosub SelectDrawSprite
          gosub SelectDrawNumber
          
          rem Draw Player 2 selection (top right)
          player1x = 104 : player1y = 40
          gosub SelectDrawSprite
          gosub SelectDrawNumber
          
          rem Draw Player 3 selection (bottom left) if Quadtari
          if controllerStatus & SetQuadtariDetected then SelectDrawP3
          goto SelectSkipP3
SelectDrawP3
          player0x = 56 : player0y = 80
          gosub SelectDrawSprite
          gosub SelectDrawNumber
          
          rem Draw Player 4 selection (bottom right) if Quadtari
          if controllerStatus & SetQuadtariDetected then SelectDrawP4
          goto SelectSkipP4
SelectDrawP4
          player1x = 104 : player1y = 80
          gosub SelectDrawSprite
          gosub SelectDrawNumber
SelectSkipP3
SelectSkipP4
          
          rem Draw locked status indicators
          rem tail call
          goto SelectDrawLocks
          
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
          rem Determine which player based on position
          let SDS_playerNumber = 255
          rem Initialize to invalid
          if player0x = 56 then SelectDeterminePlayerP0
          if player1x = 104 then SelectDeterminePlayerP1
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
          rem Load sprite for determined player
          if SLS_playerNumber > 3 then SelectDrawSpriteDone
          let SLS_playerNumberSaved = SLS_playerNumber
          rem Save player number
          let SLS_characterIndex = playerChar[SLS_playerNumberSaved]
          
          rem Use character select animation state
          rem charSelectPlayerAnimSeq has animation sequence (bit 0:
          rem   0=idle, 1=walk)
          rem charSelectPlayerAnimFrame has animation frame counter
          rem   (0-7)
          rem Map to proper animation action: 0=idle (ActionIdle=1),
          rem   1=walk (ActionWalking=3)
          if charSelectPlayerAnimSeq[SLS_playerNumberSaved] then SelectLoadWalkingSprite
          
          rem Idle animation
          let SLS_animationFrame = charSelectPlayerAnimFrame[SLS_playerNumberSaved]
          rem frame
          rem LocateCharacterArt expects: temp1=char, temp2=frame,
          rem   temp3=action, temp4=player
          let SLS_animationAction = 1
          rem ActionIdle = 1
          let SLS_playerNumberForArt = SLS_playerNumberSaved
          let temp1 = SLS_characterIndex
          let temp2 = SLS_animationFrame
          let temp3 = SLS_animationAction
          let temp4 = SLS_playerNumberForArt
          gosub bank14 LocateCharacterArt
          goto SelectLoadSpriteColor
          
SelectLoadWalkingSprite
          dim SLWS_playerNumberSaved = temp6
          dim SLWS_animationFrame = temp2
          dim SLWS_animationAction = temp3
          dim SLWS_playerNumberForArt = temp4
          dim SLWS_characterIndex = temp1
          dim SLWS_isHurt = temp2
          dim SLWS_isFlashing = temp4
          rem Walking animation
          let SLWS_animationFrame = charSelectPlayerAnimSeq[SLS_playerNumberSaved]
          rem Use sequence counter as frame (0-3 for 4-frame walk)
          let SLWS_animationAction = 3
          rem ActionWalking = 3
          let SLWS_playerNumberForArt = SLS_playerNumberSaved
          let temp1 = SLS_characterIndex
          let temp2 = SLWS_animationFrame
          let temp3 = SLWS_animationAction
          let temp4 = SLWS_playerNumberForArt
          gosub bank14 LocateCharacterArt
          
SelectLoadSpriteColor
          dim SLSC_playerNumberSaved = temp6
          dim SLSC_characterIndex = temp1
          dim SLSC_isHurt = temp2
          dim SLSC_playerNumber = temp3
          dim SLSC_isFlashing = temp4
          rem Now set player color
          let SLSC_characterIndex = playerChar[SLSC_playerNumberSaved]
          let SLSC_isHurt = 0
          rem not hurt
          let SLSC_playerNumber = SLSC_playerNumberSaved
          rem player number
          let SLSC_isFlashing = 0
          rem not flashing
          let temp2 = SLSC_isHurt
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
          rem Check if we have valid player position
          if player0x = 56 then SelectNumberPlayerP0
          if player1x = 104 then SelectNumberPlayerP1
          rem No valid position, skip number
          goto SelectDrawNumberDone
          
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
          
          if !NPC_playerIndex then SelectNumberP1
          rem P1 (0)
          if NPC_playerIndex = 1 then SelectNumberP2
          rem P2 (1)
          if NPC_playerIndex = 2 then SelectNumberP3
          rem P3 (2)
          goto SelectNumberP4
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
          rem P1: left, top row, player0, indigo
          let temp1 = SNP1_digit
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
          rem P2 (virtual sprite): right, top row, player1, red, shows P1
          let temp1 = SNP2_digit
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
          rem P3 (virtual sprite): left, bottom row, player0, yellow, shows P2
          let temp1 = SNP3_digit
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
          rem P4 (virtual sprite): right, bottom row, player1, green, shows P3
          let temp1 = SNP4_digit
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
          rem DrawDigit is in Bank 14 (FontRendering.bas) with MainLoop and drawscreen
          gosub bank14 DrawDigit
          
SelectDrawNumberDone
          return
          
SelectDrawLocks
          rem Draw locked status borders using playfield
          let temp1 = 0 : gosub bank14 GetPlayerLocked : if temp2 then SelectDrawP0Border
          goto SelectSkipP0Border
SelectDrawP0Border
          pf0 = pf0 | %10000000
          pf1 = pf1 | %00000001
SelectSkipP0Border
          
          let temp1 = 1 : gosub bank14 GetPlayerLocked : if temp2 then SelectDrawP1Border
          goto SelectSkipP1Border
SelectDrawP1Border
          pf0 = pf0 | %00001000
          pf1 = pf1 | %00010000
SelectSkipP1Border
          
          if controllerStatus & SetQuadtariDetected then SelectCheckP2Lock
          goto SelectSkipCheckP2Lock
SelectCheckP2Lock
          let temp1 = 2 : gosub bank14 GetPlayerLocked : if temp2 then SelectDrawP2Border
          let temp1 = 3 : gosub bank14 GetPlayerLocked : if temp2 then SelectDrawP3Border
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
          
          rem ==========================================================
          rem ANIMATION UPDATES
          rem ==========================================================

SelectUpdateAnimations
          rem Update character select animations for all players
          rem Players cycle through idle/walk animations to show
          rem   selected characters
          rem Each player updates independently with staggered timing
          
          rem Update Player 1 animations (characters)
          let temp1 = 0 : gosub bank14 GetPlayerLocked : if temp2 then SelectSkipPlayer0Anim  : rem Locked players don’t animate
          if playerChar[0] = CPUCharacter then SelectSkipPlayer0Anim  : rem CPU doesn’t animate
          if playerChar[0] = NoCharacter then SelectSkipPlayer0Anim  : rem NO doesn’t animate
          if playerChar[0] = RandomCharacter then SelectSkipPlayer0Anim  : rem Random doesn’t animate
          let temp1 = 0
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer0Anim
          rem Update Player 2 animations
          let temp1 = 1 : gosub bank14 GetPlayerLocked : if temp2 then SelectSkipPlayer1Anim
          if playerChar[1] = CPUCharacter then SelectSkipPlayer1Anim
          if playerChar[1] = NoCharacter then SelectSkipPlayer1Anim
          if playerChar[1] = RandomCharacter then SelectSkipPlayer1Anim
          let temp1 = 1
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer1Anim
          rem Update Player 3 animations (if Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then SelectSkipPlayer23Anim
          let temp1 = 2 : gosub bank14 GetPlayerLocked : if temp2 then SelectSkipPlayer2Anim
          if playerChar[2] = NoCharacter then SelectSkipPlayer2Anim
          if playerChar[2] = RandomCharacter then SelectSkipPlayer2Anim
          let temp1 = 2
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer2Anim
          rem Update Player 4 animations (if Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then SelectSkipPlayer23Anim
          let temp1 = 3 : gosub bank14 GetPlayerLocked : if temp2 then SelectSkipPlayer23Anim
          if playerChar[3] = NoCharacter then SelectSkipPlayer23Anim
          if playerChar[3] = RandomCharacter then SelectSkipPlayer23Anim
          let temp1 = 3
          gosub SelectUpdatePlayerAnim
          
SelectSkipPlayer23Anim
          return
          
          rem ==========================================================
          rem UPDATE INDIVIDUAL PLAYER ANIMATION
          rem ==========================================================
          
SelectUpdatePlayerAnim
          dim SUPA_playerIndex = temp1
          rem Update animation for a single player
          rem Input: playerIndex = player index (0-3)
          rem Increment frame counter
          let charSelectPlayerAnimFrame[SUPA_playerIndex] = charSelectPlayerAnimFrame[SUPA_playerIndex] + 1
          
          rem Check if it’s time to advance frame (every 6 frames for
          rem   10fps at 60fps)
          if charSelectPlayerAnimFrame[SUPA_playerIndex] >= AnimationFrameDelay then SelectAdvanceAnimFrame
          return
          
SelectAdvanceAnimFrame
          dim SAAF_playerIndex = temp1
          dim SAAF_sequenceValue = temp2
          rem Reset frame counter
          let charSelectPlayerAnimFrame[SAAF_playerIndex] = 0
          
          rem Check current animation sequence
          if !charSelectPlayerAnimSeq[SAAF_playerIndex] then SelectAdvanceIdleAnim
          rem Walking animation: cycle through 4 frames (0-3)
          rem Use bit 0-1 of sequence counter
          let SAAF_sequenceValue = (charSelectPlayerAnimSeq[SAAF_playerIndex] + 1) & 3
          let charSelectPlayerAnimSeq[SAAF_playerIndex] = SAAF_sequenceValue
          
          rem After 4 walk frames (frame 3→0), switch to idle
          if charSelectPlayerAnimSeq[SAAF_playerIndex] then return
          rem Switch back to idle after walk cycle
          let charSelectPlayerAnimSeq[SAAF_playerIndex] = 0
          
          rem Toggle to walk sequence after idle
          rem Just set sequence flag to 1 (walk) for next cycle
          goto SelectAnimWaitForToggle
          
SelectAdvanceIdleAnim
          dim SAAI_playerIndex = temp1
          rem Idle animation cycles every 60 frames, then toggles to
          rem   walk
          rem Use higher bit in sequence to count idle cycles
          rem Every 60 frames (10 idle animations), toggle to walk
          if frame & 63 then return
          rem Check every 64 frames roughly
          
          rem Toggle to walk
          let charSelectPlayerAnimSeq[SAAI_playerIndex] = 1
          rem Start walking
          return
          
SelectAnimWaitForToggle
          rem Just return, toggling handled above
          return

          rem ==========================================================
          rem CONTROLLER RESCAN DETECTION
          rem ==========================================================
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          rem to handle Quadtari being connected/disconnected
          
CharacterSelectCheckControllerRescan
          dim CSCR_switchBW = temp6
          rem Check for Game Select or Pause button press
          if switchselect then CharacterSelectDoRescan
          rem Check for Color/B&W switch toggle
          let CSCR_switchBW = switchbw
          if CSCR_switchBW = colorBWPrevious_R then CharacterSelectRescanDone
          rem Switch toggled, do rescan
          gosub bank6 SelDetectQuad
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
          
CharacterSelectDoRescan
          rem Re-detect Quadtari via bank6
          gosub bank6 SelDetectQuad
          rem Debounce - wait for switch release (drawscreen called by MainLoop)
          
CharacterSelectRescanDone
          return

