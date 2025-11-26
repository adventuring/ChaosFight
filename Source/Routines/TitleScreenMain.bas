          rem ChaosFight - Source/Routines/TitleScreenMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

TitleScreenMain
          asm
TitleScreenMain

end
          rem Title Screen - Per-frame Loop
          rem Per-frame title screen display and input handling.
          rem Called from MainLoop each frame (gameMode 2).
          rem Dispatches to other modules for character parade and rendering.
          rem Setup is handled by BeginTitleScreen (called from ChangeGameMode)
          rem This function processes one frame and returns.
          rem AVAILABLE VARIABLES (from Variables.bas):
          rem   titleParadeTimer - Frame counter for parade timing
          rem titleParadeCharacter - Current parade character
          rem   (0-MaxCharacter)
          rem   titleParadeX - X position of parade character
          rem   titleParadeActive - Whether parade is currently running
          rem   QuadtariDetected - Whether 4-player mode is active
          rem FLOW PER FRAME:
          rem 1. Update random number generator (every frame)
          rem 2. Handle input - any button press goes to character
          rem   select
          rem 3. Update character parade
          rem 4. Draw screen
          rem 5. Return to MainLoop
          rem Per-frame title screen display and input handling
          rem
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        INPT0, INPT2 (hardware) = Quadtari controller
          rem        states
          rem
          rem Output: Dispatches to TitleScreenComplete or returns
          rem
          rem Mutates: rand (global) - random number generator state
          rem
          rem Called Routines: UpdateCharacterParade (bank14) - accesses
          rem parade state,
          rem   DrawTitleScreen (bank9) - accesses title screen state,
          rem   titledrawscreen bank9 - accesses title screen graphics
          rem
          rem Constraints: Must be colocated with TitleSkipQuad,
          rem TitleScreenComplete
          rem              Called from MainLoop each frame (gameMode 2)
          rem Update random number generator (use local Randomize routine)
          rem Handle input - any button press goes to character select
          gosub randomize
          rem Check standard controllers (Player 1 & 2)
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then TitleScreenComplete
          if joy1fire then TitleScreenComplete

          rem Check Quadtari controllers (Players 3 & 4 if active)
          if 0 = (controllerStatus & SetQuadtariDetected) then TitleDoneQuad
          if !INPT0{7} then TitleScreenComplete
          if !INPT2{7} then TitleScreenComplete
TitleDoneQuad
          rem Skip Quadtari controller check (not in 4-player mode)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with TitleScreenMain

          rem Update character parade animation
          gosub UpdateCharacterParade bank14

          rem Draw title screen
          gosub DrawTitleScreen bank9

          rem Draw screen with titlescreen kernel minikernel
          rem (titlescreen system in Bank 9)
          rem Note: MainLoop calls titledrawscreen, so this is only
          rem reached if called directly
          gosub DrawTitleScreen bank9

          return thisbank
TitleScreenComplete
          rem Transition to character select
          rem
          rem Input: None (called from TitleScreenMain)
          rem
          rem Output: gameMode set to ModeCharacterSelect,
          rem ChangeGameMode called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          rem Constraints: Must be colocated with TitleScreenMain
          let gameMode = ModeCharacterSelect
          gosub ChangeGameMode bank14
          return thisbank