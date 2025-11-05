          rem ChaosFight - Source/Routines/SpecialMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem SPECIAL MOVEMENT PHYSICS
          rem ==========================================================
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
          temp1 = 0 : gosub ApplyPlayerSpecialMovement
          temp1 = 1 : gosub ApplyPlayerSpecialMovement
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then temp1 = 2 : gosub ApplyPlayerSpecialMovement
          rem tail call
          goto ApplyPlayerSpecialMovement

          rem ==========================================================
          rem APPLY SPECIAL PHYSICS TO ONE PLAYER
          rem ==========================================================
          rem INPUT: temp1 = player index (0-3)
          rem USES: temp4 = character type
ApplyPlayerSpecialMovement
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
