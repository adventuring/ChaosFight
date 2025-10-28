          rem ChaosFight - Source/Routines/SpecialMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem SPECIAL MOVEMENT PHYSICS
          rem =================================================================
          rem Per-frame physics updates for characters with special movement.
          rem Called every frame after input handling to apply character-specific
          rem physics that aren''t handled by standard movement/gravity.
          rem
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   PlayerChar[0-3] - Character type indices
          rem   PlayerX[0-3], PlayerY[0-3] - Position
          rem   PlayerState[0-3] - State flags
          rem
          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curling, 2=Dragonet, 3=EXO, 4=FatTony, 5=Grizzard,
          rem   6=Harpy, 7=Knight, 8=Magical Faerie, 9=Mystery, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Veg Dog
          rem =================================================================

          rem Apply special movement physics to all active players
ApplySpecialMovement
          temp1 = 0 : gosub ApplyPlayerSpecialMovement
          temp1 = 1 : gosub ApplyPlayerSpecialMovement
          if QuadtariDetected && SelectedChar3 != 0 then
                    temp1 = 2 : gosub ApplyPlayerSpecialMovement
          endif
          if QuadtariDetected && SelectedChar4 != 0 then
                    temp1 = 3 : gosub ApplyPlayerSpecialMovement
          endif
          return

          rem =================================================================
          rem APPLY SPECIAL PHYSICS TO ONE PLAYER
          rem =================================================================
          rem INPUT: temp1 = player index (0-3)
          rem USES: temp4 = character type
ApplyPlayerSpecialMovement
          temp4 = PlayerChar[temp1]
          
          rem Bernie (0) - screen wrap top/bottom
          if temp4 = 0 then gosub BernieScreenWrap : return
          
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
          if PlayerY[temp1] > 90 then
                    PlayerY[temp1] = 10  : rem Reappear at top
          endif
          
          rem Check if somehow went above top edge
          if PlayerY[temp1] < 5 then
                    PlayerY[temp1] = 80  : rem Reappear at bottom
          endif
          
          return
