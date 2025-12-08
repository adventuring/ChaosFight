;;; ChaosFight - Source/Routines/FallingAnimation.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Falling In Animation - Per-frame Loop
;;; Moves players from quadrant staging positions to arena row 2.

FallingAnimation1
          ;; Returns: Far (return otherbank)
;; FallingAnimation1 (duplicate)
          ;; Moves active players from quadrant spawn points to row 2 starting positions
          ;; Returns: Far (return otherbank)
          ;; Called each frame while gameMode = ModeFallingAnimation1
          ;; Flow:
          ;; 1. Move each active player toward their target position
          ;; 2. Track completion count
          ;; 3. Transition to game mode when all players arrive
          ;; Input: playerCharacter[] (global array) = character selections
          ;; controllerStatus (global) = controller detection
          ;; sta

          ;; fallFrame (global) = animation frame counter
          ;; fallComplete (global) = count of players who
          ;; reached target
          ;; activePlayers (global) = number of active players
          ;;
          ;; Output: Dispatches to FallingComplete1 or returns
          ;;
          ;; Mutates: fallFrame (incremented, wraps at 4), fallComplete
          ;; (incremented per player),
          ;; playerX[], playerY[] (updated via
          ;; MovePlayerToTarget)
          ;;
          ;; Called Routines: MovePlayerToTarget - accesses player
          ;; positions, target positions,
          ;; SetSpritePositions (bank2) - accesses player positions,
          ;; SetPlayerSprites (bank2) - accesses character sprites,
          ;; BeginGameLoop (bank11) - initializes game sta

          ;; ChangeGameMode (bank14) - accesses game mode sta

          ;;
          ;; Constraints: Must be colocated with Player1Target4P,
          ;; Player1TargetDone, DonePlayer1Move,
          ;; Player2Target4P, Player2TargetDone,
          ;; DonePlayer2Move, DonePlayer3Move,
          ;; DonePlayer4Move, FallingComplete1 (all called
          ;; via goto)
          ;; Entry point for falling animation mode (called from MainLoop)
          ;; Update animation frame
          inc fallFrame
          lda fallFrame
          cmp # 4
          bcc skip_3293
          ;; lda # 0 (duplicate)
          sta fallFrame
skip_3293:


          ;; Move Player 1 from quadrant to target (if active)
          ;; playerIndex = 0 (player index), targetX = target X,
                    ;; if playerCharacter[0] = NoCharacter then DonePlayer1Move

          ;; targetY = target Y (24)
          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)
          ;; Check if 4-player mode for target X
                    ;; if controllerStatus & SetQuadtariDetected then Player1Target4P

          ;; 2-player mode: target × = 53
          ;; lda # 53 (duplicate)
          ;; sta temp2 (duplicate)
          jmp Player1Target4P.Player1TargetDone


Player1Target4P .proc
          ;; Set Player 1 target × for 4-player mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from FallingAnimation1)
          ;;
          ;; Output: temp2 set to 32
          ;;
          ;; Mutates: temp2
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with FallingAnimation1,
          ;; Player1TargetDone
          ;; 4-player mode: target × = 32
          ;; lda # 32 (duplicate)
          ;; sta temp2 (duplicate)

Player1TargetDone:
          ;; Player 1 target calculation complete
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with FallingAnimation1
          ;; lda # 24 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 5
          ;; jmp BS_jsr (duplicate)
return_point:


                    ;; if temp4 then let fallComplete = fallComplete + 1          lda temp4          beq skip_6580
skip_6580:
          ;; jmp skip_6580 (duplicate)

DonePlayer1Move
          ;; reached = 1 if reached target
          ;; Returns: Far (return otherbank)
          ;; Player 1 movement complete (skipped if not active)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with FallingAnimation1

          ;; Move Player 2 from quadrant to target (if active)
                    ;; if playerCharacter[1] = NoCharacter then DonePlayer2Move
          ;; lda # 1 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          bne skip_6968
          ;; jmp DonePlayer2Move (duplicate)
skip_6968:

          ;; Check if 4-player mode for target X
          ;; lda # 1 (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if controllerStatus & SetQuadtariDetected then Player2Target4P

          ;; 2-player mode: target × = 107
          ;; lda # 107 (duplicate)
          ;; sta temp2 (duplicate)
          ;; jmp Player2TargetDone (duplicate)

.pend

Player2Target4P .proc
          ;; Set Player 2 target × for 4-player mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from FallingAnimation1)
          ;;
          ;; Output: temp2 set to 128
          ;;
          ;; Mutates: temp2
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with FallingAnimation1,
          ;; Player2TargetDone
          ;; 4-player mode: target × = 128
          ;; lda # 128 (duplicate)
          ;; sta temp2 (duplicate)

Player2TargetDone
          ;; Player 2 target calculation complete
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with FallingAnimation1
          ;; lda # 24 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp4 then let fallComplete = fallComplete + 1          lda temp4          beq skip_6580
;; skip_6580: (duplicate)
          ;; jmp skip_6580 (duplicate)

DonePlayer2Move
          ;; Player 2 movement complete (skipped if not active)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with FallingAnimation1

          ;; Move Player 3 from quadrant to target (if active)
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; cmp # 0 (duplicate)
          ;; bne skip_6194 (duplicate)
skip_6194:


                    ;; if playerCharacter[2] = NoCharacter then DonePlayer3Move
          ;; lda # 2 (duplicate)
          ;; sta temp1 (duplicate)
          ;; 4-player mode: target × = 64
          ;; lda # 64 (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp4 then let fallComplete = fallComplete + 1          lda temp4          beq skip_6580
;; skip_6580: (duplicate)
          ;; jmp skip_6580 (duplicate)

DonePlayer3Move
          ;; Player 3 movement complete (skipped if not in 4-player
          ;; Returns: Far (return otherbank)
          ;; mode or not active)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with FallingAnimation1

          ;; Move Player 4 from quadrant to target (if active)
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4267 (duplicate)
skip_4267:


                    ;; if playerCharacter[3] = NoCharacter then DonePlayer4Move
          ;; lda # 3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; 4-player mode: target × = 96
          ;; lda # 96 (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta temp3 (duplicate)
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(MovePlayerToTarget-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


                    ;; if temp4 then let fallComplete = fallComplete + 1          lda temp4          beq skip_6580
;; skip_6580: (duplicate)
          ;; jmp skip_6580 (duplicate)

DonePlayer4Move
          ;; Player 4 movement complete (skipped if not in 4-player
          ;; Returns: Far (return otherbank)
          ;; mode or not active)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with FallingAnimation1

          ;; Check if all players have reached their targets
                    ;; if fallComplete >= activePlayers then FallingComplete1
          ;; lda fallComplete (duplicate)
          ;; cmp activePlayers (duplicate)
          ;; bcc skip_1796 (duplicate)
          ;; jmp FallingComplete1 (duplicate)
skip_1796:

          ;; Set sprite positions and load character sprites
          ;; dynamically
          ;; Use dynamic sprite setting instead of relying on player
          ;; declarations
          ;; Cross-bank call to SetSpritePositions in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetSpritePositions-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetSpritePositions-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to SetPlayerSprites in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerSprites-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerSprites-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; drawscreen called by MainLoop
          jsr BS_return

FallingComplete1
          ;; All players have reached row 2 positions
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from FallingAnimation1)
          ;;
          ;; Output: gameMode set to ModeGame, BeginGameLoop and
          ;; ChangeGameMode called
          ;;
          ;; Mutates: gameMode (global)
          ;;
          ;; Called Routines: BeginGameLoop (bank11) - accesses game
          ;; sta

          ;; ChangeGameMode (bank14) - accesses game mode sta

          ;;
          ;; Constraints: Must be colocated with FallingAnimation1
          ;; All players have reached row 2 positions
          ;; Call BeginGameLoop to initialize game state before
          ;; switching modes
          ;; Note: BeginGameLoop will use final positions from falling
          ;; animation
          ;; Cross-bank call to BeginGameLoop in bank 11
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(BeginGameLoop-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(BeginGameLoop-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 10 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Transition to Game Mode
          ;; lda ModeGame (duplicate)
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


          ;; jsr BS_return (duplicate)

.pend

