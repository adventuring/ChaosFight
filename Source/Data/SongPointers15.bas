          rem ChaosFight - Source/Data/SongPointers15.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem SONG POINTER DATA TABLES - BANK 15
          rem ==========================================================
          rem Song pointer lookup tables for songs stored in Bank 15
          rem Format: data SongPointersL15, SongPointersH15 tables (29
          rem   entries: indices 0-28)
          rem Songs in Bank 15: OCascadia (1), Revontuli (2)
          rem All other songs (0, 3-28) have pointer = 0 (not in this bank)
          rem ==========================================================
          
          data SongPointersL15
            0, <Song_OCascadia_Voice0, <Song_Revontuli_Voice0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0
end
          data SongPointersH15
            0, >Song_OCascadia_Voice0, >Song_Revontuli_Voice0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0
end
          
          rem Voice 1 stream pointer lookup tables for Bank 15
          data SongPointersSecondL15
            0, <Song_OCascadia_Voice1, <Song_Revontuli_Voice1, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0
end
          data SongPointersSecondH15
            0, >Song_OCascadia_Voice1, >Song_Revontuli_Voice1, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0
end

