          rem ChaosFight - Source/Routines/TitleCharacterParade.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateCharacterParade
          asm
UpdateCharacterParade
end
          rem Title Screen Character Parade
          rem Manages the animated character parade that runs across the bottom of the title screen after 5 seconds (when copyright disappears).
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   titleParadeTimer - Frame counter (increments each frame)
          rem   titleParadeCharacter - Current character index (0-MaxCharacter)
          rem   titleParadeX - X position of parade character
          rem   titleParadeActive - Boolean: parade currently running
          rem TIMING:
          rem   - Parade starts after ~4 seconds (TitleParadeDelayFrames frames, TV-dependent)
          rem   - Each character moves at 2 pixels/frame (left to right)
          rem   - 1 second pause (FramesPerSecond frames) between characters
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
          rem Increment parade timer
          let titleParadeTimer = titleParadeTimer + 1

          rem Start parade after ~4 seconds (TitleParadeDelayFrames frames)
          if titleParadeTimer < TitleParadeDelayFrames then return otherbank

          rem Check if we need to start a new character
          if !titleParadeActive then StartNewParadeCharacter

          rem Move character across screen (if active)
          goto MoveParadeCharacter

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
          rem Constraints: Must be colocated with UpdateCharacterParade
Roll
          let titleParadeCharacter = rand & $1f
          rem Random character 0-MaxCharacter
          if titleParadeCharacter > MaxCharacter then Roll
          rem Start off-screen left
          let titleParadeX = 246
          let titleParadeActive = 1
          return otherbank

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
          rem Constraints: Must be colocated with UpdateCharacterParade, ParadeCharacterLeft
          rem Move 2 pixels per frame
          let titleParadeX = titleParadeX + 2

          rem Check if character has left screen
          if titleParadeX > 170 then ParadeCharacterLeft
          return otherbank

ParadeCharacterLeft
          rem Character has left - wait 1 second (FramesPerSecond frames) before next
          rem
          rem Input: titleParadeTimer, titleParadeActive (from
          rem UpdateCharacterParade)
          rem
          rem Output: titleParadeActive set to 0, titleParadeTimer
          rem decremented by FramesPerSecond
          rem
          rem Mutates: titleParadeActive (set to 0), titleParadeTimer
          rem (decremented by FramesPerSecond)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with UpdateCharacterParade
          let titleParadeActive = 0
          rem Reset timer for next character
          let titleParadeTimer = titleParadeTimer - FramesPerSecond
          return otherbank

DrawParadeCharacter
          asm
DrawParadeCharacter

end
          rem
          rem Draw Parade Character
          rem Render the current parade character at the bottom of the screen.
          rem Input: titleParadeCharacter, titleParadeX, controllerStatus, rand
          rem
          rem Output: player0x, player0y set, COLUP0 set, sprite drawn
          rem via DrawParadeCharacterSprite
          rem
          rem Mutates: player0x, player0y (TIA registers),
          rem         COLUP0 (TIA register), currentCharacter, currentPlayer,
          rem         temp2-temp3 (LoadCharacterSprite parameters)
          rem
          rem Called Routines: DrawParadeCharacterSprite (bank14, colocated) - draws
          rem character sprite
          rem
          rem Constraints: Must be colocated with DrawParadeCharacterSprite
          rem              (tail call)
          rem Position character at bottom (y=80) and current X position
          player0x = titleParadeX
          player0y = 80

          rem Always face right while marching across the title screen
          REFP0 = PlayerStateBitFacing

          rem Parade render uses fixed white color
          COLUP0 = ColGray(12)

DrawParadeCharacterSprite
          rem
          rem Draw Parade Character Sprite
          rem Load actual character artwork for the parade sprite using
          rem the character art system.
          rem
          rem Input: titleParadeTimer (animation timing), titleParadeCharacter
          rem Output: Player 0 sprite data populated in SCRAM buffers
          rem Uses default walking animation for parade march
          let currentCharacter = titleParadeCharacter
          let currentPlayer = 0
          let temp2 = titleParadeTimer & 7
          let temp3 = ActionWalking
          gosub LoadCharacterSprite bank16
          return otherbank

