;;; ChaosFight - Source/Routines/GameLoopMain.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Game Loop - Main Loop
;;; Main gameplay loop that orchestrates all game systems.
;;; Called every frame during active gameplay.
          ;; SEQUENCE PER FRAME:

ReadEnhancedButtons:
          ;; Returns: Near (return thisbank)
          ;; Read enhanced controller buttons (Genesis Button C, Joy2B+ Button II)
          ;; Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)
          ;; Stores button states in enhancedButtonStates for use throughout the frame
          ;;
          ;; Input: controllerStatus (global) = controller capabilities,
          ;; INPT0-3 (hardware) = paddle port sta

          ;;
          ;; Output: enhancedButtonStates_W = bit-packed button sta

          ;; (Bit 0=P1, bit 1=P2, Bits 2-3=always 0)
          ;;
          ;; Mutates: enhancedButtonStates_W, temp1 (used for calculations)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be called early in game loop before input processing
          lda # 0
          sta temp1

          ;; Player 1 (INPT0) - Genesis/Joy2b+ Button C/II
          ;; if controllerStatus & SetLeftPortGenesis then if !INPT0{7} then temp1 = temp1 | 1
          lda controllerStatus
          and # SetLeftPortGenesis
          beq GLM_CheckJoy2bPlus
          lda INPT0
          bmi GLM_CheckJoy2bPlus
          lda temp1
          ora # 1
          sta temp1
GLM_CheckJoy2bPlus:
          ;; if controllerStatus & SetLeftPortJoy2bPlus then if !INPT0{7} then temp1 = temp1 | 1
          lda controllerStatus
          and # SetLeftPortJoy2bPlus
          beq CheckPlayer2Enhanced

          bit INPT0
          bmi CheckPlayer2Enhanced

          lda temp1
          ora # 1
          sta temp1

CheckPlayer2Enhanced:

          ;; Player 2 (INPT2) - Genesis/Joy2b+ Button C/II
          lda INPT2
          and # 128
          cmp # 0
          bne ReadEnhancedButtonsDone

          ;; let temp1 = temp1 | 2
          lda temp1
          ora # 2
          sta temp1

ReadEnhancedButtonsDone:


          ;; Players 3-4 cannot have enhanced controllers (require Quadtari)
          ;; Bits 2-3 remain 0
          lda temp1
          sta enhancedButtonStates_W
          rts

GameMainLoop .proc



          ;; 1. Handle console switches (pause, reset, color)
          ;; Returns: Far (return otherbank)
          ;; 2. Handle player input via PlayerInput.bas
          ;; 3. Apply physics (gravity, momentum, collisions)
          ;; 4. Apply special movement (character-specific)
          ;; 5. Update attacks and check collisions
          ;; 6. Update missiles
          ;; 7. Set sprite positions
          ;; 8. Render sprites
          ;; 9. Display health
          ;; 10. Draw screen
          ;; AVAILABLE VARIABLES:
          ;; frame - Frame counter
          ;; systemFlags - bit 4 (SystemFlagGameStatePaused):
          ;; 0=normal, 1=paused
          bit 3 (SystemFlagGameStateEnding): 0=normal, 1=ending
          ;; qtcontroller - Quadtari multiplexing sta

          ;; All Player arrays (X,y, State, Health, etc.)
          ;; Main gameplay loop that orchestrates all game systems
          ;;
          ;; Input: All player state arrays, controller inputs, system
          ;; flags
          ;;
          ;; Output: All game systems updated for one frame
          ;;
          ;; Mutates: All game state (players, missiles, animations,
          ;; physics, etc.), frame counter
          ;;
          ;; Called Routines: ReadEnhancedButtons,
          ;; HandleConsoleSwitches (bank13),
          ;; InputHandleAllPlayers (bank8), UpdateGuardTimers (bank6),
          ;; UpdateCharacterAnimations (bank12),
          ;; UpdatePlayerMovement (bank8), PhysicsApplyGravity (bank13),
          ;; ApplyMomentumAndRecovery (bank8),
          ;; CheckBoundaryCollisions (bank10),
          ;; CheckPlayfieldCollisionAllDirections (bank10),
          ;; CheckAllPlayerCollisions (bank8),
          ;; ProcessAllAttacks (bank7), CheckAllPlayerEliminations (bank14),
          ;; UpdateAllMissiles (bank7),
          ;; CheckRoboTitoStretchMissileCollisions (bank10), SetPlayerSprites (bank2),
          ;; UpdatePlayer12HealthBars (bank6),
          ;; UpdatePlayer34HealthBars (bank6), UpdateSoundEffect
          ;; (bank15)
          ;;
          ;; Constraints: Must be colocated with
          ;; GameMainLoopQuadtariSkip, CheckGameEndTransition,
          ;; TransitionToWinner, GameEndCheckDone (all
          ;; called via goto)
          ;; Entry point for main gameplay loop (called
          ;; from MainLoop)
          ;; CRITICAL: Guard against being called in wrong game mode
          ;; This prevents crashes when gameMode is corrupted or incorrectly set
          ;; Only run game logic when actually in game mode (ModeGame = 6)
          lda gameMode
          cmp ModeGame
          bne GameMainLoopPaused
          jmp GameMainLoopContinue
GameMainLoopPaused:


          jsr BS_return

GameMainLoopContinue
          ;; OVSCAN HANDLER: Input reading and sound updates only
          ;; Heavy game logic moved to vblank handler (VblankModeGameMain)
          ;; This runs during overscan period before drawscreen is called

          ;; Read enhanced controller buttons (Genesis Button C, Joy2B+
          ;; II/III)
          jsr ReadEnhancedButtons

          ;; Handle console switches (in Bank 13)
          ;; Cross-bank call to HandleConsoleSwitches in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(HandleConsoleSwitches-1)
          pha
          lda # <(HandleConsoleSwitches-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          ;; Handle all player input (with Quadtari multiplexing) (in Bank 8)
          ;; Cross-bank call to InputHandleAllPlayers in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(InputHandleAllPlayers-1)
          pha
          lda # <(InputHandleAllPlayers-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:


          ;; Update guard timers (duration and cooldown)
          ;; Cross-bank call to UpdateGuardTimers in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdateGuardTimers-1)
          pha
          lda # <(UpdateGuardTimers-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; Update attack cooldown timers (in Bank 12)
          ;; Cross-bank call to UpdateAttackCooldowns in bank 12
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdateAttackCooldowns-1)
          pha
          lda # <(UpdateAttackCooldowns-1)
          pha
                    ldx # 11
          jmp BS_jsr
return_point:


          ;; Issue #1177: Update Frooty charge system every frame
          ;; TODO: #1254 for currentPlayer = 0 to 3
          ;; if currentPlayer >= 2 then goto FrootyChargeQuadtariCheck
          lda currentPlayer
          cmp 2

          bcc FrootyChargeUpdate

          jmp FrootyChargeQuadtariCheck

          FrootyChargeQuadtariCheck:

          jmp FrootyChargeUpdate

.pend

FrootyChargeQuadtariCheck .proc
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne FrootyChargeUpdate
          jmp FrootyChargeNext
FrootyChargeUpdate:


.pend

FrootyChargeUpdate .proc
          ;; Cross-bank call to FrootyAttack in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(FrootyAttack-1)
          pha
          lda # <(FrootyAttack-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:


.pend

FrootyChargeNext .proc
.pend

next_label_1_L253:.proc

          ;; Update sound effects (game mode 6 only)
          ;; Sound updates must happen in overscan so they are ready for vblank
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


          ;; Heavy game logic (physics, collisions, rendering) moved to vblank handler
          ;; This allows better time distribution: overscan for input/sound, vblank for logic
          ;; Vblank handler is called from kernel vblank_bB_code hook during vblank period

          ;; Frame counter is automatically incremented by batariBASIC
          ;; kernel
          ;; Heavy game logic (physics, collisions, rendering) is handled
          ;; in vblank handler (VblankModeGameMain) for better time distribution
          jsr BS_return

.pend

GameMainLoopPaused .proc
          ;; Game is paused - skip all movement/physics/animation updates
          ;; Returns: Far (return otherbank)
          ;; but still allow console switch handling for unpause
          ;; Vblank handler will also check pause state and skip logic
          jsr BS_return

.pend

