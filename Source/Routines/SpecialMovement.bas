          rem ChaosFight - Source/Routines/SpecialMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ApplySpecialMovement
          rem Special Movement Physics
          rem Per-frame physics updates for characters with special movement.
          rem Called every frame after input handling to apply character-specific
          rem physics not handled by standard movement/gravity.
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   playerCharacter[0-3] - Character type indices
          rem   playerX[0-3], playerY[0-3] - Position
          rem   playerState[0-3] - State flags
          rem CHARACTER INDICES:
          rem 0=Bernie, 1=Curler, 2=Dragon of Storms, 3=EXO, 4=FatTony,
          rem   5=Grizzard,
          rem 6=Harpy, 7=Knight Guy, 8=Frooty, 9=Nefertem, 10=Ninjish
          rem   Guy,
          rem 11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo,
          rem   15=Shamone
          rem Apply special movement physics to all active players
          rem Inline ApplyPlayerSpecialMovement to avoid local label
          rem cross-bank issues
          rem
          rem Input: playerCharacter[] (global array) = character types,
          rem controllerStatus (global) = Quadtari detection,
          rem playerCharacter[] (global array) = player selections
          rem 3/4 selections
          rem
          rem Output: Special movement applied (currently no-op,
          rem characters handled in gravity system)
          rem
          rem Mutates: temp4 (used for character type checks)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Player 0 - Frooty (8) and Dragon of Storms (2) skip gravity
          let temp4 = playerCharacter[0]
          if temp4 = 8 then ApplySpecialMovementP1
          rem Frooty: no gravity (free flight)
          if temp4 = 2 then ApplySpecialMovementP1
ApplySpecialMovementP1
          rem Player 1 - Frooty (8) and Dragon of Storms (2) skip gravity
          let temp4 = playerCharacter[1]
          if temp4 = 8 then ApplySpecialMovementP2
          rem Frooty: no gravity (free flight)
          if temp4 = 2 then ApplySpecialMovementP2
ApplySpecialMovementP2
          rem Player 2 (if Quadtari) - Frooty (8) and Dragon of Storms (2) skip gravity
          if (controllerStatus & SetQuadtariDetected) = 0 then goto SkipP2Checks
          if playerCharacter[2] = NoCharacter then goto SkipP2Checks
          if playerCharacter[2] = 8 then goto ApplySpecialMovementP3
          if playerCharacter[2] = 2 then goto ApplySpecialMovementP3
SkipP2Checks
ApplySpecialMovementP3
          rem Player 3 (if Quadtari) - Frooty (8) and Dragon of Storms (2) skip gravity
          if (controllerStatus & SetQuadtariDetected) = 0 then goto SkipP3Checks
          if playerCharacter[3] = NoCharacter then goto SkipP3Checks
          if playerCharacter[3] = 8 then return
          if playerCharacter[3] = 2 then return
SkipP3Checks
          rem Player 3 - Frooty (8) and Dragon of Storms (2) skip gravity
          return

ApplyPlayerSpecialMovement
          rem
          rem Apply Special Physics To One Player
          rem
          rem INPUT: temp1 = player index (0-3)
          rem USES: temp4 = character type
          rem Apply special movement physics to a single player
          rem
          rem Input: temp1 = player index (0-3), playerCharacter[] (global
          rem array) = character types
          rem
          rem Output: Special movement applied (currently no-op,
          rem characters handled in gravity system)
          rem
          rem Mutates: temp4 (used for character type lookup)
          rem
          rem Called Routines: None
          rem Constraints: None
          let temp4 = playerCharacter[temp1]

          rem Bernie (0) - screen wrap handled in
          rem   CheckBoundaryCollisions
          rem Falling off bottom respawns at top, handled in
          rem   PlayerPhysicsGravity.bas

          rem Frooty (8) and Dragon of Storms (2) - free flight (no
          rem   gravity)
          rem These characters skip gravity entirely
          if temp4 = 8 then return
          rem Frooty: no gravity (free flight)
          if temp4 = 2 then return
          rem Dragon of Storms: no gravity (free flight)

          rem All other characters use standard physics
          return
          asm
          ApplySpecialMovement = .ApplySpecialMovement
end
