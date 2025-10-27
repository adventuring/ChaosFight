          rem ChaosFight - Source/Routines/TitleScreenMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem TITLE SCREEN - MAIN LOOP
          rem =================================================================
          rem Main title screen display and input handling.
          rem Dispatches to other modules for character parade and rendering.
          rem
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   TitleParadeTimer - Frame counter for parade timing
          rem   TitleParadeChar - Current parade character (0-15)
          rem   TitleParadeX - X position of parade character
          rem   TitleParadeActive - Whether parade is currently running
          rem   QuadtariDetected - Whether 4-player mode is active
          rem
          rem FLOW:
          rem   1. Initialize title screen state
          rem   2. Loop: handle input, update parade, draw screen
          rem   3. On button press, transition to character select
          rem =================================================================

TitleScreen
          rem Initialize title screen
          COLUBK = ColBlue(8)
          
          rem Initialize character parade
          TitleParadeTimer = 0
          TitleParadeChar = 0
          TitleParadeX = 0
          TitleParadeActive = 0
          
          rem Title screen loop
TitleScreenLoop
          rem Handle input - any button press goes to character select
          rem Check standard controllers (Player 1 & 2)
          if joy0fire || joy1fire then goto TitleScreenComplete
          
          rem Check Quadtari controllers (Players 3 & 4 if active)
          if QuadtariDetected then
                    if joy2fire || joy3fire then goto TitleScreenComplete
          endif
          
          rem Update character parade
          gosub UpdateCharacterParade
          
          rem Draw title screen
          gosub DrawTitleScreen
          
          drawscreen
          goto TitleScreenLoop

TitleScreenComplete
          rem Transition to character select
          return

