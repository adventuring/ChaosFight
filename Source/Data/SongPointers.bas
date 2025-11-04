          rem ChaosFight - Source/Data/SongPointers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem SONG POINTER DATA TABLES
          rem =================================================================
          rem Song pointer lookup tables (populated with symbol addresses)
          rem Format: data SongPointersL, SongPointersH tables (5 entries: indices 0-4)
          rem Songs: 0=AtariToday, 1=Interworldly, 2=Title, 3=GameOver, 4=Victory
          rem =================================================================
          
          data SongPointersL
          <Song_AtariToday_Voice0, <Song_Interworldly_Voice0, <Song_Title_Voice0, <Song_GameOver_Voice0, <Song_Victory_Voice0
          end
          data SongPointersH
          >Song_AtariToday_Voice0, >Song_Interworldly_Voice0, >Song_Title_Voice0, >Song_GameOver_Voice0, >Song_Victory_Voice0
          end
          
          rem Voice 1 stream pointer lookup tables (populated with symbol addresses)
          rem Format: data SongPointersSecondL, SongPointersSecondH tables (5 entries: indices 0-4)
          data SongPointersSecondL
          <Song_AtariToday_Voice1, <Song_Interworldly_Voice1, <Song_Title_Voice1, <Song_GameOver_Voice1, <Song_Victory_Voice1
          end
          data SongPointersSecondH
          >Song_AtariToday_Voice1, >Song_Interworldly_Voice1, >Song_Title_Voice1, >Song_GameOver_Voice1, >Song_Victory_Voice1
          end
