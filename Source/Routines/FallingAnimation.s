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
          ;; Cross-bank call to MovePlayerToTarget in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(FallingAnimationPlayer1Return-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: FallingAnimationPlayer1Return hi (encoded)]
          lda # <(FallingAnimationPlayer1Return-1)
          pha
          ;; STACK PICTURE: [SP+1: FallingAnimationPlayer1Return hi (encoded)] [SP+0: FallingAnimationPlayer1Return lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+2: FallingAnimationPlayer1Return hi (encoded)] [SP+1: FallingAnimationPlayer1Return lo] [SP+0: MovePlayerToTarget hi (raw)]
          lda # <(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+3: FallingAnimationPlayer1Return hi (encoded)] [SP+2: FallingAnimationPlayer1Return lo] [SP+1: MovePlayerToTarget hi (raw)] [SP+0: MovePlayerToTarget lo]
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
          beq DonePlayer2Move
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
          jmp Player2TargetDone

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
.pend

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
          ;; Cross-bank call to MovePlayerToTarget in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterMovePlayerToTargetP2-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterMovePlayerToTargetP2 hi (encoded)]
          lda # <(AfterMovePlayerToTargetP2-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterMovePlayerToTargetP2 hi (encoded)] [SP+0: AfterMovePlayerToTargetP2 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterMovePlayerToTargetP2 hi (encoded)] [SP+1: AfterMovePlayerToTargetP2 lo] [SP+0: MovePlayerToTarget hi (raw)]
          lda # <(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterMovePlayerToTargetP2 hi (encoded)] [SP+2: AfterMovePlayerToTargetP2 lo] [SP+1: MovePlayerToTarget hi (raw)] [SP+0: MovePlayerToTarget lo]
          ldx # 5
          jmp BS_jsr
AfterMovePlayerToTargetP2:
          ;; Increment fallComplete if player reached target
          lda temp4
          beq DonePlayer2MoveLabel
          inc fallComplete
DonePlayer2MoveLabel:
          jmp DonePlayer2Move

DonePlayer2Move:
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
          ;; Player 3 only active in 4-player mode
          lda controllerStatus
          and # SetQuadtariDetected
          beq DonePlayer3Move

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
          ;; Cross-bank call to MovePlayerToTarget in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterMovePlayerToTargetP3-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterMovePlayerToTargetP3 hi (encoded)]
          lda # <(AfterMovePlayerToTargetP3-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterMovePlayerToTargetP3 hi (encoded)] [SP+0: AfterMovePlayerToTargetP3 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterMovePlayerToTargetP3 hi (encoded)] [SP+1: AfterMovePlayerToTargetP3 lo] [SP+0: MovePlayerToTarget hi (raw)]
          lda # <(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterMovePlayerToTargetP3 hi (encoded)] [SP+2: AfterMovePlayerToTargetP3 lo] [SP+1: MovePlayerToTarget hi (raw)] [SP+0: MovePlayerToTarget lo]
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
          ;; Cross-bank call to MovePlayerToTarget in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterMovePlayerToTargetP4-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterMovePlayerToTargetP4 hi (encoded)]
          lda # <(AfterMovePlayerToTargetP4-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterMovePlayerToTargetP4 hi (encoded)] [SP+0: AfterMovePlayerToTargetP4 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterMovePlayerToTargetP4 hi (encoded)] [SP+1: AfterMovePlayerToTargetP4 lo] [SP+0: MovePlayerToTarget hi (raw)]
          lda # <(MovePlayerToTarget-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterMovePlayerToTargetP4 hi (encoded)] [SP+2: AfterMovePlayerToTargetP4 lo] [SP+1: MovePlayerToTarget hi (raw)] [SP+0: MovePlayerToTarget lo]
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
          ;; Cross-bank call to SetSpritePositions in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterSetSpritePositions-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetSpritePositions hi (encoded)]
          lda # <(AfterSetSpritePositions-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetSpritePositions hi (encoded)] [SP+0: AfterSetSpritePositions lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetSpritePositions-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetSpritePositions hi (encoded)] [SP+1: AfterSetSpritePositions lo] [SP+0: SetSpritePositions hi (raw)]
          lda # <(SetSpritePositions-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetSpritePositions hi (encoded)] [SP+2: AfterSetSpritePositions lo] [SP+1: SetSpritePositions hi (raw)] [SP+0: SetSpritePositions lo]
          ldx # 5
          jmp BS_jsr
AfterSetSpritePositions:


          ;; Cross-bank call to SetPlayerSprites in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterSetPlayerSpritesFalling-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerSpritesFalling hi (encoded)]
          lda # <(AfterSetPlayerSpritesFalling-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerSpritesFalling hi (encoded)] [SP+0: AfterSetPlayerSpritesFalling lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerSprites-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerSpritesFalling hi (encoded)] [SP+1: AfterSetPlayerSpritesFalling lo] [SP+0: SetPlayerSprites hi (raw)]
          lda # <(SetPlayerSprites-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerSpritesFalling hi (encoded)] [SP+2: AfterSetPlayerSpritesFalling lo] [SP+1: SetPlayerSprites hi (raw)] [SP+0: SetPlayerSprites lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerSpritesFalling:


          ;; drawscreen called by MainLoop
          jmp BS_return

FallingComplete1 .proc
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
          ;; Cross-bank call to BeginGameLoop in bank 10
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterBeginGameLoop-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterBeginGameLoop hi (encoded)]
          lda # <(AfterBeginGameLoop-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterBeginGameLoop hi (encoded)] [SP+0: AfterBeginGameLoop lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(BeginGameLoop-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterBeginGameLoop hi (encoded)] [SP+1: AfterBeginGameLoop lo] [SP+0: BeginGameLoop hi (raw)]
          lda # <(BeginGameLoop-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterBeginGameLoop hi (encoded)] [SP+2: AfterBeginGameLoop lo] [SP+1: BeginGameLoop hi (raw)] [SP+0: BeginGameLoop lo]
          ldx # 10
          jmp BS_jsr
AfterBeginGameLoop:


          ;; Transition to Game Mode
          lda ModeGame
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 13
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterChangeGameModeFalling-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterChangeGameModeFalling hi (encoded)]
          lda # <(AfterChangeGameModeFalling-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterChangeGameModeFalling hi (encoded)] [SP+0: AfterChangeGameModeFalling lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterChangeGameModeFalling hi (encoded)] [SP+1: AfterChangeGameModeFalling lo] [SP+0: ChangeGameMode hi (raw)]
          lda # <(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterChangeGameModeFalling hi (encoded)] [SP+2: AfterChangeGameModeFalling lo] [SP+1: ChangeGameMode hi (raw)] [SP+0: ChangeGameMode lo]
          ldx # 13
          jmp BS_jsr
AfterChangeGameModeFalling:


          jmp BS_return

.pend

