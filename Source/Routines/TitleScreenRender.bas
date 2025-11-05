          rem ChaosFight - Source/Routines/TitleScreenRender.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem TITLE SCREEN RENDERING
          rem ==========================================================
          rem Renders the title screen using a 48×42 bitmap image.
          rem The bitmap data is generated from
          rem   Source/Art/ChaosFight.xcf
          rem by SkylineTool and included as
          rem   Source/Generated/Art.ChaosFight.s

          rem BITMAP CONFIGURATION:
          rem - Size: 48×42 pixels (displayed as 48×84 scanlines in
          rem   double-height mode)
          rem   - Uses titlescreen kernel minikernel for display
          rem - Color-per-line support (84 color values, 42 × 2 for
          rem   double-height)
          rem - Bitmap data stored in ROM:
          rem   Source/Generated/Art.ChaosFight.s

          rem AVAILABLE VARIABLES:
          rem   titleParadeActive - Whether to draw parade character
          rem   COLUBK - Background color
          rem   COLUPF - Playfield color
          rem ==========================================================

          rem Main draw routine for title screen
DrawTitleScreen
          rem Clear sprites first
          player0x = 0
          player0y = 0
          player1x = 0
          player1y = 0
          
          rem Load title screen bitmap data
          rem Inline LoadTitleBitmap (configure titlescreen kernel
          rem   bitmap)
          rem Configure titlescreen kernel to show Title (ChaosFight)
          rem   bitmap
          rem Uses 48x2_3 minikernel - set window/height via assembly
          rem   constants
          rem Bitmap data in: Source/Generated/Art.ChaosFight.s
          rem Other screens' minikernels should have window=0 in their
          rem   image files
          rem The titlescreen kernel uses fixed labels
          rem   (bmp_48x2_3_window, etc.)
          rem These are set as constants in the .s image files
          rem Title screen: bmp_48x2_3_window = 42, others = 0
          
          rem Draw character parade if active
          if titleParadeActive then gosub DrawParadeCharacter
          return

          rem ==========================================================
          rem LOAD TITLE BITMAP
          rem ==========================================================
          rem Loads the ChaosFight title bitmap data for titlescreen
          rem   kernel.
          rem Generated from Source/Art/ChaosFight.xcf → ChaosFight.png
          rem SkylineTool creates: Source/Generated/Art.ChaosFight.s
          rem   - BitmapChaosFight: 6 columns × 42 bytes (inverted-y)
          rem - BitmapChaosFightColors: 84 color values (double-height)

LoadTitleBitmap
          rem Configure titlescreen kernel to show Title (ChaosFight)
          rem   bitmap
          rem Uses 48x2_3 minikernel - set window/height via assembly
          rem   constants
              rem Bitmap data in: Source/Generated/Art.ChaosFight.s
          rem Other screens’ minikernels should have window=0 in their
          rem   image files
          
          rem The titlescreen kernel uses fixed labels
          rem   (bmp_48x2_3_window, etc.)
              rem These are set as constants in the .s image files
          rem Title screen: bmp_48x2_3_window = 42, others = 0
          
          return

