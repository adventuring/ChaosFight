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
          rem Per-frame title screen display and input handling
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        controllerStatus (global) = controller detection state
          rem        INPT0, INPT2 (hardware) = Quadtari controller states
          rem Output: Dispatches to TitleScreenComplete or returns
          rem Mutates: None (dispatcher only)
          rem Called Routines: UpdateCharacterParade (bank9) - accesses parade state,
          rem   DrawTitleScreen (bank9) - accesses title screen state,
          rem   titledrawscreen (bank9) - accesses title screen graphics
          rem Constraints: Must be colocated with TitleSkipQuad, TitleScreenComplete
          rem              Called from MainLoop each frame (gameMode 2)
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
          rem Skip Quadtari controller check (not in 4-player mode)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with TitleScreenMain
          
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
          rem Input: None (called from TitleScreenMain)
          rem Output: gameMode set to ModeCharacterSelect, ChangeGameMode called
          rem Mutates: gameMode (global)
          rem Called Routines: ChangeGameMode (bank14) - accesses game mode state
          rem Constraints: Must be colocated with TitleScreenMain
          let gameMode = ModeCharacterSelect
          gosub ChangeGameMode bank14
          return
