          rem DOWN BUTTON HANDLERS (Called via on goto from PlayerInput)
DragonOfStormsDown
          rem DRAGON OF STORMS (2) - FLY DOWN (no guard action)
          rem Dragon of Storms flies down instead of guarding
          rem
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Dragon of Storms flies down with playfield collision check
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, ScreenInsetX (global
          rem constant) = screen X inset
          rem
          rem Output: Downward velocity applied if clear below, guard
          rem bit cleared
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerState[] (global array) = player
          rem states (guard bit cleared)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only moves down if row below is clear. Cannot
          rem move if already at bottom. Uses inline coordinate
          rem conversion (not shared subroutine)
          rem Fly down with playfield collision check
          let temp2 = playerX[temp1]
          rem Check collision before moving
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem pfColumn = playfield column (0-31)
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp2 & $80 then temp2 = 0
          if temp2 > 31 then temp2 = 31

          let temp3 = playerY[temp1]
          rem Check row below player (feet at bottom of sprite)
          let temp3 = temp3 + 16
          let temp4 = temp3 / pfrowheight
          rem feetY = feet Y position
          rem feetRow = row below feet
          rem Check if at or beyond bottom row
          if temp4 >= pfrows then return
          rem At bottom, cannot move down
          rem Check if playfield pixel is clear
          let temp5 = 0
          rem Track pfread result (1 = blocked)
          if pfread(temp2, temp4) then temp5 = 1
          if temp5 = 1 then return
          rem Blocked, cannot move down

          let playerVelocityY[temp1] = 2
          rem Clear below - apply downward velocity impulse
          let playerVelocityYL[temp1] = 0
          rem +2 pixels/frame downward
          let playerState[temp1] = playerState[temp1] & !2
          rem Ensure guard bit clear
          return

HarpyDown
          rem HARPY (6) - FLY DOWN (no guard action)
          rem Harpy flies down instead of guarding
          rem
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Harpy flies down with playfield collision check, sets dive
          rem mode if airborne
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, playerState[] (global
          rem array) = player states, characterStateFlags_R[] (global
          rem SCRAM array) = character state flags, ScreenInsetX (global
          rem constant) = screen X inset
          rem
          rem Output: Downward velocity applied if clear below, dive
          rem mode set if airborne, guard bit cleared
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerState[] (global array) = player
          rem states (guard bit cleared), characterStateFlags_W[]
          rem (global SCRAM array) = character state flags (dive mode
          rem set if airborne)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only moves down if row below is clear. Cannot
          rem move if already at bottom. Sets dive mode if airborne
          rem (jumping flag set or Y < 60). Uses inline coordinate
          rem conversion (not shared subroutine)
          rem Check if Harpy is airborne and set dive mode
          if (playerState[temp1] & 4) then HarpySetDive
          let temp2 = playerY[temp1]
          rem Jumping bit set, airborne
          if temp2 < 60 then HarpySetDive
          goto HarpyNormalDown
          rem Above ground level, airborne
HarpySetDive
          rem Helper: Sets dive mode flag for Harpy when airborne
          rem
          rem Input: temp1 = player index, characterStateFlags_R[]
          rem (global SCRAM array) = character state flags
          rem
          rem Output: Dive mode flag set (bit 2)
          rem
          rem Mutates: temp5 (scratch), characterStateFlags_W[] (global
          rem SCRAM array) = character state flags (dive mode set)
          rem
          rem Called Routines: None
          rem Constraints: Internal helper for HarpyDown, only called when airborne
          rem Set dive mode flag for increased damage and normal gravity
          dim HSD_stateFlags = temp5
          let HSD_stateFlags = characterStateFlags_R[temp1] | 4
          rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[temp1] = HSD_stateFlags
HarpyNormalDown
          rem Set bit 2 (dive mode)
          rem Helper: Handles Harpy flying down with collision check
          rem
          rem Input: temp1 = player index, playerX[], playerY[] (global
          rem arrays) = player positions, ScreenInsetX (global constant)
          rem = screen X inset
          rem
          rem Output: Downward velocity applied if clear below, guard
          rem bit cleared
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerState[] (global array) = player
          rem states (guard bit cleared)
          rem
          rem Called Routines: None
          rem Constraints: Internal helper for HarpyDown, handles downward movement
          rem Fly down with playfield collision check
          let temp2 = playerX[temp1]
          rem Check collision before moving
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem pfColumn = playfield column (0-31)
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp2 & $80 then temp2 = 0
          if temp2 > 31 then temp2 = 31

          let temp3 = playerY[temp1]
          rem Check row below player (feet at bottom of sprite)
          let temp3 = temp3 + 16
          let temp4 = temp3 / 16
          rem feetY = feet Y position
          rem feetRow = row below feet
          rem Check if at or beyond bottom row
          if temp4 >= pfrows then return
          rem At bottom, cannot move down
          rem Check if playfield pixel is clear
          let temp5 = 0
          rem Track pfread result (1 = blocked)
          if pfread(temp2, temp4) then temp5 = 1
          if temp5 = 1 then return
          rem Blocked, cannot move down

          let playerVelocityY[temp1] = 2
          rem Clear below - apply downward velocity impulse
          let playerVelocityYL[temp1] = 0
          rem +2 pixels/frame downward
          let playerState[temp1] = playerState[temp1] & !2
          rem Ensure guard bit clear
          return

FrootyDown
          rem FROOTY (8) - FLY DOWN (no guard action)
          rem Frooty flies down instead of guarding
          rem
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Frooty flies down with playfield collision check
          rem (permanent flight)
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, ScreenInsetX (global
          rem constant) = screen X inset
          rem
          rem Output: Downward velocity applied if clear below, guard
          rem bit cleared
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerState[] (global array) = player
          rem states (guard bit cleared)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only moves down if row below is clear. Cannot
          rem move if already at bottom. Uses inline coordinate
          rem conversion (not shared subroutine)
          rem Fly down with playfield collision check
          let temp2 = playerX[temp1]
          rem Check collision before moving
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem pfColumn = playfield column (0-31)
          rem   result ≥ 128
          rem Check for wraparound: if subtraction wrapped negative,
          if temp2 & $80 then temp2 = 0
          if temp2 > 31 then temp2 = 31

          let temp3 = playerY[temp1]
          rem Check row below player (feet at bottom of sprite)
          let temp3 = temp3 + 16
          let temp4 = temp3 / pfrowheight
          rem feetY = feet Y position
          rem feetRow = row below feet
          rem Check if at or beyond bottom row
          if temp4 >= pfrows then return
          rem At bottom, cannot move down
          rem Check if playfield pixel is clear
          let temp5 = 0
          rem Track pfread result (1 = blocked)
          if pfread(temp2, temp4) then temp5 = 1
          if temp5 = 1 then return
          rem Blocked, cannot move down

          let playerVelocityY[temp1] = 2
          rem Clear below - apply downward velocity impulse
          let playerVelocityYL[temp1] = 0
          rem +2 pixels/frame downward
          let playerState[temp1] = playerState[temp1] & !2
          rem Ensure guard bit clear
          return

RoboTitoDown
          asm
RoboTitoDown
end
          rem ROBO TITO (13) - DOWN: Drops if latched, else guards
          rem Voluntary drop from ceiling if latched; otherwise standard guard
          rem Input: temp1 = player index
          rem Output: Drop (cleared latched bit, falling state) or guard
          rem Mutates: temp2 (drop flag), characterStateFlags_W[], playerState[],
          rem missileStretchHeight_W[]
          rem Calls: StandardGuard if not latched via dispatcher helper
          rem If latched, drop; else guard
          let temp2 = 0
          if (characterStateFlags_R[temp1] & 1) = 0 then RoboTitoInitiateDrop
          rem Not latched, dispatcher will fall through to StandardGuard
          return
RoboTitoInitiateDrop
          let temp2 = 1
          rem Signal dispatcher to skip guard after voluntary drop
          rem fall through to RoboTitoVoluntaryDrop

RoboTitoVoluntaryDrop
          rem RoboTito drops from ceiling on DOWN; clears latched bit, sets falling, resets stretch height
          rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & ($ff ^ PlayerStateBitFacing)
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionFallingShifted
          rem Clear latched bit (bit 0)
          rem Set falling animation
          let missileStretchHeight_W[temp1] = 0
          rem Clear stretch missile height when dropping
          return

StandardJump
          rem
          rem Standard Behaviors
          rem Standard jump behavior for most characters
          rem
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1]
          rem Standard jump behavior used by most characters (default
          rem jump impulse)
          rem
          rem Input: temp1 = player index (0-3)
          rem
          rem Output: Upward velocity applied, jumping flag set
          rem
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global
          rem arrays) = vertical velocity, playerState[] (global array)
          rem = player states (jumping flag set)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Apply upward velocity impulse (input applies impulse to
          let playerVelocityY[temp1] = 246
          rem   rigid body)
          rem -10 in 8-bit two’s complement: 256 - 10 = 246
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          rem Set jumping bit
          return

StandardGuard
          rem Standard guard behavior
          rem
          rem INPUT: temp1 = player index
          rem USES: playerState[temp1], playerTimers[temp1]
          rem Used by: Bernie, Curler, Zoe Ryen, Fat Tony, Megax, Knight Guy,
          rem   Nefertem, Ninjish Guy, Pork Chop, Radish Goblin, Ursulo,
          rem   Shamone, MethHound, and placeholder characters (16-30)
          rem NOTE: Flying characters (Frooty, Dragon of Storms, Harpy)
          rem   cannot guard
          rem Standard guard behavior used by most characters (blocks
          rem attacks, forces cyan guard tint)
          rem
          rem Input: temp1 = player index (0-3), playerCharacter[] (global
          rem array) = character types
          rem
          rem Output: Guard activated if allowed (not flying character,
          rem not in cooldown)
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerState[], playerTimers[] (global arrays) = player
          rem states and timers (via StartGuard)
          rem
          rem Called Routines: CheckGuardCooldown (bank6) - checks
          rem guard cooldown, StartGuard (bank6) - activates guard
          rem
          rem Constraints: Flying characters (Frooty=8, Dragon of
          rem Storms=2, Harpy=6) cannot guard. Guard blocked if in
          rem cooldown
          rem Flying characters cannot guard - DOWN is used for vertical
          rem   movement
          rem Frooty (8): DOWN = fly down (no gravity)
          rem Dragon of Storms (2): DOWN = fly down (no gravity)
          rem Harpy (6): DOWN = fly down (reduced gravity)
          let temp4 = playerCharacter[temp1]
          if temp4 = CharacterFrooty then return
          if temp4 = CharacterDragonOfStorms then return
          if temp4 = CharacterHarpy then return

          rem Check if guard is allowed (not in cooldown)
          gosub CheckGuardCooldown bank6
          if temp2 = 0 then return
          rem Guard blocked by cooldown

          goto StartGuard bank6

