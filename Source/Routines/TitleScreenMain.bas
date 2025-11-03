          rem ChaosFight - Source/Routines/TitleScreenMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem TITLE SCREEN - MAIN LOOP
          rem =================================================================
          rem Main title screen display and input handling.
          rem Dispatches to other modules for character parade and rendering.

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   titleParadeTimer - Frame counter for parade timing
          rem   titleCopyrightTimer - Frame counter for copyright display (disappears at 5 seconds)
          rem   titleParadeChar - Current parade character (0-15)
          rem   titleParadeX - X position of parade character
          rem   titleParadeActive - Whether parade is currently running
          rem   QuadtariDetected - Whether 4-player mode is active

          rem FLOW:
          rem   1. Initialize title screen state
          rem   2. Loop: handle input, update parade, draw screen
          rem   3. On button press, transition to character select
          rem =================================================================

TitleScreen
          rem Title screen loop
TitleMainLoop
          rem Increment copyright timer (separate from parade timer)
          let titleCopyrightTimer = titleCopyrightTimer + 1
          
          rem Check for 3-minute timeout (10800 frames at 60fps) - transition to Attract mode
          rem titleParadeTimer increments each frame in UpdateCharacterParade
          if titleParadeTimer >= 10800 then goto TitleScreenAttract
          
          rem Handle input - any button press goes to character select
          rem Check standard controllers (Player 1 & 2)
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then goto TitleScreenComplete
          if joy1fire then goto TitleScreenComplete
          
          rem Check Quadtari controllers (Players 3 & 4 if active)
          if 0 = (controllerStatus & SetQuadtariDetected) then goto TitleSkipQuad
          if !INPT0{7} then goto TitleScreenComplete
          if !INPT2{7} then goto TitleScreenComplete
TitleSkipQuad
          
          gosub UpdateCharacterParade
          
          gosub DrawTitleScreen
          
          rem Draw screen with titlescreen kernel minikernel
          gosub titledrawscreen bank1
          goto TitleMainLoop

TitleScreenAttract
          rem Transition to Attract mode after 3 minutes
          let gameMode = ModeAttract : gosub bank13 ChangeGameMode
          return

TitleScreenComplete
          rem Transition to character select
          let gameMode = ModeCharacterSelect : gosub bank13 ChangeGameMode
          return


          rem =================================================================
          rem BEGIN TITLE SCREEN (setup + enter loop)
          rem =================================================================
BeginTitleScreen
          rem Initialize title screen
          COLUBK = ColGray(0)
          
          rem Initialize copyright timer (disappears at 5 seconds = 300 frames)
          let titleCopyrightTimer = 0
          
          rem Initialize character parade
          let titleParadeTimer = 0
          let titleParadeChar = 0
          let titleParadeX = 0
          let titleParadeActive = 0
          
          rem Enter the title screen main loop
          goto TitleScreen
