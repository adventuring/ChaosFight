          rem ChaosFight - Source/Routines/TitleCharacterParade.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateCharacterParade
          rem Title Screen Character Parade
          rem Manages the animated character parade that runs across the bottom of the title screen after 5 seconds (when copyright disappears).
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   titleParadeTimer - Frame counter (increments each frame)
          rem   titleParadeCharacter - Current character index (0-MaxCharacter)
          rem   titleParadeX - X position of parade character
          rem   titleParadeActive - Boolean: parade currently running
          rem TIMING:
          rem   - Parade starts after ~4 seconds (250 frames at 60fps)
          rem   - Each character moves at 2 pixels/frame (left to right)
          rem   - 1 second pause (60 frames) between characters
          rem   - Characters chosen randomly from NumCharacters available
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
          rem         titleParadeCharacter, titleParadeX (set via
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
          
          if titleParadeTimer < TitleParadeDelayFrames then return : rem Start parade after ~4 seconds (250 frames at 60fps)
          
          if !titleParadeActive then StartNewParadeCharacter : rem Check if we need to start a new character
          
          if titleParadeActive then MoveParadeCharacter : rem Move character across screen (if active)
          
          return
          
StartNewParadeCharacter
          rem Start new character parade
          rem
          rem Input: rand (global) = random number generator,
          rem MaxCharacter (constant) = maximum character index
          rem
          rem Output: titleParadeCharacter set to random character,
          rem titleParadeX set to 246, titleParadeActive set to 1
          rem
          rem Mutates: titleParadeCharacter (set to random 0-MaxCharacter),
          rem titleParadeX (set to 246),
          rem         titleParadeActive (set to 1)
          rem
          rem Called Routines: None
          let titleParadeCharacter = rand & MaxCharacter : rem Constraints: Must be colocated with UpdateCharacterParade
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
          rem Render the current parade character at the bottom of the screen.
          rem Input: titleParadeCharacter, titleParadeX, controllerStatus, rand
          rem
          rem Output: player0x, player0y set, COLUP0 set, sprite drawn
          rem via DrawParadeCharacterSprite
          rem
          rem Mutates: player0x, player0y (TIA registers), COLUP0 (TIA
          rem color register via LoadCharacterColors),
          rem         temp1-temp5 (LoadCharacterColors parameters)
          rem
          rem Called Routines: DrawParadeCharacterSprite (bank9) - draws
          rem character sprite
          rem
          rem Constraints: Must be colocated with DrawParadeCharacterSprite
          rem              (tail call)
          rem Position character at bottom (y=80) and current X position
          player0x = titleParadeX
          player0y = 80
          
          rem Always face right while marching across the title screen
          REFP0 = PlayerStateBitFacing
          
          rem Load parade character colors using standard color loader
          let currentCharacter = titleParadeCharacter
          temp1 = currentCharacter
          temp2 = 0
          temp3 = 0
          temp4 = 0
          temp5 = 0
          gosub LoadCharacterColors bank10
          
DrawParadeCharacterSprite
          rem
          rem Draw Parade Character Sprite
          rem Load actual character artwork for the parade sprite using
          rem the character art system.
          rem
          rem Input: titleParadeTimer (animation timing), currentCharacter
          rem Output: Player 0 sprite data populated in SCRAM buffers
          temp1 = currentCharacter
          rem Use default walking animation for parade march
          temp2 = titleParadeTimer & 7
          temp3 = ActionWalking
          temp4 = 0
          gosub LocateCharacterArt bank14
          return

