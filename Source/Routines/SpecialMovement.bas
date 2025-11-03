          rem ChaosFight - Source/Routines/SpecialMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem SPECIAL MOVEMENT PHYSICS
          rem =================================================================
          rem Per-frame physics updates for characters with special movement.
          rem Called every frame after input handling to apply character-specific
          rem physics that are not handled by standard movement/gravity.

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   playerChar[0-3] - Character type indices
          rem   playerX[0-3], playerY[0-3] - Position
          rem   playerState[0-3] - State flags

          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curler, 2=Dragon of Storms, 3=Zoe Ryen, 4=FatTony, 5=Megax,
          rem   6=Harpy, 7=Knight, 8=Frooty, 9=Mystery, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Shamone
          rem =================================================================

          rem Apply special movement physics to all active players
ApplySpecialMovement
          currentPlayer = 0 : gosub ApplyPlayerSpecialMovement
          currentPlayer = 1 : gosub ApplyPlayerSpecialMovement
          if controllerStatus & SetQuadtariDetected then if selectedChar3 <> 255 then currentPlayer = 2 : gosub ApplyPlayerSpecialMovement
          if controllerStatus & SetQuadtariDetected then if selectedChar4 <> 255 then currentPlayer = 3 : gosub ApplyPlayerSpecialMovement
          return

          rem =================================================================
          rem APPLY SPECIAL PHYSICS TO ONE PLAYER
          rem =================================================================
          rem INPUT: currentPlayer = player index (0-3)
          rem USES: temp4 = character type
ApplyPlayerSpecialMovement
          temp4 = playerChar[currentPlayer]
          
          rem Bernie (0) - screen wrap top/bottom
          if temp4 = 0 then goto BernieScreenWrap
          
          rem Frooty (8) and Dragon of Storms (2) - free flight (no gravity)
          rem These characters skip gravity entirely
          if temp4 = 8 then return
          rem Frooty: no gravity
          if temp4 = 2 then return
          rem Dragon of Storms: no gravity (free flight)
          
          rem All other characters use standard physics
          return

          rem =================================================================
          rem BERNIE SCREEN WRAP
          rem =================================================================
          rem Bernie cannot jump, but can fall off bottom and reappear at top.
          rem This provides a unique movement advantage.
          rem INPUT: currentPlayer = player index
          rem USES: playerY[currentPlayer]
BernieScreenWrap
          rem Check if fallen off bottom edge
          if playerY[currentPlayer] > 90 then playerY[currentPlayer] = 10
          rem Reappear at top
          
          rem Check if somehow went above top edge
          if playerY[currentPlayer] < 5 then playerY[currentPlayer] = 80
          rem Reappear at bottom
          
          return
