          rem ChaosFight - Source/Data/SongPointers16.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem SONG POINTER DATA TABLES - BANK 16
          rem ==========================================================
          rem Compact pointer lookup tables for songs stored in Bank 16
          rem Format: data SongPointersL16, SongPointersH16 (27 entries)
          rem Songs in Bank 16: All songs except OCascadia (1) and
          rem   Revontuli (2) which are in Bank 15
          rem Index mapping: song 0 → index 0, songs 3-28 → indices 1-26
          rem Use: if songID = 0 then index = 0, else index = songID - 2
          rem ==========================================================
          
          data SongPointersL16
            <Song_Bernie_Voice0, <Song_EXO_Voice0, <Song_Grizzards_Voice0,
            <Song_MagicalFairyForce_Voice0, <Song_Bolero_Voice0, <Song_LowRes_Voice0, <Song_RoboTito_Voice0, <Song_SongOfTheBear_Voice0,
            <Song_DucksAway_Voice0, <Song_Character16Theme_Voice0, <Song_Character17Theme_Voice0, <Song_Character18Theme_Voice0, <Song_Character19Theme_Voice0,
            <Song_Character20Theme_Voice0, <Song_Character21Theme_Voice0, <Song_Character22Theme_Voice0, <Song_Character23Theme_Voice0, <Song_Character24Theme_Voice0,
            <Song_Character25Theme_Voice0, <Song_Character26Theme_Voice0, <Song_Character27Theme_Voice0, <Song_Character28Theme_Voice0, <Song_Character29Theme_Voice0,
            <Song_Character30Theme_Voice0, <Song_Chaotica_Voice0, <Song_AtariToday_Voice0, <Song_Interworldly_Voice0
end
          data SongPointersH16
            >Song_Bernie_Voice0, >Song_EXO_Voice0, >Song_Grizzards_Voice0,
            >Song_MagicalFairyForce_Voice0, >Song_Bolero_Voice0, >Song_LowRes_Voice0, >Song_RoboTito_Voice0, >Song_SongOfTheBear_Voice0,
            >Song_DucksAway_Voice0, >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice0, >Song_Character18Theme_Voice0, >Song_Character19Theme_Voice0,
            >Song_Character20Theme_Voice0, >Song_Character21Theme_Voice0, >Song_Character22Theme_Voice0, >Song_Character23Theme_Voice0, >Song_Character24Theme_Voice0,
            >Song_Character25Theme_Voice0, >Song_Character26Theme_Voice0, >Song_Character27Theme_Voice0, >Song_Character28Theme_Voice0, >Song_Character29Theme_Voice0,
            >Song_Character30Theme_Voice0, >Song_Chaotica_Voice0, >Song_AtariToday_Voice0, >Song_Interworldly_Voice0
end
          
          rem Voice 1 stream pointer lookup tables for Bank 16
          data SongPointersSecondL16
            <Song_Bernie_Voice1, <Song_EXO_Voice1, <Song_Grizzards_Voice1,
            <Song_MagicalFairyForce_Voice1, <Song_Bolero_Voice1, <Song_LowRes_Voice1, <Song_RoboTito_Voice1, <Song_SongOfTheBear_Voice1,
            <Song_DucksAway_Voice1, <Song_Character16Theme_Voice1, <Song_Character17Theme_Voice1, <Song_Character18Theme_Voice1, <Song_Character19Theme_Voice1,
            <Song_Character20Theme_Voice1, <Song_Character21Theme_Voice1, <Song_Character22Theme_Voice1, <Song_Character23Theme_Voice1, <Song_Character24Theme_Voice1,
            <Song_Character25Theme_Voice1, <Song_Character26Theme_Voice1, <Song_Character27Theme_Voice1, <Song_Character28Theme_Voice1, <Song_Character29Theme_Voice1,
            <Song_Character30Theme_Voice1, <Song_Chaotica_Voice1, <Song_AtariToday_Voice1, <Song_Interworldly_Voice1
end
          data SongPointersSecondH16
            >Song_Bernie_Voice1, >Song_EXO_Voice1, >Song_Grizzards_Voice1,
            >Song_MagicalFairyForce_Voice1, >Song_Bolero_Voice1, >Song_LowRes_Voice1, >Song_RoboTito_Voice1, >Song_SongOfTheBear_Voice1,
            >Song_DucksAway_Voice1, >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice1, >Song_Character18Theme_Voice1, >Song_Character19Theme_Voice1,
            >Song_Character20Theme_Voice1, >Song_Character21Theme_Voice1, >Song_Character22Theme_Voice1, >Song_Character23Theme_Voice1, >Song_Character24Theme_Voice1,
            >Song_Character25Theme_Voice1, >Song_Character26Theme_Voice1, >Song_Character27Theme_Voice1, >Song_Character28Theme_Voice1, >Song_Character29Theme_Voice1,
            >Song_Character30Theme_Voice1, >Song_Chaotica_Voice1, >Song_AtariToday_Voice1, >Song_Interworldly_Voice1
end


          
          rem ==========================================================
          rem SONG POINTER DATA TABLES - BANK 16
          rem ==========================================================
          rem Compact pointer lookup tables for songs stored in Bank 16
          rem Format: data SongPointersL16, SongPointersH16 (27 entries)
          rem Songs in Bank 16: All songs except OCascadia (1) and
          rem   Revontuli (2) which are in Bank 15
          rem Index mapping: song 0 → index 0, songs 3-28 → indices 1-26
          rem Use: if songID = 0 then index = 0, else index = songID - 2
          rem ==========================================================
          
          data SongPointersL16
            <Song_Bernie_Voice0, <Song_EXO_Voice0, <Song_Grizzards_Voice0,
            <Song_MagicalFairyForce_Voice0, <Song_Bolero_Voice0, <Song_LowRes_Voice0, <Song_RoboTito_Voice0, <Song_SongOfTheBear_Voice0,
            <Song_DucksAway_Voice0, <Song_Character16Theme_Voice0, <Song_Character17Theme_Voice0, <Song_Character18Theme_Voice0, <Song_Character19Theme_Voice0,
            <Song_Character20Theme_Voice0, <Song_Character21Theme_Voice0, <Song_Character22Theme_Voice0, <Song_Character23Theme_Voice0, <Song_Character24Theme_Voice0,
            <Song_Character25Theme_Voice0, <Song_Character26Theme_Voice0, <Song_Character27Theme_Voice0, <Song_Character28Theme_Voice0, <Song_Character29Theme_Voice0,
            <Song_Character30Theme_Voice0, <Song_Chaotica_Voice0, <Song_AtariToday_Voice0, <Song_Interworldly_Voice0
end
          data SongPointersH16
            >Song_Bernie_Voice0, >Song_EXO_Voice0, >Song_Grizzards_Voice0,
            >Song_MagicalFairyForce_Voice0, >Song_Bolero_Voice0, >Song_LowRes_Voice0, >Song_RoboTito_Voice0, >Song_SongOfTheBear_Voice0,
            >Song_DucksAway_Voice0, >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice0, >Song_Character18Theme_Voice0, >Song_Character19Theme_Voice0,
            >Song_Character20Theme_Voice0, >Song_Character21Theme_Voice0, >Song_Character22Theme_Voice0, >Song_Character23Theme_Voice0, >Song_Character24Theme_Voice0,
            >Song_Character25Theme_Voice0, >Song_Character26Theme_Voice0, >Song_Character27Theme_Voice0, >Song_Character28Theme_Voice0, >Song_Character29Theme_Voice0,
            >Song_Character30Theme_Voice0, >Song_Chaotica_Voice0, >Song_AtariToday_Voice0, >Song_Interworldly_Voice0
end
          
          rem Voice 1 stream pointer lookup tables for Bank 16
          data SongPointersSecondL16
            <Song_Bernie_Voice1, <Song_EXO_Voice1, <Song_Grizzards_Voice1,
            <Song_MagicalFairyForce_Voice1, <Song_Bolero_Voice1, <Song_LowRes_Voice1, <Song_RoboTito_Voice1, <Song_SongOfTheBear_Voice1,
            <Song_DucksAway_Voice1, <Song_Character16Theme_Voice1, <Song_Character17Theme_Voice1, <Song_Character18Theme_Voice1, <Song_Character19Theme_Voice1,
            <Song_Character20Theme_Voice1, <Song_Character21Theme_Voice1, <Song_Character22Theme_Voice1, <Song_Character23Theme_Voice1, <Song_Character24Theme_Voice1,
            <Song_Character25Theme_Voice1, <Song_Character26Theme_Voice1, <Song_Character27Theme_Voice1, <Song_Character28Theme_Voice1, <Song_Character29Theme_Voice1,
            <Song_Character30Theme_Voice1, <Song_Chaotica_Voice1, <Song_AtariToday_Voice1, <Song_Interworldly_Voice1
end
          data SongPointersSecondH16
            >Song_Bernie_Voice1, >Song_EXO_Voice1, >Song_Grizzards_Voice1,
            >Song_MagicalFairyForce_Voice1, >Song_Bolero_Voice1, >Song_LowRes_Voice1, >Song_RoboTito_Voice1, >Song_SongOfTheBear_Voice1,
            >Song_DucksAway_Voice1, >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice1, >Song_Character18Theme_Voice1, >Song_Character19Theme_Voice1,
            >Song_Character20Theme_Voice1, >Song_Character21Theme_Voice1, >Song_Character22Theme_Voice1, >Song_Character23Theme_Voice1, >Song_Character24Theme_Voice1,
            >Song_Character25Theme_Voice1, >Song_Character26Theme_Voice1, >Song_Character27Theme_Voice1, >Song_Character28Theme_Voice1, >Song_Character29Theme_Voice1,
            >Song_Character30Theme_Voice1, >Song_Chaotica_Voice1, >Song_AtariToday_Voice1, >Song_Interworldly_Voice1
end

