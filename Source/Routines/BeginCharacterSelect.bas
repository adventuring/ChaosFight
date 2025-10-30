          rem ChaosFight - Source/Routines/BeginCharacterSelect.bas
          rem Setup routine for Character Select. Sets initial state only.

BeginCharacterSelect
          rem Set screen layout for character select (32×32 admin layout)
          gosub SetAdminScreenLayout
          
          rem Initialize character selections
          PlayerChar[0] = 0
          PlayerChar[1] = 0
          PlayerChar[2] = 0
          PlayerChar[3] = 0
          PlayerLocked[0] = 0
          PlayerLocked[1] = 0
          PlayerLocked[2] = 0
          PlayerLocked[3] = 0
          ControllerStatus = ControllerStatus & ClearQuadtariDetected
          
          rem Initialize character select animations
          CharSelectAnimTimer = 0
          CharSelectAnimState = 0
          CharSelectCharIndex = 0
          CharSelectAnimFrame = 0

          rem Check for Quadtari adapter
          gosub DetectQuadtari

          COLUBK = ColGray(0)

          return


