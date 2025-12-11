;;; ChaosFight - Source/Routines/FallingAnimation.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Falling In Animation - Per-frame Loop
;;; Moves players from quadrant staging positions to arena row 2.

FallingAnimation1:
          ;; Returns: Far (return otherbank)
          ;; Moves active players from quadrant spawn points to row 2 starting positions
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
          bcc MovePlayer1

          lda # 0
          sta fallFrame

DonePlayer1MoveForward:
          jmp DonePlayer1Move

MovePlayer1:


          ;; Move Player 1 from quadrant to target (if active)
          ;; playerIndex = 0 (player index), targetX = target X
          ;; Check if player 1 is active
          lda # 0
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          beq DonePlayer1MoveForward
          ;; targetY = target Y (24)
          lda # 0
          sta temp1
          ;; Check if 4-player mode for target X
          lda controllerStatus
          and # SetQuadtariDetected
          bne Player1Target4P

          ;; 2-player mode: target × = 53
          lda # 53
          sta temp2
          jmp Player1TargetDone


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
          lda # 32
          sta temp2

.pend

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
          lda # 24
          sta temp3
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          lda # >(FallingAnimationPlayer1Return-1)
          pha
          lda # <(FallingAnimationPlayer1Return-1)
          pha
          lda # >(MovePlayerToTarget-1)
          pha
          lda # <(MovePlayerToTarget-1)
          pha
                    ldx # 5
          jmp BS_jsr
FallingAnimationPlayer1Return:
          ;; Increment fallComplete if player reached target
          lda temp4
          beq DonePlayer1Move
          inc fallComplete
DonePlayer1Move:
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
          ;; Check if player 2 is active
          lda # 1
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          beq DonePlayer2MoveForward
SetPlayer2Target:
          ;; Check if 4-player mode for target X
          lda # 1
          sta temp1
          lda controllerStatus
          and # SetQuadtariDetected
          bne Player2Target4P

          ;; 2-player mode: target × = 107
          lda # 107
          sta temp2
          jmp Player2TargetDoneLabel

Player2TargetDoneLabel:
          jmp Player2Target4P.Player2TargetDone

DonePlayer2MoveForward:
          jmp DonePlayer2Move

DonePlayer2Move:
          jmp BS_return

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
          lda # 128
          sta temp2

Player2TargetDone:
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
          ;;
          ;; Constraints: Must be colocated with FallingAnimation1
          lda # 24
          sta temp3
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          lda # >(AfterMovePlayerToTargetP2-1)
          pha
          lda # <(AfterMovePlayerToTargetP2-1)
          pha
          lda # >(MovePlayerToTarget-1)
          pha
          lda # <(MovePlayerToTarget-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterMovePlayerToTargetP2:
          ;; Increment fallComplete if player reached target
          lda temp4
          beq DonePlayer2MoveLabel
          inc fallComplete
DonePlayer2MoveLabel:
          jmp DonePlayer2Move
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

.pend

          ;; Move Player 3 from quadrant to target (if active)
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne MovePlayer3

MovePlayer3:
          ;; Check if player 3 is active
          lda # 2
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          beq DonePlayer3Move
          lda # 2
          sta temp1
          ;; 4-player mode: target × = 64
          lda # 64
          sta temp2
          lda # 24
          sta temp3
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          lda # >(AfterMovePlayerToTargetP3-1)
          pha
          lda # <(AfterMovePlayerToTargetP3-1)
          pha
          lda # >(MovePlayerToTarget-1)
          pha
          lda # <(MovePlayerToTarget-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterMovePlayerToTargetP3:


          ;; If temp4 is non-zero, increment fallComplete
          lda temp4
          beq DonePlayer3MoveLabel
          inc fallComplete
DonePlayer3MoveLabel:
          jmp BS_return

DonePlayer3Move:
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
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne MovePlayer4

MovePlayer4:


          lda # 3
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          beq DonePlayer4Move
          lda # 3
          sta temp1
          ;; 4-player mode: target × = 96
          lda # 96
          sta temp2
          lda # 24
          sta temp3
          ;; Cross-bank call to MovePlayerToTarget in bank 6
          lda # >(AfterMovePlayerToTargetP4-1)
          pha
          lda # <(AfterMovePlayerToTargetP4-1)
          pha
          lda # >(MovePlayerToTarget-1)
          pha
          lda # <(MovePlayerToTarget-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterMovePlayerToTargetP4:
          ;; Increment fallComplete if player reached target
          lda temp4
          beq DonePlayer4MoveLabel
          inc fallComplete
DonePlayer4MoveLabel:
          jmp BS_return

DonePlayer4Move:
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
          lda fallComplete
          cmp activePlayers
          bcc UpdateSprites
          jmp FallingComplete1
UpdateSprites:

          ;; Set sprite positions and load character sprites
          ;; dynamically
          ;; Use dynamic sprite setting instead of relying on player
          ;; declarations
          ;; Cross-bank call to SetSpritePositions in bank 6
          lda # >(AfterSetSpritePositions-1)
          pha
          lda # <(AfterSetSpritePositions-1)
          pha
          lda # >(SetSpritePositions-1)
          pha
          lda # <(SetSpritePositions-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetSpritePositions:


          ;; Cross-bank call to SetPlayerSprites in bank 6
          lda # >(AfterSetPlayerSpritesFalling-1)
          pha
          lda # <(AfterSetPlayerSpritesFalling-1)
          pha
          lda # >(SetPlayerSprites-1)
          pha
          lda # <(SetPlayerSprites-1)
          pha
                    ldx # 5
          jmp BS_jsr
AfterSetPlayerSpritesFalling:


          ;; drawscreen called by MainLoop
          jmp BS_return

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
          lda # >(AfterBeginGameLoop-1)
          pha
          lda # <(AfterBeginGameLoop-1)
          pha
          lda # >(BeginGameLoop-1)
          pha
          lda # <(BeginGameLoop-1)
          pha
                    ldx # 10
          jmp BS_jsr
AfterBeginGameLoop:


          ;; Transition to Game Mode
          lda ModeGame
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(AfterChangeGameModeFalling-1)
          pha
          lda # <(AfterChangeGameModeFalling-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterChangeGameModeFalling:


          jmp BS_return

.pend

