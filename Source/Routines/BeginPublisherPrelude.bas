          rem ChaosFight - Source/Routines/BeginPublisherPrelude.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem BEGIN PUBLISHER PRELUDE - SETUP ROUTINE
          rem =================================================================
          rem Initializes state for Publisher Preamble screen (gameMode 0).
          rem Called from ChangeGameMode when transitioning to Publisher Preamble.
          rem
          rem Sets up:
          rem   - Timer initialization
          rem   - Background color
          rem   - Music playback start
          rem
          rem Bitmap data is loaded automatically by titlescreen kernel via includes.
          rem No explicit loading needed - titlescreen kernel handles bitmap display.

BeginPublisherPrelude
          rem Initialize preamble timer
          let preambleTimer = 0
          
          rem Set background color
          COLUBK = ColGray(0)
          
          rem Start "AtariToday" music
          temp1 = MusicAtariToday
          rem tail call
          goto StartMusic




