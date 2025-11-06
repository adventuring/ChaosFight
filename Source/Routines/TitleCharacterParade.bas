          rem ChaosFight - Source/Routines/TitleCharacterParade.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem TITLE SCREEN CHARACTER PARADE
          rem ==========================================================
          rem Manages the animated character parade that runs across the
          rem bottom of the title screen after 5 seconds (when copyright
          rem   disappears).

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   titleParadeTimer - Frame counter (increments each frame)
          rem titleParadeChar - Current character index (0-MaxCharacter)
          rem   titleParadeX - X position of parade character
          rem   titleParadeActive - Boolean: parade currently running

          rem TIMING:
          rem   - Parade starts after 5 seconds (300 frames at 60fps)
          rem   - Each character moves at 2 pixels/frame (left to right)
          rem   - 1 second pause (60 frames) between characters
          rem - Characters chosen randomly from NumCharacters available

          rem CHARACTER INDICES:
          rem 0=Bernie, 1=Curler, 2=Dragon of Storms, 3=EXO, 4=FatTony,
          rem   5=Grizzard,
          rem 6=Harpy, 7=Knight Guy, 8=Frooty, 9=Nefertem, 10=Ninjish
          rem   Guy,
          rem 11=Pork Chop, 12=Radish, 13=Robo Tito, 14=Ursulo,
          rem   15=Shamone
          rem ==========================================================

          rem Update parade state (called every frame)
UpdateCharacterParade
          rem Increment parade timer
          let titleParadeTimer = titleParadeTimer + 1
          
          rem Start parade after 5 seconds (300 frames at 60fps)
          if titleParadeTimer < TitleParadeDelayFrames then return
          
          rem Check if we need to start a new character
          if !titleParadeActive then StartNewParadeCharacter
          
          rem Move character across screen (if active)
          if titleParadeActive then MoveParadeCharacter
          
          return
          
StartNewParadeCharacter
          rem Start new character parade
          let titleParadeChar = rand & MaxCharacter 
          rem Random character 0-MaxCharacter
          let titleParadeX = 246
          rem Start off-screen left
          let titleParadeActive = 1
          return
          
MoveParadeCharacter
          rem Move character across screen
          let titleParadeX = titleParadeX + 2 
          rem Move 2 pixels per frame
          
          rem Check if character has left screen
          if titleParadeX > 170 then ParadeCharacterLeft
          return
          
ParadeCharacterLeft
          rem Character has left - wait 1 second (60 frames) before next
          let titleParadeActive = 0
          let titleParadeTimer = titleParadeTimer - 60 
          rem Reset timer for next character
          return

          rem ==========================================================
          rem DRAW PARADE CHARACTER
          rem ==========================================================
          rem Renders the current parade character at bottom of screen
          rem INPUT VARIABLES:
          rem   titleParadeChar - Character index (0-MaxCharacter)
          rem   titleParadeX - X position on screen
          rem USES:
          rem   player0x, player0y - Sprite position
          rem   COLUP0 - Sprite color
DrawParadeCharacter
          rem Draw the current parade character at the bottom of the
          rem   screen
          rem Position character at bottom (y=80) and current X position
          player0x = titleParadeX
          player0y = 80
          
          rem Set character color based on character type (inline
          rem   SetParadeCharacterColor)
          rem Randomize color for visual variety
          rem Without Quadtari: Randomly alternate indigo/red (lum=12)
          rem With Quadtari: Randomly select from indigo, red, yellow,
          rem   green (lum=12)
          if controllerStatus & SetQuadtariDetected then SetParadeColor4Player
          
          rem 2-player mode: Randomly choose indigo or red
          temp1 = rand & 1
          if temp1 then SetParadeRed
          COLUP0 = ColIndigo(12) : goto SetParadeColorDone
SetParadeRed
          COLUP0 = ColRed(12) : goto SetParadeColorDone
          
SetParadeColor4Player
          rem 4-player mode: Randomly choose from all 4 player colors
          temp1 = rand & 3
          if temp1 = 0 then COLUP0 = ColIndigo(12) : goto SetParadeColorDone
          rem Player 1: Indigo
          if temp1 = 1 then COLUP0 = ColRed(12) : goto SetParadeColorDone
          rem Player 2: Red
          if temp1 = 2 then COLUP0 = ColYellow(12) : goto SetParadeColorDone
          rem Player 3: Yellow
#ifdef TV_SECAM
          COLUP0 = ColGreen(12)
          rem Player 4: Green (SECAM-specific, Turquoise maps to Cyan on
          rem   SECAM)
#else
          COLUP0 = ColTurquoise(12)
          rem Player 4: Turquoise (NTSC/PAL)
#endif
SetParadeColorDone
          
          rem Draw running animation for parade character
          rem tail call
          goto DrawParadeCharacterSprite
          



          rem ==========================================================
          rem DRAW PARADE CHARACTER SPRITE
          rem ==========================================================
          rem Renders running animation sprite with alternating leg
          rem   positions
          rem INPUT: titleParadeTimer (for animation frame selection)
          rem USES: player0 sprite data
DrawParadeCharacterSprite
          rem Draw running animation sprite for parade character
          rem Simple running animation with alternating leg positions
          if (titleParadeTimer & 8) then DrawParadeFrame1
          rem Frame 2 - right leg forward
                    player0:
                    %00011000
                    %00111100
                    %01111110
                    %00011000
                    %00011000
                    %00011000
                    %00011000
                    %00011000
end
          return
DrawParadeFrame1
          rem Frame 1 - left leg forward
                    player0:
                    %00011000
                    %00111100
                    %01111110
                    %00011000
                    %00011000
                    %00011000
                    %00011000
                    %00011000
end
          return

