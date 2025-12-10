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
          bcs CheckQuadtariActive
          jmp MomentumRecoveryProcess
CheckQuadtariActive:

          lda temp1
          cmp # 2
          bcs CheckPlayer2Character
          jmp MomentumRecoveryProcess
CheckPlayer2Character:


          lda controllerStatus
          and SetQuadtariDetected
          cmp # 0
          bne CheckPlayer2NoCharacter
          jmp MomentumRecoveryNext
CheckPlayer2NoCharacter:

          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then goto MomentumRecoveryNext
          lda temp1
          cmp # 2
          bne CheckPlayer3Character
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckPlayer3Character
          jmp MomentumRecoveryNext
CheckPlayer3Character:

          lda temp1
          cmp # 2
          bne CheckPlayer3NoCharacter
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckPlayer3NoCharacter
          jmp MomentumRecoveryNext
CheckPlayer3NoCharacter:


          ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then goto MomentumRecoveryNext
          lda temp1
          cmp # 3
          bne MomentumRecoveryProcess
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne MomentumRecoveryProcess
          jmp MomentumRecoveryNext
MomentumRecoveryProcess:

          lda temp1
          cmp # 3
          bne ProcessRecoveryFrames
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne ProcessRecoveryFrames
          jmp MomentumRecoveryNext
ProcessRecoveryFrames:



.pend

MomentumRecoveryProcess .proc
          ;; Decrement recovery frames (velocity is applied by
          ;; UpdatePlayerMovement)
          ;; if playerRecoveryFrames[temp1] > 0 then let playerRecoveryFrames[temp1] = playerRecoveryFrames[temp1] - 1
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          beq SyncRecoveryFlag
          dec playerRecoveryFrames,x
SyncRecoveryFlag:

          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          beq SetRecoveryFlag
          dec playerRecoveryFrames,x
SetRecoveryFlag:


          ;; Synchronize playerState bit 3 with recovery frames
          ;; Set bit 3 (recovery flag) when recovery frames > 0
                    if playerRecoveryFrames[temp1] > 0 then let playerState[temp1] = playerState[temp1] | PlayerStateBitRecovery
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          beq ClearRecoveryFlag
          lda playerState,x
          ora PlayerStateBitRecovery
          sta playerState,x
ClearRecoveryFlag:
          ;; Clear bit 3 (recovery flag) when recovery frames = 0
          ;; if ! playerRecoveryFrames[temp1] then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitRecovery)
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne CheckVelocityDecay
          lda temp1
          asl
          tax
          lda playerState
          sta playerState,x
CheckVelocityDecay:

          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne DecayVelocity
          lda temp1
          asl
          tax
          lda playerState
          sta playerState,x
DecayVelocity:


          ;; Decay velocity if recovery frames active
          ;; Velocity decay during recovery (knockback slows down over
          ;; if ! playerRecoveryFrames[temp1] then goto MomentumRecoveryNext
          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne CheckVelocitySign
          jmp MomentumRecoveryNext
CheckVelocitySign:

          lda temp1
          asl
          tax
          lda playerRecoveryFrames,x
          bne DecayPositiveVelocity
          jmp MomentumRecoveryNext
DecayPositiveVelocity:


          ;; time)
          ;; if playerVelocityX[temp1] <= 0 then MomentumRecoveryDecayNegative
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          beq DecayPositiveVelocity
          bmi DecayPositiveVelocity
          jmp MomentumRecoveryDecayNegative
DecayPositiveVelocity:

          lda temp1
          asl
          tax
          lda playerVelocityX,x
          beq DecayPositiveVelocityLabel
          bmi DecayPositiveVelocityLabel
          jmp MomentumRecoveryDecayNegative
DecayPositiveVelocityLabel:


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
          bne MomentumRecoveryNext
          lda # 0
          sta playerVelocityXL,x
MomentumRecoveryNext:
          jmp MomentumRecoveryNext

.pend

MomentumRecoveryDecayNegative .proc
          ;; Negative velocity: decay by 1 (add 1 to make less
          ;; if playerVelocityX[temp1] >= 0 then goto MomentumRecoveryNext
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bmi DecayNegativeVelocity
          jmp MomentumRecoveryNext
DecayNegativeVelocity:

          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bmi DecayNegativeVelocityLabel
          jmp MomentumRecoveryNext
DecayNegativeVelocityLabel:


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
          bne MomentumRecoveryNext
          lda # 0
          sta playerVelocityXL,x
MomentumRecoveryNext:

.pend

MomentumRecoveryNext .proc
          ;; Next player
          inc temp1
          ;; if temp1 < 4 then goto MomentumRecoveryLoop          lda temp1          cmp 4          bcs .skip_9998          jmp
          lda temp1
          cmp # 4
          bcs ApplyMomentumAndRecoveryDone
          goto_label:

          jmp goto_label
ApplyMomentumAndRecoveryDone:

          lda temp1
          cmp # 4
          bcs ApplyMomentumAndRecoveryComplete
          jmp goto_label
ApplyMomentumAndRecoveryComplete:

          
          ;; Re-enable smart branching optimization
          ;; smartbranching on
          jsr BS_return

.pend

