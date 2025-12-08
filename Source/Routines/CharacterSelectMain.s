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

          ;; jmp HandleCharacterSelectCycle (duplicate)

.pend

HCSC_CheckJoy0Left .proc

          ;; Check joy0 left button
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: joy0left (hardware) = joystick sta


          ;;
          ;; Output: Returns if not pressed, continues to HandleCharacterSelectCycle

          ;; if pressed

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with HandleCharacterSelectCycle

          ;; jsr BS_return (duplicate)

.pend

HCSC_CheckJoy1Left .proc

          ;; Check joy1 left button
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: joy1left (hardware) = joystick sta


          ;;
          ;; Output: Returns if not pressed, continues to HandleCharacterSelectCycle

          ;; if pressed

          ;;
          ;; Mutates: None

          ;;
          ;; Called Routines: None

          ;; Constraints: Must be colocated with HandleCharacterSelectCycle

          ;; jsr BS_return (duplicate)

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

          ;; lda temp1 (duplicate)
          sta temp4

          ;; Load current character selection

                    ;; let temp1 = playerCharacter[temp4]         
          ;; lda temp4 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp1 (duplicate)

          ;; temp3 stores the player index for inline cycling logic

          ;; lda temp4 (duplicate)
          ;; sta temp3 (duplicate)

          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_796 (duplicate)
          ;; jmp HCSC_CycleLeft (duplicate)
skip_796:


          ;; jmp HCSC_CycleRight (duplicate)

.pend

HCSC_CycleLeft .proc

          ;; Handle stick-left navigation with ordered wrap logic
          ;; Returns: Far (return otherbank)

          ;; lda temp1 (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_7839 (duplicate)
          ;; jmp HCSC_LeftFromRandom (duplicate)
skip_7839:


          ;; lda temp1 (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_1366 (duplicate)
          ;; jmp HCSC_LeftFromNoOrCPU (duplicate)
skip_1366:


          ;; lda temp1 (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_4773 (duplicate)
          ;; jmp HCSC_LeftFromNoOrCPU (duplicate)
skip_4773:


          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_7522 (duplicate)
          ;; jmp HCSC_LeftFromZero (duplicate)
skip_7522:


          dec temp1

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_LeftFromRandom .proc

          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6262 (duplicate)
                    ;; let temp1 = MaxCharacter : goto HCSC_CycleDone
skip_6262:

          ;; jsr HCSC_GetPlayer2Tail (duplicate)

          ;; lda NoCharacter (duplicate)
          ;; sta temp1 (duplicate)

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_LeftFromNoOrCPU .proc

          ;; lda MaxCharacter (duplicate)
          ;; sta temp1 (duplicate)

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_LeftFromZero .proc

          ;; lda RandomCharacter (duplicate)
          ;; sta temp1 (duplicate)

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_CycleRight .proc

          ;; Handle stick-right navigation with ordered wrap logic
          ;; Returns: Far (return otherbank)

          ;; lda temp1 (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_9498 (duplicate)
          ;; jmp HCSC_RightFromRandom (duplicate)
skip_9498:


          ;; lda temp1 (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_8767 (duplicate)
          ;; jmp HCSC_RightFromNoOrCPU (duplicate)
skip_8767:


          ;; lda temp1 (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_8806 (duplicate)
          ;; jmp HCSC_RightFromNoOrCPU (duplicate)
skip_8806:


          ;; lda temp1 (duplicate)
          ;; cmp MaxCharacter (duplicate)
          ;; bne skip_1541 (duplicate)
          ;; jmp HCSC_RightFromMax (duplicate)
skip_1541:


          inc temp1

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_RightFromRandom .proc

          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_RightFromNoOrCPU .proc

          ;; lda RandomCharacter (duplicate)
          ;; sta temp1 (duplicate)

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_RightFromMax .proc

          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3297 (duplicate)
                    ;; let temp1 = RandomCharacter : goto HCSC_CycleDone
skip_3297:

          ;; jsr HCSC_GetPlayer2Tail (duplicate)

          ;; lda NoCharacter (duplicate)
          ;; sta temp1 (duplicate)

          ;; jmp HCSC_CycleDone (duplicate)

.pend

HCSC_GetPlayer2Tail .proc


          ;; Determine whether Player 2 wraps to CPU or NO
          ;; Returns: Far (return otherbank)

          ;; lda CPUCharacter (duplicate)
          ;; sta temp6 (duplicate)

                    ;; if playerCharacter[2] = NoCharacter then goto HCSC_P2TailCheckP4
          ;; lda NoCharacter (duplicate)
          ;; sta temp6 (duplicate)

          ;; jmp HCSC_P2TailDone (duplicate)

.pend

HCSC_P2TailCheckP4 .proc

                    ;; if playerCharacter[3] = NoCharacter then goto HCSC_P2TailDone
          ;; lda NoCharacter (duplicate)
          ;; sta temp6 (duplicate)

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

          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta playerCharacter,x (duplicate)

          ;; lda PlayerLockedUnlocked (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Cross-bank call to SetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 5
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; Play navigation sound

          ;; lda SoundMenuNavigate (duplicate)
          ;; sta temp1 (duplicate)

          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

.pend

CharacterSelectInputEntry .proc




          ;; Cross-bank call to CharacterSelectCheckControllerRescan in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CharacterSelectCheckControllerRescan-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CharacterSelectCheckControllerRescan-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)




          ;; Consolidated input handling with Quadtari multiplexing
          ;; Returns: Far (return otherbank)

          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

          ;; Player offset: 0=P1/P2, 2=P3/P4

                    ;; if controllerStatus & SetQuadtariDetected then let temp3 = qtcontroller * 2
          ;; jsr CharacterSelectHandleTwoPlayers (duplicate)



                    ;; if controllerStatus & SetQuadtariDetected then let qtcontroller = qtcontroller ^ 1 else qtcontroller = 0
          ;; jmp CharacterSelectInputComplete (duplicate)



CharacterSelectHandleTwoPlayers
          ;; Returns: Far (return thisbank)


;; CharacterSelectHandleTwoPlayers (duplicate)




          ;; Handle input for two players (P1/P2 or P3/P4 based on temp3)
          ;; Returns: Far (return otherbank)

          ;; temp3 = player offset (0 or 2)



          ;; Check if second player should be active (Quadtari)

          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3522 (duplicate)
          ;; lda # 255 (duplicate)
          ;; sta temp4 (duplicate)
skip_3522:


                    ;; if controllerStatus & SetQuadtariDetected then let temp4 = 255
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          beq skip_4497
          ;; lda # 255 (duplicate)
          ;; sta temp4 (duplicate)
skip_4497:



          ;; ;; if temp3 < 2 then goto ProcessPlayerInput          lda temp3          cmp 2          bcs .skip_8959          jmp
          ;; lda temp3 (duplicate)
          ;; cmp # 2 (duplicate)
          bcs skip_928
          goto_label:

          ;; jmp goto_label (duplicate)
skip_928:

          ;; lda temp3 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bcs skip_5440 (duplicate)
          ;; jmp goto_label (duplicate)
skip_5440:

          

                    ;; if controllerStatus & SetQuadtariDetected then goto ProcessPlayerInput

          ;; rts (duplicate)

.pend

ProcessPlayerInput .proc



          ;; Handle Player 1/3 input (joy0)
          ;; jsr HandleCharacterSelectCycle (duplicate)

          ;; jsr HandleCharacterSelectCycle (duplicate)

          ;; NOTE: DASM raises ’Label mismatch’ if multiple banks re-include HandleCharacterSelectFire

          ;; Cross-bank call to SetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to HandleCharacterSelectFire in bank 7
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 6 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)




          ;; Handle Player 2/4 input (joy1) - only if active

          ;; rts (duplicate)

          ;; jsr HandleCharacterSelectCycle (duplicate)

          ;; jsr HandleCharacterSelectCycle (duplicate)

          ;; Cross-bank call to SetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to HandleCharacterSelectFire in bank 7
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 6 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; rts (duplicate)





CharacterSelectInputComplete

          ;; Handle random character re-rolls if any players need it
          ;; Returns: Far (return otherbank)

          ;; jsr CharacterSelectHandleRandomRolls (duplicate)



          ;; Update character select animations

          ;; Cross-bank call to SelectUpdateAnimations in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SelectUpdateAnimations-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SelectUpdateAnimations-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Draw selection screen

          ;; Draw character selection screen

          ;; Cross-bank call to SelectDrawScreen in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SelectDrawScreen-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SelectDrawScreen-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

          ;;
          ;; Random Character Roll Handler

          ;; Re-roll random selections until valid (0-15), then lock



.pend

CharacterSelectHandleRandomRolls .proc


          ;; Check each player for pending random roll
          ;; Returns: Far (return otherbank)

          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)

                    ;; if controllerStatus & SetQuadtariDetected then let temp1 = 3
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; beq skip_9782 (duplicate)
          ;; lda # 3 (duplicate)
          ;; sta temp1 (duplicate)
skip_9782:

          ;; TODO: for currentPlayer = 0 to temp1

          ;; jsr CharacterSelectRollRandomPlayer (duplicate)

.pend

next_label_1_L793:.proc

          ;; jmp CharacterSelectRollsDone (duplicate)



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

          ;; if not valid, try next frame.
          ;; Returns: Far (return otherbank)

          ;; lda rand (duplicate)
          ;; and #$1f (duplicate)
          ;; sta temp2 (duplicate)

          ;; Valid roll - character ID updated, but not locked

          ;; jsr BS_return (duplicate)

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerCharacter,x (duplicate)

          ;; jsr BS_return (duplicate)

CharacterSelectRollsDone

          ;; rts (duplicate)

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
          ;; lda 0 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: : if !temp2 then goto CharacterSelectReadyDone (duplicate)

          ;; P2 not locked, check if on CPU

          ;; ;; ;;           ;; let temp1 = 1 : gosub GetPlayerLocked bank6
          ;; lda 1 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: : if temp2 then goto CharacterSelectFinish (duplicate)

;; lda temp2 (duplicate)

;; beq skip_3576 (duplicate)

skip_3576:
          ;; jmp skip_3576 (duplicate)

          ;; lda temp2 (duplicate)

          ;; beq skip_8138 (duplicate)

          ;; jmp skip_8138: (duplicate)

          ;; lda temp2 (duplicate)

          ;; beq skip_9851 (duplicate)

          ;; jmp skip_9851: (duplicate)

                    ;; if playerCharacter[1] = CPUCharacter then goto CharacterSelectFinish
          ;; jmp CharacterSelectReadyDone (duplicate)



.pend

CharacterSelectQuadtariReady .proc

          ;; 4-player mode: Count players who are ready (locked OR on
          ;; Returns: Far (return otherbank)

          ;; CPU/NO)

          ;; lda # 0 (duplicate)
          ;; sta readyCount (duplicate)

          ;; TODO: for currentPlayer = 0 to 3

          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

          ;; Cross-bank call to GetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp2 then goto CharacterSelectQuadtariReadyIncrement
          ;; lda temp2 (duplicate)
          ;; beq skip_6413 (duplicate)
          ;; jmp CharacterSelectQuadtariReadyIncrement (duplicate)
skip_6413:

                    ;; let temp4 = playerCharacter[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp4 (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_46 (duplicate)
          ;; jmp CharacterSelectQuadtariReadyIncrement (duplicate)
skip_46:


          ;; lda temp4 (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_5848 (duplicate)
          ;; jmp CharacterSelectQuadtariReadyIncrement (duplicate)
skip_5848:


          ;; jmp CharacterSelectQuadtariReadyNext (duplicate)

CharacterSelectQuadtariReadyIncrement

          ;; inc readyCount (duplicate)

.pend

CharacterSelectQuadtariReadyNext .proc

.pend

next_label_2_1_L997:.proc

          ;; if readyCount >= 2 then goto CharacterSelectFinish
          ;; lda readyCount (duplicate)
          ;; cmp 2 (duplicate)

          bcc skip_5488

          ;; jmp skip_5488 (duplicate)

          skip_5488:



CharacterSelectReadyDone
          ;; Returns: Far (return otherbank)

          ;; Update sound effects (active sound effects need per-frame updates)
          ;; Cross-bank call to UpdateSoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdateSoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdateSoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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

                    ;; let playerState[currentPlayer] = playerState[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerState,x | PlayerStateBitFacing (duplicate)

.pend

CharacterSelectSkipFacing .proc

.pend

next_label_3 .proc



          ;; Update sound effects (active sound effects need per-frame updates)
          ;; Cross-bank call to UpdateSoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdateSoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdateSoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Transition to falling animation

          ;; lda ModeFallingAnimation (duplicate)
          ;; sta gameMode (duplicate)

          ;; Cross-bank call to ChangeGameMode in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; rts (duplicate)

.pend

