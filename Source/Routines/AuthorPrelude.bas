          rem ChaosFight - Source/Routines/AuthorPrelude.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem AUTHOR PRELUDE SCREEN
          rem ==========================================================
          rem Displays the Interworldly author logo/artwork with music.
          rem This is the second screen shown at cold start.

          rem FLOW:
          rem 1. Display 48×42 bitmap from Source/Art/Interworldly.xcf
          rem   (via titlescreen kernel)
          rem   2. Play Interworldly music
          rem   3. Wait for music completion + 0.5s OR button press
          rem   4. Transition to title screen

          rem BITMAP CONFIGURATION:
          rem - Size: 48×42 pixels (displayed as 48×84 scanlines in
          rem   double-height mode)
          rem   - Uses titlescreen kernel minikernel for display
          rem - Color-per-line support (84 color values, 42 × 2 for
          rem   double-height)
          rem - Bitmap data stored in ROM:
          rem   Source/Generated/Art.Interworldly.s

          rem AVAILABLE VARIABLES:
          rem   preambleTimer - Frame counter for timing
          rem   musicPlaying - Music state flag
          rem   QuadtariDetected - For checking all controllers
          rem ==========================================================

AuthorPrelude
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes
          rem No explicit loading needed - titlescreen kernel handles
          rem   bitmap display
          
          rem Check for button press on any controller to skip
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then AuthorPreludeComplete
          if joy1fire then AuthorPreludeComplete
          
          rem Check Quadtari controllers if detected
          if controllerStatus & SetQuadtariDetected then
            if !INPT0{7} then AuthorPreludeComplete
            if !INPT2{7} then AuthorPreludeComplete
          endif
          
          gosub bank16 UpdateMusic

          rem Auto-advance after music completes + 0.5s
          if preambleTimer > 30 && musicPlaying = 0 then AuthorPreludeComplete

          let preambleTimer = preambleTimer + 1

          return

AuthorPreludeComplete
          let gameMode = ModeTitle
          gosub bank14 ChangeGameMode
          return

          rem ==========================================================
          rem BITMAP LOADING
          rem ==========================================================
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes.
          rem Generated from Source/Art/Interworldly.xcf →
          rem   Interworldly.png
          rem SkylineTool creates: Source/Generated/Art.Interworldly.s
          rem   - BitmapInterworldly: 6 columns × 42 bytes (inverted-y)
          rem - BitmapInterworldlyColors: 84 color values
          rem   (double-height)
          rem The titlescreen kernel handles bitmap display
          rem   automatically - no explicit loading needed.

