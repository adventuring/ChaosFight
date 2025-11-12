          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

DispatchCharacterJump
          rem Dispatches character-specific jump handlers via ON...GOTO
          rem Inputs: temp4 = character index (0-31)
          rem Outputs: None; jumps to character handler or returns
          rem Mutates: None
          rem Calls: BernieJump, CurlerJump, ... ShamoneJump via dispatch table
          rem Constraints: Index 31 uses ShamoneJump; 16-30 default to StandardJump

          if temp4 >= 32 then return

          rem Optimized: Group characters with identical jump behavior
          rem StandardJump: Characters 16-30
          if temp4 >= 16 && temp4 <= 30 then goto StandardJump
          rem ShamoneJump: Character 31 (MethHound mirrors Shamone)
          if temp4 = 31 then goto ShamoneJump

          rem Unique jump handlers: Characters 0-15 (optimized dispatch)
          on temp4 goto BernieJump StandardJump DragonOfStormsJump ZoeRyenJump FatTonyJump StandardJump HarpyJump KnightGuyJump FrootyJump StandardJump NinjishGuyJump PorkChopJump RadishGoblinJump RoboTitoJump UrsuloJump ShamoneJump
          return

DispatchCharacterDown
          rem Dispatches down/guard handlers for each character
          rem Inputs: temp4 = character index (0-31)
          rem Outputs: None; branches to handler or returns
          rem Mutates: None
          rem Calls: StandardGuard, DragonOfStormsDown, HarpyDown, RoboTitoDown
          rem Constraints: Index 31 mirrors Shamone; unmapped indices use StandardGuard

          if temp4 >= 32 then return

          rem Optimized: Group characters with identical down/guard behavior
          rem Special handlers: DragonOfStormsDown(2), HarpyDown(6), FrootyDown(8), RoboTitoDown(13)
          if temp4 = 2 then goto DragonOfStormsDown
          if temp4 = 6 then goto HarpyDown
          if temp4 = 8 then goto FrootyDown
          if temp4 = 13 then goto DCD_HandleRoboTitoDown
          rem StandardGuard: All others (0,1,3,4,5,7,9,10,11,12,14,15,16-31)
          goto StandardGuard

DCD_HandleRoboTitoDown
          rem Internal: RoboTito drop vs guard dispatch helper
          gosub RoboTitoDown
          if temp2 = 1 then return
          goto StandardGuard

CCJ_ConvertPlayerXToPlayfieldColumn
          rem Convert player X position to playfield column for jump routines
          rem
          rem Input: temp1 = player index (0-3)
          rem
          rem Output: temp2 = playfield column (0-31)
          rem
          rem Mutates: temp2 (used as return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must reside in bank 13 with jump handlers
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          return

BernieJump
          rem Handles Bernie’s UP input: drop through single-row platforms
          rem Inputs: temp1 = player index, playerX[], playerY[], playerState[]
          rem Outputs: Updates playerY[] when falling through; may wrap to top row
          rem Mutates: temp1-temp6, playerY[]
          rem Calls: CCJ_ConvertPlayerXToPlayfieldColumn, BernieCheckBottomWrap
          rem Constraints: Only triggers if floor is exactly one row deep
          rem Convert player X position to playfield column (0-31)
          rem Use shared coordinate conversion subroutine
          gosub CCJ_ConvertPlayerXToPlayfieldColumn
          
          rem Convert player Y position to playfield row
          rem Player Y is bottom-left of sprite (top of sprite visually)
          rem For pfres=8: pfrowheight = 16 pixels per row
          let temp3 = playerY[temp1]
          rem Row = playerY[playerIndex] / pfrowheight
          let temp4 = temp3 / pfrowheight
          rem currentRow = row player sprite bottom is in (0-7 for
          rem   pfres=8)
          
          rem Check if Bernie is standing ON a floor (row below feet is
          rem   solid)
          rem Bernie feet are visually at bottom of 16px sprite, so
          rem   check row below
          rem Feet are at playerY + 16, so row = (playerY + 16) /
          let temp5 = temp3 + 16
          rem   pfrowheight
          let temp6 = temp5 / pfrowheight
          rem feetY = feet Y position in pixels
          rem feetRow = row directly below player feet
          
          rem Check if there is solid ground directly below feet
          let temp4 = 0
          rem Track pfread result (1 = ground present)
          if pfread(temp2, temp6) then temp4 = 1
          if temp4 = 0 then return
          rem No floor directly below feet, cannot fall through
          
          rem Floor exists directly below feet, check if it is only 1
          rem   row deep
          rem Special case: if at bottom row (pfrows - 1), check top row
          rem   (0) for wrap
          rem For pfres=8: pfrows = 8, so bottom row is 7
          if temp6 >= pfrows - 1 then BernieCheckBottomWrap
          rem At or beyond bottom row, check wrap
          
          let temp4 = temp6 + 1
          rem Normal case: Check row below that (feetRow + 1)
          rem checkRow = row below the floor row
          let temp5 = 0
          rem Track pfread result (1 = floor continues)
          if pfread(temp2, temp4) then temp5 = 1
          if temp5 = 1 then return
          rem Floor is 2+ rows deep, cannot fall through
          
          rem Floor is only 1 row deep - allow fall through
          rem Move Bernie down by 1 pixel per frame while UP is held
          let playerY[temp1] = playerY[temp1] + 1
          rem This allows him to pass through the 1-row platform
return 
          
BernieCheckBottomWrap
          rem Helper: Handles Bernie fall-through at bottom row by
          rem wrapping to top if clear
          rem
          rem Input: temp1 = player index, temp2 = playfield column,
          rem temp4 = top row (0)
          rem
          rem Output: Bernie wrapped to top if top row is clear
          rem
          rem Mutates: playerY[] (global array) = player Y position (set
          rem to 0 if wrapped)
          rem
          rem Called Routines: None
          rem Constraints: Internal helper for BernieJump, only called when at bottom row
          rem Special case: Bernie is at bottom row, trying to fall
          rem   through
          rem Bottom row is always considered 1 row deep since nothing
          rem   is below it
          let temp4 = 0
          rem Check if top row (row 0) is clear for wrapping
          rem topRow = top row (row 0)
          let temp5 = 0
          rem Track pfread result (1 = top row blocked)
          if pfread(temp2, temp4) then temp5 = 1
          if temp5 = 1 then return
          rem Top row is blocked, cannot wrap
          
          rem Top row is clear - wrap to top
          rem Set Bernie Y position to top of screen (row 0)
          rem playerY at top row = 0 * pfrowheight = 0
          let playerY[temp1] = 0
          return

DragonOfStormsJump
          rem DRAGON OF STORMS (2) - FREE FLIGHT (vertical movement)
          rem Dragon of Storms can fly up/down freely
          rem
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Dragon of Storms flies up with playfield collision check
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions
          rem
          rem Output: Upward velocity applied if clear above, jumping
          rem flag set
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerState[] (global array) = player
          rem states (jumping flag set)
          rem
          rem Called Routines: CCJ_ConvertPlayerXToPlayfieldColumn
          rem - converts player X to playfield column
          rem
          rem Constraints: Only moves up if row above is clear. Cannot
          rem move if already at top row
          rem Fly up with playfield collision check
          rem Check collision before moving - use shared coordinate conversion
          gosub CCJ_ConvertPlayerXToPlayfieldColumn
          
          let temp3 = playerY[temp1]
          rem Check row above player (top of sprite)
          let temp4 = temp3 / pfrowheight
          rem currentRow = current row
          rem Check row above (currentRow - 1), but only if not at top
          if temp4 <= 0 then return
          let temp4 = temp4 - 1
          rem Already at top row
          rem Check if playfield pixel is clear
          let temp5 = 0
          rem Track pfread result (1 = blocked)
          if pfread(temp2, temp4) then temp5 = 1
          if temp5 = 1 then return
          rem Blocked, cannot move up
          
          let playerVelocityY[temp1] = 254
          rem Clear above - apply upward velocity impulse
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          rem Set jumping flag for animation
          return

ZoeRyenJump
          rem ZOE RYEN (3) - STANDARD JUMP (light weight, high jump)
          rem Light character with high jump (stronger upward impulse)
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
          rem Apply upward velocity impulse (lighter character, higher
          let playerVelocityY[temp1] = 244
          rem   jump)
          rem -12 in 8-bit two’s complement: 256 - 12 = 244
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

FatTonyJump
          rem FAT TONY (4) - STANDARD JUMP (heavy weight, lower jump)
          rem Heavy character with lower jump (weaker upward impulse)
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
          rem Apply upward velocity impulse (heavier character, lower
          let playerVelocityY[temp1] = 248
          rem   jump)
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

HarpyJump
          rem HARPY (6) - FLAP TO FLY (UP input to flap)
          rem Harpy can fly by flapping (pressing UP repeatedly)
          rem Each flap provides upward thrust
          rem
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1],
          rem   harpyFlightEnergy[temp1], harpyLastFlapFrame[temp1]
          rem Harpy flaps to fly upward, consuming flight energy with
          rem cooldown
          rem
          rem Input: temp1 = player index (0-3), harpyFlightEnergy_R[]
          rem (global SCRAM array) = flight energy,
          rem harpyLastFlapFrame_R[] (global SCRAM array) = last flap
          rem frame, frame (global) = frame counter, playerY[] (global
          rem array) = player Y position, characterStateFlags_R[]
          rem (global SCRAM array) = character state flags,
          rem HarpyFlapCooldownFrames (global constant) = flap cooldown
          rem
          rem Output: Upward velocity applied if energy available and
          rem cooldown expired, flight mode flag set, energy decremented
          rem
          rem Mutates: temp1-temp3 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerState[] (global array) = player
          rem states (jumping flag set), characterStateFlags_W[] (global
          rem SCRAM array) = character state flags (flight mode set),
          rem harpyFlightEnergy_W[] (global SCRAM array) = flight energy
          rem (decremented), harpyLastFlapFrame_W[] (global SCRAM array)
          rem = last flap frame (updated)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Requires flight energy > 0 and cooldown
          rem expired. Cannot flap if already at top of screen (but
          rem still records flap)
          dim HJ_stateFlags = temp3
          rem Check if flight energy depleted
          if harpyFlightEnergy_R[temp1] = 0 then return
          rem No energy remaining, cannot flap
          
          rem Check flap cooldown: enforce HarpyFlapCooldownFrames between flaps
          let temp2 = frame - harpyLastFlapFrame_R[temp1]
          rem   FramesPerSecond-derived cooldown
          rem Calculate frames since last flap
          if temp2 > 127 then temp2 = 127
          rem Clamp to prevent underflow (max safe value for 8-bit)
          if temp2 < HarpyFlapCooldownFrames then return
          rem Cooldown not expired, cannot flap yet
          
          rem Check screen bounds - do not go above top
          
          if playerY[temp1] <= 5 then HarpyFlapRecord
          rem Already at top, cannot flap higher but still record
          
          rem Flap upward - apply upward velocity impulse
          rem Gravity is 0.05 px/frame² for Harpy (reduced). Over the cooldown window,
          rem   gravity accumulates to roughly 2.0 px/frame (downward)
          rem To maintain height, flap impulse must counteract with -2.0
          rem Using -2 px/frame (254 in two’s complement) for stable
          let playerVelocityY[temp1] = 254
          rem   hover with 1.5 flaps/second
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          rem Set jumping/flying bit for animation
          rem Set flight mode flag for slow gravity
          let HJ_stateFlags = characterStateFlags_R[temp1] | 2
          rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[temp1] = HJ_stateFlags
          rem Set bit 1 (flight mode)
          
HarpyFlapRecord
          rem Helper: Records flap and decrements flight energy
          rem
          rem Input: temp1 = player index, harpyFlightEnergy_R[] (global
          rem SCRAM array) = flight energy, frame (global) = frame
          rem counter
          rem
          rem Output: Flight energy decremented, last flap frame updated
          rem
          rem Mutates: harpyFlightEnergy_W[] (global SCRAM array) =
          rem flight energy (decremented), harpyLastFlapFrame_W[]
          rem (global SCRAM array) = last flap frame (updated)
          rem
          rem Called Routines: None
          rem Constraints: Internal helper for HarpyJump, only called after flap check
          rem Decrement flight energy on each flap
          if harpyFlightEnergy_R[temp1] > 0 then let harpyFlightEnergy_W[temp1] = harpyFlightEnergy_R[temp1] - 1
          
          let harpyLastFlapFrame_W[temp1] = frame
          rem Record current frame as last flap time
          
          return

KnightGuyJump
          rem KNIGHT GUY (7) - STANDARD JUMP (heavy weight)
          rem Heavy character with lower jump (weaker upward impulse)
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
          rem Apply upward velocity impulse (heavier character, lower
          let playerVelocityY[temp1] = 248
          rem   jump)
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

FrootyJump
          rem FROOTY (8) - PERMANENT FREE FLIGHT (vertical movement)
          rem Frooty has permanent flight ability - no UP tapping
          rem   required
          rem Complete control over vertical position, gravity always
          rem   overridden
          rem Can move up/down freely at all times, no guard action
          rem
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Frooty flies up with playfield collision check (permanent
          rem flight)
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, ScreenInsetX (global
          rem constant) = screen X inset
          rem
          rem Output: Upward velocity applied if clear above, jumping
          rem flag set
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerState[] (global array) = player
          rem states (jumping flag set)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only moves up if row above is clear. Cannot
          rem move if already at top row. Uses inline coordinate
          rem conversion (not shared subroutine)
          rem Fly up with playfield collision check
          let temp2 = playerX[temp1]
          rem Check collision before moving
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem pfColumn = playfield column (0-31)
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp2 & $80 then temp2 = 0
          if temp2 > 31 then temp2 = 31
          
          let temp3 = playerY[temp1]
          rem Check row above player (top of sprite)
          let temp4 = temp3 / pfrowheight
          rem currentRow = current row
          rem Check row above (currentRow - 1), but only if not at top
          if temp4 <= 0 then return
          let temp4 = temp4 - 1
          rem Already at top row
          rem Check if playfield pixel is clear
          let temp5 = 0
          rem Track pfread result (1 = blocked)
          if pfread(temp2, temp4) then temp5 = 1
          if temp5 = 1 then return
          rem Blocked, cannot move up
          
          let playerVelocityY[temp1] = 254
          rem Clear above - apply upward velocity impulse
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          rem Set jumping flag for animation
          return

NinjishGuyJump
          rem NINJISH GUY (10) - STANDARD JUMP (very light, high jump)
          rem Very light character with highest jump (strongest upward
          rem impulse)
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
          rem Apply upward velocity impulse (very light character,
          let playerVelocityY[temp1] = 243
          rem   highest jump)
          rem -13 in 8-bit two’s complement: 256 - 13 = 243
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

PorkChopJump
          rem PORK CHOP (11) - STANDARD JUMP (heavy weight)
          rem Heavy character with lower jump (weaker upward impulse)
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
          rem Apply upward velocity impulse (heavy character, lower
          let playerVelocityY[temp1] = 248
          rem   jump)
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

RadishGoblinJump
          rem RADISH GOBLIN (12) - STANDARD JUMP (very light, high jump)
          rem Very light character with highest jump (strongest upward
          rem impulse)
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
          rem Apply upward velocity impulse (very light character,
          let playerVelocityY[temp1] = 243
          rem   highest jump)
          rem -13 in 8-bit two’s complement: 256 - 13 = 243
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

RoboTitoJump
          rem ROBO TITO (13) - VERTICAL MOVEMENT (no jump physics)
          rem Robo Tito does not jump but moves vertically to screen top
          rem Special: sprite may not clear GRPn when done
          rem
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1]
          rem RoboTito stretches upward to latch to ceiling (no jump
          rem physics)
          rem
          rem Input: temp1 = player index (0-3), characterStateFlags_R[]
          rem (global SCRAM array) = character state flags,
          rem playerState[] (global array) = player states,
          rem roboTitoCanStretch_R (global SCRAM) = stretch permission
          rem flags, playerY[] (global array) = player Y position,
          rem ScreenBottom (global constant) = bottom Y coordinate,
          rem missileStretchHeight_R[] (global SCRAM array) = stretch
          rem missile heights
          rem
          rem Output: RoboTito moves up 3 pixels per frame if stretch
          rem allowed, latches to ceiling on contact, stretch height
          rem calculated
          rem
          rem Mutates: temp1-temp5 (used for calculations), playerY[]
          rem (global array) = player Y position (moved up),
          rem playerState[] (global array) = player states
          rem (ActionJumping set), characterStateFlags_W[] (global SCRAM
          rem array) = character state flags (latched bit set on ceiling
          rem contact), missileStretchHeight_W[] (global SCRAM array) =
          rem stretch missile heights (calculated and set),
          rem roboTitoCanStretch_W (global SCRAM) = stretch permission
          rem flags (cleared when stretching)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Requires grounded state and stretch permission.
          rem Cannot stretch if already latched. Stretch height clamped to 1-80 scanlines.
          rem RoboTito ceiling-stretch mechanic
          rem Check if already latched to ceiling
          if (characterStateFlags_R[temp1] & 1) then return
          rem Check if grounded and stretch is allowed
          if (playerState[temp1] & 4) then RoboTitoCannotStretch
          rem Not grounded (jumping flag set), cannot stretch
          
          rem Check stretch permission flag (must be grounded)
          let temp2 = roboTitoCanStretch_R
          rem Load bit-packed flags
          let temp3 = temp1
          rem Calculate bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp3 = 0 then RTJ_CheckBit0
          if temp3 = 1 then RTJ_CheckBit1
          if temp3 = 2 then RTJ_CheckBit2
          rem Player 3: bit 3
          let temp3 = temp2 & 8
          if !temp3 then RoboTitoCannotStretch
          rem Bit 3 not set, cannot stretch
          goto RoboTitoCanStretch

RTJ_CheckBit0
          rem Player 0: bit 0
          let temp3 = temp2 & 1
          if !temp3 then RoboTitoCannotStretch
          rem Bit 0 not set, cannot stretch
          goto RoboTitoCanStretch

RTJ_CheckBit1
          rem Player 1: bit 1
          let temp3 = temp2 & 2
          if !temp3 then RoboTitoCannotStretch
          rem Bit 1 not set, cannot stretch
          goto RoboTitoCanStretch

RTJ_CheckBit2
          rem Player 2: bit 2
          let temp3 = temp2 & 4
          if !temp3 then RoboTitoCannotStretch
          rem Bit 2 not set, cannot stretch
          goto RoboTitoCanStretch

RoboTitoCannotStretch
          rem Cannot stretch - clear missile height and return
          let missileStretchHeight_W[temp1] = 0
          return

RoboTitoCanStretch
RoboTitoStretching
          rem Helper: Sets stretching animation and calculates stretch
          rem height
          rem
          rem Input: temp1 = player index, playerY[] (global array) =
          rem player Y position, ScreenBottom (global constant) = bottom
          rem Y coordinate, roboTitoCanStretch_R (global SCRAM) =
          rem stretch permission flags, playerState[] (global array) =
          rem player states, MaskPlayerStateFlags, ActionJumpingShifted
          rem (global constants) = state mask and animation value
          rem
          rem Output: Stretching animation set, stretch height
          rem calculated and stored, stretch permission cleared
          rem
          rem Mutates: temp1-temp5 (used for calculations),
          rem playerState[] (global array) = player states
          rem (ActionJumping set), missileStretchHeight_W[] (global
          rem SCRAM array) = stretch missile heights (calculated),
          rem roboTitoCanStretch_W (global SCRAM) = stretch permission
          rem flags (cleared)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for RoboTitoJump, only called
          rem when stretch allowed
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          rem Set stretching animation (repurposed ActionJumping = 10)
          
          rem Calculate and set missile stretch height
          rem Ground level search:
          rem Start search from feet position (player bottom + 16 pixels)

          rem Convert player X position to playfield column for pfread
          gosub CCJ_ConvertPlayerXToPlayfieldColumn
          let temp4 = temp2
          rem temp4 = playfield column from subroutine

          rem Convert starting Y position to playfield row
          let temp2 = playerY[temp1] + 16
          rem Restore starting Y position (overwritten by subroutine)
          let temp5 = temp2 / pfrowheight
          rem temp5 = starting row for ground search

          rem Search downward from starting row until we find ground
GroundSearchLoop
          rem Check if we have reached bottom of playfield
          if temp5 >= pfrows then goto GroundSearchBottom
          rem Beyond playfield, use screen bottom as ground

          rem Check if playfield pixel is set in current row
          let temp6 = 0
          if pfread(temp4, temp5) then temp6 = 1
          if temp6 = 1 then goto GroundFound
          rem Ground pixel found in this row

          rem Move to next row down
          let temp5 = temp5 + 1
          goto GroundSearchLoop

GroundFound
          rem Convert found row back to Y coordinate
          rem temp2 = row * pfrowheight
          let temp2 = temp5 * pfrowheight
          goto GroundSearchDone

GroundSearchBottom
          rem Reached bottom of playfield, use screen bottom
          let temp2 = ScreenBottom
          rem fall through to GroundSearchDone

GroundSearchDone
          rem temp2 now contains ground Y position
          let temp3 = playerY[temp1]
          rem Calculate height: playerY - groundY (extends downward from player)
          let temp3 = temp3 - temp2
          rem Clamp height to reasonable maximum (80 scanlines)
          if temp3 > 80 then temp3 = 80
          rem Ensure minimum height of 1 scanline
          if temp3 < 1 then temp3 = 1
          let missileStretchHeight_W[temp1] = temp3
          rem Store stretch height
          
          rem Clear stretch permission (stretching upward, cannot
          rem stretch again until grounded)
          let temp4 = temp1
          rem Calculate bit mask and clear bit
          let temp5 = roboTitoCanStretch_R
          rem Load current flags
          if temp4 = 0 then RTS_ClearBit0
          if temp4 = 1 then RTS_ClearBit1
          if temp4 = 2 then RTS_ClearBit2
          let temp5 = temp5 & 247
          rem Player 3: clear bit 3
          goto RTS_StretchPermissionCleared
          rem 247 = $F7 = clear bit 3
RTS_ClearBit0
          let temp5 = temp5 & 254
          rem Player 0: clear bit 0
          goto RTS_StretchPermissionCleared
          rem 254 = $FE = clear bit 0
RTS_ClearBit1
          let temp5 = temp5 & 253
          rem Player 1: clear bit 1
          goto RTS_StretchPermissionCleared
          rem 253 = $FD = clear bit 1
RTS_ClearBit2
          let temp5 = temp5 & 251
          rem Player 2: clear bit 2
RTS_StretchPermissionCleared
          rem 251 = $FB = clear bit 2
          let roboTitoCanStretch_W = temp5
          rem Store cleared permission flags
          
          rem Move upward 3 pixels per frame
          
          if playerY[temp1] <= 5 then RoboTitoCheckCeiling
          let playerY[temp1] = playerY[temp1] - 3
          return
          
RoboTitoCheckCeiling
          rem Helper: Checks for ceiling contact and latches if detected
          rem
          rem Input: temp1 = player index, playerX[], playerY[] (global
          rem arrays) = player positions, ScreenInsetX (global constant)
          rem = screen X inset, characterStateFlags_R[] (global SCRAM
          rem array) = character state flags, playerState[] (global
          rem array) = player states, missileStretchHeight_R[] (global
          rem SCRAM array) = stretch missile heights,
          rem MaskPlayerStateFlags, ActionJumpingShifted (global
          rem constants) = state mask and animation value
          rem
          rem Output: RoboTito latched to ceiling if contact detected,
          rem stretch height cleared
          rem
          rem Mutates: temp1-temp4 (used for calculations), playerY[]
          rem (global array) = player Y position (moved up if no
          rem contact), characterStateFlags_W[] (global SCRAM array) =
          rem character state flags (latched bit set on contact),
          rem playerState[] (global array) = player states
          rem (ActionJumping set on latch), missileStretchHeight_W[]
          rem (global SCRAM array) = stretch missile heights (cleared on
          rem latch)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for RoboTitoJump, only called
          rem when at top of screen
          let temp2 = playerX[temp1]
          rem Check if ceiling contact using playfield collision
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp2 & $80 then temp2 = 0
          if temp2 > 31 then temp2 = 31
          
          let temp3 = playerY[temp1]
          rem Check row above player for ceiling
          if temp3 <= 0 then RoboTitoLatch
          let temp4 = temp3 / pfrowheight
          if temp4 <= 0 then RoboTitoLatch
          let temp4 = temp4 - 1
          if pfread(temp2, temp4) then RoboTitoLatch
          
          let playerY[temp1] = playerY[temp1] - 3
          rem No ceiling contact, continue stretching
          return
          
RoboTitoLatch
          rem Helper: Latches RoboTito to ceiling and clears stretch
          rem height
          rem
          rem Input: temp1 = player index, characterStateFlags_R[]
          rem (global SCRAM array) = character state flags,
          rem playerState[] (global array) = player states,
          rem missileStretchHeight_R[] (global SCRAM array) = stretch
          rem missile heights, MaskPlayerStateFlags,
          rem ActionJumpingShifted (global constants) = state mask and
          rem animation value
          rem
          rem Output: RoboTito latched to ceiling, hanging animation
          rem set, stretch height cleared
          rem
          rem Mutates: temp1-temp2, temp5 (used for calculations),
          rem characterStateFlags_W[] (global SCRAM array) = character
          rem state flags (latched bit set), playerState[] (global
          rem array) = player states (ActionJumping set),
          rem missileStretchHeight_W[] (global SCRAM array) = stretch
          rem missile heights (cleared)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for RoboTitoCheckCeiling,
          rem only called on ceiling contact
          dim RTL_stateFlags = temp5
          rem Ceiling contact detected - latch to ceiling
          let RTL_stateFlags = characterStateFlags_R[temp1] | 1
          rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[temp1] = RTL_stateFlags
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          rem Set latched bit
          rem Set hanging animation (ActionJumping = 10, repurposed for
          rem hanging)
          
          let temp2 = missileStretchHeight_R[temp1]
          rem Rapidly reduce missile height to 0 over 2-3 frames
          if temp2 <= 0 then RTL_HeightCleared
          rem Reduce by 25 scanlines per frame
          if temp2 > 25 then RTL_ReduceHeight
          let missileStretchHeight_W[temp1] = 0
          rem Less than 25 remaining, set to 0
          goto RTL_HeightCleared
RTL_ReduceHeight
          let temp2 = temp2 - 25
          let missileStretchHeight_W[temp1] = temp2
RTL_HeightCleared
          return

UrsuloJump
          rem URSULO (14) - STANDARD JUMP (heavy weight)
          rem Heavy character with lower jump (weaker upward impulse)
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
          rem Apply upward velocity impulse (heavy character, lower
          let playerVelocityY[temp1] = 248
          rem   jump)
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

ShamoneJump
          rem SHAMONE (15) - STANDARD JUMP (light weight)
          rem Light character with good jump (strong upward impulse)
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
          let playerVelocityY[temp1] = 245
          rem Apply upward velocity impulse (light character, good jump)
          rem -11 in 8-bit two’s complement: 256 - 11 = 245
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return
