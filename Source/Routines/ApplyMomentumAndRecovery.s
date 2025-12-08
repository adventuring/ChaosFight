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
          ;; ;; if temp1 < 2 then MomentumRecoveryProcess
          ;; lda temp1 (duplicate)
          cmp # 2
          bcs skip_1629
          jmp MomentumRecoveryProcess
skip_1629:

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bcs skip_7629 (duplicate)
          ;; jmp MomentumRecoveryProcess (duplicate)
skip_7629:


          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; cmp # 0 (duplicate)
          bne skip_8430
          ;; jmp MomentumRecoveryNext (duplicate)
skip_8430:

          ;; ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then goto MomentumRecoveryNext
          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_853 (duplicate)
          ;; lda 2 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_853 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_853:

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_1820 (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_1820 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_1820:


          ;; ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then goto MomentumRecoveryNext
          ;; lda temp1 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_8242 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_8242 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_8242:

          ;; lda temp1 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_5063 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_5063 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_5063:



.pend

MomentumRecoveryProcess .proc
          ;; Decrement recovery frames (velocity is applied by
          ;; UpdatePlayerMovement)
          ;; ;; if playerRecoveryFrames[temp1] > 0 then let playerRecoveryFrames[temp1] = playerRecoveryFrames[temp1] - 1
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          beq skip_2355
          dec playerRecoveryFrames,x
skip_2355:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; beq skip_9119 (duplicate)
          ;; dec playerRecoveryFrames,x (duplicate)
skip_9119:


          ;; Synchronize playerState bit 3 with recovery frames
          ;; Set bit 3 (recovery flag) when recovery frames > 0
                    ;; if playerRecoveryFrames[temp1] > 0 then let playerState[temp1] = playerState[temp1] | PlayerStateBitRecovery
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; beq skip_6729 (duplicate)
          ;; lda playerState,x (duplicate)
          ora PlayerStateBitRecovery
          ;; sta playerState,x (duplicate)
skip_6729:
          ;; Clear bit 3 (recovery flag) when recovery frames = 0
          ;; ;; if ! playerRecoveryFrames[temp1] then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitRecovery)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; bne skip_7596 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState (duplicate)
          ;; sta playerState,x (duplicate)
skip_7596:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; bne skip_3094 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState (duplicate)
          ;; sta playerState,x (duplicate)
skip_3094:


          ;; Decay velocity if recovery frames active
          ;; Velocity decay during recovery (knockback slows down over
          ;; ;; if ! playerRecoveryFrames[temp1] then goto MomentumRecoveryNext
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; bne skip_6205 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_6205:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerRecoveryFrames,x (duplicate)
          ;; bne skip_4277 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_4277:


          ;; time)
          ;; ;; if playerVelocityX[temp1] <= 0 then MomentumRecoveryDecayNegative
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; beq skip_7633 (duplicate)
          bmi skip_7633
          ;; jmp MomentumRecoveryDecayNegative (duplicate)
skip_7633:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; beq skip_2625 (duplicate)
          ;; bmi skip_2625 (duplicate)
          ;; jmp MomentumRecoveryDecayNegative (duplicate)
skip_2625:


          ;; Positive velocity: decay by 1
          ;; ;; let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerVelocityX,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerVelocityX,x (duplicate)

          ;; Also decay subpixel if integer velocity is zero
                    ;; if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; bne skip_5069 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
skip_5069:
          ;; jmp MomentumRecoveryNext (duplicate)

.pend

MomentumRecoveryDecayNegative .proc
          ;; Negative velocity: decay by 1 (add 1 to make less
          ;; ;; if playerVelocityX[temp1] >= 0 then goto MomentumRecoveryNext
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; bmi skip_8611 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_8611:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; bmi skip_7514 (duplicate)
          ;; jmp MomentumRecoveryNext (duplicate)
skip_7514:


          ;; negative)
          ;; ;; let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          inc playerVelocityX,x

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerVelocityX,x (duplicate)

          ;; Also decay subpixel if integer velocity is zero
                    ;; if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; bne skip_5069 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
;; skip_5069: (duplicate)

.pend

MomentumRecoveryNext .proc
          ;; Next player
          ;; inc temp1 (duplicate)
          ;; ;; if temp1 < 4 then goto MomentumRecoveryLoop          lda temp1          cmp 4          bcs .skip_9998          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 4 (duplicate)
          ;; bcs skip_6719 (duplicate)
          goto_label:

          ;; jmp goto_label (duplicate)
skip_6719:

          ;; lda temp1 (duplicate)
          ;; cmp # 4 (duplicate)
          ;; bcs skip_8865 (duplicate)
          ;; jmp goto_label (duplicate)
skip_8865:

          
          ;; Re-enable smart branching optimization
          ;; smartbranching on
          jsr BS_return

.pend

