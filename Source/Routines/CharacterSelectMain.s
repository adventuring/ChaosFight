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
          bne skip_6419
          jmp HCSC_CheckJoy0Left
skip_6419:


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
          bne skip_796
          jmp HCSC_CycleLeft
skip_796:


          jmp HCSC_CycleRight

.pend

HCSC_CycleLeft .proc

          ;; Handle stick-left navigation with ordered wrap logic
          ;; Returns: Far (return otherbank)

          lda temp1
          cmp RandomCharacter
          bne skip_7839
          jmp HCSC_LeftFromRandom
skip_7839:


          lda temp1
          cmp NoCharacter
          bne skip_1366
          jmp HCSC_LeftFromNoOrCPU
skip_1366:


          lda temp1
          cmp CPUCharacter
          bne skip_4773
          jmp HCSC_LeftFromNoOrCPU
skip_4773:


          lda temp1
          cmp # 0
          bne skip_7522
          jmp HCSC_LeftFromZero
skip_7522:


          dec temp1

          jmp HCSC_CycleDone

.pend

HCSC_LeftFromRandom .proc

          lda temp3
          cmp # 0
          bne skip_6262
          ;; let temp1 = MaxCharacter : goto HCSC_CycleDone
skip_6262:

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
          bne skip_9498
          jmp HCSC_RightFromRandom
skip_9498:


          lda temp1
          cmp NoCharacter
          bne skip_8767
          jmp HCSC_RightFromNoOrCPU
skip_8767:


          lda temp1
          cmp CPUCharacter
          bne skip_8806
          jmp HCSC_RightFromNoOrCPU
skip_8806:


          lda temp1
          cmp MaxCharacter
          bne skip_1541
          jmp HCSC_RightFromMax
skip_1541:


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
          bne skip_3297
          ;; let temp1 = RandomCharacter : goto HCSC_CycleDone
skip_3297:

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
return_point:


          ;; Play navigation sound

          lda SoundMenuNavigate
          sta temp1

          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
return_point:


          jsr BS_return

.pend

CharacterSelectInputEntry .proc




          ;; Cross-bank call to CharacterSelectCheckControllerRescan in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CharacterSelectCheckControllerRescan-1)
          pha
          lda # <(CharacterSelectCheckControllerRescan-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:




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
          bne skip_3522
          lda # 255
          sta temp4
skip_3522:


                    if controllerStatus & SetQuadtariDetected then let temp4 = 255
          lda controllerStatus
          and SetQuadtariDetected
          beq skip_4497
          lda # 255
          sta temp4
skip_4497:



          ;; if temp3 < 2 then goto ProcessPlayerInput          lda temp3          cmp 2          bcs .skip_8959          jmp
          lda temp3
          cmp # 2
          bcs skip_928
          goto_label:

          jmp goto_label
skip_928:

          lda temp3
          cmp # 2
          bcs skip_5440
          jmp goto_label
skip_5440:

          

          ;; if controllerStatus & SetQuadtariDetected then goto ProcessPlayerInput

          rts

.pend

ProcessPlayerInput .proc



          ;; Handle Player 1/3 input (joy0)
          jsr HandleCharacterSelectCycle

          jsr HandleCharacterSelectCycle

          ;; NOTE: DASM raises ’Label mismatch’ if multiple banks re-include HandleCharacterSelectFire

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
return_point:


          ;; Cross-bank call to HandleCharacterSelectFire in bank 7
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(HandleCharacterSelectFire-1)
          pha
          lda # <(HandleCharacterSelectFire-1)
          pha
                    ldx # 6
          jmp BS_jsr
return_point:




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
return_point:


          ;; Cross-bank call to HandleCharacterSelectFire in bank 7
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(HandleCharacterSelectFire-1)
          pha
          lda # <(HandleCharacterSelectFire-1)
          pha
                    ldx # 6
          jmp BS_jsr
return_point:


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
return_point:


          ;; Draw selection screen

          ;; Draw character selection screen

          ;; Cross-bank call to SelectDrawScreen in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SelectDrawScreen-1)
          pha
          lda # <(SelectDrawScreen-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


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

                    if controllerStatus & SetQuadtariDetected then let temp1 = 3
          lda controllerStatus
          and SetQuadtariDetected
          beq skip_9782
          lda # 3
          sta temp1
skip_9782:

          ;; TODO: for currentPlayer = 0 to temp1

          jsr CharacterSelectRollRandomPlayer

.pend

next_label_1_L793:.proc

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
return_point: : if !temp2 then goto CharacterSelectReadyDone

          ;; P2 not locked, check if on CPU

          ;; ;;           ;; let temp1 = 1 : gosub GetPlayerLocked bank6
          lda 1
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
return_point: : if temp2 then goto CharacterSelectFinish

lda temp2

beq skip_3576

skip_3576:
          jmp skip_3576

          lda temp2

          beq skip_8138

          jmp skip_8138:

          lda temp2

          beq skip_9851

          jmp skip_9851:

          ;; if playerCharacter[1] = CPUCharacter then goto CharacterSelectFinish
          jmp CharacterSelectReadyDone



.pend

CharacterSelectQuadtariReady .proc

          ;; 4-player mode: Count players who are ready (locked OR on
          ;; Returns: Far (return otherbank)

          ;; CPU/NO)

          lda # 0
          sta readyCount

          ;; TODO: for currentPlayer = 0 to 3

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
return_point:


          ;; if temp2 then goto CharacterSelectQuadtariReadyIncrement
          lda temp2
          beq skip_6413
          jmp CharacterSelectQuadtariReadyIncrement
skip_6413:

          ;; let temp4 = playerCharacter[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp4

          lda temp4
          cmp CPUCharacter
          bne skip_46
          jmp CharacterSelectQuadtariReadyIncrement
skip_46:


          lda temp4
          cmp NoCharacter
          bne skip_5848
          jmp CharacterSelectQuadtariReadyIncrement
skip_5848:


          jmp CharacterSelectQuadtariReadyNext

CharacterSelectQuadtariReadyIncrement

          inc readyCount

.pend

CharacterSelectQuadtariReadyNext .proc

.pend

next_label_2_1_L997:.proc

          ;; if readyCount >= 2 then goto CharacterSelectFinish
          lda readyCount
          cmp 2

          bcc skip_5488

          jmp skip_5488

          skip_5488:



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
return_point:


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

          ;; TODO: for currentPlayer = 0 to 3

          ;; if playerCharacter[currentPlayer] = NoCharacter then goto CharacterSelectSkipFacing

                    let playerState[currentPlayer] = playerState[currentPlayer]
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

next_label_3 .proc



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
return_point:


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
return_point:


          rts

.pend

