          rem ChaosFight - Source/Routines/AuthorPreamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem AUTHOR PREAMBLE SCREEN
          rem =================================================================
          rem Displays the Interworldly author logo/artwork with music.
          rem This is the second screen shown at cold start.

          rem FLOW:
          rem   1. Display 48×42 bitmap from Source/Art/Interworldly.xcf (via titlescreen kernel)
          rem   2. Play "Interworldly" music
          rem   3. Wait for music completion + 0.5s OR button press
          rem   4. Transition to title screen

          rem BITMAP CONFIGURATION:
          rem   - Size: 48×42 pixels (displayed as 48×84 scanlines in double-height mode)
          rem   - Uses titlescreen kernel minikernel for display
          rem   - Color-per-line support (84 color values, 42 × 2 for double-height)
          rem   - Bitmap data stored in ROM: Source/Generated/Art.Interworldly.s

          rem AVAILABLE VARIABLES:
          rem   preambleTimer - Frame counter for timing
          rem   musicPlaying - Music state flag
          rem   QuadtariDetected - For checking all controllers
          rem =================================================================

          rem =================================================================
          rem AUTHOR PREAMBLE LOOP - Called from MainLoop each frame
          rem =================================================================
          rem This is the main loop that runs each frame during Author Preamble mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginAuthorPrelude (called from ChangeGameMode).

AuthorPreamble
          rem Load bitmap data for titlescreen kernel
          gosub LoadAuthorBitmap
          
          rem Check for button press on any controller to skip
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then goto AuthorPreambleComplete
          if joy1fire then goto AuthorPreambleComplete
          if controllerStatus & SetQuadtariDetected then goto AuthorCheckQuadtari
          goto AuthorSkipQuadtari
AuthorCheckQuadtari
          if !INPT0{7} then goto AuthorPreambleComplete
          if !INPT2{7} then goto AuthorPreambleComplete
AuthorSkipQuadtari
          
          rem Update music
          gosub bank16 UpdateMusic
          
          rem Auto-advance after music completes + 0.5s
          if preambleTimer > 30 && ! musicPlaying then goto AuthorPreambleComplete
          
          rem Increment timer
          let preambleTimer = preambleTimer + 1
          
          rem Draw screen with titlescreen kernel minikernel
          gosub titledrawscreen bank1
          
          rem Return to MainLoop for next frame
          return

AuthorPreambleComplete
          let gameMode = ModeTitle : gosub bank13 ChangeGameMode
          return

          rem =================================================================
          rem LOAD AUTHOR BITMAP
          rem =================================================================
          rem Loads the Interworldly author bitmap data for titlescreen kernel.
          rem Generated from Source/Art/Interworldly.xcf → Interworldly.png
          rem SkylineTool creates: Source/Generated/Art.Interworldly.s
          rem   - BitmapInterworldly: 6 columns × 42 bytes (inverted-y)
          rem   - BitmapInterworldlyColors: 84 color values (double-height)

LoadAuthorBitmap
          rem Configure titlescreen kernel to show Author (Interworldly) bitmap
          rem Uses 48x2_2 minikernel - set window/height via assembly constants
              rem Bitmap data in: Source/Generated/Art.Interworldly.s
          rem Other screens minikernels should have window=0 in their image files
          
          rem The titlescreen kernel uses fixed labels (bmp_48x2_2_window, etc.)
              rem These are set as constants in the .s image files
          rem Author screen: bmp_48x2_2_window = 42, others = 0
          
          return

