          rem ChaosFight - Source/Routines/TitleScreenMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem TITLE SCREEN - PER-FRAME LOOP
          rem ==========================================================
          rem Per-frame title screen display and input handling.
          rem Called from MainLoop each frame (gameMode 2).
          rem Dispatches to other modules for character parade and
          rem   rendering.
          rem
          rem Setup is handled by BeginTitleScreen (called from
          rem   ChangeGameMode)
          rem This function processes one frame and returns.

          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   titleParadeTimer - Frame counter for parade timing
          rem titleParadeChar - Current parade character
          rem   (0-MaxCharacter)
          rem   titleParadeX - X position of parade character
          rem   titleParadeActive - Whether parade is currently running
          rem   QuadtariDetected - Whether 4-player mode is active

          rem FLOW PER FRAME:
          rem 1. Handle input - any button press goes to character
          rem   select
          rem   2. Update character parade
          rem   3. Draw screen
          rem   4. Return to MainLoop
          rem ==========================================================

TitleScreenMain
          rem Handle input - any button press goes to character select
          rem Check standard controllers (Player 1 & 2)
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then TitleScreenComplete
          if joy1fire then TitleScreenComplete
          
          rem Check Quadtari controllers (Players 3 & 4 if active)
          if 0 = (controllerStatus & SetQuadtariDetected) then TitleSkipQuad
          if !INPT0{7} then TitleScreenComplete
          if !INPT2{7} then TitleScreenComplete
TitleSkipQuad
          
          rem Update character parade animation
          gosub UpdateCharacterParade bank9
          
          rem Draw title screen
          gosub DrawTitleScreen bank9
          
          rem Draw screen with titlescreen kernel minikernel (titlescreen graphics in Bank 9)
          rem Note: MainLoop calls titledrawscreen, so this is only reached if called directly
          gosub titledrawscreen bank9
          
          return

TitleScreenComplete
          rem Transition to character select
          let gameMode = ModeCharacterSelect
          gosub ChangeGameMode bank14
          return
