          rem
          rem ChaosFight - Source/Data/SongPointers2.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Song Pointer Data Tables - Bank 15
          rem Compact pointer lookup tables for songs stored in Bank 15
          rem Format: data SongPointers2L, SongPointers2H (4 entries)
          rem Songs in Bank 15: Bernie (0), OCascadia (1), Revontuli (2), EXO (3)
          rem Index mapping: song ID maps directly (index = songID)
          
          data SongPointers2L
            <Song_Bernie_Voice0, <Song_OCascadia_Voice0, <Song_Revontuli_Voice0, <Song_EXO_Voice0
end
          data SongPointers2H
            >Song_Bernie_Voice0, >Song_OCascadia_Voice0, >Song_Revontuli_Voice0, >Song_EXO_Voice0
end
          
          rem Voice 1 stream pointer lookup tables for Bank 15
          data SongPointers2SecondL
            <Song_Bernie_Voice1, <Song_OCascadia_Voice1, <Song_Revontuli_Voice1, <Song_EXO_Voice1
end
          data SongPointers2SecondH
            >Song_Bernie_Voice1, >Song_OCascadia_Voice1, >Song_Revontuli_Voice1, >Song_EXO_Voice1
end


