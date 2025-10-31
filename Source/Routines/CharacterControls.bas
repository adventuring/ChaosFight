          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CHARACTER-SPECIFIC CONTROL LOGIC
          rem =================================================================
          rem Handles character-specific jump and down button behaviors.
          rem Called via "on PlayerChar[n] goto" dispatch from PlayerInput.bas

          rem INPUT VARIABLE:
          rem   temp1 = player index (0-3)

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

          rem BERNIE (0) - NO JUMP
          rem Bernie cannot jump, but can fall off bottom and wrap to top
          rem INPUT: temp1 = player index
BernieJump
          return 
          rem No jump action

          rem CURLER (1) - STANDARD JUMP
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1], PlayerState[temp1]
CurlerJump
          rem tail call
          goto StandardJump

          rem DRAGONET (2) - STANDARD JUMP
DragonetJump
          rem tail call
          goto StandardJump

          rem EXO PILOT (3) - STANDARD JUMP (light weight, high jump)
EXOJump
          PlayerY[temp1] = PlayerY[temp1] - 12 
          rem Lighter character, higher jump
          PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem FAT TONY (4) - STANDARD JUMP (heavy weight, lower jump)
FatTonyJump
          PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavier character, lower jump
          PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem GRIZZARD HANDLER (5) - STANDARD JUMP
GrizzardJump
          rem tail call
          goto StandardJump

          rem HARPY (6) - FLIGHT (repeated jumping)
          rem Harpy can "fly" by repeated jumping (sustained flight)
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1], PlayerState[temp1]
HarpyJump
          if PlayerY[temp1] <= 10 then SkipJump
          PlayerY[temp1] = PlayerY[temp1] - 3
          PlayerState[temp1] = PlayerState[temp1] | 4 
          rem Set jumping bit for animation
SkipJump
          return

          rem KNIGHT GUY (7) - STANDARD JUMP (heavy weight)
KnightJump
          PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavier character, lower jump
          PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem FROOTY (8) - FREE FLIGHT (vertical movement)
          rem Frooty can fly up/down freely, no guard action
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1]
FrootyJump
          if PlayerY[temp1] > 10 then PlayerY[temp1] = PlayerY[temp1] - 2
          return

          rem NEFERTEM (9) - STANDARD JUMP
NefertemJump
          rem tail call
          goto StandardJump

          rem NINJISH GUY (10) - STANDARD JUMP (very light, high jump)
NinjishJump
          PlayerY[temp1] = PlayerY[temp1] - 13 
          rem Very light character, highest jump
          PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem PORK CHOP (11) - STANDARD JUMP (heavy weight)
PorkChopJump
          PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavy character, lower jump
          PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem RADISH GOBLIN (12) - STANDARD JUMP (very light, high jump)
RadishJump
          PlayerY[temp1] = PlayerY[temp1] - 13 
          rem Very light character, highest jump
          PlayerState[temp1] = PlayerState[temp1] | 4
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
          PlayerY[temp1] = PlayerY[temp1] - 8 
          rem Heavy character, lower jump
          PlayerState[temp1] = PlayerState[temp1] | 4
          return

          rem VEG DOG (15) - STANDARD JUMP (light weight)
VegDogJump
          PlayerY[temp1] = PlayerY[temp1] - 11 
          rem Light character, good jump
          PlayerState[temp1] = PlayerState[temp1] | 4
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

          rem EXO PILOT (3) - GUARD
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
          rem USES: PlayerY[temp1], PlayerState[temp1]
FrootyDown
          if PlayerY[temp1] < 80 then PlayerY[temp1] = PlayerY[temp1] + 2
          PlayerState[temp1] = PlayerState[temp1] & !2 
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

          rem VEG DOG (15) - GUARD
VegDogDown
          rem tail call
          goto StandardGuard

          rem =================================================================
          rem STANDARD BEHAVIORS
          rem =================================================================

          rem Standard jump behavior for most characters
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1], PlayerState[temp1]
StandardJump
          PlayerY[temp1] = PlayerY[temp1] - 10
          PlayerState[temp1] = PlayerState[temp1] | 4 
          rem Set jumping bit
          return

          rem Standard guard behavior
          rem INPUT: temp1 = player index
          rem USES: PlayerState[temp1]
StandardGuard
          PlayerState[temp1] = PlayerState[temp1] | 2 
          rem Set guarding bit
          
          rem Set guard visual effect (flashing cyan)
          rem Character flashes light cyan ColCyan(12) in NTSC/PAL, Cyan in SECAM
          rem This will be checked in sprite rendering routines
          return

