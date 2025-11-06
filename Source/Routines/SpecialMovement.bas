          rem ChaosFight - Source/Routines/SpecialMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Special Movement Physics
          rem
          rem Per-frame physics updates for characters with special
          rem   movement.
          rem Called every frame after input handling to apply
          rem   character-specific
          rem physics that are not handled by standard movement/gravity.

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   playerChar[0-3] - Character type indices
          rem   playerX[0-3], playerY[0-3] - Position
          rem   playerState[0-3] - State flags

          rem CHARACTER INDICES:
          rem 0=Bernie, 1=Curler, 2=Dragon of Storms, 3=EXO, 4=FatTony,
          rem   5=Grizzard,
          rem 6=Harpy, 7=Knight Guy, 8=Frooty, 9=Nefertem, 10=Ninjish
          rem   Guy,
          rem 11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo,
          rem   15=Shamone
          rem ==========================================================

          rem Apply special movement physics to all active players
ApplySpecialMovement
          rem Inline ApplyPlayerSpecialMovement to avoid local label cross-bank issues
          rem Input: playerChar[] (global array) = character types, controllerStatus (global) = Quadtari detection, selectedChar3_R, selectedChar4_R (global SCRAM) = player 3/4 selections
          rem Output: Special movement applied (currently no-op, characters handled in gravity system)
          rem Mutates: temp4 (used for character type checks)
          rem Called Routines: None
          rem Constraints: None
          rem Player 0 - Frooty (8) and Dragon of Storms (2) skip gravity
          temp4 = playerChar[0]
          if temp4 = 8 then ApplySpecialMovementP1
          rem Frooty: no gravity (free flight)
          if temp4 = 2 then ApplySpecialMovementP1
          rem Dragon of Storms: no gravity (free flight)
ApplySpecialMovementP1
          rem Player 1 - Frooty (8) and Dragon of Storms (2) skip gravity
          temp4 = playerChar[1]
          if temp4 = 8 then ApplySpecialMovementP2
          rem Frooty: no gravity (free flight)
          if temp4 = 2 then ApplySpecialMovementP2
          rem Dragon of Storms: no gravity (free flight)
ApplySpecialMovementP2
          rem Player 2 (if Quadtari) - Frooty (8) and Dragon of Storms (2) skip gravity
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then if playerChar[2] = 8 then ApplySpecialMovementP3
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then if playerChar[2] = 2 then ApplySpecialMovementP3
          rem Dragon of Storms: no gravity (free flight)
ApplySpecialMovementP3
          rem Player 3 (if Quadtari) - Frooty (8) and Dragon of Storms (2) skip gravity
          if controllerStatus & SetQuadtariDetected then if !(selectedChar4_R = 255) then if playerChar[3] = 8 then return
          if controllerStatus & SetQuadtariDetected then if !(selectedChar4_R = 255) then if playerChar[3] = 2 then return
          rem Dragon of Storms: no gravity (free flight)
          return

          rem Apply Special Physics To One Player
          rem
          rem INPUT: temp1 = player index (0-3)
          rem USES: temp4 = character type
ApplyPlayerSpecialMovement
          rem Apply special movement physics to a single player
          rem Input: temp1 = player index (0-3), playerChar[] (global array) = character types
          rem Output: Special movement applied (currently no-op, characters handled in gravity system)
          rem Mutates: temp4 (used for character type lookup)
          rem Called Routines: None
          rem Constraints: None
          dim APSM_playerIndex = temp1
          temp4 = playerChar[APSM_playerIndex]
          
          rem Bernie (0) - screen wrap handled in
          rem   CheckBoundaryCollisions
          rem Falling off bottom respawns at top, handled in
          rem   PlayerPhysics.bas
          
          rem Frooty (8) and Dragon of Storms (2) - free flight (no
          rem   gravity)
          rem These characters skip gravity entirely
          if temp4 = 8 then return
          rem Frooty: no gravity (free flight)
          if temp4 = 2 then return
          rem Dragon of Storms: no gravity (free flight)
          
          rem All other characters use standard physics
          return
