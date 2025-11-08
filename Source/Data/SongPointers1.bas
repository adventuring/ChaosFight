          rem
          rem ChaosFight - Source/Data/SongPointers1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Song Pointer Data Tables - Bank 1
          rem Compact pointer lookup tables for songs stored in Bank 1
          rem Format: data SongPointers1L, SongPointers1H (25 entries)
          rem Songs in Bank 1: Song IDs 4-28 (character themes plus admin music)
          rem Index mapping: song 4 → index 0, song N → index (N - 4)
          
          data SongPointers1L
            <Song_Grizzards_Voice0, <Song_MagicalFairyForce_Voice0, <Song_Bolero_Voice0, <Song_LowRes_Voice0,
            <Song_RoboTito_Voice0, <Song_SongOfTheBear_Voice0, <Song_DucksAway_Voice0,
            <Song_Character16Theme_Voice0, <Song_Character17Theme_Voice0, <Song_Character18Theme_Voice0, <Song_Character19Theme_Voice0,
            <Song_Character20Theme_Voice0, <Song_Character21Theme_Voice0, <Song_Character22Theme_Voice0, <Song_Character23Theme_Voice0,
            <Song_Character24Theme_Voice0, <Song_Character25Theme_Voice0, <Song_Character26Theme_Voice0, <Song_Character27Theme_Voice0,
            <Song_Character28Theme_Voice0, <Song_Character29Theme_Voice0, <Song_Character30Theme_Voice0, <Song_Chaotica_Voice0,
            <Song_AtariToday_Voice0, <Song_Interworldly_Voice0
end
          data SongPointers1H
            >Song_Grizzards_Voice0, >Song_MagicalFairyForce_Voice0, >Song_Bolero_Voice0, >Song_LowRes_Voice0,
            >Song_RoboTito_Voice0, >Song_SongOfTheBear_Voice0, >Song_DucksAway_Voice0,
            >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice0, >Song_Character18Theme_Voice0, >Song_Character19Theme_Voice0,
            >Song_Character20Theme_Voice0, >Song_Character21Theme_Voice0, >Song_Character22Theme_Voice0, >Song_Character23Theme_Voice0,
            >Song_Character24Theme_Voice0, >Song_Character25Theme_Voice0, >Song_Character26Theme_Voice0, >Song_Character27Theme_Voice0,
            >Song_Character28Theme_Voice0, >Song_Character29Theme_Voice0, >Song_Character30Theme_Voice0, >Song_Chaotica_Voice0,
            >Song_AtariToday_Voice0, >Song_Interworldly_Voice0
end
          
          rem Voice 1 stream pointer lookup tables for Bank 1
          data SongPointers1SecondL
            <Song_Grizzards_Voice1, <Song_MagicalFairyForce_Voice1, <Song_Bolero_Voice1, <Song_LowRes_Voice1,
            <Song_RoboTito_Voice1, <Song_SongOfTheBear_Voice1, <Song_DucksAway_Voice1,
            <Song_Character16Theme_Voice1, <Song_Character17Theme_Voice1, <Song_Character18Theme_Voice1, <Song_Character19Theme_Voice1,
            <Song_Character20Theme_Voice1, <Song_Character21Theme_Voice1, <Song_Character22Theme_Voice1, <Song_Character23Theme_Voice1,
            <Song_Character24Theme_Voice1, <Song_Character25Theme_Voice1, <Song_Character26Theme_Voice1, <Song_Character27Theme_Voice1,
            <Song_Character28Theme_Voice1, <Song_Character29Theme_Voice1, <Song_Character30Theme_Voice1, <Song_Chaotica_Voice1,
            <Song_AtariToday_Voice1, <Song_Interworldly_Voice1
end
          data SongPointers1SecondH
            >Song_Grizzards_Voice1, >Song_MagicalFairyForce_Voice1, >Song_Bolero_Voice1, >Song_LowRes_Voice1,
            >Song_RoboTito_Voice1, >Song_SongOfTheBear_Voice1, >Song_DucksAway_Voice1,
            >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice1, >Song_Character18Theme_Voice1, >Song_Character19Theme_Voice1,
            >Song_Character20Theme_Voice1, >Song_Character21Theme_Voice1, >Song_Character22Theme_Voice1, >Song_Character23Theme_Voice1,
            >Song_Character24Theme_Voice1, >Song_Character25Theme_Voice1, >Song_Character26Theme_Voice1, >Song_Character27Theme_Voice1,
            >Song_Character28Theme_Voice1, >Song_Character29Theme_Voice1, >Song_Character30Theme_Voice1, >Song_Chaotica_Voice1,
            >Song_AtariToday_Voice1, >Song_Interworldly_Voice1
end



