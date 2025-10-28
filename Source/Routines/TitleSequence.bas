          rem ChaosFight - Source/Routines/TitleSequence.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Cold start, preamble screens, and title screen with music

          rem =================================================================
          rem COLD START / PREAMBLE SEQUENCE
          rem =================================================================
          rem Display: Publisher Preamble -> Author Preamble -> Title Screen
          rem Each preamble plays a jingle and waits for completion + 0.5s or button press
          rem Title screen loops music until button press

ColdStartSequence
          rem Detect controllers at startup
          gosub DetectControllers
          
          rem Display Publisher Preamble (Atari Today jingle)
          gosub ShowPublisherPreamble
          
          rem Display Author Preamble (Interworldly jingle)
          gosub ShowAuthorPreamble
          
          rem Display Title Screen (Chaotica music loops)
          gosub ShowTitleScreen
          
          rem Re-detect controllers before game starts
          gosub DetectControllers
          
          return

rem =================================================================
rem HELPER SUBROUTINES
rem =================================================================

LoadPublisherLogo
          rem Load publisher logo from generated playfield data
          gosub LoadPublisherPlayfield
          return

StartMusic
          rem Initialize music system for title song
          temp1 = MusicTitle
          gosub StartMusic
          return

          rem =================================================================
          rem PUBLISHER PREAMBLE SCREEN
          rem =================================================================
          rem Show Atari Today logo with jingle
          rem Wait for jingle + 0.5s or button press

ShowPublisherPreamble
          rem Set playfield resolution for preamble (high resolution)
          pfres = 12
          
          rem Clear screen
          pfclear
          
          rem Draw publisher logo using playfield
          rem Load from generated playfield data
          gosub LoadPublisherLogo
          
          rem Start Atari Today music
          rem Initialize music system
          MusicPlaying = 1
          CurrentSong = 0
          gosub StartMusic
          
          rem Wait for music completion + 0.5s or button press
          rem Music duration ~2 seconds = 120 frames
          temp1 = 0
          
PublisherPreambleLoop
          drawscreen
          temp1 = temp1 + 1
          
          rem Check for button press on any controller
          if joy0fire || joy1fire then goto ExitPublisherPreamble
          if QuadtariDetected && (joy2fire || joy3fire) then goto ExitPublisherPreamble
          
          rem Wait for music + 30 frames (0.5s)
          if temp1 < 150 then goto PublisherPreambleLoop
          
ExitPublisherPreamble
          rem Stop music
          MusicPlaying = 0
          AUDV0 = 0
          AUDV1 = 0
          return

rem =================================================================
rem HELPER SUBROUTINES
rem =================================================================

LoadPublisherLogo
          rem Load publisher logo from generated playfield data
          gosub LoadPublisherPlayfield
          return

StartMusic
          rem Initialize music system for title song
          temp1 = MusicTitle
          gosub StartMusic
          return

          rem =================================================================
          rem AUTHOR PREAMBLE SCREEN
          rem =================================================================
          rem Show Interworldly logo with jingle
          rem Wait for jingle + 0.5s or button press

ShowAuthorPreamble
          rem Set playfield resolution for preamble
          pfres = 12
          
          rem Clear screen
          pfclear
          
          rem Draw author logo
          rem Load character art from generated sprite data
          pfpixel 45 20 on
          pfpixel 46 20 on
          pfpixel 47 20 on
          pfpixel 45 21 on
          pfpixel 47 21 on
          pfpixel 45 22 on
          pfpixel 46 22 on
          pfpixel 47 22 on
          
          rem Start Interworldly music
          MusicPlaying = 1
          CurrentSong = 1
          
          rem Wait for music + 0.5s or button press
          temp1 = 0
          
AuthorPreambleLoop
          drawscreen
          temp1 = temp1 + 1
          
          rem Check for button press
          if joy0fire || joy1fire then goto ExitAuthorPreamble
          if QuadtariDetected && (joy2fire || joy3fire) then goto ExitAuthorPreamble
          
          if temp1 < 150 then goto AuthorPreambleLoop
          
ExitAuthorPreamble
          MusicPlaying = 0
          AUDV0 = 0
          AUDV1 = 0
          return

rem =================================================================
rem HELPER SUBROUTINES
rem =================================================================

LoadPublisherLogo
          rem Load publisher logo from generated playfield data
          gosub LoadPublisherPlayfield
          return

StartMusic
          rem Initialize music system for title song
          temp1 = MusicTitle
          gosub StartMusic
          return

          rem =================================================================
          rem TITLE SCREEN
          rem =================================================================
          rem Show game title with looping Chaotica music
          rem Wait for button press, then re-detect controllers

ShowTitleScreen
          rem Set playfield resolution for title
          pfres = 12
          
          rem Clear screen
          pfclear
          
          rem Draw title
          rem Load title art from generated playfield data
          pfpixel 50 15 on
          pfpixel 51 15 on
          pfpixel 52 15 on
          
          rem Start Chaotica music (loops)
          MusicPlaying = 1
          CurrentSong = 2
          
          rem Initialize character parade timer
          TitleTimer = 0
          ParadeActive = 0
          ParadeCharacter = 0
          ParadeX = 0
          ParadeDelay = 0
          
TitleScreenLoop
          drawscreen
          TitleTimer = TitleTimer + 1
          
          rem Start character parade after 10 seconds (600 frames)
          if TitleTimer > 600 && !ParadeActive then
            ParadeActive = 1
            ParadeDelay = 0
          endif
          
          rem Handle character parade
          if ParadeActive then
            gosub HandleCharacterParade
          endif
          
          rem Check for button press on any controller
          if joy0fire || joy1fire then goto ExitTitleScreen
          if QuadtariDetected && (joy2fire || joy3fire) then goto ExitTitleScreen
          
          goto TitleScreenLoop
          
ExitTitleScreen
          rem Stop music
          MusicPlaying = 0
          AUDV0 = 0
          AUDV1 = 0
          
          rem Re-detect controllers before starting game
          gosub DetectControllers
          
          return

rem =================================================================
rem HELPER SUBROUTINES
rem =================================================================

LoadPublisherLogo
          rem Load publisher logo from generated playfield data
          gosub LoadPublisherPlayfield
          return

StartMusic
          rem Initialize music system for title song
          temp1 = MusicTitle
          gosub StartMusic
          return

          rem =================================================================
          rem CHARACTER PARADE ON TITLE SCREEN
          rem =================================================================
          rem Characters run across bottom of screen, left to right
          rem 1 second pause after each character leaves

HandleCharacterParade
          rem Check if in delay between characters
          if ParadeDelay > 0 then
            ParadeDelay = ParadeDelay - 1
            return

rem =================================================================
rem HELPER SUBROUTINES
rem =================================================================

LoadPublisherLogo
          rem Load publisher logo from generated playfield data
          gosub LoadPublisherPlayfield
          return

StartMusic
          rem Initialize music system for title song
          temp1 = MusicTitle
          gosub StartMusic
          return
          endif
          
          rem Move character across screen
          if ParadeX < 160 then
            ParadeX = ParadeX + 2
            
            rem Display character at bottom of screen
            rem Use missile0 for simple display
            missile0x = ParadeX
            missile0y = 75
            ENAM0 = 1
            
            return

rem =================================================================
rem HELPER SUBROUTINES
rem =================================================================

LoadPublisherLogo
          rem Load publisher logo from generated playfield data
          gosub LoadPublisherPlayfield
          return

StartMusic
          rem Initialize music system for title song
          temp1 = MusicTitle
          gosub StartMusic
          return
          endif
          
          rem Character has left screen, start delay
          ParadeDelay = 60  : rem 1 second pause
          ENAM0 = 0
          
          rem Select next random character
          rem Use frame counter for randomness
          ParadeCharacter = (rand & 15)
          
          rem Reset position for next character
          ParadeX = 0
          
          return

