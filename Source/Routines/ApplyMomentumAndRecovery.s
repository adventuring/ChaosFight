;;; ChaosFight - Source/Routines/ApplyMomentumAndRecovery.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Research 2025-11-11: Keeping this routine bank8-only after dasm shrieked about
;;; duplicate .MomentumRecoveryNext labels trying to walk past $10000. One copy
          ;; is plenty; see Issue #875 if you are tempted to clone it again.

ApplyMomentumAndRecovery .proc

          ;; Returns: Far (return otherbank)
          ;; Apply Momentum and Recovery
          ;; Updates recovery frames and applies velocity during
          ;; hitstun.
          ;; Velocity gradually decays over time.
          ;; Refactored to loop through all players (0-3)
          ;; Updates recovery frames and applies velocity decay during
          ;; hitstun for all players
          ;; Input: playerRecoveryFrames[] (global array) = recovery
          ;; frame counts, playerVelocityX[], playerVelocityXL[]
          ;; (global arrays) = horizontal velocity, playerState[]
          ;; (global array) = player states, controllerStatus (global)
          ;; = controller state, playerCharacter[] selections
          ;; (global SCRAM) = player 3/4 selections,
          ;; PlayerStateBitRecovery (global constant) = recovery flag
          ;; bit
          ;; Output: Recovery frames decremented, recovery flag
          ;; synchronized, velocity decayed during recovery
          ;; Mutates: temp1 (used for player index),
          ;; playerRecoveryFrames[] (global array) = recovery frame
          ;; counts, playerState[] (global array) = player sta

          ;; (recovery flag bit 3), playerVelocityX[],
          ;; playerVelocityXL[] (global arrays) = horizontal velocity
          ;; (decayed)
          ;; Called Routines: None
          ;; Constraints: None
          ;; Loop through all players (0-3)
          lda # 0
          sta temp1
.pend

MomentumRecoveryLoop .proc
          ;; Check if player is active (P1/P2 always active, P3/P4 need
          ;; Quadtari)
          ;; Players 0-1 always active
          ;; if temp1 < 2 then MomentumRecoveryProcess
          lda temp1
          cmp # 2
          bcs skip_1629
          jmp MomentumRecoveryProcess
skip_1629:

          lda temp1
          cmp # 2
          bcs skip_7629
          jmp MomentumRecoveryProcess
skip_7629:


          lda controllerStatus
          and SetQuadtariDetected
          cmp # 0
          bne skip_8430
          jmp MomentumRecoveryNext
skip_8430:

          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then goto MomentumRecoveryNext
          lda temp1
          cmp # 2
          bne skip_853
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_853
          jmp MomentumRecoveryNext
skip_853:

          lda temp1
          cmp # 2
          bne skip_1820
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_1820
          jmp MomentumRecoveryNext
skip_1820:


          ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then goto MomentumRecoveryNext
          lda temp1
          cmp # 3
          bne skip_8242
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_8242
          jmp MomentumRecoveryNext
skip_8242:

          lda temp1
          cmp # 3
          bne skip_5063
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_5063
          jmp MomentumRecoveryNext
skip_5063:



.pend

MomentumRecoveryProcess .proc
          ;; Decrement recovery frames (velocity is applied by
          ;; UpdatePlayerMovement)
          ;; if playerRecoveryFrames[temp1] > 0 then let playerRecoveryFrames[temp1] = playerRecoveryFrames[temp1] - 1
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          beq skip_2355
          dec playerRecoveryFrames,x
skip_2355:

          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          beq skip_9119
          dec playerRecoveryFrames,x
skip_9119:


          ;; Synchronize playerState bit 3 with recovery frames
          ;; Set bit 3 (recovery flag) when recovery frames > 0
                    if playerRecoveryFrames[temp1] > 0 then let playerState[temp1] = playerState[temp1] | PlayerStateBitRecovery
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          beq skip_6729
          lda playerState,x
          ora PlayerStateBitRecovery
          sta playerState,x
skip_6729:
          ;; Clear bit 3 (recovery flag) when recovery frames = 0
          ;; if ! playerRecoveryFrames[temp1] then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitRecovery)
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne skip_7596
          lda temp1
          asl
          tax
          lda playerState
          sta playerState,x
skip_7596:

          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne skip_3094
          lda temp1
          asl
          tax
          lda playerState
          sta playerState,x
skip_3094:


          ;; Decay velocity if recovery frames active
          ;; Velocity decay during recovery (knockback slows down over
          ;; if ! playerRecoveryFrames[temp1] then goto MomentumRecoveryNext
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne skip_6205
          jmp MomentumRecoveryNext
skip_6205:

          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne skip_4277
          jmp MomentumRecoveryNext
skip_4277:


          ;; time)
          ;; if playerVelocityX[temp1] <= 0 then MomentumRecoveryDecayNegative
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          beq skip_7633
          bmi skip_7633
          jmp MomentumRecoveryDecayNegative
skip_7633:

          lda temp1
          asl
          tax
          lda playerVelocityX,x
          beq skip_2625
          bmi skip_2625
          jmp MomentumRecoveryDecayNegative
skip_2625:


          ;; Positive velocity: decay by 1
          ;; let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          lda temp1
          asl
          tax
          dec playerVelocityX,x

          lda temp1
          asl
          tax
          dec playerVelocityX,x

          ;; Also decay subpixel if integer velocity is zero
                    if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bne skip_5069
          lda # 0
          sta playerVelocityXL,x
skip_5069:
          jmp MomentumRecoveryNext

.pend

MomentumRecoveryDecayNegative .proc
          ;; Negative velocity: decay by 1 (add 1 to make less
          ;; if playerVelocityX[temp1] >= 0 then goto MomentumRecoveryNext
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bmi skip_8611
          jmp MomentumRecoveryNext
skip_8611:

          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bmi skip_7514
          jmp MomentumRecoveryNext
skip_7514:


          ;; negative)
          ;; let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          lda temp1
          asl
          tax
          inc playerVelocityX,x

          lda temp1
          asl
          tax
          inc playerVelocityX,x

          ;; Also decay subpixel if integer velocity is zero
                    if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bne skip_5069
          lda # 0
          sta playerVelocityXL,x
skip_5069:

.pend

MomentumRecoveryNext .proc
          ;; Next player
          inc temp1
          ;; if temp1 < 4 then goto MomentumRecoveryLoop          lda temp1          cmp 4          bcs .skip_9998          jmp
          lda temp1
          cmp # 4
          bcs skip_6719
          goto_label:

          jmp goto_label
skip_6719:

          lda temp1
          cmp # 4
          bcs skip_8865
          jmp goto_label
skip_8865:

          
          ;; Re-enable smart branching optimization
          ;; smartbranching on
          jsr BS_return

.pend

