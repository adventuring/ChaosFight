;;; ChaosFight - Source/Routines/CharacterSelectMain.s

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
          ;; Constraints: Must be colocated with CheckJoy0CharacterSelect,

          ;; CheckJoy0LeftCharacterSelect,

          ;; CheckJoy1LeftCharacterSelect, HandleCharacterSelectCycle


CheckJoy0CharacterSelect .proc

          ;; Check joy0 for players 0,2
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1, temp2 (from

          ;; HandleCharacterSelectCycle)

          ;; joy0left, joy0right (hardware) = joystick sta


          ;;
          ;; Output: Dispatches to CheckJoy0LeftCharacterSelect or HandleCharacterSelectCycle

          ;;
          ;; Mutates: None (dispatcher only)

          ;;
          ;; Called Routines: None (dispatcher only)

          ;;
          ;; Constraints: Must be colocated with

          ;; HandleCharacterSelectCycle

          ;; Players 0,2 use joy0

          lda temp2
          bne HandleCharacterSelectCycle
          jmp CheckJoy0LeftCharacterSelect
HandleCharacterSelectCycle:
           jmp BS_return

.pend

CheckJoy0LeftCharacterSelect .proc

          ;; Check joy0 left button
          ;; Returns: Far (return otherbank)

          ;; Input: joy0left (hardware) = joystick state

          ;; Output: Returns if not pressed, continues to HandleCharacterSelectCycle

          lda joy0left
          bne CheckJoy0LeftPressed
          jmp BS_return
CheckJoy0LeftPressed:

          ;; Constraints: Must be colocated with HandleCharacterSelectCycle

.pend

CheckJoy1LeftCharacterSelect .proc

          ;; Check joy1 left button
          ;; Returns: Far (return otherbank)

          ;; Input: joy1left (hardware) = joystick state

          ;; Output: Returns if not pressed, continues to HandleCharacterSelectCycle

          lda joy1left
          bne CheckJoy1LeftPressed
          jmp BS_return
CheckJoy1LeftPressed:

          ;; Constraints: Must be colocated with HandleCharacterSelectCycle

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

          ;; Set temp1 = playerCharacter[temp4]
          lda temp4
          tax
          lda playerCharacter,x
          sta temp1

          ;; temp3 stores the player index for inline cycling logic

          lda temp4
          sta temp3

          lda temp2
          bne CycleRightCharacterSelect
          jmp CycleLeftCharacterSelect
CycleRightCharacterSelect:


          jmp CycleRightCharacterSelect

.pend

CycleLeftCharacterSelect .proc

          ;; Handle stick-left navigation with ordered wrap logic
          ;; Returns: Far (return otherbank)

          lda temp1
          cmp # RandomCharacter
          bne CheckNoCharacterLeft
          jmp LeftFromRandomCharacterSelect
CheckNoCharacterLeft:


          lda temp1
          cmp # NoCharacter
          bne CheckCPUCharacterLeft
          jmp LeftFromNoOrCPUCharacterSelect
CheckCPUCharacterLeft:


          lda temp1
          cmp # CPUCharacter
          bne CheckZeroLeft
          jmp LeftFromNoOrCPUCharacterSelect
CheckZeroLeft:


          lda temp1
          bne DecrementCharacter
          jmp LeftFromZeroCharacterSelect
DecrementCharacter:


          dec temp1

          jmp CycleDoneCharacterSelect

.pend

LeftFromRandomCharacterSelect .proc

          lda temp3
          bne SetNoCharacterLeft
          ;; Set temp1 = MaxCharacter jmp CycleDoneCharacterSelect
SetNoCharacterLeft:

          jsr GetPlayer2TailCharacterSelect

          lda # NoCharacter
          sta temp1

          jmp CycleDoneCharacterSelect

.pend

LeftFromNoOrCPUCharacterSelect .proc

          lda # MaxCharacter
          sta temp1

          jmp CycleDoneCharacterSelect

.pend

LeftFromZeroCharacterSelect .proc

          lda # RandomCharacter
          sta temp1

          jmp CycleDoneCharacterSelect

.pend

CycleRightCharacterSelect .proc

          ;; Handle stick-right navigation with ordered wrap logic
          ;; Returns: Far (return otherbank)

          lda temp1
          cmp # RandomCharacter
          bne CheckNoCharacterRight
          jmp RightFromRandomCharacterSelect
CheckNoCharacterRight:


          lda temp1
          cmp # NoCharacter
          bne CheckCPUCharacterRight
          jmp RightFromNoOrCPUCharacterSelect
CheckCPUCharacterRight:


          lda temp1
          cmp # CPUCharacter
          bne CheckMaxCharacterRight
          jmp RightFromNoOrCPUCharacterSelect
CheckMaxCharacterRight:


          lda temp1
          cmp # MaxCharacter
          bne IncrementCharacter
          jmp RightFromMaxCharacterSelect
IncrementCharacter:


          inc temp1

          jmp CycleDoneCharacterSelect

.pend

RightFromRandomCharacterSelect .proc

          lda # 0
          sta temp1

          jmp CycleDoneCharacterSelect

.pend

RightFromNoOrCPUCharacterSelect .proc

          lda # RandomCharacter
          sta temp1

          jmp CycleDoneCharacterSelect

.pend

RightFromMaxCharacterSelect .proc

          lda temp3
          bne SetNoCharacterRight
          ;; Set temp1 = RandomCharacter jmp CycleDoneCharacterSelect
SetNoCharacterRight:

          jsr GetPlayer2TailCharacterSelect

          lda # NoCharacter
          sta temp1

          jmp CycleDoneCharacterSelect

.pend

GetPlayer2TailCharacterSelect .proc


          ;; Determine whether Player 2 wraps to CPU or NO
          ;; Returns: Far (return otherbank)

          lda # CPUCharacter
          sta temp6

          ;; if playerCharacter[2] = NoCharacter then jmp P2TailCheckP4CharacterSelect
          lda # NoCharacter
          sta temp6

          jmp P2TailDoneCharacterSelect

.pend

P2TailCheckP4CharacterSelect .proc

          ;; if playerCharacter[3] = NoCharacter then jmp P2TailDoneCharacterSelect
          lda # NoCharacter
          sta temp6

P2TailDoneCharacterSelect:

          rts

CycleDoneCharacterSelect

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
          tax
          lda temp1
          sta playerCharacter,x

          lda #PlayerLockedUnlocked
          sta temp2

          lda temp3
          sta temp1

          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(AfterSetPlayerLocked-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLocked hi (encoded)]
          lda # <(AfterSetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLocked hi (encoded)] [SP+0: AfterSetPlayerLocked lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLocked hi (encoded)] [SP+1: AfterSetPlayerLocked lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLocked hi (encoded)] [SP+2: AfterSetPlayerLocked lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLocked:


          ;; Play navigation sound

          lda # SoundMenuNavigate
          sta temp1

          ;; Cross-bank call to PlaySoundEffect in bank 14
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(AfterPlaySoundEffectNav-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlaySoundEffectNav hi (encoded)]
          lda # <(AfterPlaySoundEffectNav-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlaySoundEffectNav hi (encoded)] [SP+0: AfterPlaySoundEffectNav lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlaySoundEffectNav hi (encoded)] [SP+1: AfterPlaySoundEffectNav lo] [SP+0: PlaySoundEffect hi (raw)]
          lda # <(PlaySoundEffect-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlaySoundEffectNav hi (encoded)] [SP+2: AfterPlaySoundEffectNav lo] [SP+1: PlaySoundEffect hi (raw)] [SP+0: PlaySoundEffect lo]
          ldx # 14
          jmp BS_jsr
AfterPlaySoundEffectNav:


          jmp BS_return

.pend

CharacterSelectInputEntry .proc




          ;; Cross-bank call to CharacterSelectDoRescan in bank 5
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(AfterControllerRescan-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterControllerRescan hi (encoded)]
          lda # <(AfterControllerRescan-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterControllerRescan hi (encoded)] [SP+0: AfterControllerRescan lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CharacterSelectDoRescan-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterControllerRescan hi (encoded)] [SP+1: AfterControllerRescan lo] [SP+0: CharacterSelectDoRescan hi (raw)]
          lda # <(CharacterSelectDoRescan-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterControllerRescan hi (encoded)] [SP+2: AfterControllerRescan lo] [SP+1: CharacterSelectCheckControllerRescan hi (raw)] [SP+0: CharacterSelectCheckControllerRescan lo]
          ldx # 5
          jmp BS_jsr
AfterControllerRescan:




          ;; Consolidated input handling with Quadtari multiplexing
          ;; Returns: Far (return otherbank)

          lda # 0
          sta temp3

          ;; Player offset: 0=P1/P2, 2=P3/P4

          ;; If controllerStatus & SetQuadtariDetected, then set temp3 = qtcontroller * 2
          lda controllerStatus
          and # SetQuadtariDetected
          beq SetTemp3TwoPlayer
          lda qtcontroller
          asl
          sta temp3
          jmp CharacterSelectHandleQuadtari
SetTemp3TwoPlayer:
          lda # 0
          sta temp3
CharacterSelectHandleQuadtari:
          jsr CharacterSelectHandleTwoPlayers

          ;; If controllerStatus & SetQuadtariDetected, then set qtcontroller = qtcontroller ^ 1, else qtcontroller = 0
          lda controllerStatus
          and # SetQuadtariDetected
          beq SetQtControllerZero
          lda qtcontroller
          eor # 1
          sta qtcontroller
          jmp CharacterSelectInputComplete
SetQtControllerZero:
          lda # 0
          sta qtcontroller
          jmp CharacterSelectInputComplete



CharacterSelectHandleTwoPlayers




          ;; Handle input for two players (P1/P2 or P3/P4 based on temp3)
          ;; Returns: Far (return otherbank)

          ;; temp3 = player offset (0 or 2)



          ;; Check if second player should be active (Quadtari)

          lda # 0
          sta temp4

          lda temp3
          bne CheckQuadtariActive
          lda # 255
          sta temp4
CheckQuadtariActive:
          ;; If controllerStatus & SetQuadtariDetected, set temp4 = 255
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



          ;; if temp3 < 2 then jmp ProcessPlayerInput          lda temp3          cmp 2          bcs .skip_8959          jmp
          lda temp3
          cmp # 2
          bcs ProcessPlayerInputDone
          jsr ProcessPlayerInput
ProcessPlayerInputDone:

          lda temp3
          cmp # 2
          bcs CharacterSelectHandleTwoPlayersDone
          lda controllerStatus
          and # SetQuadtariDetected
          beq CharacterSelectHandleTwoPlayersDone
          jsr ProcessPlayerInput
CharacterSelectHandleTwoPlayersDone:

          

          ;; if controllerStatus & SetQuadtariDetected then jmp ProcessPlayerInput

          rts

.pend

ProcessPlayerInput .proc



          ;; Handle Player 1/3 input (joy0)
          jsr HandleCharacterSelectCycle

          jsr HandleCharacterSelectCycle

          ;; NOTE: DASM raises ’Label mismatch’ if multiple banks re-include HandleCharacterSelectFire

          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedJoy0Input-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedJoy0Input hi (encoded)]
          lda # <(AfterSetPlayerLockedJoy0Input-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedJoy0Input hi (encoded)] [SP+0: AfterSetPlayerLockedJoy0Input lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedJoy0Input hi (encoded)] [SP+1: AfterSetPlayerLockedJoy0Input lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedJoy0Input hi (encoded)] [SP+2: AfterSetPlayerLockedJoy0Input lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedJoy0Input:


          ;; Cross-bank call to HandleCharacterSelectFire in bank 6
          ;; Return address: ENCODED with caller bank 8 ($80) for BS_return to decode
          lda # ((>(AfterHandleCharacterSelectFireJoy0Input-1)) & $0f) | $80  ;;; Encode bank 8 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterHandleCharacterSelectFireJoy0Input hi (encoded)]
          lda # <(AfterHandleCharacterSelectFireJoy0Input-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterHandleCharacterSelectFireJoy0Input hi (encoded)] [SP+0: AfterHandleCharacterSelectFireJoy0Input lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(HandleCharacterSelectFire-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterHandleCharacterSelectFireJoy0Input hi (encoded)] [SP+1: AfterHandleCharacterSelectFireJoy0Input lo] [SP+0: HandleCharacterSelectFire hi (raw)]
          lda # <(HandleCharacterSelectFire-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterHandleCharacterSelectFireJoy0Input hi (encoded)] [SP+2: AfterHandleCharacterSelectFireJoy0Input lo] [SP+1: HandleCharacterSelectFire hi (raw)] [SP+0: HandleCharacterSelectFire lo]
          ldx # 6
          jmp BS_jsr
AfterHandleCharacterSelectFireJoy0Input:




          ;; Handle Player 2/4 input (joy1) - only if active

          rts

.pend
