          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER-SPECIFIC CONTROL LOGIC
          rem =================================================================
          rem Handles character-specific jump and down button behaviors.
          rem Called via "on playerChar[n] goto" dispatch from PlayerInput.bas

          rem INPUT VARIABLE:
          rem   temp1 = player index (0-3)

          rem AVAILABLE VARIABLES:
          rem   playerX[temp1], playerY[temp1] - Position
          rem   playerState[temp1] - State flags
          rem   playerVelocityX[temp1] - Horizontal velocity

          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curler, 2=Dragon of Storms, 3=ZoeRyen, 4=FatTony, 5=Megax,
          rem   6=Harpy, 7=KnightGuy, 8=Frooty, 9=Nefertem, 10=NinjishGuy,
          rem   11=PorkChop, 12=RadishGoblin, 13=RoboTito, 14=Ursulo, 15=Shamone
          rem =================================================================

          rem =================================================================
          rem JUMP HANDLERS (Called via "on goto" from PlayerInput)
          rem =================================================================

          rem BERNIE (0) - NO JUMP, BUT CAN FALL THROUGH 1-ROW FLOORS
          rem Bernie cannot jump, but pressing UP allows him to fall through
          rem floors that are only 1 playfield row deep (platforms).
          rem This is called when UP is pressed to handle fall-through logic.
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4, temp5, temp6
BernieJump
          dim BJ_playerIndex = temp1
          dim BJ_pfColumn = temp2
          dim BJ_playerY = temp3
          dim BJ_currentRow = temp4
          dim BJ_feetY = temp5
          dim BJ_feetRow = temp6
          dim BJ_checkRow = temp4
          rem Convert player X position to playfield column (0-31)
          rem Player X is in pixels (16-144), playfield is 32 columns, 4 pixels per column
          rem Column = (playerX[playerIndex] - ScreenInsetX) / 4
          let BJ_pfColumn = playerX[BJ_playerIndex]
          let BJ_pfColumn = BJ_pfColumn - ScreenInsetX
          rem Now in range 0-128
          let BJ_pfColumn = BJ_pfColumn / 4
          rem Now in range 0-32 (playfield column, clamp to 0-31)
          if BJ_pfColumn > 31 then let BJ_pfColumn = 31
          if BJ_pfColumn < 0 then let BJ_pfColumn = 0
          
          rem Convert player Y position to playfield row
          rem Player Y is bottom-left of sprite (top of sprite visually)
          rem For pfres=8: pfrowheight = 16 pixels per row
          rem Row = playerY[playerIndex] / pfrowheight
          let BJ_playerY = playerY[BJ_playerIndex]
          let BJ_currentRow = BJ_playerY / pfrowheight
          rem currentRow = row player sprite bottom is in (0-7 for pfres=8)
          
          rem Check if Bernie is standing ON a floor (row below feet is solid)
          rem Bernie feet are visually at bottom of 16px sprite, so check row below
          rem Feet are at playerY + 16, so row = (playerY + 16) / pfrowheight
          let BJ_feetY = BJ_playerY + 16
          rem feetY = feet Y position in pixels
          let BJ_feetRow = BJ_feetY / pfrowheight
          rem feetRow = row directly below player feet
          
          rem Check if there is solid ground directly below feet
          if !pfread(BJ_pfColumn, BJ_feetRow) then return
          rem No floor directly below feet, cannot fall through
          
          rem Floor exists directly below feet, check if it is only 1 row deep
          rem Special case: if at bottom row (pfrows - 1), check top row (0) for wrap
          rem For pfres=8: pfrows = 8, so bottom row is 7
          if BJ_feetRow >= pfrows - 1 then BernieCheckBottomWrap
          rem At or beyond bottom row, check wrap
          
          rem Normal case: Check row below that (feetRow + 1)
          let BJ_checkRow = BJ_feetRow + 1
          rem checkRow = row below the floor row
          if pfread(BJ_pfColumn, BJ_checkRow) then return
          rem Floor is 2+ rows deep, cannot fall through
          
          rem Floor is only 1 row deep - allow fall through
          rem Move Bernie down by 1 pixel per frame while UP is held
          rem This allows him to pass through the 1-row platform
          let playerY[BJ_playerIndex] = playerY[BJ_playerIndex] + 1
          return 
          
BernieCheckBottomWrap
          dim BCBW_pfColumn = temp2
          dim BCBW_playerIndex = temp1
          dim BCBW_topRow = temp4
          rem Special case: Bernie is at bottom row, trying to fall through
          rem Bottom row is always considered "1 row deep" since nothing is below it
          rem Check if top row (row 0) is clear for wrapping
          let BCBW_topRow = 0
          rem topRow = top row (row 0)
          if pfread(BCBW_pfColumn, BCBW_topRow) then return
          rem Top row is blocked, cannot wrap
          
          rem Top row is clear - wrap to top
          rem Set Bernie Y position to top of screen (row 0)
          rem playerY at top row = 0 * pfrowheight = 0
          let playerY[BCBW_playerIndex] = 0
          return

          rem CURLER (1) - STANDARD JUMP
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1]
CurlerJump
          rem tail call
          goto StandardJump

          rem DRAGON OF STORMS (2) - FREE FLIGHT (vertical movement)
          rem Dragon of Storms can fly up/down freely
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
DragonetJump
          dim DJ_playerIndex = temp1
          dim DJ_pfColumn = temp2
          dim DJ_playerY = temp3
          dim DJ_currentRow = temp4
          dim DJ_checkRow = temp4
          rem Fly up with playfield collision check
          rem Check collision before moving
          let DJ_pfColumn = playerX[DJ_playerIndex]
          let DJ_pfColumn = DJ_pfColumn - ScreenInsetX
          let DJ_pfColumn = DJ_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if DJ_pfColumn > 31 then let DJ_pfColumn = 31
          if DJ_pfColumn < 0 then let DJ_pfColumn = 0
          
          rem Check row above player (top of sprite)
          let DJ_playerY = playerY[DJ_playerIndex]
          let DJ_currentRow = DJ_playerY / pfrowheight
          rem currentRow = current row
          rem Check row above (currentRow - 1), but only if not at top
          if DJ_currentRow <= 0 then return
          rem Already at top row
          let DJ_checkRow = DJ_currentRow - 1
          rem Check if playfield pixel is clear
          if pfread(DJ_pfColumn, DJ_checkRow) then return
          rem Blocked, cannot move up
          
          rem Clear above - apply upward velocity impulse
          let playerVelocityY[DJ_playerIndex] = 254
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityY_lo[DJ_playerIndex] = 0
          let playerState[DJ_playerIndex] = playerState[DJ_playerIndex] | 4
          rem Set jumping flag for animation
          return

          rem ZOE RYEN (3) - STANDARD JUMP (light weight, high jump)
ZoeRyenJump
          rem Apply upward velocity impulse (lighter character, higher jump)
          let playerVelocityY[temp1] = 244
          rem -12 in 8-bit two’s complement: 256 - 12 = 244
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem FAT TONY (4) - STANDARD JUMP (heavy weight, lower jump)
FatTonyJump
          rem Apply upward velocity impulse (heavier character, lower jump)
          let playerVelocityY[temp1] = 248
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem MEGAX (5) - STANDARD JUMP
MegaxJump
          rem tail call
          goto StandardJump

          rem HARPY (6) - FLAP TO FLY (UP input to flap)
          rem Harpy can fly by flapping (pressing UP repeatedly)
          rem Each flap provides upward thrust
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1], harpyFlightEnergy[temp1], harpyLastFlapFrame[temp1]
HarpyJump
          dim HJ_playerIndex = temp1
          dim HJ_framesSinceFlap = temp2
          rem Check if flight energy depleted
          if harpyFlightEnergy_R[HJ_playerIndex] = 0 then return
          rem No energy remaining, cannot flap
          
          rem Check flap cooldown: must wait for 1.5 flaps/second (40 frames at 60fps)
          let HJ_framesSinceFlap = frame - harpyLastFlapFrame_R[HJ_playerIndex]
          rem Calculate frames since last flap
          if HJ_framesSinceFlap > 127 then let HJ_framesSinceFlap = 127
          rem Clamp to prevent underflow (max safe value for 8-bit)
          if HJ_framesSinceFlap < HarpyFlapCooldownFrames then return
          rem Cooldown not expired, cannot flap yet
          
          rem Check screen bounds - do not go above top
          if playerY[HJ_playerIndex] <= 5 then HarpyFlapRecord
          rem Already at top, cannot flap higher but still record
          
          rem Flap upward - apply upward velocity impulse
          rem Gravity is 0.05 px/frame² for Harpy (reduced). Over 40 frames, gravity accumulates:
          rem   velocity_change = 0.05 * 40 = 2.0 px/frame (downward)
          rem To maintain height, flap impulse must counteract: -2.0 px/frame (upward)
          rem Using -2 px/frame (254 in two’s complement) for stable hover with 1.5 flaps/second
          let playerVelocityY[HJ_playerIndex] = 254
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityY_lo[HJ_playerIndex] = 0
          let playerState[HJ_playerIndex] = playerState[HJ_playerIndex] | 4
          rem Set jumping/flying bit for animation
          rem Set flight mode flag for slow gravity
          let characterStateFlags[HJ_playerIndex] = characterStateFlags[HJ_playerIndex] | 2
          rem Set bit 1 (flight mode)
          
HarpyFlapRecord
          dim HFR_playerIndex = temp1
          rem Decrement flight energy on each flap
          if harpyFlightEnergy_R[HFR_playerIndex] > 0 then let harpyFlightEnergy_W[HFR_playerIndex] = harpyFlightEnergy_R[HFR_playerIndex] - 1
          
          rem Record current frame as last flap time
          let harpyLastFlapFrame_W[HFR_playerIndex] = frame
          
          return

          rem KNIGHT GUY (7) - STANDARD JUMP (heavy weight)
KnightGuyJump
          rem Apply upward velocity impulse (heavier character, lower jump)
          let playerVelocityY[temp1] = 248
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem FROOTY (8) - PERMANENT FREE FLIGHT (vertical movement)
          rem Frooty has permanent flight ability - no UP tapping required
          rem Complete control over vertical position, gravity always overridden
          rem Can move up/down freely at all times, no guard action
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
FrootyJump
          dim FJ_playerIndex = temp1
          dim FJ_pfColumn = temp2
          dim FJ_playerY = temp3
          dim FJ_currentRow = temp4
          dim FJ_checkRow = temp4
          rem Fly up with playfield collision check
          rem Check collision before moving
          let FJ_pfColumn = playerX[FJ_playerIndex]
          let FJ_pfColumn = FJ_pfColumn - ScreenInsetX
          let FJ_pfColumn = FJ_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if FJ_pfColumn > 31 then let FJ_pfColumn = 31
          if FJ_pfColumn < 0 then let FJ_pfColumn = 0
          
          rem Check row above player (top of sprite)
          let FJ_playerY = playerY[FJ_playerIndex]
          let FJ_currentRow = FJ_playerY / pfrowheight
          rem currentRow = current row
          rem Check row above (currentRow - 1), but only if not at top
          if FJ_currentRow <= 0 then return
          rem Already at top row
          let FJ_checkRow = FJ_currentRow - 1
          rem Check if playfield pixel is clear
          if pfread(FJ_pfColumn, FJ_checkRow) then return
          rem Blocked, cannot move up
          
          rem Clear above - apply upward velocity impulse
          let playerVelocityY[FJ_playerIndex] = 254
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityY_lo[FJ_playerIndex] = 0
          let playerState[FJ_playerIndex] = playerState[FJ_playerIndex] | 4
          rem Set jumping flag for animation
          return

          rem NEFERTEM (9) - STANDARD JUMP
NefertemJump
          rem tail call
          goto StandardJump

          rem NINJISH GUY (10) - STANDARD JUMP (very light, high jump)
NinjishGuyJump
          rem Apply upward velocity impulse (very light character, highest jump)
          let playerVelocityY[temp1] = 243
          rem -13 in 8-bit two’s complement: 256 - 13 = 243
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem PORK CHOP (11) - STANDARD JUMP (heavy weight)
PorkChopJump
          rem Apply upward velocity impulse (heavy character, lower jump)
          let playerVelocityY[temp1] = 248
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem RADISH GOBLIN (12) - STANDARD JUMP (very light, high jump)
RadishGoblinJump
          rem Apply upward velocity impulse (very light character, highest jump)
          let playerVelocityY[temp1] = 243
          rem -13 in 8-bit two’s complement: 256 - 13 = 243
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem ROBO TITO (13) - VERTICAL MOVEMENT (no jump physics)
          rem Robo Tito does not jump but moves vertically to screen top
          rem Special: sprite may not clear GRPn when done
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1]
RoboTitoJump
          dim RTJ_playerIndex = temp1
          rem RoboTito ceiling-stretch mechanic
          rem Check if already latched to ceiling
          if (characterStateFlags[RTJ_playerIndex] & 1) then return
          rem Already latched, ignore UP input
          
          rem Check if grounded (not jumping)
          if (playerState[RTJ_playerIndex] & 4) then RoboTitoStretching
          rem Not grounded, stretching upward
          goto RoboTitoStretching
          
RoboTitoStretching
          dim RTS_playerIndex = temp1
          rem Set stretching animation (repurposed ActionJumping = 10)
          let playerState[RTS_playerIndex] = (playerState[RTS_playerIndex] & MaskPlayerStateFlags) | (ActionJumping << ShiftAnimationState)
          
          rem Move upward 3 pixels per frame
          if playerY[RTS_playerIndex] <= 5 then RoboTitoCheckCeiling
          let playerY[RTS_playerIndex] = playerY[RTS_playerIndex] - 3
          return
          
RoboTitoCheckCeiling
          dim RTCC_playerIndex = temp1
          dim RTCC_pfColumn = temp2
          dim RTCC_playerY = temp3
          dim RTCC_currentRow = temp4
          dim RTCC_checkRow = temp4
          rem Check if ceiling contact using playfield collision
          let RTCC_pfColumn = playerX[RTCC_playerIndex]
          let RTCC_pfColumn = RTCC_pfColumn - ScreenInsetX
          let RTCC_pfColumn = RTCC_pfColumn / 4
          if RTCC_pfColumn > 31 then let RTCC_pfColumn = 31
          if RTCC_pfColumn < 0 then let RTCC_pfColumn = 0
          
          rem Check row above player for ceiling
          let RTCC_playerY = playerY[RTCC_playerIndex]
          if RTCC_playerY <= 0 then RoboTitoLatch
          let RTCC_currentRow = RTCC_playerY / pfrowheight
          if RTCC_currentRow <= 0 then RoboTitoLatch
          let RTCC_checkRow = RTCC_currentRow - 1
          if pfread(RTCC_pfColumn, RTCC_checkRow) then RoboTitoLatch
          
          rem No ceiling contact, continue stretching
          let playerY[RTCC_playerIndex] = playerY[RTCC_playerIndex] - 3
          return
          
RoboTitoLatch
          dim RTL_playerIndex = temp1
          rem Ceiling contact detected - latch to ceiling
          let characterStateFlags[RTL_playerIndex] = characterStateFlags[RTL_playerIndex] | 1
          rem Set latched bit
          let playerState[RTL_playerIndex] = (playerState[RTL_playerIndex] & MaskPlayerStateFlags) | (ActionFalling << ShiftAnimationState)
          rem Set latched animation (repurposed ActionFalling = 11)
          return

          rem URSULO (14) - STANDARD JUMP (heavy weight)
UrsuloJump
          rem Apply upward velocity impulse (heavy character, lower jump)
          let playerVelocityY[temp1] = 248
          rem -8 in 8-bit two’s complement: 256 - 8 = 248
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem SHAMONE (15) - STANDARD JUMP (light weight)
ShamoneJump
          rem Apply upward velocity impulse (light character, good jump)
          let playerVelocityY[temp1] = 245
          rem -11 in 8-bit two’s complement: 256 - 11 = 245
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return

          rem =================================================================
          rem DOWN BUTTON HANDLERS (Called via "on goto" from PlayerInput)
          rem =================================================================

          rem BERNIE (0) - GUARD
BernieDown
          rem tail call
          goto StandardGuard

          rem CURLER (1) - GUARD
CurlerDown
          rem tail call
          goto StandardGuard

          rem DRAGON OF STORMS (2) - FLY DOWN (no guard action)
          rem Dragon of Storms flies down instead of guarding
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
DragonetDown
          dim DD_playerIndex = temp1
          dim DD_pfColumn = temp2
          dim DD_playerY = temp3
          dim DD_feetY = temp3
          dim DD_feetRow = temp4
          rem Fly down with playfield collision check
          rem Check collision before moving
          let DD_pfColumn = playerX[DD_playerIndex]
          let DD_pfColumn = DD_pfColumn - ScreenInsetX
          let DD_pfColumn = DD_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if DD_pfColumn > 31 then let DD_pfColumn = 31
          if DD_pfColumn < 0 then let DD_pfColumn = 0
          
          rem Check row below player (feet at bottom of sprite)
          let DD_playerY = playerY[DD_playerIndex]
          let DD_feetY = DD_playerY + 16
          rem feetY = feet Y position
          let DD_feetRow = DD_feetY / pfrowheight
          rem feetRow = row below feet
          rem Check if at or beyond bottom row
          if DD_feetRow >= pfrows then return
          rem At bottom, cannot move down
          rem Check if playfield pixel is clear
          if pfread(DD_pfColumn, DD_feetRow) then return
          rem Blocked, cannot move down
          
          rem Clear below - apply downward velocity impulse
          let playerVelocityY[DD_playerIndex] = 2
          rem +2 pixels/frame downward
          let playerVelocityY_lo[DD_playerIndex] = 0
          let playerState[DD_playerIndex] = playerState[DD_playerIndex] & !2
          rem Ensure guard bit clear
          return

          rem ZOE RYEN (3) - GUARD
ZoeRyenDown
          rem tail call
          goto StandardGuard

          rem FAT TONY (4) - GUARD
FatTonyDown
          rem tail call
          goto StandardGuard

          rem MEGAX (5) - GUARD
MegaxDown
          rem tail call
          goto StandardGuard

          rem HARPY (6) - FLY DOWN (no guard action)
          rem Harpy flies down instead of guarding
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
HarpyDown
          dim HD_playerIndex = temp1
          dim HD_playerY = temp2
          dim HD_pfColumn = temp2
          dim HD_feetY = temp3
          dim HD_feetRow = temp4
          rem Check if Harpy is airborne and set dive mode
          if (playerState[HD_playerIndex] & 4) then HarpySetDive
          rem Jumping bit set, airborne
          let HD_playerY = playerY[HD_playerIndex]
          if HD_playerY < 60 then HarpySetDive
          rem Above ground level, airborne
          goto HarpyNormalDown
HarpySetDive
          dim HSD_playerIndex = temp1
          rem Set dive mode flag for increased damage and normal gravity
          let characterStateFlags[HSD_playerIndex] = characterStateFlags[HSD_playerIndex] | 4
          rem Set bit 2 (dive mode)
HarpyNormalDown
          dim HND_playerIndex = temp1
          dim HND_pfColumn = temp2
          dim HND_playerY = temp3
          dim HND_feetY = temp3
          dim HND_feetRow = temp4
          rem Fly down with playfield collision check
          rem Check collision before moving
          let HND_pfColumn = playerX[HND_playerIndex]
          let HND_pfColumn = HND_pfColumn - ScreenInsetX
          let HND_pfColumn = HND_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if HND_pfColumn > 31 then let HND_pfColumn = 31
          if HND_pfColumn < 0 then let HND_pfColumn = 0
          
          rem Check row below player (feet at bottom of sprite)
          let HND_playerY = playerY[HND_playerIndex]
          let HND_feetY = HND_playerY + 16
          rem feetY = feet Y position
          let HND_feetRow = HND_feetY / pfrowheight
          rem feetRow = row below feet
          rem Check if at or beyond bottom row
          if HND_feetRow >= pfrows then return
          rem At bottom, cannot move down
          rem Check if playfield pixel is clear
          if pfread(HND_pfColumn, HND_feetRow) then return
          rem Blocked, cannot move down
          
          rem Clear below - apply downward velocity impulse
          let playerVelocityY[HND_playerIndex] = 2
          rem +2 pixels/frame downward
          let playerVelocityY_lo[HND_playerIndex] = 0
          let playerState[HND_playerIndex] = playerState[HND_playerIndex] & !2
          rem Ensure guard bit clear
          return

          rem KNIGHT GUY (7) - GUARD
KnightGuyDown
          rem tail call
          goto StandardGuard

          rem FROOTY (8) - FLY DOWN (no guard action)
          rem Frooty flies down instead of guarding
          rem INPUT: temp1 = player index
          rem USES: playerX[temp1], playerY[temp1], temp2, temp3, temp4
FrootyDown
          dim FD_playerIndex = temp1
          dim FD_pfColumn = temp2
          dim FD_playerY = temp3
          dim FD_feetY = temp3
          dim FD_feetRow = temp4
          rem Fly down with playfield collision check
          rem Check collision before moving
          let FD_pfColumn = playerX[FD_playerIndex]
          let FD_pfColumn = FD_pfColumn - ScreenInsetX
          let FD_pfColumn = FD_pfColumn / 4
          rem pfColumn = playfield column (0-31)
          if FD_pfColumn > 31 then let FD_pfColumn = 31
          if FD_pfColumn < 0 then let FD_pfColumn = 0
          
          rem Check row below player (feet at bottom of sprite)
          let FD_playerY = playerY[FD_playerIndex]
          let FD_feetY = FD_playerY + 16
          rem feetY = feet Y position
          let FD_feetRow = FD_feetY / pfrowheight
          rem feetRow = row below feet
          rem Check if at or beyond bottom row
          if FD_feetRow >= pfrows then return
          rem At bottom, cannot move down
          rem Check if playfield pixel is clear
          if pfread(FD_pfColumn, FD_feetRow) then return
          rem Blocked, cannot move down
          
          rem Clear below - apply downward velocity impulse
          let playerVelocityY[FD_playerIndex] = 2
          rem +2 pixels/frame downward
          let playerVelocityY_lo[FD_playerIndex] = 0
          let playerState[FD_playerIndex] = playerState[FD_playerIndex] & !2
          rem Ensure guard bit clear
          return

          rem NEFERTEM (9) - GUARD
NefertemDown
          rem tail call
          goto StandardGuard

          rem NINJISH GUY (10) - GUARD
NinjishGuyDown
          rem tail call
          goto StandardGuard

          rem PORK CHOP (11) - GUARD
PorkChopDown
          rem tail call
          goto StandardGuard

          rem RADISH GOBLIN (12) - GUARD
RadishGoblinDown
          rem tail call
          goto StandardGuard

          rem ROBO TITO (13) - GUARD
RoboTitoDown
          rem RoboTito voluntary drop from ceiling
          rem Check if latched to ceiling
          if (characterStateFlags[temp1] & 1) = 0 then RoboTitoNotLatched
          rem Not latched, proceed to guard
          goto RoboTitoNotLatched
          
RoboTitoVoluntaryDrop
          rem Release from ceiling on DOWN press
          let characterStateFlags[temp1] = characterStateFlags[temp1] & 254
          rem Clear latched bit (bit 0)
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionFalling << ShiftAnimationState)
          rem Set falling animation
          return
          
RoboTitoNotLatched
          rem Not latched, use standard guard
          goto StandardGuard

          rem URSULO (14) - GUARD
UrsuloDown
          rem tail call
          goto StandardGuard

          rem SHAMONE (15) - GUARD
ShamoneDown
          rem tail call
          goto StandardGuard

          rem =================================================================
          rem STANDARD BEHAVIORS
          rem =================================================================

          rem Standard jump behavior for most characters
          rem INPUT: temp1 = player index
          rem USES: playerY[temp1], playerState[temp1]
StandardJump
          rem Apply upward velocity impulse (input applies impulse to rigid body)
          let playerVelocityY[temp1] = 246
          rem -10 in 8-bit two’s complement: 256 - 10 = 246
          let playerVelocityY_lo[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          rem Set jumping bit
          return

          rem Standard guard behavior
          rem INPUT: temp1 = player index
          rem USES: playerState[temp1], playerTimers[temp1]
          rem NOTE: Flying characters (Frooty, Dragon of Storms, Harpy) cannot guard
StandardGuard
          dim SG_playerIndex = temp1
          dim SG_characterType = temp4
          dim SG_guardAllowed = temp2
          rem Flying characters cannot guard - DOWN is used for vertical movement
          rem Frooty (8): DOWN = fly down (no gravity)
          rem Dragon of Storms (2): DOWN = fly down (no gravity)
          rem Harpy (6): DOWN = fly down (reduced gravity)
          let SG_characterType = playerChar[SG_playerIndex]
          if SG_characterType = 8 then return
          rem Frooty cannot guard
          if SG_characterType = 2 then return
          rem Dragon of Storms cannot guard
          if SG_characterType = 6 then return
          rem Harpy cannot guard
          
          rem Check if guard is allowed (not in cooldown)
          let temp1 = SG_playerIndex
          gosub CheckGuardCooldown
          let SG_guardAllowed = temp2
          if SG_guardAllowed = 0 then return
          rem Guard blocked by cooldown
          
          rem Start guard with proper timing
          let temp1 = SG_playerIndex
          rem tail call
          goto StartGuard
          rem StartGuard sets guard bit and duration timer
          
          rem Set guard visual effect (flashing cyan)
          rem Character flashes light cyan ColCyan(12) in NTSC/PAL, Cyan in SECAM
          rem This will be checked in sprite rendering routines

