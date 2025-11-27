          rem ChaosFight - Source/Routines/ApplyMomentumAndRecovery.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Research 2025-11-11: Keeping this routine bank8-only after dasm shrieked about
          rem   duplicate .MomentumRecoveryNext labels trying to walk past $10000. One copy
          rem   is plenty; see Issue #875 if you are tempted to clone it again.
ApplyMomentumAndRecovery
          rem Returns: Far (return otherbank)
          asm
ApplyMomentumAndRecovery

end
          rem
          rem Returns: Far (return otherbank)
          rem Apply Momentum And Recovery
          rem Updates recovery frames and applies velocity during
          rem   hitstun.
          rem Velocity gradually decays over time.
          rem Refactored to loop through all players (0-3)
          rem Updates recovery frames and applies velocity decay during
          rem hitstun for all players
          rem
          rem Input: playerRecoveryFrames[] (global array) = recovery
          rem frame counts, playerVelocityX[], playerVelocityXL[]
          rem (global arrays) = horizontal velocity, playerState[]
          rem (global array) = player states, controllerStatus (global)
          rem = controller state, playerCharacter[] selections
          rem (global SCRAM) = player 3/4 selections,
          rem PlayerStateBitRecovery (global constant) = recovery flag
          rem bit
          rem
          rem Output: Recovery frames decremented, recovery flag
          rem synchronized, velocity decayed during recovery
          rem
          rem Mutates: temp1 (used for player index),
          rem playerRecoveryFrames[] (global array) = recovery frame
          rem counts, playerState[] (global array) = player states
          rem (recovery flag bit 3), playerVelocityX[],
          rem playerVelocityXL[] (global arrays) = horizontal velocity
          rem (decayed)
          rem
          rem Called Routines: None
          rem Constraints: None
          rem Loop through all players (0-3)
          let temp1 = 0
MomentumRecoveryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem Quadtari)
          rem Players 0-1 always active
          if temp1 < 2 then MomentumRecoveryProcess
          if (controllerStatus & SetQuadtariDetected) = 0 then goto MomentumRecoveryNext
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto MomentumRecoveryNext
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto MomentumRecoveryNext

MomentumRecoveryProcess
          rem Decrement recovery frames (velocity is applied by
          rem UpdatePlayerMovement)
          if playerRecoveryFrames[temp1] > 0 then let playerRecoveryFrames[temp1] = playerRecoveryFrames[temp1] - 1

          rem Synchronize playerState bit 3 with recovery frames

          rem Set bit 3 (recovery flag) when recovery frames > 0
          if playerRecoveryFrames[temp1] > 0 then let playerState[temp1] = playerState[temp1] | PlayerStateBitRecovery
          rem Clear bit 3 (recovery flag) when recovery frames = 0
          if ! playerRecoveryFrames[temp1] then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitRecovery)

          rem Decay velocity if recovery frames active

          rem Velocity decay during recovery (knockback slows down over
          if ! playerRecoveryFrames[temp1] then goto MomentumRecoveryNext
          rem time)
          if playerVelocityX[temp1] <= 0 then MomentumRecoveryDecayNegative
          rem Positive velocity: decay by 1
          let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          goto MomentumRecoveryNext
MomentumRecoveryDecayNegative
          rem Negative velocity: decay by 1 (add 1 to make less
          if playerVelocityX[temp1] >= 0 then goto MomentumRecoveryNext
          rem   negative)
          let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0

MomentumRecoveryNext
          rem Next player
          let temp1 = temp1 + 1
          if temp1 < 4 then goto MomentumRecoveryLoop

          rem Re-enable smart branching optimization
          rem smartbranching on

          return thisbank

