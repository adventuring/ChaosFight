          rem ChaosFight - Source/Routines/BeginFallingAnimation.bas
          rem Setup routine for Falling Animation. Sets initial state only.

BeginFallingAnimation
          rem Initialize Falling Animation mode
          rem Set animation state
          FallFrame = 0
          FallSpeed = 2
          FallComplete = 0
          
          rem Count active players for falling animation
          rem Start with Players 1 and 2 (always active if characters selected)
          ActivePlayers = 0
          if selectedChar1 <> 255 then let ActivePlayers = ActivePlayers + 1
          if selectedChar2 <> 255 then let ActivePlayers = ActivePlayers + 1
          
          rem Count Players 3 and 4 if Quadtari detected and characters selected
          if ControllerStatus & SetQuadtariDetected then goto BeginFallingCountQuadtari
          goto BeginFallingCountDone
BeginFallingCountQuadtari
          if selectedChar3 <> 255 then let ActivePlayers = ActivePlayers + 1
          if selectedChar4 <> 255 then let ActivePlayers = ActivePlayers + 1
BeginFallingCountDone
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Define quadrant starting positions for all players
          rem Quadrants: Top-left, Top-right, Bottom-left, Bottom-right
          rem Players start at their quadrant positions, then move to top of screen
          rem Participant 1 (array [0]) → Top-left quadrant
          if selectedChar1 <> 255 then
                    PlayerX[0] = 40
          rem Top-left X (centered in left half)
                    PlayerY[0] = 100
          rem Start at quadrant Y position (will move to top)
          end
          
          rem Participant 2 (array [1]) → Top-right quadrant
          if selectedChar2 <> 255 then
                    PlayerX[1] = 120
          rem Top-right X (centered in right half)
                    PlayerY[1] = 100
          rem Start at quadrant Y position (will move to top)
          end
          
          rem Participant 3 (array [2]) → Bottom-left quadrant (4-player mode only)
          if ControllerStatus & SetQuadtariDetected then goto BeginFallingSetPlayer3
          goto BeginFallingSetPlayer3Done
BeginFallingSetPlayer3
          if selectedChar3 <> 255 then
                    PlayerX[2] = 40
          rem Bottom-left X (centered in left half)
                    PlayerY[2] = 150
          rem Start at quadrant Y position (will move to top)
          end
BeginFallingSetPlayer3Done
          
          rem Participant 4 (array [3]) → Bottom-right quadrant (4-player mode only)
          if ControllerStatus & SetQuadtariDetected then goto BeginFallingSetPlayer4
          goto BeginFallingSetPlayer4Done
BeginFallingSetPlayer4
          if selectedChar4 <> 255 then
                    PlayerX[3] = 120
          rem Bottom-right X (centered in right half)
                    PlayerY[3] = 150
          rem Start at quadrant Y position (will move to top)
          end
BeginFallingSetPlayer4Done

          return


