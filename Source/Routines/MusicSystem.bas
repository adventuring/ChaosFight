          rem ChaosFight - Source/Routines/MusicSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem MUSIC SYSTEM
          rem =================================================================
          rem NOTE: This implementation is FUBAR and needs to be rebuilt from
          rem      scratch based on requirements in GitHub issues (#162, #243, #306).
          rem      Requirements:
          rem      - Music must come from assets, not hard-coded in sources
          rem      - Music is polyphony 2, sound effects polyphony 1
          rem      - Sound effects use first-come, first-served voices
          rem      - Music and sound effects must properly share TIA audio channels
          rem
          rem Provides music playback using TIA audio channels
          rem Maps one "channel" to 2 voices (AUDC0 + AUDC1)
          rem No backlog/queue - lower priority sounds not considered
          rem Uses AUDC0 for melody, AUDC1 for harmony/rhythm

          rem =================================================================
          rem MUSIC CONSTANTS
          rem =================================================================
          rem Constants defined in Source/Common/Constants.bas

          rem =================================================================
          rem MUSIC STATE VARIABLES
          rem =================================================================
          rem MusicPlaying - Current music track (0 = none, 1-4 = track)
          rem MusicPosition - Current position in track (0-255)
          rem MusicTimer - Frame counter for timing
          rem MusicChannel0 - AUDC0 data for melody
          rem MusicChannel1 - AUDC1 data for harmony

          rem =================================================================
          rem MUSIC DATA TABLES
          rem =================================================================
          rem Title screen music (Chaotica)
          data TitleMusicChannel0
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
end

          data TitleMusicChannel1
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
          $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A, $08, $06, $04, $02, $00, $0C, $0A
end

          rem Interworldly music (author preamble)
          data InterworldlyMusicChannel0
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
end

          data InterworldlyMusicChannel1
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
end

          rem AtariToday music (publisher preamble)
          data AtariTodayMusicChannel0
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
          $0E, $0C, $0A, $08, $06, $04, $02, $00, $0E, $0C, $0A, $08, $06, $04, $02, $00
end

          data AtariTodayMusicChannel1
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
          $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04, $02, $00, $0A, $08, $06, $04
end

          rem =================================================================
          rem MUSIC PLAYBACK FUNCTIONS
          rem =================================================================

          rem Start playing a music track
          rem Input: temp1 = music track (0-4)
StartMusic
          if temp1 = 0 then return 
          rem No music
          
          MusicPlaying = temp1
          MusicPosition = 0
          MusicTimer = 0
          
          return

          rem Update music playback (call each frame)
UpdateMusic
          if MusicPlaying = 0 then return
          
          rem Update timer
          MusicTimer = MusicTimer + 1
          
          rem Update every 4 frames (15Hz)
          if MusicTimer < 4 then return
          MusicTimer = 0
          
          rem Get current music data
          if MusicPlaying = MusicTitle then gosub UpdateTitleMusic
          if MusicPlaying = MusicInterworldly then gosub UpdateInterworldlyMusic
          if MusicPlaying = MusicAtariToday then gosub UpdateAtariTodayMusic
          if MusicPlaying = MusicVictory then gosub UpdateVictoryMusic
          if MusicPlaying = MusicGameOver then gosub UpdateGameOverMusic
          
          rem Advance position
          MusicPosition = MusicPosition + 1
          
          rem Check for end of track
          if MusicPosition < 128 then return
          MusicPlaying = 0
          MusicPosition = 0
          
          return

          rem Stop music
StopMusic
          MusicPlaying = 0
          MusicPosition = 0
          MusicTimer = 0
          AUDC0 = 0
          AUDF0 = 0
          AUDV0 = 0
          return

          rem =================================================================
          rem TRACK-SPECIFIC UPDATE FUNCTIONS
          rem =================================================================

          rem Update title music
UpdateTitleMusic
          temp2 = TitleMusicChannel0[MusicPosition]
          temp3 = TitleMusicChannel1[MusicPosition]
          
          AUDC0 = temp2
          AUDF0 = temp2
          AUDV0 = 6
          
          AUDC1 = temp3
          AUDF1 = temp3
          AUDV1 = 4
          
          return

          rem Update Interworldly music
UpdateInterworldlyMusic
          temp2 = InterworldlyMusicChannel0[MusicPosition]
          temp3 = InterworldlyMusicChannel1[MusicPosition]
          
          AUDC0 = temp2
          AUDF0 = temp2
          AUDV0 = 5
          
          AUDC1 = temp3
          AUDF1 = temp3
          AUDV1 = 3
          
          return

          rem Update AtariToday music
UpdateAtariTodayMusic
          temp2 = AtariTodayMusicChannel0[MusicPosition]
          temp3 = AtariTodayMusicChannel1[MusicPosition]
          
          AUDC0 = temp2
          AUDF0 = temp2
          AUDV0 = 4
          
          AUDC1 = temp3
          AUDF1 = temp3
          AUDV1 = 2
          
          return

          rem Update victory music
UpdateVictoryMusic
          rem Simple victory fanfare
          temp2 = 15 - (MusicPosition & 15)
          temp3 = 7 - (MusicPosition & 7)
          
          AUDC0 = temp2
          AUDF0 = temp2
          AUDV0 = 7
          
          AUDC1 = temp3
          AUDF1 = temp3
          AUDV1 = 5
          
          return

          rem Update game over music
UpdateGameOverMusic
          rem Simple game over theme
          temp2 = MusicPosition & 15
          temp3 = (MusicPosition & 7) + 8
          
          AUDC0 = temp2
          AUDF0 = temp2
          AUDV0 = 4
          
          AUDC1 = temp3
          AUDF1 = temp3
          AUDV1 = 3
          
          return
