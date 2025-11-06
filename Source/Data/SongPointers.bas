          rem
          rem ChaosFight - Source/Data/SongPointers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem Song Pointer Data Tables
          rem Song pointer lookup tables (populated with symbol
          rem   addresses)
          rem Format: data SongPointersL, SongPointersH tables (29
          rem   entries: indices 0-28)
          rem Songs 0-25: Unique character theme songs in character ID
          rem   order (skipping duplicates)
          rem Character order: 0=Bernie, 1=OCascadia, 2=Revontuli,
          rem   3=EXO, 4=Grizzards,
          rem 7=MagicalFairyForce, 9=Bolero, 10=LowRes, 13=RoboTito,
          rem   14=SongOfTheBear,
          rem   15=DucksAway, 16-30=Character16Theme-Character30Theme
          rem Song 26: Chaotica (Title screen)
          rem Song 27: AtariToday (Publisher prelude)
          rem Song 28: Interworldly (Author prelude)
          
          data SongPointersL
            <Song_Bernie_Voice0, <Song_OCascadia_Voice0, <Song_Revontuli_Voice0, <Song_EXO_Voice0, <Song_Grizzards_Voice0,
            <Song_MagicalFairyForce_Voice0, <Song_Bolero_Voice0, <Song_LowRes_Voice0, <Song_RoboTito_Voice0, <Song_SongOfTheBear_Voice0,
            <Song_DucksAway_Voice0, <Song_Character16Theme_Voice0, <Song_Character17Theme_Voice0, <Song_Character18Theme_Voice0, <Song_Character19Theme_Voice0,
            <Song_Character20Theme_Voice0, <Song_Character21Theme_Voice0, <Song_Character22Theme_Voice0, <Song_Character23Theme_Voice0, <Song_Character24Theme_Voice0,
            <Song_Character25Theme_Voice0, <Song_Character26Theme_Voice0, <Song_Character27Theme_Voice0, <Song_Character28Theme_Voice0, <Song_Character29Theme_Voice0,
            <Song_Character30Theme_Voice0, <Song_Chaotica_Voice0, <Song_AtariToday_Voice0, <Song_Interworldly_Voice0
end
          data SongPointersH
            >Song_Bernie_Voice0, >Song_OCascadia_Voice0, >Song_Revontuli_Voice0, >Song_EXO_Voice0, >Song_Grizzards_Voice0,
            >Song_MagicalFairyForce_Voice0, >Song_Bolero_Voice0, >Song_LowRes_Voice0, >Song_RoboTito_Voice0, >Song_SongOfTheBear_Voice0,
            >Song_DucksAway_Voice0, >Song_Character16Theme_Voice0, >Song_Character17Theme_Voice0, >Song_Character18Theme_Voice0, >Song_Character19Theme_Voice0,
            >Song_Character20Theme_Voice0, >Song_Character21Theme_Voice0, >Song_Character22Theme_Voice0, >Song_Character23Theme_Voice0, >Song_Character24Theme_Voice0,
            >Song_Character25Theme_Voice0, >Song_Character26Theme_Voice0, >Song_Character27Theme_Voice0, >Song_Character28Theme_Voice0, >Song_Character29Theme_Voice0,
            >Song_Character30Theme_Voice0, >Song_Chaotica_Voice0, >Song_AtariToday_Voice0, >Song_Interworldly_Voice0
end
          
          rem Voice 1 stream pointer lookup tables (populated with
          rem   symbol addresses)
          rem Format: data SongPointersSecondL, SongPointersSecondH
          rem   tables (29 entries: indices 0-28)
          data SongPointersSecondL
            <Song_Bernie_Voice1, <Song_OCascadia_Voice1, <Song_Revontuli_Voice1, <Song_EXO_Voice1, <Song_Grizzards_Voice1,
            <Song_MagicalFairyForce_Voice1, <Song_Bolero_Voice1, <Song_LowRes_Voice1, <Song_RoboTito_Voice1, <Song_SongOfTheBear_Voice1,
            <Song_DucksAway_Voice1, <Song_Character16Theme_Voice1, <Song_Character17Theme_Voice1, <Song_Character18Theme_Voice1, <Song_Character19Theme_Voice1,
            <Song_Character20Theme_Voice1, <Song_Character21Theme_Voice1, <Song_Character22Theme_Voice1, <Song_Character23Theme_Voice1, <Song_Character24Theme_Voice1,
            <Song_Character25Theme_Voice1, <Song_Character26Theme_Voice1, <Song_Character27Theme_Voice1, <Song_Character28Theme_Voice1, <Song_Character29Theme_Voice1,
            <Song_Character30Theme_Voice1, <Song_Chaotica_Voice1, <Song_AtariToday_Voice1, <Song_Interworldly_Voice1
end
          data SongPointersSecondH
            >Song_Bernie_Voice1, >Song_OCascadia_Voice1, >Song_Revontuli_Voice1, >Song_EXO_Voice1, >Song_Grizzards_Voice1,
            >Song_MagicalFairyForce_Voice1, >Song_Bolero_Voice1, >Song_LowRes_Voice1, >Song_RoboTito_Voice1, >Song_SongOfTheBear_Voice1,
            >Song_DucksAway_Voice1, >Song_Character16Theme_Voice1, >Song_Character17Theme_Voice1, >Song_Character18Theme_Voice1, >Song_Character19Theme_Voice1,
            >Song_Character20Theme_Voice1, >Song_Character21Theme_Voice1, >Song_Character22Theme_Voice1, >Song_Character23Theme_Voice1, >Song_Character24Theme_Voice1,
            >Song_Character25Theme_Voice1, >Song_Character26Theme_Voice1, >Song_Character27Theme_Voice1, >Song_Character28Theme_Voice1, >Song_Character29Theme_Voice1,
            >Song_Character30Theme_Voice1, >Song_Chaotica_Voice1, >Song_AtariToday_Voice1, >Song_Interworldly_Voice1
end
