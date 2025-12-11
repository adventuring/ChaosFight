;;; ChaosFight - Source/Routines/CharacterSelectMain.bas

          ;;
;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; Character Select - Per-frame Loop

          ;;
          ;; Per-frame character selection screen with Quadtari

          ;; support.

          ;; Called from MainLoop each frame (gameMode 3).

          ;; Players cycle through NumCharacters characters and lock in

          ;; their choice.

          ;; Setup is handled by SetupCharacterSelect in

          ;; ChangeGameMode.bas

          ;; This function processes one frame and returns.

          ;; FLOW PER FRAME:

          ;; 1. Handle input with Quadtari multiplexing

          ;; 2. Update animations

          ;; 3. Check if ready to proceed

          ;; 4. Draw screen

          ;; 5. Return to MainLoop

          ;; QUADTARI MULTIPLEXING:

          ;; Even frames (qtcontroller=0): joy0=P1, joy1=P2

          ;; Odd frames (qtcontroller=1): joy0=P3, joy1=P4

          ;; AVAILABLE VARIABLES:

          ;; playerCharacter[0-3) - Selected character indices (0-15)

          ;;
          ;; playerLocked[0-3) - Lock state (0=unlocked, 1=locked)

          ;; QuadtariDetected - Whether 4-player mode is active

          ;; readyCount - Number of locked players

          ;; Shared Character Select Input Handlers

          ;; Consolidated input handlers for character selection

          ;; Handle character cycling (left/right)

          ;;
          ;; INPUT: temp1 = player index (0-3), temp2 = direction

          ;; (0=left, 1=right)

          ;; temp3 = player number (0-3)

          ;; Uses: joy0left/joy0right for players 0,2;

          ;; joy1left/joy1right for players 1,3

          ;;
          ;; OUTPUT: Updates playerCharacter[playerIndex] and plays sound

          ;; Handle character cycling (left/right) for a player

          ;;
          ;; Input: temp1 = player index (0-3)

          ;; temp2 = direction (0=left, 1=right)

          ;; playerCharacter[] (global array) = current character

          ;; selections

          ;; joy0left, joy0right, joy1left, joy1right (hardware)

          ;; = joystick sta


          ;;
          ;; Output: playerCharacter[temp1] updated, playerLocked

          ;; state set to unlocked

          ;;
          ;; Mutates: playerCharacter[temp1] (cycled),

          ;; playerLocked state (set to unlocked),

          ;; temp1, temp2, temp3 (passed to helper routines)

          ;;
          ;; Called Routines: CycleCharacterLeft, CycleCharacterRight -

          ;; access playerCharacter[],

          ;; SetPlayerLocked (bank6) - accesses playerLocked sta


          ;; PlaySoundEffect (bank15) - plays navigation sound

          ;;
          ;; Constraints: Must be colocated with HCSC_CheckJoy0,

          ;; HCSC_CheckJoy0Left,

          ;; HCSC_CheckJoy1Left, HandleCharacterSelectCycle


HCSC_CheckJoy0 .proc

          ;; Check joy0 for players 0,2
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1, temp2 (from

          ;; HandleCharacterSelectCycle)

          ;; joy0left, joy0right (hardware) = joystick sta


          ;;
          ;; Output: Dispatches to HCSC_CheckJoy0Left or HandleCharacterSelectCycle

          ;;
          ;; Mutates: None (dispatcher only)

          ;;
          ;; Called Routines: None (dispatcher only)

          ;;
          ;; Constraints: Must be colocated with

          ;; HandleCharacterSelectCycle

          ;; Players 0,2 use joy0

          lda temp2
          cmp # 0
          bne HandleCharacterSelectCycle
          jmp HCSC_CheckJoy0Left
HandleCharacterSelectCycle:


          jsr BS_return

          jmp HandleCharacterSelectCycle

.pend

HCSC_CheckJoy0Left .proc

          ;; Check joy0 left button
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: joy0left (hardware) = joystick sta


          ;;
          ;; Output: Returns if not pressed, continues to HandleCharacterSelectCycle

          if pressed

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with HandleCharacterSelectCycle

          jsr BS_return

.pend

HCSC_CheckJoy1Left .proc

          ;; Check joy1 left button
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: joy1left (hardware) = joystick sta


          ;;
          ;; Output: Returns if not pressed, continues to HandleCharacterSelectCycle

          if pressed

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with HandleCharacterSelectCycle

          jsr BS_return

.pend

HandleCharacterSelectCycle .proc


          ;; Perform character cycling
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1, temp2 (from

          ;; HandleCharacterSelectCycle)

          ;; playerCharacter[] (global array) = current character

          ;; selections

          ;;
          ;; Output: playerCharacter[temp1] cycled, playerLocked

          ;; state set to unlocked

          ;;
          ;; Mutates: playerCharacter[temp1], playerLocked sta


          ;; temp1, temp2, temp3

          ;;
          ;; Called Routines: CycleCharacterLeft, CycleCharacterRight,

          ;; SetPlayerLocked (bank6),

          ;; PlaySoundEffect (bank15)

          ;;
          ;; Constraints: Must be colocated with

          ;; Preserve player index for updates and lock handling

          lda temp1
          sta temp4

          ;; Load current character selection

          ;; let temp1 = playerCharacter[temp4]         
          lda temp4
          asl
          tax
          lda playerCharacter,x
          sta temp1

          ;; temp3 stores the player index for inline cycling logic

          lda temp4
          sta temp3

          lda temp2
          cmp # 0
          bne HCSC_CycleRight
          jmp HCSC_CycleLeft
HCSC_CycleRight:


          jmp HCSC_CycleRight

.pend

HCSC_CycleLeft .proc

          ;; Handle stick-left navigation with ordered wrap logic
          ;; Returns: Far (return otherbank)

          lda temp1
          cmp RandomCharacter
          bne CheckNoCharacterLeft
          jmp HCSC_LeftFromRandom
CheckNoCharacterLeft:


          lda temp1
          cmp NoCharacter
          bne CheckCPUCharacterLeft
          jmp HCSC_LeftFromNoOrCPU
CheckCPUCharacterLeft:


          lda temp1
          cmp CPUCharacter
          bne CheckZeroLeft
          jmp HCSC_LeftFromNoOrCPU
CheckZeroLeft:


          lda temp1
          cmp # 0
          bne DecrementCharacter
          jmp HCSC_LeftFromZero
DecrementCharacter:


          dec temp1

          jmp HCSC_CycleDone

.pend

HCSC_LeftFromRandom .proc

          lda temp3
          cmp # 0
          bne SetNoCharacterLeft
          ;; let temp1 = MaxCharacter : goto HCSC_CycleDone
SetNoCharacterLeft:

          jsr HCSC_GetPlayer2Tail

          lda NoCharacter
          sta temp1

          jmp HCSC_CycleDone

.pend

HCSC_LeftFromNoOrCPU .proc

          lda MaxCharacter
          sta temp1

          jmp HCSC_CycleDone

.pend

HCSC_LeftFromZero .proc

          lda RandomCharacter
          sta temp1

          jmp HCSC_CycleDone

.pend

HCSC_CycleRight .proc

          ;; Handle stick-right navigation with ordered wrap logic
          ;; Returns: Far (return otherbank)

          lda temp1
          cmp RandomCharacter
          bne CheckNoCharacterRight
          jmp HCSC_RightFromRandom
CheckNoCharacterRight:


          lda temp1
          cmp NoCharacter
          bne CheckCPUCharacterRight
          jmp HCSC_RightFromNoOrCPU
CheckCPUCharacterRight:


          lda temp1
          cmp CPUCharacter
          bne CheckMaxCharacterRight
          jmp HCSC_RightFromNoOrCPU
CheckMaxCharacterRight:


          lda temp1
          cmp MaxCharacter
          bne IncrementCharacter
          jmp HCSC_RightFromMax
IncrementCharacter:


          inc temp1

          jmp HCSC_CycleDone

.pend

HCSC_RightFromRandom .proc

          lda # 0
          sta temp1

          jmp HCSC_CycleDone

.pend

HCSC_RightFromNoOrCPU .proc

          lda RandomCharacter
          sta temp1

          jmp HCSC_CycleDone

.pend

HCSC_RightFromMax .proc

          lda temp3
          cmp # 0
          bne SetNoCharacterRight
          ;; let temp1 = RandomCharacter : goto HCSC_CycleDone
SetNoCharacterRight:

          jsr HCSC_GetPlayer2Tail

          lda NoCharacter
          sta temp1

          jmp HCSC_CycleDone

.pend

HCSC_GetPlayer2Tail .proc


          ;; Determine whether Player 2 wraps to CPU or NO
          ;; Returns: Far (return otherbank)

          lda CPUCharacter
          sta temp6

          ;; if playerCharacter[2] = NoCharacter then goto HCSC_P2TailCheckP4
          lda NoCharacter
          sta temp6

          jmp HCSC_P2TailDone

.pend

HCSC_P2TailCheckP4 .proc

          ;; if playerCharacter[3] = NoCharacter then goto HCSC_P2TailDone
          lda NoCharacter
          sta temp6

HCSC_P2TailDone

          rts

HCSC_CycleDone

          ;; Character cycling complete
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1, temp1 (from

          ;; HandleCharacterSelectCycle)

          ;; temp1 (from CycleCharacterLeft/Right)

          ;;
          ;; Output: playerCharacter[temp1] updated, playerLocked

          ;; state set to unlocked

          ;;
          ;; Mutates: playerCharacter[temp1], playerLocked sta


          ;; temp1, temp2

          ;;
          ;; Called Routines: SetPlayerLocked (bank6),

          ;; PlaySoundEffect (bank15)

          lda temp3
          asl
          tax
          lda temp1
          sta playerCharacter,x

          lda PlayerLockedUnlocked
          sta temp2

          lda temp3
          sta temp1

          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerLocked:


          ;; Play navigation sound

          lda # SoundMenuNavigate
          sta temp1

          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(AfterPlaySoundEffectNav-1)
          pha
          lda # <(AfterPlaySoundEffectNav-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterPlaySoundEffectNav:


          jsr BS_return

.pend

CharacterSelectInputEntry .proc




          ;; Cross-bank call to CharacterSelectCheckControllerRescan in bank 6
          lda # >(AfterControllerRescan-1)
          pha
          lda # <(AfterControllerRescan-1)
          pha
          lda # >(CharacterSelectCheckControllerRescan-1)
          pha
          lda # <(CharacterSelectCheckControllerRescan-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterControllerRescan:




          ;; Consolidated input handling with Quadtari multiplexing
          ;; Returns: Far (return otherbank)

          lda # 0
          sta temp3

          ;; Player offset: 0=P1/P2, 2=P3/P4

                    if controllerStatus & SetQuadtariDetected then let temp3 = qtcontroller * 2
          jsr CharacterSelectHandleTwoPlayers



                    if controllerStatus & SetQuadtariDetected then let qtcontroller = qtcontroller ^ 1 else qtcontroller = 0
          jmp CharacterSelectInputComplete



CharacterSelectHandleTwoPlayers
          ;; Returns: Far (return thisbank)


CharacterSelectHandleTwoPlayers




          ;; Handle input for two players (P1/P2 or P3/P4 based on temp3)
          ;; Returns: Far (return otherbank)

          ;; temp3 = player offset (0 or 2)



          ;; Check if second player should be active (Quadtari)

          lda # 0
          sta temp4

          lda temp3
          cmp # 0
          bne CheckQuadtariActive
          lda # 255
          sta temp4
CheckQuadtariActive:
          ;; if controllerStatus & SetQuadtariDetected then let temp4 = 255
          lda controllerStatus
          and # SetQuadtariDetected
          beq NoQuadtariActive
          lda # 255
          sta temp4
          jmp QuadtariCheckDone
NoQuadtariActive:
          lda # 0
          sta temp4
QuadtariCheckDone:
          beq ProcessPlayerInput
          lda # 255
          sta temp4
ProcessPlayerInput:



          ;; if temp3 < 2 then goto ProcessPlayerInput          lda temp3          cmp 2          bcs .skip_8959          jmp
          lda temp3
          cmp # 2
          bcs ProcessPlayerInputDone
          goto_label:

          jmp goto_label
ProcessPlayerInputDone:

          lda temp3
          cmp # 2
          bcs CharacterSelectHandleTwoPlayersDone
          jmp goto_label
CharacterSelectHandleTwoPlayersDone:

          

          ;; if controllerStatus & SetQuadtariDetected then goto ProcessPlayerInput

          rts

.pend

ProcessPlayerInput .proc



          ;; Handle Player 1/3 input (joy0)
          jsr HandleCharacterSelectCycle

          jsr HandleCharacterSelectCycle

          ;; NOTE: DASM raises ’Label mismatch’ if multiple banks re-include HandleCharacterSelectFire

          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(AfterSetPlayerLockedJoy0Input-1)
          pha
          lda # <(AfterSetPlayerLockedJoy0Input-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedJoy0Input:


          ;; Cross-bank call to HandleCharacterSelectFire in bank 7
          lda # >(AfterHandleCharacterSelectFireJoy0Input-1)
          pha
          lda # <(AfterHandleCharacterSelectFireJoy0Input-1)
          pha
          lda # >(HandleCharacterSelectFire-1)
          pha
          lda # <(HandleCharacterSelectFire-1)
          pha
                    ldx # 6
          jmp BS_jsr
AfterHandleCharacterSelectFireJoy0Input:




          ;; Handle Player 2/4 input (joy1) - only if active

          rts

          jsr HandleCharacterSelectCycle

          jsr HandleCharacterSelectCycle

          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedJoy1Done:


          ;; Cross-bank call to HandleCharacterSelectFire in bank 7
          lda # >(AfterHandleCharacterSelectFireJoy1Done-1)
          pha
          lda # <(AfterHandleCharacterSelectFireJoy1Done-1)
          pha
          lda # >(HandleCharacterSelectFire-1)
          pha
          lda # <(HandleCharacterSelectFire-1)
          pha
                    ldx # 6
          jmp BS_jsr
AfterHandleCharacterSelectFireJoy1Done:


          rts





CharacterSelectInputComplete

          ;; Handle random character re-rolls if any players need it
          ;; Returns: Far (return otherbank)

          jsr CharacterSelectHandleRandomRolls



          ;; Update character select animations

          ;; Cross-bank call to SelectUpdateAnimations in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SelectUpdateAnimations-1)
          pha
          lda # <(SelectUpdateAnimations-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedRender:


          ;; Draw selection screen

          ;; Draw character selection screen

          ;; Cross-bank call to SelectDrawScreen in bank 6
          lda # >(AfterSelectDrawScreen-1)
          pha
          lda # <(AfterSelectDrawScreen-1)
          pha
          lda # >(SelectDrawScreen-1)
          pha
          lda # <(SelectDrawScreen-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSelectDrawScreen:


          jsr BS_return

          ;;
          ;; Random Character Roll Handler

          ;; Re-roll random selections until valid (0-15), then lock



.pend

CharacterSelectHandleRandomRolls .proc


          ;; Check each player for pending random roll
          ;; Returns: Far (return otherbank)

          lda # 1
          sta temp1
          ;; if controllerStatus & SetQuadtariDetected then let temp1 = 3
          lda controllerStatus
          and # SetQuadtariDetected
          beq NoQuadtariForRandom
          lda # 3
          sta temp1
NoQuadtariForRandom:
          beq CharacterSelectRollRandomPlayer
          lda # 3
          sta temp1
CharacterSelectRollRandomPlayer:

          ;; TODO: #1254 for currentPlayer = 0 to temp1

          jsr CharacterSelectRollRandomPlayer

CharacterSelectRollRandomPlayerReturn:

          jmp CharacterSelectRollsDone

.pend

CharacterSelectRollRandomPlayer .proc




          ;; Handle random character roll for the current player’s slot.
          ;; Returns: Far (return otherbank)

          ;; Requirements: Each frame, if selection is RandomCharacter,

          ;; sample rand & $1f and accept the result when it is < NumCharacters.

          ;; Does NOT lock the character - player must press fire to lock.

          ;;
          ;; Input: currentPlayer (global) = player index (0-3)

          ;; Output: playerCharacter[currentPlayer] updated when roll succeeds

          ;;
          ;; Mutates: temp2, playerCharacter[]

          ;;
          ;; Called Routines: None

.pend

CharacterSelectRollRandomPlayerReroll .proc

          if not valid, try next frame.
          ;; Returns: Far (return otherbank)

          lda rand
          and #$1f
          sta temp2

          ;; Valid roll - character ID updated, but not locked

          jsr BS_return

          lda currentPlayer
          asl
          tax
          lda temp2
          sta playerCharacter,x

          jsr BS_return

CharacterSelectRollsDone

          rts

.pend

CharacterSelectCheckReady .proc

          ;;
          ;; Returns: Far (return otherbank)

          ;; Check If Ready To Proceed

          ;; 2-player mode: P1 must be locked and (P2 locked OR P2 on

          ;; CPU)

          ;; if controllerStatus & SetQuadtariDetected then goto CharacterSelectQuadtariReady

          ;; P1 is locked, check P2

          ;; let temp1 = 0 : gosub GetPlayerLocked bank6
          lda 0
          sta temp1
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(GetPlayerLocked-1)
          pha
          lda # <(GetPlayerLocked-1)
          pha
          ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedP0: : if !temp2 then goto CharacterSelectReadyDone

          ;; P2 not locked, check if on CPU

          ;; ;;           ;; let temp1 = 1 : gosub GetPlayerLocked bank6
          lda # 1
          sta temp1
          lda # >(AfterGetPlayerLockedP1-1)
          pha
          lda # <(AfterGetPlayerLockedP1-1)
          pha
          lda # >(GetPlayerLocked-1)
          pha
          lda # <(GetPlayerLocked-1)
          pha
          ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedP1: : if temp2 then goto CharacterSelectFinish

lda temp2

beq CheckPlayer2Locked

CheckPlayer2Locked:
          jmp CheckPlayer2Locked

          lda temp2

          beq CheckPlayer2CPU

          jmp CheckPlayer2CPU:

          lda temp2

          beq CharacterSelectReadyDone

          jmp CharacterSelectReadyDone:

          ;; if playerCharacter[1] = CPUCharacter then goto CharacterSelectFinish
          jmp CharacterSelectReadyDone



.pend

CharacterSelectQuadtariReady .proc

          ;; 4-player mode: Count players who are ready (locked OR on
          ;; Returns: Far (return otherbank)

          ;; CPU/NO)

          lda # 0
          sta readyCount

          ;; TODO: #1254 for currentPlayer = 0 to 3

          lda currentPlayer
          sta temp1

          ;; Cross-bank call to GetPlayerLocked in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(GetPlayerLocked-1)
          pha
          lda # <(GetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedQuadtariReady:


          ;; if temp2 then goto CharacterSelectQuadtariReadyIncrement
          lda temp2
          beq CheckCPUCharacterQuadtari
          jmp CharacterSelectQuadtariReadyIncrement
CheckCPUCharacterQuadtari:

          ;; let temp4 = playerCharacter[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp4

          lda temp4
          cmp CPUCharacter
          bne CheckNoCharacterQuadtari
          jmp CharacterSelectQuadtariReadyIncrement
CheckNoCharacterQuadtari:


          lda temp4
          cmp NoCharacter
          bne CharacterSelectQuadtariReadyNext
          jmp CharacterSelectQuadtariReadyIncrement
CharacterSelectQuadtariReadyNext:


          jmp CharacterSelectQuadtariReadyNext

CharacterSelectQuadtariReadyIncrement

          inc readyCount

.pend

CharacterSelectQuadtariReadyNext .proc

.pend

CharacterSelectReadyCheck .proc

          ;; if readyCount >= 2 then goto CharacterSelectFinish
          lda readyCount
          cmp # 2

          bcc CharacterSelectReadyDone

          jmp CharacterSelectFinish

CharacterSelectReadyDone:



CharacterSelectReadyDone
          ;; Returns: Far (return otherbank)

          ;; Update sound effects (active sound effects need per-frame updates)
          ;; Cross-bank call to UpdateSoundEffect in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdateSoundEffect-1)
          pha
          lda # <(UpdateSoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterUpdateSoundEffect:


          jsr BS_return

.pend

CharacterSelectFinish .proc

          ;; Finalize selections and transition to falling animation
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: playerCharacter[] (global array) = character selections,

          ;; playerState[] (global array) = facing flags per player

          ;;
          ;; Output: Facing bit set for each active player,

          ;; gameMode set to ModeFallingAnimation

          ;;
          ;; Mutates: playerState[], gameMode

          ;; Initialize facing bit (bit 0) for all selected players

          ;; (default: face right = 1)

          ;; TODO: #1254 for currentPlayer = 0 to 3

          ;; if playerCharacter[currentPlayer] = NoCharacter then goto CharacterSelectSkipFacing
          ;; let playerState[currentPlayer] = playerState[currentPlayer] (no-op, removed)
          lda currentPlayer
          asl
          tax
          lda playerState,x
          lda currentPlayer
          asl
          tax
          sta playerState,x | PlayerStateBitFacing

.pend

CharacterSelectSkipFacing .proc

.pend

UpdateSoundEffects .proc

          ;; Update sound effects (active sound effects need per-frame updates)
          ;; Cross-bank call to UpdateSoundEffect in bank 15
          lda # >(UpdateSoundEffectsReturn-1)
          pha
          lda # <(UpdateSoundEffectsReturn-1)
          pha
          lda # >(UpdateSoundEffect-1)
          pha
          lda # <(UpdateSoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
UpdateSoundEffectsReturn:


          ;; Transition to falling animation

          lda ModeFallingAnimation
          sta gameMode

          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterChangeGameMode:


          rts

.pend

