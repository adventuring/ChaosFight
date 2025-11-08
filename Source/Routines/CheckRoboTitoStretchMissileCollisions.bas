          rem ChaosFight - Source/Routines/CheckRoboTitoStretchMissileCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckRoboTitoStretchMissileCollisions
          rem Detects RoboTito stretch missile hits against other players
          rem Inputs: playerCharacter[], playerState[], characterStateFlags_R[],
          rem         missileStretchHeight_R[], playerX[], playerY[], playerHealth[]
          rem Outputs: Updates via HandleRoboTitoStretchMissileHit when collisions occur
          rem Mutates: temp1-temp6, playerState[], characterStateFlags_W[],
          rem          missileStretchHeight_W[], roboTitoCanStretch_W
          rem Calls: HandleRoboTitoStretchMissileHit
          rem Constraints: None

          let temp1 = 0 : rem Loop through all players
          
CRTSMC_PlayerLoop
          rem Check if player is RoboTito and stretching
          if playerCharacter[temp1] = CharacterRoboTito then CRTSMC_IsRoboTito
          goto CRTSMC_NextPlayer
CRTSMC_IsRoboTito
          rem Not RoboTito, skip
          rem Check if stretching (not latched, ActionJumping animation
          rem = 10)
          if (characterStateFlags_R[temp1] & 1) then CRTSMC_NextPlayer
          let playerStateTemp_W = playerState[temp1] : rem Latched to ceiling, no stretch missile
          let playerStateTemp_W = playerStateTemp_R & 240
          let playerStateTemp_W = playerStateTemp_R / 16 : rem Mask bits 4-7 (animation state)
          rem Shift right by 4 to get animation state
          if playerStateTemp_R = 10 then CRTSMC_IsStretching
          goto CRTSMC_NextPlayer
CRTSMC_IsStretching
          rem Not in stretching animation, no stretch missile
          
          let temp2 = missileStretchHeight_R[temp1] : rem Check if stretch missile has height > 0
          if temp2 <= 0 then CRTSMC_NextPlayer
          rem No stretch missile, skip
          
          let temp3 = playerX[temp1] : rem Get stretch missile position (at player position)
          let temp4 = playerY[temp1]
          
          rem Check collision with other players
          rem Missile extends from playerY down by stretchHeight
          rem Bounding box: X = missileX, Y = missileY, Width = 1
          rem (missile width),
          let temp6 = 0 : rem Height = stretchHeight
          
CRTSMC_CheckOtherPlayer
          rem Skip self
          if temp6 = temp1 then CRTSMC_SkipSelf
          
          rem Skip eliminated players
          
          if playerHealth[temp6] = 0 then CRTSMC_SkipSelf
          
          rem AABB collision check
          rem Missile left/right: missileX to missileX+1 (missile width
          rem = 1)
          rem Missile top/bottom: missileY to missileY+stretchHeight
          rem Player left/right: playerX to
          rem playerX+PlayerSpriteHalfWidth*2
          rem Player top/bottom: playerY to playerY+PlayerSpriteHeight
          if temp3 >= playerX[temp6] + PlayerSpriteHalfWidth then CRTSMC_SkipSelf
          rem Missile left edge >= player right edge, no collision
          if temp3 + 1 <= playerX[temp6] then CRTSMC_SkipSelf
          rem Missile right edge <= player left edge, no collision
          if temp4 >= playerY[temp6] + PlayerSpriteHeight then CRTSMC_SkipSelf
          rem Missile top edge >= player bottom edge, no collision
          if temp4 + temp2 <= playerY[temp6] then CRTSMC_SkipSelf
          rem Missile bottom edge <= player top edge, no collision
          
          let temp5 = temp6 : rem Collision detected! Handle stretch missile hit
          gosub HandleRoboTitoStretchMissileHit
          goto CRTSMC_NextPlayer : rem After handling hit, skip remaining players for this RoboTito
          
CRTSMC_SkipSelf
          let temp6 = temp6 + 1
          if temp6 < 4 then CRTSMC_CheckOtherPlayer
          
CRTSMC_NextPlayer
          let temp1 = temp1 + 1
          if temp1 < 4 then CRTSMC_PlayerLoop
          
          return
          
HandleRoboTitoStretchMissileHit
          rem Resolves stretch missile collisions and resets stretch state
          rem Inputs: temp1 = RoboTito player index, temp5 = hit player index
          rem Outputs: Updates playerState[], characterStateFlags_W[], roboTitoCanStretch_W
          rem Mutates: temp2-temp6 (scratch), missileStretchHeight_W[]
          rem Calls: None
          rem Constraints: Keep contiguous with CRTSMC logic for bank locality
          rem owner), temp5 = hit player index (victim), playerState[]
          rem (global array) = player states, roboTitoCanStretch_R
          rem (global SCRAM) = stretch permission flags,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags
          rem
          rem Output: RoboTito falls, stretch missile removed, stretch
          rem permission cleared
          rem
          rem Mutates: missileStretchHeight_W[] (global SCRAM array) =
          rem stretch missile heights, playerState[] (global array) =
          rem player states, playerVelocityY[], playerVelocityYL[]
          rem (global arrays) = vertical velocity, roboTitoCanStretch_W
          rem (global SCRAM) = stretch permission flags,
          rem characterStateFlags_W[] (global SCRAM array) = character
          rem state flags, temp2-temp3 (used for calculations)
          rem
          rem Called Routines: None
          rem Constraints: None
          let missileStretchHeight_W[temp1] = 0 : rem Vanish stretch missile (set height to 0)
          
          rem Set RoboTito to free fall
          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping : rem Set jumping flag (bit 2) to enable gravity
          let playerVelocityY[temp1] = TerminalVelocity : rem Set terminal velocity downward
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionFallingShifted : rem Set falling animation (ActionFalling = 11)
          rem   ActionFalling
          rem MaskPlayerStateFlags masks bits 0-3, set bits 4-7 to
          
          rem Optimized: Clear stretch permission flag with formula
          let temp2 = roboTitoCanStretch_R
          let temp3 = 1
          for temp4 = 0 to temp1 - 1
            let temp3 = temp3 * 2
          next
          let temp2 = temp2 & (255 - temp3) : rem Clear the appropriate bit
          rem 251 = $FB = clear bit 2
          let roboTitoCanStretch_W = temp2
          rem Store cleared permission flags
          
          let temp3 = characterStateFlags_R[temp1] : rem Clear latched flag if set (falling from ceiling)
          let temp3 = temp3 & 254
          let characterStateFlags_W[temp1] = temp3 : rem Clear bit 0 (latched flag)
          
          return

