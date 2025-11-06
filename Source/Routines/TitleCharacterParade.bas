          rem ChaosFight - Source/Routines/TitleCharacterParade.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Title Screen Character Parade
          rem
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
          rem Manages the animated character parade that runs across the bottom of the title screen
          rem Input: titleParadeTimer (global) = frame counter
          rem        titleParadeActive (global) = parade active flag
          rem        TitleParadeDelayFrames (constant) = delay before parade starts
          rem Output: titleParadeTimer incremented, parade state updated
          rem Mutates: titleParadeTimer (incremented), titleParadeActive (set via StartNewParadeCharacter),
          rem         titleParadeChar, titleParadeX (set via StartNewParadeCharacter, MoveParadeCharacter)
          rem Called Routines: StartNewParadeCharacter - accesses rand, MaxCharacter,
          rem   MoveParadeCharacter - accesses titleParadeX
          rem Constraints: Must be colocated with StartNewParadeCharacter, MoveParadeCharacter,
          rem              ParadeCharacterLeft (all called via goto)
          rem              Called every frame from TitleScreenMain
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
          rem Input: rand (global) = random number generator, MaxCharacter (constant) = maximum character index
          rem Output: titleParadeChar set to random character, titleParadeX set to 246, titleParadeActive set to 1
          rem Mutates: titleParadeChar (set to random 0-MaxCharacter), titleParadeX (set to 246),
          rem         titleParadeActive (set to 1)
          rem Called Routines: None
          rem Constraints: Must be colocated with UpdateCharacterParade
          let titleParadeChar = rand & MaxCharacter 
          rem Random character 0-MaxCharacter
          let titleParadeX = 246
          rem Start off-screen left
          let titleParadeActive = 1
          return
          
MoveParadeCharacter
          rem Move character across screen
          rem Input: titleParadeX (global) = current X position
          rem Output: titleParadeX incremented by 2, dispatches to ParadeCharacterLeft if off-screen
          rem Mutates: titleParadeX (incremented by 2)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with UpdateCharacterParade, ParadeCharacterLeft
          let titleParadeX = titleParadeX + 2 
          rem Move 2 pixels per frame
          
          rem Check if character has left screen
          if titleParadeX > 170 then ParadeCharacterLeft
          return
          
ParadeCharacterLeft
          rem Character has left - wait 1 second (60 frames) before next
          rem Input: titleParadeTimer, titleParadeActive (from UpdateCharacterParade)
          rem Output: titleParadeActive set to 0, titleParadeTimer decremented by 60
          rem Mutates: titleParadeActive (set to 0), titleParadeTimer (decremented by 60)
          rem Called Routines: None
          rem Constraints: Must be colocated with UpdateCharacterParade
          let titleParadeActive = 0
          let titleParadeTimer = titleParadeTimer - 60 
          rem Reset timer for next character
          return

          rem Draw Parade Character
          rem
          rem Renders the current parade character at bottom of screen
          rem INPUT VARIABLES:
          rem   titleParadeChar - Character index (0-MaxCharacter)
          rem   titleParadeX - X position on screen
          rem USES:
          rem   player0x, player0y - Sprite position
          rem   COLUP0 - Sprite color
DrawParadeCharacter
          rem Renders the current parade character at bottom of screen
          rem Input: titleParadeX (global) = X position of parade character
          rem        controllerStatus (global) = controller detection state
          rem        rand (global) = random number generator
          rem Output: player0x, player0y set, COLUP0 set, sprite drawn via DrawParadeCharacterSprite
          rem Mutates: player0x, player0y (TIA registers), COLUP0 (TIA color register),
          rem         temp1 (used for random color selection)
          rem Called Routines: DrawParadeCharacterSprite (bank9) - draws character sprite
          rem Constraints: Must be colocated with SetParadeColor4PlayerInline,
          rem              SetParadeColor4PlayerLastInline (all called via goto)
          rem Position character at bottom (y=80) and current X position
          player0x = titleParadeX
          player0y = 80
          
          rem Set character color based on character type (inline
          rem   SetParadeCharacterColor)
          rem Randomize color for visual variety
          rem Without Quadtari: Randomly alternate indigo/red (lum=12)
          rem With Quadtari: Randomly select from indigo, red, yellow,
          rem   green (lum=12)
          if controllerStatus & SetQuadtariDetected then SetParadeColor4PlayerInline
          rem 2-player mode: Randomly choose indigo or red
          temp1 = rand & 1
          if temp1 then COLUP0 = ColRed(12)
          if !temp1 then COLUP0 = ColIndigo(12)
          rem Draw running animation for parade character
          rem tail call
          goto DrawParadeCharacterSprite bank9
          
SetParadeColor4PlayerInline
          rem 4-player mode: Randomly choose from all 4 player colors
          rem Input: rand (global) = random number generator
          rem Output: COLUP0 set to random player color, dispatches to SetParadeColor4PlayerLastInline or DrawParadeCharacterSprite
          rem Mutates: temp1 (random color selection), COLUP0 (TIA color register)
          rem Called Routines: None (dispatcher only, tail call to DrawParadeCharacterSprite)
          rem Constraints: Must be colocated with DrawParadeCharacter, SetParadeColor4PlayerLastInline
          temp1 = rand & 3
          if temp1 = 0 then COLUP0 = ColIndigo(12)
          if temp1 = 1 then COLUP0 = ColRed(12)
          if temp1 = 2 then COLUP0 = ColYellow(12)
          if temp1 = 3 then SetParadeColor4PlayerLastInline
          rem Draw running animation for parade character
          rem tail call
          goto DrawParadeCharacterSprite bank9
          
SetParadeColor4PlayerLastInline
          rem Set Player 4 color (Turquoise/Green depending on TV standard)
          rem Input: None (called from SetParadeColor4PlayerInline)
          rem Output: COLUP0 set to Player 4 color
          rem Mutates: COLUP0 (TIA color register)
          rem Called Routines: None (tail call to DrawParadeCharacterSprite)
          rem Constraints: Must be colocated with DrawParadeCharacter, SetParadeColor4PlayerInline
#ifdef TV_SECAM
          COLUP0 = ColGreen(12)
          rem Player 4: Green (SECAM-specific, Turquoise maps to Cyan on
          rem   SECAM)
#else
          COLUP0 = ColTurquoise(12)
          rem Player 4: Turquoise (NTSC/PAL)
#endif
          rem Draw running animation for parade character
          rem tail call
          goto DrawParadeCharacterSprite bank9
          



          rem Draw Parade Character Sprite
          rem
          rem Renders running animation sprite with alternating leg
          rem   positions
          rem INPUT: titleParadeTimer (for animation frame selection)
          rem USES: player0 sprite data
DrawParadeCharacterSprite
          rem Renders running animation sprite with alternating leg positions
          rem Input: titleParadeTimer (global) = frame counter (for animation frame selection)
          rem Output: player0 sprite data set to running animation frame
          rem Mutates: player0 sprite data (set via inline sprite definition)
          rem Called Routines: None (uses inline sprite data)
          rem Constraints: Must be colocated with DrawParadeFrame1 (called via goto)
          rem              Called from DrawParadeCharacter (bank9)
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
          rem Input: None (called from DrawParadeCharacterSprite)
          rem Output: player0 sprite data set to frame 1
          rem Mutates: player0 sprite data (set via inline sprite definition)
          rem Called Routines: None (uses inline sprite data)
          rem Constraints: Must be colocated with DrawParadeCharacterSprite
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

