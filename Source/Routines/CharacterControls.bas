          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER-SPECIFIC CONTROL LOGIC
          rem =================================================================
          rem Handles character-specific jump and down button behaviors.
          rem Called via "on playerChar[n] goto" dispatch from PlayerInput.bas

          rem INPUT VARIABLE:
          rem   currentPlayer = participant array index (0-3 maps to participants 1-4)

          rem AVAILABLE VARIABLES:
          rem   playerX[currentPlayer], playerY[currentPlayer] - Position
          rem   playerState[currentPlayer] - State flags
          rem   playerMomentumX[currentPlayer] - Horizontal momentum

          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curler, 2=Dragon of Storms, 3=Zoe Ryen, 4=FatTony, 5=Megax,
          rem   6=Harpy, 7=Knight, 8=Frooty, 9=Nefertem, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Shamone
          rem =================================================================

          rem =================================================================
          rem JUMP HANDLERS (Called via "on goto" from PlayerInput)
          rem =================================================================

          rem BERNIE (0) - NO JUMP, BUT CAN FALL THROUGH 1-ROW FLOORS
          rem Bernie cannot jump, but pressing UP allows him to fall through
          rem floors that are only 1 playfield row deep (platforms).
          rem This is called when UP is pressed to handle fall-through logic.
          rem INPUT: currentPlayer = player index
          rem USES: playerX[currentPlayer], playerY[currentPlayer], temp2, temp3, temp4, temp5, temp6
BernieJump
          rem Convert player X position to playfield column (0-31)
          rem Player X is in pixels (16-144), playfield is 32 columns, 4 pixels per column
          rem Column = (playerX[currentPlayer] - ScreenInsetX) / 4
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          rem Now in range 0-128
          temp2 = temp2 / 4
          rem Now in range 0-32 (playfield column, clamp to 0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Convert player Y position to playfield row
          rem Player Y is bottom-left of sprite (top of sprite visually)
          rem For pfres=8: pfrowheight = 16 pixels per row
          rem Row = playerY[currentPlayer] / pfrowheight
          temp3 = playerY[currentPlayer]
          temp4 = temp3 / pfrowheight
          rem temp4 = row player sprite bottom is in (0-7 for pfres=8)
          
          rem Check if Bernie is standing ON a floor (row below feet is solid)
            rem Bernie feet are visually at bottom of 16px sprite, so check row below
          rem Feet are at playerY + 16, so row = (playerY + 16) / pfrowheight
          temp5 = temp3 + 16
          rem temp5 = feet Y position in pixels
          temp6 = temp5 / pfrowheight
            rem temp6 = row directly below player feet
          
            rem Check if there is solid ground directly below feet
          if !pfread(temp2, temp6) then return
            rem No floor directly below feet, cannot fall through
          
            rem Floor exists directly below feet, check if it is only 1 row deep
          rem Special case: if at bottom row (pfrows - 1), check top row (0) for wrap
          rem For pfres=8: pfrows = 8, so bottom row is 7
          if temp6 >= pfrows - 1 then goto BernieCheckBottomWrap
          rem At or beyond bottom row, check wrap
          
          rem Normal case: Check row below that (temp6 + 1)
          temp4 = temp6 + 1
          rem temp4 = row below the floor row
          if pfread(temp2, temp4) then return
            rem Floor is 2+ rows deep, cannot fall through
          
          rem Floor is only 1 row deep - allow fall through
          rem Move Bernie down by 1 pixel per frame while UP is held
          rem This allows him to pass through the 1-row platform
          let playerY[currentPlayer] = playerY[currentPlayer] + 1
          return 
          
BernieCheckBottomWrap
          rem Special case: Bernie is at bottom row, trying to fall through
          rem Bottom row is always considered "1 row deep" since nothing is below it
          rem Check if top row (row 0) is clear for wrapping
          temp4 = 0
          rem temp4 = top row (row 0)
          if pfread(temp2, temp4) then return
            rem Top row is blocked, cannot wrap
          
          rem Top row is clear - wrap to top
            rem Set Bernie Y position to top of screen (row 0)
          rem playerY at top row = 0 * pfrowheight = 0
          let playerY[currentPlayer] = 0
          return

          rem CURLER (1) - STANDARD JUMP
          rem INPUT: currentPlayer = player index
          rem USES: playerY[currentPlayer], playerState[currentPlayer]
CurlerJump
          rem tail call
          goto StandardJump

          rem DRAGON OF STORMS (2) - FREE FLIGHT (vertical movement)
          rem Dragon of Storms can fly up/down freely
          rem INPUT: currentPlayer = player index
          rem USES: playerX[currentPlayer], playerY[currentPlayer], temp2, temp3, temp4
DragonOfStormsJump
          rem Fly up with playfield collision check
          rem Check collision before moving
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column (0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Check row above player (top of sprite)
          temp3 = playerY[currentPlayer]
          temp4 = temp3 / pfrowheight
          rem temp4 = current row
          rem Check row above (temp4 - 1), but only if not at top
          if temp4 <= 0 then return
          rem Already at top row
          temp4 = temp4 - 1
          rem Check if playfield pixel is clear
          if pfread(temp2, temp4) then return
            rem Blocked, cannot move up
          
          rem Clear above - move up
          let playerY[currentPlayer] = playerY[currentPlayer] - 2
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          rem Set jumping flag for animation
          return

          rem Zoe Ryen (3) - STANDARD JUMP (light weight, high jump)
ZoeRyenJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 12 
          rem Lighter character, higher jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          return

          rem FAT TONY (4) - STANDARD JUMP (heavy weight, lower jump)
FatTonyJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 8 
          rem Heavier character, lower jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          return

          rem MEGAX (5) - STANDARD JUMP
MegaxJump
          rem tail call
          goto StandardJump

          rem HARPY (6) - FLAP TO FLY (UP input to flap)
          rem Harpy can fly by flapping (pressing UP repeatedly)
          rem Each flap provides upward thrust
          rem INPUT: currentPlayer = player index
          rem USES: playerY[currentPlayer], playerState[currentPlayer]
HarpyJump
          rem Flap upward - move up by 3 pixels
            rem Check screen bounds - do not go above top
          if playerY[currentPlayer] <= 5 then return
            rem Already at top, cannot flap higher
          let playerY[currentPlayer] = playerY[currentPlayer] - 3
          let playerState[currentPlayer] = playerState[currentPlayer] | 4 
          rem Set jumping/flying bit for animation
          return

          rem KNIGHT GUY (7) - STANDARD JUMP (heavy weight)
KnightJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 8 
          rem Heavier character, lower jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          return

          rem FROOTY (8) - FREE FLIGHT (vertical movement)
          rem Frooty can fly up/down freely, no guard action
          rem INPUT: currentPlayer = player index
          rem USES: playerX[currentPlayer], playerY[currentPlayer], temp2, temp3, temp4
FrootyJump
          rem Fly up with playfield collision check
          rem Check collision before moving
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column (0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Check row above player (top of sprite)
          temp3 = playerY[currentPlayer]
          temp4 = temp3 / pfrowheight
          rem temp4 = current row
          rem Check row above (temp4 - 1), but only if not at top
          if temp4 <= 0 then return
          rem Already at top row
          temp4 = temp4 - 1
          rem Check if playfield pixel is clear
          if pfread(temp2, temp4) then return
            rem Blocked, cannot move up
          
          rem Clear above - move up
          let playerY[currentPlayer] = playerY[currentPlayer] - 2
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          rem Set jumping flag for animation
          return

          rem NEFERTEM (9) - STANDARD JUMP
NefertemJump
          rem tail call
          goto StandardJump

          rem NINJISH GUY (10) - STANDARD JUMP (very light, high jump)
NinjishJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 13 
          rem Very light character, highest jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          return

          rem PORK CHOP (11) - STANDARD JUMP (heavy weight)
PorkChopJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 8 
          rem Heavy character, lower jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          return

          rem RADISH GOBLIN (12) - STANDARD JUMP (very light, high jump)
RadishJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 13 
          rem Very light character, highest jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          return

          rem ROBO TITO (13) - VERTICAL MOVEMENT (no jump physics)
          rem Robo Tito does not jump but moves vertically to screen top
          rem Special: sprite may not clear GRPn when done
          rem INPUT: currentPlayer = player index
          rem USES: playerY[currentPlayer]
RoboTitoJump
          if playerY[currentPlayer] > 10 then playerY[currentPlayer] = playerY[currentPlayer] - 3
          return

          rem URSULO (14) - STANDARD JUMP (heavy weight)
UrsuloJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 8 
          rem Heavy character, lower jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
          return

          rem SHAMONE (15) - STANDARD JUMP (light weight)
ShamoneJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 11 
          rem Light character, good jump
          let playerState[currentPlayer] = playerState[currentPlayer] | 4
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

          rem DRAGON OF STORMS (2) - GUARD
DragonOfStormsDown
          rem tail call
          goto StandardGuard

          rem Zoe Ryen (3) - GUARD
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

          rem HARPY (6) - GUARD
HarpyDown
          rem tail call
          goto StandardGuard

          rem KNIGHT GUY (7) - GUARD
KnightDown
          rem tail call
          goto StandardGuard

          rem FROOTY (8) - FLY DOWN (no guard action)
          rem Frooty flies down instead of guarding
          rem INPUT: currentPlayer = player index
          rem USES: playerX[currentPlayer], playerY[currentPlayer], temp2, temp3, temp4
FrootyDown
          rem Fly down with playfield collision check
          rem Check collision before moving
          temp2 = playerX[currentPlayer]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column (0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Check row below player (feet at bottom of sprite)
          temp3 = playerY[currentPlayer]
          temp3 = temp3 + 16
          rem temp3 = feet Y position
          temp4 = temp3 / pfrowheight
          rem temp4 = row below feet
          rem Check if at or beyond bottom row
          if temp4 >= pfrows then return
            rem At bottom, cannot move down
          rem Check if playfield pixel is clear
          if pfread(temp2, temp4) then return
            rem Blocked, cannot move down
          
          rem Clear below - move down
          let playerY[currentPlayer] = playerY[currentPlayer] + 2
          let playerState[currentPlayer] = playerState[currentPlayer] & !2 
          rem Ensure guard bit clear
          return

          rem NEFERTEM (9) - GUARD
NefertemDown
          rem tail call
          goto StandardGuard

          rem NINJISH GUY (10) - GUARD
NinjishDown
          rem tail call
          goto StandardGuard

          rem PORK CHOP (11) - GUARD
PorkChopDown
          rem tail call
          goto StandardGuard

          rem RADISH GOBLIN (12) - GUARD
RadishDown
          rem tail call
          goto StandardGuard

          rem ROBO TITO (13) - GUARD
RoboTitoDown
          rem tail call
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
          rem INPUT: currentPlayer = player index
          rem USES: playerY[currentPlayer], playerState[currentPlayer]
StandardJump
          let playerY[currentPlayer] = playerY[currentPlayer] - 10
          let playerState[currentPlayer] = playerState[currentPlayer] | 4 
          rem Set jumping bit
          return

          rem Standard guard behavior
          rem INPUT: currentPlayer = player index
          rem USES: playerState[currentPlayer]
StandardGuard
          let playerState[currentPlayer] = playerState[currentPlayer] | 2 
          rem Set guarding bit
          
          rem Set guard visual effect (flashing cyan)
          rem Character flashes light cyan ColCyan(12) in NTSC/PAL, Cyan in SECAM
          rem This will be checked in sprite rendering routines
          return

