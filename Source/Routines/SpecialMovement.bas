          rem ChaosFight - Source/Routines/SpecialMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem SPECIAL MOVEMENT PHYSICS
          rem =================================================================
          rem Per-frame physics updates for characters with special movement.
          rem Called every frame after input handling to apply character-specific
          rem physics that are not handled by standard movement/gravity.

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   PlayerChar[0-3] - Character type indices
          rem   PlayerX[0-3], PlayerY[0-3] - Position
          rem   PlayerState[0-3] - State flags

          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curler, 2=Dragonet, 3=EXO, 4=FatTony, 5=Grizzard,
          rem   6=Harpy, 7=Knight, 8=Frooty, 9=Mystery, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Veg Dog
          rem =================================================================

          rem Apply special movement physics to all active players
ApplySpecialMovement
          temp1 = 0 : gosub ApplyPlayerSpecialMovement
          temp1 = 1 : gosub ApplyPlayerSpecialMovement
          if ControllerStatus & SetQuadtariDetected then if SelectedChar3 <> 255 then temp1 = 2 : gosub ApplyPlayerSpecialMovement
          if ControllerStatus & SetQuadtariDetected then if SelectedChar4 <> 255 then temp1 = 3 : gosub ApplyPlayerSpecialMovement
          return

          rem =================================================================
          rem APPLY SPECIAL PHYSICS TO ONE PLAYER
          rem =================================================================
          rem INPUT: temp1 = player index (0-3)
          rem USES: temp4 = character type
ApplyPlayerSpecialMovement
          temp4 = PlayerChar[temp1]
          
          rem Bernie (0) - screen wrap top/bottom
          if temp4 = 0 then goto BernieScreenWrap
          
          rem Frooty (8) and Dragonet (2) - free flight (no gravity)
          rem These characters skip gravity entirely
          if temp4 = 8 then return
          rem Frooty: no gravity
          if temp4 = 2 then return
          rem Dragonet: no gravity (free flight)
          
          rem All other characters use standard physics
          return

          rem =================================================================
          rem BERNIE SCREEN WRAP
          rem =================================================================
          rem Bernie cannot jump, but can fall off bottom and reappear at top.
          rem This provides a unique movement advantage.
          rem INPUT: temp1 = player index
          rem USES: PlayerY[temp1]
BernieScreenWrap
          rem Check if fallen off bottom edge
          if PlayerY[temp1] > 90 then PlayerY[temp1] = 10
          rem Reappear at top
          
          rem Check if somehow went above top edge
          if PlayerY[temp1] < 5 then PlayerY[temp1] = 80
          rem Reappear at bottom
          
          return
