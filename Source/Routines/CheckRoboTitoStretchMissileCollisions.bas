          rem ChaosFight - Source/Routines/CheckRoboTitoStretchMissileCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckRoboTitoStretchMissileCollisions
          asm
CheckRoboTitoStretchMissileCollisions
end
          rem Detects RoboTito stretch missile hits against other players
          rem Inputs: playerCharacter[], playerState[], characterStateFlags_R[],
          rem         missileStretchHeight_R[], playerX[], playerY[], playerHealth[]
          rem Outputs: Updates via HandleRoboTitoStretchMissileHit when collisions occur
          rem Mutates: temp1-temp6, playerState[], characterStateFlags_W[],
          rem          missileStretchHeight_W[], roboTitoCanStretch_W
          rem Calls: HandleRoboTitoStretchMissileHit
          rem Constraints: None

          let temp1 = 0
          rem Loop through all players

CRTSMC_PlayerLoop
          rem Check if player is RoboTito and stretching
          if playerCharacter[temp1] = CharacterRoboTito then CRTSMC_IsRoboTito
          goto CRTSMC_NextPlayer

CRTSMC_IsRoboTito
          rem Player is RoboTito, check stretching state
          rem Check if stretching (not latched, ActionJumping animation
          rem = 10)
          rem Latched to ceiling, no stretch missile
          let temp5 = characterStateFlags_R[temp1] & 1
          if temp5 then CRTSMC_NextPlayer
          let playerStateTemp_W = playerState[temp1]
          rem Mask bits 4-7 (animation state)
          let playerStateTemp_W = playerStateTemp_W & MaskPlayerStateAnimation
          rem Shift right by 4 to get animation state
          let playerStateTemp_W = playerStateTemp_W / 16
          if playerStateTemp_W = 10 then CRTSMC_IsStretching
          goto CRTSMC_NextPlayer

CRTSMC_IsStretching
          rem In stretching animation, check for stretch missile

          let temp2 = missileStretchHeight_R[temp1]
          rem Check if stretch missile has height > 0
          if !temp2 then CRTSMC_NextPlayer

          let temp3 = playerX[temp1] + 7
          let temp4 = playerY[temp1] + 16

          rem Check collision with other players
          rem Missile extends from playerY down by stretchHeight
          rem Bounding box: X = missileX, Y = missileY, Width = 4, Height = stretchHeight
          let temp6 = 0

CRTSMC_CheckOtherPlayer
          rem Skip self
          if temp6 = temp1 then CRTSMC_DoneSelf

          rem Skip eliminated players

          if !playerHealth[temp6] then CRTSMC_DoneSelf

          rem AABB collision check
          rem Missile left/right: missileX to missileX+1 (missile width
          rem = 1)
          rem Missile top/bottom: missileY to missileY+stretchHeight
          rem Player left/right: playerX to
          rem playerX+PlayerSpriteHalfWidth*2
          rem Player top/bottom: playerY to playerY+PlayerSpriteHeight
          if temp3 >= playerX[temp6] + PlayerSpriteHalfWidth then CRTSMC_DoneSelf
          rem Missile left edge >= player right edge, no collision
          if temp3 + 1 <= playerX[temp6] then CRTSMC_DoneSelf
          rem Missile right edge <= player left edge, no collision
          if temp4 >= playerY[temp6] + PlayerSpriteHeight then CRTSMC_DoneSelf
          rem Missile top edge >= player bottom edge, no collision
          if temp4 + temp2 <= playerY[temp6] then CRTSMC_DoneSelf
          rem Missile bottom edge <= player top edge, no collision

          let temp5 = temp6
          rem Collision detected! Handle stretch missile hit
          gosub HandleRoboTitoStretchMissileHit

          goto CRTSMC_NextPlayer

          rem After handling hit, skip remaining players for this RoboTito
CRTSMC_DoneSelf
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
          let missileStretchHeight_W[temp1] = 0
          rem Vanish stretch missile (set height to 0)

          rem Set RoboTito to free fall
          playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionFallingShifted

          rem Clear stretch permission flag for this player
          let temp2 = roboTitoCanStretch_R
          let temp3 = 1
          if temp1 > 0 then for temp4 = 1 to temp1 : temp3 = temp3 * 2 : next
          let temp2 = temp2 & (255 - temp3)
          rem Clear the appropriate bit
          let roboTitoCanStretch_W = temp2
          rem Store cleared permission flags

          let temp3 = characterStateFlags_R[temp1]
          rem Clear latched flag if set (falling from ceiling)
          let temp3 = temp3 & 254
          let characterStateFlags_W[temp1] = temp3
          rem Clear bit 0 (latched flag)

          return

