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
          
          rem Note: Player positions should be set to quadrant positions before calling
          rem This is handled by the calling code (character select transition)

          return


