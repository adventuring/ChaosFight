          rem ChaosFight - Source/Routines/AuthorPrelude.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Displays the Interworldly author logo/artwork with music.
          rem Author Prelude Screen
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
          rem Per-frame author prelude display and input handling
          rem
          rem Input: joy0fire, joy1fire (hardware) = button states
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        INPT0-3 (hardware) = MegaDrive/Joy2b+ controller
          rem        button states
          rem        preambleTimer (global) = frame counter
          rem        musicPlaying (global) = music playback state
          rem
          rem Output: Dispatches to AuthorPreludeComplete or returns
          rem
          rem Mutates: preambleTimer (incremented)
          rem
          rem Called Routines: UpdateMusic (bank1) - accesses music
          rem state variables
          rem
          rem Constraints: Must be colocated with AuthorPreludeComplete
          rem              Called from MainLoop each frame (gameMode 1)
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes
          rem No explicit loading needed - titlescreen kernel handles
          rem   bitmap display

AuthorPrelude
          asm
AuthorPrelude

end
          rem Check for button press on any controller to skip
          rem Use skip-over pattern to avoid complex || operator issues
          if joy0fire then AuthorPreludeComplete
          if joy1fire then AuthorPreludeComplete

          rem Check MegaDrive/Joy2b+ controllers if detected
          rem Player 1: Genesis Button C (INPT0) or Joy2b+ Button C/II (INPT0) or Joy2b+ Button III (INPT1)
          rem OR flags together and check for nonzero match
          let temp1 = controllerStatus & (SetLeftPortGenesis | SetLeftPortJoy2bPlus)
          if temp1 then if !INPT0{7} then AuthorPreludeComplete
          let temp1 = controllerStatus & SetLeftPortJoy2bPlus
          if temp1 then if !INPT1{7} then AuthorPreludeComplete

          rem Player 2: Genesis Button C (INPT2) or Joy2b+ Button C/II (INPT2) or Joy2b+ Button III (INPT3)
          let temp1 = controllerStatus & (SetRightPortGenesis | SetRightPortJoy2bPlus)
          if temp1 then if !INPT2{7} then AuthorPreludeComplete
          let temp1 = controllerStatus & SetRightPortJoy2bPlus
          if temp1 then if !INPT3{7} then AuthorPreludeComplete

          gosub UpdateMusic bank1

          rem Auto-advance after music completes + 0.5s

          if preambleTimer > 30 && musicPlaying = 0 then AuthorPreludeComplete

          let preambleTimer = preambleTimer + 1

          return

AuthorPreludeComplete
          rem Transition to Title Screen mode
          rem
          rem Input: None (called from AuthorPrelude)
          rem
          rem Output: gameMode set to ModeTitle, ChangeGameMode called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          rem Constraints: Must be colocated with AuthorPrelude
          let gameMode = ModeTitle
          gosub ChangeGameMode bank14
          return

          rem
          rem Bitmap Loading
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

