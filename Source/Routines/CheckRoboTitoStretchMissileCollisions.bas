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
          rem Input: playerChar[] (global array) = character types,
          rem playerState[] (global array) = player states,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags, missileStretchHeight_R[] (global SCRAM array)
          rem = stretch missile heights, playerX[], playerY[] (global
          rem arrays) = player positions, playerHealth[] (global array)
          rem = player health
          rem Output: Stretch missile collisions detected and handled
          rem Mutates: temp1-temp7 (used for calculations),
          rem playerState[], characterStateFlags_W[],
          rem missileStretchHeight_W[], roboTitoCanStretch_W (via
          rem HandleRoboTitoStretchMissileHit)
          rem Called Routines: HandleRoboTitoStretchMissileHit -
          rem processes collision when detected
          dim CRTSMC_playerIndex = temp1 : rem Constraints: None
          dim CRTSMC_stretchHeight = temp2
          dim CRTSMC_missileX = temp3
          dim CRTSMC_missileY = temp4
          dim CRTSMC_hitPlayer = temp5
          dim CRTSMC_otherPlayer = temp6
          let CRTSMC_playerIndex = 0 : rem Loop through all players
          
CRTSMC_PlayerLoop
          if playerChar[CRTSMC_playerIndex] = CharRoboTito then CRTSMC_IsRoboTito : rem Check if player is RoboTito and stretching
          goto CRTSMC_NextPlayer
          rem Not RoboTito, skip
CRTSMC_IsRoboTito
          rem Check if stretching (not latched, ActionJumping animation
          rem = 10)
          if (characterStateFlags_R[CRTSMC_playerIndex] & 1) then CRTSMC_NextPlayer
          let temp7 = playerState[CRTSMC_playerIndex] : rem Latched to ceiling, no stretch missile
          let temp7 = temp7 & 240
          let temp7 = temp7 / 16 : rem Mask bits 4-7 (animation state)
          if temp7 = 10 then CRTSMC_IsStretching : rem Shift right by 4 to get animation state
          goto CRTSMC_NextPlayer
          rem Not in stretching animation, no stretch missile
CRTSMC_IsStretching
          
          let CRTSMC_stretchHeight = missileStretchHeight_R[CRTSMC_playerIndex] : rem Check if stretch missile has height > 0
          if CRTSMC_stretchHeight <= 0 then CRTSMC_NextPlayer
          rem No stretch missile, skip
          
          let CRTSMC_missileX = playerX[CRTSMC_playerIndex] : rem Get stretch missile position (at player position)
          let CRTSMC_missileY = playerY[CRTSMC_playerIndex]
          
          rem Check collision with other players
          rem Missile extends from playerY down by stretchHeight
          rem Bounding box: X = missileX, Y = missileY, Width = 1
          rem (missile width),
          let CRTSMC_otherPlayer = 0 : rem Height = stretchHeight
          
CRTSMC_CheckOtherPlayer
          if CRTSMC_otherPlayer = CRTSMC_playerIndex then CRTSMC_SkipSelf : rem Skip self
          
          if playerHealth[CRTSMC_otherPlayer] = 0 then CRTSMC_SkipSelf : rem Skip eliminated players
          
          rem AABB collision check
          rem Missile left/right: missileX to missileX+1 (missile width
          rem = 1)
          rem Missile top/bottom: missileY to missileY+stretchHeight
          rem Player left/right: playerX to
          rem playerX+PlayerSpriteHalfWidth*2
          if CRTSMC_missileX >= playerX[CRTSMC_otherPlayer] + PlayerSpriteHalfWidth then CRTSMC_SkipSelf : rem Player top/bottom: playerY to playerY+PlayerSpriteHeight
          rem Missile left edge >= player right edge, no collision
          if CRTSMC_missileX + 1 <= playerX[CRTSMC_otherPlayer] then CRTSMC_SkipSelf
          rem Missile right edge <= player left edge, no collision
          if CRTSMC_missileY >= playerY[CRTSMC_otherPlayer] + PlayerSpriteHeight then CRTSMC_SkipSelf
          rem Missile top edge >= player bottom edge, no collision
          if CRTSMC_missileY + CRTSMC_stretchHeight <= playerY[CRTSMC_otherPlayer] then CRTSMC_SkipSelf
          rem Missile bottom edge <= player top edge, no collision
          
          let CRTSMC_hitPlayer = CRTSMC_otherPlayer : rem Collision detected! Handle stretch missile hit
          gosub HandleRoboTitoStretchMissileHit
          goto CRTSMC_NextPlayer : rem After handling hit, skip remaining players for this RoboTito
          
CRTSMC_SkipSelf
          let CRTSMC_otherPlayer = CRTSMC_otherPlayer + 1
          if CRTSMC_otherPlayer < 4 then CRTSMC_CheckOtherPlayer
          
CRTSMC_NextPlayer
          let CRTSMC_playerIndex = CRTSMC_playerIndex + 1
          if CRTSMC_playerIndex < 4 then CRTSMC_PlayerLoop
          
          return
          
HandleRoboTitoStretchMissileHit
          rem
          rem Handle Robotito Stretch Missile Hit
          rem Processes a stretch missile hit on another player.
          rem Causes RoboTito to fall and prevents further stretching.
          rem INPUT:
          rem   temp1 = RoboTito player index (stretch missile owner)
          rem   temp5 = hit player index (victim)
          rem Process a stretch missile hit on another player, causing
          rem RoboTito to fall
          rem Input: temp1 = RoboTito player index (stretch missile
          rem owner), temp5 = hit player index (victim), playerState[]
          rem (global array) = player states, roboTitoCanStretch_R
          rem (global SCRAM) = stretch permission flags,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags
          rem Output: RoboTito falls, stretch missile removed, stretch
          rem permission cleared
          rem Mutates: missileStretchHeight_W[] (global SCRAM array) =
          rem stretch missile heights, playerState[] (global array) =
          rem player states, playerVelocityY[], playerVelocityYL[]
          rem (global arrays) = vertical velocity, roboTitoCanStretch_W
          rem (global SCRAM) = stretch permission flags,
          rem characterStateFlags_W[] (global SCRAM array) = character
          rem state flags, temp2-temp3 (used for calculations)
          rem Called Routines: None
          dim HRTSMH_roboTitoIndex = temp1 : rem Constraints: None
          dim HRTSMH_hitPlayer = temp5
          dim HRTSMH_flags = temp2
          let missileStretchHeight_W[HRTSMH_roboTitoIndex] = 0 : rem Vanish stretch missile (set height to 0)
          
          rem Set RoboTito to free fall
          let playerState[HRTSMH_roboTitoIndex] = playerState[HRTSMH_roboTitoIndex] | PlayerStateBitJumping : rem Set jumping flag (bit 2) to enable gravity
          let playerVelocityY[HRTSMH_roboTitoIndex] = TerminalVelocity : rem Set terminal velocity downward
          let playerVelocityYL[HRTSMH_roboTitoIndex] = 0
          let playerState[HRTSMH_roboTitoIndex] = (playerState[HRTSMH_roboTitoIndex] & MaskPlayerStateFlags) | ActionFallingShifted : rem Set falling animation (ActionFalling = 11)
          rem   ActionFalling
          rem MaskPlayerStateFlags masks bits 0-3, set bits 4-7 to
          
          let HRTSMH_flags = roboTitoCanStretch_R : rem Clear stretch permission flag
          let temp3 = HRTSMH_roboTitoIndex : rem Load current flags
          if temp3 = 0 then HRTSMH_ClearBit0 : rem Calculate bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp3 = 1 then HRTSMH_ClearBit1
          if temp3 = 2 then HRTSMH_ClearBit2
          let HRTSMH_flags = HRTSMH_flags & 247 : rem Player 3: clear bit 3
          goto HRTSMH_PermissionCleared : rem 247 = $F7 = clear bit 3
HRTSMH_ClearBit0
          let HRTSMH_flags = HRTSMH_flags & 254 : rem Player 0: clear bit 0
          goto HRTSMH_PermissionCleared : rem 254 = $FE = clear bit 0
HRTSMH_ClearBit1
          let HRTSMH_flags = HRTSMH_flags & 253 : rem Player 1: clear bit 1
          goto HRTSMH_PermissionCleared : rem 253 = $FD = clear bit 1
HRTSMH_ClearBit2
          let HRTSMH_flags = HRTSMH_flags & 251 : rem Player 2: clear bit 2
          rem 251 = $FB = clear bit 2
HRTSMH_PermissionCleared
          let roboTitoCanStretch_W = HRTSMH_flags
          rem Store cleared permission flags
          
          let temp3 = characterStateFlags_R[HRTSMH_roboTitoIndex] : rem Clear latched flag if set (falling from ceiling)
          let temp3 = temp3 & 254
          let characterStateFlags_W[HRTSMH_roboTitoIndex] = temp3 : rem Clear bit 0 (latched flag)
          
          return

