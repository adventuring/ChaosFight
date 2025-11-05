          rem ChaosFight - Source/Routines/CheckRoboTitoStretchMissileCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem CHECK ROBOTITO STRETCH MISSILE COLLISIONS
          rem ==========================================================
          rem Checks collision between RoboTito stretch missiles and other
          rem   players.
          rem When a stretch missile is hit, RoboTito falls and cannot
          rem   stretch again until grounded.

          rem This routine checks all players who are RoboTito and
          rem   stretching (have active stretch missiles), and checks
          rem   collision with other players.
          
CheckRoboTitoStretchMissileCollisions
          dim CRTSMC_playerIndex = temp1
          dim CRTSMC_stretchHeight = temp2
          dim CRTSMC_missileX = temp3
          dim CRTSMC_missileY = temp4
          dim CRTSMC_hitPlayer = temp5
          dim CRTSMC_otherPlayer = temp6
          rem Loop through all players
          let CRTSMC_playerIndex = 0
          
CRTSMC_PlayerLoop
          rem Check if player is RoboTito and stretching
          if playerChar[CRTSMC_playerIndex] = CharRoboTito then CRTSMC_IsRoboTito
          goto CRTSMC_NextPlayer
          rem Not RoboTito, skip
CRTSMC_IsRoboTito
          rem Check if stretching (not latched, ActionJumping animation = 10)
          if (characterStateFlags_R[CRTSMC_playerIndex] & 1) then CRTSMC_NextPlayer
          rem Latched to ceiling, no stretch missile
          let temp7 = playerState[CRTSMC_playerIndex]
          let temp7 = temp7 & 240
          rem Mask bits 4-7 (animation state)
          let temp7 = temp7 / 16
          rem Shift right by 4 to get animation state
          if temp7 = 10 then CRTSMC_IsStretching
          goto CRTSMC_NextPlayer
          rem Not in stretching animation, no stretch missile
CRTSMC_IsStretching
          
          rem Check if stretch missile has height > 0
          let CRTSMC_stretchHeight = missileStretchHeight_R[CRTSMC_playerIndex]
          if CRTSMC_stretchHeight <= 0 then CRTSMC_NextPlayer
          rem No stretch missile, skip
          
          rem Get stretch missile position (at player position)
          let CRTSMC_missileX = playerX[CRTSMC_playerIndex]
          let CRTSMC_missileY = playerY[CRTSMC_playerIndex]
          
          rem Check collision with other players
          rem Missile extends from playerY down by stretchHeight
          rem Bounding box: X = missileX, Y = missileY, Width = 1 (missile width),
          rem   Height = stretchHeight
          let CRTSMC_otherPlayer = 0
          
CRTSMC_CheckOtherPlayer
          rem Skip self
          if CRTSMC_otherPlayer = CRTSMC_playerIndex then CRTSMC_SkipSelf
          
          rem Skip eliminated players
          if playerHealth[CRTSMC_otherPlayer] = 0 then CRTSMC_SkipSelf
          
          rem AABB collision check
          rem Missile left/right: missileX to missileX+1 (missile width = 1)
          rem Missile top/bottom: missileY to missileY+stretchHeight
          rem Player left/right: playerX to playerX+PlayerSpriteHalfWidth*2
          rem Player top/bottom: playerY to playerY+PlayerSpriteHeight
          if CRTSMC_missileX >= playerX[CRTSMC_otherPlayer] + PlayerSpriteHalfWidth then CRTSMC_SkipSelf
          rem Missile left edge >= player right edge, no collision
          if CRTSMC_missileX + 1 <= playerX[CRTSMC_otherPlayer] then CRTSMC_SkipSelf
          rem Missile right edge <= player left edge, no collision
          if CRTSMC_missileY >= playerY[CRTSMC_otherPlayer] + PlayerSpriteHeight then CRTSMC_SkipSelf
          rem Missile top edge >= player bottom edge, no collision
          if CRTSMC_missileY + CRTSMC_stretchHeight <= playerY[CRTSMC_otherPlayer] then CRTSMC_SkipSelf
          rem Missile bottom edge <= player top edge, no collision
          
          rem Collision detected! Handle stretch missile hit
          let CRTSMC_hitPlayer = CRTSMC_otherPlayer
          gosub HandleRoboTitoStretchMissileHit
          rem After handling hit, skip remaining players for this RoboTito
          goto CRTSMC_NextPlayer
          
CRTSMC_SkipSelf
          let CRTSMC_otherPlayer = CRTSMC_otherPlayer + 1
          if CRTSMC_otherPlayer < 4 then CRTSMC_CheckOtherPlayer
          
CRTSMC_NextPlayer
          let CRTSMC_playerIndex = CRTSMC_playerIndex + 1
          if CRTSMC_playerIndex < 4 then CRTSMC_PlayerLoop
          
          return
          
          rem ==========================================================
          rem HANDLE ROBOTITO STRETCH MISSILE HIT
          rem ==========================================================
          rem Processes a stretch missile hit on another player.
          rem Causes RoboTito to fall and prevents further stretching.
          
          rem INPUT:
          rem   temp1 = RoboTito player index (stretch missile owner)
          rem   temp5 = hit player index (victim)
HandleRoboTitoStretchMissileHit
          dim HRTSMH_roboTitoIndex = temp1
          dim HRTSMH_hitPlayer = temp5
          dim HRTSMH_flags = temp2
          rem Vanish stretch missile (set height to 0)
          let missileStretchHeight_W[HRTSMH_roboTitoIndex] = 0
          
          rem Set RoboTito to free fall
          rem Set jumping flag (bit 2) to enable gravity
          let playerState[HRTSMH_roboTitoIndex] = playerState[HRTSMH_roboTitoIndex] | PlayerStateBitJumping
          rem Set terminal velocity downward
          let playerVelocityY[HRTSMH_roboTitoIndex] = TerminalVelocity
          let playerVelocityYL[HRTSMH_roboTitoIndex] = 0
          rem Set falling animation (ActionFalling = 11)
          let playerState[HRTSMH_roboTitoIndex] = (playerState[HRTSMH_roboTitoIndex] & MaskPlayerStateFlags) | (ActionFalling << ShiftAnimationState)
          rem   ActionFalling
          rem MaskPlayerStateFlags masks bits 0-3, set bits 4-7 to
          
          rem Clear stretch permission flag
          let HRTSMH_flags = roboTitoCanStretch_R
          rem Load current flags
          let temp3 = HRTSMH_roboTitoIndex
          rem Calculate bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp3 = 0 then HRTSMH_ClearBit0
          if temp3 = 1 then HRTSMH_ClearBit1
          if temp3 = 2 then HRTSMH_ClearBit2
          rem Player 3: clear bit 3
          let HRTSMH_flags = HRTSMH_flags & 247
          rem 247 = $F7 = clear bit 3
          goto HRTSMH_PermissionCleared
HRTSMH_ClearBit0
          rem Player 0: clear bit 0
          let HRTSMH_flags = HRTSMH_flags & 254
          rem 254 = $FE = clear bit 0
          goto HRTSMH_PermissionCleared
HRTSMH_ClearBit1
          rem Player 1: clear bit 1
          let HRTSMH_flags = HRTSMH_flags & 253
          rem 253 = $FD = clear bit 1
          goto HRTSMH_PermissionCleared
HRTSMH_ClearBit2
          rem Player 2: clear bit 2
          let HRTSMH_flags = HRTSMH_flags & 251
          rem 251 = $FB = clear bit 2
HRTSMH_PermissionCleared
          let roboTitoCanStretch_W = HRTSMH_flags
          rem Store cleared permission flags
          
          rem Clear latched flag if set (falling from ceiling)
          let temp3 = characterStateFlags_R[HRTSMH_roboTitoIndex]
          let temp3 = temp3 & 254
          rem Clear bit 0 (latched flag)
          let characterStateFlags_W[HRTSMH_roboTitoIndex] = temp3
          
          return

