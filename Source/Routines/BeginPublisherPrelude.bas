          rem ChaosFight - Source/Routines/BeginPublisherPrelude.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem BEGIN PUBLISHER PRELUDE - SETUP ROUTINE
          rem ==========================================================
          rem Initializes state for Publisher Prelude screen (gameMode
          rem   0).
          rem Called from ChangeGameMode when transitioning to Publisher
          rem   Prelude.
          rem
          rem Sets up:
          rem   - Timer initialization
          rem   - Background color
          rem   - Music playback start
          rem
          rem Bitmap data is loaded automatically by titlescreen kernel
          rem   via includes.
          rem No explicit loading needed - titlescreen kernel handles
          rem   bitmap display.

BeginPublisherPrelude
          rem Initialize prelude timer
          let preambleTimer = 0
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Start AtariToday music
          temp1 = MusicAtariToday
          rem tail call
          goto StartMusic




