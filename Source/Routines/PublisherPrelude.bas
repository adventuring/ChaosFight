          rem ChaosFight - Source/Routines/PublisherPrelude.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem Publisher Prelude Screen - Per-frame Loop
          rem Per-frame publisher prelude display and input handling.
          rem Called from MainLoop each frame (gameMode 0).
          rem Setup is handled by BeginPublisherPrelude in
          rem   ChangeGameMode.bas.
          rem This function processes one frame and returns.
          rem FLOW PER FRAME (OVerscan only - minimal work):
          rem 1. Handle input - any button press skips to author prelude
          rem 2. Check auto-advance timer (music completion + 0.5s)
          rem 3. Increment timer
          rem 4. Return to MainLoop (music and drawing handled by MainLoop)
          rem BITMAP CONFIGURATION:
          rem - Size: 48×42 pixels (displayed as 48×84 scanlines in
          rem   double-height mode)
          rem   - Uses titlescreen kernel minikernel for display
          rem - Color-per-line support (84 color values, 42 × 2 for
          rem   double-height)
          rem - Bitmap data stored in ROM:
          rem   Source/Generated/Art.AtariAge.s
          rem AVAILABLE VARIABLES:
          rem   preambleTimer - Frame counter for timing
          rem   musicPlaying - Music state flag
          rem   QuadtariDetected - For checking all controllers
          rem Per-frame publisher prelude display and input handling
          rem
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        INPT0-3 (hardware) = MegaDrive/Joy2b+ controller
          rem        button states
          rem        preambleTimer (global) = frame counter
          rem        musicPlaying (global) = music playback state
          rem
          rem Output: Dispatches to PublisherPreludeComplete or returns
          rem
          rem Mutates: preambleTimer (incremented)
          rem
          rem Called Routines: None (music handled by MainLoop, window values set in BeginPublisherPrelude)
          rem
          rem Constraints: Must be colocated with
          rem PublisherPreludeComplete
          rem              Called from MainLoop each frame (gameMode 0)
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes
          rem No explicit loading needed - titlescreen kernel handles
          rem   bitmap display

PublisherPreludeMain
          rem Returns: Far (return otherbank)
          asm
PublisherPreludeMain
end
          rem Check for button press on any controller to skip
          if joy0fire then goto PublisherPreludeComplete

          if joy1fire then goto PublisherPreludeComplete

          rem Check MegaDrive/Joy2b+ controllers if detected
          rem Player 1: Genesis Button C (INPT0) or Joy2b+ Button C/II (INPT0) or Joy2b+ Button III (INPT1)
          rem OR flags together and check for nonzero match
          let temp1 = controllerStatus & (SetLeftPortGenesis | SetLeftPortJoy2bPlus)
          if temp1 then if !INPT0{7} then goto PublisherPreludeComplete

          let temp1 = controllerStatus & SetLeftPortJoy2bPlus
          if temp1 then if !INPT1{7} then goto PublisherPreludeComplete

          rem Player 2: Genesis Button C (INPT2) or Joy2b+ Button C/II (INPT2) or Joy2b+ Button III (INPT3)
          let temp1 = controllerStatus & (SetRightPortGenesis | SetRightPortJoy2bPlus)
          if temp1 then if !INPT2{7} then goto PublisherPreludeComplete

          let temp1 = controllerStatus & SetRightPortJoy2bPlus
          if temp1 then if !INPT3{7} then goto PublisherPreludeComplete

          rem Auto-advance after music completes + 0.5s
          rem Long branch - use goto (generates JMP) instead of if-then (generates branch)
          if preambleTimer > 30 && musicPlaying = 0 then goto PublisherPreludeComplete

          let preambleTimer = preambleTimer + 1

          rem Music and drawing handled by MainLoop (PlayMusic and DrawTitleScreen)
          return otherbank

PublisherPreludeComplete
          rem Transition to Author Prelude mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: None (called from PublisherPreludeMain)
          rem
          rem Output: gameMode set to ModeAuthorPrelude, ChangeGameMode
          rem called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          rem Constraints: Must be colocated with PublisherPreludeMain
          let gameMode = ModeAuthorPrelude
          gosub ChangeGameMode bank14

          return otherbank
          rem
          rem Bitmap Loading
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes.
          rem Generated from Source/Art/AtariAge.xcf → AtariAge.png
          rem SkylineTool creates: Source/Generated/Art.AtariAge.s
          rem   - BitmapAtariAge: 6 columns × 42 bytes (inverted-y)
          rem   - BitmapAtariAgeColors: 84 color values (double-height)
          rem The titlescreen kernel handles bitmap display
          rem   automatically - no explicit loading needed.
