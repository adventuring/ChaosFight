CheckRoboTitoStretchMissileCollisions
          rem
          rem ChaosFight -
          rem Source/Routines/CheckRoboTitoStretchMissileCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Check Robotito Stretch Missile Collisions
          rem Checks collision between RoboTito stretch missiles and
          rem other
          rem   players.
          rem When a stretch missile is hit, RoboTito falls and cannot
          rem   stretch again until grounded.
          rem This routine checks all players who are RoboTito and
          rem   stretching (have active stretch missiles), and checks
          rem   collision with other players.
          
          rem Check collision between RoboTito stretch missiles and
          rem other players
          rem
          rem Input: playerCharacter[] (global array) = character types,
          rem playerState[] (global array) = player states,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags, missileStretchHeight_R[] (global SCRAM array)
          rem = stretch missile heights, playerX[], playerY[] (global
          rem arrays) = player positions, playerHealth[] (global array)
          rem = player health
          rem
          rem Output: Stretch missile collisions detected and handled
          rem
          rem Mutates: temp1-temp6 (used for calculations),
          rem playerState[], characterStateFlags_W[],
          rem missileStretchHeight_W[], roboTitoCanStretch_W (via
          rem HandleRoboTitoStretchMissileHit)
          rem
          rem Called Routines: HandleRoboTitoStretchMissileHit -
          rem processes collision when detected
          rem Constraints: None
          let temp1 = 0 : rem Loop through all players
          
CRTSMC_PlayerLoop
          if playerCharacter[temp1] = CharacterRoboTito then CRTSMC_IsRoboTito : rem Check if player is RoboTito and stretching
          goto CRTSMC_NextPlayer
CRTSMC_IsRoboTito
          rem Not RoboTito, skip
          rem Check if stretching (not latched, ActionJumping animation
          rem = 10)
          if (characterStateFlags_R[temp1] & 1) then CRTSMC_NextPlayer
          let playerStateTemp_W = playerState[temp1] : rem Latched to ceiling, no stretch missile
          let playerStateTemp_W = playerStateTemp_R & 240
          let playerStateTemp_W = playerStateTemp_R / 16 : rem Mask bits 4-7 (animation state)
          if playerStateTemp_R = 10 then CRTSMC_IsStretching : rem Shift right by 4 to get animation state
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
          if temp6 = temp1 then CRTSMC_SkipSelf : rem Skip self
          
          if playerHealth[temp6] = 0 then CRTSMC_SkipSelf : rem Skip eliminated players
          
          rem AABB collision check
          rem Missile left/right: missileX to missileX+1 (missile width
          rem = 1)
          rem Missile top/bottom: missileY to missileY+stretchHeight
          rem Player left/right: playerX to
          rem playerX+PlayerSpriteHalfWidth*2
          if temp3 >= playerX[temp6] + PlayerSpriteHalfWidth then CRTSMC_SkipSelf : rem Player top/bottom: playerY to playerY+PlayerSpriteHeight
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
          rem
          rem Handle Robotito Stretch Missile Hit
          rem Processes a stretch missile hit on another player.
          rem Causes RoboTito to fall and prevents further stretching.
          rem
          rem INPUT:
          rem   temp1 = RoboTito player index (stretch missile owner)
          rem   temp5 = hit player index (victim)
          rem Process a stretch missile hit on another player, causing
          rem RoboTito to fall
          rem
          rem Input: temp1 = RoboTito player index (stretch missile
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
          
          let temp2 = roboTitoCanStretch_R : rem Clear stretch permission flag
          let temp3 = temp1 : rem Load current flags
          if temp3 = 0 then HRTSMH_ClearBit0 : rem Calculate bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp3 = 1 then HRTSMH_ClearBit1
          if temp3 = 2 then HRTSMH_ClearBit2
          let temp2 = temp2 & 247 : rem Player 3: clear bit 3
          goto HRTSMH_PermissionCleared : rem 247 = $F7 = clear bit 3
HRTSMH_ClearBit0
          let temp2 = temp2 & 254 : rem Player 0: clear bit 0
          goto HRTSMH_PermissionCleared : rem 254 = $FE = clear bit 0
HRTSMH_ClearBit1
          let temp2 = temp2 & 253 : rem Player 1: clear bit 1
          goto HRTSMH_PermissionCleared : rem 253 = $FD = clear bit 1
HRTSMH_ClearBit2
          let temp2 = temp2 & 251 : rem Player 2: clear bit 2
HRTSMH_PermissionCleared
          rem 251 = $FB = clear bit 2
          let roboTitoCanStretch_W = temp2
          rem Store cleared permission flags
          
          let temp3 = characterStateFlags_R[temp1] : rem Clear latched flag if set (falling from ceiling)
          let temp3 = temp3 & 254
          let characterStateFlags_W[temp1] = temp3 : rem Clear bit 0 (latched flag)
          
          return

