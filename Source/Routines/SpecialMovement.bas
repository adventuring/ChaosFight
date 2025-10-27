          rem ChaosFight - Source/Routines/SpecialMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem SPECIAL MOVEMENT PHYSICS
          rem =================================================================
          rem Per-frame physics updates for characters with special movement.
          rem This is called every frame after input handling to apply
          rem character-specific physics (e.g., Bernie's screen wrap).
          rem
          rem INPUT VARIABLE:
          rem   temp1 = player index (0-3)
          rem
          rem AVAILABLE VARIABLES:
          rem   PlayerChar[temp1] - Character type
          rem   PlayerX[temp1], PlayerY[temp1] - Position
          rem   PlayerState[temp1] - State flags
          rem
          rem CHARACTER INDICES:
          rem   0=Bernie, 1=Curling, 2=Dragonet, 3=EXO, 4=FatTony, 5=Grizzard,
          rem   6=Harpy, 7=Knight, 8=Magical Faerie, 9=Mystery, 10=Ninjish,
          rem   11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo, 15=Veg Dog
          rem =================================================================

          rem Apply special movement physics to all players
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

          rem Apply special movement for one player
          rem INPUT: temp1 = player index
ApplyPlayerSpecialMovement
          temp4 = PlayerChar[temp1]
          
          rem Bernie - screen wrap
          if temp4 = 0 then gosub BernieScreenWrap : return
          
          rem No special physics for other characters
          return

          rem =================================================================
          rem ROBO TITO SPECIAL MOVEMENT
          rem =================================================================
          rem Robo Tito does not jump but can reach the top of the screen
          rem His sprite continues to display last row until reaching ground
          rem Input: temp1 = player index
          HandleRoboTitoMovement
            rem Check if up is pressed
            if temp1 = 0 && joy0up then
              rem Move up instead of jump
              if PlayerY[0] > 10 then PlayerY[0] = PlayerY[0] - 2
            endif
            if temp1 = 1 && joy1up then
              if PlayerY[1] > 10 then PlayerY[1] = PlayerY[1] - 2
            endif
            if temp1 = 2 && joy2up then
              if PlayerY[2] > 10 then PlayerY[2] = PlayerY[2] - 2
            endif
            if temp1 = 3 && joy3up then
              if PlayerY[3] > 10 then PlayerY[3] = PlayerY[3] - 2
            endif
            
            rem Check if down is pressed
            if temp1 = 0 && joy0down then
              if PlayerY[0] < 80 then PlayerY[0] = PlayerY[0] + 2
            endif
            if temp1 = 1 && joy1down then
              if PlayerY[1] < 80 then PlayerY[1] = PlayerY[1] + 2
            endif
            if temp1 = 2 && joy2down then
              if PlayerY[2] < 80 then PlayerY[2] = PlayerY[2] + 2
            endif
            if temp1 = 3 && joy3down then
              if PlayerY[3] < 80 then PlayerY[3] = PlayerY[3] + 2
            endif
            return

          rem =================================================================
          rem BERNIE SPECIAL MOVEMENT
          rem =================================================================
          rem Bernie does not jump but wraps from top to bottom
          rem Input: temp1 = player index
          HandleBernieMovement
            rem Check if trying to jump (up pressed)
            if temp1 = 0 && joy0up then
              rem Don't allow jumping for Bernie
              PlayerState[0] = PlayerState[0] & ~4
            endif
            if temp1 = 1 && joy1up then
              PlayerState[1] = PlayerState[1] & ~4
            endif
            if temp1 = 2 && joy2up then
              PlayerState[2] = PlayerState[2] & ~4
            endif
            if temp1 = 3 && joy3up then
              PlayerState[3] = PlayerState[3] & ~4
            endif
            
            rem Handle vertical wrapping
            if PlayerY[temp1] < 10 then
              rem Wrapped off top, appear at bottom
              PlayerY[temp1] = 80
            endif
            if PlayerY[temp1] > 80 then
              rem Fell off bottom, appear at top
              PlayerY[temp1] = 10
            endif
            return

          rem =================================================================
          rem HARPY SPECIAL MOVEMENT
          rem =================================================================
          rem Harpy can "fly" by repeated jumping
          rem Attack causes diagonal swoop
          rem Input: temp1 = player index
          HandleHarpyMovement
            rem Allow repeated jumps (flying)
            rem Check if fire button pressed for swoop attack
            if temp1 = 0 && joy0fire then
              rem Swoop attack: move diagonally down and forward
              if PlayerState[0] & 1 then
                rem Facing right
                PlayerX[0] = PlayerX[0] + 3
                PlayerY[0] = PlayerY[0] + 2
              else
                rem Facing left
                PlayerX[0] = PlayerX[0] - 3
                PlayerY[0] = PlayerY[0] + 2
              endif
              rem Mark as attacking
              PlayerState[0] = PlayerState[0] | 16
            endif
            
            if temp1 = 1 && joy1fire then
              if PlayerState[1] & 1 then
                PlayerX[1] = PlayerX[1] + 3
                PlayerY[1] = PlayerY[1] + 2
              else
                PlayerX[1] = PlayerX[1] - 3
                PlayerY[1] = PlayerY[1] + 2
              endif
              PlayerState[1] = PlayerState[1] | 16
            endif
            
            if temp1 = 2 && joy2fire then
              if PlayerState[2] & 1 then
                PlayerX[2] = PlayerX[2] + 3
                PlayerY[2] = PlayerY[2] + 2
              else
                PlayerX[2] = PlayerX[2] - 3
                PlayerY[2] = PlayerY[2] + 2
              endif
              PlayerState[2] = PlayerState[2] | 16
            endif
            
            if temp1 = 3 && joy3fire then
              if PlayerState[3] & 1 then
                PlayerX[3] = PlayerX[3] + 3
                PlayerY[3] = PlayerY[3] + 2
              else
                PlayerX[3] = PlayerX[3] - 3
                PlayerY[3] = PlayerY[3] + 2
              endif
              PlayerState[3] = PlayerState[3] | 16
            endif
            
            rem Allow jump any time in air for flying effect
            if temp1 = 0 && joy0up then
              if PlayerY[0] > 10 then
                PlayerY[0] = PlayerY[0] - 3
                PlayerState[0] = PlayerState[0] | 4
              endif
            endif
            if temp1 = 1 && joy1up then
              if PlayerY[1] > 10 then
                PlayerY[1] = PlayerY[1] - 3
                PlayerState[1] = PlayerState[1] | 4
              endif
            endif
            if temp1 = 2 && joy2up then
              if PlayerY[2] > 10 then
                PlayerY[2] = PlayerY[2] - 3
                PlayerState[2] = PlayerState[2] | 4
              endif
            endif
            if temp1 = 3 && joy3up then
              if PlayerY[3] > 10 then
                PlayerY[3] = PlayerY[3] - 3
                PlayerState[3] = PlayerState[3] | 4
              endif
            endif
            return

          rem =================================================================
          rem MAGICAL FAERIE SPECIAL MOVEMENT
          rem =================================================================
          rem Magical Faerie can fly up/down freely but has no guard action
          rem Input: temp1 = player index
          HandleMagicalFaerieMovement
            rem Allow free vertical movement (flying)
            if temp1 = 0 && joy0up then
              if PlayerY[0] > 10 then PlayerY[0] = PlayerY[0] - 2
            endif
            if temp1 = 1 && joy1up then
              if PlayerY[1] > 10 then PlayerY[1] = PlayerY[1] - 2
            endif
            if temp1 = 2 && joy2up then
              if PlayerY[2] > 10 then PlayerY[2] = PlayerY[2] - 2
            endif
            if temp1 = 3 && joy3up then
              if PlayerY[3] > 10 then PlayerY[3] = PlayerY[3] - 2
            endif
            
            rem Allow free downward movement
            if temp1 = 0 && joy0down then
              if PlayerY[0] < 80 then PlayerY[0] = PlayerY[0] + 2
            endif
            if temp1 = 1 && joy1down then
              if PlayerY[1] < 80 then PlayerY[1] = PlayerY[1] + 2
            endif
            if temp1 = 2 && joy2down then
              if PlayerY[2] < 80 then PlayerY[2] = PlayerY[2] + 2
            endif
            if temp1 = 3 && joy3down then
              if PlayerY[3] < 80 then PlayerY[3] = PlayerY[3] + 2
            endif
            
            rem Disable guard action for Magical Faerie
            rem Clear guarding bit if somehow set
            PlayerState[temp1] = PlayerState[temp1] & ~2
            
            rem No gravity for Magical Faerie (can hover)
            return

