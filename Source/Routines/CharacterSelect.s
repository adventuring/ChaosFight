;;; ChaosFight - Source/Routines/CharacterSelect.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CharacterSelectEntry .proc
;;; Initializes character select screen sta

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
          lda 0
          asl
          tax
          ;; lda CharacterBernie (duplicate)
          sta playerCharacter,x
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterBernie (duplicate)
          ;; sta playerCharacter,x (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterBernie (duplicate)
          ;; sta playerCharacter,x (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterBernie (duplicate)
          ;; sta playerCharacter,x (duplicate)
          ;; Initialize playerLocked (bit-packed, all unlocked)
          ;; lda # 0 (duplicate)
          ;; sta playerLocked (duplicate)
          ;; NOTE: Do NOT clear controllerStatus flags here - monotonic
          ;; detection (upgrades only)
          ;; Controller detection is handled by DetectPads with
          ;; monotonic state machine

          ;; Initialize character select animations
          ;; lda # 0 (duplicate)
          ;; sta characterSelectAnimationTimer (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta characterSelectAnimationState (duplicate)
          ;; Start with idle animation
          ;; lda # 0 (duplicate)
          ;; sta characterSelectCharacterIndex_W (duplicate)
          ;; Start with first character
          ;; lda # 0 (duplicate)
          ;; sta characterSelectAnimationFrame (duplicate)

          ;; Check for Quadtari adapter (inlined for performance)
          ;; CANONICAL QUADTARI DETECTION: Check paddle ports INPT0-3
          ;; Require BOTH sides present: Left (INPT0 LOW, INPT1 HIGH) and Right (INPT2 LOW, INPT3 HIGH)
                    ;; if INPT0{7} then goto CharacterSelectQuadtariAbsent

                    ;; if !INPT1{7} then goto CharacterSelectQuadtariAbsent
          bit INPT1
          bmi skip_5888
          jmp CharacterSelectQuadtariAbsent
skip_5888:

                    ;; if INPT2{7} then goto CharacterSelectQuadtariAbsent
          ;; bit INPT2 (duplicate)
          bpl skip_4108
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_4108:

          ;; All checks passed - Quadtari detected
                    ;; if !INPT3{7} then goto CharacterSelectQuadtariAbsent
          ;; bit INPT3 (duplicate)
          ;; bmi skip_7109 (duplicate)
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_7109:
          ;; lda controllerStatus (duplicate)
          ora SetQuadtariDetected
          ;; sta controllerStatus (duplicate)

.pend

CharacterSelectQuadtariAbsent .proc
          ;; Background: black (COLUBK starts black, no need to set)
          ;; Always black background

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
                    ;; if qtcontroller then goto CharacterSelectHandleQuadtari
          ;; lda qtcontroller (duplicate)
          beq skip_9978
          ;; jmp CharacterSelectHandleQuadtari (duplicate)
skip_9978:

          ;; Handle Player 1 input (joy0 on even frames)
          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)
          jsr HandleCharacterSelectPlayerInput

          ;; Handle Player 2 input (joy1 on even frames)
          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr HandleCharacterSelectPlayerInput (duplicate)

          ;; Switch to odd frame mode for next iteration
          qtcontroller = 1
          ;; jmp CharacterSelectHandleComplete (duplicate)

.pend

CharacterSelectHandleQuadtari .proc
          ;; Handle Player 3 input (joy0 on odd frames, Quadtari only)
                    ;; if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer3
          ;; jmp CharacterSelectHandleQuadtariDone (duplicate)

.pend

CharacterSelectHandlePlayer3 .proc
          ;; Handle Player 3 input (joy0 on odd frames, Quadtari only)
          ;; lda # 2 (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr HandleCharacterSelectPlayerInput (duplicate)

          ;; Handle Player 4 input (joy1 on odd frames, Quadtari only)
                    ;; if controllerStatus & SetQuadtariDetected then CharacterSelectHandlePlayer4
          ;; jmp CharacterSelectHandleQuadtariDone (duplicate)

.pend

CharacterSelectHandlePlayer4 .proc
          ;; lda # 3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr HandleCharacterSelectPlayerInput (duplicate)

CharacterSelectHandleQuadtariDone
          ;; Switch back to even frame mode for next iteration
          ;; qtcontroller = 0 (duplicate)

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
          ;; ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] - 1
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          dec playerCharacter,x

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerCharacter,x (duplicate)

                    ;; if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = MaxCharacter

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
          ;; ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] + 1
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          inc playerCharacter,x

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerCharacter,x (duplicate)

                    ;; if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = CharacterBernie

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


          ;; rts (duplicate)

CharacterSelectHandleComplete
          ;; Check if all players are ready to start (inline
          ;; SelAllReady)
          ;; lda # 0 (duplicate)
          ;; sta readyCount (duplicate)

          ;; Count locked players
          ;; inc readyCount (duplicate)

          ;; inc readyCount (duplicate)

                    ;; if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariPlayersInline
          ;; jmp CharacterSelectDoneQuadtariPlayersInline (duplicate)

.pend

CharacterSelectQuadtariPlayersInline .proc
          ;; inc readyCount (duplicate)

          ;; inc readyCount (duplicate)

CharacterSelectDoneQuadtariPlayersInline
          ;; Check if enough players are ready
                    ;; if controllerStatus & SetQuadtariDetected then CharacterSelectQuadtariReadyInline

          ;; Need at least 1 player ready for 2-player mode
          ;; ;; ;;           ;; let temp1 = 0 : gosub GetPlayerLocked bank6
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
;; return_point: : if temp2 then goto CharacterSelectCompleted (duplicate)

;; lda temp2 (duplicate)

;; beq skip_1268 (duplicate)

skip_1268:
          ;; jmp skip_1268 (duplicate)

          ;; lda temp2 (duplicate)

          ;; beq skip_4268 (duplicate)

          ;; jmp skip_4268: (duplicate)

          ;; lda temp2 (duplicate)

          ;; beq skip_37 (duplicate)

          ;; jmp skip_37: (duplicate)

          ;; ;; ;;           ;; let temp1 = 1 : gosub GetPlayerLocked bank6 : if temp2 then goto CharacterSelectCompleted          lda temp2          beq skip_2410
skip_2410:
          ;; jmp skip_2410 (duplicate)
          ;; lda temp2 (duplicate)

          ;; beq skip_4768 (duplicate)

          ;; jmp skip_4768: (duplicate)

          ;; lda temp2 (duplicate)

          ;; beq skip_8352 (duplicate)

          ;; jmp skip_8352: (duplicate)

          ;; jmp CharacterSelectDoneQuadtariReadyInline (duplicate)

.pend

CharacterSelectQuadtariReadyInline .proc
          ;; Need at least 2 players ready for 4-player mode
          ;; if readyCount>= 2 then goto CharacterSelectCompleted
          ;; lda readyCount (duplicate)
          cmp 2

          bcc skip_1942

          ;; jmp skip_1942 (duplicate)

          skip_1942:

CharacterSelectDoneQuadtariReadyInline
          ;; Draw character selection screen
          ;; jsr CharacterSelectDrawScreen (duplicate)

          ;; drawscreen called by MainLoop
          ;; rts (duplicate)

.pend

CharacterSelectDrawScreen .proc
          ;; Draw character selection screen via shared renderer
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


          ;; rts (duplicate)

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
          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          bne skip_290
          ;; jmp HCSPI_UseJoy0 (duplicate)
skip_290:


          ;; Players 1,3 use joy1
          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_9848 (duplicate)
          ;; jmp HCSPI_UseJoy0 (duplicate)
skip_9848:


          ;; jsr SelectStickLeft (duplicate)

          ;; Unlock by moving up
          ;; jsr SelectStickRight (duplicate)

          ;; Handle fire button (selection)
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


          ;; Cross-bank call to HandleCharacterSelectFire in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; rts (duplicate)

.pend

HCSPI_UseJoy0 .proc
          ;; Players 0,2 use joy0
          ;; jsr SelectStickLeft (duplicate)

          ;; Unlock by moving up
          ;; jsr SelectStickRight (duplicate)

          ;; Handle fire button (selection)
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


          ;; Cross-bank call to HandleCharacterSelectFire in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(HandleCharacterSelectFire-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; rts (duplicate)

CharacterSelectCompleted
          ;; Character selection complete (stores selected characters
          ;; and initializes facing directions)
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
                    ;; if playerCharacter[0] = NoCharacter then DoneCharacter1FacingSel

                    ;; let playerState[0] = playerState[0]
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerState,x | 1 (duplicate)

DoneCharacter1FacingSel
                    ;; if playerCharacter[1] = NoCharacter then DoneCharacter2FacingSel
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_8511 (duplicate)
          ;; jmp DoneCharacter2FacingSel (duplicate)
skip_8511:

                    ;; let playerState[1] = playerState[1]
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerState,x | 1 (duplicate)

DoneCharacter2FacingSel
                    ;; if playerCharacter[2] = NoCharacter then DoneCharacter3FacingSel
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_4461 (duplicate)
          ;; jmp DoneCharacter3FacingSel (duplicate)
skip_4461:

                    ;; let playerState[2] = playerState[2]
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerState,x | 1 (duplicate)

DoneCharacter3FacingSel
                    ;; if playerCharacter[3] = NoCharacter then DoneCharacter4FacingSel
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_5900 (duplicate)
          ;; jmp DoneCharacter4FacingSel (duplicate)
skip_5900:

                    ;; let playerState[3] = playerState[3]
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerState,x | 1 (duplicate)

DoneCharacter4FacingSel
          ;; Proceed to falling animation
          ;; rts (duplicate)

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
          ;; and Right (INPT2 LOW, INPT3 HIGH)

          ;; Check left side: if INPT0 is HIGH then not detected

          ;; Check left side: if INPT1 is LOW then not detected
                    ;; if INPT0{7} then CharacterSelectQuadtariAbsent
          ;; bit INPT0 (duplicate)
          ;; bpl skip_460 (duplicate)
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_460:

                    ;; if !INPT1{7} then CharacterSelectQuadtariAbsent
          ;; bit INPT1 (duplicate)
          ;; bmi skip_9316 (duplicate)
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_9316:

          ;; Check right side: if INPT2 is HIGH then not detected

          ;; Check right side: if INPT3 is LOW then not detected
                    ;; if INPT2{7} then CharacterSelectQuadtariAbsent
          ;; bit INPT2 (duplicate)
          ;; bpl skip_7185 (duplicate)
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_7185:

                    ;; if !INPT3{7} then CharacterSelectQuadtariAbsent
          ;; bit INPT3 (duplicate)
          ;; bmi skip_8722 (duplicate)
          ;; jmp CharacterSelectQuadtariAbsent (duplicate)
skip_8722:

          ;; All checks passed - Quadtari detected
          ;; jmp CharacterSelectQuadtariDetected (duplicate)

.pend

;; CharacterSelectQuadtariAbsent .proc (duplicate)
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
          ;; rts (duplicate)

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
          ;; lda controllerStatus (duplicate)
          ;; ora SetQuadtariDetected (duplicate)
          ;; sta controllerStatus (duplicate)
          ;; rts (duplicate)

.pend

