          rem ChaosFight - Source/Routines/TitleScreenRender.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

DrawTitleScreen
          asm
DrawTitleScreen
end
          rem Title Screen Rendering
          rem Render the title screen using a 48×42 bitmap generated from Source/Art/ChaosFight.xcf
          rem and included as Source/Generated/Art.ChaosFight.s
          rem BITMAP CONFIGURATION:
          rem - Size: 48×42 pixels (displayed as 48×84 scanlines in double-height mode)
          rem   - Uses titlescreen kernel minikernel for display
          rem - Color-per-line support (84 color values, 42 × 2 for
          rem   double-height)
          rem - Bitmap data stored in ROM: Source/Generated/Art.ChaosFight.s
          rem AVAILABLE VARIABLES:
          rem   titleParadeActive - Whether to draw parade character
          rem   COLUBK - Background color
          rem   COLUPF - Playfield color
          rem Main draw routine for title screen
          rem Clear sprites first
          rem
          rem Input: titleParadeActive (global) = whether to draw parade
          rem
          rem Output: Title screen rendered, sprites cleared
          rem
          rem Mutates: player0x, player0y, player1x, player1y (cleared
          rem to 0)
          rem
          rem Called Routines: DrawParadeCharacter (bank14) - if
          rem titleParadeActive set
          rem
          rem Constraints: None
          player0x = 0
          player0y = 0
          player1x = 0
          player1y = 0

          rem Bitmap configured at compile-time (bmp_48x2_3_window = 42)

          rem Draw character parade if active
          if titleParadeActive then gosub DrawParadeCharacter bank14

          rem Call titlescreen kernel to render the bitmap
          asm
            jsr titledrawscreen
end

          return


