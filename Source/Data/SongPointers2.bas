          rem ChaosFight - Source/Data/SongPointers2.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Song Pointer Data Tables - Bank 2
          rem Compact pointer lookup tables for songs stored in Bank 15
          rem Format: data SongPointers2L, SongPointers2H (7 entries)
          rem Songs in Bank 15: IDs 0-Bank15MaxSongID (currently Bernie, OCascadia, Revontuli, EXO, Grizzards, MagicalFairyForce, Bolero)
          rem Index mapping: song ID maps directly (index = songID)

          data SongPointers2L
            <Song_Bernie_Voice0, <Song_OCascadia_Voice0, <Song_Revontuli_Voice0, <Song_EXO_Voice0, <Song_Grizzards_Voice0, <Song_MagicalFairyForce_Voice0, <Song_Bolero_Voice0
end
          data SongPointers2H
            >Song_Bernie_Voice0, >Song_OCascadia_Voice0, >Song_Revontuli_Voice0, >Song_EXO_Voice0, >Song_Grizzards_Voice0, >Song_MagicalFairyForce_Voice0, >Song_Bolero_Voice0
end

          rem Voice 1 stream pointer lookup tables for Bank 15
          data SongPointers2SecondL
            <Song_Bernie_Voice1, <Song_OCascadia_Voice1, <Song_Revontuli_Voice1, <Song_EXO_Voice1, <Song_Grizzards_Voice1, <Song_MagicalFairyForce_Voice1, <Song_Bolero_Voice1
end
          data SongPointers2SecondH
            >Song_Bernie_Voice1, >Song_OCascadia_Voice1, >Song_Revontuli_Voice1, >Song_EXO_Voice1, >Song_Grizzards_Voice1, >Song_MagicalFairyForce_Voice1, >Song_Bolero_Voice1
end


