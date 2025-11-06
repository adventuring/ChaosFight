BernieJump
          rem
          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character-specific Control Logic
          rem Handles character-specific jump and down button behaviors.
          rem Called via on playerChar[n] goto dispatch from
          rem   PlayerInput.bas
          rem INPUT VARIABLE:
          rem   temp1 = player index (0-3)
          rem AVAILABLE VARIABLES:
          rem   playerX[temp1], playerY[temp1] - Position
          rem   playerState[temp1] - State flags
          rem   playerVelocityX[temp1] - Horizontal velocity
          rem CHARACTER INDICES:
          rem 0=Bernie, 1=Curler, 2=Dragon of Storms, 3=ZoeRyen,
          rem   4=FatTony, 5=Megax,
          rem
          rem 6=Harpy, 7=KnightGuy, 8=Frooty, 9=Nefertem, 10=NinjishGuy,
          rem 11=PorkChop, 12=RadishGoblin, 13=RoboTito, 14=Ursulo,
          rem   15=Shamone
          rem Jump Handlers (called Via On Goto From Playerinput)
          rem BERNIE (0) - NO JUMP, BUT CAN FALL THROUGH 1-ROW FLOORS
          rem Bernie cannot jump, but pressing UP allows him to fall
          rem   through
          rem floors that are only 1 playfield row deep (platforms).
          rem This is called when UP is pressed to handle fall-through
          rem   logic.
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4,
          rem   temp5, temp6
          rem Bernie cannot jump, but pressing UP allows him to fall through 1-row platforms
          rem Input: temp1 = player index (0-3), playerX[], playerY[] (global arrays) = player positions
          rem Output: Bernie falls through 1-row platforms or wraps to top if at bottom
          rem Mutates: temp1-temp6 (used for calculations), playerY[] (global array) = player Y position (moved down 1 pixel or wrapped to top)
          rem Called Routines: ConvertPlayerXToPlayfieldColumn (bank13) - converts player X to playfield column
          rem Constraints: Only works on 1-row deep platforms. At bottom row, wraps to top if top row is clear
          dim BJ_playerIndex = temp1
          dim BJ_pfColumn = temp2
          dim BJ_playerY = temp3
          dim BJ_currentRow = temp4
          dim BJ_feetY = temp5
          dim BJ_feetRow = temp6
          dim BJ_checkRow = temp4
          rem Convert player X position to playfield column (0-31)
          let temp1 = BJ_playerIndex : rem Use shared coordinate conversion subroutine
          gosub ConvertPlayerXToPlayfieldColumn
          let BJ_pfColumn = temp2
          
          rem Convert player Y position to playfield row
          rem Player Y is bottom-left of sprite (top of sprite visually)
          rem For pfres=8: pfrowheight = 16 pixels per row
          let BJ_playerY = playerY[BJ_playerIndex] : rem Row = playerY[playerIndex] / pfrowheight
          let BJ_currentRow = BJ_playerY / pfrowheight
          rem currentRow = row player sprite bottom is in (0-7 for
          rem   pfres=8)
          
          rem Check if Bernie is standing ON a floor (row below feet is
          rem   solid)
          rem Bernie feet are visually at bottom of 16px sprite, so
          rem   check row below
          rem Feet are at playerY + 16, so row = (playerY + 16) /
          let BJ_feetY = BJ_playerY + 16 : rem   pfrowheight
          let BJ_feetRow = BJ_feetY / pfrowheight : rem feetY = feet Y position in pixels
          rem feetRow = row directly below player feet
          
          if !pfread(BJ_pfColumn, BJ_feetRow) then return : rem Check if there is solid ground directly below feet
          rem No floor directly below feet, cannot fall through
          
          rem Floor exists directly below feet, check if it is only 1
          rem   row deep
          rem Special case: if at bottom row (pfrows - 1), check top row
          rem   (0) for wrap
          rem For pfres=8: pfrows = 8, so bottom row is 7
          if BJ_feetRow >= pfrows - 1 then BernieCheckBottomWrap
          rem At or beyond bottom row, check wrap
          
          let BJ_checkRow = BJ_feetRow + 1 : rem Normal case: Check row below that (feetRow + 1)
          if pfread(BJ_pfColumn, BJ_checkRow) then return : rem checkRow = row below the floor row
          rem Floor is 2+ rows deep, cannot fall through
          
          rem Floor is only 1 row deep - allow fall through
          rem Move Bernie down by 1 pixel per frame while UP is held
          let playerY[BJ_playerIndex] = playerY[BJ_playerIndex] + 1 : rem This allows him to pass through the 1-row platform
          return 
          
BernieCheckBottomWrap
          rem Helper: Handles Bernie fall-through at bottom row by wrapping to top if clear
          rem Input: temp1 = player index, temp2 = playfield column, temp4 = top row (0)
          rem Output: Bernie wrapped to top if top row is clear
          rem Mutates: playerY[] (global array) = player Y position (set to 0 if wrapped)
          rem Called Routines: None
          dim BCBW_pfColumn = temp2 : rem Constraints: Internal helper for BernieJump, only called when at bottom row
          dim BCBW_playerIndex = temp1
          dim BCBW_topRow = temp4
          rem Special case: Bernie is at bottom row, trying to fall
          rem   through
          rem Bottom row is always considered 1 row deep since nothing
          rem   is below it
          let BCBW_topRow = 0 : rem Check if top row (row 0) is clear for wrapping
          if pfread(BCBW_pfColumn, BCBW_topRow) then return : rem topRow = top row (row 0)
          rem Top row is blocked, cannot wrap
          
          rem Top row is clear - wrap to top
          rem Set Bernie Y position to top of screen (row 0)
          rem playerY at top row = 0 * pfrowheight = 0
          let playerY[BCBW_playerIndex] = 0
          return

CurlerJump
          rem CURLER (1) - STANDARD JUMP
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1]
          rem Standard jump behavior (tail call to StandardJump)
          rem Input: temp1 = player index (0-3)
          rem Output: Standard jump applied
          rem Mutates: playerVelocityY[], playerVelocityYL[], playerState[] (via StandardJump)
          rem Called Routines: StandardJump (tail call via goto)
          rem Constraints: None
          goto StandardJump : rem tail call

DragonetJump
          rem DRAGON OF STORMS (2) - FREE FLIGHT (vertical movement)
          rem Dragon of Storms can fly up/down freely
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Dragon of Storms flies up with playfield collision check
          rem Input: temp1 = player index (0-3), playerX[], playerY[] (global arrays) = player positions
          rem Output: Upward velocity applied if clear above, jumping flag set
          rem Mutates: temp1-temp4 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: ConvertPlayerXToPlayfieldColumn (bank13) - converts player X to playfield column
          rem Constraints: Only moves up if row above is clear. Cannot move if already at top row
          dim DJ_playerIndex = temp1
          dim DJ_pfColumn = temp2
          dim DJ_playerY = temp3
          dim DJ_currentRow = temp4
          dim DJ_checkRow = temp4
          rem Fly up with playfield collision check
          let temp1 = DJ_playerIndex : rem Check collision before moving - use shared coordinate conversion
          gosub ConvertPlayerXToPlayfieldColumn
          let DJ_pfColumn = temp2
          
          let DJ_playerY = playerY[DJ_playerIndex] : rem Check row above player (top of sprite)
          let DJ_currentRow = DJ_playerY / pfrowheight
          rem currentRow = current row
          if DJ_currentRow <= 0 then return : rem Check row above (currentRow - 1), but only if not at top
          let DJ_checkRow = DJ_currentRow - 1 : rem Already at top row
          if pfread(DJ_pfColumn, DJ_checkRow) then return : rem Check if playfield pixel is clear
          rem Blocked, cannot move up
          
          let playerVelocityY[DJ_playerIndex] = 254 : rem Clear above - apply upward velocity impulse
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityYL[DJ_playerIndex] = 0
          let playerState[DJ_playerIndex] = playerState[DJ_playerIndex] | 4
          rem Set jumping flag for animation
          return

          rem ZOE RYEN (3) - STANDARD JUMP (light weight, high jump)
ZoeRyenJump
          rem Light character with high jump (stronger upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (lighter character, higher
          let playerVelocityY[temp1] = 244 : rem   jump)
          rem -12 in 8-bit two’s complement: 256 - 12 = 244
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem FAT TONY (4) - STANDARD JUMP (heavy weight, lower jump)
FatTonyJump
          rem Heavy character with lower jump (weaker upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (heavier character, lower
          let playerVelocityY[temp1] = 248 : rem   jump)
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem MEGAX (5) - STANDARD JUMP
MegaxJump
          rem Standard jump behavior (tail call to StandardJump)
          rem Input: temp1 = player index (0-3)
          rem Output: Standard jump applied
          rem Mutates: playerVelocityY[], playerVelocityYL[], playerState[] (via StandardJump)
          rem Called Routines: StandardJump (tail call via goto)
          rem Constraints: None
          goto StandardJump : rem tail call

HarpyJump
          rem HARPY (6) - FLAP TO FLY (UP input to flap)
          rem Harpy can fly by flapping (pressing UP repeatedly)
          rem Each flap provides upward thrust
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1],
          rem   harpyFlightEnergy[temp1], harpyLastFlapFrame[temp1]
          rem Harpy flaps to fly upward, consuming flight energy with cooldown
          rem Input: temp1 = player index (0-3), harpyFlightEnergy_R[] (global SCRAM array) = flight energy, harpyLastFlapFrame_R[] (global SCRAM array) = last flap frame, frame (global) = frame counter, playerY[] (global array) = player Y position, characterStateFlags_R[] (global SCRAM array) = character state flags, HarpyFlapCooldownFrames (global constant) = flap cooldown
          rem Output: Upward velocity applied if energy available and cooldown expired, flight mode flag set, energy decremented
          rem Mutates: temp1-temp2 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set), characterStateFlags_W[] (global SCRAM array) = character state flags (flight mode set), harpyFlightEnergy_W[] (global SCRAM array) = flight energy (decremented), harpyLastFlapFrame_W[] (global SCRAM array) = last flap frame (updated)
          rem Called Routines: None
          rem Constraints: Requires flight energy > 0 and cooldown expired. Cannot flap if already at top of screen (but still records flap)
          dim HJ_playerIndex = temp1
          dim HJ_framesSinceFlap = temp2
          if harpyFlightEnergy_R[HJ_playerIndex] = 0 then return : rem Check if flight energy depleted
          rem No energy remaining, cannot flap
          
          rem Check flap cooldown: must wait for 1.5 flaps/second (40
          let HJ_framesSinceFlap = frame - harpyLastFlapFrame_R[HJ_playerIndex] : rem   frames at 60fps)
          if HJ_framesSinceFlap > 127 then let HJ_framesSinceFlap = 127 : rem Calculate frames since last flap
          if HJ_framesSinceFlap < HarpyFlapCooldownFrames then return : rem Clamp to prevent underflow (max safe value for 8-bit)
          rem Cooldown not expired, cannot flap yet
          
          if playerY[HJ_playerIndex] <= 5 then HarpyFlapRecord : rem Check screen bounds - do not go above top
          rem Already at top, cannot flap higher but still record
          
          rem Flap upward - apply upward velocity impulse
          rem Gravity is 0.05 px/frame² for Harpy (reduced). Over 40
          rem   frames, gravity accumulates:
          rem   velocity_change = 0.05 * 40 = 2.0 px/frame (downward)
          rem To maintain height, flap impulse must counteract: -2.0
          rem   px/frame (upward)
          rem Using -2 px/frame (254 in two’s complement) for stable
          let playerVelocityY[HJ_playerIndex] = 254 : rem   hover with 1.5 flaps/second
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityYL[HJ_playerIndex] = 0
          let playerState[HJ_playerIndex] = playerState[HJ_playerIndex] | 4
          rem Set jumping/flying bit for animation
          rem Set flight mode flag for slow gravity
          let HJ_stateFlags = characterStateFlags_R[HJ_playerIndex] | 2 : rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[HJ_playerIndex] = HJ_stateFlags
          rem Set bit 1 (flight mode)
          
HarpyFlapRecord
          rem Helper: Records flap and decrements flight energy
          rem Input: temp1 = player index, harpyFlightEnergy_R[] (global SCRAM array) = flight energy, frame (global) = frame counter
          rem Output: Flight energy decremented, last flap frame updated
          rem Mutates: harpyFlightEnergy_W[] (global SCRAM array) = flight energy (decremented), harpyLastFlapFrame_W[] (global SCRAM array) = last flap frame (updated)
          rem Called Routines: None
          dim HFR_playerIndex = temp1 : rem Constraints: Internal helper for HarpyJump, only called after flap check
          if harpyFlightEnergy_R[HFR_playerIndex] > 0 then let harpyFlightEnergy_W[HFR_playerIndex] = harpyFlightEnergy_R[HFR_playerIndex] - 1 : rem Decrement flight energy on each flap
          
          let harpyLastFlapFrame_W[HFR_playerIndex] = frame : rem Record current frame as last flap time
          
          return

          rem KNIGHT GUY (7) - STANDARD JUMP (heavy weight)
KnightGuyJump
          rem Heavy character with lower jump (weaker upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (heavier character, lower
          let playerVelocityY[temp1] = 248 : rem   jump)
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
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Frooty flies up with playfield collision check (permanent flight)
          rem Input: temp1 = player index (0-3), playerX[], playerY[] (global arrays) = player positions, ScreenInsetX (global constant) = screen X inset
          rem Output: Upward velocity applied if clear above, jumping flag set
          rem Mutates: temp1-temp4 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: Only moves up if row above is clear. Cannot move if already at top row. Uses inline coordinate conversion (not shared subroutine)
          dim FJ_playerIndex = temp1
          dim FJ_pfColumn = temp2
          dim FJ_playerY = temp3
          dim FJ_currentRow = temp4
          dim FJ_checkRow = temp4
          rem Fly up with playfield collision check
          let FJ_pfColumn = playerX[FJ_playerIndex] : rem Check collision before moving
          let FJ_pfColumn = FJ_pfColumn - ScreenInsetX
          let FJ_pfColumn = FJ_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if FJ_pfColumn & $80 then let FJ_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if FJ_pfColumn > 31 then let FJ_pfColumn = 31
          
          let FJ_playerY = playerY[FJ_playerIndex] : rem Check row above player (top of sprite)
          let FJ_currentRow = FJ_playerY / pfrowheight
          rem currentRow = current row
          if FJ_currentRow <= 0 then return : rem Check row above (currentRow - 1), but only if not at top
          let FJ_checkRow = FJ_currentRow - 1 : rem Already at top row
          if pfread(FJ_pfColumn, FJ_checkRow) then return : rem Check if playfield pixel is clear
          rem Blocked, cannot move up
          
          let playerVelocityY[FJ_playerIndex] = 254 : rem Clear above - apply upward velocity impulse
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityYL[FJ_playerIndex] = 0
          let playerState[FJ_playerIndex] = playerState[FJ_playerIndex] | 4
          rem Set jumping flag for animation
          return

          rem NEFERTEM (9) - STANDARD JUMP
NefertemJump
          rem Standard jump behavior (tail call to StandardJump)
          rem Input: temp1 = player index (0-3)
          rem Output: Standard jump applied
          rem Mutates: playerVelocityY[], playerVelocityYL[], playerState[] (via StandardJump)
          rem Called Routines: StandardJump (tail call via goto)
          rem Constraints: None
          goto StandardJump : rem tail call

          rem NINJISH GUY (10) - STANDARD JUMP (very light, high jump)
NinjishGuyJump
          rem Very light character with highest jump (strongest upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (very light character,
          let playerVelocityY[temp1] = 243 : rem   highest jump)
          rem -13 in 8-bit two’s complement: 256 - 13 = 243
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem PORK CHOP (11) - STANDARD JUMP (heavy weight)
PorkChopJump
          rem Heavy character with lower jump (weaker upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (heavy character, lower
          let playerVelocityY[temp1] = 248 : rem   jump)
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem RADISH GOBLIN (12) - STANDARD JUMP (very light, high jump)
RadishGoblinJump
          rem Very light character with highest jump (strongest upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (very light character,
          let playerVelocityY[temp1] = 243 : rem   highest jump)
          rem -13 in 8-bit two’s complement: 256 - 13 = 243
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

RoboTitoJump
          rem ROBO TITO (13) - VERTICAL MOVEMENT (no jump physics)
          rem Robo Tito does not jump but moves vertically to screen top
          rem Special: sprite may not clear GRPn when done
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1]
          rem RoboTito stretches upward to latch to ceiling (no jump physics)
          rem Input: temp1 = player index (0-3), characterStateFlags_R[] (global SCRAM array) = character state flags, playerState[] (global array) = player states, roboTitoCanStretch_R (global SCRAM) = stretch permission flags, playerY[] (global array) = player Y position, ScreenBottom (global constant) = bottom Y coordinate, missileStretchHeight_R[] (global SCRAM array) = stretch missile heights
          rem Output: RoboTito moves up 3 pixels per frame if stretch allowed, latches to ceiling on contact, stretch height calculated
          rem Mutates: temp1-temp5 (used for calculations), playerY[] (global array) = player Y position (moved up), playerState[] (global array) = player states (ActionJumping set), characterStateFlags_W[] (global SCRAM array) = character state flags (latched bit set on ceiling contact), missileStretchHeight_W[] (global SCRAM array) = stretch missile heights (calculated and set), roboTitoCanStretch_W (global SCRAM) = stretch permission flags (cleared when stretching)
          rem Called Routines: None
          rem Constraints: Requires grounded state and stretch permission. Cannot stretch if already latched. Stretch height clamped to 1-80 scanlines
          dim RTJ_playerIndex = temp1
          dim RTJ_canStretch = temp2
          rem RoboTito ceiling-stretch mechanic
          if (characterStateFlags_R[RTJ_playerIndex] & 1) then return : rem Check if already latched to ceiling
          rem Already latched, ignore UP input
          
          rem Check if grounded and stretch is allowed
          if (playerState[RTJ_playerIndex] & 4) then RoboTitoCannotStretch : rem Must be grounded (not jumping/falling) to stretch
          rem Not grounded (jumping flag set), cannot stretch
          
          let RTJ_canStretch = roboTitoCanStretch_R : rem Check stretch permission flag (must be grounded)
          let temp3 = RTJ_playerIndex : rem Load bit-packed flags
          if temp3 = 0 then RTJ_CheckBit0 : rem Calculate bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp3 = 1 then RTJ_CheckBit1
          if temp3 = 2 then RTJ_CheckBit2
          let temp3 = RTJ_canStretch & 8 : rem Player 3: bit 3
          if !temp3 then RoboTitoCannotStretch
          goto RoboTitoCanStretch : rem Bit 3 not set, cannot stretch
RTJ_CheckBit0
          let temp3 = RTJ_canStretch & 1 : rem Player 0: bit 0
          if !temp3 then RoboTitoCannotStretch
          goto RoboTitoCanStretch : rem Bit 0 not set, cannot stretch
RTJ_CheckBit1
          let temp3 = RTJ_canStretch & 2 : rem Player 1: bit 1
          if !temp3 then RoboTitoCannotStretch
          goto RoboTitoCanStretch : rem Bit 1 not set, cannot stretch
RTJ_CheckBit2
          let temp3 = RTJ_canStretch & 4 : rem Player 2: bit 2
          if !temp3 then RoboTitoCannotStretch
          goto RoboTitoCanStretch : rem Bit 2 not set, cannot stretch
RoboTitoCannotStretch
          let missileStretchHeight_W[RTJ_playerIndex] = 0 : rem Cannot stretch - clear missile height and return
          return
RoboTitoCanStretch
          goto RoboTitoStretching : rem Grounded and permission granted - allow stretching
          
RoboTitoStretching
          rem Helper: Sets stretching animation and calculates stretch height
          rem Input: temp1 = player index, playerY[] (global array) = player Y position, ScreenBottom (global constant) = bottom Y coordinate, roboTitoCanStretch_R (global SCRAM) = stretch permission flags, playerState[] (global array) = player states, MaskPlayerStateFlags, ActionJumpingShifted (global constants) = state mask and animation value
          rem Output: Stretching animation set, stretch height calculated and stored, stretch permission cleared
          rem Mutates: temp1-temp5 (used for calculations), playerState[] (global array) = player states (ActionJumping set), missileStretchHeight_W[] (global SCRAM array) = stretch missile heights (calculated), roboTitoCanStretch_W (global SCRAM) = stretch permission flags (cleared)
          rem Called Routines: None
          rem Constraints: Internal helper for RoboTitoJump, only called when stretch allowed
          dim RTS_playerIndex = temp1
          dim RTS_groundY = temp2
          dim RTS_stretchHeight = temp3
          let playerState[RTS_playerIndex] = (playerState[RTS_playerIndex] & MaskPlayerStateFlags) | ActionJumpingShifted : rem Set stretching animation (repurposed ActionJumping = 10)
          
          rem Calculate and set missile stretch height
          rem Ground level: Use ScreenBottom (192) as ground Y position
          let RTS_groundY = ScreenBottom : rem Note: Y coordinate increases downward (0=top, 192=bottom)
          let RTS_stretchHeight = playerY[RTS_playerIndex] : rem Calculate height: playerY - groundY (extends downward from player)
          let RTS_stretchHeight = RTS_stretchHeight - RTS_groundY
          if RTS_stretchHeight > 80 then let RTS_stretchHeight = 80 : rem Clamp height to reasonable maximum (80 scanlines)
          if RTS_stretchHeight < 1 then let RTS_stretchHeight = 1 : rem Ensure minimum height of 1 scanline
          let missileStretchHeight_W[RTS_playerIndex] = RTS_stretchHeight : rem Store stretch height
          
          rem Clear stretch permission (stretching upward, cannot stretch again until grounded)
          let temp4 = RTS_playerIndex : rem Calculate bit mask and clear bit
          let temp5 = roboTitoCanStretch_R
          if temp4 = 0 then RTS_ClearBit0 : rem Load current flags
          if temp4 = 1 then RTS_ClearBit1
          if temp4 = 2 then RTS_ClearBit2
          let temp5 = temp5 & 247 : rem Player 3: clear bit 3
          goto RTS_StretchPermissionCleared : rem 247 = $F7 = clear bit 3
RTS_ClearBit0
          let temp5 = temp5 & 254 : rem Player 0: clear bit 0
          goto RTS_StretchPermissionCleared : rem 254 = $FE = clear bit 0
RTS_ClearBit1
          let temp5 = temp5 & 253 : rem Player 1: clear bit 1
          goto RTS_StretchPermissionCleared : rem 253 = $FD = clear bit 1
RTS_ClearBit2
          let temp5 = temp5 & 251 : rem Player 2: clear bit 2
          rem 251 = $FB = clear bit 2
RTS_StretchPermissionCleared
          let roboTitoCanStretch_W = temp5
          rem Store cleared permission flags
          
          if playerY[RTS_playerIndex] <= 5 then RoboTitoCheckCeiling : rem Move upward 3 pixels per frame
          let playerY[RTS_playerIndex] = playerY[RTS_playerIndex] - 3
          return
          
RoboTitoCheckCeiling
          rem Helper: Checks for ceiling contact and latches if detected
          rem Input: temp1 = player index, playerX[], playerY[] (global arrays) = player positions, ScreenInsetX (global constant) = screen X inset, characterStateFlags_R[] (global SCRAM array) = character state flags, playerState[] (global array) = player states, missileStretchHeight_R[] (global SCRAM array) = stretch missile heights, MaskPlayerStateFlags, ActionJumpingShifted (global constants) = state mask and animation value
          rem Output: RoboTito latched to ceiling if contact detected, stretch height cleared
          rem Mutates: temp1-temp4 (used for calculations), playerY[] (global array) = player Y position (moved up if no contact), characterStateFlags_W[] (global SCRAM array) = character state flags (latched bit set on contact), playerState[] (global array) = player states (ActionJumping set on latch), missileStretchHeight_W[] (global SCRAM array) = stretch missile heights (cleared on latch)
          rem Called Routines: None
          rem Constraints: Internal helper for RoboTitoJump, only called when at top of screen
          dim RTCC_playerIndex = temp1
          dim RTCC_pfColumn = temp2
          dim RTCC_playerY = temp3
          dim RTCC_currentRow = temp4
          dim RTCC_checkRow = temp4
          let RTCC_pfColumn = playerX[RTCC_playerIndex] : rem Check if ceiling contact using playfield collision
          let RTCC_pfColumn = RTCC_pfColumn - ScreenInsetX
          let RTCC_pfColumn = RTCC_pfColumn / 4
          if RTCC_pfColumn & $80 then let RTCC_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if RTCC_pfColumn > 31 then let RTCC_pfColumn = 31
          
          let RTCC_playerY = playerY[RTCC_playerIndex] : rem Check row above player for ceiling
          if RTCC_playerY <= 0 then RoboTitoLatch
          let RTCC_currentRow = RTCC_playerY / pfrowheight
          if RTCC_currentRow <= 0 then RoboTitoLatch
          let RTCC_checkRow = RTCC_currentRow - 1
          if pfread(RTCC_pfColumn, RTCC_checkRow) then RoboTitoLatch
          
          let playerY[RTCC_playerIndex] = playerY[RTCC_playerIndex] - 3 : rem No ceiling contact, continue stretching
          return
          
RoboTitoLatch
          rem Helper: Latches RoboTito to ceiling and clears stretch height
          rem Input: temp1 = player index, characterStateFlags_R[] (global SCRAM array) = character state flags, playerState[] (global array) = player states, missileStretchHeight_R[] (global SCRAM array) = stretch missile heights, MaskPlayerStateFlags, ActionJumpingShifted (global constants) = state mask and animation value
          rem Output: RoboTito latched to ceiling, hanging animation set, stretch height cleared
          rem Mutates: temp1-temp2 (used for calculations), characterStateFlags_W[] (global SCRAM array) = character state flags (latched bit set), playerState[] (global array) = player states (ActionJumping set), missileStretchHeight_W[] (global SCRAM array) = stretch missile heights (cleared)
          rem Called Routines: None
          rem Constraints: Internal helper for RoboTitoCheckCeiling, only called on ceiling contact
          dim RTL_playerIndex = temp1
          dim RTL_currentHeight = temp2
          rem Ceiling contact detected - latch to ceiling
          let RTL_stateFlags = characterStateFlags_R[RTL_playerIndex] | 1 : rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[RTL_playerIndex] = RTL_stateFlags
          let playerState[RTL_playerIndex] = (playerState[RTL_playerIndex] & MaskPlayerStateFlags) | ActionJumpingShifted : rem Set latched bit
          rem Set hanging animation (ActionJumping = 10, repurposed for hanging)
          
          let RTL_currentHeight = missileStretchHeight_R[RTL_playerIndex] : rem Rapidly reduce missile height to 0 over 2-3 frames
          if RTL_currentHeight <= 0 then RTL_HeightCleared
          if RTL_currentHeight > 25 then RTL_ReduceHeight : rem Reduce by 25 scanlines per frame
          let missileStretchHeight_W[RTL_playerIndex] = 0 : rem Less than 25 remaining, set to 0
          goto RTL_HeightCleared
RTL_ReduceHeight
          let RTL_currentHeight = RTL_currentHeight - 25
          let missileStretchHeight_W[RTL_playerIndex] = RTL_currentHeight
RTL_HeightCleared
          return

          rem URSULO (14) - STANDARD JUMP (heavy weight)
UrsuloJump
          rem Heavy character with lower jump (weaker upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (heavy character, lower
          let playerVelocityY[temp1] = 248 : rem   jump)
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem SHAMONE (15) - STANDARD JUMP (light weight)
ShamoneJump
          rem Light character with good jump (strong upward impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          let playerVelocityY[temp1] = 245 : rem Apply upward velocity impulse (light character, good jump)
          rem -11 in 8-bit two’s complement: 256 - 11 = 245
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem DOWN BUTTON HANDLERS (Called via on goto from
          rem   PlayerInput)

          rem BERNIE (0) - GUARD
BernieDown
          rem Standard guard behavior (tail call to StandardGuard)
          rem Input: temp1 = player index (0-3)
          rem Output: Standard guard applied
          rem Mutates: playerState[], playerTimers[] (via StandardGuard)
          rem Called Routines: StandardGuard (tail call via goto)
          rem Constraints: None
          goto StandardGuard : rem tail call

          rem CURLER (1) - GUARD
CurlerDown
          rem Standard guard behavior (tail call to StandardGuard)
          rem Input: temp1 = player index (0-3)
          rem Output: Standard guard applied
          rem Mutates: playerState[], playerTimers[] (via StandardGuard)
          rem Called Routines: StandardGuard (tail call via goto)
          rem Constraints: None
          goto StandardGuard : rem tail call

DragonetDown
          rem DRAGON OF STORMS (2) - FLY DOWN (no guard action)
          rem Dragon of Storms flies down instead of guarding
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Dragon of Storms flies down with playfield collision check
          rem Input: temp1 = player index (0-3), playerX[], playerY[] (global arrays) = player positions, ScreenInsetX (global constant) = screen X inset
          rem Output: Downward velocity applied if clear below, guard bit cleared
          rem Mutates: temp1-temp4 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (guard bit cleared)
          rem Called Routines: None
          rem Constraints: Only moves down if row below is clear. Cannot move if already at bottom. Uses inline coordinate conversion (not shared subroutine)
          dim DD_playerIndex = temp1
          dim DD_pfColumn = temp2
          dim DD_playerY = temp3
          dim DD_feetY = temp3
          dim DD_feetRow = temp4
          rem Fly down with playfield collision check
          let DD_pfColumn = playerX[DD_playerIndex] : rem Check collision before moving
          let DD_pfColumn = DD_pfColumn - ScreenInsetX
          let DD_pfColumn = DD_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if DD_pfColumn & $80 then let DD_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if DD_pfColumn > 31 then let DD_pfColumn = 31
          
          let DD_playerY = playerY[DD_playerIndex] : rem Check row below player (feet at bottom of sprite)
          let DD_feetY = DD_playerY + 16
          let DD_feetRow = DD_feetY / pfrowheight : rem feetY = feet Y position
          rem feetRow = row below feet
          if DD_feetRow >= pfrows then return : rem Check if at or beyond bottom row
          rem At bottom, cannot move down
          if pfread(DD_pfColumn, DD_feetRow) then return : rem Check if playfield pixel is clear
          rem Blocked, cannot move down
          
          let playerVelocityY[DD_playerIndex] = 2 : rem Clear below - apply downward velocity impulse
          let playerVelocityYL[DD_playerIndex] = 0 : rem +2 pixels/frame downward
          let playerState[DD_playerIndex] = playerState[DD_playerIndex] & !2
          rem Ensure guard bit clear
          return

          rem ZOE RYEN (3) - GUARD
ZoeRyenDown
          goto StandardGuard : rem tail call

          rem FAT TONY (4) - GUARD
FatTonyDown
          goto StandardGuard : rem tail call

          rem MEGAX (5) - GUARD
MegaxDown
          goto StandardGuard : rem tail call

HarpyDown
          rem HARPY (6) - FLY DOWN (no guard action)
          rem Harpy flies down instead of guarding
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Harpy flies down with playfield collision check, sets dive mode if airborne
          rem Input: temp1 = player index (0-3), playerX[], playerY[] (global arrays) = player positions, playerState[] (global array) = player states, characterStateFlags_R[] (global SCRAM array) = character state flags, ScreenInsetX (global constant) = screen X inset
          rem Output: Downward velocity applied if clear below, dive mode set if airborne, guard bit cleared
          rem Mutates: temp1-temp4 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (guard bit cleared), characterStateFlags_W[] (global SCRAM array) = character state flags (dive mode set if airborne)
          rem Called Routines: None
          rem Constraints: Only moves down if row below is clear. Cannot move if already at bottom. Sets dive mode if airborne (jumping flag set or Y < 60). Uses inline coordinate conversion (not shared subroutine)
          dim HD_playerIndex = temp1
          dim HD_playerY = temp2
          dim HD_pfColumn = temp2
          dim HD_feetY = temp3
          dim HD_feetRow = temp4
          if (playerState[HD_playerIndex] & 4) then HarpySetDive : rem Check if Harpy is airborne and set dive mode
          let HD_playerY = playerY[HD_playerIndex] : rem Jumping bit set, airborne
          if HD_playerY < 60 then HarpySetDive
          goto HarpyNormalDown : rem Above ground level, airborne
HarpySetDive
          rem Helper: Sets dive mode flag for Harpy when airborne
          rem Input: temp1 = player index, characterStateFlags_R[] (global SCRAM array) = character state flags
          rem Output: Dive mode flag set (bit 2)
          rem Mutates: characterStateFlags_W[] (global SCRAM array) = character state flags (dive mode set)
          rem Called Routines: None
          dim HSD_playerIndex = temp1 : rem Constraints: Internal helper for HarpyDown, only called when airborne
          rem Set dive mode flag for increased damage and normal gravity
          let HSD_stateFlags = characterStateFlags_R[HSD_playerIndex] | 4 : rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[HSD_playerIndex] = HSD_stateFlags
          rem Set bit 2 (dive mode)
HarpyNormalDown
          rem Helper: Handles Harpy flying down with collision check
          rem Input: temp1 = player index, playerX[], playerY[] (global arrays) = player positions, ScreenInsetX (global constant) = screen X inset
          rem Output: Downward velocity applied if clear below, guard bit cleared
          rem Mutates: temp1-temp4 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (guard bit cleared)
          rem Called Routines: None
          dim HND_playerIndex = temp1 : rem Constraints: Internal helper for HarpyDown, handles downward movement
          dim HND_pfColumn = temp2
          dim HND_playerY = temp3
          dim HND_feetY = temp3
          dim HND_feetRow = temp4
          rem Fly down with playfield collision check
          let HND_pfColumn = playerX[HND_playerIndex] : rem Check collision before moving
          let HND_pfColumn = HND_pfColumn - ScreenInsetX
          let HND_pfColumn = HND_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if HND_pfColumn & $80 then let HND_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if HND_pfColumn > 31 then let HND_pfColumn = 31
          
          let HND_playerY = playerY[HND_playerIndex] : rem Check row below player (feet at bottom of sprite)
          let HND_feetY = HND_playerY + 16
          let HND_feetRow = HND_feetY / pfrowheight : rem feetY = feet Y position
          rem feetRow = row below feet
          if HND_feetRow >= pfrows then return : rem Check if at or beyond bottom row
          rem At bottom, cannot move down
          if pfread(HND_pfColumn, HND_feetRow) then return : rem Check if playfield pixel is clear
          rem Blocked, cannot move down
          
          let playerVelocityY[HND_playerIndex] = 2 : rem Clear below - apply downward velocity impulse
          let playerVelocityYL[HND_playerIndex] = 0 : rem +2 pixels/frame downward
          let playerState[HND_playerIndex] = playerState[HND_playerIndex] & !2
          rem Ensure guard bit clear
          return

          rem KNIGHT GUY (7) - GUARD
KnightGuyDown
          goto StandardGuard : rem tail call

FrootyDown
          rem FROOTY (8) - FLY DOWN (no guard action)
          rem Frooty flies down instead of guarding
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
          rem Frooty flies down with playfield collision check (permanent flight)
          rem Input: temp1 = player index (0-3), playerX[], playerY[] (global arrays) = player positions, ScreenInsetX (global constant) = screen X inset
          rem Output: Downward velocity applied if clear below, guard bit cleared
          rem Mutates: temp1-temp4 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (guard bit cleared)
          rem Called Routines: None
          rem Constraints: Only moves down if row below is clear. Cannot move if already at bottom. Uses inline coordinate conversion (not shared subroutine)
          dim FD_playerIndex = temp1
          dim FD_pfColumn = temp2
          dim FD_playerY = temp3
          dim FD_feetY = temp3
          dim FD_feetRow = temp4
          rem Fly down with playfield collision check
          let FD_pfColumn = playerX[FD_playerIndex] : rem Check collision before moving
          let FD_pfColumn = FD_pfColumn - ScreenInsetX
          let FD_pfColumn = FD_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          rem   result ≥ 128
          if FD_pfColumn & $80 then let FD_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative,
          if FD_pfColumn > 31 then let FD_pfColumn = 31
          
          let FD_playerY = playerY[FD_playerIndex] : rem Check row below player (feet at bottom of sprite)
          let FD_feetY = FD_playerY + 16
          let FD_feetRow = FD_feetY / pfrowheight : rem feetY = feet Y position
          rem feetRow = row below feet
          if FD_feetRow >= pfrows then return : rem Check if at or beyond bottom row
          rem At bottom, cannot move down
          if pfread(FD_pfColumn, FD_feetRow) then return : rem Check if playfield pixel is clear
          rem Blocked, cannot move down
          
          let playerVelocityY[FD_playerIndex] = 2 : rem Clear below - apply downward velocity impulse
          let playerVelocityYL[FD_playerIndex] = 0 : rem +2 pixels/frame downward
          let playerState[FD_playerIndex] = playerState[FD_playerIndex] & !2
          rem Ensure guard bit clear
          return

          rem NEFERTEM (9) - GUARD
NefertemDown
          goto StandardGuard : rem tail call

          rem NINJISH GUY (10) - GUARD
NinjishGuyDown
          goto StandardGuard : rem tail call

          rem PORK CHOP (11) - GUARD
PorkChopDown
          goto StandardGuard : rem tail call

          rem RADISH GOBLIN (12) - GUARD
RadishGoblinDown
          goto StandardGuard : rem tail call

          rem ROBO TITO (13) - GUARD
RoboTitoDown
          rem RoboTito drops from ceiling on DOWN press, or guards if not latched
          rem Input: temp1 = player index (0-3), characterStateFlags_R[] (global SCRAM array) = character state flags, playerState[] (global array) = player states, missileStretchHeight_R[] (global SCRAM array) = stretch missile heights, MaskPlayerStateFlags, ActionFallingShifted (global constants) = state mask and animation value, PlayerStateBitFacing (global constant) = facing bit mask
          rem Output: RoboTito drops from ceiling if latched, or standard guard applied if not latched
          rem Mutates: temp1 (used for calculations), characterStateFlags_W[] (global SCRAM array) = character state flags (latched bit cleared if dropping), playerState[] (global array) = player states (ActionFalling set if dropping), missileStretchHeight_W[] (global SCRAM array) = stretch missile heights (cleared if dropping), playerState[], playerTimers[] (via StandardGuard if not latched)
          rem Called Routines: StandardGuard (tail call via goto if not latched)
          rem Constraints: If latched to ceiling, DOWN causes voluntary drop. If not latched, DOWN triggers standard guard
          rem RoboTito voluntary drop from ceiling
          if !(characterStateFlags_R[temp1] & 1) then RoboTitoNotLatched : rem Check if latched to ceiling
          goto RoboTitoNotLatched : rem Not latched, proceed to guard
          
RoboTitoVoluntaryDrop
          rem Helper: Releases RoboTito from ceiling on DOWN press
          rem Input: temp1 = player index, characterStateFlags_R[] (global SCRAM array) = character state flags, playerState[] (global array) = player states, missileStretchHeight_R[] (global SCRAM array) = stretch missile heights, MaskPlayerStateFlags, ActionFallingShifted (global constants) = state mask and animation value, PlayerStateBitFacing (global constant) = facing bit mask
          rem Output: RoboTito released from ceiling, falling animation set, stretch height cleared
          rem Mutates: characterStateFlags_W[] (global SCRAM array) = character state flags (latched bit cleared), playerState[] (global array) = player states (ActionFalling set), missileStretchHeight_W[] (global SCRAM array) = stretch missile heights (cleared)
          rem Called Routines: None
          rem Constraints: Internal helper for RoboTitoDown, only called when latched to ceiling
          dim RTLVD_playerIndex = temp1
          rem Release from ceiling on DOWN press
          let RTLVD_stateFlags = characterStateFlags_R[RTLVD_playerIndex] & (255 - PlayerStateBitFacing) : rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[RTLVD_playerIndex] = RTLVD_stateFlags
          let playerState[RTLVD_playerIndex] = (playerState[RTLVD_playerIndex] & MaskPlayerStateFlags) | ActionFallingShifted : rem Clear latched bit (bit 0)
          rem Set falling animation
          let missileStretchHeight_W[RTLVD_playerIndex] = 0 : rem Clear stretch missile height when dropping
          return
          
RoboTitoNotLatched
          rem Helper: Routes to standard guard if not latched
          rem Input: temp1 = player index
          rem Output: Standard guard applied
          rem Mutates: playerState[], playerTimers[] (via StandardGuard)
          rem Called Routines: StandardGuard (tail call via goto)
          rem Constraints: Internal helper for RoboTitoDown, only called when not latched
          goto StandardGuard : rem Not latched, use standard guard

          rem URSULO (14) - GUARD
UrsuloDown
          goto StandardGuard : rem tail call

          rem SHAMONE (15) - GUARD
ShamoneDown
          goto StandardGuard : rem tail call

          rem
          rem Placeholder Character Handlers (16-30)
          rem These characters are not yet implemented and use standard
          rem   behaviors

Char16Jump
          goto StandardJump : rem tail call

Char17Jump
          goto StandardJump : rem tail call

Char18Jump
          goto StandardJump : rem tail call

Char19Jump
          goto StandardJump : rem tail call

Char20Jump
          goto StandardJump : rem tail call

Char21Jump
          goto StandardJump : rem tail call

Char22Jump
          goto StandardJump : rem tail call

Char23Jump
          goto StandardJump : rem tail call

Char24Jump
          goto StandardJump : rem tail call

Char25Jump
          goto StandardJump : rem tail call

Char26Jump
          goto StandardJump : rem tail call

Char27Jump
          goto StandardJump : rem tail call

Char28Jump
          goto StandardJump : rem tail call

Char29Jump
          goto StandardJump : rem tail call

Char30Jump
          goto StandardJump : rem tail call

Char16Down
          goto StandardGuard : rem tail call

Char17Down
          goto StandardGuard : rem tail call

Char18Down
          goto StandardGuard : rem tail call

Char19Down
          goto StandardGuard : rem tail call

Char20Down
          goto StandardGuard : rem tail call

Char21Down
          goto StandardGuard : rem tail call

Char22Down
          goto StandardGuard : rem tail call

Char23Down
          goto StandardGuard : rem tail call

Char24Down
          goto StandardGuard : rem tail call

Char25Down
          goto StandardGuard : rem tail call

Char26Down
          goto StandardGuard : rem tail call

Char27Down
          goto StandardGuard : rem tail call

Char28Down
          goto StandardGuard : rem tail call

Char29Down
          goto StandardGuard : rem tail call

Char30Down
          goto StandardGuard : rem tail call

StandardJump
          rem
          rem Standard Behaviors
          rem Standard jump behavior for most characters
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1]
          rem Standard jump behavior used by most characters (default jump impulse)
          rem Input: temp1 = player index (0-3)
          rem Output: Upward velocity applied, jumping flag set
          rem Mutates: playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerState[] (global array) = player states (jumping flag set)
          rem Called Routines: None
          rem Constraints: None
          rem Apply upward velocity impulse (input applies impulse to
          let playerVelocityY[temp1] = 246 : rem   rigid body)
          rem -10 in 8-bit two’s complement: 256 - 10 = 246
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          rem Set jumping bit
          return

StandardGuard
          rem Standard guard behavior
          rem INPUT: temp1 = player index
          rem USES: playerState[temp1], playerTimers[temp1]
          rem NOTE: Flying characters (Frooty, Dragon of Storms, Harpy)
          rem   cannot guard
          rem Standard guard behavior used by most characters (blocks attacks, visual flashing)
          rem Input: temp1 = player index (0-3), playerChar[] (global array) = character types
          rem Output: Guard activated if allowed (not flying character, not in cooldown)
          rem Mutates: temp1-temp4 (used for calculations), playerState[], playerTimers[] (global arrays) = player states and timers (via StartGuard)
          rem Called Routines: CheckGuardCooldown (bank11) - checks guard cooldown, StartGuard (bank11) - activates guard
          rem Constraints: Flying characters (Frooty=8, Dragon of Storms=2, Harpy=6) cannot guard. Guard blocked if in cooldown
          dim SG_playerIndex = temp1
          dim SG_characterType = temp4
          dim SG_guardAllowed = temp2
          rem Flying characters cannot guard - DOWN is used for vertical
          rem   movement
          rem Frooty (8): DOWN = fly down (no gravity)
          rem Dragon of Storms (2): DOWN = fly down (no gravity)
          rem Harpy (6): DOWN = fly down (reduced gravity)
          let SG_characterType = playerChar[SG_playerIndex]
          if SG_characterType = 8 then return
          if SG_characterType = 2 then return : rem Frooty cannot guard
          if SG_characterType = 6 then return : rem Dragon of Storms cannot guard
          rem Harpy cannot guard
          
          let temp1 = SG_playerIndex : rem Check if guard is allowed (not in cooldown)
          gosub CheckGuardCooldown
          let SG_guardAllowed = temp2
          if SG_guardAllowed = 0 then return
          rem Guard blocked by cooldown
          
          let temp1 = SG_playerIndex : rem Start guard with proper timing
          goto StartGuard : rem tail call
          rem StartGuard sets guard bit and duration timer
          
          rem Set guard visual effect (flashing cyan)
          rem Character flashes light cyan ColCyan(12) in NTSC/PAL, Cyan
          rem   in SECAM
          rem This will be checked in sprite rendering routines

