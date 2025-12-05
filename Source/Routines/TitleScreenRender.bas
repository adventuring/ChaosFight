          rem ChaosFight - Source/Routines/TitleScreenRender.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

DrawTitleScreen
          rem Returns: Far (return otherbank)
          asm
DrawTitleScreen
end
          rem Title Screen Rendering (Publisher/Author/Title screens)
          rem Returns: Far (return otherbank)
          rem Render screens using 48×42 bitmaps via titlescreen kernel
          rem CRITICAL: Sets window values based on gameMode to show correct bitmaps
          rem Publisher (gameMode 0): AtariAge logo + AtariAge text (bmp_48x2_1, bmp_48x2_2)
          rem Author (gameMode 1): BRP signature (bmp_48x2_4)
          rem Title (gameMode 2): ChaosFight title (bmp_48x2_3)
          rem
          rem Input: gameMode (global 0-2) = which screen to render
          rem        titleParadeActive (global) = whether to draw parade character
          rem
          rem Output: Screen rendered with correct bitmaps, sprites cleared
          rem
          rem Mutates: player0x, player0y, player1x, player1y (cleared to 0)
          rem          titlescreenWindow1-4 (set based on gameMode)
          rem
          rem Called Routines: DrawParadeCharacter (bank14) - if titleParadeActive set
          rem
          rem Constraints: Must be called every frame for modes 0-2
          let player0x = 0
          let player0y = 0
          let player1x = 0
          let player1y = 0

          rem Set window values based on gameMode to show correct bitmaps
          rem CRITICAL: Window values must be set every frame (titlescreen kernel uses them)
          rem gameMode 0 = Publisher Prelude, 1 = Author Prelude, 2 = Title Screen
          if gameMode = 0 then goto DrawPublisherScreen

          if gameMode = 1 then goto DrawAuthorScreen

          rem Default: Title screen (gameMode = 2)
          goto DrawTitleScreenOnly

DrawPublisherScreen
          rem Publisher Prelude: Show AtariAge logo + AtariAge text
          let titlescreenWindow1 = 42  ; AtariAge logo visible
          let titlescreenWindow2 = 42  ; AtariAgeText visible
          let titlescreenWindow3 = 0   ; ChaosFight hidden
          let titlescreenWindow4 = 0   ; BRP hidden
          goto DrawTitleScreenCommon

DrawAuthorScreen
          rem Author Prelude: Show BRP signature only
          let titlescreenWindow1 = 0   ; AtariAge logo hidden
          let titlescreenWindow2 = 0   ; AtariAgeText hidden
          let titlescreenWindow3 = 0   ; ChaosFight hidden
          let titlescreenWindow4 = 42  ; BRP visible
          goto DrawTitleScreenCommon

DrawTitleScreenOnly
          rem Title Screen: Show ChaosFight title only
          let titlescreenWindow1 = 0   ; AtariAge logo hidden
          let titlescreenWindow2 = 0   ; AtariAgeText hidden
          let titlescreenWindow3 = 42  ; ChaosFight visible
          let titlescreenWindow4 = 0   ; BRP hidden
          goto DrawTitleScreenCommon

DrawTitleScreenCommon
          rem Draw character parade if active (Title screen only)
          if titleParadeActive then gosub DrawParadeCharacter bank14

          rem Call titlescreen kernel to render the bitmap(s)
          rem titledrawscreen is defined in Source/TitleScreen/asm/titlescreen.s
          rem Kernel uses titlescreenWindow1-4 runtime variables to select bitmaps
          asm
            jsr titledrawscreen
end
          return otherbank
          rem
          rem Load Title Bitmap
          rem Loads the ChaosFight title bitmap data for titlescreen
          rem   kernel.
          rem Generated from Source/Art/ChaosFight.xcf → ChaosFight.png
          rem SkylineTool creates: Source/Generated/Art.ChaosFight.s
          rem   - BitmapChaosFight: 6 columns × 42 bytes (inverted-y)
          rem - BitmapChaosFightColors: 84 color values (double-height)

LoadTitleBitmap
          rem Returns: Far (return otherbank)
          asm
LoadTitleBitmap
end
          return otherbank
          rem Configure titlescreen kernel to show Title (ChaosFight)
          rem Returns: Far (return otherbank)
          rem   bitmap
          rem Uses 48x2_3 minikernel - set window/height via assembly
          rem   constants
          rem Other screens’ minikernels should have window=0 in their
          rem Bitmap data in: Source/Generated/Art.ChaosFight.s
          rem   image files
