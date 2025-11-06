          rem ChaosFight - Source/Routines/PublisherPrelude.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem PUBLISHER PRELUDE SCREEN - PER-FRAME LOOP
          rem ==========================================================
          rem Per-frame publisher prelude display and input handling.
          rem Called from MainLoop each frame (gameMode 0).
          rem
          rem Setup is handled by BeginPublisherPrelude in
          rem   ChangeGameMode.bas.
          rem This function processes one frame and returns.
          rem
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
          rem ==========================================================

PublisherPreludeMain
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes
          rem No explicit loading needed - titlescreen kernel handles
          rem   bitmap display
          
          rem Check for button press on any controller to skip
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then PublisherPreludeComplete
          if joy1fire then PublisherPreludeComplete
          
          rem Check Quadtari controllers if detected (inline to avoid label)
          if controllerStatus & SetQuadtariDetected then if !INPT0{7} then PublisherPreludeComplete
          if controllerStatus & SetQuadtariDetected then if !INPT2{7} then PublisherPreludeComplete
          
          rem Music update handled by MainLoop after per-frame logic
          
          rem Auto-advance after music completes + 0.5s
          if preambleTimer > 30 && musicPlaying = 0 then PublisherPreludeComplete

          let preambleTimer = preambleTimer + 1
          
          rem Set window values for Publisher screen (AtariAge logo +
          rem   AtariAge text)
          gosub bank12 SetPublisherWindowValues
          
          rem Drawing handled by MainLoop (titledrawscreen for admin
          rem   screens)
          return

PublisherPreludeComplete
          let gameMode = ModeAuthorPrelude
          gosub bank14 ChangeGameMode
          return

          rem ==========================================================
          rem BITMAP LOADING
          rem ==========================================================
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes.
          rem Generated from Source/Art/AtariAge.xcf → AtariAge.png
          rem SkylineTool creates: Source/Generated/Art.AtariAge.s
          rem   - BitmapAtariAge: 6 columns × 42 bytes (inverted-y)
          rem   - BitmapAtariAgeColors: 84 color values (double-height)
          rem The titlescreen kernel handles bitmap display
          rem   automatically - no explicit loading needed.


