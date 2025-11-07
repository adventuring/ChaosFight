UpdateCharacterParade
          rem
          rem ChaosFight - Source/Routines/TitleCharacterParade.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Title Screen Character Parade
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
          rem Update parade state (called every frame)
          rem Manages the animated character parade that runs across the
          rem bottom of the title screen
          rem
          rem Input: titleParadeTimer (global) = frame counter
          rem        titleParadeActive (global) = parade active flag
          rem        TitleParadeDelayFrames (constant) = delay before
          rem        parade starts
          rem
          rem Output: titleParadeTimer incremented, parade state updated
          rem
          rem Mutates: titleParadeTimer (incremented), titleParadeActive
          rem (set via StartNewParadeCharacter),
          rem         titleParadeChar, titleParadeX (set via
          rem         StartNewParadeCharacter, MoveParadeCharacter)
          rem
          rem Called Routines: StartNewParadeCharacter - accesses rand,
          rem MaxCharacter,
          rem   MoveParadeCharacter - accesses titleParadeX
          rem
          rem Constraints: Must be colocated with
          rem StartNewParadeCharacter, MoveParadeCharacter,
          rem              ParadeCharacterLeft (all called via goto)
          rem              Called every frame from TitleScreenMain
          let titleParadeTimer = titleParadeTimer + 1 : rem Increment parade timer
          
          if titleParadeTimer < TitleParadeDelayFrames then return : rem Start parade after 5 seconds (300 frames at 60fps)
          
          if !titleParadeActive then StartNewParadeCharacter : rem Check if we need to start a new character
          
          if titleParadeActive then MoveParadeCharacter : rem Move character across screen (if active)
          
          return
          
StartNewParadeCharacter
          rem Start new character parade
          rem
          rem Input: rand (global) = random number generator,
          rem MaxCharacter (constant) = maximum character index
          rem
          rem Output: titleParadeChar set to random character,
          rem titleParadeX set to 246, titleParadeActive set to 1
          rem
          rem Mutates: titleParadeChar (set to random 0-MaxCharacter),
          rem titleParadeX (set to 246),
          rem         titleParadeActive (set to 1)
          rem
          rem Called Routines: None
          let titleParadeChar = rand & MaxCharacter : rem Constraints: Must be colocated with UpdateCharacterParade
          let titleParadeX = 246 : rem Random character 0-MaxCharacter
          let titleParadeActive = 1 : rem Start off-screen left
          return
          
MoveParadeCharacter
          rem Move character across screen
          rem
          rem Input: titleParadeX (global) = current X position
          rem
          rem Output: titleParadeX incremented by 2, dispatches to
          rem ParadeCharacterLeft if off-screen
          rem
          rem Mutates: titleParadeX (incremented by 2)
          rem
          rem Called Routines: None (dispatcher only)
          let titleParadeX = titleParadeX + 2 : rem Constraints: Must be colocated with UpdateCharacterParade, ParadeCharacterLeft
          rem Move 2 pixels per frame
          
          if titleParadeX > 170 then ParadeCharacterLeft : rem Check if character has left screen
          return
          
ParadeCharacterLeft
          rem Character has left - wait 1 second (60 frames) before next
          rem
          rem Input: titleParadeTimer, titleParadeActive (from
          rem UpdateCharacterParade)
          rem
          rem Output: titleParadeActive set to 0, titleParadeTimer
          rem decremented by 60
          rem
          rem Mutates: titleParadeActive (set to 0), titleParadeTimer
          rem (decremented by 60)
          rem
          rem Called Routines: None
          let titleParadeActive = 0 : rem Constraints: Must be colocated with UpdateCharacterParade
          let titleParadeTimer = titleParadeTimer - 60 
          rem Reset timer for next character
          return

DrawParadeCharacter
          rem
          rem Draw Parade Character
          rem Renders the current parade character at bottom of screen
          rem INPUT VARIABLES:
          rem   titleParadeChar - Character index (0-MaxCharacter)
          rem   titleParadeX - X position on screen
          rem USES:
          rem   player0x, player0y - Sprite position
          rem   COLUP0 - Sprite color
          rem Renders the current parade character at bottom of screen
          rem
          rem Input: titleParadeX (global) = X position of parade
          rem character
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        rand (global) = random number generator
          rem
          rem Output: player0x, player0y set, COLUP0 set, sprite drawn
          rem via DrawParadeCharacterSprite
          rem
          rem Mutates: player0x, player0y (TIA registers), COLUP0 (TIA
          rem color register),
          rem         temp1 (used for random color selection)
          rem
          rem Called Routines: DrawParadeCharacterSprite (bank9) - draws
          rem character sprite
          rem
          rem Constraints: Must be colocated with
          rem SetParadeColor4PlayerInline,
          rem              SetParadeColor4PlayerLastInline (all called
          rem              via goto)
          rem Position character at bottom (y=80) and current X position
          player0x = titleParadeX
          player0y = 80
          
          rem Set character color based on character type (inline
          rem   SetParadeCharacterColor)
          rem Randomize color for visual variety
          rem Without Quadtari: Randomly alternate indigo/red (lum=12)
          rem With Quadtari: Randomly select from indigo, red, yellow,
          if controllerStatus & SetQuadtariDetected then SetParadeColor4PlayerInline : rem green (lum=12)
          rem 2-player mode: Randomly choose indigo or red
          temp1 = rand & 1
          if temp1 then COLUP0 = ColRed(12)
          if !temp1 then COLUP0 = ColIndigo(12)
          rem Draw running animation for parade character
          goto DrawParadeCharacterSprite bank9 : rem tail call
          
SetParadeColor4PlayerInline
          rem 4-player mode: Randomly choose from all 4 player colors
          rem
          rem Input: rand (global) = random number generator
          rem
          rem Output: COLUP0 set to random player color, dispatches to
          rem SetParadeColor4PlayerLastInline or
          rem DrawParadeCharacterSprite
          rem
          rem Mutates: temp1 (random color selection), COLUP0 (TIA color
          rem register)
          rem
          rem Called Routines: None (dispatcher only, tail call to
          rem DrawParadeCharacterSprite)
          rem
          rem Constraints: Must be colocated with DrawParadeCharacter,
          rem SetParadeColor4PlayerLastInline
          temp1 = rand & 3
          if temp1 = 0 then COLUP0 = ColIndigo(12)
          if temp1 = 1 then COLUP0 = ColRed(12)
          if temp1 = 2 then COLUP0 = ColYellow(12)
          if temp1 = 3 then SetParadeColor4PlayerLastInline
          rem Draw running animation for parade character
          goto DrawParadeCharacterSprite bank9 : rem tail call
          
SetParadeColor4PlayerLastInline
          rem Set Player 4 color (Turquoise/Green depending on TV
          rem standard)
          rem
          rem Input: None (called from SetParadeColor4PlayerInline)
          rem
          rem Output: COLUP0 set to Player 4 color
          rem
          rem Mutates: COLUP0 (TIA color register)
          rem
          rem Called Routines: None (tail call to
          rem DrawParadeCharacterSprite)
          rem
          rem Constraints: Must be colocated with DrawParadeCharacter,
          rem SetParadeColor4PlayerInline
          COLUP0 = ColTurquoise(12)
          rem Player 4: Turquoise (SECAM macro maps to Cyan)
          rem Draw running animation for parade character
          goto DrawParadeCharacterSprite bank9 : rem tail call
          



DrawParadeCharacterSprite
          rem
          rem Draw Parade Character Sprite
          rem Renders running animation sprite with alternating leg
          rem   positions
          rem
          rem INPUT: titleParadeTimer (for animation frame selection)
          rem USES: player0 sprite data
          rem Renders running animation sprite with alternating leg
          rem positions
          rem
          rem Input: titleParadeTimer (global) = frame counter (for
          rem animation frame selection)
          rem
          rem Output: player0 sprite data set to running animation frame
          rem
          rem Mutates: player0 sprite data (set via inline sprite
          rem definition)
          rem
          rem Called Routines: None (uses inline sprite data)
          rem
          rem Constraints: Must be colocated with DrawParadeFrame1
          rem (called via goto)
          rem              Called from DrawParadeCharacter (bank9)
          rem Draw running animation sprite for parade character
          if (titleParadeTimer & 8) then DrawParadeFrame1 : rem Simple running animation with alternating leg positions
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
                    player0:
          rem Frame 1 - left leg forward
          rem
          rem Input: None (called from DrawParadeCharacterSprite)
          rem
          rem Output: player0 sprite data set to frame 1
          rem
          rem Mutates: player0 sprite data (set via inline sprite
          rem definition)
          rem
          rem Called Routines: None (uses inline sprite data)
          rem
          rem Constraints: Must be colocated with
          rem DrawParadeCharacterSprite
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

