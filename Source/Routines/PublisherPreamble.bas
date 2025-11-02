          rem ChaosFight - Source/Routines/PublisherPreamble.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PUBLISHER PREAMBLE SCREEN
          rem =================================================================
          rem Displays the AtariAge publisher logo/artwork with music.
          rem This is the first screen shown at cold start.

          rem FLOW:
          rem   1. Display 48×42 bitmap from Source/Art/AtariAge.xcf (via titlescreen kernel)
          rem   2. Play "AtariToday" jingle
          rem   3. Wait for jingle completion + 0.5s OR button press
          rem   4. Transition to author preamble

          rem BITMAP CONFIGURATION:
          rem   - Size: 48×42 pixels (displayed as 48×84 scanlines in double-height mode)
          rem   - Uses titlescreen kernel minikernel for display
          rem   - Color-per-line support (84 color values, 42 × 2 for double-height)
          rem   - Bitmap data stored in ROM: Source/Generated/Art.AtariAge.s

          rem AVAILABLE VARIABLES:
          rem   preambleTimer - Frame counter for timing
          rem   musicPlaying - Music state flag
          rem   QuadtariDetected - For checking all controllers
          rem =================================================================

PublisherPreamble
          rem Load bitmap data for titlescreen kernel
          gosub LoadPublisherBitmap
          
          rem Check for button press on any controller to skip
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then goto PublisherPreambleComplete
          if joy1fire then goto PublisherPreambleComplete
          
          if controllerStatus & SetQuadtariDetected then goto PublisherCheckQuadtari

          goto PublisherSkipQuadtari

PublisherCheckQuadtari
          if !INPT0{7} then goto PublisherPreambleComplete
          if !INPT2{7} then goto PublisherPreambleComplete
PublisherSkipQuadtari
          gosub bank16 UpdateMusic

          rem Auto-advance after music completes + 0.5s
         if preambleTimer > 30 && musicPlaying = 0 then goto PublisherPreambleComplete

          preambleTimer = preambleTimer + 1
          
          rem Draw screen with titlescreen kernel minikernel
          gosub titledrawscreen bank1

          return

PublisherPreambleComplete
          gameMode = ModeAuthorPreamble : gosub bank13 ChangeGameMode
          return

          rem =================================================================
          rem LOAD PUBLISHER BITMAP
          rem =================================================================
          rem Loads the AtariAge publisher bitmap data for titlescreen kernel.
          rem Generated from Source/Art/AtariAge.xcf → AtariAge.png
          rem SkylineTool creates: Source/Generated/Art.AtariAge.s
          rem   - BitmapAtariAge: 6 columns × 42 bytes (inverted-y)
          rem   - BitmapAtariAgeColors: 84 color values (double-height)

LoadPublisherBitmap
          rem Configure titlescreen kernel to show Publisher (AtariAge) bitmap
          rem Uses 48x2_1 minikernel - set window/height via assembly constants
              rem Bitmap data in: Source/Generated/Art.AtariAge.s
          rem Other screens minikernels should have window=0 in their image files
          
          rem The titlescreen kernel uses fixed labels (bmp_48x2_1_window, etc.)
              rem These are set as constants in the .s image files
          rem Publisher screen: bmp_48x2_1_window = 42, others = 0
          
          return


