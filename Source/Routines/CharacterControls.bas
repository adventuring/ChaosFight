          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER-SPECIFIC CONTROL LOGIC
          rem =================================================================
          rem Handles character-specific jump and down button behaviors.
          rem Called via "on PlayerChar[n] goto" dispatch from PlayerInput.bas

          rem INPUT VARIABLE:
          rem   temp1 = participant array index (0-3 maps to participants 1-4)

          rem AVAILABLE VARIABLES:
          rem   PlayerX[temp1], PlayerY[temp1] - Position
          rem   PlayerState[temp1] - State flags
          rem   PlayerMomentumX[temp1] - Horizontal momentum

          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curler, 2=Dragonet, 3=EXO, 4=FatTony, 5=Grizzard,
          rem   6=Harpy, 7=Knight, 8=Frooty, 9=Nefertem, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Veg Dog
          rem =================================================================

          rem =================================================================
          rem JUMP HANDLERS (Called via "on goto" from PlayerInput)
          rem =================================================================

          rem BERNIE (0) - NO JUMP, BUT CAN FALL THROUGH 1-ROW FLOORS
          rem Bernie cannot jump, but pressing UP allows him to fall through
          rem floors that are only 1 playfield row deep (platforms).
          rem This is called when UP is pressed to handle fall-through logic.
          rem INPUT: temp1 = player index
          rem USES: PlayerX[temp1], PlayerY[temp1], temp2, temp3, temp4, temp5, temp6
BernieJump
          rem Convert player X position to playfield column (0-31)
          rem Player X is in pixels (16-144), playfield is 32 columns, 4 pixels per column
          rem Column = (PlayerX[temp1] - ScreenInsetX) / 4
          temp2 = PlayerX[temp1]
          temp2 = temp2 - ScreenInsetX
          rem Now in range 0-128
          temp2 = temp2 / 4
          rem Now in range 0-32 (playfield column, clamp to 0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Convert player Y position to playfield row
          rem Player Y is bottom-left of sprite (top of sprite visually)
          rem For pfres=8: pfrowheight = 16 pixels per row
          rem Row = PlayerY[temp1] / pfrowheight
          temp3 = PlayerY[temp1]
          temp4 = temp3 / pfrowheight
          rem temp4 = row player sprite bottom is in (0-7 for pfres=8)
          
          rem Check if Bernie is standing ON a floor (row below feet is solid)
            rem Bernie feet are visually at bottom of 16px sprite, so check row below
          rem Feet are at PlayerY + 16, so row = (PlayerY + 16) / pfrowheight
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
          let PlayerY[temp1] = PlayerY[temp1] + 1
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
          rem PlayerY at top row = 0 * pfrowheight = 0
          let PlayerY[temp1] = 0
          return

          rem CURLER (1) - STANDARD JUMP
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1], PlayerState[temp1]
CurlerJump
          rem tail call
          goto StandardJump

          rem DRAGONET (2) - FREE FLIGHT (vertical movement)
          rem Dragonet can fly up/down freely
          rem INPUT: temp1 = player index
          rem USES: PlayerX[temp1], PlayerY[temp1], temp2, temp3, temp4
DragonetJump
          rem Fly up with playfield collision check
          rem Check collision before moving
          temp2 = PlayerX[temp1]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column (0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Check row above player (top of sprite)
          temp3 = PlayerY[temp1]
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
          let PlayerY[temp1] = PlayerY[temp1] - 2
          let PlayerState[temp1] = PlayerState[temp1] | 4
          rem Set jumping flag for animation
          return

          rem Zoe Ryen (3) - STANDARD JUMP (light weight, high jump)
EXOJump
          let PlayerY[temp1] = PlayerY[temp1] - 12 
          rem Lighter character, higher jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem FAT TONY (4) - STANDARD JUMP (heavy weight, lower jump)
FatTonyJump
          let PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavier character, lower jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem GRIZZARD HANDLER (5) - STANDARD JUMP
GrizzardJump
          rem tail call
          goto StandardJump

          rem HARPY (6) - FLAP TO FLY (UP input to flap)
          rem Harpy can fly by flapping (pressing UP repeatedly)
          rem Each flap provides upward thrust
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1], PlayerState[temp1]
HarpyJump
          rem Flap upward - move up by 3 pixels
            rem Check screen bounds - do not go above top
          if PlayerY[temp1] <= 5 then return
            rem Already at top, cannot flap higher
          let PlayerY[temp1] = PlayerY[temp1] - 3
          let PlayerState[temp1] = PlayerState[temp1] | 4 
          rem Set jumping/flying bit for animation
          return

          rem KNIGHT GUY (7) - STANDARD JUMP (heavy weight)
KnightJump
          let PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavier character, lower jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem FROOTY (8) - FREE FLIGHT (vertical movement)
          rem Frooty can fly up/down freely, no guard action
          rem INPUT: temp1 = player index
          rem USES: PlayerX[temp1], PlayerY[temp1], temp2, temp3, temp4
FrootyJump
          rem Fly up with playfield collision check
          rem Check collision before moving
          temp2 = PlayerX[temp1]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column (0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Check row above player (top of sprite)
          temp3 = PlayerY[temp1]
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
          let PlayerY[temp1] = PlayerY[temp1] - 2
          let PlayerState[temp1] = PlayerState[temp1] | 4
          rem Set jumping flag for animation
          return

          rem NEFERTEM (9) - STANDARD JUMP
NefertemJump
          rem tail call
          goto StandardJump

          rem NINJISH GUY (10) - STANDARD JUMP (very light, high jump)
NinjishJump
          let PlayerY[temp1] = PlayerY[temp1] - 13 
          rem Very light character, highest jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem PORK CHOP (11) - STANDARD JUMP (heavy weight)
PorkChopJump
          let PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavy character, lower jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem RADISH GOBLIN (12) - STANDARD JUMP (very light, high jump)
RadishJump
          let PlayerY[temp1] = PlayerY[temp1] - 13 
          rem Very light character, highest jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem ROBO TITO (13) - VERTICAL MOVEMENT (no jump physics)
          rem Robo Tito does not jump but moves vertically to screen top
          rem Special: sprite may not clear GRPn when done
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1]
RoboTitoJump
          if PlayerY[temp1] > 10 then PlayerY[temp1] = PlayerY[temp1] - 3
          return

          rem URSULO (14) - STANDARD JUMP (heavy weight)
UrsuloJump
          let PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavy character, lower jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem SHAMONE (15) - STANDARD JUMP (light weight)
ShamoneJump
          let PlayerY[temp1] = PlayerY[temp1] - 11 
          rem Light character, good jump
          let PlayerState[temp1] = PlayerState[temp1] | 4
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

          rem DRAGONET (2) - GUARD
DragonetDown
          rem tail call
          goto StandardGuard

          rem Zoe Ryen (3) - GUARD
EXODown
          rem tail call
          goto StandardGuard

          rem FAT TONY (4) - GUARD
FatTonyDown
          rem tail call
          goto StandardGuard

          rem GRIZZARD HANDLER (5) - GUARD
GrizzardDown
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
          rem INPUT: temp1 = player index
          rem USES: PlayerX[temp1], PlayerY[temp1], temp2, temp3, temp4
FrootyDown
          rem Fly down with playfield collision check
          rem Check collision before moving
          temp2 = PlayerX[temp1]
          temp2 = temp2 - ScreenInsetX
          temp2 = temp2 / 4
          rem temp2 = playfield column (0-31)
          if temp2 > 31 then temp2 = 31
          if temp2 < 0 then temp2 = 0
          
          rem Check row below player (feet at bottom of sprite)
          temp3 = PlayerY[temp1]
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
          let PlayerY[temp1] = PlayerY[temp1] + 2
          let PlayerState[temp1] = PlayerState[temp1] & !2 
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
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1], PlayerState[temp1]
StandardJump
          let PlayerY[temp1] = PlayerY[temp1] - 10
          let PlayerState[temp1] = PlayerState[temp1] | 4 
          rem Set jumping bit
          return

          rem Standard guard behavior
          rem INPUT: temp1 = player index
          rem USES: PlayerState[temp1]
StandardGuard
          let PlayerState[temp1] = PlayerState[temp1] | 2 
          rem Set guarding bit
          
          rem Set guard visual effect (flashing cyan)
          rem Character flashes light cyan ColCyan(12) in NTSC/PAL, Cyan in SECAM
          rem This will be checked in sprite rendering routines
          return

