          rem ChaosFight - Source/Data/SongPointers15.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Song Pointer Data Tables - Bank 15
          rem
          rem Compact pointer lookup tables for songs stored in Bank 15
          rem Format: data SongPointersL15, SongPointersH15 (2 entries)
          rem Songs in Bank 15: OCascadia (1), Revontuli (2)
          rem Index 0 = OCascadia (song ID 1), Index 1 = Revontuli (song ID 2)
          rem Use: index = songID - 1 (for songs 1-2)
          rem ==========================================================
          
          data SongPointersL15
            <Song_OCascadia_Voice0, <Song_Revontuli_Voice0
end
          data SongPointersH15
            >Song_OCascadia_Voice0, >Song_Revontuli_Voice0
end
          
          rem Voice 1 stream pointer lookup tables for Bank 15
          data SongPointersSecondL15
            <Song_OCascadia_Voice1, <Song_Revontuli_Voice1
end
          data SongPointersSecondH15
            >Song_OCascadia_Voice1, >Song_Revontuli_Voice1
end


