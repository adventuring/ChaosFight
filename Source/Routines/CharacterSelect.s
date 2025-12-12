;;; ChaosFight - Source/Routines/CharacterSelect.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CharacterSelectEntry .proc
          ;; Initializes character select screen sta

          ;; Notes: PlayerLockedHelpers.bas resides in Bank 6
          ;;
          ;; Input: None (entry point)
          ;;
          ;; Output: playerCharacter[] initialized, playerLocked
          ;; initialized, animation state initialized,
          ;; COLUBK set, Quadtari detection called
          ;;
          ;; Mutates: playerCharacter[0-3] (set to 0), playerLocked (set to
          ;; 0), characterSelectAnimationTimer,
          ;; characterSelectAnimationState, characterSelectCharacterIndex,
          ;; characterSelectAnimationFrame, COLUBK (TIA register)
          ;;
          ;; Called Routines: CharacterSelectDetectQuadtari - accesses controller
          ;; detection sta

          ;;
          ;; Constraints: Entry point for character select screen
          ;; initialization
          ;; Must be colocated with CharacterSelectLoop (called
          ;; via goto)
          ;; Initialize character selections
          lda # 0
          asl
          tax
          lda # CharacterBernie
          sta playerCharacter,x
          lda # 1
          asl
          tax
          lda # CharacterBernie
          sta playerCharacter,x
          lda # 2
          asl
          tax
          lda # CharacterBernie
          sta playerCharacter,x
          lda # 3
          asl
          tax
          lda # CharacterBernie
          sta playerCharacter,x
          ;; Initialize playerLocked (bit-packed, all unlocked)
          lda # 0
          sta playerLocked
          ;; NOTE: Do NOT clear controllerStatus flags here - monotonic
          ;; detection (upgrades only)
          ;; Controller detection is handled by DetectPads with
          ;; monotonic state machine

          ;; Initialize character select animations
          lda # 0
          sta characterSelectAnimationTimer
          lda # 0
          sta characterSelectAnimationState
          ;; Start with idle animation
          lda # 0
          sta characterSelectCharacterIndex_W
          ;; Start with first character
          lda # 0
          sta characterSelectAnimationFrame

          ;; Check for Quadtari adapter (inlined for performance)
          ;; CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          ;; Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) and Right (INPT2 LOW, INPT3 HIGH)
          ;; If INPT0{7} is set, Quadtari absent
          bit INPT0
          bpl CheckINPT1
          jmp CharacterSelectQuadtariAbsent
CheckINPT1:

          ;; If !INPT1{7}, Quadtari absent
          bit INPT1
          bmi CheckINPT2
          jmp CharacterSelectQuadtariAbsent

CheckINPT2:

          ;; If INPT2{7} is set, Quadtari absent
          bit INPT2
          bpl CheckINPT3
          jmp CharacterSelectQuadtariAbsent
CheckINPT3:

          ;; All checks passed - Quadtari detected
          ;; If !INPT3{7}, Quadtari absent
          bit INPT3
          bmi SetQuadtariDetected
          jmp CharacterSelectQuadtariAbsent
SetQuadtariDetected:
          lda controllerStatus
          ora # SetQuadtariDetected
          sta controllerStatus

.pend

CharacterSelectLoop .proc
          ;; Per-frame character select screen loop with Quadtari
          ;; multiplexing
          ;;
          ;; Input: qtcontroller (global) = Quadtari controller frame
          ;; toggle
          ;; joy0left, joy0right, joy0up, joy0down, joy0fire
          ;; (hardware) = Player 1/3 joystick
          ;; joy1left, joy1right, joy1up, joy1down, joy1fire
          ;; (hardware) = Player 2/4 joystick
          ;; playerCharacter[] (global array) = current character
          ;; selections
          ;; playerLocked (global) = player lock sta

          ;; MaxCharacter (constant) = maximum character index
          ;;
          ;; Output: Dispatches to CharacterSelectHandleQuadtari or processes even
          ;; frame input, then returns
          ;;
          ;; Mutates: qtcontroller (toggled), playerCharacter[],
          ;; playerLocked state, temp1, temp2 (passed to
          ;; SetPlayerLocked)
          ;;
          ;; Called Routines: SetPlayerLocked (bank6) - accesses
          ;; playerLocked sta

          ;;
          ;; Constraints: Must be colocated with SelectStickLeft,
          ;; SelectStickRight, HandleCharacterSelectPlayerInput,
          ;; CharacterSelectHandleQuadtari
          ;; Entry point for character select screen loop
          ;; Quadtari controller multiplexing:
          ;; On even frames (qtcontroller=0): handle controllers 0 and
          ;; 1
          ;; On odd frames (qtcontroller=1): handle controllers 2 and 3
          ;; (if Quadtari detected)
          ;; if qtcontroller then jmp CharacterSelectHandleQuadtari
          lda qtcontroller
          beq HandleEvenFrameInput
          jmp CharacterSelectHandleQuadtari
HandleEvenFrameInput:

          ;; Handle Player 1 input (joy0 on even frames)
          lda # 0
          sta temp1
          jsr HandleCharacterSelectPlayerInput

          ;; Handle Player 2 input (joy1 on even frames)
          lda # 1
          sta temp1
          jsr HandleCharacterSelectPlayerInput

          ;; Switch to odd frame mode for next iteration
          qtcontroller = 1
          jmp CharacterSelectHandleComplete

.pend

CharacterSelectHandleQuadtari .proc
          ;; Handle Player 3 input (joy0 on odd frames, Quadtari only)
                    if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer3
          jmp CharacterSelectHandleQuadtariDone

.pend

CharacterSelectHandlePlayer3 .proc
          ;; Handle Player 3 input (joy0 on odd frames, Quadtari only)
          lda # 2
          sta temp1
          jsr HandleCharacterSelectPlayerInput

          ;; Handle Player 4 input (joy1 on odd frames, Quadtari only)
                    if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer4
          jmp CharacterSelectHandleQuadtariDone

.pend

CharacterSelectHandlePlayer4 .proc
          lda # 3
          sta temp1
          jsr HandleCharacterSelectPlayerInput

CharacterSelectHandleQuadtariDone
          ;; Switch back to even frame mode for next iteration
          qtcontroller = 0

.pend

SelectStickLeft .proc
          ;; Handle stick-left navigation for the active player
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerCharacter[] (global) = browsing selections
          ;; Output: playerCharacter[currentPlayer] decremented with wrap
          ;; to MaxCharacter, lock state cleared on wrap
          ;; Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          ;; SetPlayerLocked)
          ;; Called Routines: SetPlayerLocked (bank6)
          ;; Constraints: currentPlayer must be set by caller
          ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] - 1
          lda currentPlayer
          asl
          tax
          dec playerCharacter,x

          lda currentPlayer
          asl
          tax
          dec playerCharacter,x

          ;; If playerCharacter[currentPlayer] > MaxCharacter, then set playerCharacter[currentPlayer] = MaxCharacter
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          cmp # MaxCharacter
          bcc CheckMaxCharacterDone
          lda # MaxCharacter
          sta playerCharacter,x
CheckMaxCharacterDone:

          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(AfterSetPlayerLockedStickLeft-1)
          pha
          lda # <(AfterSetPlayerLockedStickLeft-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedStickLeft:


          rts

.pend

SelectStickRight .proc
          ;; Handle stick-right navigation for the active player
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerCharacter[] (global) = browsing selections
          ;; Output: playerCharacter[currentPlayer] incremented with wrap
          ;; to 0, lock state cleared on wrap
          ;; Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          ;; SetPlayerLocked)
          ;; Called Routines: SetPlayerLocked (bank6)
          ;; Constraints: currentPlayer must be set by caller
          ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] + 1
          lda currentPlayer
          asl
          tax
          inc playerCharacter,x

          lda currentPlayer
          asl
          tax
          inc playerCharacter,x

                    if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = CharacterBernie

          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(AfterSetPlayerLockedStickRight-1)
          pha
          lda # <(AfterSetPlayerLockedStickRight-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedStickRight:


          rts

CharacterSelectHandleComplete
          ;; Check if all players are ready to start (inline
          ;; SelAllReady)
          lda # 0
          sta readyCount

          ;; Count locked players
          inc readyCount

          inc readyCount

                    if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariPlayersInline
          jmp CharacterSelectDoneQuadtariPlayersInline

.pend

CharacterSelectQuadtariPlayersInline .proc
          inc readyCount

          inc readyCount

CharacterSelectDoneQuadtariPlayersInline
          ;; Check if enough players are ready
                    if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariReadyInline

          ;; Need at least 1 player ready for 2-player mode
          ;; ;;           ;; Set temp1 = 0 cross-bank call to GetPlayerLocked bank6
          lda # 0
          sta temp1
          lda # >(AfterGetPlayerLockedCheckReady-1)
          pha
          lda # <(AfterGetPlayerLockedCheckReady-1)
          pha
          lda # >(GetPlayerLocked-1)
          pha
          lda # <(GetPlayerLocked-1)
          pha
          ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedCheckReady:
          ;; If temp2 then jmp CharacterSelectCompleted
          lda temp2
          beq CheckPlayer2Locked
          jmp CharacterSelectCompleted

CheckPlayer2Locked:

          ;; Set temp1 = 1
          ;; Cross-bank call to GetPlayerLocked bank6
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

AfterGetPlayerLockedP1:
          ;; If temp2 then jmp CharacterSelectCompleted
          lda temp2
          beq CharacterSelectDoneQuadtariReadyInline
          jmp CharacterSelectCompleted

CharacterSelectDoneQuadtariReadyInline:

.pend

CharacterSelectQuadtariReadyInline .proc
          ;; Need at least 2 players ready for 4-player mode
          ;; if readyCount>= 2 then jmp CharacterSelectCompleted
          lda readyCount
          cmp # 2

          bcc CharacterSelectDoneQuadtariReadyInline

          jmp CharacterSelectDoneQuadtariReadyInline

          CharacterSelectDoneQuadtariReadyInline:

CharacterSelectDoneQuadtariReadyInline
          ;; Draw character selection screen
          jsr CharacterSelectDrawScreen

          ;; drawscreen called by MainLoop
          rts

.pend

CharacterSelectDrawScreen .proc
          ;; Draw character selection screen via shared renderer
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


          rts

.pend

HandleCharacterSelectPlayerInput .proc
          ;; Unified handler for character select player input
          ;;
          ;; Input: temp1 = player index (0-3)
          ;; joy0left/joy0right/joy0up/joy0fire/joy0down (players 0,2)
          ;; joy1left/joy1right/joy1up/joy1fire/joy1down (players 1,3)
          ;;
          ;; Output: playerCharacter[] updated, playerLocked state updated
          ;;
          ;; Mutates: currentPlayer (set to temp1), playerCharacter[],
          ;; playerLocked state, temp1, temp2 (passed to helpers)
          ;;
          ;; Called Routines: SelectStickLeft, SelectStickRight,
          ;; SetPlayerLocked (bank6), HandleCharacterSelectFire (bank6)
          ;;
          ;; Constraints: Must determine joy port based on player index
          ;; (players 0,2 use joy0; players 1,3 use joy1)
          ;; Determine which joy port to use based on player index
          lda temp1
          sta currentPlayer
          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          lda temp1
          cmp # 0
          bne CheckPlayer2Joy0
          jmp HCSPI_UseJoy0
CheckPlayer2Joy0:


          ;; Players 1,3 use joy1
          lda temp1
          cmp # 2
          bne UseJoy1
          jmp HCSPI_UseJoy0
UseJoy1:


          jsr SelectStickLeft

          ;; Unlock by moving up
          jsr SelectStickRight

          ;; Handle fire button (selection)
          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(AfterSetPlayerLockedInput-1)
          pha
          lda # <(AfterSetPlayerLockedInput-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedInput:


          ;; Cross-bank call to HandleCharacterSelectFire in bank 6
          lda # >(AfterHandleCharacterSelectFireInput-1)
          pha
          lda # <(AfterHandleCharacterSelectFireInput-1)
          pha
          lda # >(HandleCharacterSelectFire-1)
          pha
          lda # <(HandleCharacterSelectFire-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterHandleCharacterSelectFireInput:


          rts

.pend

HCSPI_UseJoy0 .proc
          ;; Players 0,2 use joy0
          jsr SelectStickLeft

          ;; Unlock by moving up
          jsr SelectStickRight

          ;; Handle fire button (selection)
          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(AfterSetPlayerLockedJoy0-1)
          pha
          lda # <(AfterSetPlayerLockedJoy0-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedJoy0:


          ;; Cross-bank call to HandleCharacterSelectFire in bank 6
          lda # >(AfterHandleCharacterSelectFireJoy0-1)
          pha
          lda # <(AfterHandleCharacterSelectFireJoy0-1)
          pha
          lda # >(HandleCharacterSelectFire-1)
          pha
          lda # <(HandleCharacterSelectFire-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterHandleCharacterSelectFireJoy0:


          rts

CharacterSelectCompleted
          ;; Character selection complete (stores selected characters
          and initializes facing directions)
          ;;
          ;; Input: playerCharacter[] (global array) = current character
          ;; selections, playerState[] (global array) = player sta

          ;; NoCharacter (global constant) = no character consta

          ;;
          ;; Output: Selected characters stored, facing directions
          ;; initialized (default: face right = 1)
          ;;
          ;; Mutates: playerState[] (global array) = player states (facing bit
          ;; set for selected players)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Only sets facing bit for players with valid
          ;; character selections (not NoCharacter). Default facing:
          ;; right (bit 0 = 1)
          ;; Character selection complete
          ;; Initialize facing bit (bit 0) for all selected players
          ;; (default: face right = 1)
                    if playerCharacter[0] = NoCharacter then DoneCharacter1FacingSel

                    let playerState[0] = playerState[0]
          lda # 0
          asl
          tax
          lda playerState,x
          lda # 0
          asl
          tax
          sta playerState,x | 1

DoneCharacter1FacingSel
                    if playerCharacter[1] = NoCharacter then DoneCharacter2FacingSel
          lda # 1
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne SetPlayer2Facing
          jmp DoneCharacter2FacingSel
SetPlayer2Facing:

                    let playerState[1] = playerState[1]
          lda # 1
          asl
          tax
          lda playerState,x
          lda # 1
          asl
          tax
          sta playerState,x | 1

DoneCharacter2FacingSel
                    if playerCharacter[2] = NoCharacter then DoneCharacter3FacingSel
          lda # 2
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne SetPlayer3Facing
          jmp DoneCharacter3FacingSel
SetPlayer3Facing:

                    let playerState[2] = playerState[2]
          lda # 2
          asl
          tax
          lda playerState,x
          lda # 2
          asl
          tax
          sta playerState,x | 1

DoneCharacter3FacingSel
                    if playerCharacter[3] = NoCharacter then DoneCharacter4FacingSel
          lda # 3
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne SetPlayer4Facing
          jmp DoneCharacter4FacingSel
SetPlayer4Facing:

                    let playerState[3] = playerState[3]
          lda # 3
          asl
          tax
          lda playerState,x
          lda # 3
          asl
          tax
          sta playerState,x | 1

DoneCharacter4FacingSel
          ;; Proceed to falling animation
          rts

.pend

CharacterSelectDetectQuadtari .proc
          ;; Detect Quadtari adapter
          ;; Detect Quadtari adapter (canonical detection: check paddle
          ;; ports INPT0-3)
          ;;
          ;; Input: INPT0-3 (hardware registers) = paddle port sta

          ;; controllerStatus (global) = controller detection sta

          ;; SetQuadtariDetected (global constant) = Quadtari detection
          ;; flag
          ;;
          ;; Output: Quadtari detection flag set if adapter detected
          ;;
          ;; Mutates: controllerStatus (global) = controller detection
          ;; state (Quadtari flag set if detected)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Requires BOTH sides present: Left (INPT0 LOW,
          ;; INPT1 HIGH) and Right (INPT2 LOW, INPT3 HIGH). Uses
          ;; monotonic merge (OR) to preserve existing capabilities
          ;; (upgrades only, never downgrades). If Quadtari was
          ;; previously detected, it remains detected
          ;; CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          ;; Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH)
          and Right (INPT2 LOW, INPT3 HIGH)

          ;; Check left side: if INPT0 is HIGH then not detected

          ;; Check left side: if INPT1 is LOW then not detected
                    if INPT0{7} then CharacterSelectQuadtariAbsent
          bit INPT0
          bpl CheckINPT1Detect
          jmp CharacterSelectQuadtariAbsent
CheckINPT1Detect:

                    if !INPT1{7} then CharacterSelectQuadtariAbsent
          bit INPT1
          bmi CheckINPT2Detect
          jmp CharacterSelectQuadtariAbsent
CheckINPT2Detect:

          ;; Check right side: if INPT2 is HIGH then not detected

          ;; Check right side: if INPT3 is LOW then not detected
                    if INPT2{7} then CharacterSelectQuadtariAbsent
          bit INPT2
          bpl CheckINPT3Detect
          jmp CharacterSelectQuadtariAbsent
CheckINPT3Detect:

                    if !INPT3{7} then CharacterSelectQuadtariAbsent
          bit INPT3
          bmi CharacterSelectQuadtariDetected
          jmp CharacterSelectQuadtariAbsent
CharacterSelectQuadtariDetected:

          ;; All checks passed - Quadtari detected
          jmp CharacterSelectQuadtariDetected

.pend

CharacterSelectQuadtariAbsent .proc
          ;; Helper: Quadtari not detected in this detection cycle
          ;;
          ;; Input: None
          ;;
          ;; Output: No changes (monotonic detection preserves previous
          ;; sta

          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Helper for CharacterSelectDetectQuadtari; only executes when Quadtari
          ;; is absent. Monotonic detection means controllerStatus is never cleared here.
          ;; DetectPads (SELECT handler) is the sole routine that upgrades controller
          ;; status flags.
          rts

.pend

CharacterSelectQuadtariDetected .proc
          ;; Helper: Quadtari detected - set detection flag
          ;;
          ;; Input: controllerStatus (global) = controller detection
          ;; state, SetQuadtariDetected (global constant) = Quadtari
          ;; detection flag
          ;;
          ;; Output: Quadtari detection flag set
          ;;
          ;; Mutates: controllerStatus (global) = controller detection
          ;; state (Quadtari flag set via OR merge)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Internal helper for CharacterSelectDetectQuadtari, only
          ;; called when Quadtari detected. Uses monotonic merge (OR)
          ;; to preserve existing capabilities (upgrades only, never
          ;; downgrades)
          ;; Quadtari detected - use monotonic merge to preserve
          ;; existing capabilities
          ;; OR merge ensures upgrades only, never downgrades
          lda controllerStatus
          ora # SetQuadtariDetected
          sta controllerStatus

          rts

.pend

