PublisherPreludeMain
          rem
          rem ChaosFight - Source/Routines/PublisherPrelude.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Publisher Prelude Screen - Per-frame Loop
          rem
          rem Per-frame publisher prelude display and input handling.
          rem Called from MainLoop each frame (gameMode 0).
          rem
          rem Setup is handled by BeginPublisherPrelude in
          rem   ChangeGameMode.bas.
          rem This function processes one frame and returns.
          rem FLOW PER FRAME:
          rem 1. Handle input - any button press skips to author
          rem   prelude
          rem   2. Update music playback
          rem   3. Check auto-advance timer (music completion + 0.5s)
          rem   4. Set window values for Publisher screen
          rem   5. Return to MainLoop (drawing handled by MainLoop)
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
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        controllerStatus (global) = controller detection state
          rem        INPT0, INPT2 (hardware) = Quadtari controller states
          rem        preambleTimer (global) = frame counter
          rem        musicPlaying (global) = music playback state
          rem Output: Dispatches to PublisherPreludeComplete or returns
          rem Mutates: preambleTimer (incremented)
          rem Called Routines: SetPublisherWindowValues (bank12) - accesses window state
          rem Constraints: Must be colocated with PublisherPreludeComplete
          rem              Called from MainLoop each frame (gameMode 0)
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes
          rem No explicit loading needed - titlescreen kernel handles
          rem   bitmap display
          
          rem Check for button press on any controller to skip
          if joy0fire then PublisherPreludeComplete : rem Use skip-over pattern to avoid complex || operator issues
          if joy1fire then PublisherPreludeComplete
          
          if controllerStatus & SetQuadtariDetected then if !INPT0{7} then PublisherPreludeComplete : rem Check Quadtari controllers if detected (inline to avoid label)
          if controllerStatus & SetQuadtariDetected then if !INPT2{7} then PublisherPreludeComplete
          
          rem Music update handled by MainLoop after per-frame logic
          
          if preambleTimer > 30 && musicPlaying = 0 then PublisherPreludeComplete : rem Auto-advance after music completes + 0.5s

          let preambleTimer = preambleTimer + 1
          
          rem Set window values for Publisher screen (AtariAge logo +
          gosub SetPublisherWindowValues bank12 : rem   AtariAge text)
          
          rem Drawing handled by MainLoop (titledrawscreen for admin
          rem   screens)
          return

PublisherPreludeComplete
          rem Transition to Author Prelude mode
          rem Input: None (called from PublisherPreludeMain)
          rem Output: gameMode set to ModeAuthorPrelude, ChangeGameMode called
          rem Mutates: gameMode (global)
          rem Called Routines: ChangeGameMode (bank14) - accesses game mode state
          let gameMode = ModeAuthorPrelude : rem Constraints: Must be colocated with PublisherPreludeMain
          gosub ChangeGameMode bank14
          return

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


