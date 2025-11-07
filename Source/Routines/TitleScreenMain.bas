TitleScreenMain
          rem
          rem ChaosFight - Source/Routines/TitleScreenMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Title Screen - Per-frame Loop
          rem
          rem Per-frame title screen display and input handling.
          rem Called from MainLoop each frame (gameMode 2).
          rem Dispatches to other modules for character parade and
          rem   rendering.
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
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: UpdateCharacterParade (bank9) - accesses
          rem parade state,
          rem   DrawTitleScreen (bank9) - accesses title screen state,
          rem   titledrawscreen (bank9) - accesses title screen graphics
          rem
          rem Constraints: Must be colocated with TitleSkipQuad,
          rem TitleScreenComplete
          rem              Called from MainLoop each frame (gameMode 2)
          rem Handle input - any button press goes to character select
          rem Check standard controllers (Player 1 & 2)
          if joy0fire then TitleScreenComplete : rem Use skip-over pattern to avoid complex || operator issues
          if joy1fire then TitleScreenComplete
          
          if 0 = (controllerStatus & SetQuadtariDetected) then TitleSkipQuad : rem Check Quadtari controllers (Players 3 & 4 if active)
          if !INPT0{7} then TitleScreenComplete
          if !INPT2{7} then TitleScreenComplete
TitleSkipQuad
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
          
          gosub UpdateCharacterParade bank9 : rem Update character parade animation
          
          gosub DrawTitleScreen bank9 : rem Draw title screen
          
          rem Draw screen with titlescreen kernel minikernel
          rem (titlescreen graphics in Bank 9)
          rem Note: MainLoop calls titledrawscreen, so this is only
          rem reached if called directly
          gosub titledrawscreen bank9
          
          return

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
          let gameMode = ModeCharacterSelect : rem Constraints: Must be colocated with TitleScreenMain
          gosub ChangeGameMode bank14
          return
